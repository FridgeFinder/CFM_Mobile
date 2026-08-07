import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/domain/models/subscription_preferences.dart';
import '../../features/auth/data/repositories/notifications_repository.dart';
import '../../features/map/domain/models/fridge_domain.dart';
import 'auth_provider.dart';
import '../utils/app_logger.dart';
import 'notification_providers.dart';

part 'subscriptions_provider.g.dart';

const _subscriptionsCacheBoxName = 'subscriptions_cache';

String _subscriptionsCacheKey(String userId) => 'subscriptions_$userId';

Map<String, List<SubscriptionPreferences>> _lastSubscriptionsSnapshots = {};

Future<bool> _ensureHiveInitialized() async {
  try {
    await Hive.initFlutter();
    return true;
  } on MissingPluginException catch (_) {
    return false;
  } catch (e) {
    if (e.toString().contains('already initialized')) {
      return true;
    }
    logger.w('Unable to initialize Hive: $e');
    return false;
  }
}

Future<Box<String>?> _openSubscriptionsCacheBox() async {
  try {
    if (!await _ensureHiveInitialized()) {
      return null;
    }
    if (Hive.isBoxOpen(_subscriptionsCacheBoxName)) {
      return Hive.box<String>(_subscriptionsCacheBoxName);
    }
    return await Hive.openBox<String>(_subscriptionsCacheBoxName);
  } catch (e) {
    if (e.toString().contains('initialize Hive') ||
        e.toString().contains('You need to initialize Hive')) {
      return null;
    }
    logger.w('Unable to open subscriptions cache box: $e');
    return null;
  }
}

List<SubscriptionPreferences> _decodeSubscriptions(String? rawJson) {
  if (rawJson == null || rawJson.isEmpty) return const [];

  try {
    final decoded = jsonDecode(rawJson);
    if (decoded is! List) return const [];

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(SubscriptionPreferences.fromJson)
        .toList();
  } catch (e) {
    logger.w('Unable to decode subscriptions cache: $e');
    return const [];
  }
}

String _encodeSubscriptions(List<SubscriptionPreferences> subscriptions) {
  final normalized = subscriptions
      .map((subscription) => subscription.toJson())
      .toList()
    ..sort((a, b) {
      final fridgeA = a['fridgeId'] as String? ?? '';
      final fridgeB = b['fridgeId'] as String? ?? '';
      return fridgeA.compareTo(fridgeB);
    });

  return jsonEncode(normalized);
}

/// Provider for user's subscribed fridges
@riverpod
Stream<List<SubscriptionPreferences>> subscribedFridges(
  Ref ref,
) async* {
  final authUserAsync = ref.watch(currentAuthUserProvider);
  final authUser = authUserAsync.when(
    data: (user) => user,
    loading: () => null,
    error: (_, _) => null,
  );
  if (authUser == null) {
    yield [];
    return;
  }

  final cacheBox = await _openSubscriptionsCacheBox();
  final cacheKey = _subscriptionsCacheKey(authUser.uid);
  final cachedRaw = cacheBox?.get(cacheKey);
  final cachedSubscriptions = _decodeSubscriptions(cachedRaw);

  final previousSnapshot = _lastSubscriptionsSnapshots[authUser.uid];
  if (previousSnapshot != null && previousSnapshot.isNotEmpty && cachedSubscriptions.isEmpty) {
    yield previousSnapshot;
  }

  if (cachedSubscriptions.isNotEmpty) {
    yield cachedSubscriptions;
  }

  final repository = ref.watch(notificationsRepositoryProvider);
  try {
    final subscriptions = await repository.getAllForUser(authUser.uid);
    final latestRaw = _encodeSubscriptions(subscriptions);
    if (cacheBox != null && latestRaw != cachedRaw) {
      await cacheBox.put(cacheKey, latestRaw);
    }

    _lastSubscriptionsSnapshots[authUser.uid] = subscriptions;

    if (latestRaw != cachedRaw || cachedSubscriptions.isEmpty) {
      yield subscriptions;
    }
  } catch (e) {
    logger.w('Failed to refresh subscriptions from API: $e');
    if (cachedSubscriptions.isEmpty) {
      rethrow;
    }
  }
}

/// Provider for checking if a fridge is subscribed
@riverpod
bool isFridgeSubscribed(
  Ref ref,
  String fridgeId,
) {
  final subscriptionsAsync = ref.watch(subscribedFridgesProvider);
  return subscriptionsAsync.when(
    data: (subscriptions) =>
        subscriptions.any((sub) => sub.fridgeId == fridgeId),
    loading: () => false,
    error: (_, _) => false,
  );
}

/// Provider for subscription preferences for a specific fridge
@riverpod
SubscriptionPreferences? fridgeSubscriptionPreferences(
  Ref ref,
  String fridgeId,
) {
  final subscriptionsAsync = ref.watch(subscribedFridgesProvider);
  return subscriptionsAsync.when(
    data: (subscriptions) {
      try {
        return subscriptions.firstWhere((sub) => sub.fridgeId == fridgeId);
      } catch (_) {
        return null;
      }
    },
    loading: () => null,
    error: (_, _) => null,
  );
}

/// Notifier for managing subscriptions
@riverpod
class SubscriptionManager extends _$SubscriptionManager {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  void _invalidateSubscriptionViews(String fridgeId) {
    ref.invalidate(subscribedFridgesProvider);
    ref.invalidate(isFridgeSubscribedProvider(fridgeId));
    ref.invalidate(fridgeSubscriptionPreferencesProvider(fridgeId));
  }

  /// Follow a fridge with notification preferences
  /// Throws if the fridge condition is notAtLocation or ghost.
  Future<void> followFridge(
    String fridgeId,
    NotificationPreferences preferences, {
    FridgeCondition? fridgeCondition,
  }) async {
    if (fridgeCondition == FridgeCondition.notAtLocation) {
      throw Exception('Cannot follow a fridge that is not at its location');
    }
    if (fridgeCondition == FridgeCondition.ghost) {
      throw Exception('Cannot follow a ghost fridge');
    }

    try {
      final authUserAsync = ref.read(currentAuthUserProvider);
      final authUser = authUserAsync.when(
        data: (user) => user,
        loading: () => null,
        error: (_, _) => null,
      );
      if (authUser == null) {
        throw Exception('User must be authenticated');
      }

      // Check if this is truly the first subscription from backend source of truth.
      final repository = ref.read(notificationsRepositoryProvider);
      final existingSubscriptions = await repository.getAllForUser(authUser.uid);
      if (!ref.mounted) return;

      final isFirstSubscription = existingSubscriptions.isEmpty;

      final subscription = SubscriptionPreferences(
        fridgeId: fridgeId,
        subscribedAt: DateTime.now(),
        notificationPreferences: preferences,
      );

      await repository.followFridge(
        userId: authUser.uid,
        fridgeId: fridgeId,
        preferences: subscription.notificationPreferences,
      );
      if (!ref.mounted) return;
      _invalidateSubscriptionViews(fridgeId);

      logger.i('Subscribed to fridge: $fridgeId');

      // If this is the first subscription, request notification permissions
      if (isFirstSubscription) {
        logger.i('First subscription detected - requesting notification permissions');
        final fcmService = ref.read(fcmServiceProvider);
        final permissionsGranted = await fcmService.requestPermissionsAndGetToken();

        // Check if provider is still mounted after async operation
        if (!ref.mounted) return;

        if (permissionsGranted) {
          logger.i('Notification permissions granted for first subscription');
        } else {
          logger.w('Notification permissions not granted - user can enable later in settings');
        }
      }
    } catch (e) {
      logger.e('Error subscribing to fridge: $e');
      rethrow;
    }
  }

  /// Unfollow a fridge
  Future<void> unfollowFridge(String fridgeId) async {
    try {
      final authUserAsync = ref.read(currentAuthUserProvider);
      final authUser = authUserAsync.when(
        data: (user) => user,
        loading: () => null,
        error: (_, _) => null,
      );
      if (authUser == null) {
        throw Exception('User must be authenticated');
      }

        final repository = ref.read(notificationsRepositoryProvider);
        await repository.unfollowFridge(userId: authUser.uid, fridgeId: fridgeId);
        if (!ref.mounted) return;
        _invalidateSubscriptionViews(fridgeId);

      logger.i('Unsubscribed from fridge: $fridgeId');
    } catch (e) {
      logger.e('Error unsubscribing from fridge: $e');
      rethrow;
    }
  }

  /// Update notification preferences for a subscribed fridge
  Future<void> updateNotificationPreferences(
    String fridgeId,
    NotificationPreferences preferences,
  ) async {
    try {
      final authUserAsync = ref.read(currentAuthUserProvider);
      final authUser = authUserAsync.when(
        data: (user) => user,
        loading: () => null,
        error: (_, _) => null,
      );
      if (authUser == null) {
        throw Exception('User must be authenticated');
      }

      final repository = ref.read(notificationsRepositoryProvider);
      await repository.updatePreferences(
        userId: authUser.uid,
        fridgeId: fridgeId,
        preferences: preferences,
      );
      if (!ref.mounted) return;
      _invalidateSubscriptionViews(fridgeId);

      logger.i('Updated notification preferences for fridge: $fridgeId');
    } catch (e) {
      logger.e('Error updating notification preferences: $e');
      rethrow;
    }
  }
}


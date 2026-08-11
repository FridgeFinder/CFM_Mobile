import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exceptions/app_exception.dart';
import '../../features/auth/domain/models/fridge_notification_preferences.dart';
import '../../features/auth/data/repositories/notifications_repository.dart';
import '../../features/map/domain/models/fridge_domain.dart';
import 'auth_provider.dart';
import '../utils/app_logger.dart';
import '../utils/fridge_id_utils.dart';
import 'notification_providers.dart';

part 'followed_fridges_provider.g.dart';

const _followedFridgesCacheBoxName = 'followed_fridges_cache';

String _followedFridgesCacheKey(String userId) => 'followed_fridges_$userId';

Map<String, List<FridgeNotificationPreferences>> _lastFollowedFridgesSnapshots = {};

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

Future<Box<String>?> _openFollowedFridgesCacheBox() async {
  try {
    if (!await _ensureHiveInitialized()) {
      return null;
    }
    if (Hive.isBoxOpen(_followedFridgesCacheBoxName)) {
      return Hive.box<String>(_followedFridgesCacheBoxName);
    }
    return await Hive.openBox<String>(_followedFridgesCacheBoxName);
  } catch (e) {
    if (e.toString().contains('initialize Hive') ||
        e.toString().contains('You need to initialize Hive')) {
      return null;
    }
    logger.w('Unable to open followed fridges cache box: $e');
    return null;
  }
}

List<FridgeNotificationPreferences> _decodeFollowedFridges(String? rawJson) {
  if (rawJson == null || rawJson.isEmpty) return const [];

  try {
    final decoded = jsonDecode(rawJson);
    if (decoded is! List) return const [];

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(FridgeNotificationPreferences.fromJson)
        .toList();
  } catch (e) {
    logger.w('Unable to decode followed fridges cache: $e');
    return const [];
  }
}

String _encodeFollowedFridges(List<FridgeNotificationPreferences> followedFridges) {
  final normalized = followedFridges
      .map((followedFridge) => followedFridge.toJson())
      .toList()
    ..sort((a, b) {
      final fridgeA = a['fridgeId'] as String? ?? '';
      final fridgeB = b['fridgeId'] as String? ?? '';
      return fridgeA.compareTo(fridgeB);
    });

  return jsonEncode(normalized);
}

/// Provider for user's followed fridges
@riverpod
Stream<List<FridgeNotificationPreferences>> followedFridges(
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

  final cacheBox = await _openFollowedFridgesCacheBox();
  final cacheKey = _followedFridgesCacheKey(authUser.uid);
  final cachedRaw = cacheBox?.get(cacheKey);
  final cachedFollowedFridges = _decodeFollowedFridges(cachedRaw);

  final previousSnapshot = _lastFollowedFridgesSnapshots[authUser.uid];
  if (previousSnapshot != null && previousSnapshot.isNotEmpty && cachedFollowedFridges.isEmpty) {
    yield previousSnapshot;
  }

  if (cachedFollowedFridges.isNotEmpty) {
    yield cachedFollowedFridges;
  }

  final repository = ref.watch(notificationsRepositoryProvider);
  try {
    final followedFridges = await repository.getAllForUser(authUser.uid);
    final latestRaw = _encodeFollowedFridges(followedFridges);
    if (cacheBox != null && latestRaw != cachedRaw) {
      await cacheBox.put(cacheKey, latestRaw);
    }

    _lastFollowedFridgesSnapshots[authUser.uid] = followedFridges;

    if (latestRaw != cachedRaw || cachedFollowedFridges.isEmpty) {
      yield followedFridges;
    }
  } on NotFoundException catch (e) {
    logger.w('Followed fridges endpoint returned not found; treating as empty list: $e');
    const followedFridges = <FridgeNotificationPreferences>[];
    final latestRaw = _encodeFollowedFridges(followedFridges);
    if (cacheBox != null && latestRaw != cachedRaw) {
      await cacheBox.put(cacheKey, latestRaw);
    }

    _lastFollowedFridgesSnapshots[authUser.uid] = followedFridges;

    if (latestRaw != cachedRaw || cachedFollowedFridges.isEmpty) {
      yield followedFridges;
    }
  } catch (e) {
    logger.w('Failed to refresh followed fridges from API: $e');
    if (cachedFollowedFridges.isEmpty) {
      rethrow;
    }
  }
}

/// Provider for checking if a fridge is followed
@riverpod
bool isFridgeFollowed(
  Ref ref,
  String fridgeId,
) {
  final followedFridgesAsync = ref.watch(followedFridgesProvider);
  return followedFridgesAsync.when(
    data: (followedFridges) =>
        followedFridges.any((followedFridge) => fridgeIdsMatch(followedFridge.fridgeId, fridgeId)),
    loading: () => false,
    error: (_, _) => false,
  );
}

/// Provider for alert preferences for a specific fridge.
@riverpod
FridgeNotificationPreferences? fridgeAlertPreferences(
  Ref ref,
  String fridgeId,
) {
  final followedFridgesAsync = ref.watch(followedFridgesProvider);
  return followedFridgesAsync.when(
    data: (followedFridges) {
      try {
        return followedFridges.firstWhere(
          (followedFridge) => fridgeIdsMatch(followedFridge.fridgeId, fridgeId),
        );
      } catch (_) {
        return null;
      }
    },
    loading: () => null,
    error: (_, _) => null,
  );
}

/// Notifier for managing followed fridges.
@riverpod
class FollowManager extends _$FollowManager {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  void _invalidateFollowViews(String fridgeId) {
    ref.invalidate(followedFridgesProvider);
    ref.invalidate(isFridgeFollowedProvider(fridgeId));
    ref.invalidate(fridgeAlertPreferencesProvider(fridgeId));
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

      // Check if this is truly the first followed fridge from backend source of truth.
      final repository = ref.read(notificationsRepositoryProvider);
      final existingFollowedFridges = await repository.getAllForUser(authUser.uid);

      final isFirstFollow = existingFollowedFridges.isEmpty;

      final followedFridge = FridgeNotificationPreferences(
        fridgeId: fridgeId,
        notificationPreferences: preferences,
      );

      await repository.followFridge(
        userId: authUser.uid,
        fridgeId: fridgeId,
        preferences: followedFridge.notificationPreferences,
      );

      // Verify the follow is persisted before surfacing success to the UI.
      FridgeNotificationPreferences? persistedFollow;
      for (var attempt = 0; attempt < 3; attempt++) {
        persistedFollow = await repository.getForFridge(
          userId: authUser.uid,
          fridgeId: fridgeId,
        );
        if (persistedFollow != null) {
          break;
        }
        await Future.delayed(const Duration(milliseconds: 200));
      }

      if (persistedFollow == null) {
        throw Exception(
          'Follow request did not persist on the server. Please try again.',
        );
      }

      if (!ref.mounted) return;
      _invalidateFollowViews(fridgeId);

      logger.i('Followed fridge: $fridgeId');

      // If this is the first follow, request notification permissions.
      if (isFirstFollow) {
        logger.i('First follow detected - requesting notification permissions');
        final fcmService = ref.read(fcmServiceProvider);
        final permissionsGranted = await fcmService.requestPermissionsAndGetToken();

        // Check if provider is still mounted after async operation
        if (!ref.mounted) return;

        if (permissionsGranted) {
          logger.i('Notification permissions granted for first follow');
        } else {
          logger.w('Notification permissions not granted - user can enable later in settings');
        }
      }
    } catch (e) {
      logger.e('Error following fridge: $e');
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
        _invalidateFollowViews(fridgeId);

      logger.i('Unfollowed fridge: $fridgeId');
    } catch (e) {
      logger.e('Error unfollowing fridge: $e');
      rethrow;
    }
  }

  /// Update notification preferences for a followed fridge
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
      _invalidateFollowViews(fridgeId);

      logger.i('Updated notification preferences for fridge: $fridgeId');
    } catch (e) {
      logger.e('Error updating notification preferences: $e');
      rethrow;
    }
  }
}


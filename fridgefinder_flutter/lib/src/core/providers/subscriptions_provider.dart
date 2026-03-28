import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/domain/models/subscription_preferences.dart';
import '../../features/map/domain/models/fridge_domain.dart';
import 'auth_provider.dart';
import 'database_provider.dart';
import '../utils/app_logger.dart';
import '../utils/firebase_helpers.dart';
import 'notification_providers.dart';

part 'subscriptions_provider.g.dart';

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

  final database = DatabaseProvider.databaseRef;
  final subscriptionsRef = database
      .child('users')
      .child(authUser.uid)
      .child('subscribedFridges');

  yield* subscriptionsRef.onValue.map((event) {
    if (!event.snapshot.exists) {
      return <SubscriptionPreferences>[];
    }

    final data = event.snapshot.value;
    if (data is! Map) {
      return <SubscriptionPreferences>[];
    }

    return data.entries.map((entry) {
      final fridgeId = entry.key;
      final value = entry.value as Map<Object?, Object?>;
      final convertedValue = convertFirebaseMap(value);
      return SubscriptionPreferences.fromJson({
        'fridgeId': fridgeId,
        ...convertedValue,
      });
    }).toList();
  });
}

/// Provider for checking if a fridge is subscribed
@riverpod
Future<bool> isFridgeSubscribed(
  Ref ref,
  String fridgeId,
) async {
  final subscriptions = await ref.watch(subscribedFridgesProvider.future);
  return subscriptions.any((sub) => sub.fridgeId == fridgeId);
}

/// Provider for subscription preferences for a specific fridge
@riverpod
Future<SubscriptionPreferences?> fridgeSubscriptionPreferences(
  Ref ref,
  String fridgeId,
) async {
  final subscriptions = await ref.watch(subscribedFridgesProvider.future);
  try {
    return subscriptions.firstWhere((sub) => sub.fridgeId == fridgeId);
  } catch (e) {
    return null;
  }
}

/// Notifier for managing subscriptions
@riverpod
class SubscriptionManager extends _$SubscriptionManager {
  @override
  FutureOr<void> build() {
    // No initial state needed
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

      // Check if this is the user's first subscription
      final existingSubscriptions = await ref.read(subscribedFridgesProvider.future);
      if (!ref.mounted) return;

      final isFirstSubscription = existingSubscriptions.isEmpty;

      final database = DatabaseProvider.databaseRef;
      final subscriptionRef = database
          .child('users')
          .child(authUser.uid)
          .child('subscribedFridges')
          .child(fridgeId);

      final subscription = SubscriptionPreferences(
        fridgeId: fridgeId,
        subscribedAt: DateTime.now(),
        notificationPreferences: preferences,
      );

      await subscriptionRef.set(subscription.toJson());
      if (!ref.mounted) return;

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

          // Also request geofencing permission if user is a volunteer
          final userProfileAsync = ref.read(userProfileProvider);
          userProfileAsync.whenData((profile) async {
            if (profile != null && profile.isVolunteer) {
              // Geofencing will be enabled when user enables it in settings
              // For now, just log that we could request it
              logger.d('User is volunteer - geofencing can be enabled in settings');
            }
          });
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

      final database = DatabaseProvider.databaseRef;
      await database
          .child('users')
          .child(authUser.uid)
          .child('subscribedFridges')
          .child(fridgeId)
          .remove();

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

      final database = DatabaseProvider.databaseRef;
      await database
          .child('users')
          .child(authUser.uid)
          .child('subscribedFridges')
          .child(fridgeId)
          .child('notificationPreferences')
          .update(preferences.toJson());

      logger.i('Updated notification preferences for fridge: $fridgeId');
    } catch (e) {
      logger.e('Error updating notification preferences: $e');
      rethrow;
    }
  }
}


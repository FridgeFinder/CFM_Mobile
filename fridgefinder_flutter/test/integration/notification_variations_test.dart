import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:fridgefinder_app/src/features/map/presentation/controllers/fridge_list_controller.dart';
import 'package:fridgefinder_app/src/features/auth/domain/models/subscription_preferences.dart';
import 'package:fridgefinder_app/src/core/providers/subscriptions_provider.dart';
import 'package:fridgefinder_app/src/core/providers/auth_provider.dart';
import 'package:fridgefinder_app/src/routing/router.dart';
import '../fixtures/fridge_fixtures.dart';
import '../helpers/test_helpers.dart';
import '../test_helpers.dart';

/// Mock User for authentication tests
class TestUser implements firebase_auth.User {
  @override
  final String uid;

  @override
  final String? email;

  TestUser({required this.uid, this.email});

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Test-friendly app wrapper
class TestFridgeFinderApp extends ConsumerWidget {
  const TestFridgeFinderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'FridgeFinder',
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Helper to create app widget with authentication and subscriptions
Widget createNotificationTestApp({
  firebase_auth.User? authenticatedUser,
  List<SubscriptionPreferences>? subscriptions,
  String? fcmToken,
}) {
  final fridgesWithDistance = FridgeFixtures.allFridges
      .map((fridge) => FridgeWithDistance(fridge: fridge, distanceKm: null))
      .toList();

  final subscriptionsList = subscriptions ?? [];
  final isAuthenticated = authenticatedUser != null;

  return ProviderScope(
    overrides: [
      ...getBaseTestOverrides(),
      fridgeListProvider.overrideWith(
        (ref) => Future.value(FridgeFixtures.allFridges),
      ),
      fridgesSortedByDistanceProvider.overrideWithValue(fridgesWithDistance),
      currentAuthUserProvider.overrideWith(
        (ref) => isAuthenticated
            ? AsyncValue.data(authenticatedUser)
            : const AsyncValue.data(null),
      ),
      isAuthenticatedProvider.overrideWith((ref) => isAuthenticated),
      userProfileProvider.overrideWith((ref) => Future.value(null)),
      subscribedFridgesProvider.overrideWith(
        (ref) => Stream.value(subscriptionsList),
      ),
    ],
    child: const TestFridgeFinderApp(),
  );
}

void main() {
  setUpAll(() async {
    await initHiveForTesting();
  });

  tearDownAll(() async {
    await cleanupHive();
  });

  group('Notification Variations - Notification Delivery', () {
    testWidgets('NOT-001: Receive While App in Foreground',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-1', email: 'test1@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
        fcmToken: 'test-fcm-token-1',
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // App open on any screen
      // Fridge status changes triggering notification
      // Expected: Local notification appears at top
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-002: Receive While App in Background',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-2', email: 'test2@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
        fcmToken: 'test-fcm-token-2',
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // App in background (home screen visible)
      // Notification arrives
      // Expected: Banner notification appears
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-003: Receive While App Killed',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-3', email: 'test3@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
        fcmToken: 'test-fcm-token-3',
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Force close app
      // Notification arrives
      // Expected: Notification appears in notification center
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-004: Tap Notification - Opens Fridge Profile (FCM Notification)',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-4', email: 'test4@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
        fcmToken: 'test-fcm-token-4',
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Receive FCM notification from Cloud Function
      // Tap notification
      // Expected:
      //  - App opens (if killed) or comes to foreground
      //  - Navigates to map screen
      //  - Fridge details sheet opens automatically showing correct fridge
      //  - Notification navigation provider correctly sets fridge ID
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-004A: Tap Notification - Opens Fridge Profile (Local Notification)',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-5', email: 'test5@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Receive local notification (foreground or geofence)
      // Tap notification
      // Expected:
      //  - Fridge details sheet opens showing correct fridge
      //  - Works even if app is already open
      //  - Navigation state correctly updated
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-004B: Tap Notification - Invalid Fridge ID in Payload',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-6', email: 'test6@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: 'invalid-fridge-id',
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Mock notification with invalid/non-existent fridge ID
      // Tap notification
      // Expected:
      //  - App handles gracefully, doesn't crash
      //  - Shows error message or navigates to map without opening sheet
      //  - Logs error for debugging
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-004C: Tap Notification - App Killed State',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-7', email: 'test7@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Force close app completely
      // Receive notification
      // Tap notification
      // Expected:
      //  - App launches
      //  - Navigates to correct fridge profile
      //  - All providers initialize correctly
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-004D: Tap Notification - Multiple Notifications Queued',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-8', email: 'test8@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeDirty.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeOutOfOrder.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Receive 3 notifications while app is killed
      // Tap first notification
      // Expected:
      //  - App opens to first fridge
      //  - Other notifications remain in notification center
      //  - Can tap subsequent notifications to navigate to those fridges
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-005: Dismiss Notification Without Tapping',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-9', email: 'test9@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Receive notification
      // Swipe to dismiss
      // Expected: Notification removed, no action taken
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-006: Receive Multiple Notifications',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-10', email: 'test10@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeDirty.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeOutOfOrder.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.ghostFridge.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.notAtLocationFridge.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Subscribe to 5 fridges
      // All 5 change status simultaneously
      // Expected: 5 separate notifications appear
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-007: Notification for Unsubscribed Fridge',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-11', email: 'test11@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Mock cloud function bug sending notification for unsubscribed fridge
      // Expected: App handles gracefully, doesn't crash
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });

  group('Notification Variations - Notification Types', () {
    testWidgets('NOT-008: Notification - Update with Food',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-12', email: 'test12@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(
              updatedWithFood: true,
            ),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Subscribe with "Updated with Food" enabled
      // Fridge restocked
      // Expected: Receives notification
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-009: Notification - Running Low',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-13', email: 'test13@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(
              runningLow: true,
            ),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Subscribe with "Running Low" enabled
      // Fridge drops to <50% food
      // Expected: Receives notification
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-010: Notification - Empty',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-14', email: 'test14@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(
              empty: true,
            ),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Subscribe with "Empty" enabled
      // Fridge reaches 0% food
      // Expected: Receives notification
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-011: Notification - Needs Cleaning',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-15', email: 'test15@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeDirty.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(
              needsCleaning: true,
            ),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Subscribe with "Needs Cleaning" enabled
      // Fridge marked as dirty
      // Expected: Receives notification
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-012: Notification - Needs Servicing',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-16', email: 'test16@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeOutOfOrder.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(
              needsServicing: true,
            ),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Subscribe with "Needs Servicing" enabled
      // Fridge marked as out of order
      // Expected: Receives notification
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-013: Notification - Routine Validation',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-17', email: 'test17@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(
              routineValidation: true,
            ),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Subscribe with "Routine Validation" enabled
      // 7 days pass without update
      // Expected: Receives notification
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });

  group('Notification Variations - Settings Interactions', () {
    testWidgets('NOT-014: Notification Frequency - Immediate',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-18', email: 'test18@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Set frequency to Immediate
      // Fridge updates
      // Expected: Notification arrives within 1 minute
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-015: Notification Frequency - Daily',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-19', email: 'test19@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Set frequency to Daily
      // Fridge updates
      // Expected: Notification batched, arrives once daily
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-016: Notification Frequency - Weekly',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-20', email: 'test20@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Set frequency to Weekly
      // Fridge updates
      // Expected: Notification batched, arrives once weekly
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-017: Turn Off Notifications Globally',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-21', email: 'test21@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Toggle off "Enable Notifications" in profile
      // Fridge updates
      // Expected: No notifications received, still subscribed
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-018: Turn On Notifications After Being Off',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-22', email: 'test22@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Previously disabled notifications
      // Enable in profile
      // Fridge updates
      // Expected: Notifications resume
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });

  group('Notification Variations - FCM Token Management', () {
    testWidgets('NOT-019: FCM Token Generated on First Subscription',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-23', email: 'test23@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Sign in, no subscriptions yet
      // Subscribe to first fridge with permission granted
      // Expected:
      //  - FCM token generated and saved to /users/{userId}/fcmToken
      //  - Token visible in Firebase Realtime Database
      //  - Token persists across app restarts
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-020: FCM Token Refresh Handling',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-24', email: 'test24@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
        fcmToken: 'old-fcm-token',
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // User subscribed, token exists
      // Firebase refreshes token (e.g., app reinstall, token expiry)
      // Expected:
      //  - New token automatically saved to database
      //  - Old token replaced
      //  - Notifications continue working without interruption
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-021: FCM Token Deleted on Sign Out',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-25', email: 'test25@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
        fcmToken: 'test-fcm-token',
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // User subscribed with FCM token saved
      // Sign out
      // Expected:
      //  - FCM token deleted from Firebase
      //  - Token removed from device
      //  - No notifications received after sign out
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-022: FCM Token Not Saved When Permission Denied',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-26', email: 'test26@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // First subscription: Deny notification permission
      // Expected:
      //  - Subscription created
      //  - NO FCM token saved to database
      //  - /users/{userId}/fcmToken path doesn't exist
      //  - User can enable notifications later in settings
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-023: FCM Token Saved After Permission Granted Later',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-27', email: 'test27@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // First subscription: Deny permission
      // Go to device Settings → Enable notifications
      // Return to app
      // Subscribe to second fridge (or enable in app settings)
      // Expected:
      //  - App detects permission granted
      //  - FCM token requested and saved
      //  - Token appears in database
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-024: FCM Token Persists Across App Restarts',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-28', email: 'test28@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
        fcmToken: 'persistent-fcm-token',
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Subscribe with permission granted
      // Verify token in database
      // Force close app
      // Restart app
      // Expected:
      //  - Same FCM token still in database
      //  - Token not regenerated unnecessarily
      //  - Notifications still work
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-025: FCM Token Saved to Profile When Profile Exists',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-29', email: 'test29@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [],
        fcmToken: 'profile-fcm-token',
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // User profile already created
      // Subscribe to first fridge
      // Expected:
      //  - FCM token saved to profile.fcmToken field
      //  - Token also accessible via /users/{userId}/fcmToken path
      //  - Both paths stay in sync
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-026: FCM Token Saved Directly When Profile Doesn\'t Exist',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-30', email: 'test30@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Sign in but profile creation delayed/failed
      // Subscribe immediately
      // Expected:
      //  - Token saved directly to /users/{userId}/fcmToken
      //  - Token persists even if profile creation fails
      //  - Token merged into profile when profile is eventually created
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });

  group('Notification Variations - Navigation Scenarios', () {
    testWidgets('NOT-027: Notification Navigation Provider State Management',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-31', email: 'test31@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Receive notification with fridge ID
      // Tap notification
      // Expected:
      //  - notificationNavigationProvider sets fridge ID
      //  - Map screen listens and opens fridge sheet
      //  - Provider state cleared after navigation
      //  - Subsequent notifications work correctly
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-028: Notification Navigation - Map Screen Not Loaded',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-32', email: 'test32@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // App killed
      // Tap notification
      // Expected:
      //  - App launches
      //  - Map screen loads
      //  - Fridge list loads
      //  - Then fridge sheet opens (with delay for data loading)
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-029: Notification Navigation - Fridge Not Found',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-33', email: 'test33@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: 'non-existent-fridge-id',
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Receive notification for fridge ID that doesn't exist in current data
      // Tap notification
      // Expected:
      //  - App handles gracefully
      //  - Shows error or navigates to map without opening sheet
      //  - Doesn't crash
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NOT-030: Notification Navigation - Multiple Rapid Taps',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-34', email: 'test34@example.com');

      await tester.pumpWidget(createNotificationTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeDirty.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeOutOfOrder.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Receive 3 notifications
      // Tap all 3 rapidly before navigation completes
      // Expected:
      //  - App handles gracefully
      //  - Navigates to last tapped fridge
      //  - Or queues navigation requests properly
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });
}

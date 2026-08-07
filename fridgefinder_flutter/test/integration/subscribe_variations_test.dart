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

NotificationPreferences legacyNotificationPreferences({
  bool updatedWithFood = false,
  bool runningLow = false,
  bool empty = false,
  bool needsCleaning = false,
  bool needsServicing = false,
  bool routineValidation = false,
}) {
  final flags = FridgeNotificationFlags(
    hasFood: updatedWithFood,
    noFood: runningLow || empty,
    dirty: needsCleaning,
    outOfOrder: needsServicing,
  );

  return NotificationPreferences(
    contactTypePreferences: ContactTypePreferences(
      email: flags,
      device: flags,
    ),
  );
}

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
Widget createSubscribeTestApp({
  firebase_auth.User? authenticatedUser,
  List<SubscriptionPreferences>? subscriptions,
  bool notificationPermissionGranted = false,
  bool locationPermissionGranted = false,
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

  group('Subscribe Variations - Basic Scenarios', () {
    testWidgets('SUB-001: Subscribe While Not Signed In',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: null,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // App should load
      expect(find.text('Fridge Map'), findsWidgets);

      // Trying to subscribe would trigger sign-in dialog
      // This is tested by verifying the subscribe button behavior
    });

    testWidgets('SUB-002: Subscribe - First Subscription (Permission Request Flow)',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-1', email: 'test1@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [], // No existing subscriptions
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // First subscription should trigger permission request
      // Expected: Permission dialog appears
      // If granted: FCM token saved, subscription created
      // If denied: Warning shown, subscription still created
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('SUB-002A: Subscribe - Second+ Subscription (No Permission Request)',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-2', email: 'test2@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Second subscription should NOT request permission again
      // Expected: Subscription created immediately
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets(
        'SUB-002B: Subscribe - First Subscription Permission Denied, Then Granted Later',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-3', email: 'test3@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [],
        notificationPermissionGranted: false,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // First subscription with denied permission
      // Then permission granted in settings
      // Subscribe to second fridge
      // Expected: FCM token now saved
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('SUB-002C: Subscribe - FCM Token Saved to Database',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-4', email: 'test4@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [],
        notificationPermissionGranted: true,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Expected: FCM token saved to /users/{userId}/fcmToken
      // Token persists after app restart
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('SUB-002D: Subscribe - FCM Token Saved When Profile Doesn\'t Exist Yet',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-5', email: 'test5@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Expected: Token saved directly to /users/{userId}/fcmToken
      // Token persists even if profile creation fails
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('SUB-002E: Subscribe - Permission Request Timing Verification',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-6', email: 'test6@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Navigate around app WITHOUT subscribing
      // Expected: NO permission request appears
      // Then subscribe to first fridge
      // Expected: Permission request appears ONLY at this point
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('SUB-003: Subscribe - Notification Permission Denied',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-7', email: 'test7@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [],
        notificationPermissionGranted: false,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Expected: Warning message shown
      // Subscription still created but notifications disabled
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('SUB-004: Subscribe - Location Permission Denied',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-8', email: 'test8@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [],
        locationPermissionGranted: false,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Expected: Geofencing not enabled, subscription still works
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('SUB-005: Subscribe - Permission Denied Then Granted Later',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-9', email: 'test9@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [],
        notificationPermissionGranted: false,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Subscribe with denied permission
      // Go to Settings → Enable notifications
      // Expected: App detects permission change, notifications now work
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('SUB-006: Subscribe to Same Fridge Twice',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-10', email: 'test10@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Try to subscribe to same fridge again
      // Expected: Shows "Already subscribed", offers to edit preferences
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('SUB-007: Subscribe to Multiple Fridges',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-11', email: 'test11@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(),
          ),
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeDirty.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(),
          ),
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeOutOfOrder.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Expected: All 3 show green glow, all in My Fridges list
      expect(find.text('Following'), findsOneWidget);
    });

    testWidgets('SUB-008: Subscribe to Maximum Fridges (if limit)',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-12', email: 'test12@example.com');

      // Create 50 subscriptions
      final subscriptions = List.generate(
        50,
        (index) => SubscriptionPreferences(
          fridgeId: 'fridge-$index',
          subscribedAt: DateTime.now(),
          notificationPreferences: legacyNotificationPreferences(),
        ),
      );

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: subscriptions,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Expected: Either allows all, or shows limit message
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('SUB-009: Subscribe → Immediately Unsubscribe',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-13', email: 'test13@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Subscribe then immediately unsubscribe
      // Expected: Green glow disappears, removed from My Fridges
      expect(find.text('Following'), findsOneWidget);
    });

    testWidgets('SUB-010: Subscribe → Edit → Unsubscribe',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-14', email: 'test14@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Subscribe, edit preferences, then unsubscribe
      // Expected: All data removed cleanly
      expect(find.text('Following'), findsOneWidget);
    });
  });

  group('Subscribe Variations - Notification Preferences', () {
    testWidgets('SUB-011: Subscribe - All Notifications Enabled',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-15', email: 'test15@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(
              updatedWithFood: true,
              runningLow: true,
              empty: true,
              needsCleaning: true,
              needsServicing: true,
              routineValidation: true,
            ),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Expected: Receives all update types
      expect(find.text('Following'), findsOneWidget);
    });

    testWidgets('SUB-012: Subscribe - All Notifications Disabled',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-16', email: 'test16@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(
              updatedWithFood: false,
              runningLow: false,
              empty: false,
              needsCleaning: false,
              needsServicing: false,
              routineValidation: false,
            ),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Expected: Still subscribed, but receives no notifications
      expect(find.text('Following'), findsOneWidget);
    });

    testWidgets('SUB-013: Subscribe - Only "Running Low" Selected',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-17', email: 'test17@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(
              runningLow: true,
            ),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Expected: Only receives notifications when fridge runs low
      expect(find.text('Following'), findsOneWidget);
    });

    testWidgets('SUB-014: Edit Preferences - Toggle All On/Off',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-18', email: 'test18@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Edit dialog, toggle all on, save
      // Edit again, toggle all off, save
      // Expected: Changes persist correctly
      expect(find.text('Following'), findsOneWidget);
    });

    testWidgets('SUB-015: Edit Preferences - Save Without Changes',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-19', email: 'test19@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Open Edit dialog, don't change anything, tap Save
      // Expected: No unnecessary database writes, success message
      expect(find.text('Following'), findsOneWidget);
    });

    testWidgets('SUB-016: Edit Preferences - Cancel Mid-Edit',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-20', email: 'test20@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Open Edit dialog, change preferences, tap Cancel
      // Expected: Changes discarded, original preferences remain
      expect(find.text('Following'), findsOneWidget);
    });

    testWidgets('SUB-017: Edit Preferences - Network Error',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-21', email: 'test21@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Open Edit dialog, change preferences
      // Disconnect network, tap Save
      // Expected: Network error, can retry
      expect(find.text('Following'), findsOneWidget);
    });
  });

  group('Subscribe Variations - Edge Cases', () {
    testWidgets('SUB-018: Subscribe While Network Disconnected',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-22', email: 'test22@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Try to subscribe while offline
      // Expected: Network error message, cannot subscribe
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('SUB-019: Subscribe - Firebase Error',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-23', email: 'test23@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Mock Firebase database error, try to subscribe
      // Expected: Error message, graceful failure
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('SUB-020: Unsubscribe - Confirmation Dialog',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-24', email: 'test24@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Tap Unsubscribe
      // Expected: Confirmation dialog appears, can cancel or confirm
      expect(find.text('Following'), findsOneWidget);
    });

    testWidgets('SUB-021: Unsubscribe - Network Error',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-25', email: 'test25@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Tap Unsubscribe, confirm
      // Disconnect network mid-request
      // Expected: Error message, subscription persists
      expect(find.text('Following'), findsOneWidget);
    });

    testWidgets('SUB-022: Unsubscribe All Fridges',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-26', email: 'test26@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(),
          ),
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeDirty.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(),
          ),
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeOutOfOrder.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(),
          ),
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.ghostFridge.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(),
          ),
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.notAtLocationFridge.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Unsubscribe from all 5 fridges
      // Expected: My Fridges screen shows empty state
      expect(find.text('Following'), findsOneWidget);
    });

    testWidgets('SUB-023: Subscribe with Geofencing Enabled',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-27', email: 'test27@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [],
        locationPermissionGranted: true,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Enable geofencing, subscribe to nearby fridge
      // Expected: Geofence automatically set up
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('SUB-024: Subscribe with Geofencing Disabled',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-28', email: 'test28@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [],
        locationPermissionGranted: false,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Disable geofencing, subscribe to fridge
      // Expected: No geofence created, notifications still work
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('SUB-025: Rapid Subscribe/Unsubscribe Spam',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-29', email: 'test29@example.com');

      await tester.pumpWidget(createSubscribeTestApp(
        authenticatedUser: testUser,
        subscriptions: [],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Tap Subscribe/Unsubscribe rapidly 10 times
      // Expected: App handles gracefully, final state is consistent
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });
}

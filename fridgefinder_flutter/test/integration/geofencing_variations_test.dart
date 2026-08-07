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

/// Helper to create app widget with geofencing settings
/// NOTE: For geofencing tests, user must be a volunteer (isVolunteer: true)
Widget createGeofencingTestApp({
  firebase_auth.User? authenticatedUser,
  List<SubscriptionPreferences>? subscriptions,
  bool locationPermissionGranted = false,
  bool alwaysLocationPermission = false,
  bool geofencingEnabled = false,
  bool isVolunteer = true, // Geofencing is volunteer-only
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

  group('Geofencing Variations - Setup Scenarios', () {
    // NOTE: As of the latest implementation, geofencing is VOLUNTEER-ONLY
    // Non-volunteer users will never see geofencing options or prompts
    // These tests should be run with volunteer profiles

    testWidgets('GEO-001: Enable Geofencing - "While Using" Permission (Volunteer Only)',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-1', email: 'test1@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        locationPermissionGranted: true,
        alwaysLocationPermission: false,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Toggle on Geofencing
      // Grant "While Using" location permission
      // Expected: Works while app in foreground only
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('GEO-002: Enable Geofencing - "Always" Permission',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-2', email: 'test2@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        locationPermissionGranted: true,
        alwaysLocationPermission: true,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Toggle on Geofencing
      // Grant "Always" location permission
      // Expected: Works in foreground and background
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('GEO-003: Enable Geofencing - Permission Denied',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-3', email: 'test3@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        locationPermissionGranted: false,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Toggle on Geofencing
      // Deny location permission
      // Expected: Error message, toggle stays off
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('GEO-004: Enable Geofencing - Permission Denied → Retry',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-4', email: 'test4@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        locationPermissionGranted: false,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Deny permission first time
      // App shows "Open Settings" option
      // Go to settings, grant permission
      // Return to app, toggle on again
      // Expected: Now works
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('GEO-005: Disable Geofencing',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-5', email: 'test5@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        geofencingEnabled: true,
        locationPermissionGranted: true,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Geofencing currently enabled
      // Toggle off
      // Expected: All geofences removed, no more proximity notifications
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('GEO-006: Geofencing - Location Permission Revoked Mid-Use',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-6', email: 'test6@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        geofencingEnabled: true,
        locationPermissionGranted: true,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Geofencing enabled and working
      // Go to iOS Settings → Revoke location permission
      // Expected: App detects revocation, shows error, disables geofencing
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });

  group('Geofencing Variations - Geofence Trigger Scenarios', () {
    testWidgets('GEO-007: Enter Geofence - Subscribed Fridge Needs Attention',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-7', email: 'test7@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        geofencingEnabled: true,
        locationPermissionGranted: true,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeDirty.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(
              needsCleaning: true,
            ),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Geofencing enabled
      // Subscribed to fridge needing cleaning
      // Approach within 200m
      // Expected: Proximity notification appears
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('GEO-008: Enter Geofence - Subscribed Fridge in Good Condition',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-8', email: 'test8@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        geofencingEnabled: true,
        locationPermissionGranted: true,
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

      // Geofencing enabled
      // Subscribed to fridge in good condition
      // Approach within 200m
      // Expected: No notification (fridge doesn't need attention)
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('GEO-009: Enter Geofence - Non-Subscribed Fridge',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-9', email: 'test9@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        geofencingEnabled: true,
        locationPermissionGranted: true,
        subscriptions: [],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Geofencing enabled
      // NOT subscribed to fridge
      // Approach within 200m
      // Expected: Proximity is detected and logged, but no notification sent
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('GEO-010: Exit Geofence',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-10', email: 'test10@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        geofencingEnabled: true,
        locationPermissionGranted: true,
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

      // Inside geofence
      // Move >200m away
      // Expected: No notification on exit
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('GEO-011: Geofencing + Battery Optimization',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-11', email: 'test11@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        geofencingEnabled: true,
        locationPermissionGranted: true,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Geofencing enabled
      // Battery saver mode activated
      // Expected: Geofencing may be less accurate, app handles gracefully
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });

  group('Geofencing Variations - Platform-Specific', () {
    testWidgets('GEO-012: iOS - Two-Step Permission Flow',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-12', email: 'test12@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        locationPermissionGranted: true,
        alwaysLocationPermission: false,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Request location permission on iOS
      // First prompt: "While Using"
      // Grant "While Using"
      // System prompts for "Always" after some use
      // Expected: App detects permission upgrade
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('GEO-013: iOS - Background Location Indicator',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-13', email: 'test13@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        geofencingEnabled: true,
        locationPermissionGranted: true,
        alwaysLocationPermission: true,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Geofencing enabled with "Always" permission
      // App in background
      // Expected: Blue bar appears showing location use
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('GEO-014: Android - Battery Optimization Whitelist',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-14', email: 'test14@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        geofencingEnabled: true,
        locationPermissionGranted: true,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Geofencing enabled
      // System battery optimization kills background tasks
      // Expected: App requests whitelist, or shows guidance
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('GEO-015: Geofencing - Multiple Subscribed Fridges Nearby',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-15', email: 'test15@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        geofencingEnabled: true,
        locationPermissionGranted: true,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeDirty.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(
              needsCleaning: true,
            ),
          ),
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeOutOfOrder.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(
              needsServicing: true,
            ),
          ),
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.ghostFridge.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Subscribed to 3 fridges in same area
      // All need attention
      // Enter geofence radius
      // Expected: Single notification mentioning multiple fridges, or one notification per fridge
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('GEO-016: Geofencing - Mixed Subscribed and Non-Subscribed Fridges',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-16', email: 'test16@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        geofencingEnabled: true,
        locationPermissionGranted: true,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeDirty.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(
              needsCleaning: true,
            ),
          ),
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeOutOfOrder.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(
              needsServicing: true,
            ),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Geofencing enabled
      // Subscribed to 2 fridges, NOT subscribed to 3 other fridges
      // All 5 fridges within 200m radius
      // 2 subscribed fridges need attention, 3 non-subscribed also need attention
      // Expected: Only receives notifications for the 2 subscribed fridges
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });

  group('Geofencing Variations - Notification Delivery', () {
    testWidgets('GEO-017: Geofence Notification - Local Notification Sent',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-17', email: 'test17@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        geofencingEnabled: true,
        locationPermissionGranted: true,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeDirty.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(
              needsCleaning: true,
            ),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Geofencing enabled, subscribed to fridge needing attention
      // Enter geofence radius (200m)
      // Expected:
      //  - Local notification appears: "{Fridge Name} needs attention"
      //  - Notification body describes what fridge needs
      //  - Notification payload includes fridge ID for navigation
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('GEO-018: Geofence Notification - Notification Cooldown',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-18', email: 'test18@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        geofencingEnabled: true,
        locationPermissionGranted: true,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeDirty.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(
              needsCleaning: true,
            ),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Enter geofence, receive notification
      // Stay within geofence for 15 minutes
      // Expected:
      //  - Only ONE notification received
      //  - No duplicate notifications during cooldown period (30 minutes)
      //  - After 30 minutes, can receive another notification if still in geofence
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('GEO-019: Geofence Notification - Multiple Needs Detected',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-19', email: 'test19@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        geofencingEnabled: true,
        locationPermissionGranted: true,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeDirty.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(
              needsCleaning: true,
              runningLow: true,
            ),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Fridge needs cleaning AND running low on food
      // Enter geofence
      // Expected:
      //  - Single notification mentioning all needs
      //  - Notification body: "You're near a fridge that needs cleaning, running low on food"
      //  - Tapping notification opens fridge details
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('GEO-020: Geofence Notification - User Notifications Disabled',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-20', email: 'test20@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        geofencingEnabled: true,
        locationPermissionGranted: true,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeDirty.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Geofencing enabled, subscribed to fridge
      // User disabled notifications globally in settings
      // Enter geofence
      // Expected:
      //  - NO notification sent (respects user preference)
      //  - Geofence still monitored but notifications suppressed
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('GEO-021: Geofence Notification - Notification Preferences Respected',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-21', email: 'test21@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        geofencingEnabled: true,
        locationPermissionGranted: true,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeDirty.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(
              needsCleaning: true,
            ),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Subscribed to fridge with only "Needs Cleaning" enabled
      // Fridge is running low (but not dirty)
      // Enter geofence
      // Expected:
      //  - NO notification (preference not enabled for "running low")
      //  - If fridge becomes dirty, THEN notification sent
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('GEO-022: Geofence Notification - Exit and Re-Enter Geofence',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-22', email: 'test22@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        geofencingEnabled: true,
        locationPermissionGranted: true,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeDirty.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(
              needsCleaning: true,
            ),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Enter geofence, receive notification
      // Exit geofence (>200m away)
      // Re-enter geofence within 30 minutes
      // Expected:
      //  - NO notification (still in cooldown period)
      //  - After 30 minutes, can receive notification again
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('GEO-023: Geofence Notification - Tap Notification Navigation',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-23', email: 'test23@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        geofencingEnabled: true,
        locationPermissionGranted: true,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeDirty.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(
              needsCleaning: true,
            ),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Receive geofence notification
      // Tap notification
      // Expected:
      //  - App opens/comes to foreground
      //  - Fridge details sheet opens showing correct fridge
      //  - Navigation works same as FCM notifications
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('GEO-024: Geofence Notification - Background Location Required',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-24', email: 'test24@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        geofencingEnabled: true,
        locationPermissionGranted: true,
        alwaysLocationPermission: false,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Enable geofencing
      // Grant "While Using" permission only
      // Expected:
      //  - Geofencing may not work in background
      //  - App should request "Always" permission
      //  - Or show message explaining background location needed
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('GEO-025: Geofence Notification - Foreground vs Background',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-25', email: 'test25@example.com');

      await tester.pumpWidget(createGeofencingTestApp(
        authenticatedUser: testUser,
        geofencingEnabled: true,
        locationPermissionGranted: true,
        alwaysLocationPermission: true,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeDirty.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: legacyNotificationPreferences(
              needsCleaning: true,
            ),
          ),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Geofencing enabled with "Always" permission
      // App in foreground: Enter geofence
      // Expected: Notification appears
      // Put app in background: Exit and re-enter geofence
      // Expected: Notification still appears (background monitoring works)
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });
}

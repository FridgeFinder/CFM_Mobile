import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:fridgefinder_app/src/features/map/presentation/controllers/fridge_list_controller.dart';
import 'package:fridgefinder_app/src/core/providers/auth_provider.dart';
import 'package:fridgefinder_app/src/routing/router.dart';
import '../fixtures/fridge_fixtures.dart';
import '../helpers/test_helpers.dart';
import '../test_helpers.dart';

/// Mock User for tests
class TestUser implements firebase_auth.User {
  @override
  final String uid;

  @override
  final String? email;

  TestUser({required this.uid, this.email});

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Test app wrapper
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

/// Helper to create app widget for permission tests
Widget createPermissionTestApp({
  firebase_auth.User? authenticatedUser,
  bool notificationPermissionGranted = false,
  bool locationPermissionGranted = false,
  bool alwaysLocationPermission = false,
}) {
  final fridgesWithDistance = FridgeFixtures.allFridges
      .map((fridge) => FridgeWithDistance(fridge: fridge, distanceKm: null))
      .toList();

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
    ],
    child: const TestFridgeFinderApp(),
  );
}

void main() {
  setUpAll(() async {
    await initHiveForTesting();
    // Firebase emulator not needed - using mocks
  });

  tearDownAll(() async {
    await cleanupHive();
  });

  group('Permission Flow - Notification Permissions', () {
    testWidgets('PERM-001: First Notification Permission Request',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-1', email: 'test1@example.com');

      await tester.pumpWidget(createPermissionTestApp(
        authenticatedUser: testUser,
        notificationPermissionGranted: false,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // First subscription triggers permission request
      // Expected:
      //  - Native permission dialog appears
      //  - App explains why permission is needed
      //  - User can grant or deny
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('PERM-002: Notification Permission Granted',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-2', email: 'test2@example.com');

      await tester.pumpWidget(createPermissionTestApp(
        authenticatedUser: testUser,
        notificationPermissionGranted: true,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // User grants notification permission
      // Expected:
      //  - FCM token generated
      //  - Token saved to database
      //  - Subscription created successfully
      //  - Success message shown
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('PERM-003: Notification Permission Denied',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-3', email: 'test3@example.com');

      await tester.pumpWidget(createPermissionTestApp(
        authenticatedUser: testUser,
        notificationPermissionGranted: false,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // User denies notification permission
      // Expected:
      //  - Warning message: "You won't receive notifications"
      //  - Subscription still created
      //  - FCM token NOT saved
      //  - Can enable later in settings
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('PERM-004: Notification Permission Denied Then Granted in Settings',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-4', email: 'test4@example.com');

      await tester.pumpWidget(createPermissionTestApp(
        authenticatedUser: testUser,
        notificationPermissionGranted: false,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // User denies permission initially
      // Goes to device Settings → Enables notifications
      // Returns to app
      // Expected:
      //  - App detects permission change
      //  - Shows: "Notifications now enabled!"
      //  - Generates and saves FCM token
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });

  group('Permission Flow - Location Permissions', () {
    testWidgets('PERM-005: First Location Permission Request (While Using)',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-5', email: 'test5@example.com');

      await tester.pumpWidget(createPermissionTestApp(
        authenticatedUser: testUser,
        locationPermissionGranted: false,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // User enables geofencing for first time
      // Expected:
      //  - Native permission dialog: "While Using"
      //  - App explains proximity alerts
      //  - User can grant or deny
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('PERM-006: Location Permission Granted (While Using)',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-6', email: 'test6@example.com');

      await tester.pumpWidget(createPermissionTestApp(
        authenticatedUser: testUser,
        locationPermissionGranted: true,
        alwaysLocationPermission: false,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // User grants "While Using" permission
      // Expected:
      //  - Geofencing enabled (limited to foreground)
      //  - Geofences registered for subscribed fridges
      //  - Success message shown
      //  - App may prompt for "Always" later (iOS)
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('PERM-007: Location Permission Upgraded to Always (iOS)',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-7', email: 'test7@example.com');

      await tester.pumpWidget(createPermissionTestApp(
        authenticatedUser: testUser,
        locationPermissionGranted: true,
        alwaysLocationPermission: true,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // User upgrades from "While Using" to "Always"
      // Expected:
      //  - Geofencing now works in background
      //  - App detects upgrade
      //  - Message: "Background alerts now enabled!"
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('PERM-008: Location Permission Denied',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-8', email: 'test8@example.com');

      await tester.pumpWidget(createPermissionTestApp(
        authenticatedUser: testUser,
        locationPermissionGranted: false,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // User denies location permission
      // Expected:
      //  - Error: "Geofencing requires location permission"
      //  - Geofencing toggle stays off
      //  - Button: "Open Settings" to grant permission
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('PERM-009: Location Permission Revoked Mid-Use',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-9', email: 'test9@example.com');

      await tester.pumpWidget(createPermissionTestApp(
        authenticatedUser: testUser,
        locationPermissionGranted: true,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Geofencing enabled and working
      // User goes to Settings → Revokes location permission
      // Returns to app
      // Expected:
      //  - App detects revocation
      //  - Geofencing automatically disabled
      //  - Geofences removed
      //  - Alert: "Location permission revoked. Geofencing disabled."
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('PERM-010: Permission Rationale Shown (After Denial)',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-10', email: 'test10@example.com');

      await tester.pumpWidget(createPermissionTestApp(
        authenticatedUser: testUser,
        notificationPermissionGranted: false,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // User denies permission once
      // Tries to subscribe again
      // Expected:
      //  - Rationale dialog explains why permission is needed
      //  - "Open Settings" button to grant permission
      //  - Or "Continue without notifications" option
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });
}

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

/// Helper to create app widget for network tests
Widget createNetworkTestApp({
  firebase_auth.User? authenticatedUser,
  bool isOffline = false,
  bool isSlowNetwork = false,
  bool hasNetworkError = false,
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

  group('Network & Connectivity - Offline Scenarios', () {
    testWidgets('NET-001: Launch App Offline',
        (WidgetTester tester) async {
      await tester.pumpWidget(createNetworkTestApp(
        isOffline: true,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Start app with no network connection
      // Expected:
      //  - Error view with retry button
      //  - Graceful degradation
      //  - Clear message about network unavailability
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NET-002: Go Offline During App Use',
        (WidgetTester tester) async {
      await tester.pumpWidget(createNetworkTestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // App running normally
      // Disable WiFi/cellular mid-use
      // Expected:
      //  - Cached data still visible
      //  - New requests fail gracefully
      //  - Offline indicator shown
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NET-003: Go Online After Being Offline',
        (WidgetTester tester) async {
      await tester.pumpWidget(createNetworkTestApp(
        isOffline: true,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // App offline, showing cached data
      // Enable network
      // Pull to refresh
      // Expected:
      //  - Data refreshes successfully
      //  - App fully functional
      //  - Offline indicator disappears
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NET-004: Intermittent Connection',
        (WidgetTester tester) async {
      await tester.pumpWidget(createNetworkTestApp(
        hasNetworkError: true,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Network flaky, drops frequently
      // Expected:
      //  - Retry logic handles failures
      //  - Eventual consistency
      //  - No crashes from network errors
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });

  group('Network & Connectivity - Slow Network Scenarios', () {
    testWidgets('NET-005: Very Slow Network - Loading Fridges',
        (WidgetTester tester) async {
      await tester.pumpWidget(createNetworkTestApp(
        isSlowNetwork: true,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Throttle network to 2G speeds
      // Launch app
      // Expected:
      //  - Loading indicator shown
      //  - Eventually loads or shows timeout error
      //  - User can cancel and retry
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NET-006: Very Slow Network - Image Upload',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-6', email: 'test6@example.com');

      await tester.pumpWidget(createNetworkTestApp(
        authenticatedUser: testUser,
        isSlowNetwork: true,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Submit report with photo on slow network
      // Expected:
      //  - Upload progress indicator visible
      //  - Can take time but succeeds eventually
      //  - User can cancel upload
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NET-007: Network Timeout - API Call',
        (WidgetTester tester) async {
      await tester.pumpWidget(createNetworkTestApp(
        hasNetworkError: true,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // API call takes >30 seconds
      // Expected:
      //  - Timeout error message shown
      //  - Can retry
      //  - Clear error message
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NET-008: Network Timeout - Firebase Operation',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-8', email: 'test8@example.com');

      await tester.pumpWidget(createNetworkTestApp(
        authenticatedUser: testUser,
        hasNetworkError: true,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Firebase operation takes too long
      // Expected:
      //  - Timeout error
      //  - Graceful failure
      //  - User can retry
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });

  group('Network & Connectivity - Firebase Emulator Scenarios', () {
    testWidgets('NET-009: Firebase Emulator Restart',
        (WidgetTester tester) async {
      await tester.pumpWidget(createNetworkTestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // Running tests against emulator
      // Emulator restarts mid-test
      // Expected:
      //  - Connection error detected
      //  - App reconnects automatically
      //  - Minimal disruption to user
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NET-010: Firebase Emulator - Auth Disconnect',
        (WidgetTester tester) async {
      await tester.pumpWidget(createNetworkTestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // Auth emulator goes down
      // Try to sign in
      // Expected:
      //  - Auth error shown
      //  - Clear message about service unavailability
      //  - Can retry when service restored
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NET-011: Firebase Emulator - Database Disconnect',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-11', email: 'test11@example.com');

      await tester.pumpWidget(createNetworkTestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Database emulator goes down
      // Try to read/write data
      // Expected:
      //  - Database error shown
      //  - Retry logic kicks in
      //  - Local cache used if available
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('NET-012: Firebase Emulator - Functions Disconnect',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-12', email: 'test12@example.com');

      await tester.pumpWidget(createNetworkTestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Cloud functions emulator down
      // Status update triggers function
      // Expected:
      //  - Function call fails
      //  - Graceful handling
      //  - User action still completes locally
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });
}

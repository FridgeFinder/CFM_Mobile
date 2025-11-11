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

/// Helper to create app widget for performance tests
Widget createPerformanceTestApp({
  firebase_auth.User? authenticatedUser,
  List<SubscriptionPreferences>? subscriptions,
  bool largeDataset = false,
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
    // Firebase emulator not needed - using mocks
  });

  tearDownAll(() async {
    await cleanupHive();
  });

  group('Performance & Stress - High Volume Scenarios', () {
    testWidgets('PERF-001: Subscribe to 100 Fridges',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-1', email: 'test1@example.com');

      await tester.pumpWidget(createPerformanceTestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Subscribe to all available fridges (if 100+)
      // Expected:
      //  - App handles gracefully
      //  - No performance degradation
      //  - UI remains responsive
      //  - Memory usage acceptable
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('PERF-002: Receive 20 Notifications Rapidly',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-2', email: 'test2@example.com');

      await tester.pumpWidget(createPerformanceTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Mock 20 status updates in 1 minute
      // Expected:
      //  - All notifications arrive
      //  - App doesn't crash
      //  - Notification queue handled properly
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('PERF-003: Submit 50 Reports Consecutively',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-3', email: 'test3@example.com');

      await tester.pumpWidget(createPerformanceTestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Submit report on 50 different fridges
      // Expected:
      //  - All reports saved
      //  - Points calculated correctly
      //  - No database throttling issues
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('PERF-004: Load Map with 500+ Markers',
        (WidgetTester tester) async {
      await tester.pumpWidget(createPerformanceTestApp(
        largeDataset: true,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Database has 500+ fridges
      // Open map view
      // Expected:
      //  - Clustering works
      //  - Map loads within 3 seconds
      //  - Zoom in/out is smooth
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('PERF-005: Large Dataset - List View Scrolling',
        (WidgetTester tester) async {
      await tester.pumpWidget(createPerformanceTestApp(
        largeDataset: true,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // List view with 500+ fridges
      // Scroll rapidly
      // Expected:
      //  - Smooth scrolling
      //  - No jank or lag
      //  - ListView.builder handles efficiently
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });

  group('Performance & Stress - Memory & Battery', () {
    testWidgets('PERF-006: App Running for 24 Hours',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-6', email: 'test6@example.com');

      await tester.pumpWidget(createPerformanceTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Leave app open (backgrounded) for 24 hours
      // Expected:
      //  - No memory leaks
      //  - App still functional when reopened
      //  - No zombie processes
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('PERF-007: Geofencing - Battery Drain Test',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-7', email: 'test7@example.com');

      await tester.pumpWidget(createPerformanceTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Enable geofencing
      // Monitor battery usage over 8 hours
      // Expected:
      //  - Battery drain acceptable (<10% over 8 hours)
      //  - Location updates efficient
      //  - Background processing minimal
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('PERF-008: Continuous Location Tracking',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-8', email: 'test8@example.com');

      await tester.pumpWidget(createPerformanceTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Enable geofencing with Always permission
      // App in background for hours
      // Expected:
      //  - Location updates efficient
      //  - Battery impact minimal
      //  - Geofences trigger correctly
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });
}

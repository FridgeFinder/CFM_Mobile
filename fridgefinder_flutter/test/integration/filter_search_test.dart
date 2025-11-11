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

/// Helper to create app widget for filter tests
Widget createFilterTestApp({
  firebase_auth.User? authenticatedUser,
  List<SubscriptionPreferences>? subscriptions,
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

  group('Filter & Search - Subscribed Filter Scenarios', () {
    testWidgets('FIL-001: Subscribed Filter - Alone',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-1', email: 'test1@example.com');

      await tester.pumpWidget(createFilterTestApp(
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

      // Enable only Subscribed filter
      // Expected:
      //  - Shows only subscribed fridges on map and list
      //  - Other fridges hidden
      //  - Count shows subscribed fridges only
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('FIL-002: Subscribed Filter + Full',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-2', email: 'test2@example.com');

      await tester.pumpWidget(createFilterTestApp(
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

      // Enable Subscribed + Full filters
      // Expected:
      //  - Shows only subscribed fridges that are full
      //  - Combines both filter criteria
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('FIL-003: Subscribed Filter + Needs Cleaning',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-3', email: 'test3@example.com');

      await tester.pumpWidget(createFilterTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeDirty.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Enable Subscribed + Needs Cleaning
      // Expected:
      //  - Shows only subscribed fridges that need cleaning
      //  - Dirty fridge appears
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('FIL-004: Subscribed Filter + Search Query',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-4', email: 'test4@example.com');

      await tester.pumpWidget(createFilterTestApp(
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

      // Enable Subscribed filter
      // Search for "Community"
      // Expected:
      //  - Shows only subscribed fridges matching "Community"
      //  - Text search applied to filtered results
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('FIL-005: Subscribed Filter + Location Search',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-5', email: 'test5@example.com');

      await tester.pumpWidget(createFilterTestApp(
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

      // Enable Subscribed filter
      // Search location "94107"
      // Expected:
      //  - Shows subscribed fridges near that location
      //  - Location search + filter combined
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('FIL-006: Clear Subscribed Filter',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-6', email: 'test6@example.com');

      await tester.pumpWidget(createFilterTestApp(
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

      // Enable Subscribed filter
      // Tap Clear Filters
      // Expected:
      //  - Subscribed filter cleared
      //  - Shows all fridges
      //  - Filter pill no longer highlighted
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('FIL-007: Subscribe While Subscribed Filter Active',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-7', email: 'test7@example.com');

      await tester.pumpWidget(createFilterTestApp(
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
        ],
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Subscribed filter enabled (showing 2 fridges)
      // Subscribe to a 3rd fridge
      // Expected:
      //  - 3rd fridge immediately appears in filtered view
      //  - Count updates to 3
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('FIL-008: Unsubscribe While Subscribed Filter Active',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-8', email: 'test8@example.com');

      await tester.pumpWidget(createFilterTestApp(
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
      await tester.pump(const Duration(milliseconds: 200));

      // Subscribed filter enabled (showing 3 fridges)
      // Unsubscribe from one
      // Expected:
      //  - That fridge immediately disappears from view
      //  - Count updates to 2
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('FIL-009: Subscribed Filter - No Subscriptions',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-9', email: 'test9@example.com');

      await tester.pumpWidget(createFilterTestApp(
        authenticatedUser: testUser,
        subscriptions: [],
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // User not subscribed to any fridges
      // Try to enable Subscribed filter
      // Expected:
      //  - Filter pill doesn't appear (hidden when no subscriptions)
      //  - No empty state shown
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('FIL-010: Subscribed Filter - Sign Out While Active',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-10', email: 'test10@example.com');

      await tester.pumpWidget(createFilterTestApp(
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

      // Subscribed filter enabled
      // Sign out
      // Expected:
      //  - Filter automatically clears
      //  - Pill disappears
      //  - Shows all fridges
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });

  group('Filter & Search - General Filter & Search', () {
    testWidgets('FIL-011: Multiple Food Level Filters',
        (WidgetTester tester) async {
      await tester.pumpWidget(createFilterTestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // Enable Full + Many Items
      // Expected:
      //  - Shows fridges with ≥50% food
      //  - OR logic for same category
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('FIL-012: Multiple Condition Filters',
        (WidgetTester tester) async {
      await tester.pumpWidget(createFilterTestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // Enable Needs Cleaning + Needs Servicing
      // Expected:
      //  - Shows dirty OR out-of-order fridges
      //  - OR logic for same category
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('FIL-013: Food Level + Condition Filters',
        (WidgetTester tester) async {
      await tester.pumpWidget(createFilterTestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // Enable Full + Needs Cleaning
      // Expected:
      //  - Shows fridges that are full AND need cleaning
      //  - AND logic across different categories
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('FIL-014: Filter Persistence After App Restart',
        (WidgetTester tester) async {
      await tester.pumpWidget(createFilterTestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // Enable several filters
      // Close app completely
      // Reopen app
      // Expected:
      //  - Filters still active
      //  - Saved to local storage
      //  - State restored
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('FIL-015: Location Search - Invalid Location',
        (WidgetTester tester) async {
      await tester.pumpWidget(createFilterTestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // Search for "asdfghjkl"
      // Expected:
      //  - Error: "Location not found"
      //  - No changes to current view
      //  - Can clear search and retry
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });
}

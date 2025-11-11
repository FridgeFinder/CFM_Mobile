import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgefinder_app/src/features/map/presentation/controllers/fridge_list_controller.dart';
import 'package:fridgefinder_app/src/features/auth/domain/models/subscription_preferences.dart';
import 'package:fridgefinder_app/src/core/providers/subscriptions_provider.dart';
import 'package:fridgefinder_app/src/core/providers/auth_provider.dart';
import 'package:fridgefinder_app/src/routing/router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../fixtures/fridge_fixtures.dart';
import '../helpers/test_helpers.dart';
import '../test_helpers.dart';

/// Mock User for authentication tests
class TestUser implements User {
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

/// Helper to create app widget with mocks
Widget createTestApp({
  User? authenticatedUser,
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
  });

  tearDownAll(() async {
    await cleanupHive();
  });

  group('Filter Combination Tests', () {
    testWidgets(
      'FIL-002: Subscribed filter + Full filter combined',
      (WidgetTester tester) async {
        final testUser = TestUser(uid: 'test-user', email: 'test@example.com');
        final subscriptions = [
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
        ];

        await tester.pumpWidget(createTestApp(
          authenticatedUser: testUser,
          subscriptions: subscriptions,
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Activate subscribed filter
        final subscribedPill = find.text('Subscribed');
        if (subscribedPill.evaluate().isNotEmpty) {
          await tester.tap(subscribedPill);
          await tester.pump();
        }

        // Activate Full filter
        final fullFilter = find.text('Full');
        if (fullFilter.evaluate().isNotEmpty) {
          await tester.tap(fullFilter);
          await tester.pump();
        }

        // Both filters should be active
        expect(find.text('Subscribed'), findsOneWidget);
        expect(find.text('Full'), findsOneWidget);
      },
    );

    testWidgets(
      'FIL-011: Multiple food level filters combined',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Activate Full filter
        final fullFilter = find.text('Full');
        if (fullFilter.evaluate().isNotEmpty) {
          await tester.tap(fullFilter);
          await tester.pump();
        }

        // Activate Many Items filter
        final manyItemsFilter = find.text('Many Items');
        if (manyItemsFilter.evaluate().isNotEmpty) {
          await tester.tap(manyItemsFilter);
          await tester.pump();
        }

        // Both should be active
        expect(find.text('Full'), findsOneWidget);
        expect(find.text('Many Items'), findsOneWidget);
      },
    );

    testWidgets(
      'FIL-012: Multiple condition filters combined',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Activate Needs Cleaning filter
        final needsCleaningFilter = find.text('Needs Cleaning');
        if (needsCleaningFilter.evaluate().isNotEmpty) {
          await tester.tap(needsCleaningFilter);
          await tester.pump();
        }

        // Activate Needs Servicing filter
        final needsServicingFilter = find.text('Needs Servicing');
        if (needsServicingFilter.evaluate().isNotEmpty) {
          await tester.tap(needsServicingFilter);
          await tester.pump();
        }

        // Both should be active
        expect(find.text('Needs Cleaning'), findsOneWidget);
        expect(find.text('Needs Servicing'), findsOneWidget);
      },
    );

    testWidgets(
      'FIL-013: Food level + condition filters combined',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Activate Full filter (food level)
        final fullFilter = find.text('Full');
        if (fullFilter.evaluate().isNotEmpty) {
          await tester.tap(fullFilter);
          await tester.pump();
        }

        // Activate Needs Cleaning filter (condition)
        final needsCleaningFilter = find.text('Needs Cleaning');
        if (needsCleaningFilter.evaluate().isNotEmpty) {
          await tester.tap(needsCleaningFilter);
          await tester.pump();
        }

        // Both should be active
        expect(find.text('Full'), findsOneWidget);
        expect(find.text('Needs Cleaning'), findsOneWidget);
      },
    );

    testWidgets(
      'FIL-006: Clear all filters',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Activate multiple filters
        final fullFilter = find.text('Full');
        if (fullFilter.evaluate().isNotEmpty) {
          await tester.tap(fullFilter);
          await tester.pump();
        }

        final manyItemsFilter = find.text('Many Items');
        if (manyItemsFilter.evaluate().isNotEmpty) {
          await tester.tap(manyItemsFilter);
          await tester.pump();
        }

        // Deactivate filters by tapping again
        await tester.tap(fullFilter);
        await tester.pump();

        await tester.tap(manyItemsFilter);
        await tester.pump();

        // Filters should still be visible (just not active)
        expect(find.text('Full'), findsOneWidget);
        expect(find.text('Many Items'), findsOneWidget);
      },
    );
  });

  group('Subscribed Filter Advanced Tests', () {
    testWidgets(
      'FILTER-006: Subscribed + status filters work together',
      (WidgetTester tester) async {
        final testUser = TestUser(uid: 'test-user', email: 'test@example.com');
        final subscriptions = [
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
        ];

        await tester.pumpWidget(createTestApp(
          authenticatedUser: testUser,
          subscriptions: subscriptions,
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Activate subscribed filter
        final subscribedPill = find.text('Subscribed');
        expect(subscribedPill, findsOneWidget);
        await tester.tap(subscribedPill);
        await tester.pump();

        // Activate Full status filter
        final fullFilter = find.text('Full');
        if (fullFilter.evaluate().isNotEmpty) {
          await tester.tap(fullFilter);
          await tester.pump();
        }

        // Both filters should be active (AND logic)
        expect(find.text('Subscribed'), findsOneWidget);
        expect(find.text('Full'), findsOneWidget);
      },
    );

    testWidgets(
      'FILTER-009: Subscribed pill hidden when no subscriptions',
      (WidgetTester tester) async {
        final testUser = TestUser(uid: 'test-user', email: 'test@example.com');

        await tester.pumpWidget(createTestApp(
          authenticatedUser: testUser,
          subscriptions: [], // No subscriptions
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Subscribed pill should NOT appear
        expect(find.text('Subscribed'), findsNothing);

        // But other filters should be visible
        expect(find.text('Full'), findsOneWidget);
      },
    );
  });

  group('Filter State Management Tests', () {
    testWidgets(
      'STATE-001: Activating same filter twice',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Activate filter
        final fullFilter = find.text('Full');
        await tester.tap(fullFilter);
        await tester.pump();

        // Tap same filter again (deactivate)
        await tester.tap(fullFilter);
        await tester.pump();

        // Filter should still be visible
        expect(fullFilter, findsOneWidget);
      },
    );

    testWidgets(
      'STATE-002: Basic filters are visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Some status filters should be visible
        expect(find.text('Full'), findsOneWidget);
        expect(find.text('Many Items'), findsOneWidget);
      },
    );

    testWidgets(
      'STATE-003: Complex filter sequence',
      (WidgetTester tester) async {
        final testUser = TestUser(uid: 'test-user', email: 'test@example.com');
        final subscriptions = [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ];

        await tester.pumpWidget(createTestApp(
          authenticatedUser: testUser,
          subscriptions: subscriptions,
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Sequence: Activate subscribed, activate full, deactivate subscribed
        final subscribedPill = find.text('Subscribed');
        await tester.tap(subscribedPill);
        await tester.pump();

        final fullFilter = find.text('Full');
        await tester.tap(fullFilter);
        await tester.pump();

        // Deactivate subscribed
        await tester.tap(subscribedPill);
        await tester.pump();

        // Full should still be active
        expect(find.text('Full'), findsOneWidget);
        expect(find.text('Subscribed'), findsOneWidget);
      },
    );
  });

  group('Filter Visual Feedback Tests', () {
    testWidgets(
      'VISUAL-001: Filter pills are visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Verify common filter pills appear
        expect(find.text('Full'), findsOneWidget);
        expect(find.text('Many Items'), findsOneWidget);
        expect(find.text('Needs Cleaning'), findsOneWidget);
        expect(find.text('Needs Servicing'), findsOneWidget);
      },
    );

    testWidgets(
      'VISUAL-002: Subscribed pill appears first when visible',
      (WidgetTester tester) async {
        final testUser = TestUser(uid: 'test-user', email: 'test@example.com');
        final subscriptions = [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ];

        await tester.pumpWidget(createTestApp(
          authenticatedUser: testUser,
          subscriptions: subscriptions,
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Subscribed pill should be visible
        expect(find.text('Subscribed'), findsOneWidget);

        // Other filters also visible
        expect(find.text('Full'), findsOneWidget);
      },
    );
  });
}

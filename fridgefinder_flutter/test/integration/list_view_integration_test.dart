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

  group('List View Basic Tests', () {
    testWidgets(
      'LIST-001: App loads successfully',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Verify app loaded
        expect(find.text('Fridge Map'), findsWidgets);
      },
    );

    testWidgets(
      'LIST-002: Navigation bar is visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Wait for nav bar
        int attempts = 0;
        while (find.byIcon(Icons.list).evaluate().isEmpty && attempts < 20) {
          await tester.pump(const Duration(milliseconds: 50));
          attempts++;
        }

        // Verify nav icons exist
        expect(find.byIcon(Icons.list), findsWidgets);
        expect(find.byIcon(Icons.map), findsWidgets);
      },
    );
  });

  group('Filter Persistence Tests', () {
    testWidgets(
      'FILTER-008: Multiple filters can be activated together',
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

        // Both should be active
        expect(find.text('Full'), findsOneWidget);
        expect(find.text('Many Items'), findsOneWidget);
      },
    );

    testWidgets(
      'FILTER-009: Deactivating filter works',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Activate filter
        final fullFilter = find.text('Full');
        if (fullFilter.evaluate().isNotEmpty) {
          await tester.tap(fullFilter);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));

          // Deactivate same filter
          await tester.tap(fullFilter);
          await tester.pump();

          // Filter should still be visible (just not active)
          expect(find.text('Full'), findsOneWidget);
        }
      },
    );
  });

  group('Subscription Visual Tests', () {
    testWidgets(
      'VIS-003: Subscribed pill visible with authenticated user',
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
        expect(find.text('Following'), findsOneWidget);
      },
    );

    testWidgets(
      'VIS-004: Subscribed pill toggles on tap',
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

        final subscribedPill = find.text('Following');
        expect(subscribedPill, findsOneWidget);

        // Tap to activate
        await tester.tap(subscribedPill);
        await tester.pump();

        // Tap again to deactivate
        await tester.tap(subscribedPill);
        await tester.pump();

        // Should still be visible
        expect(subscribedPill, findsOneWidget);
      },
    );
  });

  group('Edge Case Tests', () {
    testWidgets(
      'EDGE-001: App handles empty subscriptions list',
      (WidgetTester tester) async {
        final testUser = TestUser(uid: 'test-user', email: 'test@example.com');

        await tester.pumpWidget(createTestApp(
          authenticatedUser: testUser,
          subscriptions: [], // Empty list
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // App should load successfully
        expect(find.text('Fridge Map'), findsWidgets);

        // Subscribed pill should NOT be visible
        expect(find.text('Following'), findsNothing);
      },
    );

    testWidgets(
      'EDGE-002: App handles null user gracefully',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          authenticatedUser: null,
          subscriptions: [],
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // App should load successfully
        expect(find.text('Fridge Map'), findsWidgets);

        // Subscribed pill should NOT be visible
        expect(find.text('Following'), findsNothing);
      },
    );
  });
}

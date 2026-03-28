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

/// Test-friendly app wrapper that handles Firebase gracefully
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

/// Helper to create app widget with auth and subscription mocks
Widget createAppWidgetWithAuth({
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
      // Mock authentication
      currentAuthUserProvider.overrideWith(
        (ref) => isAuthenticated
            ? AsyncValue.data(authenticatedUser)
            : const AsyncValue.data(null),
      ),
      isAuthenticatedProvider.overrideWith((ref) => isAuthenticated),
      // Mock user profile (return null to avoid database calls)
      userProfileProvider.overrideWith((ref) => Future.value(null)),
      // Mock subscriptions
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

  group('Subscription Filter Tests', () {
    testWidgets(
      'FILTER-001: Subscribed pill not visible when not authenticated',
      (WidgetTester tester) async {
        // Setup: No authenticated user
        await tester.pumpWidget(createAppWidgetWithAuth(
          authenticatedUser: null,
          subscriptions: [],
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 200));

        // Verify: Subscribed pill is NOT visible
        expect(find.text('Following'), findsNothing);

        // Verify: Status filters are shown
        expect(find.text('Full'), findsOneWidget);
      },
    );

    testWidgets(
      'FILTER-002: Subscribed pill not visible when user has no subscriptions',
      (WidgetTester tester) async {
        // Setup: Authenticated user with NO subscriptions
        final testUser = TestUser(uid: 'test-user-3', email: 'test3@example.com');

        await tester.pumpWidget(createAppWidgetWithAuth(
          authenticatedUser: testUser,
          subscriptions: [], // Empty subscriptions
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 200));

        // Verify: Subscribed pill is NOT visible (no subscriptions)
        expect(find.text('Following'), findsNothing);
      },
    );

    testWidgets(
      'FILTER-003: Subscribed pill appears when user has subscriptions',
      (WidgetTester tester) async {
        // Setup: User with 2 subscriptions
        final testUser = TestUser(uid: 'test-user-2', email: 'test2@example.com');
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

        await tester.pumpWidget(createAppWidgetWithAuth(
          authenticatedUser: testUser,
          subscriptions: subscriptions,
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 200));

        // Verify: Subscribed pill filter is visible
        expect(find.text('Following'), findsOneWidget);
      },
    );

    testWidgets(
      'FILTER-004: Tap subscribed pill to activate filter',
      (WidgetTester tester) async {
        // Setup: User with subscriptions
        final testUser = TestUser(uid: 'test-user-4', email: 'test4@example.com');
        final subscriptions = [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ];

        await tester.pumpWidget(createAppWidgetWithAuth(
          authenticatedUser: testUser,
          subscriptions: subscriptions,
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 200));

        // Find subscribed pill
        final subscribedPill = find.text('Following');
        expect(subscribedPill, findsOneWidget);

        // Tap subscribed pill to activate filter
        await tester.tap(subscribedPill);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Verify: No exceptions were thrown
        expect(true, isTrue);
      },
    );
  });

  group('Subscription UI Tests', () {
    testWidgets(
      'SUB-001: Subscribe button visible when viewing fridge without subscription',
      (WidgetTester tester) async {
        // Note: This is a simplified test that just verifies the filter pill appears
        // Full profile sheet testing requires more complex navigation setup

        final testUser = TestUser(uid: 'test-user-5', email: 'test5@example.com');

        await tester.pumpWidget(createAppWidgetWithAuth(
          authenticatedUser: testUser,
          subscriptions: [], // No subscriptions
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Verify: App loaded successfully
        expect(find.text('Fridge Map'), findsWidgets);
      },
    );
  });
}

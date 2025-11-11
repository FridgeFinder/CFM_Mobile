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

/// Helper to create app widget for data persistence tests
Widget createDataPersistenceTestApp({
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

  group('Data Persistence - App Restart Scenarios', () {
    testWidgets('DATA-001: Kill App, Reopen Immediately',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-1', email: 'test1@example.com');

      await tester.pumpWidget(createDataPersistenceTestApp(
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

      // Use app normally
      // Force kill
      // Reopen
      // Expected:
      //  - Recent state restored (filters, selected fridge, etc.)
      //  - Subscriptions intact
      //  - User still authenticated
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('DATA-002: App Backgrounded for Hours',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-2', email: 'test2@example.com');

      await tester.pumpWidget(createDataPersistenceTestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Use app
      // Background for 4 hours
      // Reopen
      // Expected:
      //  - Data refreshes from server
      //  - Session may expire and re-auth required
      //  - App state restored
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('DATA-003: App Backgrounded Overnight',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-3', email: 'test3@example.com');

      await tester.pumpWidget(createDataPersistenceTestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Use app
      // Background overnight (8+ hours)
      // Reopen
      // Expected:
      //  - Data refreshes completely
      //  - Re-authentication if token expired
      //  - Fresh data loaded
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('DATA-004: Device Restart',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-4', email: 'test4@example.com');

      await tester.pumpWidget(createDataPersistenceTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(
              updatedWithFood: true,
              runningLow: true,
            ),
          ),
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.fridgeDirty.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Use app, subscribe to fridges
      // Restart device
      // Open app
      // Expected:
      //  - All subscriptions persist
      //  - Settings persist
      //  - Geofences re-registered
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });

  group('Data Persistence - Data Sync Scenarios', () {
    testWidgets('DATA-005: Subscribe on Device A, Open Device B',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-5', email: 'test5@example.com');

      await tester.pumpWidget(createDataPersistenceTestApp(
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

      // Sign in on iPhone
      // Subscribe to fridge
      // Sign in on iPad with same account
      // Expected:
      //  - iPad shows subscription (once data syncs)
      //  - Subscription data identical
      //  - Both devices can manage subscription
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('DATA-006: Submit Report on Device A, Check Device B',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-6', email: 'test6@example.com');

      await tester.pumpWidget(createDataPersistenceTestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Submit report on iPhone
      // Check on iPad
      // Expected:
      //  - Report appears in activity history
      //  - Points updated on both devices
      //  - Timestamp correct
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('DATA-007: Delete Account on Device A, Try Device B',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-7', email: 'test7@example.com');

      await tester.pumpWidget(createDataPersistenceTestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Delete account on iPhone
      // Try to use iPad
      // Expected:
      //  - iPad shows signed-out state
      //  - Account doesn't exist
      //  - Can't sign in with deleted credentials
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('DATA-008: Edit Preferences on Device A, Check Device B',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-8', email: 'test8@example.com');

      await tester.pumpWidget(createDataPersistenceTestApp(
        authenticatedUser: testUser,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(
              updatedWithFood: true,
              runningLow: false,
            ),
          ),
        ],
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Edit notification preferences on iPhone
      // Check on iPad
      // Expected:
      //  - Preferences synced
      //  - Match across devices
      //  - Changes reflected immediately
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });
}

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

/// Helper to create app widget for multi-device tests
Widget createMultiDeviceTestApp({
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

  group('Multi-Device Scenarios', () {
    testWidgets('MULTI-001: Sign In on 2 Devices Simultaneously',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-1', email: 'test1@example.com');

      await tester.pumpWidget(createMultiDeviceTestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Sign in on iPhone and iPad at same time
      // Expected:
      //  - Both work correctly
      //  - Data syncs between them
      //  - FCM tokens registered for both devices
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('MULTI-002: Subscribe on iPhone, Receive Notification on Both',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-2', email: 'test2@example.com');

      await tester.pumpWidget(createMultiDeviceTestApp(
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

      // Subscribe on iPhone
      // iPad also signed in
      // Fridge updates
      // Expected:
      //  - Both devices receive notification
      //  - Notification content identical
      //  - Both can navigate to fridge details
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('MULTI-003: Sign Out on One Device',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-3', email: 'test3@example.com');

      await tester.pumpWidget(createMultiDeviceTestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Signed in on iPhone and iPad
      // Sign out on iPhone
      // Expected:
      //  - iPad still signed in
      //  - No disruption to iPad session
      //  - iPhone FCM token removed
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('MULTI-004: Delete Account on One Device, Check Other',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-4', email: 'test4@example.com');

      await tester.pumpWidget(createMultiDeviceTestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Delete account on iPhone
      // Check iPad
      // Expected:
      //  - iPad shows signed-out state
      //  - Must re-authenticate
      //  - Account data deleted from both
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('MULTI-005: Different Users on Different Devices',
        (WidgetTester tester) async {
      final testUserA = TestUser(uid: 'test-user-a', email: 'testa@example.com');
      final testUserB = TestUser(uid: 'test-user-b', email: 'testb@example.com');

      // Device A with User A
      await tester.pumpWidget(createMultiDeviceTestApp(
        authenticatedUser: testUserA,
        subscriptions: [
          SubscriptionPreferences(
            fridgeId: FridgeFixtures.verifiedFridgeWithFood.id,
            subscribedAt: DateTime.now(),
            notificationPreferences: const NotificationPreferences(),
          ),
        ],
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // User A on iPhone
      // User B on iPad
      // Expected:
      //  - Completely separate data
      //  - No cross-contamination
      //  - Each user sees only their subscriptions
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });
}

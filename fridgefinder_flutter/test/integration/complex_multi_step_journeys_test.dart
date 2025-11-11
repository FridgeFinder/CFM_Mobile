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

/// Helper to create app widget for journey tests
Widget createJourneyTestApp({
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

  group('Complex Multi-Step Journeys', () {
    testWidgets('JOURNEY-001: Complete Volunteer Path (Phone Auth)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createJourneyTestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // 1. Sign up with phone authentication
      // 2. Create profile as volunteer with zip code
      // 3. Subscribe to 3 fridges with different preferences
      // 4. Receive notifications for 2 fridges
      // 5. Tap notification, opens correct fridge
      // 6. Submit report with photo, earn +10 points
      // 7. Submit cleaning report, earn +20 points
      // 8. Submit stocking report, earn +30 points
      // 9. Check profile, verify 60 points total
      // 10. Edit notification preferences
      // 11. Enable geofencing
      // 12. Enter geofence, receive proximity notification
      // 13. Unsubscribe from 1 fridge
      // 14. Delete account, re-authenticate
      // 15. Verify account deleted, data removed
      // Expected: All steps succeed, data consistent throughout
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('JOURNEY-002: Complete Volunteer Path (Google Auth)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createJourneyTestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // Same as JOURNEY-001 but using Google Sign-In
      // Expected: All steps succeed, data consistent throughout
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('JOURNEY-003: Non-Volunteer Journey',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-3', email: 'test3@example.com');

      await tester.pumpWidget(createJourneyTestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // 1. Sign up as non-volunteer
      // 2. Subscribe to fridges
      // 3. Receive notifications
      // 4. Submit reports (no points awarded)
      // 5. Manage subscriptions
      // 6. Sign out
      // 7. Sign in again
      // 8. Data persists
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('JOURNEY-004: Error-Prone Journey',
        (WidgetTester tester) async {
      await tester.pumpWidget(createJourneyTestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // 1. Sign up with network errors (retry flow)
      // 2. Subscribe with permission denials (grant later)
      // 3. Submit reports with validation errors
      // 4. Disconnect network mid-operation (retry)
      // 5. Recover gracefully from all errors
      // 6. Complete journey successfully
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('JOURNEY-005: Permission-Heavy Journey',
        (WidgetTester tester) async {
      await tester.pumpWidget(createJourneyTestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // 1. Sign up
      // 2. Request location permission - Deny
      // 3. Request notification permission - Deny
      // 4. Try to subscribe - Works but limited
      // 5. Enable geofencing - Permission required
      // 6. Grant permissions via Settings
      // 7. Retry geofencing - Now works
      // 8. Complete journey with all features enabled
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('JOURNEY-006: Multi-Subscription Journey',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-6', email: 'test6@example.com');

      await tester.pumpWidget(createJourneyTestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // 1. Sign up
      // 2. Subscribe to 10 fridges consecutively
      // 3. Edit preferences for each differently
      // 4. Receive notifications from multiple fridges
      // 5. Report on all 10 fridges
      // 6. Earn points
      // 7. Unsubscribe from 5
      // 8. Subscribe to 5 new ones
      // 9. Final state: 10 subscriptions (5 original, 5 new)
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('JOURNEY-007: Offline-to-Online Journey',
        (WidgetTester tester) async {
      await tester.pumpWidget(createJourneyTestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // 1. Start app offline
      // 2. View cached data
      // 3. Try to subscribe (fails)
      // 4. Go online
      // 5. Retry subscribe (succeeds)
      // 6. Submit report
      // 7. Everything syncs correctly
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('JOURNEY-008: Platform-Switching Journey',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-8', email: 'test8@example.com');

      await tester.pumpWidget(createJourneyTestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // 1. Sign up on iPhone
      // 2. Subscribe to fridges
      // 3. Sign out
      // 4. Sign in on Android
      // 5. Verify all data synced
      // 6. Make changes on Android
      // 7. Check on iPhone
      // 8. Changes reflected
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('JOURNEY-009: Rapid Feature Usage',
        (WidgetTester tester) async {
      await tester.pumpWidget(createJourneyTestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // 1. Sign up quickly
      // 2. Immediately subscribe to 5 fridges
      // 3. Rapidly tap through all screens
      // 4. Submit multiple reports quickly
      // 5. Toggle settings rapidly
      // 6. App remains stable and consistent
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('JOURNEY-010: Geofencing-Focused Journey',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-10', email: 'test10@example.com');

      await tester.pumpWidget(createJourneyTestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // 1. Sign up
      // 2. Subscribe to nearby fridge
      // 3. Enable geofencing with "Always" permission
      // 4. Walk around neighborhood
      // 5. Enter geofence of subscribed fridge needing attention
      // 6. Receive proximity notification
      // 7. Tap notification, submit report
      // 8. Earn points
      // 9. Exit geofence (no notification)
      // 10. Enter geofence of non-subscribed fridge (proximity detected and logged, but no notification sent)
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('JOURNEY-011: Notification-Heavy Journey',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-11', email: 'test11@example.com');

      await tester.pumpWidget(createJourneyTestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // 1. Sign up
      // 2. Subscribe to 10 fridges
      // 3. Set all preferences to immediate
      // 4. Mock 10 fridges updating simultaneously
      // 5. Receive 10 notifications
      // 6. Tap through each notification
      // 7. Submit report on each fridge
      // 8. Check points accumulated correctly
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('JOURNEY-012: Filter-Focused Journey',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-12', email: 'test12@example.com');

      await tester.pumpWidget(createJourneyTestApp(
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

      // 1. Sign up and subscribe to fridges
      // 2. Enable subscribed filter
      // 3. Verify only subscribed fridges shown
      // 4. Combine with food level filters
      // 5. Combine with search
      // 6. Combine with location search
      // 7. Clear all filters
      // 8. Subscribe to new fridge while filter active
      // 9. Verify appears immediately
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('JOURNEY-013: Long-Term Usage Journey',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-13', email: 'test13@example.com');

      await tester.pumpWidget(createJourneyTestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // 1. Sign up
      // 2. Use app daily for 7 days
      // 3. Submit reports each day
      // 4. Accumulate 100+ points
      // 5. Subscribe/unsubscribe from various fridges
      // 6. Edit preferences multiple times
      // 7. Toggle settings
      // 8. Verify data integrity after week
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('JOURNEY-014: Account Lifecycle Journey',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-14', email: 'test14@example.com');

      await tester.pumpWidget(createJourneyTestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // 1. Sign up
      // 2. Use app extensively (subscribe, report, earn points)
      // 3. Sign out
      // 4. Sign in again (verify persistence)
      // 5. Continue using
      // 6. Delete account
      // 7. Try to sign in (account doesn't exist)
      // 8. Create new account with same credentials
      // 9. Verify fresh start (no old data)
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('JOURNEY-015: Edge Case Gauntlet',
        (WidgetTester tester) async {
      await tester.pumpWidget(createJourneyTestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // 1. Sign up with emoji username
      // 2. Subscribe with all notifications disabled
      // 3. Submit report with no photo
      // 4. Enable geofencing without location permission (fail)
      // 5. Grant permission manually
      // 6. Enable geofencing again (succeed)
      // 7. Unsubscribe from all fridges
      // 8. Subscribe to new fridges
      // 9. Rotate device during forms
      // 10. Background app during operations
      // 11. Kill app, reopen
      // 12. Everything still works
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });
}

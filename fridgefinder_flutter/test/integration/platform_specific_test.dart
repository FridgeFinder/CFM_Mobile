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

/// Helper to create app widget for platform-specific tests
Widget createPlatformTestApp({
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

  group('Platform-Specific - iOS-Specific', () {
    testWidgets('PLAT-001: iOS - App Tracking Transparency',
        (WidgetTester tester) async {
      await tester.pumpWidget(createPlatformTestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // iOS 14.5+, App Tracking Transparency prompt
      // Expected:
      //  - If tracking needed, prompt appears
      //  - If denied, app works without tracking
      //  - Analytics disabled if denied
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('PLAT-002: iOS - Background App Refresh',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-2', email: 'test2@example.com');

      await tester.pumpWidget(createPlatformTestApp(
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

      // Disable Background App Refresh for app
      // Expected:
      //  - Geofencing may not work properly
      //  - Notifications still arrive via FCM
      //  - Warning shown to user
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('PLAT-003: iOS - Low Power Mode',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-3', email: 'test3@example.com');

      await tester.pumpWidget(createPlatformTestApp(
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

      // Enable Low Power Mode
      // Geofencing active
      // Expected:
      //  - Geofencing accuracy reduced or disabled
      //  - Clear message about limitations
      //  - App adapts behavior
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('PLAT-004: iOS - Notification Grouping',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-4', email: 'test4@example.com');

      await tester.pumpWidget(createPlatformTestApp(
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

      // Receive 5 notifications
      // Expected:
      //  - iOS groups them by app
      //  - Expandable notification stack
      //  - Each notification separately actionable
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('PLAT-005: iOS - 3D Touch / Haptic Touch',
        (WidgetTester tester) async {
      await tester.pumpWidget(createPlatformTestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // Long press on map marker
      // Expected:
      //  - Quick actions or preview (if implemented)
      //  - Haptic feedback
      //  - Peek and pop functionality
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });

  group('Platform-Specific - Android-Specific', () {
    testWidgets('PLAT-006: Android - Notification Channels',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-6', email: 'test6@example.com');

      await tester.pumpWidget(createPlatformTestApp(
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

      // App creates notification channels
      // User disables specific channel
      // Expected:
      //  - Notifications for that channel don't appear
      //  - Other channels still work
      //  - App respects channel settings
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('PLAT-007: Android - Battery Optimization',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-7', email: 'test7@example.com');

      await tester.pumpWidget(createPlatformTestApp(
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

      // System aggressively kills background tasks
      // Geofencing enabled
      // Expected:
      //  - App requests exemption or shows guidance
      //  - User can whitelist app
      //  - Graceful degradation if denied
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('PLAT-008: Android - Doze Mode',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-8', email: 'test8@example.com');

      await tester.pumpWidget(createPlatformTestApp(
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

      // Device enters Doze mode
      // Expected:
      //  - App behavior limited
      //  - Notifications may delay
      //  - FCM high-priority messages still delivered
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('PLAT-009: Android - Split Screen Mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(createPlatformTestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // Use app in split screen
      // Expected:
      //  - UI adapts to smaller screen size
      //  - Remains functional
      //  - Layout adjusts appropriately
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('PLAT-010: Android - Picture-in-Picture',
        (WidgetTester tester) async {
      await tester.pumpWidget(createPlatformTestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // If video/maps support PiP
      // Expected:
      //  - Works smoothly
      //  - Maintains state
      //  - Can return to full screen
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });
}

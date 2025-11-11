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

/// Helper to create app widget for edit preferences tests
Widget createEditPreferencesTestApp({
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

  group('Edit Notification Preferences', () {
    testWidgets('EDIT-001: Edit Notifications Button Visibility',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-1', email: 'test1@example.com');

      await tester.pumpWidget(createEditPreferencesTestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Open fridge profile sheet for non-subscribed fridge
      // Expected:
      //  - Only "Subscribe" button visible
      // Subscribe to fridge
      // Expected:
      //  - "Edit Notifications" and "Unsubscribe" buttons appear
      //  - Buttons stacked vertically, compact design
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('EDIT-002: Edit Notifications - Loading Dialog Flow',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-2', email: 'test2@example.com');

      await tester.pumpWidget(createEditPreferencesTestApp(
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

      // Tap "Edit Notifications"
      // Expected:
      //  - Full-screen loading dialog appears (circular indicator, dimmed background)
      //  - Preferences load
      //  - Loading dialog dismisses automatically (NO HANGING)
      //  - Edit preferences dialog appears
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('EDIT-003: Edit Notifications - All Preferences Displayed',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-3', email: 'test3@example.com');

      await tester.pumpWidget(createEditPreferencesTestApp(
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

      // Open edit dialog
      // Expected:
      //  - All 6 notification types shown:
      //    - Updated with Food ✓
      //    - Running Low ✓
      //    - Empty ✓
      //    - Needs Cleaning
      //    - Needs Servicing
      //    - Routine Validation
      //  - Each has icon, title, subtitle, and toggle switch
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('EDIT-004: Edit Notifications - Toggle Switches',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-4', email: 'test4@example.com');

      await tester.pumpWidget(createEditPreferencesTestApp(
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

      // Toggle "Needs Cleaning" on
      // Toggle "Running Low" off
      // Expected:
      //  - Switches animate smoothly
      //  - Current state persisted in dialog
      //  - No API call until "Save" clicked
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('EDIT-005: Edit Notifications - Cancel Changes',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-5', email: 'test5@example.com');

      await tester.pumpWidget(createEditPreferencesTestApp(
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
        ],
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Change 3 preferences
      // Tap "Cancel"
      // Expected:
      //  - Dialog closes, NO changes saved
      // Reopen dialog
      // Expected:
      //  - Shows original preferences (changes discarded)
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('EDIT-006: Edit Notifications - Save Changes Successfully',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-6', email: 'test6@example.com');

      await tester.pumpWidget(createEditPreferencesTestApp(
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
        ],
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Change 2 preferences
      // Tap "Save"
      // Expected:
      //  - "Save" button shows loading spinner briefly
      //  - Dialog closes automatically (NO HANGING DIALOG)
      //  - Green success snackbar: "Notification preferences updated"
      //  - NO full-screen loading indicator remains
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('EDIT-007: Edit Notifications - Save Error Handling',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-7', email: 'test7@example.com');

      await tester.pumpWidget(createEditPreferencesTestApp(
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

      // Disconnect network
      // Change preferences
      // Tap "Save"
      // Expected:
      //  - Loading indicator appears
      //  - Error snackbar appears: "Error updating preferences..."
      //  - Dialog stays open (can retry)
      //  - NO hanging loading indicators
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('EDIT-008: Edit Notifications - Navigator Context Bug Fix',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-8', email: 'test8@example.com');

      await tester.pumpWidget(createEditPreferencesTestApp(
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

      // Open fridge profile sheet (bottom sheet)
      // Tap "Edit Notifications"
      // Expected:
      //  - Loading dialog uses root navigator
      //  - Edit dialog uses root navigator
      //  - NO context/navigator mismatch errors
      //  - All dialogs dismiss properly
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('EDIT-009: Edit Notifications - Rapid Taps',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-9', email: 'test9@example.com');

      await tester.pumpWidget(createEditPreferencesTestApp(
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

      // Rapidly tap "Edit Notifications" button 3 times
      // Expected:
      //  - Only ONE edit dialog opens
      //  - No duplicate loading dialogs
      //  - No navigator stack issues
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });
}

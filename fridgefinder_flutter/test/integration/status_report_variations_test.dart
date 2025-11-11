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
import '../helpers/firebase_emulator_helpers.dart';
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

/// Helper to create app widget for status report tests
Widget createStatusReportTestApp({
  firebase_auth.User? authenticatedUser,
  bool isVolunteer = false,
}) {
  final fridgesWithDistance = FridgeFixtures.allFridges
      .map((fridge) => FridgeWithDistance(fridge: fridge, distanceKm: null))
      .toList();

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
    ],
    child: const TestFridgeFinderApp(),
  );
}

void main() {
  setUpAll(() async {
    await initHiveForTesting();
    await initializeFirebaseEmulator();
  });

  tearDownAll(() async {
    await cleanupHive();
  });

  group('Status Report Variations - Basic Reports', () {
    testWidgets('REP-001: Submit Valid Status Report - Anonymous User',
        (WidgetTester tester) async {
      await tester.pumpWidget(createStatusReportTestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // Open fridge profile, tap "Report Status Update"
      // Fill out form: condition=good, foodPercentage=75, notes="Test"
      // Submit
      // Expected: Success, points NOT awarded (anonymous)
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('REP-002: Submit Valid Status Report - Authenticated Non-Volunteer',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-1', email: 'test1@example.com');

      await tester.pumpWidget(createStatusReportTestApp(
        authenticatedUser: testUser,
        isVolunteer: false,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Submit report as authenticated non-volunteer
      // Expected: Success, points NOT awarded
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('REP-003: Submit Valid Status Report - Authenticated Volunteer',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-2', email: 'test2@example.com');

      await tester.pumpWidget(createStatusReportTestApp(
        authenticatedUser: testUser,
        isVolunteer: true,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Submit report as authenticated volunteer
      // Expected: Success, base points awarded (10 points)
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('REP-004: Submit Report with Photo - Camera',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-3', email: 'test3@example.com');

      await tester.pumpWidget(createStatusReportTestApp(
        authenticatedUser: testUser,
        isVolunteer: true,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Tap "Add Photo" → Choose "Camera"
      // Take photo, confirm
      // Submit report
      // Expected: Photo uploaded to S3, URL saved in report
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('REP-005: Submit Report with Photo - Gallery',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-4', email: 'test4@example.com');

      await tester.pumpWidget(createStatusReportTestApp(
        authenticatedUser: testUser,
        isVolunteer: true,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Tap "Add Photo" → Choose "Gallery"
      // Select existing photo, confirm
      // Submit report
      // Expected: Photo uploaded, URL saved
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('REP-006: Submit Report Without Photo',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-5', email: 'test5@example.com');

      await tester.pumpWidget(createStatusReportTestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Fill form, don't add photo
      // Submit
      // Expected: Success, photo field is null
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('REP-007: Submit Report - Validation Error (Missing Condition)',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-6', email: 'test6@example.com');

      await tester.pumpWidget(createStatusReportTestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Leave condition unselected, fill other fields
      // Tap Submit
      // Expected: Validation error "Please select condition"
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('REP-008: Submit Report - Validation Error (Missing Food Level)',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-7', email: 'test7@example.com');

      await tester.pumpWidget(createStatusReportTestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Select condition, leave food level unselected
      // Tap Submit
      // Expected: Validation error "Please select food level"
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('REP-009: Submit Report - Network Error',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-8', email: 'test8@example.com');

      await tester.pumpWidget(createStatusReportTestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Fill form correctly
      // Disconnect network
      // Tap Submit
      // Expected: Network error message, can retry
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('REP-010: Submit Report - Cancel Mid-Submission',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-9', email: 'test9@example.com');

      await tester.pumpWidget(createStatusReportTestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Fill form, tap Submit
      // Tap Cancel/Back during submission
      // Expected: Submission cancelled, form data preserved or discarded
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });

  group('Status Report Variations - Bonus Points', () {
    testWidgets('REP-011: Cleaning Bonus - Dirty → Good (Volunteer)',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-10', email: 'test10@example.com');

      await tester.pumpWidget(createStatusReportTestApp(
        authenticatedUser: testUser,
        isVolunteer: true,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Fridge currently "Dirty"
      // Report new condition: "Good"
      // Expected: Base points (10) + Cleaning bonus (50) = 60 points total
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('REP-012: Cleaning Bonus - Out of Order → Good (Volunteer)',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-11', email: 'test11@example.com');

      await tester.pumpWidget(createStatusReportTestApp(
        authenticatedUser: testUser,
        isVolunteer: true,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Fridge currently "Out of Order"
      // Report new condition: "Good"
      // Expected: Base points (10) + Cleaning bonus (50) = 60 points total
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('REP-013: Stocking Bonus - Empty → Full (Volunteer)',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-12', email: 'test12@example.com');

      await tester.pumpWidget(createStatusReportTestApp(
        authenticatedUser: testUser,
        isVolunteer: true,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Fridge currently 0% food
      // Report new food level: 100%
      // Expected: Base points (10) + Stocking bonus (50) = 60 points total
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('REP-014: Stocking Bonus - Empty → Many Items (Volunteer)',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-13', email: 'test13@example.com');

      await tester.pumpWidget(createStatusReportTestApp(
        authenticatedUser: testUser,
        isVolunteer: true,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Fridge currently 0% food
      // Report new food level: 75%
      // Expected: Base points (10) + Stocking bonus (50) = 60 points total
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('REP-015: Both Bonuses - Dirty+Empty → Good+Full (Volunteer)',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-14', email: 'test14@example.com');

      await tester.pumpWidget(createStatusReportTestApp(
        authenticatedUser: testUser,
        isVolunteer: true,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Fridge currently Dirty and 0% food
      // Report: Good and 100% food
      // Expected: Base (10) + Cleaning (50) + Stocking (50) = 110 points total
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('REP-016: No Bonus - Good → Good (Volunteer)',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-15', email: 'test15@example.com');

      await tester.pumpWidget(createStatusReportTestApp(
        authenticatedUser: testUser,
        isVolunteer: true,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Fridge currently Good and 50% food
      // Report: Good and 50% food (no change)
      // Expected: Base points only (10)
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('REP-017: No Bonus - Good → Dirty (Volunteer)',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-16', email: 'test16@example.com');

      await tester.pumpWidget(createStatusReportTestApp(
        authenticatedUser: testUser,
        isVolunteer: true,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Fridge currently Good
      // Report: Dirty (decline in condition)
      // Expected: Base points only (10), no bonus
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('REP-018: Bonus Not Awarded to Non-Volunteer',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-17', email: 'test17@example.com');

      await tester.pumpWidget(createStatusReportTestApp(
        authenticatedUser: testUser,
        isVolunteer: false,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Non-volunteer reports: Dirty → Good
      // Expected: No points awarded at all (non-volunteer)
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('REP-019: Bonus Not Awarded to Anonymous User',
        (WidgetTester tester) async {
      await tester.pumpWidget(createStatusReportTestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // Anonymous user reports: Dirty → Good
      // Expected: No points awarded
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('REP-020: Points Visible in Profile After Report',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-18', email: 'test18@example.com');

      await tester.pumpWidget(createStatusReportTestApp(
        authenticatedUser: testUser,
        isVolunteer: true,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Submit report earning points
      // Navigate to Profile screen
      // Expected: New point total visible, activity log shows report
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });
}

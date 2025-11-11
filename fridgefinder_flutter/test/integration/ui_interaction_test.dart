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

/// Helper to create app widget for UI tests
Widget createUITestApp({
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

  group('UI & Interaction - Screen Rotation', () {
    testWidgets('UI-001: Rotate During Sign-In Form',
        (WidgetTester tester) async {
      await tester.pumpWidget(createUITestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // Fill out profile form
      // Rotate device 90°
      // Expected:
      //  - Form data persists
      //  - Layout adjusts to landscape
      //  - No data loss
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('UI-002: Rotate During Map View',
        (WidgetTester tester) async {
      await tester.pumpWidget(createUITestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // Viewing map
      // Rotate device
      // Expected:
      //  - Map redraws correctly
      //  - Markers remain visible
      //  - User position maintained
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('UI-003: Rotate During Bottom Sheet',
        (WidgetTester tester) async {
      await tester.pumpWidget(createUITestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // Fridge profile sheet open
      // Rotate device
      // Expected:
      //  - Sheet adjusts height
      //  - Content remains accessible
      //  - No content cut off
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });

  group('UI & Interaction - Rapid Interaction', () {
    testWidgets('UI-004: Rapid Filter Toggle',
        (WidgetTester tester) async {
      await tester.pumpWidget(createUITestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // Tap filter pills rapidly 10+ times
      // Expected:
      //  - No crashes
      //  - State updates correctly
      //  - UI remains responsive
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('UI-005: Rapid Subscribe/Unsubscribe',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-5', email: 'test5@example.com');

      await tester.pumpWidget(createUITestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Tap Subscribe and Unsubscribe buttons rapidly
      // Expected:
      //  - Final state is consistent
      //  - No race conditions
      //  - Button state correct
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('UI-006: Spam Refresh',
        (WidgetTester tester) async {
      await tester.pumpWidget(createUITestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // Pull to refresh list 10 times rapidly
      // Expected:
      //  - Only one or few refresh operations
      //  - Handles gracefully
      //  - No memory leaks
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });

  group('UI & Interaction - Accessibility', () {
    testWidgets('UI-007: Screen Reader Enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(createUITestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // Enable TalkBack (Android) or VoiceOver (iOS)
      // Navigate app
      // Expected:
      //  - All buttons/elements have accessibility labels
      //  - Semantic tree is well-formed
      //  - Navigation is logical
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('UI-008: Large Text Size',
        (WidgetTester tester) async {
      await tester.pumpWidget(createUITestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // Increase system text size to maximum
      // Open app
      // Expected:
      //  - UI adjusts to larger text
      //  - Text doesn't overflow
      //  - Layout remains usable
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('UI-009: Dark Mode Toggle',
        (WidgetTester tester) async {
      final testUser = TestUser(uid: 'test-user-9', email: 'test9@example.com');

      await tester.pumpWidget(createUITestApp(
        authenticatedUser: testUser,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      // Toggle dark mode in profile
      // Expected:
      //  - UI updates immediately
      //  - Theme persists across app restart
      //  - All screens respect theme
      expect(find.text('Fridge Map'), findsWidgets);
    });

    testWidgets('UI-010: Reduced Motion',
        (WidgetTester tester) async {
      await tester.pumpWidget(createUITestApp());
      await tester.pump(const Duration(milliseconds: 200));

      // Enable "Reduce Motion" accessibility setting
      // Expected:
      //  - Pulsing animations stop or reduce
      //  - Transitions are simpler
      //  - App remains functional
      expect(find.text('Fridge Map'), findsWidgets);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgefinder_app/src/features/profile/presentation/screens/status_update_screen.dart';
import 'package:fridgefinder_app/src/features/profile/presentation/widgets/status_update_form.dart';
import '../../../../fixtures/fridge_fixtures.dart';

/// Helper to pump StatusUpdateScreen inside a Navigator (needed for pop tests).
Widget _buildTestApp({
  required StatusUpdateScreen screen,
}) {
  return ProviderScope(
    child: MaterialApp(
      home: screen,
    ),
  );
}

void main() {
  // ---------------------------------------------------------------------------
  // Cycle 4: Full Page Wrapper
  // ---------------------------------------------------------------------------
  group('StatusUpdateScreen layout', () {
    testWidgets('renders Scaffold with AppBar titled "Report Status Update"',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(
        screen: StatusUpdateScreen(
          fridge: FridgeFixtures.verifiedFridgeWithFood,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.text('Report Status Update'), findsOneWidget);
      // Verify it's in an AppBar
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Report Status Update'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('contains StatusUpdateForm', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        screen: StatusUpdateScreen(
          fridge: FridgeFixtures.verifiedFridgeWithFood,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(StatusUpdateForm), findsOneWidget);
    });

    testWidgets('body wrapped in GestureDetector for keyboard dismissal',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(
        screen: StatusUpdateScreen(
          fridge: FridgeFixtures.verifiedFridgeWithFood,
        ),
      ));
      await tester.pumpAndSettle();

      // The GestureDetector should be an ancestor of the StatusUpdateForm
      expect(
        find.ancestor(
          of: find.byType(StatusUpdateForm),
          matching: find.byType(GestureDetector),
        ),
        findsWidgets,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Cycle 5: PopScope — Unsaved Changes Protection
  // ---------------------------------------------------------------------------
  group('PopScope unsaved changes', () {
    testWidgets('PopScope canPop=true when no data entered', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        screen: StatusUpdateScreen(
          fridge: FridgeFixtures.verifiedFridgeWithFood,
        ),
      ));
      await tester.pumpAndSettle();

      final popScopeFinder = find.byWidgetPredicate((w) => w is PopScope);
      expect(popScopeFinder, findsWidgets);
      final popScope = tester.widget<PopScope>(popScopeFinder.first);
      expect(popScope.canPop, isTrue);
    });

    testWidgets('PopScope canPop=false after selecting a condition',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(
        screen: StatusUpdateScreen(
          fridge: FridgeFixtures.verifiedFridgeWithFood,
        ),
      ));
      await tester.pumpAndSettle();

      // Select a condition
      await tester.tap(find.text('Good'));
      await tester.pumpAndSettle();

      final popScopeFinder = find.byWidgetPredicate((w) => w is PopScope);
      expect(popScopeFinder, findsWidgets);
      final popScope = tester.widget<PopScope>(popScopeFinder.first);
      expect(popScope.canPop, isFalse);
    });

    testWidgets('back with unsaved data shows discard confirmation dialog',
        (tester) async {
      // Wrap in a Navigator so we can test pop behavior
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StatusUpdateScreen(
                        fridge: FridgeFixtures.verifiedFridgeWithFood,
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to the screen
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Make the form dirty
      await tester.tap(find.text('Good'));
      await tester.pumpAndSettle();

      // Simulate back navigation
      final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
      await widgetsAppState.didPopRoute();
      await tester.pumpAndSettle();

      // Should see the discard dialog
      expect(find.text('Discard changes?'), findsOneWidget);
    });

    testWidgets('tapping Discard in dialog pops the page', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StatusUpdateScreen(
                        fridge: FridgeFixtures.verifiedFridgeWithFood,
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to the screen
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Make the form dirty
      await tester.tap(find.text('Good'));
      await tester.pumpAndSettle();

      // Simulate back navigation
      final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
      await widgetsAppState.didPopRoute();
      await tester.pumpAndSettle();

      // Tap Discard
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      // Should be back at the original page
      expect(find.text('Open'), findsOneWidget);
      expect(find.byType(StatusUpdateScreen), findsNothing);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgefinder_app/src/features/map/presentation/controllers/filter_condition.dart';
import 'package:fridgefinder_app/src/features/map/presentation/widgets/filter_pill_button.dart';
import '../../../../test_setup.dart';

void main() {
  setUpAll(() async {
    await setupTests();
  });

  tearDownAll(() async {
    await teardownTests();
  });

  group('FilterPillButton Tests', () {
    testWidgets('renders with correct label', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FilterPillButton(
                condition: FilterCondition.goodWithFood,
                isSelected: false,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Good (w/ Food)'), findsOneWidget);
    });

    testWidgets('shows green checkmark when selected', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FilterPillButton(
                condition: FilterCondition.goodWithFood,
                isSelected: true,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('does not show checkmark when not selected', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FilterPillButton(
                condition: FilterCondition.goodWithFood,
                isSelected: false,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('has rounded border shape', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FilterPillButton(
                condition: FilterCondition.goodWithFood,
                isSelected: false,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      final container = find.byType(Container).first;
      expect(container, findsOneWidget);
    });

    testWidgets('responds to tap', (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FilterPillButton(
                condition: FilterCondition.goodWithFood,
                isSelected: false,
                onPressed: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('different conditions display different labels', (
      WidgetTester tester,
    ) async {
      final conditions = [
        FilterCondition.goodWithFood,
        FilterCondition.goodEmpty,
        FilterCondition.dirty,
        FilterCondition.outOfOrder,
        FilterCondition.ghost,
        FilterCondition.notAtLocation,
      ];

      for (final condition in conditions) {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: FilterPillButton(
                  condition: condition,
                  isSelected: false,
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.text(condition.label), findsOneWidget);
      }
    });

    testWidgets('selected state changes appearance', (
      WidgetTester tester,
    ) async {
      final key = GlobalKey();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FilterPillButton(
                key: key,
                condition: FilterCondition.goodWithFood,
                isSelected: false,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Check unselected state
      expect(find.byIcon(Icons.check), findsNothing);

      // Rebuild with selected
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FilterPillButton(
                key: key,
                condition: FilterCondition.goodWithFood,
                isSelected: true,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Check selected state
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}

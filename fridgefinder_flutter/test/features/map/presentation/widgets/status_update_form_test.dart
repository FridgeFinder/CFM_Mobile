import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgefinder_app/src/features/profile/presentation/widgets/status_update_form.dart';
import '../../../../fixtures/fridge_fixtures.dart';

void main() {
  group('StatusUpdateForm Widget Tests', () {
    testWidgets('displays form title', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatusUpdateForm(fridge: FridgeFixtures.verifiedFridgeWithFood),
            ),
          ),
        ),
      );

      expect(find.text('Fridge Condition'), findsOneWidget);
    });

    testWidgets('displays food level slider', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatusUpdateForm(fridge: FridgeFixtures.verifiedFridgeWithFood),
            ),
          ),
        ),
      );

      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('displays food level percentage', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatusUpdateForm(fridge: FridgeFixtures.verifiedFridgeWithFood),
            ),
          ),
        ),
      );

      expect(find.textContaining('%'), findsWidgets);
    });

    testWidgets('displays notes field', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatusUpdateForm(fridge: FridgeFixtures.verifiedFridgeWithFood),
            ),
          ),
        ),
      );

      expect(find.text('Additional Notes (Optional)'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('displays submit button', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatusUpdateForm(fridge: FridgeFixtures.verifiedFridgeWithFood),
            ),
          ),
        ),
      );

      expect(find.text('Submit Update'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('initializes with fridge latest condition', (WidgetTester tester) async {
      final fridge = FridgeFixtures.verifiedFridgeWithFood;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatusUpdateForm(fridge: fridge),
            ),
          ),
        ),
      );

      // Verify the form is displayed with condition options
      expect(find.text('Fridge Condition'), findsOneWidget);
      expect(find.text('Working - Fully Functional'), findsOneWidget);
    });

    testWidgets('has segmented button for condition selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatusUpdateForm(fridge: FridgeFixtures.verifiedFridgeWithFood),
            ),
          ),
        ),
      );

      // Check for condition selection widgets
      expect(find.text('Working - Fully Functional'), findsOneWidget);
    });

    testWidgets('slider has correct min and max', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatusUpdateForm(fridge: FridgeFixtures.verifiedFridgeWithFood),
            ),
          ),
        ),
      );

      final slider = find.byType(Slider);
      final sliderWidget = slider.evaluate().single.widget as Slider;

      expect(sliderWidget.min, 0);
      expect(sliderWidget.max, 1);
    });

    testWidgets('slider has divisions', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatusUpdateForm(fridge: FridgeFixtures.verifiedFridgeWithFood),
            ),
          ),
        ),
      );

      final slider = find.byType(Slider);
      final sliderWidget = slider.evaluate().single.widget as Slider;

      expect(sliderWidget.divisions, 10);
    });

    testWidgets('shows all condition options', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatusUpdateForm(fridge: FridgeFixtures.verifiedFridgeWithFood),
            ),
          ),
        ),
      );

      expect(find.text('Working - Fully Functional'), findsOneWidget);
      expect(find.text('Needs Cleaning'), findsOneWidget);
      expect(find.text('Needs Servicing'), findsOneWidget);
      expect(find.text('Temporarily Unavailable'), findsOneWidget);
      expect(find.text('Permanently Unavailable'), findsOneWidget);
    });

    testWidgets('can interact with form elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatusUpdateForm(fridge: FridgeFixtures.verifiedFridgeWithFood),
            ),
          ),
        ),
      );

      // Type in notes field
      await tester.enterText(find.byType(TextField), 'Test notes');
      await tester.pumpAndSettle();

      expect(find.text('Test notes'), findsOneWidget);
    });

    testWidgets('displays form in scrollable view', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatusUpdateForm(fridge: FridgeFixtures.verifiedFridgeWithFood),
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('submit button is full width', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatusUpdateForm(fridge: FridgeFixtures.verifiedFridgeWithFood),
            ),
          ),
        ),
      );

      final sizedBox = find.ancestor(
        of: find.byType(ElevatedButton),
        matching: find.byType(SizedBox),
      );

      expect(sizedBox, findsOneWidget);
    });
  });
}

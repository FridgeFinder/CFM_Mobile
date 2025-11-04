import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/common_widgets/loading_indicator.dart';

void main() {
  group('LoadingIndicator Widget Tests', () {
    testWidgets('displays circular progress indicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingIndicator())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays message when provided', (WidgetTester tester) async {
      const testMessage = 'Loading fridges...';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingIndicator(message: testMessage)),
        ),
      );

      expect(find.text(testMessage), findsOneWidget);
    });

    testWidgets('does not display message when not provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingIndicator())),
      );

      expect(find.byType(Text), findsNothing);
    });

    testWidgets('centers content properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingIndicator(message: 'Loading')),
        ),
      );

      final centerFinder = find.byType(Center);
      expect(centerFinder, findsOneWidget);

      final center = centerFinder.evaluate().single.widget as Center;
      final column = center.child as Column;
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('message has proper spacing from indicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingIndicator(message: 'Test')),
        ),
      );

      final sizedBoxFinder = find.byType(SizedBox);
      expect(sizedBoxFinder, findsOneWidget);

      final sizedBox = sizedBoxFinder.evaluate().single.widget as SizedBox;
      expect(sizedBox.height, 16);
    });
  });
}

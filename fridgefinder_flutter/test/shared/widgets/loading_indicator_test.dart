import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/common_widgets/loading_indicator.dart';
import 'package:design_system/design_system.dart';

void main() {
  group('LoadingIndicator Widget Tests', () {
    testWidgets('displays loading indicator M3E', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingIndicator())),
      );

      expect(find.byType(LoadingIndicatorM3E), findsOneWidget);
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

    testWidgets('displays random message when not provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingIndicator())),
      );

      // Should display a text message (a random loading message)
      expect(find.byType(Text), findsOneWidget);
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

    testWidgets('message is displayed with LoadingIndicatorM3E', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingIndicator(message: 'Test')),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
      expect(find.byType(LoadingIndicatorM3E), findsOneWidget);
    });
  });
}

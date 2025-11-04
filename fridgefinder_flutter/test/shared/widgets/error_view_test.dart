import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/common_widgets/error_view.dart';

void main() {
  group('ErrorView Widget Tests', () {
    testWidgets('displays error icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ErrorView(message: 'Test error')),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays default title when not provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ErrorView(message: 'Test error')),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('displays custom title when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(title: 'Custom Error', message: 'Test message'),
          ),
        ),
      );

      expect(find.text('Custom Error'), findsOneWidget);
    });

    testWidgets('displays error message', (WidgetTester tester) async {
      const errorMessage = 'Network connection failed';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ErrorView(message: errorMessage)),
        ),
      );

      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('displays retry button when onRetry provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(message: 'Test error', onRetry: () {}),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('does not display retry button when onRetry not provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ErrorView(message: 'Test error')),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('calls retry callback when retry button tapped', (
      WidgetTester tester,
    ) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'Test error',
              onRetry: () => retryPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(retryPressed, isTrue);
    });

    testWidgets('uses custom retry label when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'Test error',
              onRetry: () {},
              retryLabel: 'Retry Now',
            ),
          ),
        ),
      );

      expect(find.text('Retry Now'), findsOneWidget);
    });
  });
}

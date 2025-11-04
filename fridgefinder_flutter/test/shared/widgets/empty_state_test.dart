import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/common_widgets/empty_state.dart';

void main() {
  group('EmptyStateView Widget Tests', () {
    testWidgets('displays custom icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              title: 'No Results',
              message: 'Nothing found',
              icon: Icons.search_off,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('displays default icon when not provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(title: 'Empty', message: 'Nothing here'),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('displays title', (WidgetTester tester) async {
      const title = 'No Fridges Found';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(title: title, message: 'Test message'),
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
    });

    testWidgets('displays message', (WidgetTester tester) async {
      const message = 'There are no items to display';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(title: 'Empty', message: message),
          ),
        ),
      );

      expect(find.text(message), findsOneWidget);
    });

    testWidgets('displays action widget when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              title: 'Empty',
              message: 'Test message',
              action: ElevatedButton(
                onPressed: () {},
                child: const Text('Retry'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('does not display action when not provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(title: 'Empty', message: 'Test message'),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('centers content properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(title: 'Empty', message: 'Test message'),
          ),
        ),
      );

      final centerFinder = find.byType(Center);
      expect(centerFinder, findsWidgets);

      // Verify at least one Center exists
      expect(centerFinder.evaluate().isNotEmpty, isTrue);
    });
  });
}

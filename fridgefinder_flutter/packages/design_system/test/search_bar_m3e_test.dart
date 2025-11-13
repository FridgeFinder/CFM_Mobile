import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/navigation/search_bar_m3e.dart';

void main() {
  group('SearchBarM3E', () {
    testWidgets('renders with default properties', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchBarM3E(),
          ),
        ),
      );

      expect(find.byType(SearchBarM3E), findsOneWidget);
    });

    testWidgets('displays hint text when provided', (tester) async {
      const hintText = 'Search for fridges...';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchBarM3E(
              hintText: hintText,
            ),
          ),
        ),
      );

      expect(find.text(hintText), findsOneWidget);
    });

    testWidgets('expands on tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchBarM3E(
              hintText: 'Search...',
            ),
          ),
        ),
      );

      // Tap the search bar
      await tester.tap(find.byType(SearchBarM3E));
      await tester.pumpAndSettle();

      // Verify TextField is visible (expanded state)
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('calls onChanged callback when text changes', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarM3E(
              hintText: 'Search...',
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      // Tap to expand
      await tester.tap(find.byType(SearchBarM3E));
      await tester.pumpAndSettle();

      // Enter text
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();

      expect(changedValue, equals('test query'));
    });

    testWidgets('calls onSubmitted callback when submitted', (tester) async {
      String? submittedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarM3E(
              hintText: 'Search...',
              onSubmitted: (value) {
                submittedValue = value;
              },
            ),
          ),
        ),
      );

      // Tap to expand
      await tester.tap(find.byType(SearchBarM3E));
      await tester.pumpAndSettle();

      // Enter text
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();

      // Submit
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submittedValue, equals('test query'));
    });

    testWidgets('shows clear button when text is present', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarM3E(
              controller: controller,
              expandedByDefault: true,
            ),
          ),
        ),
      );

      // Initially no clear button
      expect(find.byIcon(Icons.clear), findsNothing);

      // Add text
      controller.text = 'test';
      await tester.pumpAndSettle();

      // Clear button should appear
      expect(find.byIcon(Icons.clear), findsOneWidget);

      controller.dispose();
    });

    testWidgets('clears text when clear button is pressed', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarM3E(
              controller: controller,
              expandedByDefault: true,
              onChanged: (value) {
                // Value changes are handled by controller
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter text
      controller.text = 'test query';
      await tester.pumpAndSettle();

      // Verify text is present
      expect(controller.text, equals('test query'));
      expect(find.byIcon(Icons.clear), findsOneWidget);

      // Find and tap clear button using skipOffstage: false to find hidden widgets
      final clearButton = find.descendant(
        of: find.byType(FadeTransition),
        matching: find.byType(IconButton),
        skipOffstage: false,
      );

      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      // Verify text is cleared
      expect(controller.text, isEmpty);

      controller.dispose();
    });

    testWidgets('shows voice search button when enabled', (tester) async {
      bool voiceSearchCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarM3E(
              showVoiceSearch: true,
              expandedByDefault: true,
              onVoiceSearch: () {
                voiceSearchCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify voice search button is present
      expect(find.byIcon(Icons.mic), findsOneWidget);

      // Tap voice search button
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pump();

      expect(voiceSearchCalled, isTrue);
    });

    testWidgets('auto-focuses when autoFocus is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchBarM3E(
              autoFocus: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify TextField is present (expanded state)
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('uses custom leading icon when provided', (tester) async {
      const customIcon = Icons.location_on;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchBarM3E(
              leadingIcon: customIcon,
            ),
          ),
        ),
      );

      expect(find.byIcon(customIcon), findsOneWidget);
    });

    testWidgets('uses custom trailing widget when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarM3E(
              expandedByDefault: true,
              trailing: IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });
  });

  group('CompactSearchBarM3E', () {
    testWidgets('renders with compact height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactSearchBarM3E(),
          ),
        ),
      );

      expect(find.byType(CompactSearchBarM3E), findsOneWidget);

      // Find the container
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CompactSearchBarM3E),
          matching: find.byType(Container),
        ),
      );

      // Verify height is 48dp (compact)
      expect(container.constraints?.maxHeight, equals(48.0));
    });

    testWidgets('calls onSubmitted callback', (tester) async {
      String? submittedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactSearchBarM3E(
              onSubmitted: (value) {
                submittedValue = value;
              },
            ),
          ),
        ),
      );

      // Enter text
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Submit
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submittedValue, equals('test'));
    });
  });

  group('SearchBarWithSuggestionsM3E', () {
    testWidgets('renders without suggestions initially', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchBarWithSuggestionsM3E(
              suggestions: ['Apple', 'Banana', 'Cherry'],
            ),
          ),
        ),
      );

      expect(find.byType(SearchBarWithSuggestionsM3E), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('shows filtered suggestions when typing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchBarWithSuggestionsM3E(
              suggestions: ['Apple', 'Banana', 'Cherry', 'Apricot'],
            ),
          ),
        ),
      );

      // Tap to expand
      await tester.tap(find.byType(SearchBarM3E));
      await tester.pumpAndSettle();

      // Enter text
      await tester.enterText(find.byType(TextField), 'ap');
      await tester.pumpAndSettle();

      // Verify filtered suggestions are shown
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Apricot'), findsOneWidget);
      expect(find.text('Banana'), findsNothing);
      expect(find.text('Cherry'), findsNothing);
    });

    testWidgets('calls onSuggestionSelected when tapping suggestion',
        (tester) async {
      String? selectedSuggestion;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarWithSuggestionsM3E(
              suggestions: const ['Apple', 'Banana', 'Cherry'],
              onSuggestionSelected: (value) {
                selectedSuggestion = value;
              },
            ),
          ),
        ),
      );

      // Tap to expand
      await tester.tap(find.byType(SearchBarM3E));
      await tester.pumpAndSettle();

      // Enter text to show suggestions
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pumpAndSettle();

      // Tap on a suggestion
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();

      expect(selectedSuggestion, equals('Apple'));
    });

    testWidgets('uses custom suggestion builder when provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarWithSuggestionsM3E(
              suggestions: const ['Apple', 'Banana'],
              suggestionBuilder: (context, suggestion) {
                return Container(
                  key: Key(suggestion),
                  child: Text('Custom: $suggestion'),
                );
              },
            ),
          ),
        ),
      );

      // Tap to expand
      await tester.tap(find.byType(SearchBarM3E));
      await tester.pumpAndSettle();

      // Enter text
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pumpAndSettle();

      // Verify custom builder is used
      expect(find.text('Custom: Apple'), findsOneWidget);
    });
  });
}

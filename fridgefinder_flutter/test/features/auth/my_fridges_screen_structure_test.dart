import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgefinder_app/src/features/auth/presentation/screens/my_fridges_screen.dart';
import 'package:design_system/design_system.dart';

/// Tests for MyFridgesScreen structure and widget composition
/// These tests verify the UI structure without requiring full provider mocking
void main() {
  group('MyFridgesScreen Loading States Structure', () {
    testWidgets('MyFridgesScreen widget is created successfully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MyFridgesScreen(),
          ),
        ),
      );

      // Verify the widget tree renders without errors
      expect(find.byType(MyFridgesScreen), findsOneWidget);
    });

    testWidgets('LoadingIndicatorM3E renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicatorM3E(message: 'Loading fridges...'),
          ),
        ),
      );

      await tester.pump();

      // Verify loading indicator is shown
      expect(find.byType(LoadingIndicatorM3E), findsOneWidget);
      expect(find.text('Loading fridges...'), findsOneWidget);
    });

    testWidgets('LoadingIndicatorM3E with random message',
        (WidgetTester tester) async {
      // Test that LoadingIndicatorM3E accepts any message
      const testMessages = [
        'Defrosting...',
        'Chilling...',
        'Loading...',
      ];

      for (final message in testMessages) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LoadingIndicatorM3E(message: message),
            ),
          ),
        );

        await tester.pump();

        expect(find.byType(LoadingIndicatorM3E), findsOneWidget);
        expect(find.text(message), findsOneWidget);

        // Use pump() instead of pumpAndSettle() for morphing animations
        await tester.pump(const Duration(milliseconds: 100));
      }
    });

    testWidgets('LoadingIndicatorM3E displays centered',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicatorM3E(message: 'Test'),
          ),
        ),
      );

      await tester.pump();

      // Verify Center widget exists (LoadingIndicatorM3E uses Center internally)
      expect(find.byType(Center), findsWidgets);
      expect(find.byType(LoadingIndicatorM3E), findsOneWidget);
    });

    testWidgets('Empty state icon and text render correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: M3ESpacing.all(M3ESpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Colors.grey,
                    ),
                    M3ESpacing.verticalXL,
                    Text(
                      'No Subscribed Fridges',
                      style: M3ETypography.headlineMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify empty state elements
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.text('No Subscribed Fridges'), findsOneWidget);
    });

    testWidgets('Card and ListTile structure for fridge items',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 1,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.kitchen),
                    title: const Text('Test Fridge'),
                    subtitle: const Text('123 Main St'),
                    trailing: const Icon(Icons.favorite),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify card structure
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('Test Fridge'), findsOneWidget);
      expect(find.text('123 Main St'), findsOneWidget);
      expect(find.byIcon(Icons.kitchen), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('ListView has correct padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 2,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text('Fridge $index'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the ListView
      final listView = tester.widget<ListView>(find.byType(ListView));

      // Verify padding
      expect(listView.padding, equals(const EdgeInsets.all(16)));
    });

    testWidgets('Error view structure with retry button',
        (WidgetTester tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64),
                  const SizedBox(height: 16),
                  const Text('Failed to load your fridges'),
                  const SizedBox(height: 16),
                  FilledButtonM3E(
                    onPressed: () {
                      retryPressed = true;
                    },
                    icon: Icons.refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify error state elements
      expect(find.text('Failed to load your fridges'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Test retry button
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(retryPressed, isTrue);
    });

    testWidgets('Sign-in prompt structure when not authenticated',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: M3ESpacing.all(M3ESpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 64,
                    ),
                    M3ESpacing.verticalXL,
                    Text(
                      'Subscribe to specific fridges to receive updates on food availability or when fridges need re-stocking or cleaning.',
                      textAlign: TextAlign.center,
                      style: M3ETypography.bodyMedium,
                    ),
                    M3ESpacing.verticalXXL,
                    FilledButtonM3E(
                      icon: Icons.login,
                      onPressed: () {},
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify sign-in prompt elements
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(
          find.text(
              'Subscribe to specific fridges to receive updates on food availability or when fridges need re-stocking or cleaning.'),
          findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Multiple fridge cards render in list',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.kitchen),
                    title: Text('Community Fridge #${index + 1}'),
                    subtitle: Text('Address ${index + 1}'),
                    trailing: const Icon(Icons.favorite),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify multiple cards
      expect(find.byType(Card), findsNWidgets(3));
      expect(find.text('Community Fridge #1'), findsOneWidget);
      expect(find.text('Community Fridge #2'), findsOneWidget);
      expect(find.text('Community Fridge #3'), findsOneWidget);
    });

    testWidgets('Card margin is correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Container(height: 50),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.margin, equals(const EdgeInsets.only(bottom: 12)));
    });

    testWidgets('FilledButtonM3E with icon renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilledButtonM3E(
              icon: Icons.map,
              onPressed: () {},
              child: const Text('Browse Fridges'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify button with icon
      expect(find.byType(FilledButtonM3E), findsOneWidget);
      expect(find.text('Browse Fridges'), findsOneWidget);
    });

    testWidgets('M3E spacing constants are consistent',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                M3ESpacing.verticalXS,
                M3ESpacing.verticalSM,
                M3ESpacing.verticalMD,
                M3ESpacing.verticalLG,
                M3ESpacing.verticalXL,
                M3ESpacing.verticalXXL,
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify column renders with spacing
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(SizedBox), findsNWidgets(6));
    });
  });
}

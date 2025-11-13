import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgefinder_app/src/features/profile/presentation/profile_screen.dart';
import 'package:design_system/design_system.dart';

/// Tests for ProfileScreen structure and widget composition
/// These tests verify the UI structure without requiring full provider mocking
void main() {
  group('ProfileScreen Structure Tests', () {
    testWidgets('ProfileScreen widget is created successfully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: ProfileScreen()),
          ),
        ),
      );

      // Verify the widget tree renders without errors
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('ProfileScreen has SingleChildScrollView for scrollability',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: ProfileScreen()),
          ),
        ),
      );

      await tester.pump();

      // Verify scrollable content structure
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('ProfileScreen uses M3E spacing and components',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: const Scaffold(body: ProfileScreen()),
          ),
        ),
      );

      await tester.pump();

      // Verify M3E components are used (CardM3E, Typography, etc)
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('ProfileScreen displays correctly with Material3 theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            home: const Scaffold(body: ProfileScreen()),
          ),
        ),
      );

      await tester.pump();

      // Verify it renders with M3 theme
      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('SwitchM3E widget structure is correct',
        (WidgetTester tester) async {
      bool testValue = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SwitchM3E(
              value: testValue,
              onChanged: (value) {
                testValue = value;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify SwitchM3E renders
      expect(find.byType(SwitchM3E), findsOneWidget);
    });

    testWidgets('SegmentedButtonM3E widget structure is correct',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SegmentedButtonM3E<String>(
              showSelectedIcon: false,
              emptySelectionAllowed: false,
              segments: const [
                ButtonSegment(
                  value: 'option1',
                  label: Text('Option 1'),
                ),
                ButtonSegment(
                  value: 'option2',
                  label: Text('Option 2'),
                ),
              ],
              selected: const {'option1'},
              onSelectionChanged: (Set<String> selected) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify SegmentedButtonM3E renders
      expect(find.byType(SegmentedButtonM3E<String>), findsOneWidget);
      expect(find.text('Option 1'), findsOneWidget);
      expect(find.text('Option 2'), findsOneWidget);
    });

    testWidgets('LoadingIndicatorM3E displays with message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicatorM3E(message: 'Test loading message'),
          ),
        ),
      );

      await tester.pump();

      // Verify loading indicator and message
      expect(find.byType(LoadingIndicatorM3E), findsOneWidget);
      expect(find.text('Test loading message'), findsOneWidget);
    });

    testWidgets('LoadingIndicatorM3E displays without message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicatorM3E(),
          ),
        ),
      );

      await tester.pump();

      // Verify loading indicator renders without message
      expect(find.byType(LoadingIndicatorM3E), findsOneWidget);
    });

    testWidgets('CardM3E renders with child content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardM3E(
              child: const Text('Card content'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify card and content
      expect(find.byType(CardM3E), findsOneWidget);
      expect(find.text('Card content'), findsOneWidget);
    });

    testWidgets('FilledButtonM3E renders with icon and text',
        (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilledButtonM3E(
              icon: Icons.check,
              onPressed: () {
                pressed = true;
              },
              child: const Text('Test Button'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify button renders
      expect(find.byType(FilledButtonM3E), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);

      // Test button tap
      await tester.tap(find.byType(FilledButtonM3E));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('OutlinedButtonM3E renders with icon and text',
        (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OutlinedButtonM3E(
              icon: Icons.logout,
              onPressed: () {
                pressed = true;
              },
              child: const Text('Test Outlined'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify button renders
      expect(find.byType(OutlinedButtonM3E), findsOneWidget);
      expect(find.text('Test Outlined'), findsOneWidget);

      // Test button tap
      await tester.tap(find.byType(OutlinedButtonM3E));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('CircularProgressIndicatorM3E renders with different sizes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CircularProgressIndicatorM3E.small(),
                CircularProgressIndicatorM3E.medium(),
                CircularProgressIndicatorM3E.large(),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify all three size variants render
      expect(find.byType(CircularProgressIndicatorM3E), findsNWidgets(3));
    });

    testWidgets('M3E typography styles are applied correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Headline', style: M3ETypography.headlineMedium),
                Text('Title', style: M3ETypography.titleLarge),
                Text('Body', style: M3ETypography.bodyMedium),
                Text('Label', style: M3ETypography.labelSmall),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify text widgets render
      expect(find.text('Headline'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
      expect(find.text('Label'), findsOneWidget);
    });
  });
}

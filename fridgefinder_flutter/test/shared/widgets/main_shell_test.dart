import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:fridgefinder_app/src/common_widgets/main_shell.dart';
import '../../helpers/test_helpers.dart';

void main() {
  setUpAll(() async {
    await initHiveForTesting();
  });

  tearDownAll(() async {
    await cleanupHive();
  });

  group('MainShell Widget Tests', () {
    testWidgets('displays correct page title for map route', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MainShell(
              currentRoute: '/',
              child: const Scaffold(body: Center(child: Text('Map Screen'))),
            ),
          ),
        ),
      );

      // Check for Fridge Map text (appears in AppBar and drawer when opened)
      expect(find.text('Fridge Map'), findsWidgets);
      // Verify it appears at least once
      expect(
        find.text('Fridge Map').evaluate().length,
        greaterThanOrEqualTo(1),
      );
    });

    testWidgets('displays correct page title for list route', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MainShell(
              currentRoute: '/list',
              child: const Scaffold(body: Center(child: Text('List Screen'))),
            ),
          ),
        ),
      );

      // Check for Fridge List text (appears in AppBar and drawer when opened)
      expect(find.text('Fridge List'), findsWidgets);
      // Verify it appears at least once
      expect(
        find.text('Fridge List').evaluate().length,
        greaterThanOrEqualTo(1),
      );
    });

    testWidgets('displays correct page title for favorites route', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MainShell(
              currentRoute: '/my-fridges',
              child: const Scaffold(
                body: Center(child: Text('My Fridges Screen')),
              ),
            ),
          ),
        ),
      );

      // Check for My Fridges text
      expect(find.text('My Fridges'), findsWidgets);
    });

    testWidgets('displays correct page title for profile route', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MainShell(
              currentRoute: '/profile',
              child: const Scaffold(
                body: Center(child: Text('Profile Screen')),
              ),
            ),
          ),
        ),
      );

      // Check for Profile text (appears in AppBar and drawer when opened)
      expect(find.text('Profile'), findsWidgets);
      // Verify it appears at least once
      expect(find.text('Profile').evaluate().length, greaterThanOrEqualTo(1));
    });

    testWidgets('drawer displays all menu items when opened', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MainShell(
              currentRoute: '/',
              child: const Scaffold(body: Center(child: Text('Map Screen'))),
            ),
          ),
        ),
      );

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify all menu items are displayed
      expect(find.text('Fridge Map'), findsWidgets); // In appbar and drawer
      expect(find.text('Fridge List'), findsOneWidget);
      expect(find.text('My Fridges').evaluate().length, greaterThanOrEqualTo(1));
      expect(find.text('Profile'), findsWidgets);
    });

    testWidgets('drawer has close button', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MainShell(
              currentRoute: '/',
              child: const Scaffold(body: Center(child: Text('Map Screen'))),
            ),
          ),
        ),
      );

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify drawer is open
      expect(find.text('About FridgeFinder'), findsOneWidget);

      // Verify close button exists (there should be at least one more close icon than in the closed state)
      expect(find.byIcon(Icons.close), findsWidgets);
    });

    testWidgets('displays bottom navigation bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MainShell(
              currentRoute: '/',
              child: const Scaffold(body: Center(child: Text('Map Screen'))),
            ),
          ),
        ),
      );

      expect(find.byType(NavigationBarEnhancedM3E), findsOneWidget);
    });

    testWidgets('renders child widget content', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MainShell(
              currentRoute: '/',
              child: const Scaffold(
                body: Center(child: Text('Custom Child Content')),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Custom Child Content'), findsOneWidget);
    });
  });
}

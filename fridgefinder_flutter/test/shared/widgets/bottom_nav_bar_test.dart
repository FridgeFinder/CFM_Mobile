import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgefinder_app/src/common_widgets/bottom_nav_bar.dart';
import '../../helpers/test_helpers.dart';

void main() {
  setUpAll(() async {
    await initHiveForTesting();
  });

  tearDownAll(() async {
    await cleanupHive();
  });

  group('AppBottomNavBar Widget Tests', () {
    testWidgets('displays all navigation items', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              bottomNavigationBar: AppBottomNavBar(currentRoute: '/'),
              body: SizedBox(),
            ),
          ),
        ),
      );

      expect(find.text('Map'), findsOneWidget);
      expect(find.text('List'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('displays correct icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              bottomNavigationBar: AppBottomNavBar(currentRoute: '/'),
              body: SizedBox(),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.map), findsOneWidget);
      expect(find.byIcon(Icons.list), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('highlights correct item for / route', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              bottomNavigationBar: AppBottomNavBar(currentRoute: '/'),
              body: SizedBox(),
            ),
          ),
        ),
      );

      final navBar = find.byType(BottomNavigationBar);
      expect(navBar, findsOneWidget);

      final bottomNavBar = navBar.evaluate().single.widget as BottomNavigationBar;
      expect(bottomNavBar.currentIndex, 0);
    });

    testWidgets('highlights correct item for /list route', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              bottomNavigationBar: AppBottomNavBar(currentRoute: '/list'),
              body: SizedBox(),
            ),
          ),
        ),
      );

      final navBar = find.byType(BottomNavigationBar);
      final bottomNavBar = navBar.evaluate().single.widget as BottomNavigationBar;
      expect(bottomNavBar.currentIndex, 1);
    });

    testWidgets('highlights correct item for /favorites route', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              bottomNavigationBar: AppBottomNavBar(currentRoute: '/favorites'),
              body: SizedBox(),
            ),
          ),
        ),
      );

      final navBar = find.byType(BottomNavigationBar);
      final bottomNavBar = navBar.evaluate().single.widget as BottomNavigationBar;
      expect(bottomNavBar.currentIndex, 2);
    });

    testWidgets('highlights correct item for /profile route', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              bottomNavigationBar: AppBottomNavBar(currentRoute: '/profile'),
              body: SizedBox(),
            ),
          ),
        ),
      );

      final navBar = find.byType(BottomNavigationBar);
      final bottomNavBar = navBar.evaluate().single.widget as BottomNavigationBar;
      expect(bottomNavBar.currentIndex, 3);
    });

    testWidgets('defaults to Map (index 0) for unknown route', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              bottomNavigationBar: AppBottomNavBar(currentRoute: '/unknown'),
              body: SizedBox(),
            ),
          ),
        ),
      );

      final navBar = find.byType(BottomNavigationBar);
      final bottomNavBar = navBar.evaluate().single.widget as BottomNavigationBar;
      expect(bottomNavBar.currentIndex, 0);
    });

    testWidgets('shows BottomNavigationBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              bottomNavigationBar: AppBottomNavBar(currentRoute: '/'),
              body: SizedBox(),
            ),
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}

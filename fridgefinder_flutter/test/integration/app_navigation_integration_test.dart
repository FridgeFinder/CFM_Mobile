import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fridgefinder_app/app.dart';
import 'package:fridgefinder_app/src/features/map/presentation/controllers/fridge_list_controller.dart';
import '../fixtures/fridge_fixtures.dart';
import '../helpers/test_helpers.dart';

void main() {
  setUpAll(() async {
    await initHiveForTesting();
  });

  tearDownAll(() async {
    await cleanupHive();
  });

  group('App Navigation Integration Tests', () {
    testWidgets('app starts with map screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fridgeListProvider.overrideWith((ref) async => FridgeFixtures.allFridges),
          ],
          child: const FridgeFinderApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fridge Map'), findsOneWidget);
    });

    testWidgets('navigates from map to list via bottom nav', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fridgeListProvider.overrideWith((ref) async => FridgeFixtures.allFridges),
          ],
          child: const FridgeFinderApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap the List navigation item - tap the icon in the bottom nav bar
      final navBar = find.byType(BottomNavigationBar);
      expect(navBar, findsWidgets);

      final listIcon = find.byIcon(Icons.list).last;
      await tester.tap(listIcon);
      await tester.pumpAndSettle();

      expect(find.text('Fridge List'), findsOneWidget);
    });

    testWidgets('navigates from list to map via bottom nav', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fridgeListProvider.overrideWith((ref) async => FridgeFixtures.allFridges),
          ],
          child: const FridgeFinderApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to list
      final listIcon = find.byIcon(Icons.list).last;
      await tester.tap(listIcon);
      await tester.pumpAndSettle();

      expect(find.text('Fridge List'), findsOneWidget);

      // Navigate back to map
      final mapIcon = find.byIcon(Icons.map).first;
      await tester.tap(mapIcon);
      await tester.pumpAndSettle();

      expect(find.text('Fridge Map'), findsOneWidget);
    });

    testWidgets('navigates to favorites via bottom nav', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fridgeListProvider.overrideWith((ref) async => FridgeFixtures.allFridges),
          ],
          child: const FridgeFinderApp(),
        ),
      );
      await tester.pumpAndSettle();

      final favoritesIcon = find.byIcon(Icons.favorite).last;
      await tester.tap(favoritesIcon);
      await tester.pumpAndSettle();

      expect(find.text('Favorites Screen - Coming Soon'), findsOneWidget);
    });

    testWidgets('navigates to profile via bottom nav', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fridgeListProvider.overrideWith((ref) async => FridgeFixtures.allFridges),
          ],
          child: const FridgeFinderApp(),
        ),
      );
      await tester.pumpAndSettle();

      final profileIcon = find.byIcon(Icons.person).last;
      await tester.tap(profileIcon);
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsWidgets);
      expect(find.text('Theme Settings'), findsOneWidget);
    });

    testWidgets('displays correct bottom nav index for each route', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fridgeListProvider.overrideWith((ref) async => FridgeFixtures.allFridges),
          ],
          child: const FridgeFinderApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Map screen (index 0)
      expect(find.text('Fridge Map'), findsOneWidget);

      // Navigate to list (index 1)
      await tester.tap(find.byIcon(Icons.list).last);
      await tester.pumpAndSettle();

      final navBar = find.byType(BottomNavigationBar);
      final bottomNav = navBar.evaluate().last.widget as BottomNavigationBar;
      expect(bottomNav.currentIndex, 1);

      // Navigate to favorites (index 2)
      await tester.tap(find.byIcon(Icons.favorite).last);
      await tester.pumpAndSettle();

      final navBar2 = find.byType(BottomNavigationBar);
      final bottomNav2 = navBar2.evaluate().last.widget as BottomNavigationBar;
      expect(bottomNav2.currentIndex, 2);

      // Navigate to profile (index 3)
      await tester.tap(find.byIcon(Icons.person).last);
      await tester.pumpAndSettle();

      final navBar3 = find.byType(BottomNavigationBar);
      final bottomNav3 = navBar3.evaluate().last.widget as BottomNavigationBar;
      expect(bottomNav3.currentIndex, 3);
    });

    testWidgets('app loads data and displays map', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fridgeListProvider.overrideWith((ref) async => FridgeFixtures.allFridges),
          ],
          child: const FridgeFinderApp(),
        ),
      );
      await tester.pumpAndSettle();

      // App should have loaded and display the map screen
      expect(find.text('Fridge Map'), findsOneWidget);
    });

    testWidgets('shows fridges after loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fridgeListProvider.overrideWith((ref) async => FridgeFixtures.allFridges),
          ],
          child: const FridgeFinderApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Should have loaded fridges - verify by checking for the map which displays the fridges
      expect(find.byType(FlutterMap), findsOneWidget);
    });

    testWidgets('all navigation items are accessible', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fridgeListProvider.overrideWith((ref) async => FridgeFixtures.allFridges),
          ],
          child: const FridgeFinderApp(),
        ),
      );
      await tester.pumpAndSettle();

      final navBar = find.byType(BottomNavigationBar);
      final bottomNav = navBar.evaluate().last.widget as BottomNavigationBar;

      expect(bottomNav.items.length, 4);
      expect(bottomNav.items[0].label, 'Map');
      expect(bottomNav.items[1].label, 'List');
      expect(bottomNav.items[2].label, 'Favorites');
      expect(bottomNav.items[3].label, 'Profile');
    });
  });
}

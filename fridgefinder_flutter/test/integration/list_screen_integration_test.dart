import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  group('List Screen Integration Tests', () {
    testWidgets('list screen displays all fridges', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fridgeListProvider.overrideWith((ref) async => FridgeFixtures.allFridges),
          ],
          child: const FridgeFinderApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to list screen - tap list icon in bottom nav bar
      await tester.tap(find.byIcon(Icons.list).last);
      await tester.pumpAndSettle();

      // Should display all 4 fridges
      expect(find.text('Living Gallery'), findsOneWidget);
      expect(find.text('Collective Focus Resource Hub'), findsOneWidget);
      expect(find.text('Community Care Center'), findsOneWidget);
    });

    testWidgets('search filters fridges by name', (WidgetTester tester) async {
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
      await tester.tap(find.byIcon(Icons.list).last);
      await tester.pumpAndSettle();

      // Find search field
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Type search query
      await tester.enterText(searchField, 'Living');
      await tester.pumpAndSettle();

      // Should only show Living Gallery
      expect(find.text('Living Gallery'), findsOneWidget);
      expect(find.text('Collective Focus Resource Hub'), findsNothing);
    });

    testWidgets('search is case insensitive', (WidgetTester tester) async {
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
      await tester.tap(find.byIcon(Icons.list).last);
      await tester.pumpAndSettle();

      // Search with uppercase
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'LIVING');
      await tester.pumpAndSettle();

      // Should still find Living Gallery
      expect(find.text('Living Gallery'), findsOneWidget);
    });

    testWidgets('search filters fridges by city', (WidgetTester tester) async {
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
      await tester.tap(find.byIcon(Icons.list).last);
      await tester.pumpAndSettle();

      // Search by city
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'New York');
      await tester.pumpAndSettle();

      // Should find multiple fridges in New York
      expect(find.text('Living Gallery'), findsOneWidget);
      expect(find.text('Collective Focus Resource Hub'), findsOneWidget);
    });

    testWidgets('clear search shows all fridges again', (WidgetTester tester) async {
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
      await tester.tap(find.byIcon(Icons.list).last);
      await tester.pumpAndSettle();

      // Search for something
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Living');
      await tester.pumpAndSettle();

      // Clear the search
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();

      // Should show all fridges again
      expect(find.text('Living Gallery'), findsOneWidget);
      expect(find.text('Collective Focus Resource Hub'), findsOneWidget);
      expect(find.text('Community Care Center'), findsOneWidget);
    });

    testWidgets('shows empty state for no results', (WidgetTester tester) async {
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
      await tester.tap(find.byIcon(Icons.list).last);
      await tester.pumpAndSettle();

      // Search for non-existent fridge
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'NonExistent');
      await tester.pumpAndSettle();

      // Should show empty state message
      expect(find.text('No results'), findsOneWidget);
    });

    testWidgets('fridge cards display status and food level', (WidgetTester tester) async {
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
      await tester.tap(find.byIcon(Icons.list).last);
      await tester.pumpAndSettle();

      // Should display status and food level information (appears for each fridge)
      expect(find.text('Status'), findsWidgets);
      expect(find.text('Food Level'), findsWidgets);
    });

    testWidgets('tapping fridge card shows details', (WidgetTester tester) async {
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
      await tester.tap(find.byIcon(Icons.list).last);
      await tester.pumpAndSettle();

      // Tap on a fridge card
      final card = find.byType(Card).first;
      await tester.tap(card);
      await tester.pumpAndSettle();

      // Should show bottom sheet with details
      expect(find.text('Location'), findsOneWidget);
    });

    testWidgets('list displays fridge addresses', (WidgetTester tester) async {
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
      await tester.tap(find.byIcon(Icons.list).last);
      await tester.pumpAndSettle();

      // Should display addresses
      expect(find.text('New York, NY'), findsWidgets);
    });

    testWidgets('search field has proper hint text', (WidgetTester tester) async {
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
      await tester.tap(find.byIcon(Icons.list).last);
      await tester.pumpAndSettle();

      // Check for search hint
      expect(find.text('Search by name or location...'), findsOneWidget);
    });

    testWidgets('list screen loads and displays fridges', (WidgetTester tester) async {
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
      await tester.tap(find.byIcon(Icons.list).last);
      await tester.pumpAndSettle();

      // Should show list with fridges
      expect(find.text('Fridge List'), findsOneWidget);
      expect(find.byType(Card), findsWidgets);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgefinder_app/app.dart';
import 'package:fridgefinder_app/src/features/list/presentation/list_screen.dart';
import 'package:fridgefinder_app/src/features/map/presentation/controllers/fridge_list_controller.dart';
import 'package:fridgefinder_app/src/features/map/presentation/controllers/map_filter_controller.dart';
import '../fixtures/fridge_fixtures.dart';
import '../helpers/test_helpers.dart';
import '../test_helpers.dart';

/// Helper to create widget with ListScreen and proper overrides
Widget createListScreenWidget() {
  // Create fridgesWithDistance for override
  final fridgesWithDistance = FridgeFixtures.allFridges
      .map((fridge) => FridgeWithDistance(fridge: fridge, distanceKm: null))
      .toList();

  return ProviderScope(
    overrides: [
      ...getBaseTestOverrides(),
      fridgeListProvider.overrideWith(
        (ref) => Future.value(FridgeFixtures.allFridges),
      ),
      fridgesSortedByDistanceProvider.overrideWithValue(fridgesWithDistance),
    ],
    child: MaterialApp(home: Scaffold(body: ListScreen())),
  );
}

/// Helper to wait for async providers to complete
Future<void> waitForProviders(WidgetTester tester) async {
  // Wait for providers to resolve - pump a few frames
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 100));
}

/// Helper to wait for list screen to load cards
Future<void> waitForListToLoad(WidgetTester tester) async {
  // Wait for loading indicator to disappear
  int attempts = 0;
  while (find.text('Loading fridges...').evaluate().isNotEmpty &&
      attempts < 20) {
    await tester.pump(const Duration(milliseconds: 50));
    attempts++;
  }

  // Wait for cards to render
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  setUpAll(() async {
    await initHiveForTesting();
  });

  tearDownAll(() async {
    await cleanupHive();
  });

  group('List Screen Integration Tests', () {
    testWidgets('list screen displays all fridges', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createListScreenWidget());

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      await waitForListToLoad(tester);

      // Should display fridge names from fixtures
      expect(find.byType(Card), findsWidgets);
      expect(find.text('Living Gallery'), findsWidgets);
      expect(find.text('B\'ShERT NYC Fridge'), findsWidgets);
      expect(find.text('Test Dirty Fridge'), findsWidgets);
    });

    testWidgets('search filters fridges by name', (WidgetTester tester) async {
      await tester.pumpWidget(createListScreenWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      await waitForListToLoad(tester);

      // Find search field
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Type search query
      await tester.enterText(searchField, 'Living');
      await tester.pumpAndSettle();

      // Should only show Living Gallery
      expect(find.text('Living Gallery'), findsWidgets);
      expect(find.text('B\'ShERT NYC Fridge'), findsNothing);
    });

    testWidgets('search is case insensitive', (WidgetTester tester) async {
      await tester.pumpWidget(createListScreenWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      await waitForListToLoad(tester);

      // Search with uppercase
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'LIVING');
      await tester.pumpAndSettle();

      // Should still find Living Gallery
      expect(find.text('Living Gallery'), findsWidgets);
    });

    testWidgets('search filters fridges by city', (WidgetTester tester) async {
      await tester.pumpWidget(createListScreenWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      await waitForListToLoad(tester);

      // Search by city
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'New York');
      await tester.pumpAndSettle();

      // Should find fridges in New York
      expect(find.text('Living Gallery'), findsWidgets);
      expect(find.text('Broken Fridge'), findsWidgets);
    });

    testWidgets('clear search shows all fridges again', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createListScreenWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      await waitForListToLoad(tester);

      // Search for something
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Living');
      await tester.pumpAndSettle();

      // Clear the search
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();

      // Should show all fridges again
      expect(find.text('Living Gallery'), findsWidgets);
      expect(find.text('B\'ShERT NYC Fridge'), findsWidgets);
      expect(find.text('Test Dirty Fridge'), findsWidgets);
    });

    testWidgets('shows empty state for no results', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createListScreenWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      await waitForListToLoad(tester);

      // Search for non-existent fridge
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'NonExistent');
      await tester.pumpAndSettle();

      // Should show empty state message
      expect(find.text('No results'), findsOneWidget);
    });

    testWidgets('fridge cards display status and food level', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createListScreenWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      await waitForListToLoad(tester);

      // Should display status and food level information (appears for each fridge)
      expect(find.text('Status'), findsWidgets);
      expect(find.text('Food Level'), findsWidgets);
    });

    testWidgets('tapping fridge card shows details', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createListScreenWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      await waitForListToLoad(tester);

      // Tap on a fridge card
      final cards = find.byType(Card);
      expect(cards, findsWidgets);
      await tester.tap(cards.first);
      await tester.pumpAndSettle();

      // Should show bottom sheet with details
      expect(find.text('Location'), findsOneWidget);
    });

    testWidgets('list displays fridge addresses', (WidgetTester tester) async {
      await tester.pumpWidget(createListScreenWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      await waitForListToLoad(tester);

      // Should display addresses
      expect(find.text('New York, NY'), findsWidgets);
    });

    testWidgets('search field has proper hint text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createListScreenWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      await waitForListToLoad(tester);

      // Check for search hint
      expect(find.text('Search by name or location...'), findsOneWidget);
    });

    testWidgets('list screen loads and displays fridges', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createListScreenWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      await waitForListToLoad(tester);

      // Should show list with fridges - check for fridge names or cards
      expect(find.text('Living Gallery'), findsWidgets);
      expect(find.text('B\'ShERT NYC Fridge'), findsWidgets);
    });
  });
}

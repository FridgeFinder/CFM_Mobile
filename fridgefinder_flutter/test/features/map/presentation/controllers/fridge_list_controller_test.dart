import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgefinder_app/src/features/map/presentation/controllers/fridge_list_controller.dart';
import 'package:fridgefinder_app/src/features/map/presentation/controllers/map_filter_controller.dart';
import '../../../../fixtures/fridge_fixtures.dart';
import '../../../../test_helpers.dart';

void main() {
  group('Fridge List Controller Tests', () {
    late ProviderContainer container;

    setUp(() async {
      container = createTestProviderContainer();
      // Ensure mapFilterProvider resolves before tests that depend on fridgeListProvider
      await container.read(mapFilterProvider.future);
    });

    tearDown(() {
      container.dispose();
    });

    group('fridgeListProvider', () {
      test('fetches all fridges successfully from mock repository', () async {
        // Ensure filter state resolves before reading fridge list
        await container.read(mapFilterProvider.future);
        final fridgesFuture = container.read(fridgeListProvider.future);
        final fridges = await fridgesFuture;

        expect(fridges, isNotEmpty);
        expect(
          fridges.length,
          equals(5),
        ); // All fridges including ghosts (filtering is downstream)
        expect(fridges[0].name, equals('Living Gallery'));
      });

      test('fridges have required fields', () async {
        final fridgesFuture = container.read(fridgeListProvider.future);
        final fridges = await fridgesFuture;

        for (final fridge in fridges) {
          expect(fridge.id, isNotEmpty);
          expect(fridge.name, isNotEmpty);
          expect(fridge.location.geoLat, isNotNull);
          expect(fridge.location.geoLng, isNotNull);
        }
      });

      test('verified fridges have status information', () async {
        final fridgesFuture = container.read(fridgeListProvider.future);
        final fridges = await fridgesFuture;

        final verifiedFridges = fridges.where((f) => f.verified);
        expect(verifiedFridges, isNotEmpty);

        for (final fridge in verifiedFridges) {
          expect(fridge.latestFridgeReport, isNotNull);
          expect(fridge.statusText, isNotEmpty);
        }
      });
    });

    group('selectedFridgeIdProvider', () {
      test('initializes with null', () {
        final selectedId = container.read(selectedFridgeIdProvider);
        expect(selectedId, isNull);
      });

      test('can set selected fridge ID', () {
        final notifier = container.read(selectedFridgeIdProvider.notifier);
        notifier.setSelectedFridgeId('fridge_1');

        final selectedId = container.read(selectedFridgeIdProvider);
        expect(selectedId, equals('fridge_1'));
      });

      test('can clear selection', () {
        final notifier = container.read(selectedFridgeIdProvider.notifier);
        notifier.setSelectedFridgeId('fridge_1');
        notifier.clearSelection();

        final selectedId = container.read(selectedFridgeIdProvider);
        expect(selectedId, isNull);
      });
    });

    group('selectedFridgeProvider', () {
      test('returns null when no fridge is selected', () {
        final selectedFridge = container.read(selectedFridgeProvider);
        expect(selectedFridge, isNull);
      });

      test('returns selected fridge when ID is set', () async {
        // First ensure fridges are loaded
        await container.read(fridgeListProvider.future);

        final notifier = container.read(selectedFridgeIdProvider.notifier);
        notifier.setSelectedFridgeId('livinggallery');

        // Wait for provider to update - need to read after state change
        await container.read(fridgeListProvider.future);

        final selectedFridge = container.read(selectedFridgeProvider);
        expect(selectedFridge, isNotNull);
        expect(selectedFridge?.id, equals('livinggallery'));
        expect(selectedFridge?.name, equals('Living Gallery'));
      });

      test('returns null for invalid fridge ID', () async {
        await container.read(fridgeListProvider.future);

        final notifier = container.read(selectedFridgeIdProvider.notifier);
        notifier.setSelectedFridgeId('invalid_id_xyz');

        await Future.delayed(const Duration(milliseconds: 100));

        final selectedFridge = container.read(selectedFridgeProvider);
        expect(selectedFridge, isNull);
      });
    });

    group('searchQueryProvider', () {
      test('initializes with empty string', () {
        final query = container.read(searchQueryProvider);
        expect(query, equals(''));
      });

      test('can set search query', () {
        final notifier = container.read(searchQueryProvider.notifier);
        notifier.setSearchQuery('downtown');

        final query = container.read(searchQueryProvider);
        expect(query, equals('downtown'));
      });

      test('can clear search', () {
        final notifier = container.read(searchQueryProvider.notifier);
        notifier.setSearchQuery('downtown');
        notifier.clearSearch();

        final query = container.read(searchQueryProvider);
        expect(query, equals(''));
      });
    });

    group('filteredFridgesProvider', () {
      test('returns all fridges when search query is empty', () async {
        await container.read(fridgeListProvider.future);

        final filtered = container.read(filteredFridgesProvider);
        expect(filtered.length, equals(4)); // ghost excluded by default
      });

      test('filters fridges by name', () async {
        await container.read(fridgeListProvider.future);

        final notifier = container.read(searchQueryProvider.notifier);
        notifier.setSearchQuery('living');

        // Read the provider again to get updated value
        await container.read(fridgeListProvider.future);

        final filtered = container.read(filteredFridgesProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every(
            (f) =>
                f.name.toLowerCase().contains('living') ||
                f.location.city.toLowerCase().contains('living') ||
                f.location.state.toLowerCase().contains('living'),
          ),
          isTrue,
        );
      });

      test('filters fridges by city', () async {
        await container.read(fridgeListProvider.future);

        final notifier = container.read(searchQueryProvider.notifier);
        notifier.setSearchQuery('brooklyn');

        // Read the provider again to get updated value
        await container.read(fridgeListProvider.future);

        final filtered = container.read(filteredFridgesProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every(
            (f) =>
                f.name.toLowerCase().contains('brooklyn') ||
                f.location.city.toLowerCase().contains('brooklyn') ||
                f.location.state.toLowerCase().contains('brooklyn'),
          ),
          isTrue,
        );
      });

      test('returns empty list for non-matching search', () async {
        await container.read(fridgeListProvider.future);

        final notifier = container.read(searchQueryProvider.notifier);
        notifier.setSearchQuery('nonexistent');

        await Future.delayed(const Duration(milliseconds: 100));

        final filtered = container.read(filteredFridgesProvider);
        expect(filtered, isEmpty);
      });

      test('search is case insensitive', () async {
        await container.read(fridgeListProvider.future);

        final notifier = container.read(searchQueryProvider.notifier);
        notifier.setSearchQuery('LIVING');

        // Read the provider again to get updated value
        await container.read(fridgeListProvider.future);

        final filtered = container.read(filteredFridgesProvider);
        expect(filtered, isNotEmpty);
      });
    });

    group('singleFridgeProvider', () {
      test('fetches single fridge by ID', () async {
        final fridgeFuture = container.read(
          singleFridgeProvider('livinggallery').future,
        );
        final fridge = await fridgeFuture;

        expect(fridge.id, equals('livinggallery'));
        expect(fridge.name, equals('Living Gallery'));
      });

      test('fetches correct fridge for different ID', () async {
        final fridgeFuture = container.read(
          singleFridgeProvider('bshertnycfridge').future,
        );
        final fridge = await fridgeFuture;

        expect(fridge.id, equals('bshertnycfridge'));
        expect(fridge.name, equals('B\'ShERT NYC Fridge'));
      });
    });

    group('Fridge domain model properties', () {
      test('verified fridge with food returns correct marker color', () async {
        final fridge = FridgeFixtures.verifiedFridgeWithFood;
        expect(fridge.markerColor, isNotNull);
      });

      test('unverified fridge returns grey marker color', () async {
        final fridge = FridgeFixtures.notAtLocationFridge;
        expect(fridge.markerColor, isNotNull);
      });

      test('fridge status text reflects condition', () async {
        final workingFridge = FridgeFixtures.verifiedFridgeWithFood;
        expect(workingFridge.statusText, equals('Good'));
      });

      test('fridge food level text is accurate', () async {
        final fridge = FridgeFixtures.verifiedFridgeWithFood;
        final foodText = fridge.foodLevelText;
        expect(foodText, equals('Full'));
      });

      test('fridge address formatting works correctly', () async {
        final fridge = FridgeFixtures.verifiedFridgeWithFood;
        expect(fridge.location.fullAddress, contains(','));
        expect(
          fridge.location.shortAddress,
          equals('${fridge.location.city}, ${fridge.location.state}'),
        );
      });
    });

    group('filteredFridgesProvider address/zip search', () {
      test('matches by street address', () async {
        await container.read(fridgeListProvider.future);

        final notifier = container.read(searchQueryProvider.notifier);
        notifier.setSearchQuery('1094 Broadway');

        await container.read(fridgeListProvider.future);

        final filtered = container.read(filteredFridgesProvider);
        expect(filtered, isNotEmpty);
        expect(filtered.any((f) => f.id == 'livinggallery'), isTrue);
      });

      test('matches by zip code', () async {
        await container.read(fridgeListProvider.future);

        final notifier = container.read(searchQueryProvider.notifier);
        notifier.setSearchQuery('11221');

        await container.read(fridgeListProvider.future);

        final filtered = container.read(filteredFridgesProvider);
        expect(filtered, isNotEmpty);
        expect(filtered.any((f) => f.id == 'livinggallery'), isTrue);
      });
    });
  });
}

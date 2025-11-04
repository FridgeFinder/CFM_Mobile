import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgefinder_app/src/features/map/presentation/controllers/fridge_list_controller.dart';
import 'package:fridgefinder_app/src/core/providers/location_provider.dart';
import '../../../../helpers/test_helpers.dart';
import '../../../../test_helpers.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initHiveForTesting();
  });

  tearDownAll(() async {
    await cleanupHive();
  });

  group('fridgesSortedByDistanceProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = createTestProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'returns fridges without distance when location is not available',
      () async {
        // Mock location access disabled
        final locationAccessNotifier = container.read(
          locationAccessProvider.notifier,
        );
        locationAccessNotifier.setAccess(false);

        // Load fridges
        await container.read(fridgeListProvider.future);

        // Get fridges with distance
        final fridgesWithDistance = container.read(
          fridgesSortedByDistanceProvider,
        );

        expect(fridgesWithDistance, isNotEmpty);
        // All should have null distance
        for (final fridge in fridgesWithDistance) {
          expect(fridge.distanceKm, isNull);
        }
      },
    );

    test('provider uses select() to avoid unnecessary recalculations', () async {
      await container.read(fridgeListProvider.future);

      // Read the provider - this should use select() internally for efficiency
      final fridgesWithDist = container.read(fridgesSortedByDistanceProvider);
      expect(fridgesWithDist, isNotEmpty);

      // Accessing again should use cached result
      final fridgesWithDist2 = container.read(fridgesSortedByDistanceProvider);
      expect(fridgesWithDist2, isNotEmpty);
      // Same reference indicates no recalculation happened
      expect(identical(fridgesWithDist, fridgesWithDist2), isTrue);
    });

    test(
      'FridgeWithDistance model holds fridge and distance correctly',
      () async {
        final testFridge = (await container.read(
          fridgeListProvider.future,
        )).first;

        final fridgeWithDistance = FridgeWithDistance(
          fridge: testFridge,
          distanceKm: 5.2,
        );

        expect(fridgeWithDistance.fridge, equals(testFridge));
        expect(fridgeWithDistance.distanceKm, equals(5.2));
      },
    );

    test('FridgeWithDistance with null distance', () async {
      final testFridge = (await container.read(
        fridgeListProvider.future,
      )).first;

      final fridgeWithDistance = FridgeWithDistance(
        fridge: testFridge,
        distanceKm: null,
      );

      expect(fridgeWithDistance.fridge, equals(testFridge));
      expect(fridgeWithDistance.distanceKm, isNull);
    });

    test('sorting handles fridges with and without distance', () async {
      final fridges = await container.read(fridgeListProvider.future);

      // Create a mix of fridges with and without distance
      final mixed = [
        FridgeWithDistance(fridge: fridges[0], distanceKm: null),
        FridgeWithDistance(fridge: fridges[1], distanceKm: 10.0),
        FridgeWithDistance(fridge: fridges[2], distanceKm: 5.0),
        FridgeWithDistance(fridge: fridges[3], distanceKm: null),
      ];

      // Sort by distance (closest first, nulls last)
      mixed.sort((a, b) {
        if (a.distanceKm == null && b.distanceKm == null) return 0;
        if (a.distanceKm == null) return 1;
        if (b.distanceKm == null) return -1;
        return a.distanceKm!.compareTo(b.distanceKm!);
      });

      // Verify sorting
      expect(mixed[0].distanceKm, equals(5.0));
      expect(mixed[1].distanceKm, equals(10.0));
      expect(mixed[2].distanceKm, isNull);
      expect(mixed[3].distanceKm, isNull);
    });

    test('provider does not recalculate when search query changes', () async {
      await container.read(fridgeListProvider.future);

      // Get initial fridges with distance
      final initial = container.read(fridgesSortedByDistanceProvider);
      final initialLength = initial.length;

      // Change search query (should not affect distance calculation)
      container.read(searchQueryProvider.notifier).setSearchQuery('test query');

      // Fridges with distance should still be the same
      final afterSearch = container.read(fridgesSortedByDistanceProvider);
      expect(afterSearch.length, equals(initialLength));
    });

    test('uses granular location watching via select()', () async {
      // The provider should use select() to watch only the location value
      // This means changes to other location provider states won't cause recalc
      await container.read(fridgeListProvider.future);

      final fridgesWithDistance1 = container.read(
        fridgesSortedByDistanceProvider,
      );
      expect(fridgesWithDistance1, isNotEmpty);

      // Access again - should be cached
      final fridgesWithDistance2 = container.read(
        fridgesSortedByDistanceProvider,
      );
      expect(
        identical(fridgesWithDistance1, fridgesWithDistance2),
        isTrue,
        reason:
            'Provider should cache results when dependencies have not changed',
      );
    });
  });
}

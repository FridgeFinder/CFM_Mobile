import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/features/map/presentation/controllers/filter_condition.dart';
import 'package:fridgefinder_app/src/features/map/domain/models/fridge_domain.dart';
import '../../../../fixtures/fridge_fixtures.dart';

void main() {
  group('FilterCondition Tests', () {
    group('Label Display', () {
      test('goodWithFood has correct label', () {
        expect(FilterCondition.goodWithFood.label, equals('Good (w/ Food)'));
      });

      test('goodEmpty has correct label', () {
        expect(FilterCondition.goodEmpty.label, equals('Good (Empty)'));
      });

      test('dirty has correct label', () {
        expect(FilterCondition.dirty.label, equals('Dirty'));
      });

      test('outOfOrder has correct label', () {
        expect(FilterCondition.outOfOrder.label, equals('Out of Order'));
      });

      test('ghost has correct label', () {
        expect(FilterCondition.ghost.label, equals('Ghost'));
      });

      test('notAtLocation has correct label', () {
        expect(FilterCondition.notAtLocation.label, equals('Not at Location'));
      });
    });

    group('Matching Good Condition', () {
      test('goodWithFood matches fridge with good condition and food > 0', () {
        final fridge = FridgeFixtures.verifiedFridgeWithFood;
        expect(
          FilterCondition.goodWithFood.matches(fridge),
          isTrue,
        );
      });

      test('goodEmpty matches fridge with good condition and food == 0', () {
        final fridge = FridgeDomain(
          id: 'test',
          name: 'Test Fridge',
          verified: true,
          location: FridgeLocationDomain(
            street: '123 Main',
            city: 'Test City',
            state: 'TS',
            zip: '12345',
            geoLat: 0.0,
            geoLng: 0.0,
          ),
          latestFridgeReport: FridgeReportDomain(
            fridgeId: 'test',
            condition: FridgeCondition.good,
            foodPercentage: 0.0,
            notes: 'Empty',
            epochTimestamp: '1234567890',
            timestamp: '2025-01-01T00:00:00Z',
          ),
        );

        expect(FilterCondition.goodEmpty.matches(fridge), isTrue);
      });

      test('goodWithFood does not match empty good fridge', () {
        final fridge = FridgeDomain(
          id: 'test',
          name: 'Test Fridge',
          verified: true,
          location: FridgeLocationDomain(
            street: '123 Main',
            city: 'Test City',
            state: 'TS',
            zip: '12345',
            geoLat: 0.0,
            geoLng: 0.0,
          ),
          latestFridgeReport: FridgeReportDomain(
            fridgeId: 'test',
            condition: FridgeCondition.good,
            foodPercentage: 0.0,
            notes: 'Empty',
            epochTimestamp: '1234567890',
            timestamp: '2025-01-01T00:00:00Z',
          ),
        );

        expect(FilterCondition.goodWithFood.matches(fridge), isFalse);
      });

      test('goodEmpty does not match good fridge with food', () {
        expect(
          FilterCondition.goodEmpty.matches(FridgeFixtures.verifiedFridgeWithFood),
          isFalse,
        );
      });
    });

    group('Matching Dirty Condition', () {
      test('dirty matches fridge with dirty condition', () {
        expect(
          FilterCondition.dirty.matches(FridgeFixtures.fridgeDirty),
          isTrue,
        );
      });

      test('dirty does not match good condition', () {
        expect(
          FilterCondition.dirty.matches(FridgeFixtures.verifiedFridgeWithFood),
          isFalse,
        );
      });
    });

    group('Matching Out of Order Condition', () {
      test('outOfOrder matches fridge with out of order condition', () {
        expect(
          FilterCondition.outOfOrder.matches(FridgeFixtures.fridgeOutOfOrder),
          isTrue,
        );
      });

      test('outOfOrder does not match good condition', () {
        expect(
          FilterCondition.outOfOrder.matches(FridgeFixtures.verifiedFridgeWithFood),
          isFalse,
        );
      });
    });

    group('Matching Ghost Condition', () {
      test('ghost matches fridge with ghost condition', () {
        expect(
          FilterCondition.ghost.matches(FridgeFixtures.ghostFridge),
          isTrue,
        );
      });

      test('ghost does not match good condition', () {
        expect(
          FilterCondition.ghost.matches(FridgeFixtures.verifiedFridgeWithFood),
          isFalse,
        );
      });
    });

    group('Matching Not at Location Condition', () {
      test('notAtLocation matches fridge with not at location condition', () {
        expect(
          FilterCondition.notAtLocation.matches(FridgeFixtures.notAtLocationFridge),
          isTrue,
        );
      });

      test('notAtLocation does not match good condition', () {
        expect(
          FilterCondition.notAtLocation.matches(FridgeFixtures.verifiedFridgeWithFood),
          isFalse,
        );
      });
    });

    group('Fridge Without Report', () {
      test('fridge without report matches goodWithFood (default)', () {
        final fridge = FridgeDomain(
          id: 'test',
          name: 'Test Fridge',
          verified: true,
          location: FridgeLocationDomain(
            street: '123 Main',
            city: 'Test City',
            state: 'TS',
            zip: '12345',
            geoLat: 0.0,
            geoLng: 0.0,
          ),
          latestFridgeReport: null,
        );

        expect(FilterCondition.goodWithFood.matches(fridge), isTrue);
        expect(FilterCondition.goodEmpty.matches(fridge), isFalse);
        expect(FilterCondition.dirty.matches(fridge), isFalse);
        expect(FilterCondition.outOfOrder.matches(fridge), isFalse);
        expect(FilterCondition.ghost.matches(fridge), isFalse);
        expect(FilterCondition.notAtLocation.matches(fridge), isFalse);
      });
    });

    group('Food Level Boundaries', () {
      test('goodWithFood matches at boundary food level > 0', () {
        final fridge = FridgeDomain(
          id: 'test',
          name: 'Test',
          verified: true,
          location: FridgeLocationDomain(
            street: '123 Main',
            city: 'Test',
            state: 'TS',
            zip: '12345',
            geoLat: 0.0,
            geoLng: 0.0,
          ),
          latestFridgeReport: FridgeReportDomain(
            fridgeId: 'test',
            condition: FridgeCondition.good,
            foodPercentage: 0.01,
            notes: 'Very small amount',
            epochTimestamp: '1234567890',
            timestamp: '2025-01-01T00:00:00Z',
          ),
        );

        expect(FilterCondition.goodWithFood.matches(fridge), isTrue);
      });

      test('goodEmpty matches at boundary food level == 0', () {
        final fridge = FridgeDomain(
          id: 'test',
          name: 'Test',
          verified: true,
          location: FridgeLocationDomain(
            street: '123 Main',
            city: 'Test',
            state: 'TS',
            zip: '12345',
            geoLat: 0.0,
            geoLng: 0.0,
          ),
          latestFridgeReport: FridgeReportDomain(
            fridgeId: 'test',
            condition: FridgeCondition.good,
            foodPercentage: 0.0,
            notes: 'Empty',
            epochTimestamp: '1234567890',
            timestamp: '2025-01-01T00:00:00Z',
          ),
        );

        expect(FilterCondition.goodEmpty.matches(fridge), isTrue);
      });
    });

    group('Enum Values', () {
      test('all conditions are defined', () {
        expect(FilterCondition.values.length, equals(6));
      });

      test('all conditions have unique values', () {
        final values = FilterCondition.values.map((c) => c.value).toSet();
        expect(values.length, equals(6));
      });
    });
  });
}

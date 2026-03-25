import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/features/map/presentation/controllers/filter_condition.dart';
import '../../../../fixtures/fridge_fixtures.dart';

void main() {
  group('FilterCondition Tests', () {
    group('Label Display', () {
      test('full has correct label', () {
        expect(FilterCondition.full.label, equals('Full'));
      });

      test('manyItems has correct label', () {
        expect(FilterCondition.manyItems.label, equals('Many Items'));
      });

      test('fewItems has correct label', () {
        expect(FilterCondition.fewItems.label, equals('Few Items'));
      });

      test('empty has correct label', () {
        expect(FilterCondition.empty.label, equals('Empty'));
      });

      test('needsCleaning has correct label', () {
        expect(FilterCondition.needsCleaning.label, equals('Needs Cleaning'));
      });

      test('needsServicing has correct label', () {
        expect(FilterCondition.needsServicing.label, equals('Needs Repairs'));
      });

      test('notAtLocation has correct label', () {
        expect(FilterCondition.notAtLocation.label, equals('Not at Location'));
      });
    });

    group('Matching Full Condition (>= 75%)', () {
      test('full matches fridge with good condition and food >= 75%', () {
        expect(
          FilterCondition.full.matches(FridgeFixtures.verifiedFridgeWithFood),
          isTrue,
        );
      });

      test('full does not match fridge with food < 75%', () {
        final fridge = FridgeFixtures.verifiedFridgeWithFood.copyWith(
          latestFridgeReport: FridgeFixtures.verifiedFridgeWithFood
              .latestFridgeReport!
              .copyWith(foodPercentage: 0.7),
        );
        expect(FilterCondition.full.matches(fridge), isFalse);
      });
    });

    group('Matching Many Items Condition (50-74%)', () {
      test('manyItems matches fridge with 50-74% food', () {
        final fridge = FridgeFixtures.verifiedFridgeWithFood.copyWith(
          latestFridgeReport: FridgeFixtures.verifiedFridgeWithFood
              .latestFridgeReport!
              .copyWith(foodPercentage: 0.6),
        );
        expect(FilterCondition.manyItems.matches(fridge), isTrue);
      });

      test('manyItems does not match fridge with food < 50%', () {
        final fridge = FridgeFixtures.verifiedFridgeWithFood.copyWith(
          latestFridgeReport: FridgeFixtures.verifiedFridgeWithFood
              .latestFridgeReport!
              .copyWith(foodPercentage: 0.4),
        );
        expect(FilterCondition.manyItems.matches(fridge), isFalse);
      });
    });

    group('Matching Few Items Condition (1-49%)', () {
      test('fewItems matches fridge with 1-49% food', () {
        final fridge = FridgeFixtures.verifiedFridgeWithFood.copyWith(
          latestFridgeReport: FridgeFixtures.verifiedFridgeWithFood
              .latestFridgeReport!
              .copyWith(foodPercentage: 0.3),
        );
        expect(FilterCondition.fewItems.matches(fridge), isTrue);
      });

      test('fewItems does not match empty fridge', () {
        final fridge = FridgeFixtures.verifiedFridgeWithFood.copyWith(
          latestFridgeReport: FridgeFixtures.verifiedFridgeWithFood
              .latestFridgeReport!
              .copyWith(foodPercentage: 0.0),
        );
        expect(FilterCondition.fewItems.matches(fridge), isFalse);
      });
    });

    group('Matching Empty Condition (0%)', () {
      test('empty matches fridge with food == 0', () {
        final fridge = FridgeFixtures.verifiedFridgeWithFood.copyWith(
          latestFridgeReport: FridgeFixtures.verifiedFridgeWithFood
              .latestFridgeReport!
              .copyWith(foodPercentage: 0.0),
        );
        expect(FilterCondition.empty.matches(fridge), isTrue);
      });

      test('empty does not match fridge with any food', () {
        expect(
          FilterCondition.empty.matches(FridgeFixtures.verifiedFridgeWithFood),
          isFalse,
        );
      });
    });

    group('Matching Needs Cleaning Condition', () {
      test('needsCleaning matches fridge with dirty condition', () {
        expect(
          FilterCondition.needsCleaning.matches(FridgeFixtures.fridgeDirty),
          isTrue,
        );
      });

      test('needsCleaning does not match good condition', () {
        expect(
          FilterCondition.needsCleaning
              .matches(FridgeFixtures.verifiedFridgeWithFood),
          isFalse,
        );
      });
    });

    group('Matching Needs Servicing Condition', () {
      test('needsServicing matches fridge with out of order condition', () {
        expect(
          FilterCondition.needsServicing
              .matches(FridgeFixtures.fridgeOutOfOrder),
          isTrue,
        );
      });

      test('needsServicing does not match good condition', () {
        expect(
          FilterCondition.needsServicing
              .matches(FridgeFixtures.verifiedFridgeWithFood),
          isFalse,
        );
      });
    });

    group('Matching Not at Location Condition', () {
      test('notAtLocation matches fridge with not at location condition', () {
        expect(
          FilterCondition.notAtLocation
              .matches(FridgeFixtures.notAtLocationFridge),
          isTrue,
        );
      });

      test('notAtLocation does not match good condition', () {
        expect(
          FilterCondition.notAtLocation
              .matches(FridgeFixtures.verifiedFridgeWithFood),
          isFalse,
        );
      });
    });

    group('Food Level Boundaries', () {
      test('handles food level at exactly 0 (empty)', () {
        final fridge = FridgeFixtures.verifiedFridgeWithFood.copyWith(
          latestFridgeReport: FridgeFixtures.verifiedFridgeWithFood
              .latestFridgeReport!
              .copyWith(foodPercentage: 0.0),
        );
        expect(FilterCondition.empty.matches(fridge), isTrue);
        expect(FilterCondition.fewItems.matches(fridge), isFalse);
      });

      test('handles food level at 50% boundary (many items)', () {
        final fridge = FridgeFixtures.verifiedFridgeWithFood.copyWith(
          latestFridgeReport: FridgeFixtures.verifiedFridgeWithFood
              .latestFridgeReport!
              .copyWith(foodPercentage: 0.5),
        );
        expect(FilterCondition.manyItems.matches(fridge), isTrue);
        expect(FilterCondition.fewItems.matches(fridge), isFalse);
        expect(FilterCondition.full.matches(fridge), isFalse);
      });

      test('handles food level at 75% boundary (full)', () {
        final fridge = FridgeFixtures.verifiedFridgeWithFood.copyWith(
          latestFridgeReport: FridgeFixtures.verifiedFridgeWithFood
              .latestFridgeReport!
              .copyWith(foodPercentage: 0.75),
        );
        expect(FilterCondition.full.matches(fridge), isTrue);
        expect(FilterCondition.manyItems.matches(fridge), isFalse);
      });
    });

    group('Enum Values', () {
      test('all conditions are defined', () {
        expect(FilterCondition.values.length, equals(7));
      });

      test('all conditions have unique values', () {
        final values = FilterCondition.values.map((c) => c.value).toSet();
        expect(values.length, equals(7));
      });
    });
  });
}

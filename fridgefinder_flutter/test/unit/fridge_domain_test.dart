import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/features/map/domain/models/fridge_domain.dart';
import '../fixtures/fridge_fixtures.dart';

void main() {
  group('FridgeDomain statusText', () {
    test('dirty condition returns "Needs Cleaning"', () {
      final fridge = FridgeFixtures.fridgeDirty;
      expect(fridge.statusText, 'Needs Cleaning');
    });

    test('good condition returns "Good"', () {
      final fridge = FridgeFixtures.verifiedFridgeWithFood;
      expect(fridge.statusText, 'Good');
    });

    test('outOfOrder condition returns "Needs Repairs"', () {
      final fridge = FridgeFixtures.fridgeOutOfOrder;
      expect(fridge.statusText, 'Needs Repairs');
    });

    test('notAtLocation condition returns "Not at Location"', () {
      final fridge = FridgeFixtures.notAtLocationFridge;
      expect(fridge.statusText, 'Not at Location');
    });

    test('ghost condition returns "Ghost Fridge"', () {
      final fridge = FridgeFixtures.ghostFridge;
      expect(fridge.statusText, 'Ghost Fridge');
    });

    test('no report returns "No recent updates"', () {
      const fridge = FridgeDomain(
        id: 'test',
        name: 'Test Fridge',
        location: FridgeLocationDomain(),
      );
      expect(fridge.statusText, 'No recent updates');
    });
  });

  group('FridgeDomain foodLevelText', () {
    test('full food returns "Full"', () {
      final fridge = FridgeFixtures.verifiedFridgeWithFood;
      expect(fridge.foodLevelText, 'Full');
    });

    test('empty food returns "Empty"', () {
      final fridge = FridgeFixtures.fridgeOutOfOrder;
      expect(fridge.foodLevelText, 'Empty');
    });

    test('few items returns "Few Items"', () {
      final fridge = FridgeFixtures.fridgeDirty;
      expect(fridge.foodLevelText, 'Few Items');
    });
  });
}

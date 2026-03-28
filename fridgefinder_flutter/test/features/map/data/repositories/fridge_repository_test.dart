import 'package:flutter_test/flutter_test.dart';
import '../../../../test_helpers.dart';
import '../../../../fixtures/fridge_fixtures.dart';

void main() {
  group('MockFridgeRepository ghost filtering', () {
    late MockFridgeRepository repository;

    setUp(() {
      repository = MockFridgeRepository();
    });

    test('getFridges() excludes ghost fridges by default', () async {
      final fridges = await repository.getFridges();

      expect(fridges.any((f) => f.id == 'ghost_fridge_001'), isFalse);
      expect(fridges.length, equals(FridgeFixtures.allFridges.length - 1));
    });

    test('getFridges(includeGhosts: true) includes ghost fridges', () async {
      final fridges = await repository.getFridges(includeGhosts: true);

      expect(fridges.any((f) => f.id == 'ghost_fridge_001'), isTrue);
      expect(fridges.length, equals(FridgeFixtures.allFridges.length));
    });
  });
}

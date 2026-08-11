import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/features/map/presentation/controllers/filter_condition.dart';
import 'package:fridgefinder_app/src/features/map/presentation/controllers/map_filter_controller.dart';

void main() {
  group('MapFilterState Tests', () {
    group('Constructor', () {
      test('creates state with all required fields', () {
        final state = MapFilterState(
          selectedConditions: {FilterCondition.full},
          searchQuery: '',
        );

        expect(state.selectedConditions.length, equals(1));
        expect(state.selectedConditions, contains(FilterCondition.full));
        expect(state.searchQuery, equals(''));
      });

      test('default state has no conditions selected (shows everything)', () {
        const state = MapFilterState(
          selectedConditions: <FilterCondition>{},
          searchQuery: '',
        );

        expect(state.selectedConditions.isEmpty, isTrue);
        expect(state.searchQuery, equals(''));
        expect(state.isDefault, isTrue);
      });
    });

    group('copyWith', () {
      test('creates new state with updated conditions', () {
        const initial = MapFilterState(
          selectedConditions: <FilterCondition>{},
          searchQuery: '',
        );

        final updated = initial.copyWith(
          selectedConditions: {FilterCondition.full},
        );

        expect(updated.selectedConditions, contains(FilterCondition.full));
        expect(
          initial.selectedConditions.isEmpty,
          isTrue,
        ); // Original unchanged
      });

      test('creates new state with updated search query', () {
        const initial = MapFilterState(
          selectedConditions: <FilterCondition>{},
          searchQuery: '',
        );

        final updated = initial.copyWith(searchQuery: 'test');

        expect(updated.searchQuery, equals('test'));
        expect(initial.searchQuery, equals('')); // Original unchanged
      });
    });

    group('Filter State Properties', () {
      test('isDefault is true when no conditions selected and no search', () {
        const state = MapFilterState(
          selectedConditions: <FilterCondition>{},
          searchQuery: '',
        );

        expect(state.isDefault, isTrue);
      });

      test('isDefault is false when search query is set', () {
        const state = MapFilterState(
          selectedConditions: <FilterCondition>{},
          searchQuery: 'test',
        );

        expect(state.isDefault, isFalse);
      });

      test('isDefault is false when any conditions selected', () {
        const state = MapFilterState(
          selectedConditions: {FilterCondition.full},
          searchQuery: '',
        );

        expect(state.isDefault, isFalse);
      });

      test('deselectedConditions returns unselected conditions', () {
        final selectedConditions = {
          FilterCondition.full,
          FilterCondition.manyItems,
          FilterCondition.fewItems,
        };

        final state = MapFilterState(
          selectedConditions: selectedConditions,
          searchQuery: '',
        );

        expect(state.deselectedConditions.length, equals(4));
        expect(
          state.deselectedConditions,
          contains(FilterCondition.needsCleaning),
        );
        expect(
          state.deselectedConditions,
          contains(FilterCondition.notAtLocation),
        );
      });
    });

    group('Equality', () {
      test('states with same values are equal', () {
        const state1 = MapFilterState(
          selectedConditions: {FilterCondition.full},
          searchQuery: '',
        );

        const state2 = MapFilterState(
          selectedConditions: {FilterCondition.full},
          searchQuery: '',
        );

        expect(state1, equals(state2));
      });

      test('states with different values are not equal', () {
        const state1 = MapFilterState(
          selectedConditions: {FilterCondition.full},
          searchQuery: '',
        );

        const state2 = MapFilterState(
          selectedConditions: {FilterCondition.needsCleaning},
          searchQuery: '',
        );

        expect(state1, isNot(equals(state2)));
      });
    });
  });
}

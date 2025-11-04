import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/features/map/presentation/controllers/map_filter_controller.dart';
import 'package:fridgefinder_app/src/features/map/presentation/controllers/filter_condition.dart';

void main() {
  group('MapFilterState Tests', () {
    group('Initial State', () {
      test('creates default state with all conditions selected', () {
        final state = MapFilterState(
          selectedConditions: FilterCondition.values.toSet(),
          searchQuery: '',
        );

        expect(state.selectedConditions.length, equals(6));
        expect(
          state.selectedConditions,
          contains(FilterCondition.goodWithFood),
        );
        expect(state.selectedConditions, contains(FilterCondition.goodEmpty));
        expect(state.selectedConditions, contains(FilterCondition.dirty));
        expect(state.selectedConditions, contains(FilterCondition.outOfOrder));
        expect(state.selectedConditions, contains(FilterCondition.ghost));
        expect(
          state.selectedConditions,
          contains(FilterCondition.notAtLocation),
        );
        expect(state.searchQuery, equals(''));
        expect(state.isDefault, isTrue);
      });
    });

    group('copyWith', () {
      test('creates new state with updated conditions', () {
        final state = MapFilterState(
          selectedConditions: {FilterCondition.goodWithFood},
          searchQuery: 'test',
        );

        final newState = state.copyWith(
          selectedConditions: {FilterCondition.dirty},
        );

        expect(newState.selectedConditions, equals({FilterCondition.dirty}));
        expect(newState.searchQuery, equals('test')); // Unchanged
      });

      test('creates new state with updated search query', () {
        final state = MapFilterState(
          selectedConditions: {FilterCondition.goodWithFood},
          searchQuery: 'test',
        );

        final newState = state.copyWith(searchQuery: 'new query');

        expect(newState.searchQuery, equals('new query'));
        expect(
          newState.selectedConditions,
          equals({FilterCondition.goodWithFood}),
        ); // Unchanged
      });
    });

    group('Filter State Properties', () {
      test('isDefault is true when all conditions selected and no search', () {
        final state = MapFilterState(
          selectedConditions: FilterCondition.values.toSet(),
          searchQuery: '',
        );
        expect(state.isDefault, isTrue);
      });

      test('isDefault is false when search query is set', () {
        final state = MapFilterState(
          selectedConditions: FilterCondition.values.toSet(),
          searchQuery: 'test',
        );
        expect(state.isDefault, isFalse);
      });

      test('isDefault is false when not all conditions selected', () {
        final conditions = FilterCondition.values.toSet();
        conditions.remove(FilterCondition.dirty);

        final state = MapFilterState(
          selectedConditions: conditions,
          searchQuery: '',
        );
        expect(state.isDefault, isFalse);
      });

      test('deselectedConditions returns unselected conditions', () {
        final selectedConditions = {
          FilterCondition.goodWithFood,
          FilterCondition.goodEmpty,
          FilterCondition.outOfOrder,
        };

        final state = MapFilterState(
          selectedConditions: selectedConditions,
          searchQuery: '',
        );

        expect(state.deselectedConditions.length, equals(3));
        expect(state.deselectedConditions, contains(FilterCondition.dirty));
        expect(state.deselectedConditions, contains(FilterCondition.ghost));
        expect(
          state.deselectedConditions,
          contains(FilterCondition.notAtLocation),
        );
      });
    });

    group('Equality', () {
      test('states with same values are equal', () {
        final state1 = MapFilterState(
          selectedConditions: {FilterCondition.goodWithFood},
          searchQuery: 'test',
        );

        final state2 = MapFilterState(
          selectedConditions: {FilterCondition.goodWithFood},
          searchQuery: 'test',
        );

        expect(state1, equals(state2));
      });

      test('states with different values are not equal', () {
        final state1 = MapFilterState(
          selectedConditions: {FilterCondition.goodWithFood},
          searchQuery: 'test',
        );

        final state2 = MapFilterState(
          selectedConditions: {FilterCondition.dirty},
          searchQuery: 'test',
        );

        expect(state1, isNot(equals(state2)));
      });
    });
  });
}

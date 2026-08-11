import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgefinder_app/src/features/map/presentation/widgets/filter_status_indicator.dart';
import 'package:fridgefinder_app/src/features/map/presentation/controllers/map_filter_controller.dart';
import 'package:fridgefinder_app/src/features/map/presentation/controllers/filter_condition.dart';

class _MockMapFilter extends MapFilter {
  final MapFilterState _state;
  _MockMapFilter(this._state);

  @override
  Future<MapFilterState> build() async => _state;
}

void main() {
  group('FilterStatusIndicator', () {
    testWidgets('uses Semantics liveRegion for screen reader announcements', (
      WidgetTester tester,
    ) async {
      final activeFilterState = MapFilterState(
        selectedConditions: {FilterCondition.full},
        searchQuery: '',
        followingOnly: false,
        includeGhosts: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mapFilterProvider.overrideWith(
              () => _MockMapFilter(activeFilterState),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Stack(children: const [FilterStatusIndicator()]),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the Semantics widget with liveRegion
      final semanticsFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.liveRegion == true,
      );
      expect(semanticsFinder, findsOneWidget);

      // Verify the label contains 'Active filter'
      final semantics = tester.widget<Semantics>(semanticsFinder);
      expect(semantics.properties.label, contains('Active filter'));
    });

    testWidgets('hidden when filter state is default', (
      WidgetTester tester,
    ) async {
      const defaultFilterState = MapFilterState(
        selectedConditions: <FilterCondition>{},
        searchQuery: '',
        followingOnly: false,
        includeGhosts: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mapFilterProvider.overrideWith(
              () => _MockMapFilter(defaultFilterState),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Stack(children: const [FilterStatusIndicator()]),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should not find any Semantics with liveRegion since indicator is hidden
      final semanticsFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.liveRegion == true,
      );
      expect(semanticsFinder, findsNothing);
    });
  });
}

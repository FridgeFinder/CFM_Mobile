import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/filter_condition.dart';
import '../controllers/map_filter_controller.dart';
import 'filter_pill_button.dart';

/// Reusable horizontal scrollable row of filter pills
/// Used in both map view and list view
class FilterPillsRow extends ConsumerWidget {
  const FilterPillsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterStateAsync = ref.watch(mapFilterProvider);

    return filterStateAsync.when(
      data: (state) {
        return SizedBox(
          height: 48,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                ...FilterCondition.values.map(
                  (condition) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterPillButton(
                      condition: condition,
                      isSelected: state.selectedConditions.contains(condition),
                      onPressed: () {
                        ref
                            .read(mapFilterProvider.notifier)
                            .toggleCondition(condition);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

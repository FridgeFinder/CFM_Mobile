import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import '../controllers/map_filter_controller.dart';

/// Filter status indicator shown at bottom of map.
/// Displays info about active filters/search in a readable chip.
/// Only shows if filter state is not default.
class FilterStatusIndicator extends ConsumerWidget {
  const FilterStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterStateAsync = ref.watch(mapFilterProvider);

    return filterStateAsync.when(
      data: (filterState) {
        if (filterState.isDefault) {
          return const SizedBox.shrink();
        }

        final statusParts = <String>[];

        if (filterState.followingOnly) {
          statusParts.add('Following only');
        }

        if (filterState.includeGhosts) {
          statusParts.add('Including ghosts');
        }

        // Show what's actively selected rather than what's hidden
        if (filterState.selectedConditions.isNotEmpty &&
            filterState.deselectedConditions.isNotEmpty) {
          final selectedLabels = filterState.selectedConditions
              .map((c) => c.label)
              .join(', ');
          statusParts.add('Showing: $selectedLabels');
        }

        if (filterState.searchQuery.isNotEmpty) {
          statusParts.add('"${filterState.searchQuery}"');
        }

        if (statusParts.isEmpty) return const SizedBox.shrink();

        return Positioned(
          bottom: 16,
          left: 16,
          right: 80, // Leave space for FAB
          child: Semantics(
            liveRegion: true,
            label: 'Active filter: ${statusParts.join(', ')}',
            child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: M3ESpacing.sm,
              vertical: M3ESpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inverseSurface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusParts.join(' · '),
              style: M3ETypography.labelSmall.copyWith(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

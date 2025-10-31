import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/map_filter_controller.dart';

/// Filter status indicator shown at bottom of map
/// Displays info about active filters/search in a discreet way
/// Only shows if filter state is not default
class FilterStatusIndicator extends ConsumerWidget {
  const FilterStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterStateAsync = ref.watch(mapFilterProvider);

    return filterStateAsync.when(
      data: (filterState) {
        // Don't show if at default state
        if (filterState.isDefault) {
          return const SizedBox.shrink();
        }

        final statusParts = <String>[];

        // Add deselected conditions info
        if (filterState.deselectedConditions.isNotEmpty) {
          final deselectedLabels = filterState.deselectedConditions
              .map((c) => c.label.toLowerCase())
              .join(', ');
          statusParts.add('not showing: $deselectedLabels');
        }

        // Add search query info
        if (filterState.searchQuery.isNotEmpty) {
          statusParts.add('searching for: "${filterState.searchQuery}"');
        }

        return Positioned(
          bottom: 16,
          left: 16,
          right: 80, // Leave space for FAB
          child: Text(
            statusParts.join(' • '),
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              shadows: [
                Shadow(
                  offset: const Offset(1, 1),
                  blurRadius: 4,
                  color: Colors.black.withValues(alpha: 1.0),
                ),
                Shadow(
                  offset: const Offset(-1, -1),
                  blurRadius: 4,
                  color: Colors.black.withValues(alpha: 1.0),
                ),
                Shadow(
                  offset: const Offset(0, 0),
                  blurRadius: 6,
                  color: Colors.black.withValues(alpha: 0.9),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

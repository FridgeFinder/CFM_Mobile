import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import '../controllers/filter_condition.dart';
import '../controllers/map_filter_controller.dart';
import 'filter_pill_button.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/followed_fridges_provider.dart';

/// Reusable horizontal scrollable row of filter pills
/// Used in both map view and list view
class FilterPillsRow extends ConsumerWidget {
  const FilterPillsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterStateAsync = ref.watch(mapFilterProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final followedFridgesAsync = ref.watch(followedFridgesProvider);

    return filterStateAsync.when(
      data: (state) {
        // Check if the user follows any fridges
        final hasFollowedFridges = followedFridgesAsync.when(
          data: (subs) => subs.isNotEmpty,
          loading: () => false,
          error: (_, _) => false,
        );

        return Padding(
          padding: EdgeInsets.only(
            top: M3ESpacing.xs,
          ), // Added top padding for breathing room
          child: SizedBox(
            height: 48,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: M3ESpacing.sm),
              child: Row(
                children: [
                  // Following pill - FIRST position, only show if authenticated and following fridges
                  if (isAuthenticated && hasFollowedFridges)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: M3ESpacing.xxs),
                      child: _buildFollowingPill(
                        context: context,
                        isSelected: state.followingOnly,
                        onPressed: () {
                          ref
                              .read(mapFilterProvider.notifier)
                              .toggleFollowingOnly();
                        },
                      ),
                    ),
                  // Other filter pills
                  ...FilterCondition.values.map(
                    (condition) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: M3ESpacing.xxs),
                      child: FilterPillButton(
                        condition: condition,
                        isSelected: state.selectedConditions.contains(
                          condition,
                        ),
                        onPressed: () {
                          ref
                              .read(mapFilterProvider.notifier)
                              .toggleCondition(condition);
                        },
                      ),
                    ),
                  ),
                  // Ghost Fridges pill - after condition pills
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: M3ESpacing.xxs),
                    child: FilterChipM3E(
                      label: 'Ghost Fridges',
                      selected: state.includeGhosts,
                      icon: Icons.visibility_off,
                      color: Colors.grey,
                      onSelected: (_) {
                        ref
                            .read(mapFilterProvider.notifier)
                            .toggleIncludeGhosts();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildFollowingPill({
    required BuildContext context,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    // Use the M3E FilterChipM3E component for consistency and vibrant styling
    // Green color matches followed markers and full status
    return FilterChipM3E(
      label: 'Following',
      selected: isSelected,
      icon: Icons.favorite,
      color: const Color(
        0xFFFFD700,
      ), // Shimmering gold - matches followed markers
      onSelected: (_) => onPressed(),
    );
  }
}

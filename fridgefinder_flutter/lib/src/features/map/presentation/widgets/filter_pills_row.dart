import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import '../controllers/filter_condition.dart';
import '../controllers/map_filter_controller.dart';
import 'filter_pill_button.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/subscriptions_provider.dart';
import '../../../../core/providers/theme_provider.dart';

/// Reusable horizontal scrollable row of filter pills
/// Used in both map view and list view
class FilterPillsRow extends ConsumerWidget {
  const FilterPillsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterStateAsync = ref.watch(mapFilterProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final subscriptionsAsync = ref.watch(subscribedFridgesProvider);
    final themeMode = ref.watch(appThemeModeProvider);

    // Determine if dark mode
    final isDarkMode =
        themeMode == AppThemeMode.dark ||
        (themeMode == AppThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return filterStateAsync.when(
      data: (state) {
        // Check if user has subscriptions
        final hasSubscriptions = subscriptionsAsync.when(
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
                  // Subscribed pill - FIRST position, only show if authenticated and has subscriptions
                  if (isAuthenticated && hasSubscriptions)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: M3ESpacing.xxs),
                      child: _buildSubscribedPill(
                        context: context,
                        isSelected: state.subscribedOnly,
                        isDarkMode: isDarkMode,
                        onPressed: () {
                          ref
                              .read(mapFilterProvider.notifier)
                              .toggleSubscribedOnly();
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

  Widget _buildSubscribedPill({
    required BuildContext context,
    required bool isSelected,
    required bool isDarkMode,
    required VoidCallback onPressed,
  }) {
    // Use the M3E FilterChipM3E component for consistency and vibrant styling
    // Green color matches subscribed markers and full status
    return FilterChipM3E(
      label: 'Subscribed',
      selected: isSelected,
      icon: Icons.favorite,
      color: const Color(
        0xFFFFD700,
      ), // Shimmering gold - matches subscribed markers
      onSelected: (_) => onPressed(),
    );
  }
}

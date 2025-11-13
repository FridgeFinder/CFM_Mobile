import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import '../controllers/filter_condition.dart';
import '../controllers/map_filter_controller.dart';
import 'filter_pill_button.dart';
import 'fridge_marker.dart';
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

        return SizedBox(
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
                        ref.read(mapFilterProvider.notifier).toggleSubscribedOnly();
                      },
                    ),
                  ),
                // Other filter pills
                ...FilterCondition.values.map(
                  (condition) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: M3ESpacing.xxs),
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
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildSubscribedPill({
    required BuildContext context,
    required bool isSelected,
    required bool isDarkMode,
    required VoidCallback onPressed,
  }) {
    final color = FridgeMarker.subscribedGreen;
    // Transparent green background with white text/icon
    final borderColor = isSelected ? color : Colors.grey.shade800;
    final backgroundColor = color.withValues(alpha: 0.85);

    final pillContent = Container(
      padding: EdgeInsets.symmetric(
        horizontal: M3ESpacing.lg,
        vertical: M3ESpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 2.0),
        borderRadius: BorderRadius.circular(M3EShapes.full),
        color: backgroundColor,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite,
                size: 18,
                color: Colors.white,
              ),
              M3ESpacing.horizontalXS,
              Text(
                'Subscribed',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          // Green checkmark when selected
          if (isSelected)
            Positioned(
              top: -10,
              right: -25,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
            ),
        ],
      ),
    );

    // Add green glow when selected
    if (isSelected) {
      return GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(M3EShapes.full),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: pillContent,
        ),
      );
    }

    return GestureDetector(
      onTap: onPressed,
      child: pillContent,
    );
  }
}

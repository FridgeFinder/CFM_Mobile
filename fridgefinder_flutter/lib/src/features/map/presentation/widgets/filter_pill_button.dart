import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import '../controllers/filter_condition.dart';

/// A pill-shaped filter button for fridge condition filtering using M3E FilterChipM3E
/// Shows condition icon and label, with a checkmark when selected
///
/// M3E Specifications (from FilterChipM3E):
/// - Semantic colors matching filter meanings (green for full, amber for many, etc.)
/// - Selection bounce animation (scale 1.0 → 1.05 → 1.0) with overshoot
/// - Elevated shadow on selected state (2dp with colored shadow)
/// - Hover lift with background color change
/// - Press feedback (scale 0.95)
/// - Smooth 350ms transitions with emphasized decelerate curve
///
/// Color Mapping:
/// - Full: Green (#5FD65F - tertiary) - matches full status markers
/// - Many Items: Amber (#FFB300 - warning) - matches many items yellow
/// - Few Items: Pink (#FF6B9D - secondary) - matches few items pink
/// - Empty: Gray/neutral - matches empty state
/// - Needs Cleaning: Orange/Coral (#FF7043 - alert) - matches dirty state
/// - Needs Servicing: Orange/Coral (#FF7043 - alert) - matches maintenance
/// - Not at Location: Gray/neutral - matches inactive state
class FilterPillButton extends ConsumerWidget {
  final FilterCondition condition;
  final bool isSelected;
  final VoidCallback onPressed;

  const FilterPillButton({
    super.key,
    required this.condition,
    required this.isSelected,
    required this.onPressed,
  });

  /// Get icon for filter condition
  IconData _getIcon() {
    switch (condition) {
      case FilterCondition.full:
        return Icons.shopping_basket;
      case FilterCondition.manyItems:
        return Icons.shopping_cart;
      case FilterCondition.fewItems:
        return Icons.shopping_bag_outlined;
      case FilterCondition.empty:
        return Icons.inbox_outlined;
      case FilterCondition.needsCleaning:
        return Icons.cleaning_services_outlined;
      case FilterCondition.needsServicing:
        return Icons.build_outlined;
      case FilterCondition.notAtLocation:
        return Icons.location_off_outlined;
    }
  }

  /// Get semantic color for filter condition
  /// Maps each filter to a color that matches its semantic meaning
  Color _getSemanticColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (condition) {
      case FilterCondition.full:
        // Green - matches full status and followed markers
        return const Color(0xFF5FD65F); // Tertiary color

      case FilterCondition.manyItems:
        // Amber - matches many items yellow markers
        return const Color(0xFFFFB300); // Warning color

      case FilterCondition.fewItems:
        // Pink - matches few items pink markers
        return const Color(0xFFFF6B9D); // Secondary color

      case FilterCondition.empty:
        // Gray/neutral - matches empty state
        return colorScheme.outline;

      case FilterCondition.needsCleaning:
      case FilterCondition.needsServicing:
        // Orange/Coral - matches dirty/maintenance states
        return const Color(0xFFFF7043); // Alert color

      case FilterCondition.notAtLocation:
        // Gray/neutral - matches inactive state
        return colorScheme.outline;
    }
  }

  /// Get display label for filter condition
  String _getLabel() {
    return condition.label;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilterChipM3E(
      label: _getLabel(),
      selected: isSelected,
      icon: _getIcon(),
      color: _getSemanticColor(context),
      onSelected: (_) => onPressed(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/filter_condition.dart';
import '../../../../core/utils/fridge_icon_utils.dart';
import '../../../../core/providers/theme_provider.dart';

/// A pill-shaped filter button for fridge condition filtering
/// Shows condition icon and label, with a checkmark when selected
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

  /// Get status color for filter condition, adjusted for dark mode
  Color _getColor(bool isDarkMode) {
    var color = FridgeIconUtils.getStatusColorForFilterCondition(condition);

    // In dark mode, invert the "Not at Location" color from black to light grey
    if (isDarkMode && condition == FilterCondition.notAtLocation) {
      color = Colors.grey[300]!;
    }

    return color;
  }

  /// Get display label for filter condition
  String _getLabel() {
    return condition.label;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeNotifierProvider);

    // Determine if dark mode
    final isDarkMode =
        themeMode == AppThemeMode.dark ||
        (themeMode == AppThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final color = _getColor(isDarkMode);
    final unselectedBorderColor = isDarkMode
        ? Colors.grey.shade600
        : Colors.grey.shade300;
    final borderColor = isSelected ? color : unselectedBorderColor;
    final backgroundColor = isSelected
        ? color.withValues(alpha: 0.15)
        : Colors.transparent;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 2.0),
          borderRadius: BorderRadius.circular(18),
          color: backgroundColor,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main content: SVG icon and label
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Use SVG icon that matches the fridge representation
                SizedBox(
                  width: 18,
                  height: 18,
                  child: FridgeIconUtils.getConditionPillIcon(condition),
                ),
                const SizedBox(width: 6),
                Text(
                  _getLabel(),
                  style: TextStyle(
                    color: color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            // Green checkmark when selected - overlays on top right corner
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
      ),
    );
  }
}

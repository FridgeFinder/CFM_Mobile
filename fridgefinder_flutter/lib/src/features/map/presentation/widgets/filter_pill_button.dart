import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import '../controllers/filter_condition.dart';
import '../../../../core/utils/fridge_icon_utils.dart';
import '../../../../core/providers/theme_provider.dart';

/// A pill-shaped filter button for fridge condition filtering
/// Shows condition icon and label, with a checkmark when selected
///
/// M3E Specifications:
/// - Full corner radius (pill shape)
/// - 8% hover, 12% pressed state layers
/// - 300ms spring animations for selection state
/// - M3E spacing tokens
class FilterPillButton extends ConsumerStatefulWidget {
  final FilterCondition condition;
  final bool isSelected;
  final VoidCallback onPressed;

  const FilterPillButton({
    super.key,
    required this.condition,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  ConsumerState<FilterPillButton> createState() => _FilterPillButtonState();
}

class _FilterPillButtonState extends ConsumerState<FilterPillButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: M3EMotion.medium2, // 300ms
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: M3EMotion.standard,
    );

    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(FilterPillButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Get status color for filter condition, adjusted for dark mode
  Color _getColor(bool isDarkMode) {
    var color = FridgeIconUtils.getStatusColorForFilterCondition(widget.condition);

    // In dark mode, invert the "Not at Location" color from black to light grey
    if (isDarkMode && widget.condition == FilterCondition.notAtLocation) {
      color = Colors.grey[300]!;
    }

    return color;
  }

  /// Get display label for filter condition
  String _getLabel() {
    return widget.condition.label;
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(appThemeModeProvider);

    // Determine if dark mode
    final isDarkMode =
        themeMode == AppThemeMode.dark ||
        (themeMode == AppThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final color = _getColor(isDarkMode);
    final unselectedBorderColor = isDarkMode
        ? Colors.grey.shade600
        : Colors.grey.shade300;
    final borderColor = widget.isSelected ? color : unselectedBorderColor;
    // Semi-transparent background for all pills to ensure legibility on map
    final baseBackground = Colors.black.withValues(alpha: 0.5);
    final backgroundColor = widget.isSelected
        ? color.withValues(alpha: 0.25)
        : baseBackground;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        final scale = _isPressed ? 0.95 : 1.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: M3ESpacing.lg,
              vertical: M3ESpacing.xxs + 2,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 2.0),
              borderRadius: BorderRadius.circular(M3EShapes.full),
              color: backgroundColor,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(M3EShapes.full),
                ),
                overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return M3EStateLayer.getPressColor(color);
                  }
                  if (states.contains(WidgetState.hovered)) {
                    return M3EStateLayer.getHoverColor(color);
                  }
                  return null;
                }),
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
                          child: FridgeIconUtils.getConditionPillIcon(widget.condition),
                        ),
                        M3ESpacing.horizontalXS,
                        Text(
                          _getLabel(),
                          style: TextStyle(
                            color: color,
                            fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    // Green checkmark when selected - overlays on top right corner
                    if (widget.isSelected)
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
            ),
          ),
        );
      },
    );
  }
}

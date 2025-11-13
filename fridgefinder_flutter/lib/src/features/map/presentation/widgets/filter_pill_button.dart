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
  late Animation<BorderRadius> _borderRadiusAnimation;
  late Animation<double> _paddingAnimation;
  late Animation<double> _borderWidthAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    // Increased duration for more noticeable animation (500ms instead of 300ms)
    _controller = AnimationController(
      duration: M3EMotion.long2, // 500ms - more noticeable
      vsync: this,
    );

    // Increased scale for more noticeable expansion (1.0 → 1.15)
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(
        parent: _controller,
        curve: M3EMotion.expressiveDefaultOvershoot,
      ),
    );

    _borderRadiusAnimation = ShapeMorph.createMorph(
      controller: _controller,
      startType: ShapeType.rounded,
      endType: ShapeType.pill,
      customRadius: 8.0,
    );

    // Animate padding changes for more noticeable morph
    _paddingAnimation =
        Tween<double>(
          begin: 0.0,
          end: 3.0, // More padding change
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: M3EMotion.expressiveDefaultOvershoot,
          ),
        );

    _borderWidthAnimation =
        Tween<double>(
          begin: 1.0,
          end: 2.0, // Thicker border when selected
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: M3EMotion.expressiveDefaultOvershoot,
          ),
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
    var color = FridgeIconUtils.getStatusColorForFilterCondition(
      widget.condition,
    );

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

    final colorScheme = Theme.of(context).colorScheme;
    final color = _getColor(isDarkMode);
    final unselectedBorderColor = colorScheme.outlineVariant;
    final borderColor = widget.isSelected ? color : unselectedBorderColor;

    // Improved legibility in light mode with better contrast
    // Use solid backgrounds in light mode, semi-transparent in dark mode
    final baseBackground = isDarkMode
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.85)
        : colorScheme.surface.withValues(
            alpha: 0.95,
          ); // More opaque in light mode

    final backgroundColor = widget.isSelected
        ? (isDarkMode
              ? colorScheme.primaryContainer.withValues(alpha: 0.7)
              : colorScheme.primaryContainer.withValues(
                  alpha: 0.9,
                )) // More opaque when selected in light mode
        : baseBackground;

    // Ensure text color has good contrast in light mode
    final textColor = isDarkMode
        ? color
        : (widget.isSelected
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurface); // Better contrast in light mode

    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _borderRadiusAnimation,
        _paddingAnimation,
        _borderWidthAnimation,
      ]),
      builder: (context, child) {
        final scale = _isPressed
            ? 0.95
            : (widget.isSelected ? _scaleAnimation.value : 1.0);

        return Transform.scale(
          scale: scale,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal:
                  M3ESpacing.lg +
                  (widget.isSelected ? _paddingAnimation.value : 0),
              vertical:
                  M3ESpacing.xxs +
                  2 +
                  (widget.isSelected ? _paddingAnimation.value / 2 : 0),
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: borderColor,
                width: widget.isSelected ? _borderWidthAnimation.value : 2.0,
              ),
              borderRadius: widget.isSelected
                  ? _borderRadiusAnimation.value
                  : BorderRadius.circular(8.0),
              color: backgroundColor,
              // Add subtle shadow in light mode for better legibility
              boxShadow: isDarkMode
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                    return M3EColors.getStateLayerColor(
                      baseColor: colorScheme.onSurface,
                      state: 'press',
                    );
                  }
                  if (states.contains(WidgetState.hovered)) {
                    return M3EColors.getStateLayerColor(
                      baseColor: colorScheme.onSurface,
                      state: 'hover',
                    );
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
                          child: FridgeIconUtils.getConditionPillIcon(
                            widget.condition,
                          ),
                        ),
                        M3ESpacing.horizontalXS,
                        Text(
                          _getLabel(),
                          style: TextStyle(
                            color: widget.isSelected ? textColor : color,
                            fontWeight: widget.isSelected
                                ? FontWeight.w700
                                : FontWeight.w600, // Bolder when selected
                            fontSize: widget.isSelected
                                ? 13
                                : 12, // Slightly larger when selected
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
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14,
                          ),
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

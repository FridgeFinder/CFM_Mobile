import 'package:flutter/material.dart';
import '../theme/motion.dart';
import '../theme/state_layers.dart';
import '../theme/spacing.dart';

/// M3E List Tile with enhanced interactions
///
/// Enhanced Features:
/// - Hover lift animation (0.5dp to 3dp elevation)
/// - Press feedback with 0.98x scale for tactile response
/// - Subtle surface tinting with primary color
/// - Leading icons at 40px with primary color accent
/// - Title uses titleMedium (16sp) semibold for better hierarchy
/// - Subtitle uses bodyMedium with onSurfaceVariant color
/// - Trailing icons at 24px with subtle color
/// - Secondary container background when selected
/// - Generous 12-16dp padding for touch targets
/// - 12dp border radius for cohesive M3E aesthetic
/// - Enhanced state layers with primary color on hover
/// - Swipe actions support for delete/edit operations
///
/// Perfect for fridge list items with status indicators, food levels, and distance.
class ListTileM3E extends StatefulWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final bool selected;
  final bool dense;
  final List<SwipeAction>? swipeActions;
  final Color? selectedColor;

  const ListTileM3E({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.selected = false,
    this.dense = false,
    this.swipeActions,
    this.selectedColor,
  });

  @override
  State<ListTileM3E> createState() => _ListTileM3EState();
}

class _ListTileM3EState extends State<ListTileM3E>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: M3EMotion.emphasizedAccelerate,
      ),
    );

    _hoverController = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3),
      vsync: this,
    );
    _elevationAnimation = Tween<double>(begin: 0.5, end: 3.0).animate(
      CurvedAnimation(
        parent: _hoverController,
        curve: M3EMotion.emphasizedDecelerate,
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final selectedColor =
        widget.selectedColor ?? colorScheme.secondaryContainer;

    Widget tile = AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _elevationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            color: widget.selected ? selectedColor : colorScheme.surfaceContainerLow,
            elevation: _elevationAnimation.value,
            shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
            surfaceTintColor: colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: widget.enabled ? widget.onTap : null,
              onLongPress: widget.enabled ? widget.onLongPress : null,
              onTapDown: widget.enabled
                  ? (_) {
                      _pressController.forward();
                    }
                  : null,
              onTapUp: widget.enabled
                  ? (_) {
                      _pressController.reverse();
                    }
                  : null,
              onTapCancel: widget.enabled
                  ? () {
                      _pressController.reverse();
                    }
                  : null,
              onHover: widget.enabled
                  ? (value) {
                      if (value) {
                        _hoverController.forward();
                      } else {
                        _hoverController.reverse();
                      }
                    }
                  : null,
              borderRadius: BorderRadius.circular(12),
              overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.pressed)) {
                  return M3EStateLayer.getPressColor(colorScheme.onSurface);
                }
                if (states.contains(WidgetState.hovered)) {
                  return M3EStateLayer.getHoverColor(colorScheme.primary);
                }
                if (states.contains(WidgetState.focused)) {
                  return M3EStateLayer.getFocusColor(colorScheme.onSurface);
                }
                return null;
              }),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: M3ESpacing.md,
                  vertical: widget.dense ? M3ESpacing.xs : M3ESpacing.sm,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.leading != null) ...[
                      // Enhanced leading widget with better size and color
                      IconTheme(
                        data: IconThemeData(
                          color: widget.selected
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.primary,
                          size: 40,
                        ),
                        child: widget.leading!,
                      ),
                      M3ESpacing.horizontalMD,
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.title != null)
                            DefaultTextStyle(
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.0,
                                height: 1.3,
                                color: widget.selected
                                    ? colorScheme.onSecondaryContainer
                                    : colorScheme.onSurface,
                              ) ?? const TextStyle(),
                              child: widget.title!,
                            ),
                          if (widget.subtitle != null) ...[
                            M3ESpacing.verticalXXS,
                            DefaultTextStyle(
                              style: textTheme.bodyMedium?.copyWith(
                                color: widget.selected
                                    ? colorScheme.onSecondaryContainer.withValues(alpha: 0.8)
                                    : colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ) ?? const TextStyle(),
                              child: widget.subtitle!,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (widget.trailing != null) ...[
                      M3ESpacing.horizontalMD,
                      // Enhanced trailing widget with better color
                      IconTheme(
                        data: IconThemeData(
                          color: widget.selected
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                        child: widget.trailing!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    // Wrap with swipe actions if provided
    if (widget.swipeActions != null && widget.swipeActions!.isNotEmpty) {
      return Dismissible(
        key: Key('list_tile_${widget.hashCode}'),
        background: Container(
          color: colorScheme.errorContainer,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: M3ESpacing.md),
          child: Icon(Icons.delete, color: colorScheme.onErrorContainer),
        ),
        secondaryBackground: Container(
          color: colorScheme.primaryContainer,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: M3ESpacing.md),
          child: Icon(Icons.edit, color: colorScheme.onPrimaryContainer),
        ),
        onDismissed: (direction) {
          if (direction == DismissDirection.startToEnd) {
            widget.swipeActions!
                .firstWhere(
                  (action) => action.direction == SwipeDirection.left,
                  orElse: () => widget.swipeActions!.first,
                )
                .onAction();
          } else {
            widget.swipeActions!
                .firstWhere(
                  (action) => action.direction == SwipeDirection.right,
                  orElse: () => widget.swipeActions!.first,
                )
                .onAction();
          }
        },
        child: tile,
      );
    }

    return tile;
  }
}

/// Swipe action configuration
class SwipeAction {
  final SwipeDirection direction;
  final VoidCallback onAction;
  final Widget icon;
  final Color? backgroundColor;

  const SwipeAction({
    required this.direction,
    required this.onAction,
    required this.icon,
    this.backgroundColor,
  });
}

/// Swipe direction
enum SwipeDirection { left, right }

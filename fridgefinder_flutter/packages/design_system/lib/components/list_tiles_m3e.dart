import 'package:flutter/material.dart';
import '../theme/motion.dart';
import '../theme/state_layers.dart';
import '../theme/spacing.dart';

/// M3E List Tile with enhanced interactions
///
/// Features:
/// - Hover lift animation
/// - Press feedback with scale
/// - Swipe actions support
/// - Selection animations
/// - State layers for all interactive states
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
    _elevationAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
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
    final selectedColor =
        widget.selectedColor ?? colorScheme.secondaryContainer;

    Widget tile = AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _elevationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            color: widget.selected ? selectedColor : Colors.transparent,
            elevation: _elevationAnimation.value,
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
                  return M3EStateLayer.getHoverColor(colorScheme.onSurface);
                }
                if (states.contains(WidgetState.focused)) {
                  return M3EStateLayer.getFocusColor(colorScheme.onSurface);
                }
                return null;
              }),
              child: ListTile(
                leading: widget.leading,
                title: widget.title,
                subtitle: widget.subtitle,
                trailing: widget.trailing,
                enabled: widget.enabled,
                selected: widget.selected,
                dense: widget.dense,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: M3ESpacing.md,
                  vertical: M3ESpacing.xs,
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

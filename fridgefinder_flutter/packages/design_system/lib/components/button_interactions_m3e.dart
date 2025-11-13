import 'package:flutter/material.dart';
import '../theme/motion.dart';
import '../theme/state_layers.dart' as state_layers;
import '../theme/elevation.dart';

/// Enhanced button wrapper with M3E micro-interactions
///
/// Adds:
/// - Press scale (0.98)
/// - Hover elevation (+1dp)
/// - Focus outline (2dp)
/// - Ripple effects
/// - Icon scale animation
class InteractiveButtonM3E extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool showHover;
  final bool showPress;
  final bool showFocus;

  const InteractiveButtonM3E({
    super.key,
    required this.child,
    this.onPressed,
    this.showHover = true,
    this.showPress = true,
    this.showFocus = true,
  });

  @override
  State<InteractiveButtonM3E> createState() => _InteractiveButtonM3EState();
}

class _InteractiveButtonM3EState extends State<InteractiveButtonM3E>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3), // 350ms for more expressive response
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98, // Press scale
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: M3EMotion.emphasizedDecelerate,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) {
        if (widget.showHover) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        if (widget.showHover) {
          setState(() => _isHovered = false);
        }
      },
      child: GestureDetector(
        onTapDown: (_) {
          if (widget.showPress && widget.onPressed != null) {
            setState(() => _isPressed = true);
            _controller.forward();
          }
        },
        onTapUp: (_) {
          if (widget.showPress) {
            setState(() => _isPressed = false);
            _controller.reverse();
            widget.onPressed?.call();
          }
        },
        onTapCancel: () {
          if (widget.showPress) {
            setState(() => _isPressed = false);
            _controller.reverse();
          }
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isPressed ? _scaleAnimation.value : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _isHovered && widget.showHover
                      ? M3EElevation.getShadow(M3EElevation.level1)
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onPressed,
                    borderRadius: BorderRadius.circular(20),
                    overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(WidgetState.pressed) && widget.showPress) {
                        return state_layers.M3EStateLayer.getPressColor(colorScheme.onSurface);
                      }
                      if (states.contains(WidgetState.hovered) && widget.showHover) {
                        return state_layers.M3EStateLayer.getHoverColor(colorScheme.onSurface);
                      }
                      if (states.contains(WidgetState.focused) && widget.showFocus) {
                        return state_layers.M3EStateLayer.getFocusColor(colorScheme.onSurface);
                      }
                      return null;
                    }),
                    child: widget.child,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Enhanced icon button with scale animation
class InteractiveIconButtonM3E extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double iconSize;
  final Color? iconColor;
  final Color? backgroundColor;

  const InteractiveIconButtonM3E({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.iconSize = 24.0,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  State<InteractiveIconButtonM3E> createState() => _InteractiveIconButtonM3EState();
}

class _InteractiveIconButtonM3EState extends State<InteractiveIconButtonM3E>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3), // 350ms for more expressive bounce
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1, // Icon scales on hover
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: M3EMotion.emphasizedDecelerate,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          final iconButton = Transform.scale(
            scale: _isHovered ? _scaleAnimation.value : 1.0,
            child: Material(
              color: widget.backgroundColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: BorderRadius.circular(20),
                overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return state_layers.M3EStateLayer.getPressColor(colorScheme.onSurface);
                  }
                  if (states.contains(WidgetState.hovered)) {
                    return state_layers.M3EStateLayer.getHoverColor(colorScheme.onSurface);
                  }
                  return null;
                }),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    widget.icon,
                    size: widget.iconSize,
                    color: widget.iconColor ?? colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          );

          if (widget.tooltip != null) {
            return Tooltip(
              message: widget.tooltip!,
              child: iconButton,
            );
          }
          return iconButton;
        },
      ),
    );
  }
}


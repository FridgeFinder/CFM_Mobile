import 'package:flutter/material.dart';
import '../theme/motion.dart';

/// M3E Filter Chip with vibrant selection states and expressive animations
///
/// Features:
/// - Vibrant primary color for selected state with enhanced visual distinction
/// - Selection bounce animation (scale 1.0 → 1.05 → 1.0) with overshoot
/// - Elevated shadow on selected state (2dp with colored shadow)
/// - Hover lift with background color change (elevation +1dp)
/// - Press feedback (scale 0.95)
/// - Custom-built design with AnimatedContainer for full control
/// - Enhanced borders with vibrant primary accent when selected
/// - Better padding and touch targets (18px horizontal, 10px vertical)
/// - Smooth 300ms transitions with emphasized decelerate curve
/// - Check circle icon when selected (replaces standard checkmark)
/// - Larger icons (20px) with proper spacing (6px)
/// - Custom semantic colors for filter meaning (green for full/subscribed, amber for many, etc.)
class FilterChipM3E extends StatefulWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;
  final Color? color;

  const FilterChipM3E({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
    this.icon,
    this.color,
  });

  @override
  State<FilterChipM3E> createState() => _FilterChipM3EState();
}

class _FilterChipM3EState extends State<FilterChipM3E>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3), // 350ms for more expressive bounce
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05, // Bounce scale
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: M3EMotion.expressiveDefaultOvershoot,
    ));

    if (widget.selected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(FilterChipM3E oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      if (widget.selected) {
        _controller.reset();
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;

    // Use custom color if provided, otherwise default to primary
    final baseColor = widget.color ?? colorScheme.primary;

    // Generate appropriate container color based on the base color
    // For light mode: lighter tint (blend with white) with slight transparency
    // For dark mode: darker tint (blend with dark surface) with slight transparency
    final containerColor = brightness == Brightness.light
        ? Color.lerp(baseColor, Colors.white, 0.85)!.withValues(alpha: 0.85)
        : Color.lerp(baseColor, colorScheme.surface, 0.7)!.withValues(alpha: 0.85);

    // Generate appropriate text color for contrast
    // Use darker shade in light mode, lighter shade in dark mode
    final onContainerColor = brightness == Brightness.light
        ? Color.lerp(baseColor, Colors.black, 0.4)!
        : Color.lerp(baseColor, Colors.white, 0.6)!;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onSelected?.call(!widget.selected);
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            final scale = _isPressed ? 0.95 : (widget.selected ? _scaleAnimation.value : 1.0);
            return Transform.scale(
              scale: scale,
              child: Material(
                elevation: widget.selected ? 2.0 : (_isHovered ? 1.0 : 0.0),
                borderRadius: BorderRadius.circular(12),
                shadowColor: widget.selected
                    ? baseColor.withValues(alpha: 0.3)
                    : Colors.transparent,
                color: Colors.transparent,
                child: AnimatedContainer(
                  duration: M3EMotion.getDuration(M3EMotion.medium2),
                  curve: M3EMotion.emphasizedDecelerate,
                  decoration: BoxDecoration(
                    color: widget.selected
                        ? containerColor
                        : (_isHovered
                            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.85)
                            : colorScheme.surfaceContainerLow.withValues(alpha: 0.85)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.selected
                          ? baseColor.withValues(alpha: 0.5)
                          : colorScheme.outline.withValues(alpha: 0.3),
                      width: widget.selected ? 1.5 : 1.0,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.icon != null ? 14 : 18,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon == null && widget.selected) ...[
                        Icon(
                          Icons.check_circle,
                          size: 18,
                          color: baseColor,
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: 20,
                          color: widget.selected
                              ? baseColor
                              : baseColor.withValues(alpha: 0.6), // Dimmed semantic color when unselected
                        ),
                        const SizedBox(width: 6),
                      ],
                      AnimatedDefaultTextStyle(
                        duration: M3EMotion.getDuration(M3EMotion.medium2),
                        curve: M3EMotion.emphasizedDecelerate,
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: widget.selected
                              ? onContainerColor
                              : colorScheme.onSurface,
                          fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                        child: Text(widget.label),
                      ),
                    ],
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

/// M3E Input Chip with vibrant hover states and smooth delete animation
///
/// Features:
/// - Vibrant secondary color hover state for visual feedback
/// - Custom avatar display in circular primaryContainer
/// - Smooth delete animation with scale-down and fade-out
/// - Hover lift with elevation and color change (2dp on hover)
/// - Custom delete button with error color on hover
/// - Enhanced borders with secondary accent on hover
/// - Better padding and touch targets
/// - Smooth 300ms transitions with emphasized decelerate curve
/// - Larger icons (18-20px) with proper spacing
class InputChipM3E extends StatefulWidget {
  final String label;
  final VoidCallback? onDeleted;
  final VoidCallback? onPressed;
  final IconData? avatar;

  const InputChipM3E({
    super.key,
    required this.label,
    this.onDeleted,
    this.onPressed,
    this.avatar,
  });

  @override
  State<InputChipM3E> createState() => _InputChipM3EState();
}

class _InputChipM3EState extends State<InputChipM3E>
    with TickerProviderStateMixin {
  late AnimationController _deleteController;
  late Animation<double> _deleteAnimation;
  bool _isHovered = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _deleteController = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3), // 350ms for smoother fade
      vsync: this,
    );

    _deleteAnimation = CurvedAnimation(
      parent: _deleteController,
      curve: M3EMotion.emphasizedDecelerate,
    );
  }

  @override
  void dispose() {
    _deleteController.dispose();
    super.dispose();
  }

  void _handleDelete() {
    setState(() => _isDeleting = true);
    _deleteController.forward().then((_) {
      widget.onDeleted?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _deleteAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isDeleting ? (1.0 - _deleteAnimation.value * 0.2) : 1.0,
            child: Opacity(
              opacity: _isDeleting ? 1.0 - _deleteAnimation.value : 1.0,
              child: Material(
                elevation: _isHovered ? 2.0 : 0.0,
                borderRadius: BorderRadius.circular(12),
                shadowColor: colorScheme.primary.withValues(alpha: 0.15),
                color: Colors.transparent,
                child: AnimatedContainer(
                  duration: M3EMotion.getDuration(M3EMotion.medium2),
                  curve: M3EMotion.emphasizedDecelerate,
                  decoration: BoxDecoration(
                    color: _isHovered
                        ? colorScheme.secondaryContainer
                        : colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isHovered
                          ? colorScheme.secondary.withValues(alpha: 0.4)
                          : colorScheme.outline.withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                  padding: EdgeInsets.only(
                    left: widget.avatar != null ? 6 : 16,
                    right: 8,
                    top: 8,
                    bottom: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.avatar != null) ...[
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.avatar,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      AnimatedDefaultTextStyle(
                        duration: M3EMotion.getDuration(M3EMotion.medium2),
                        curve: M3EMotion.emphasizedDecelerate,
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: _isHovered
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                        child: Text(widget.label),
                      ),
                      if (widget.onDeleted != null) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _handleDelete,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _isHovered
                                    ? colorScheme.error.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: _isHovered
                                    ? colorScheme.error
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// M3E Assist Chip with vibrant tertiary hover states and expressive press feedback
///
/// Features:
/// - Vibrant tertiary (green) color on hover for positive, action-oriented feel
/// - Primary color on press for clear interaction feedback
/// - Smooth press animation with scale-down (0.95)
/// - Hover lift with elevation and color change (2dp on hover)
/// - Enhanced borders with tertiary accent on hover
/// - Better padding and touch targets (16px horizontal, 10px vertical)
/// - Smooth 300ms transitions with emphasized decelerate curve
/// - Larger icons (20px) with proper spacing (8px)
/// - Dynamic text weight (w600 when pressed, w500 otherwise)
class AssistChipM3E extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const AssistChipM3E({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  State<AssistChipM3E> createState() => _AssistChipM3EState();
}

class _AssistChipM3EState extends State<AssistChipM3E>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3), // 350ms for more expressive bounce
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95, // Press scale
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
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _controller.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _controller.reverse();
          widget.onPressed?.call();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isPressed ? _scaleAnimation.value : 1.0,
              child: Material(
                elevation: _isHovered ? 2.0 : 0.0,
                borderRadius: BorderRadius.circular(12),
                shadowColor: colorScheme.primary.withValues(alpha: 0.2),
                color: Colors.transparent,
                child: AnimatedContainer(
                  duration: M3EMotion.getDuration(M3EMotion.medium2),
                  curve: M3EMotion.emphasizedDecelerate,
                  decoration: BoxDecoration(
                    color: _isPressed
                        ? colorScheme.primaryContainer
                        : (_isHovered
                            ? colorScheme.tertiaryContainer
                            : colorScheme.surfaceContainerLow),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isHovered
                          ? colorScheme.tertiary.withValues(alpha: 0.4)
                          : colorScheme.outline.withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: 20,
                          color: _isPressed
                              ? colorScheme.primary
                              : (_isHovered
                                  ? colorScheme.tertiary
                                  : colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(width: 8),
                      ],
                      AnimatedDefaultTextStyle(
                        duration: M3EMotion.getDuration(M3EMotion.medium2),
                        curve: M3EMotion.emphasizedDecelerate,
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: _isPressed
                              ? colorScheme.onPrimaryContainer
                              : (_isHovered
                                  ? colorScheme.onTertiaryContainer
                                  : colorScheme.onSurface),
                          fontWeight: _isPressed ? FontWeight.w600 : FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                        child: Text(widget.label),
                      ),
                    ],
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

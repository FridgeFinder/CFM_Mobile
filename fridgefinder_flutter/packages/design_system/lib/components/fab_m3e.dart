import 'package:flutter/material.dart';
import '../theme/elevation.dart';
import '../theme/motion.dart';
import '../theme/shapes.dart';
import '../theme/spacing.dart';
import 'dart:math' as math;

/// Material 3 Expressive Floating Action Button
///
/// Implements M3E FAB variants with expressive spring animations and state transitions.
///
/// ## M3E Enhancement: Five Size Variants
///
/// - **Extra Small FAB**: 32x32dp, 18dp icon, Level 3 elevation
/// - **Small FAB**: 40x40dp, 20dp icon, Level 3 elevation
/// - **Regular FAB**: 56x56dp, 24dp icon, Level 3 elevation (default)
/// - **Large FAB**: 72x72dp, 30dp icon, Level 3 elevation
/// - **Extra Large FAB**: 96x96dp, 36dp icon, Level 3 elevation
/// - **Extended FAB**: 56dp height, pill shape, icon + label
///
/// ## Animations:
///
/// - **Enter**: Scale 0 → 1.0 with expressive spring (300ms)
/// - **Exit**: Scale 1.0 → 0 with emphasized accelerate (250ms)
/// - **Hover**: Level 3 → 4 elevation (250ms)
/// - **Press**: Scale 0.95 with spring (150ms)
/// - **Expand**: Width animation with gentle spring (350ms)
///
/// ## Example:
///
/// ```dart
/// FABM3E(
///   onPressed: () {},
///   icon: Icons.add,
/// )
/// ```
class FABM3E extends StatefulWidget {
  /// Callback when FAB is pressed
  final VoidCallback? onPressed;

  /// Icon to display
  final IconData icon;

  /// Label text for extended FAB
  final String? label;

  /// Size variant
  final FABSize size;

  /// Background color (defaults to theme primary)
  final Color? backgroundColor;

  /// Foreground color (defaults to theme onPrimary)
  final Color? foregroundColor;

  /// Custom elevation (defaults to level3)
  final double? elevation;

  /// Custom hover elevation (defaults to level4)
  final double? hoverElevation;

  /// Tooltip message
  final String? tooltip;

  /// Hero tag for hero animations
  final Object? heroTag;

  /// Whether to show the FAB with entrance animation
  final bool visible;

  /// Shape (defaults to M3E shape)
  final ShapeBorder? shape;

  /// Whether this is a tonal variant
  final bool tonal;

  const FABM3E({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.size = FABSize.regular,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.hoverElevation,
    this.tooltip,
    this.heroTag,
    this.visible = true,
    this.shape,
    this.tonal = false,
  });

  @override
  State<FABM3E> createState() => _FABM3EState();
}

class _FABM3EState extends State<FABM3E>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool _isHovered = false;
  bool _isPressed = false;

  // Size specifications for different FAB variants - M3E: 5 sizes
  static const Map<FABSize, FABSpec> _fabSpecs = {
    FABSize.xs: FABSpec(
      size: 32.0,
      iconSize: 18.0,
      cornerRadius: M3EShapes.small,
    ),
    FABSize.small: FABSpec(
      size: 40.0,
      iconSize: 20.0,
      cornerRadius: M3EShapes.small,
    ),
    FABSize.regular: FABSpec(
      size: 56.0,
      iconSize: 24.0,
      cornerRadius: M3EShapes.large,
    ),
    FABSize.large: FABSpec(
      size: 72.0,
      iconSize: 30.0,
      cornerRadius: M3EShapes.extraLarge,
    ),
    FABSize.xl: FABSpec(
      size: 96.0,
      iconSize: 36.0,
      cornerRadius: M3EShapes.extraLarge,
    ),
  };

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: M3EMotion.medium2,
      vsync: this,
    );

    // Entrance animation with expressive spring
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: M3EMotion.emphasized,
      reverseCurve: M3EMotion.emphasizedAccelerate,
    );

    if (widget.visible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(FABM3E oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
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

  void _handleHoverChange(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }

  void _handlePressChange(bool isPressed) {
    setState(() {
      _isPressed = isPressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final spec = _fabSpecs[widget.size]!;

    final backgroundColor = widget.tonal
        ? (widget.backgroundColor ?? colorScheme.secondaryContainer)
        : (widget.backgroundColor ?? colorScheme.primary);

    final foregroundColor = widget.tonal
        ? (widget.foregroundColor ?? colorScheme.onSecondaryContainer)
        : (widget.foregroundColor ?? colorScheme.onPrimary);

    final isExtended = widget.label != null;

    Widget fab = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = _isPressed ? 0.95 : 1.0;
        final combinedScale = _scaleAnimation.value * scale;

        final currentElevation = _isHovered
            ? (widget.hoverElevation ?? M3EElevation.fabHovered)
            : (widget.elevation ?? M3EElevation.fabDefault);

        return Transform.scale(
          scale: combinedScale,
          child: Material(
            color: backgroundColor,
            elevation: currentElevation,
            shadowColor: Colors.black,
            shape: widget.shape ??
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    isExtended ? M3EShapes.large : spec.cornerRadius,
                  ),
                ),
            child: InkWell(
              onTap: widget.onPressed,
              onHover: _handleHoverChange,
              onTapDown: (_) => _handlePressChange(true),
              onTapUp: (_) => _handlePressChange(false),
              onTapCancel: () => _handlePressChange(false),
              customBorder: widget.shape ??
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      isExtended ? M3EShapes.large : spec.cornerRadius,
                    ),
                  ),
              child: Container(
                height: isExtended ? 56.0 : spec.size,
                constraints: isExtended
                    ? BoxConstraints(minWidth: spec.size)
                    : BoxConstraints.tight(Size.square(spec.size)),
                padding: isExtended
                    ? const EdgeInsets.symmetric(
                        horizontal: M3ESpacing.md,
                      )
                    : EdgeInsets.zero,
                child: isExtended
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.icon,
                            size: spec.iconSize,
                            color: foregroundColor,
                          ),
                          const SizedBox(width: M3ESpacing.xs),
                          Text(
                            widget.label!,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: foregroundColor,
                            ),
                          ),
                        ],
                      )
                    : Icon(
                        widget.icon,
                        size: spec.iconSize,
                        color: foregroundColor,
                      ),
              ),
            ),
          ),
        );
      },
    );

    if (widget.tooltip != null) {
      fab = Tooltip(
        message: widget.tooltip!,
        child: fab,
      );
    }

    if (widget.heroTag != null) {
      fab = Hero(
        tag: widget.heroTag!,
        child: fab,
      );
    }

    return fab;
  }
}

/// FAB size variants - M3E Enhancement: 5 sizes
enum FABSize {
  /// 32x32dp FAB - Extra Small
  xs,

  /// 40x40dp FAB - Small
  small,

  /// 56x56dp FAB (default) - Medium/Regular
  regular,

  /// 72x72dp FAB - Large
  large,

  /// 96x96dp FAB - Extra Large
  xl,
}

/// FAB specifications
class FABSpec {
  final double size;
  final double iconSize;
  final double cornerRadius;

  const FABSpec({
    required this.size,
    required this.iconSize,
    required this.cornerRadius,
  });
}

/// Material 3 Expressive Icon Button
///
/// Implements M3E icon button variants with proper state layers and animations.
///
/// ## Variants:
///
/// - **Standard**: 40x40dp container, 24dp icon, 48dp touch target
/// - **Filled**: Background filled with primary
/// - **Tonal**: Background filled with secondaryContainer
/// - **Outlined**: 1dp outline
///
/// ## Example:
///
/// ```dart
/// IconButtonM3E(
///   icon: Icons.favorite,
///   onPressed: () {},
///   variant: IconButtonVariant.filled,
/// )
/// ```
class IconButtonM3E extends StatefulWidget {
  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Icon to display
  final IconData icon;

  /// Icon button variant
  final IconButtonVariant variant;

  /// Custom icon size (defaults to 24dp)
  final double? iconSize;

  /// Custom color
  final Color? color;

  /// Background color (for filled/tonal variants)
  final Color? backgroundColor;

  /// Tooltip message
  final String? tooltip;

  /// Whether this is selected (for toggle buttons)
  final bool selected;

  /// Selected icon (for toggle buttons)
  final IconData? selectedIcon;

  /// Callback when selection changes
  final ValueChanged<bool>? onSelectedChanged;

  const IconButtonM3E({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = IconButtonVariant.standard,
    this.iconSize,
    this.color,
    this.backgroundColor,
    this.tooltip,
    this.selected = false,
    this.selectedIcon,
    this.onSelectedChanged,
  });

  @override
  State<IconButtonM3E> createState() => _IconButtonM3EState();
}

class _IconButtonM3EState extends State<IconButtonM3E>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: M3EMotion.short3,
      vsync: this,
    );

    if (widget.selected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(IconButtonM3E oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selected != oldWidget.selected) {
      if (widget.selected) {
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

  void _handleTap() {
    if (widget.onSelectedChanged != null) {
      widget.onSelectedChanged!(!widget.selected);
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine colors based on variant
    Color? iconColor;
    Color? bgColor;
    Color? overlayColor;

    switch (widget.variant) {
      case IconButtonVariant.standard:
        iconColor = widget.color ?? colorScheme.onSurfaceVariant;
        bgColor = null;
        overlayColor = colorScheme.onSurfaceVariant;
        break;

      case IconButtonVariant.filled:
        iconColor = widget.color ?? colorScheme.onPrimary;
        bgColor = widget.backgroundColor ?? colorScheme.primary;
        overlayColor = colorScheme.onPrimary;
        break;

      case IconButtonVariant.tonal:
        iconColor = widget.color ?? colorScheme.onSecondaryContainer;
        bgColor = widget.backgroundColor ?? colorScheme.secondaryContainer;
        overlayColor = colorScheme.onSecondaryContainer;
        break;

      case IconButtonVariant.outlined:
        iconColor = widget.color ?? colorScheme.onSurfaceVariant;
        bgColor = null;
        overlayColor = colorScheme.onSurfaceVariant;
        break;
    }

    if (widget.selected) {
      switch (widget.variant) {
        case IconButtonVariant.standard:
          iconColor = colorScheme.primary;
          break;
        case IconButtonVariant.filled:
          // Already uses primary colors
          break;
        case IconButtonVariant.tonal:
          iconColor = colorScheme.onSecondaryContainer;
          bgColor = colorScheme.secondaryContainer;
          break;
        case IconButtonVariant.outlined:
          iconColor = colorScheme.inverseSurface;
          bgColor = colorScheme.inverseSurface;
          break;
      }
    }

    final displayIcon = widget.selected && widget.selectedIcon != null
        ? widget.selectedIcon!
        : widget.icon;

    Widget button = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = _isPressed ? 0.95 : 1.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(M3EShapes.full),
              border: widget.variant == IconButtonVariant.outlined
                  ? Border.all(
                      color: colorScheme.outline,
                      width: 1.0,
                    )
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed != null || widget.onSelectedChanged != null
                    ? _handleTap
                    : null,
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                customBorder: const CircleBorder(),
                overlayColor: overlayColor != null
                    ? WidgetStateProperty.resolveWith<Color?>((states) {
                        final color = overlayColor!;
                        if (states.contains(WidgetState.pressed)) {
                          return M3EStateLayer.getPressColor(color);
                        }
                        if (states.contains(WidgetState.hovered)) {
                          return M3EStateLayer.getHoverColor(color);
                        }
                        return null;
                      })
                    : null,
                child: Center(
                  child: Icon(
                    displayIcon,
                    size: widget.iconSize ?? 24.0,
                    color: iconColor,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Icon button variant types
enum IconButtonVariant {
  /// Standard icon button with no background
  standard,

  /// Filled icon button with primary background
  filled,

  /// Tonal icon button with secondary container background
  tonal,

  /// Outlined icon button with border
  outlined,
}

/// Material 3 Expressive FAB Menu
///
/// A FAB that expands to show a menu of child FABs with staggered animations.
///
/// ## Features:
///
/// - Main FAB that expands to show menu
/// - Child FABs with 50ms stagger delay
/// - Backdrop scrim with fade
/// - Labels appear with slide + fade
///
/// ## Example:
///
/// ```dart
/// FABMenuM3E(
///   icon: Icons.add,
///   items: [
///     FABMenuItem(
///       icon: Icons.photo,
///       label: 'Photo',
///       onPressed: () {},
///     ),
///     FABMenuItem(
///       icon: Icons.video_library,
///       label: 'Video',
///       onPressed: () {},
///     ),
///   ],
/// )
/// ```
class FABMenuM3E extends StatefulWidget {
  /// Icon for the main FAB
  final IconData icon;

  /// Icon when menu is open
  final IconData? openIcon;

  /// Menu items
  final List<FABMenuItem> items;

  /// Background color
  final Color? backgroundColor;

  /// Foreground color
  final Color? foregroundColor;

  /// Tooltip for main FAB
  final String? tooltip;

  /// Hero tag
  final Object? heroTag;

  /// Whether to show labels
  final bool showLabels;

  /// Direction to expand menu
  final FABMenuDirection direction;

  const FABMenuM3E({
    super.key,
    required this.icon,
    this.openIcon,
    required this.items,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.heroTag,
    this.showLabels = true,
    this.direction = FABMenuDirection.up,
  });

  @override
  State<FABMenuM3E> createState() => _FABMenuM3EState();
}

class _FABMenuM3EState extends State<FABMenuM3E>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _mainRotation;
  late Animation<double> _scrimOpacity;

  bool _isOpen = false;

  // Stagger delay between child animations
  static const Duration _staggerDelay = Duration(milliseconds: 50);

  // Spacing between FABs
  static const double _fabSpacing = 72.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: M3EMotion.medium3,
      vsync: this,
    );

    // Main FAB rotation
    _mainRotation = Tween<double>(
      begin: 0.0,
      end: 0.125, // 45 degrees
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: M3EMotion.emphasized,
    ));

    // Scrim opacity
    _scrimOpacity = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _closeMenu() {
    if (_isOpen) {
      setState(() {
        _isOpen = false;
        _controller.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        // Backdrop scrim
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeMenu,
              child: AnimatedBuilder(
                animation: _scrimOpacity,
                builder: (context, child) {
                  return Container(
                    color: Colors.black.withValues(alpha: _scrimOpacity.value * 0.5),
                  );
                },
              ),
            ),
          ),

        // Child FABs
        ...List.generate(widget.items.length, (index) {
          final item = widget.items[index];
          final reversedIndex = widget.items.length - 1 - index;
          final delay = reversedIndex * _staggerDelay.inMilliseconds;

          // Calculate position based on direction
          double offsetX = 0;
          double offsetY = 0;

          switch (widget.direction) {
            case FABMenuDirection.up:
              offsetY = -(index + 1) * _fabSpacing;
              break;
            case FABMenuDirection.down:
              offsetY = (index + 1) * _fabSpacing;
              break;
            case FABMenuDirection.left:
              offsetX = -(index + 1) * _fabSpacing;
              break;
            case FABMenuDirection.right:
              offsetX = (index + 1) * _fabSpacing;
              break;
          }

          return _FABMenuItemWidget(
            item: item,
            controller: _controller,
            delay: delay,
            offsetX: offsetX,
            offsetY: offsetY,
            showLabel: widget.showLabels,
            onPressed: () {
              _closeMenu();
              item.onPressed();
            },
          );
        }),

        // Main FAB
        AnimatedBuilder(
          animation: _mainRotation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _mainRotation.value * 2 * math.pi,
              child: FABM3E(
                icon: _isOpen ? (widget.openIcon ?? Icons.close) : widget.icon,
                onPressed: _toggleMenu,
                backgroundColor: widget.backgroundColor,
                foregroundColor: widget.foregroundColor,
                tooltip: widget.tooltip,
                heroTag: widget.heroTag,
              ),
            );
          },
        ),
      ],
    );
  }
}

/// FAB menu item widget with staggered animation
class _FABMenuItemWidget extends StatelessWidget {
  final FABMenuItem item;
  final AnimationController controller;
  final int delay;
  final double offsetX;
  final double offsetY;
  final bool showLabel;
  final VoidCallback onPressed;

  const _FABMenuItemWidget({
    required this.item,
    required this.controller,
    required this.delay,
    required this.offsetX,
    required this.offsetY,
    required this.showLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Create staggered animation
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(
        (delay / M3EMotion.medium3.inMilliseconds).clamp(0.0, 1.0),
        1.0,
        curve: M3EMotion.emphasizedDecelerate,
      ),
    );

    final scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(animation);

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(animation);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            offsetX * animation.value,
            offsetY * animation.value,
          ),
          child: Opacity(
            opacity: animation.value,
            child: Transform.scale(
              scale: scaleAnimation.value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label
                  if (showLabel && item.label != null)
                    SlideTransition(
                      position: slideAnimation,
                      child: Padding(
                        padding: const EdgeInsets.only(right: M3ESpacing.xs),
                        child: Material(
                          color: theme.colorScheme.surface,
                          elevation: M3EElevation.level2,
                          borderRadius: BorderRadius.circular(M3EShapes.extraSmall),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: M3ESpacing.sm,
                              vertical: M3ESpacing.xxs,
                            ),
                            child: Text(
                              item.label!,
                              style: theme.textTheme.labelMedium,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // FAB
                  FABM3E(
                    icon: item.icon,
                    onPressed: onPressed,
                    size: FABSize.small,
                    backgroundColor: item.backgroundColor,
                    foregroundColor: item.foregroundColor,
                    tooltip: !showLabel ? item.label : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// FAB menu item data
class FABMenuItem {
  /// Icon to display
  final IconData icon;

  /// Label text (shown next to FAB)
  final String? label;

  /// Callback when pressed
  final VoidCallback onPressed;

  /// Background color
  final Color? backgroundColor;

  /// Foreground color
  final Color? foregroundColor;

  const FABMenuItem({
    required this.icon,
    this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });
}

/// Direction for FAB menu expansion
enum FABMenuDirection {
  /// Expand upward
  up,

  /// Expand downward
  down,

  /// Expand to the left
  left,

  /// Expand to the right
  right,
}

/// Extended FAB with expand/collapse animation
///
/// A FAB that can animate between icon-only and extended (icon + label) states.
///
/// ## Example:
///
/// ```dart
/// ExtendedFABM3E(
///   icon: Icons.edit,
///   label: 'Edit',
///   expanded: true,
///   onPressed: () {},
/// )
/// ```
class ExtendedFABM3E extends StatefulWidget {
  /// Callback when pressed
  final VoidCallback? onPressed;

  /// Icon to display
  final IconData icon;

  /// Label text
  final String label;

  /// Whether the FAB is expanded
  final bool expanded;

  /// Background color
  final Color? backgroundColor;

  /// Foreground color
  final Color? foregroundColor;

  /// Custom elevation
  final double? elevation;

  /// Custom hover elevation
  final double? hoverElevation;

  /// Tooltip message
  final String? tooltip;

  /// Hero tag
  final Object? heroTag;

  /// Whether to show the FAB with entrance animation
  final bool visible;

  /// Whether this is a tonal variant
  final bool tonal;

  const ExtendedFABM3E({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.expanded = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.hoverElevation,
    this.tooltip,
    this.heroTag,
    this.visible = true,
    this.tonal = false,
  });

  @override
  State<ExtendedFABM3E> createState() => _ExtendedFABM3EState();
}

class _ExtendedFABM3EState extends State<ExtendedFABM3E>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _expandController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _expandAnimation;

  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Entrance animation
    _entranceController = AnimationController(
      duration: M3EMotion.medium2,
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: M3EMotion.emphasized,
      reverseCurve: M3EMotion.emphasizedAccelerate,
    );

    // Expand/collapse animation
    _expandController = AnimationController(
      duration: M3EMotion.medium3,
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: M3EMotion.standard,
    );

    if (widget.visible) {
      _entranceController.forward();
    }

    if (widget.expanded) {
      _expandController.forward();
    }
  }

  @override
  void didUpdateWidget(ExtendedFABM3E oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _entranceController.forward();
      } else {
        _entranceController.reverse();
      }
    }

    if (widget.expanded != oldWidget.expanded) {
      if (widget.expanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final backgroundColor = widget.tonal
        ? (widget.backgroundColor ?? colorScheme.secondaryContainer)
        : (widget.backgroundColor ?? colorScheme.primary);

    final foregroundColor = widget.tonal
        ? (widget.foregroundColor ?? colorScheme.onSecondaryContainer)
        : (widget.foregroundColor ?? colorScheme.onPrimary);

    Widget fab = AnimatedBuilder(
      animation: Listenable.merge([_entranceController, _expandController]),
      builder: (context, child) {
        final pressScale = _isPressed ? 0.95 : 1.0;
        final combinedScale = _scaleAnimation.value * pressScale;

        final currentElevation = _isHovered
            ? (widget.hoverElevation ?? M3EElevation.fabHovered)
            : (widget.elevation ?? M3EElevation.fabDefault);

        return Transform.scale(
          scale: combinedScale,
          child: Material(
            color: backgroundColor,
            elevation: currentElevation,
            shadowColor: Colors.black,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(M3EShapes.large),
              ),
            ),
            child: InkWell(
              onTap: widget.onPressed,
              onHover: (value) => setState(() => _isHovered = value),
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              customBorder: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(M3EShapes.large),
                ),
              ),
              child: Container(
                height: 56.0,
                padding: const EdgeInsets.symmetric(
                  horizontal: M3ESpacing.md,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      size: 24.0,
                      color: foregroundColor,
                    ),
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: _expandAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.only(left: M3ESpacing.xs),
                          child: Text(
                            widget.label,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: foregroundColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                          ),
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

    if (widget.tooltip != null) {
      fab = Tooltip(
        message: widget.tooltip!,
        child: fab,
      );
    }

    if (widget.heroTag != null) {
      fab = Hero(
        tag: widget.heroTag!,
        child: fab,
      );
    }

    return fab;
  }
}

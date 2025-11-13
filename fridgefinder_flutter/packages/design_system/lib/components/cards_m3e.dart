import 'package:flutter/material.dart';
import '../theme/elevation.dart';
import '../theme/motion.dart';
import '../theme/shapes.dart';
import '../theme/spacing.dart';
import '../theme/state_layers.dart';

/// M3E Card
///
/// An elevated or filled card with proper M3E styling, elevation transitions,
/// and interactive states.
///
/// Enhanced Features:
/// - Level 1 default elevation with smooth level 2 hover
/// - Enhanced surface tinting with primary color
/// - Generous 20dp padding for better content breathing room
/// - Smooth shadow transitions with proper alpha blending
/// - 16dp border radius for M3E aesthetic
/// - Better visual hierarchy with improved spacing
///
/// Perfect for fridge list items with status, food level, and distance information.
class CardM3E extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final ShapeBorder? shape;
  final bool filled;
  final bool outlined;
  final Clip clipBehavior;

  const CardM3E({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.shape,
    this.filled = false,
    this.outlined = false,
    this.clipBehavior = Clip.none,
  });

  @override
  State<CardM3E> createState() => _CardM3EState();
}

class _CardM3EState extends State<CardM3E>
    with TickerProviderStateMixin {
  late AnimationController _elevationController;
  late AnimationController _pressController;
  late Animation<double> _elevationAnimation;
  late Animation<double> _pressScaleAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _elevationController = AnimationController(
      duration: M3EMotionPatterns.elevationChange,
      vsync: this,
    );

    _pressController = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3), // 350ms for more noticeable press feedback
      vsync: this,
    );

    _elevationAnimation = Tween<double>(
      begin: M3EElevation.level1,
      end: M3EElevation.level2,
    ).animate(CurvedAnimation(
      parent: _elevationController,
      curve: M3EMotionPatterns.elevationCurve,
    ));

    _pressScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98, // Slight scale down on press
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: M3EMotion.emphasizedDecelerate,
    ));
  }

  @override
  void dispose() {
    _elevationController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleHoverChange(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (widget.onTap != null) {
      if (isHovered) {
        _elevationController.forward();
      } else {
        _elevationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Determine card variant with enhanced surface tinting
    Color cardColor;
    double cardElevation;
    Border? border;

    if (widget.outlined) {
      cardColor = widget.color ?? colorScheme.surface;
      cardElevation = widget.elevation ?? M3EElevation.cardDefault;
      border = Border.all(
        color: colorScheme.outlineVariant,
        width: 1.0,
      );
    } else if (widget.filled) {
      // Use higher surface container for more prominent filled cards
      cardColor = widget.color ?? colorScheme.surfaceContainerHighest;
      cardElevation = widget.elevation ?? M3EElevation.cardDefault;
      border = null;
    } else {
      // Elevated variant (default) - enhanced with better surface tinting
      cardColor = widget.color ?? colorScheme.surfaceContainerLow;
      cardElevation = widget.elevation ?? M3EElevation.level1;
      border = null;
    }

    final borderRadius = (widget.shape as RoundedRectangleBorder?)?.borderRadius ??
        (M3EShapes.card as RoundedRectangleBorder).borderRadius;

    // Enhanced padding for better content breathing room
    final effectivePadding = widget.padding ?? M3ESpacing.all(M3ESpacing.lg);

    Widget cardContent = Container(
      margin: widget.margin ?? M3ESpacing.only(bottom: M3ESpacing.md),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: borderRadius,
        border: border,
      ),
      child: Padding(
        padding: effectivePadding,
        child: widget.child,
      ),
    );

    if (widget.onTap != null) {
      cardContent = MouseRegion(
        onEnter: (_) => _handleHoverChange(true),
        onExit: (_) => _handleHoverChange(false),
        child: GestureDetector(
          onTapDown: (_) {
            setState(() => _isPressed = true);
            _pressController.forward();
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            _pressController.reverse();
            widget.onTap?.call();
          },
          onTapCancel: () {
            setState(() => _isPressed = false);
            _pressController.reverse();
          },
          child: AnimatedBuilder(
            animation: _pressScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isPressed ? _pressScaleAnimation.value : 1.0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    borderRadius: borderRadius as BorderRadius?,
                    overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(WidgetState.pressed)) {
                        return M3EStateLayer.getPressColor(colorScheme.onSurface);
                      }
                      if (states.contains(WidgetState.hovered)) {
                        return M3EStateLayer.getHoverColor(colorScheme.onSurface);
                      }
                      return null;
                    }),
                    child: child,
                  ),
                ),
              );
            },
            child: cardContent,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _elevationAnimation,
      builder: (context, child) {
        final currentElevation = widget.onTap != null && _isHovered
            ? _elevationAnimation.value
            : cardElevation;

        return Material(
          color: Colors.transparent,
          elevation: currentElevation,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
          surfaceTintColor: widget.outlined || widget.filled
              ? Colors.transparent
              : colorScheme.primary,
          shape: widget.shape ?? M3EShapes.card,
          clipBehavior: widget.clipBehavior,
          child: child,
        );
      },
      child: cardContent,
    );
  }
}

/// M3E Card Header
///
/// A standardized card header with title, subtitle, and optional leading/trailing widgets.
///
/// Enhanced Features:
/// - Title uses titleLarge (22sp) with semibold weight for better hierarchy
/// - Subtitle uses bodyMedium with onSurfaceVariant color for secondary info
/// - Leading icons sized at 40px with primary color accent
/// - Trailing icons sized at 24px with subtle onSurfaceVariant color
/// - Better line height (1.2 for title, 1.4 for subtitle) for readability
/// - Supports up to 2 lines for both title and subtitle
///
/// Perfect for displaying fridge names, status, and metadata.
class CardHeaderM3E extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  const CardHeaderM3E({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[
          // Enhanced leading widget with better visual prominence
          IconTheme(
            data: IconThemeData(
              color: colorScheme.primary,
              size: 40,
            ),
            child: leading!,
          ),
          M3ESpacing.horizontalMD,
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                M3ESpacing.verticalXS,
                Text(
                  subtitle!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          M3ESpacing.horizontalMD,
          // Enhanced trailing widget with better alignment
          Padding(
            padding: M3ESpacing.only(top: M3ESpacing.xxs),
            child: IconTheme(
              data: IconThemeData(
                color: colorScheme.onSurfaceVariant,
                size: 24,
              ),
              child: trailing!,
            ),
          ),
        ],
      ],
    );
  }
}

/// M3E Status Badge
///
/// A compact status indicator with color-coded background and text.
///
/// Features:
/// - Uses secondary/tertiary colors for vibrant status display
/// - 8dp padding with 8dp border radius
/// - Semibold text for better readability
/// - Automatic contrast-safe text color
/// - Perfect for food level, status, and distance indicators
///
/// Example usage:
/// ```dart
/// StatusBadgeM3E(
///   label: 'Full',
///   color: colorScheme.tertiary, // Green for full
/// )
/// StatusBadgeM3E(
///   label: '2.3 km',
///   color: colorScheme.primary,
/// )
/// ```
class StatusBadgeM3E extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;

  const StatusBadgeM3E({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final bgColor = backgroundColor ?? colorScheme.secondaryContainer;
    final fgColor = textColor ?? colorScheme.onSecondaryContainer;

    return Container(
      padding: padding ?? M3ESpacing.symmetric(
        horizontal: M3ESpacing.sm,
        vertical: M3ESpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: textTheme.labelMedium?.copyWith(
          color: fgColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

/// M3E Metadata Row
///
/// A row of metadata items with consistent spacing and styling.
///
/// Features:
/// - Consistent 12dp spacing between items
/// - Uses bodySmall with onSurfaceVariant color
/// - Supports icons with automatic theming
/// - Wraps to multiple lines if needed
///
/// Perfect for displaying fridge metadata like distance, food level, last updated, etc.
///
/// Example:
/// ```dart
/// MetadataRowM3E(
///   items: [
///     MetadataItem(icon: Icons.location_on, text: '2.3 km'),
///     MetadataItem(icon: Icons.kitchen, text: '42 items'),
///     MetadataItem(text: 'Updated 5m ago'),
///   ],
/// )
/// ```
class MetadataRowM3E extends StatelessWidget {
  final List<MetadataItem> items;
  final double spacing;

  const MetadataRowM3E({
    super.key,
    required this.items,
    this.spacing = M3ESpacing.sm,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      spacing: spacing,
      runSpacing: M3ESpacing.xxs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: items.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              M3ESpacing.horizontalXXS,
            ],
            Text(
              item.text,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

/// Metadata item for MetadataRowM3E
class MetadataItem {
  final IconData? icon;
  final String text;

  const MetadataItem({
    this.icon,
    required this.text,
  });
}

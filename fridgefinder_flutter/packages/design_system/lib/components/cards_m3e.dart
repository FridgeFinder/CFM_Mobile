import 'package:flutter/material.dart';
import '../theme/elevation.dart';
import '../theme/motion.dart';
import '../theme/shapes.dart';
import '../theme/spacing.dart';

/// M3E Card
///
/// An elevated or filled card with proper M3E styling, elevation transitions,
/// and interactive states.
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
    with SingleTickerProviderStateMixin {
  late AnimationController _elevationController;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _elevationController = AnimationController(
      duration: M3EMotionPatterns.elevationChange,
      vsync: this,
    );

    _elevationAnimation = Tween<double>(
      begin: M3EElevation.cardDefault,
      end: M3EElevation.cardHovered,
    ).animate(CurvedAnimation(
      parent: _elevationController,
      curve: M3EMotionPatterns.elevationCurve,
    ));
  }

  @override
  void dispose() {
    _elevationController.dispose();
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

    // Determine card variant
    Color cardColor;
    double cardElevation;
    Border? border;

    if (widget.outlined) {
      cardColor = widget.color ?? colorScheme.surface;
      cardElevation = widget.elevation ?? M3EElevation.cardDefault;
      border = Border.all(
        color: colorScheme.outlineVariant,
        width: 1,
      );
    } else if (widget.filled) {
      cardColor = widget.color ?? colorScheme.surfaceContainerHighest;
      cardElevation = widget.elevation ?? M3EElevation.cardDefault;
      border = null;
    } else {
      // Elevated variant (default)
      cardColor = widget.color ?? colorScheme.surfaceContainerLow;
      cardElevation = widget.elevation ?? M3EElevation.cardDefault;
      border = null;
    }

    final borderRadius = (widget.shape as RoundedRectangleBorder?)?.borderRadius ??
        (M3EShapes.card as RoundedRectangleBorder).borderRadius;

    Widget cardContent = Container(
      margin: widget.margin ?? M3ESpacing.only(bottom: M3ESpacing.sm),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: borderRadius,
        border: border,
      ),
      child: Padding(
        padding: widget.padding ?? M3ESpacing.cardPadding,
        child: widget.child,
      ),
    );

    if (widget.onTap != null) {
      cardContent = MouseRegion(
        onEnter: (_) => _handleHoverChange(true),
        onExit: (_) => _handleHoverChange(false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: borderRadius as BorderRadius?,
          child: cardContent,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _elevationAnimation,
      builder: (context, child) {
        return Material(
          color: Colors.transparent,
          elevation: widget.onTap != null && _isHovered
              ? _elevationAnimation.value
              : cardElevation,
          shadowColor: colorScheme.shadow,
          surfaceTintColor: widget.outlined || widget.filled
              ? Colors.transparent
              : colorScheme.surfaceTint,
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[
          leading!,
          M3ESpacing.horizontalMD,
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                M3ESpacing.verticalXXS,
                Text(
                  subtitle!,
                  style: textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          M3ESpacing.horizontalMD,
          trailing!,
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/motion.dart';
import '../theme/spacing.dart';

/// M3E Divider Component
///
/// Material 3 Expressive dividers with variants and animations.
///
/// Features:
/// - Inset dividers (with leading/trailing padding)
/// - Vertical dividers
/// - Dividers with labels
/// - Animated appearance
class DividerM3E extends StatelessWidget {
  /// Divider height/thickness
  final double height;

  /// Divider color
  final Color? color;

  /// Leading indent (for inset dividers)
  final double? indent;

  /// Trailing indent (for inset dividers)
  final double? endIndent;

  /// Whether to animate appearance
  final bool animate;

  const DividerM3E({
    super.key,
    this.height = 1.0,
    this.color,
    this.indent,
    this.endIndent,
    this.animate = false,
  });

  /// Inset divider variant
  const DividerM3E.inset({
    super.key,
    this.height = 1.0,
    this.color,
    this.indent = M3ESpacing.md,
    this.endIndent = 0.0,
    this.animate = false,
  });

  /// Vertical divider variant
  const DividerM3E.vertical({
    super.key,
    this.height = 24.0,
    this.color,
    this.indent,
    this.endIndent,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.outlineVariant;

    Widget divider = Divider(
      height: height,
      thickness: height,
      color: effectiveColor,
      indent: indent,
      endIndent: endIndent,
    );

    if (animate) {
      return TweenAnimationBuilder<double>(
        duration: M3EMotion.getDuration(M3EMotion.medium3),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: divider,
          );
        },
      );
    }

    return divider;
  }
}

/// M3E Divider with Label
///
/// A divider with a centered label text.
class DividerWithLabelM3E extends StatelessWidget {
  /// Label text
  final String label;

  /// Divider height/thickness
  final double height;

  /// Divider color
  final Color? color;

  /// Label text style
  final TextStyle? labelStyle;

  /// Padding around label
  final EdgeInsets? labelPadding;

  /// Whether to animate appearance
  final bool animate;

  const DividerWithLabelM3E({
    super.key,
    required this.label,
    this.height = 1.0,
    this.color,
    this.labelStyle,
    this.labelPadding,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.outlineVariant;
    final textStyle = labelStyle ??
        Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        );

    Widget divider = Row(
      children: [
        Expanded(
          child: Divider(
            height: height,
            thickness: height,
            color: effectiveColor,
          ),
        ),
        Padding(
          padding: labelPadding ?? const EdgeInsets.symmetric(
            horizontal: M3ESpacing.md,
          ),
          child: Text(
            label,
            style: textStyle,
          ),
        ),
        Expanded(
          child: Divider(
            height: height,
            thickness: height,
            color: effectiveColor,
          ),
        ),
      ],
    );

    if (animate) {
      return TweenAnimationBuilder<double>(
        duration: M3EMotion.getDuration(M3EMotion.medium3),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: divider,
          );
        },
      );
    }

    return divider;
  }
}

/// M3E Vertical Divider
///
/// A vertical divider for separating horizontal content.
class VerticalDividerM3E extends StatelessWidget {
  /// Divider width/thickness
  final double width;

  /// Divider height
  final double height;

  /// Divider color
  final Color? color;

  /// Whether to animate appearance
  final bool animate;

  const VerticalDividerM3E({
    super.key,
    this.width = 1.0,
    this.height = 24.0,
    this.color,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.outlineVariant;

    Widget divider = VerticalDivider(
      width: width,
      thickness: width,
      color: effectiveColor,
    );

    if (animate) {
      return TweenAnimationBuilder<double>(
        duration: M3EMotion.getDuration(M3EMotion.medium3),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: divider,
          );
        },
      );
    }

    return divider;
  }
}


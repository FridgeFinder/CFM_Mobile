import 'package:flutter/material.dart';

/// M3E Button Variants
///
/// Flutter's built-in button widgets already follow M3 design.
/// These are convenience wrappers with consistent styling and M3E size variants.
///
/// ## M3E Enhancement: Five Size Variants
///
/// All button types support five sizes (XS, SM, MD, LG, XL) versus M3's single default size.
/// This provides greater flexibility for different UI contexts and hierarchy.

/// Button size variants for M3E
enum ButtonSizeM3E {
  /// Extra Small - 32dp height, 12dp padding, 12sp text
  xs,

  /// Small - 36dp height, 14dp padding, 13sp text
  sm,

  /// Medium (Default) - 40dp height, 16dp padding, 14sp text
  md,

  /// Large - 48dp height, 20dp padding, 15sp text
  lg,

  /// Extra Large - 56dp height, 24dp padding, 16sp text
  xl,
}

/// Button size specifications
class ButtonSizeSpec {
  final double height;
  final EdgeInsets padding;
  final double fontSize;
  final double iconSize;

  const ButtonSizeSpec({
    required this.height,
    required this.padding,
    required this.fontSize,
    required this.iconSize,
  });

  /// Get specification for a given size
  static ButtonSizeSpec forSize(ButtonSizeM3E size) {
    switch (size) {
      case ButtonSizeM3E.xs:
        return const ButtonSizeSpec(
          height: 32,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          fontSize: 12,
          iconSize: 18,
        );
      case ButtonSizeM3E.sm:
        return const ButtonSizeSpec(
          height: 36,
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          fontSize: 13,
          iconSize: 20,
        );
      case ButtonSizeM3E.md:
        return const ButtonSizeSpec(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          fontSize: 14,
          iconSize: 24,
        );
      case ButtonSizeM3E.lg:
        return const ButtonSizeSpec(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          fontSize: 15,
          iconSize: 24,
        );
      case ButtonSizeM3E.xl:
        return const ButtonSizeSpec(
          height: 56,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          fontSize: 16,
          iconSize: 28,
        );
    }
  }
}

/// M3E Filled Button (Primary action)
///
/// Supports 5 size variants: XS, SM, MD (default), LG, XL
///
/// Example:
/// ```dart
/// FilledButtonM3E(
///   onPressed: () {},
///   size: ButtonSizeM3E.lg,
///   child: Text('Large Button'),
/// )
///
/// // Or use named constructors
/// FilledButtonM3E.xs(
///   onPressed: () {},
///   child: Text('Extra Small'),
/// )
/// ```
class FilledButtonM3E extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;
  final ButtonSizeM3E size;

  const FilledButtonM3E({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
    this.size = ButtonSizeM3E.md,
  });

  /// Extra small button (32dp height)
  const FilledButtonM3E.xs({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  }) : size = ButtonSizeM3E.xs;

  /// Small button (36dp height)
  const FilledButtonM3E.sm({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  }) : size = ButtonSizeM3E.sm;

  /// Large button (48dp height)
  const FilledButtonM3E.lg({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  }) : size = ButtonSizeM3E.lg;

  /// Extra large button (56dp height)
  const FilledButtonM3E.xl({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  }) : size = ButtonSizeM3E.xl;

  ButtonStyle _getStyleForSize(BuildContext context) {
    final spec = ButtonSizeSpec.forSize(size);
    final theme = Theme.of(context);

    return FilledButton.styleFrom(
      minimumSize: Size(0, spec.height),  // Min width 0, min height from spec
      padding: spec.padding,
      textStyle: theme.textTheme.labelLarge?.copyWith(
        fontSize: spec.fontSize,
      ),
      iconSize: spec.iconSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _getStyleForSize(context);

    if (icon != null) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: child,
        style: style,
      );
    }
    return FilledButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );
  }
}

/// M3E Outlined Button (Secondary action)
///
/// Supports 5 size variants: XS, SM, MD (default), LG, XL
class OutlinedButtonM3E extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;
  final ButtonSizeM3E size;

  const OutlinedButtonM3E({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
    this.size = ButtonSizeM3E.md,
  });

  /// Extra small button (32dp height)
  const OutlinedButtonM3E.xs({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  }) : size = ButtonSizeM3E.xs;

  /// Small button (36dp height)
  const OutlinedButtonM3E.sm({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  }) : size = ButtonSizeM3E.sm;

  /// Large button (48dp height)
  const OutlinedButtonM3E.lg({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  }) : size = ButtonSizeM3E.lg;

  /// Extra large button (56dp height)
  const OutlinedButtonM3E.xl({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  }) : size = ButtonSizeM3E.xl;

  ButtonStyle _getStyleForSize(BuildContext context) {
    final spec = ButtonSizeSpec.forSize(size);
    final theme = Theme.of(context);

    return OutlinedButton.styleFrom(
      minimumSize: Size(0, spec.height),  // Min width 0, min height from spec
      padding: spec.padding,
      textStyle: theme.textTheme.labelLarge?.copyWith(
        fontSize: spec.fontSize,
      ),
      iconSize: spec.iconSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _getStyleForSize(context);

    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: child,
        style: style,
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );
  }
}

/// M3E Text Button (Tertiary action)
///
/// Supports 5 size variants: XS, SM, MD (default), LG, XL
class TextButtonM3E extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;
  final ButtonSizeM3E size;

  const TextButtonM3E({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
    this.size = ButtonSizeM3E.md,
  });

  /// Extra small button (32dp height)
  const TextButtonM3E.xs({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  }) : size = ButtonSizeM3E.xs;

  /// Small button (36dp height)
  const TextButtonM3E.sm({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  }) : size = ButtonSizeM3E.sm;

  /// Large button (48dp height)
  const TextButtonM3E.lg({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  }) : size = ButtonSizeM3E.lg;

  /// Extra large button (56dp height)
  const TextButtonM3E.xl({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  }) : size = ButtonSizeM3E.xl;

  ButtonStyle _getStyleForSize(BuildContext context) {
    final spec = ButtonSizeSpec.forSize(size);
    final theme = Theme.of(context);

    return TextButton.styleFrom(
      minimumSize: Size(0, spec.height),  // Min width 0, min height from spec
      padding: spec.padding,
      textStyle: theme.textTheme.labelLarge?.copyWith(
        fontSize: spec.fontSize,
      ),
      iconSize: spec.iconSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _getStyleForSize(context);

    if (icon != null) {
      return TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: child,
        style: style,
      );
    }
    return TextButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );
  }
}

/// M3E Elevated Button
///
/// Supports 5 size variants: XS, SM, MD (default), LG, XL
class ElevatedButtonM3E extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;
  final ButtonSizeM3E size;

  const ElevatedButtonM3E({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
    this.size = ButtonSizeM3E.md,
  });

  /// Extra small button (32dp height)
  const ElevatedButtonM3E.xs({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  }) : size = ButtonSizeM3E.xs;

  /// Small button (36dp height)
  const ElevatedButtonM3E.sm({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  }) : size = ButtonSizeM3E.sm;

  /// Large button (48dp height)
  const ElevatedButtonM3E.lg({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  }) : size = ButtonSizeM3E.lg;

  /// Extra large button (56dp height)
  const ElevatedButtonM3E.xl({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  }) : size = ButtonSizeM3E.xl;

  ButtonStyle _getStyleForSize(BuildContext context) {
    final spec = ButtonSizeSpec.forSize(size);
    final theme = Theme.of(context);

    return ElevatedButton.styleFrom(
      minimumSize: Size(0, spec.height),  // Min width 0, min height from spec
      padding: spec.padding,
      textStyle: theme.textTheme.labelLarge?.copyWith(
        fontSize: spec.fontSize,
      ),
      iconSize: spec.iconSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _getStyleForSize(context);

    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: child,
        style: style,
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );
  }
}

/// M3E Tonal Button (Filled tonal variant)
///
/// Supports 5 size variants: XS, SM, MD (default), LG, XL
class FilledTonalButtonM3E extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;
  final ButtonSizeM3E size;

  const FilledTonalButtonM3E({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
    this.size = ButtonSizeM3E.md,
  });

  /// Extra small button (32dp height)
  const FilledTonalButtonM3E.xs({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  }) : size = ButtonSizeM3E.xs;

  /// Small button (36dp height)
  const FilledTonalButtonM3E.sm({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  }) : size = ButtonSizeM3E.sm;

  /// Large button (48dp height)
  const FilledTonalButtonM3E.lg({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  }) : size = ButtonSizeM3E.lg;

  /// Extra large button (56dp height)
  const FilledTonalButtonM3E.xl({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  }) : size = ButtonSizeM3E.xl;

  ButtonStyle _getStyleForSize(BuildContext context) {
    final spec = ButtonSizeSpec.forSize(size);
    final theme = Theme.of(context);

    return FilledButton.styleFrom(
      minimumSize: Size(0, spec.height),  // Min width 0, min height from spec
      padding: spec.padding,
      textStyle: theme.textTheme.labelLarge?.copyWith(
        fontSize: spec.fontSize,
      ),
      iconSize: spec.iconSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _getStyleForSize(context);

    if (icon != null) {
      return FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: child,
        style: style,
      );
    }
    return FilledButton.tonal(
      onPressed: onPressed,
      style: style,
      child: child,
    );
  }
}

/// M3E Icon Button
///
/// Supports 5 size variants: XS, SM, MD (default), LG, XL
///
/// Note: Icon buttons are square, so size affects both width and height
class IconButtonM3E extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final bool filled;
  final bool tonal;
  final bool outlined;
  final ButtonSizeM3E size;

  const IconButtonM3E({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.filled = false,
    this.tonal = false,
    this.outlined = false,
    this.size = ButtonSizeM3E.md,
  });

  /// Extra small icon button (32x32dp)
  const IconButtonM3E.xs({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.filled = false,
    this.tonal = false,
    this.outlined = false,
  }) : size = ButtonSizeM3E.xs;

  /// Small icon button (36x36dp)
  const IconButtonM3E.sm({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.filled = false,
    this.tonal = false,
    this.outlined = false,
  }) : size = ButtonSizeM3E.sm;

  /// Large icon button (48x48dp)
  const IconButtonM3E.lg({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.filled = false,
    this.tonal = false,
    this.outlined = false,
  }) : size = ButtonSizeM3E.lg;

  /// Extra large icon button (56x56dp)
  const IconButtonM3E.xl({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.filled = false,
    this.tonal = false,
    this.outlined = false,
  }) : size = ButtonSizeM3E.xl;

  ButtonStyle _getStyleForSize() {
    final spec = ButtonSizeSpec.forSize(size);

    return IconButton.styleFrom(
      minimumSize: Size.square(spec.height),
      iconSize: spec.iconSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _getStyleForSize();

    final button = filled
        ? IconButton.filled(
            onPressed: onPressed,
            icon: Icon(icon),
            style: style,
          )
        : tonal
            ? IconButton.filledTonal(
                onPressed: onPressed,
                icon: Icon(icon),
                style: style,
              )
            : outlined
                ? IconButton.outlined(
                    onPressed: onPressed,
                    icon: Icon(icon),
                    style: style,
                  )
                : IconButton(
                    onPressed: onPressed,
                    icon: Icon(icon),
                    style: style,
                  );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

// Note: FABM3E is now defined in fab_m3e.dart with full M3E support
// including 5 size variants (XS, SM, MD, LG, XL) and expressive animations.

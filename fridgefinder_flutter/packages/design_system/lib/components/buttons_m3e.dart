import 'package:flutter/material.dart';

/// M3E Button Variants
///
/// Flutter's built-in button widgets already follow M3 design.
/// These are convenience wrappers with consistent styling.

/// M3E Filled Button (Primary action)
class FilledButtonM3E extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;

  const FilledButtonM3E({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: child,
      );
    }
    return FilledButton(
      onPressed: onPressed,
      child: child,
    );
  }
}

/// M3E Outlined Button (Secondary action)
class OutlinedButtonM3E extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;

  const OutlinedButtonM3E({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: child,
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      child: child,
    );
  }
}

/// M3E Text Button (Tertiary action)
class TextButtonM3E extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;

  const TextButtonM3E({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: child,
      );
    }
    return TextButton(
      onPressed: onPressed,
      child: child,
    );
  }
}

/// M3E Elevated Button
class ElevatedButtonM3E extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;

  const ElevatedButtonM3E({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: child,
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      child: child,
    );
  }
}

/// M3E Tonal Button (Filled tonal variant)
class FilledTonalButtonM3E extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;

  const FilledTonalButtonM3E({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: child,
      );
    }
    return FilledButton.tonal(
      onPressed: onPressed,
      child: child,
    );
  }
}

/// M3E Icon Button
class IconButtonM3E extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final bool filled;
  final bool tonal;
  final bool outlined;

  const IconButtonM3E({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.filled = false,
    this.tonal = false,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = filled
        ? IconButton.filled(
            onPressed: onPressed,
            icon: Icon(icon),
          )
        : tonal
            ? IconButton.filledTonal(
                onPressed: onPressed,
                icon: Icon(icon),
              )
            : outlined
                ? IconButton.outlined(
                    onPressed: onPressed,
                    icon: Icon(icon),
                  )
                : IconButton(
                    onPressed: onPressed,
                    icon: Icon(icon),
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

/// M3E FAB (Floating Action Button)
class FABM3E extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? label;
  final bool small;
  final bool large;

  const FABM3E({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.small = false,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label!),
      );
    }

    if (small) {
      return FloatingActionButton.small(
        onPressed: onPressed,
        child: Icon(icon),
      );
    }

    if (large) {
      return FloatingActionButton.large(
        onPressed: onPressed,
        child: Icon(icon),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      child: Icon(icon),
    );
  }
}

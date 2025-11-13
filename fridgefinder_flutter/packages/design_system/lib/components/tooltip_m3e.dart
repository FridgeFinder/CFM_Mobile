import 'package:flutter/material.dart';
import '../theme/motion.dart';
import '../theme/spacing.dart';
import '../theme/elevation.dart';
import '../theme/shapes.dart';

/// M3E Tooltip Component
///
/// Material 3 Expressive tooltip with rich content support and positioning.
///
/// Features:
/// - Plain and rich variants
/// - Multiple positioning options
/// - Fade entrance/exit animations
/// - Custom styling with M3E elevation
/// - Accessible by default
class TooltipM3E extends StatelessWidget {
  /// The message to display
  final String message;

  /// Rich content widget (overrides message if provided)
  final Widget? richContent;

  /// Tooltip position preference
  final TooltipPosition position;

  /// Whether to show arrow pointer
  final bool showArrow;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom text color
  final Color? textColor;

  /// Maximum width before wrapping
  final double? maxWidth;

  /// Padding around content
  final EdgeInsets? padding;

  /// Whether this is a rich tooltip variant
  final bool rich;

  const TooltipM3E({
    super.key,
    required this.message,
    this.richContent,
    this.position = TooltipPosition.below,
    this.showArrow = true,
    this.backgroundColor,
    this.textColor,
    this.maxWidth,
    this.padding,
    this.rich = false,
  });

  /// Show a plain tooltip
  static void showPlain(
    BuildContext context, {
    required String message,
    required Offset targetPosition,
    TooltipPosition position = TooltipPosition.below,
    Color? backgroundColor,
    Color? textColor,
  }) {
    _showTooltip(
      context,
      message: message,
      targetPosition: targetPosition,
      position: position,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }

  /// Show a rich tooltip with custom content
  static void showRich(
    BuildContext context, {
    required Widget content,
    required Offset targetPosition,
    TooltipPosition position = TooltipPosition.below,
    Color? backgroundColor,
    double? maxWidth,
  }) {
    _showTooltip(
      context,
      content: content,
      targetPosition: targetPosition,
      position: position,
      backgroundColor: backgroundColor,
      maxWidth: maxWidth,
      rich: true,
    );
  }

  static void _showTooltip(
    BuildContext context, {
    String? message,
    Widget? content,
    required Offset targetPosition,
    TooltipPosition position = TooltipPosition.below,
    Color? backgroundColor,
    Color? textColor,
    double? maxWidth,
    bool rich = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBackgroundColor =
        backgroundColor ?? colorScheme.inverseSurface;
    final effectiveTextColor =
        textColor ?? colorScheme.onInverseSurface;

    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      transitionDuration: M3EMotion.getDuration(M3EMotion.medium3),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _TooltipOverlay(
          message: message,
          content: content,
          targetPosition: targetPosition,
          position: position,
          backgroundColor: effectiveBackgroundColor,
          textColor: effectiveTextColor,
          maxWidth: maxWidth,
          rich: rich,
          animation: animation,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: M3EMotion.emphasizedDecelerate,
            reverseCurve: M3EMotion.emphasizedAccelerate,
          ),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // For inline usage, wrap child with Tooltip widget
    return Tooltip(
      message: message,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(M3EShapes.small),
        boxShadow: M3EElevation.getShadow(M3EElevation.level2),
      ),
      textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: textColor ?? Theme.of(context).colorScheme.onInverseSurface,
      ),
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: M3ESpacing.sm,
        vertical: M3ESpacing.xs,
      ),
      margin: const EdgeInsets.symmetric(horizontal: M3ESpacing.md),
      preferBelow: position == TooltipPosition.below,
      verticalOffset: M3ESpacing.xs,
      waitDuration: M3EMotion.medium3,
      showDuration: M3EMotion.long2,
    );
  }
}

/// Tooltip position options
enum TooltipPosition {
  above,
  below,
  left,
  right,
  auto,
}

/// Tooltip overlay widget
class _TooltipOverlay extends StatelessWidget {
  final String? message;
  final Widget? content;
  final Offset targetPosition;
  final TooltipPosition position;
  final Color backgroundColor;
  final Color textColor;
  final double? maxWidth;
  final bool rich;
  final Animation<double> animation;

  const _TooltipOverlay({
    required this.message,
    required this.content,
    required this.targetPosition,
    required this.position,
    required this.backgroundColor,
    required this.textColor,
    required this.maxWidth,
    required this.rich,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Calculate position
    Offset tooltipPosition = _calculatePosition(
      targetPosition,
      position,
      size,
    );

    return Stack(
      children: [
        // Invisible tap target to dismiss
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.transparent),
          ),
        ),
        // Tooltip content
        Positioned(
          left: tooltipPosition.dx,
          top: tooltipPosition.dy,
          child: FadeTransition(
            opacity: animation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: maxWidth != null
                    ? BoxConstraints(maxWidth: maxWidth!)
                    : null,
                padding: const EdgeInsets.symmetric(
                  horizontal: M3ESpacing.sm,
                  vertical: M3ESpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(M3EShapes.small),
                  boxShadow: M3EElevation.getShadow(M3EElevation.level2),
                ),
                child: rich && content != null
                    ? content
                    : Text(
                        message ?? '',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: textColor,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Offset _calculatePosition(
    Offset target,
    TooltipPosition position,
    Size screenSize,
  ) {
    const tooltipOffset = 8.0;
    const tooltipHeight = 32.0;
    const tooltipWidth = 100.0; // Approximate

    switch (position) {
      case TooltipPosition.above:
        return Offset(
          target.dx - tooltipWidth / 2,
          target.dy - tooltipHeight - tooltipOffset,
        );
      case TooltipPosition.below:
        return Offset(
          target.dx - tooltipWidth / 2,
          target.dy + tooltipOffset,
        );
      case TooltipPosition.left:
        return Offset(
          target.dx - tooltipWidth - tooltipOffset,
          target.dy - tooltipHeight / 2,
        );
      case TooltipPosition.right:
        return Offset(
          target.dx + tooltipOffset,
          target.dy - tooltipHeight / 2,
        );
      case TooltipPosition.auto:
        // Auto-position based on available space
        if (target.dy > screenSize.height / 2) {
          // Prefer above
          return Offset(
            target.dx - tooltipWidth / 2,
            target.dy - tooltipHeight - tooltipOffset,
          );
        } else {
          // Prefer below
          return Offset(
            target.dx - tooltipWidth / 2,
            target.dy + tooltipOffset,
          );
        }
    }
  }
}


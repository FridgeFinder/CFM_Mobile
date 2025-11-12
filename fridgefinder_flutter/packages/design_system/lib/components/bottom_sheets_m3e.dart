import 'package:flutter/material.dart';
import '../theme/spacing.dart';
import '../theme/shapes.dart';
import '../theme/motion.dart';

/// M3E Bottom Sheet
///
/// Utilities for showing bottom sheets with proper M3E styling.
class BottomSheetM3E {
  /// Show a modal bottom sheet
  static Future<T?> showModal<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor,
      shape: M3EShapes.bottomSheet,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: M3EMotionPatterns.bottomSheetFallback,
      ),
      builder: (context) => child,
    );
  }

  /// Show a modal bottom sheet with a drag handle
  static Future<T?> showModalWithHandle<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      shape: M3EShapes.bottomSheet,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DragHandleM3E(),
          Flexible(child: child),
        ],
      ),
    );
  }
}

/// M3E Drag Handle
///
/// A visual indicator for draggable bottom sheets.
class DragHandleM3E extends StatelessWidget {
  const DragHandleM3E({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(top: M3ESpacing.sm, bottom: M3ESpacing.xs),
      width: 32,
      height: 4,
      decoration: BoxDecoration(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// M3E Bottom Sheet Content Wrapper
///
/// Provides consistent padding for bottom sheet content.
class BottomSheetContentM3E extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const BottomSheetContentM3E({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? M3ESpacing.bottomSheetContentPadding,
      child: child,
    );
  }
}

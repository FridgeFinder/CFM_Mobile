import 'package:flutter/material.dart';
import '../theme/spacing.dart';
import '../theme/shapes.dart';

/// M3E Dialog
///
/// A dialog with proper M3E styling and animations.
class DialogM3E {
  /// Show a simple alert dialog
  static Future<bool?> showAlert({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'OK',
    String? cancelText,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Show a confirmation dialog
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDestructive
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Show a custom dialog
  static Future<T?> showCustom<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      builder: (context) => Dialog(
        shape: M3EShapes.dialog,
        child: child,
      ),
    );
  }
}

/// M3E Dialog Content Wrapper
///
/// Provides consistent padding and structure for dialog content.
class DialogContentM3E extends StatelessWidget {
  final String? title;
  final Widget content;
  final List<Widget>? actions;
  final Widget? icon;

  const DialogContentM3E({
    super.key,
    this.title,
    required this.content,
    this.actions,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: M3ESpacing.dialogPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Center(child: icon!),
            M3ESpacing.verticalMD,
          ],
          if (title != null) ...[
            Text(
              title!,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            M3ESpacing.verticalMD,
          ],
          content,
          if (actions != null && actions!.isNotEmpty) ...[
            M3ESpacing.verticalMD,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (int i = 0; i < actions!.length; i++) ...[
                  if (i > 0) M3ESpacing.horizontalXS,
                  actions![i],
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

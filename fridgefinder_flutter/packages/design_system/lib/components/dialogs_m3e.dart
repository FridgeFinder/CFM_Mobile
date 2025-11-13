import 'package:flutter/material.dart';
import '../theme/spacing.dart';
import '../theme/shapes.dart';
import '../theme/motion.dart';
import '../theme/elevation.dart';

/// M3E Dialog
///
/// A dialog with proper M3E styling and animations.
class DialogM3E {
  /// Show a simple alert dialog with M3E animations
  static Future<bool?> showAlert({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'OK',
    String? cancelText,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: M3EMotion.getDuration(M3EMotion.long2), // 500ms
      pageBuilder: (context, animation, secondaryAnimation) {
        return AlertDialog(
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
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return _DialogTransition(animation: animation, child: child);
      },
    );
  }

  /// Show a confirmation dialog with M3E animations
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: M3EMotion.getDuration(M3EMotion.long2), // 500ms
      pageBuilder: (context, animation, secondaryAnimation) {
        return AlertDialog(
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
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return _DialogTransition(animation: animation, child: child);
      },
    );
  }

  /// Show a custom dialog with M3E animations
  static Future<T?> showCustom<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel ?? MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: barrierColor ?? Colors.black54,
      transitionDuration: M3EMotion.getDuration(M3EMotion.long2), // 500ms
      pageBuilder: (context, animation, secondaryAnimation) {
        return Dialog(
          shape: M3EShapes.dialog,
          child: child,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return _DialogTransition(animation: animation, child: child);
      },
    );
  }
}

/// M3E Dialog Transition with scale spring and content stagger
///
/// Features:
/// - Scale spring animation (0.8 → 1.0 with overshoot)
/// - Fade scrim (0 → 0.54 opacity)
/// - Content stagger (title → content → actions)
class _DialogTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _DialogTransition({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Scrim fade (0-30% of animation)
    final scrimAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );

    // Dialog scale with spring (0-100%)
    final scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: M3EMotion.expressiveDefaultOvershoot,
    ));

    // Content fade (30-100% of animation)
    final contentFadeAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    );

    return Stack(
      children: [
        // Scrim backdrop
        FadeTransition(
          opacity: scrimAnimation,
          child: Container(
            color: Colors.black54,
          ),
        ),
        // Dialog with scale animation
        Center(
          child: FadeTransition(
            opacity: contentFadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: Material(
                elevation: M3EElevation.dialog,
                shape: M3EShapes.dialog,
                color: Colors.transparent,
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// M3E Dialog Content Wrapper with staggered animations
///
/// Provides consistent padding and structure for dialog content.
/// Content elements fade in with stagger (icon → title → content → actions).
class DialogContentM3E extends StatefulWidget {
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
  State<DialogContentM3E> createState() => _DialogContentM3EState();
}

class _DialogContentM3EState extends State<DialogContentM3E>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _contentAnimation;
  late Animation<double> _actionsAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.long2), // 500ms
      vsync: this,
    );

    // Staggered animations
    _iconAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.2, curve: M3EMotion.emphasizedDecelerate),
    );
    _titleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.4, curve: M3EMotion.emphasizedDecelerate),
    );
    _contentAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.6, curve: M3EMotion.emphasizedDecelerate),
    );
    _actionsAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: M3EMotion.emphasizedDecelerate),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: M3ESpacing.dialogPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.icon != null) ...[
            FadeTransition(
              opacity: _iconAnimation,
              child: ScaleTransition(
                scale: _iconAnimation,
                child: Center(child: widget.icon!),
              ),
            ),
            M3ESpacing.verticalMD,
          ],
          if (widget.title != null) ...[
            FadeTransition(
              opacity: _titleAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.1),
                  end: Offset.zero,
                ).animate(_titleAnimation),
                child: Text(
                  widget.title!,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            M3ESpacing.verticalMD,
          ],
          FadeTransition(
            opacity: _contentAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.05),
                end: Offset.zero,
              ).animate(_contentAnimation),
              child: widget.content,
            ),
          ),
          if (widget.actions != null && widget.actions!.isNotEmpty) ...[
            M3ESpacing.verticalMD,
            FadeTransition(
              opacity: _actionsAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(_actionsAnimation),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (int i = 0; i < widget.actions!.length; i++) ...[
                      if (i > 0) M3ESpacing.horizontalXS,
                      widget.actions![i],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

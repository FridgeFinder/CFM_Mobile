import 'package:flutter/material.dart';
import '../theme/motion.dart';
import '../theme/spacing.dart';
import '../theme/elevation.dart';

/// M3E Banner Component
///
/// Material 3 Expressive banner with slide animation and dismiss functionality.
///
/// Features:
/// - Single-line and multi-line variants
/// - Slide-in animation from top
/// - Dismiss with swipe gesture
/// - Action buttons support
/// - Customizable colors and icons
class BannerM3E extends StatefulWidget {
  /// Banner content text
  final String message;

  /// Optional leading icon
  final Widget? leadingIcon;

  /// Optional leading icon color
  final Color? leadingIconColor;

  /// Action buttons
  final List<BannerAction>? actions;

  /// Background color
  final Color? backgroundColor;

  /// Text color
  final Color? textColor;

  /// Whether banner is dismissible
  final bool dismissible;

  /// Callback when banner is dismissed
  final VoidCallback? onDismissed;

  /// Content padding
  final EdgeInsets? contentPadding;

  /// Whether to show as multi-line (wraps text)
  final bool multiLine;

  const BannerM3E({
    super.key,
    required this.message,
    this.leadingIcon,
    this.leadingIconColor,
    this.actions,
    this.backgroundColor,
    this.textColor,
    this.dismissible = true,
    this.onDismissed,
    this.contentPadding,
    this.multiLine = false,
  });

  /// Show a banner as a dialog overlay
  static void show(
    BuildContext context, {
    required String message,
    Widget? leadingIcon,
    Color? leadingIconColor,
    List<BannerAction>? actions,
    Color? backgroundColor,
    Color? textColor,
    bool dismissible = true,
    VoidCallback? onDismissed,
    bool multiLine = false,
  }) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: dismissible,
      transitionDuration: M3EMotion.getDuration(M3EMotion.medium4),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _BannerOverlay(
          message: message,
          leadingIcon: leadingIcon,
          leadingIconColor: leadingIconColor,
          actions: actions,
          backgroundColor: backgroundColor,
          textColor: textColor,
          dismissible: dismissible,
          onDismissed: onDismissed,
          multiLine: multiLine,
          animation: animation,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: M3EMotion.expressiveDefaultOvershoot,
            reverseCurve: M3EMotion.emphasizedAccelerate,
          )),
          child: child,
        );
      },
    );
  }

  @override
  State<BannerM3E> createState() => _BannerM3EState();
}

class _BannerM3EState extends State<BannerM3E> {
  bool _isDismissed = false;

  void _handleDismiss() {
    if (widget.dismissible) {
      setState(() {
        _isDismissed = true;
      });
      widget.onDismissed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = widget.backgroundColor ?? colorScheme.surfaceContainerHighest;
    final textColor = widget.textColor ?? colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: widget.contentPadding ?? const EdgeInsets.symmetric(
        horizontal: M3ESpacing.md,
        vertical: M3ESpacing.sm,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: M3EElevation.getShadow(M3EElevation.level1),
      ),
      child: Row(
        crossAxisAlignment: widget.multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          // Leading icon
          if (widget.leadingIcon != null) ...[
            IconTheme(
              data: IconThemeData(
                color: widget.leadingIconColor ?? textColor,
                size: 24,
              ),
              child: widget.leadingIcon!,
            ),
            const SizedBox(width: M3ESpacing.sm),
          ],
          // Message
          Expanded(
            child: Text(
              widget.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor,
              ),
              maxLines: widget.multiLine ? null : 1,
              overflow: widget.multiLine ? null : TextOverflow.ellipsis,
            ),
          ),
          // Actions
          if (widget.actions != null && widget.actions!.isNotEmpty) ...[
            const SizedBox(width: M3ESpacing.sm),
            ...widget.actions!.map((action) => Padding(
              padding: const EdgeInsets.only(left: M3ESpacing.xs),
              child: TextButton(
                onPressed: () {
                  action.onPressed();
                  if (action.dismissOnAction) {
                    _handleDismiss();
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: textColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: M3ESpacing.sm,
                    vertical: M3ESpacing.xs,
                  ),
                ),
                child: Text(action.label),
              ),
            )),
          ],
          // Dismiss button
          if (widget.dismissible) ...[
            const SizedBox(width: M3ESpacing.xs),
            IconButton(
              icon: const Icon(Icons.close),
              iconSize: 20,
              color: textColor,
              onPressed: _handleDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Banner action button
class BannerAction {
  final String label;
  final VoidCallback onPressed;
  final bool dismissOnAction;

  const BannerAction({
    required this.label,
    required this.onPressed,
    this.dismissOnAction = false,
  });
}

/// Banner overlay widget
class _BannerOverlay extends StatelessWidget {
  final String message;
  final Widget? leadingIcon;
  final Color? leadingIconColor;
  final List<BannerAction>? actions;
  final Color? backgroundColor;
  final Color? textColor;
  final bool dismissible;
  final VoidCallback? onDismissed;
  final bool multiLine;
  final Animation<double> animation;

  const _BannerOverlay({
    required this.message,
    required this.leadingIcon,
    required this.leadingIconColor,
    required this.actions,
    required this.backgroundColor,
    required this.textColor,
    required this.dismissible,
    required this.onDismissed,
    required this.multiLine,
    required this.animation,
  });

  void _handleDismiss(BuildContext context) {
    Navigator.of(context).pop();
    onDismissed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: M3EMotion.expressiveDefaultOvershoot,
          )),
          child: BannerM3E(
            message: message,
            leadingIcon: leadingIcon,
            leadingIconColor: leadingIconColor,
            actions: actions,
            backgroundColor: backgroundColor,
            textColor: textColor,
            dismissible: dismissible,
            onDismissed: () => _handleDismiss(context),
            multiLine: multiLine,
          ),
        ),
      ),
    );
  }
}


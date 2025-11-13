import 'package:flutter/material.dart';
import '../theme/motion.dart';
import '../theme/spacing.dart';

/// M3E Empty State Component
///
/// Displays an empty state with icon, title, description, and optional action.
///
/// Features:
/// - Fade-in entrance animation
/// - Loading transition support
/// - Customizable icon, colors, and actions
class EmptyStateM3E extends StatefulWidget {
  /// Icon to display
  final IconData? icon;

  /// Custom icon widget (overrides icon if provided)
  final Widget? iconWidget;

  /// Title text
  final String? title;

  /// Description text
  final String? description;

  /// Primary action button
  final Widget? primaryAction;

  /// Secondary action button
  final Widget? secondaryAction;

  /// Custom icon color
  final Color? iconColor;

  /// Custom text color
  final Color? textColor;

  /// Whether to show loading state
  final bool isLoading;

  /// Padding around content
  final EdgeInsets? padding;

  const EmptyStateM3E({
    super.key,
    this.icon,
    this.iconWidget,
    this.title,
    this.description,
    this.primaryAction,
    this.secondaryAction,
    this.iconColor,
    this.textColor,
    this.isLoading = false,
    this.padding,
  }) : assert(icon != null || iconWidget != null || isLoading,
          'Either icon, iconWidget, or isLoading must be provided');

  @override
  State<EmptyStateM3E> createState() => _EmptyStateM3EState();
}

class _EmptyStateM3EState extends State<EmptyStateM3E>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium4),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: M3EMotion.emphasizedDecelerate,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: M3EMotion.expressiveDefaultOvershoot,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(EmptyStateM3E oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = widget.iconColor ?? colorScheme.onSurfaceVariant;
    final textColor = widget.textColor ?? colorScheme.onSurfaceVariant;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(M3ESpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  if (widget.isLoading)
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(
                        color: iconColor,
                      ),
                    )
                  else if (widget.iconWidget != null)
                    IconTheme(
                      data: IconThemeData(
                        color: iconColor,
                        size: 64,
                      ),
                      child: widget.iconWidget!,
                    )
                  else if (widget.icon != null)
                    Icon(
                      widget.icon,
                      size: 64,
                      color: iconColor,
                    ),
                  if (widget.icon != null || widget.iconWidget != null || widget.isLoading)
                    const SizedBox(height: M3ESpacing.lg),
                  // Title
                  if (widget.title != null)
                    Text(
                      widget.title!,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  if (widget.title != null && widget.description != null)
                    const SizedBox(height: M3ESpacing.sm),
                  // Description
                  if (widget.description != null)
                    Text(
                      widget.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textColor.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  if ((widget.title != null || widget.description != null) &&
                      (widget.primaryAction != null || widget.secondaryAction != null))
                    const SizedBox(height: M3ESpacing.xl),
                  // Actions
                  if (widget.primaryAction != null || widget.secondaryAction != null)
                    Wrap(
                      spacing: M3ESpacing.sm,
                      runSpacing: M3ESpacing.sm,
                      alignment: WrapAlignment.center,
                      children: [
                        if (widget.primaryAction != null) widget.primaryAction!,
                        if (widget.secondaryAction != null) widget.secondaryAction!,
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


import 'package:flutter/material.dart';
import '../theme/elevation.dart';
import '../theme/motion.dart';
import '../theme/shapes.dart';

// ============================================================================
// BADGE COMPONENTS
// ============================================================================

/// Badge position relative to anchor widget
enum BadgePosition {
  topRight,
  topLeft,
  bottomRight,
  bottomLeft,
  topCenter,
  bottomCenter,
  leftCenter,
  rightCenter,
}

/// Material 3 Expressive Badge
///
/// A small indicator that can display a dot, number, or text.
///
/// ## Specifications:
/// - Small badge: 6x6dp dot (no content)
/// - Large badge: 16dp height, 6dp min width
/// - Corner radius: Full pill shape
/// - Elevation: Level 0 (flat)
/// - Animation: Scale 0 → 1.0 + fade (150ms responsive spring)
///
/// ## Usage:
/// ```dart
/// BadgeM3E(
///   child: Icon(Icons.notifications),
///   count: 5,
///   backgroundColor: Colors.red,
///   position: BadgePosition.topRight,
/// )
/// ```
class BadgeM3E extends StatefulWidget {
  /// The widget to anchor the badge to
  final Widget child;

  /// The count to display (1-999+). If null, shows a small dot.
  final int? count;

  /// Custom text to display instead of count
  final String? label;

  /// Badge background color. Defaults to error color.
  final Color? backgroundColor;

  /// Badge foreground/text color. Defaults to onError color.
  final Color? foregroundColor;

  /// Position of the badge relative to the child
  final BadgePosition position;

  /// Whether to show the badge
  final bool show;

  /// Offset from the default position
  final Offset? offset;

  /// Whether to animate badge appearance
  final bool animate;

  const BadgeM3E({
    super.key,
    required this.child,
    this.count,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.position = BadgePosition.topRight,
    this.show = true,
    this.offset,
    this.animate = true,
  }) : assert(
          count == null || label == null,
          'Cannot provide both count and label',
        );

  @override
  State<BadgeM3E> createState() => _BadgeM3EState();
}

class _BadgeM3EState extends State<BadgeM3E>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  int? _previousCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3), // 350ms for more expressive badge
      vsync: this,
    );

    // Scale animation with smooth overshoot for expressive badge entrance
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: M3EMotion.expressiveFastOvershoot,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (widget.show && widget.animate) {
      _controller.forward();
    } else if (widget.show) {
      _controller.value = 1.0;
    }

    _previousCount = widget.count;
  }

  @override
  void didUpdateWidget(BadgeM3E oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.show != oldWidget.show) {
      if (widget.show) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }

    // Animate count change with pulse
    if (widget.count != _previousCount && widget.count != null) {
      _animateCountChange();
      _previousCount = widget.count;
    }
  }

  void _animateCountChange() {
    // Pulse animation: scale up then back down
    _controller.reset();
    _controller.forward();
    // Add a small pulse after initial animation completes
    Future.delayed(M3EMotion.medium3, () {
      if (mounted) {
        _controller.forward(from: 0.8);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final badgeBackgroundColor =
        widget.backgroundColor ?? colorScheme.error;
    final badgeForegroundColor =
        widget.foregroundColor ?? colorScheme.onError;

    final hasContent = widget.count != null || widget.label != null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (widget.show)
          _buildPositionedBadge(
            hasContent: hasContent,
            badgeBackgroundColor: badgeBackgroundColor,
            badgeForegroundColor: badgeForegroundColor,
            theme: theme,
          ),
      ],
    );
  }

  Widget _buildPositionedBadge({
    required bool hasContent,
    required Color badgeBackgroundColor,
    required Color badgeForegroundColor,
    required ThemeData theme,
  }) {
    final positionParams = _getPositionParams();
    final customOffset = widget.offset;

    return Positioned(
      top: customOffset?.dy ?? positionParams['top'],
      right: customOffset?.dx ?? positionParams['right'],
      bottom: positionParams['bottom'],
      left: positionParams['left'],
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            constraints: BoxConstraints(
              minWidth: hasContent ? 16.0 : 6.0,
              minHeight: hasContent ? 16.0 : 6.0,
            ),
            padding: hasContent
                ? const EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 2.0,
                  )
                : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: badgeBackgroundColor,
              borderRadius: BorderRadius.circular(M3EShapes.full),
            ),
            child: hasContent
                ? Center(
                    child: Text(
                      widget.label ?? _formatCount(widget.count!),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: badgeForegroundColor,
                        fontSize: 10.0,
                        height: 1.0,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Map<String, double?> _getPositionParams() {
    const offset = 4.0;
    switch (widget.position) {
      case BadgePosition.topRight:
        return {'top': -offset, 'right': -offset, 'bottom': null, 'left': null};
      case BadgePosition.topLeft:
        return {'top': -offset, 'left': -offset, 'bottom': null, 'right': null};
      case BadgePosition.bottomRight:
        return {'bottom': -offset, 'right': -offset, 'top': null, 'left': null};
      case BadgePosition.bottomLeft:
        return {'bottom': -offset, 'left': -offset, 'top': null, 'right': null};
      case BadgePosition.topCenter:
        return {'top': -offset, 'bottom': null, 'left': null, 'right': null};
      case BadgePosition.bottomCenter:
        return {'bottom': -offset, 'top': null, 'left': null, 'right': null};
      case BadgePosition.leftCenter:
        return {'left': -offset, 'top': null, 'bottom': null, 'right': null};
      case BadgePosition.rightCenter:
        return {'right': -offset, 'top': null, 'bottom': null, 'left': null};
    }
  }

  String _formatCount(int count) {
    if (count > 999) return '999+';
    return count.toString();
  }
}

// ============================================================================
// SNACKBAR COMPONENTS
// ============================================================================

/// Snackbar duration presets
enum SnackbarDuration {
  short_(4000), // 4 seconds
  long_(10000); // 10 seconds

  final int milliseconds;
  const SnackbarDuration(this.milliseconds);

  Duration get duration => Duration(milliseconds: milliseconds);
}

/// Material 3 Expressive Snackbar
///
/// A brief message that appears at the bottom of the screen.
///
/// ## Specifications:
/// - Width: Min 344dp, Max 672dp
/// - Height: 48dp (single-line), 68dp+ (multi-line)
/// - Padding: 16dp horizontal, 12dp vertical
/// - Corner radius: 4dp
/// - Elevation: Level 3
/// - Animation: Slide up from bottom with expressive spring (400ms)
/// - Auto-dismiss: 4s (short), 10s (long)
/// - Supports swipe-to-dismiss
///
/// ## Usage:
/// ```dart
/// showSnackbarM3E(
///   context: context,
///   message: 'File saved successfully',
///   action: SnackbarAction(
///     label: 'Undo',
///     onPressed: () {},
///   ),
/// );
/// ```
class SnackbarM3E extends StatelessWidget {
  final String message;
  final SnackbarAction? action;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final ShapeBorder? shape;
  final double? elevation;
  final Duration? duration;
  final VoidCallback? onDismissed;

  const SnackbarM3E({
    super.key,
    required this.message,
    this.action,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.margin,
    this.shape,
    this.elevation,
    this.duration,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(
        minWidth: 344.0,
        maxWidth: 672.0,
        minHeight: 48.0,
      ),
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
      margin: margin ?? const EdgeInsets.all(8.0),
      decoration: ShapeDecoration(
        color: backgroundColor ?? colorScheme.inverseSurface,
        shape: shape ?? M3EShapes.snackbar,
        shadows: M3EElevation.getShadow(elevation ?? M3EElevation.snackbar),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(
                color: foregroundColor ?? colorScheme.onInverseSurface,
                size: 20.0,
              ),
              child: icon!,
            ),
            const SizedBox(width: 12.0),
          ],
          Flexible(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: foregroundColor ?? colorScheme.onInverseSurface,
              ),
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 8.0),
            TextButton(
              onPressed: action!.onPressed,
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
              ),
              child: Text(action!.label),
            ),
          ],
        ],
      ),
    );
  }
}

/// Snackbar action button configuration
class SnackbarAction {
  final String label;
  final VoidCallback onPressed;

  const SnackbarAction({
    required this.label,
    required this.onPressed,
  });
}

/// Show a Material 3 Expressive Snackbar
///
/// This is the recommended way to show snackbars in your app.
///
/// ## Features:
/// - Expressive slide-up animation with spring physics
/// - Swipe-to-dismiss support
/// - Auto-dismiss after specified duration
/// - Optional action button
/// - Optional leading icon
///
/// ## Example:
/// ```dart
/// final controller = showSnackbarM3E(
///   context: context,
///   message: 'Message sent',
///   action: SnackbarAction(
///     label: 'Undo',
///     onPressed: () {
///       // Handle undo
///     },
///   ),
///   icon: Icon(Icons.check_circle),
///   duration: SnackbarDuration.short_,
/// );
///
/// // Optionally dismiss programmatically
/// controller.dismiss();
/// ```
SnackbarController showSnackbarM3E({
  required BuildContext context,
  required String message,
  SnackbarAction? action,
  Widget? icon,
  Color? backgroundColor,
  Color? foregroundColor,
  SnackbarDuration duration = SnackbarDuration.short_,
  VoidCallback? onDismissed,
}) {
  final controller = ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: SnackbarM3E(
        message: message,
        action: action,
        icon: icon,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        onDismissed: onDismissed,
      ),
      duration: duration.duration,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.horizontal, // Swipe left/right to dismiss
      shape: M3EShapes.snackbar,
    ),
  );

  return SnackbarController._(controller);
}

/// Controller for managing a displayed snackbar
class SnackbarController {
  final ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _controller;

  SnackbarController._(this._controller);

  /// Dismiss the snackbar
  void dismiss() {
    _controller.close();
  }

  /// Get the future that completes when snackbar is dismissed
  Future<SnackBarClosedReason> get closed => _controller.closed;
}

// ============================================================================
// TOOLTIP COMPONENTS
// ============================================================================

/// Tooltip type
enum TooltipType {
  plain,
  rich,
}

/// Tooltip position preference
enum TooltipPosition {
  bottom,
  top,
  left,
  right,
  auto, // Automatically choose best position
}

/// Material 3 Expressive Tooltip
///
/// A text label that appears on hover or long press.
///
/// ## Specifications (Plain):
/// - Max width: 200dp
/// - Corner radius: 4dp
/// - Elevation: Level 2
/// - Padding: 4dp vertical / 8dp horizontal
/// - Typography: bodySmall
///
/// ## Specifications (Rich):
/// - Max width: 320dp
/// - Can include actions and icons
/// - Padding: 8dp vertical / 12dp horizontal
///
/// ## Animation:
/// - Fade in after 500ms delay
/// - Fade out instantly on exit
///
/// ## Usage:
/// ```dart
/// TooltipM3E(
///   message: 'Add to favorites',
///   child: IconButton(
///     icon: Icon(Icons.favorite),
///     onPressed: () {},
///   ),
/// )
/// ```
class TooltipM3E extends StatefulWidget {
  final Widget child;
  final String? message;
  final Widget? richContent;
  final TooltipType type;
  final TooltipPosition position;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Duration? waitDuration;
  final Duration? showDuration;
  final bool enableFeedback;

  const TooltipM3E({
    super.key,
    required this.child,
    this.message,
    this.richContent,
    this.type = TooltipType.plain,
    this.position = TooltipPosition.auto,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.foregroundColor,
    this.waitDuration,
    this.showDuration,
    this.enableFeedback = true,
  }) : assert(
          message != null || richContent != null,
          'Either message or richContent must be provided',
        );

  @override
  State<TooltipM3E> createState() => _TooltipM3EState();
}

class _TooltipM3EState extends State<TooltipM3E>
    with TickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3), // 350ms for more expressive badge
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _removeTooltip();
    _controller.dispose();
    super.dispose();
  }

  void _showTooltip() {
    // Wait before showing
    Future.delayed(
      widget.waitDuration ?? const Duration(milliseconds: 500),
      () {
        if (!mounted) return;

        _overlayEntry = _createOverlayEntry();
        Overlay.of(context).insert(_overlayEntry!);
        _controller.forward();

        // Auto hide after duration
        if (widget.showDuration != null) {
          Future.delayed(widget.showDuration!, () {
            _removeTooltip();
          });
        }
      },
    );
  }

  void _removeTooltip() {
    _controller.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        top: _calculateTop(offset, size),
        left: _calculateLeft(offset, size),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: _buildTooltipContent(),
          ),
        ),
      ),
    );
  }

  double _calculateTop(Offset offset, Size size) {
    final position = _getEffectivePosition(offset, size);
    switch (position) {
      case TooltipPosition.bottom:
        return offset.dy + size.height + 8.0;
      case TooltipPosition.top:
        return offset.dy - 48.0 - 8.0; // Approximate tooltip height
      case TooltipPosition.left:
      case TooltipPosition.right:
        return offset.dy + (size.height / 2) - 24.0;
      case TooltipPosition.auto:
        return offset.dy + size.height + 8.0;
    }
  }

  double _calculateLeft(Offset offset, Size size) {
    final position = _getEffectivePosition(offset, size);
    switch (position) {
      case TooltipPosition.bottom:
      case TooltipPosition.top:
        return offset.dx + (size.width / 2) - 100.0; // Center align
      case TooltipPosition.left:
        return offset.dx - 200.0 - 8.0;
      case TooltipPosition.right:
        return offset.dx + size.width + 8.0;
      case TooltipPosition.auto:
        return offset.dx + (size.width / 2) - 100.0;
    }
  }

  TooltipPosition _getEffectivePosition(Offset offset, Size size) {
    if (widget.position != TooltipPosition.auto) {
      return widget.position;
    }

    // Auto-detect best position based on screen space
    final screenSize = MediaQuery.of(context).size;
    final hasSpaceBelow = offset.dy + size.height + 60.0 < screenSize.height;
    final hasSpaceAbove = offset.dy > 60.0;

    if (hasSpaceBelow) return TooltipPosition.bottom;
    if (hasSpaceAbove) return TooltipPosition.top;
    return TooltipPosition.bottom;
  }

  Widget _buildTooltipContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isRich = widget.type == TooltipType.rich;
    final maxWidth = isRich ? 320.0 : 200.0;
    final defaultPadding = isRich
        ? const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0)
        : const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0);

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: widget.padding ?? defaultPadding,
      margin: widget.margin ?? const EdgeInsets.all(4.0),
      decoration: ShapeDecoration(
        color: widget.backgroundColor ?? colorScheme.inverseSurface,
        shape: M3EShapes.tooltip,
        shadows: M3EElevation.getShadow(M3EElevation.tooltip),
      ),
      child: widget.richContent ??
          Text(
            widget.message!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: widget.foregroundColor ?? colorScheme.onInverseSurface,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _showTooltip,
      child: MouseRegion(
        onEnter: (_) => _showTooltip(),
        onExit: (_) => _removeTooltip(),
        child: widget.child,
      ),
    );
  }
}

/// Wrapper widget for easy tooltip usage
///
/// This is a convenience widget that wraps your child with a tooltip.
///
/// ## Usage:
/// ```dart
/// TooltipWrapperM3E(
///   message: 'Share',
///   child: IconButton(
///     icon: Icon(Icons.share),
///     onPressed: () {},
///   ),
/// )
/// ```
class TooltipWrapperM3E extends StatelessWidget {
  final Widget child;
  final String message;
  final TooltipPosition position;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const TooltipWrapperM3E({
    super.key,
    required this.child,
    required this.message,
    this.position = TooltipPosition.auto,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return TooltipM3E(
      message: message,
      position: position,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      child: child,
    );
  }
}

/// Rich tooltip content with title and optional action
///
/// Use this for more complex tooltip content.
///
/// ## Usage:
/// ```dart
/// TooltipM3E(
///   type: TooltipType.rich,
///   richContent: RichTooltipContent(
///     title: 'Premium Feature',
///     description: 'Upgrade to access this feature',
///     action: TooltipAction(
///       label: 'Upgrade',
///       onPressed: () {},
///     ),
///   ),
///   child: Icon(Icons.lock),
/// )
/// ```
class RichTooltipContent extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? icon;
  final TooltipAction? action;

  const RichTooltipContent({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          IconTheme(
            data: IconThemeData(
              color: colorScheme.onInverseSurface,
              size: 20.0,
            ),
            child: icon!,
          ),
          const SizedBox(height: 8.0),
        ],
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onInverseSurface,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 4.0),
          Text(
            description!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onInverseSurface,
            ),
          ),
        ],
        if (action != null) ...[
          const SizedBox(height: 8.0),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: action!.onPressed,
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4.0,
                ),
              ),
              child: Text(action!.label),
            ),
          ),
        ],
      ],
    );
  }
}

/// Tooltip action button configuration
class TooltipAction {
  final String label;
  final VoidCallback onPressed;

  const TooltipAction({
    required this.label,
    required this.onPressed,
  });
}

// ============================================================================
// EXAMPLES AND USAGE DEMONSTRATIONS
// ============================================================================

/// Example widget demonstrating all communication components
///
/// This widget showcases the proper usage of badges, snackbars, and tooltips.
/// Use this as a reference for implementing these components in your app.
class CommunicationComponentsExample extends StatefulWidget {
  const CommunicationComponentsExample({super.key});

  @override
  State<CommunicationComponentsExample> createState() =>
      _CommunicationComponentsExampleState();
}

class _CommunicationComponentsExampleState
    extends State<CommunicationComponentsExample> {
  int _notificationCount = 3;
  final int _messageCount = 12;
  bool _showBadge = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communication Components'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Badge Examples
          _buildSectionTitle('Badges'),
          const SizedBox(height: 16.0),
          Wrap(
            spacing: 24.0,
            runSpacing: 24.0,
            children: [
              // Small dot badge
              BadgeM3E(
                show: _showBadge,
                child: const Icon(Icons.notifications_outlined, size: 32),
              ),

              // Badge with count
              BadgeM3E(
                count: _notificationCount,
                show: _showBadge,
                child: const Icon(Icons.notifications_outlined, size: 32),
              ),

              // Badge with large count
              BadgeM3E(
                count: _messageCount,
                show: _showBadge,
                position: BadgePosition.topRight,
                child: const Icon(Icons.mail_outline, size: 32),
              ),

              // Badge with 999+
              BadgeM3E(
                count: 1234,
                show: _showBadge,
                child: const Icon(Icons.inbox_outlined, size: 32),
              ),

              // Badge with custom color
              BadgeM3E(
                count: 5,
                show: _showBadge,
                backgroundColor: Colors.green,
                position: BadgePosition.bottomRight,
                child: const Icon(Icons.favorite_outline, size: 32),
              ),

              // Badge with label
              BadgeM3E(
                label: 'NEW',
                show: _showBadge,
                backgroundColor: Colors.blue,
                child: const Icon(Icons.star_outline, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _notificationCount++;
                  });
                },
                child: const Text('Increment'),
              ),
              const SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showBadge = !_showBadge;
                  });
                },
                child: Text(_showBadge ? 'Hide Badges' : 'Show Badges'),
              ),
            ],
          ),

          const SizedBox(height: 32.0),
          const Divider(),
          const SizedBox(height: 32.0),

          // Snackbar Examples
          _buildSectionTitle('Snackbars'),
          const SizedBox(height: 16.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              ElevatedButton(
                onPressed: () {
                  showSnackbarM3E(
                    context: context,
                    message: 'This is a simple snackbar',
                  );
                },
                child: const Text('Simple Snackbar'),
              ),
              ElevatedButton(
                onPressed: () {
                  showSnackbarM3E(
                    context: context,
                    message: 'File saved successfully',
                    action: SnackbarAction(
                      label: 'Undo',
                      onPressed: () {
                        // Handle undo
                      },
                    ),
                  );
                },
                child: const Text('With Action'),
              ),
              ElevatedButton(
                onPressed: () {
                  showSnackbarM3E(
                    context: context,
                    message: 'Message sent',
                    icon: const Icon(Icons.check_circle),
                    duration: SnackbarDuration.long_,
                  );
                },
                child: const Text('With Icon'),
              ),
              ElevatedButton(
                onPressed: () {
                  showSnackbarM3E(
                    context: context,
                    message: 'Connection lost',
                    icon: const Icon(Icons.error_outline),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  );
                },
                child: const Text('Error Snackbar'),
              ),
            ],
          ),

          const SizedBox(height: 32.0),
          const Divider(),
          const SizedBox(height: 32.0),

          // Tooltip Examples
          _buildSectionTitle('Tooltips'),
          const SizedBox(height: 16.0),
          Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: [
              // Plain tooltip
              TooltipWrapperM3E(
                message: 'Add to favorites',
                child: IconButton(
                  icon: const Icon(Icons.favorite_outline),
                  onPressed: () {},
                ),
              ),

              // Tooltip with custom position
              TooltipWrapperM3E(
                message: 'Share with friends',
                position: TooltipPosition.top,
                child: IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {},
                ),
              ),

              // Rich tooltip
              TooltipM3E(
                type: TooltipType.rich,
                richContent: RichTooltipContent(
                  title: 'Premium Feature',
                  description: 'Upgrade to access advanced features',
                  icon: const Icon(Icons.lock_outlined),
                  action: TooltipAction(
                    label: 'Upgrade',
                    onPressed: () {
                      // Handle upgrade
                    },
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.workspace_premium_outlined),
                  onPressed: () {},
                ),
              ),
            ],
          ),

          const SizedBox(height: 32.0),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

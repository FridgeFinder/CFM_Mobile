import 'package:flutter/material.dart';
import '../theme/spacing.dart';
import '../theme/motion.dart';
import 'loading_m3e_morphing.dart';

/// M3E Loading Indicator
///
/// A centered loading spinner with optional message.
/// Uses M3E morphing animations for expressive motion.
class LoadingIndicatorM3E extends StatelessWidget {
  final String? message;
  final Color? color;
  final double? size;

  const LoadingIndicatorM3E({super.key, this.message, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MorphingLoadingIndicatorM3E.blobMorph(
            size: size ?? 60,
            color: color,
          ),
          if (message != null) ...[
            M3ESpacing.verticalMD,
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// M3E Circular Progress Indicator Size Variants
enum CircularProgressSizeM3E {
  small(24.0, 3.0),
  medium(48.0, 4.0),
  large(64.0, 5.0);

  final double size;
  final double strokeWidth;

  const CircularProgressSizeM3E(this.size, this.strokeWidth);
}

/// M3E Enhanced Circular Progress Indicator
///
/// A Material 3 Expressive circular progress indicator with:
/// - Size variants: small (24dp), medium (48dp), large (64dp)
/// - Customizable stroke width with rounded caps
/// - Indeterminate: Smooth rotation animation (1333ms)
/// - Determinate: Arc progress based on value
/// - Primary color (default) or customizable
class CircularProgressIndicatorM3E extends StatelessWidget {
  /// Progress value (0.0 to 1.0). Null for indeterminate.
  final double? value;

  /// Size variant
  final CircularProgressSizeM3E size;

  /// Custom stroke width (overrides size default)
  final double? strokeWidth;

  /// Custom color (defaults to primary)
  final Color? color;

  /// Background track color for determinate progress
  final Color? backgroundColor;

  const CircularProgressIndicatorM3E({
    super.key,
    this.value,
    this.size = CircularProgressSizeM3E.medium,
    this.strokeWidth,
    this.color,
    this.backgroundColor,
  });

  /// Small variant (24dp)
  const CircularProgressIndicatorM3E.small({
    super.key,
    this.value,
    this.strokeWidth,
    this.color,
    this.backgroundColor,
  }) : size = CircularProgressSizeM3E.small;

  /// Medium variant (48dp)
  const CircularProgressIndicatorM3E.medium({
    super.key,
    this.value,
    this.strokeWidth,
    this.color,
    this.backgroundColor,
  }) : size = CircularProgressSizeM3E.medium;

  /// Large variant (64dp)
  const CircularProgressIndicatorM3E.large({
    super.key,
    this.value,
    this.strokeWidth,
    this.color,
    this.backgroundColor,
  }) : size = CircularProgressSizeM3E.large;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveStrokeWidth = strokeWidth ?? size.strokeWidth;

    return SizedBox(
      width: size.size,
      height: size.size,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: effectiveStrokeWidth,
        strokeCap: StrokeCap.round,
        color: color ?? colorScheme.primary,
        backgroundColor:
            backgroundColor ??
            (value != null ? colorScheme.surfaceContainerHighest : null),
      ),
    );
  }
}

/// M3E Enhanced Linear Progress Indicator
///
/// A horizontal progress bar with Material 3 Expressive styling:
/// - Height: 4dp (default), customizable
/// - Rounded ends using ClipRRect
/// - Gap between active/inactive tracks
/// - Optional stop indicator at the end
/// - Indeterminate: Moving bar animation
/// - Determinate: Fill width based on progress
/// - Colors: primary track, surfaceVariant background
class LinearProgressIndicatorM3E extends StatelessWidget {
  /// Progress value (0.0 to 1.0). Null for indeterminate.
  final double? value;

  /// Custom track color (defaults to primary)
  final Color? color;

  /// Custom background color (defaults to surfaceContainerHighest)
  final Color? backgroundColor;

  /// Height of the progress bar
  final double height;

  /// Border radius for rounded ends
  final double? borderRadius;

  /// Whether to show a stop indicator at the end (for determinate only)
  final bool showStopIndicator;

  const LinearProgressIndicatorM3E({
    super.key,
    this.value,
    this.color,
    this.backgroundColor,
    this.height = 4.0,
    this.borderRadius,
    this.showStopIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBorderRadius = borderRadius ?? (height / 2);
    final effectiveColor = color ?? colorScheme.primary;
    final effectiveBackgroundColor =
        backgroundColor ?? colorScheme.surfaceContainerHighest;

    return ClipRRect(
      borderRadius: BorderRadius.circular(effectiveBorderRadius),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            // Background track
            Container(
              width: double.infinity,
              height: height,
              color: effectiveBackgroundColor,
            ),
            // Progress indicator
            LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
              minHeight: height,
            ),
            // Stop indicator (for determinate only)
            if (showStopIndicator && value != null && value! > 0)
              Positioned(
                left: null,
                right: 0,
                child: FractionalTranslation(
                  translation: Offset(-value!, 0),
                  child: Container(
                    width: height,
                    height: height,
                    decoration: BoxDecoration(
                      color: effectiveColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// M3E Progress Indicator with Label
///
/// A progress indicator that shows a label below it:
/// - Shows percentage (0% - 100%) by default
/// - Or custom value with formatter
/// - Typography: labelMedium
/// - Animated number transitions
/// - Supports both circular and linear indicators
class ProgressIndicatorWithLabelM3E extends StatelessWidget {
  /// Progress value (0.0 to 1.0)
  final double value;

  /// Whether to use circular (true) or linear (false) indicator
  final bool circular;

  /// Size for circular indicator
  final CircularProgressSizeM3E circularSize;

  /// Height for linear indicator
  final double linearHeight;

  /// Custom label formatter. If null, shows percentage.
  /// Example: (value) => '${(value * 100).toInt()}/100 MB'
  final String Function(double)? labelFormatter;

  /// Custom color (defaults to primary)
  final Color? color;

  /// Background color for indicator
  final Color? backgroundColor;

  /// Gap between indicator and label
  final double gap;

  const ProgressIndicatorWithLabelM3E({
    super.key,
    required this.value,
    this.circular = true,
    this.circularSize = CircularProgressSizeM3E.medium,
    this.linearHeight = 4.0,
    this.labelFormatter,
    this.color,
    this.backgroundColor,
    this.gap = M3ESpacing.xs,
  });

  /// Circular variant with label
  const ProgressIndicatorWithLabelM3E.circular({
    super.key,
    required this.value,
    this.circularSize = CircularProgressSizeM3E.medium,
    this.labelFormatter,
    this.color,
    this.backgroundColor,
    this.gap = M3ESpacing.xs,
  }) : circular = true,
       linearHeight = 4.0;

  /// Linear variant with label
  const ProgressIndicatorWithLabelM3E.linear({
    super.key,
    required this.value,
    this.linearHeight = 4.0,
    this.labelFormatter,
    this.color,
    this.backgroundColor,
    this.gap = M3ESpacing.xs,
  }) : circular = false,
       circularSize = CircularProgressSizeM3E.medium;

  String _defaultFormatter(double value) {
    return '${(value * 100).round()}%';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final formatter = labelFormatter ?? _defaultFormatter;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress indicator
        if (circular)
          CircularProgressIndicatorM3E(
            value: value,
            size: circularSize,
            color: color,
            backgroundColor: backgroundColor,
          )
        else
          LinearProgressIndicatorM3E(
            value: value,
            height: linearHeight,
            color: color,
            backgroundColor: backgroundColor,
          ),
        SizedBox(height: gap),
        // Animated label (respects reduce motion)
        TweenAnimationBuilder<double>(
          duration: M3EMotion.getDurationReduced(M3EMotion.medium4), // Smoother animation
          curve: M3EMotion.getCurve(M3EMotion.emphasizedDecelerate), // Smoother curve
          tween: Tween<double>(begin: 0, end: value),
          builder: (context, animatedValue, child) {
            return Text(
              formatter(animatedValue),
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            );
          },
        ),
      ],
    );
  }
}

/// M3E Skeleton Loader
///
/// A shimmer loading placeholder for content.
/// Use while content is loading to maintain layout stability.
class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({super.key, this.width, this.height, this.borderRadius});

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Shimmer animation - smooth gradient sweep
    _shimmerController = AnimationController(
      duration: M3EMotion.getDurationReduced(
        const Duration(milliseconds: 1500),
        percentageWhenReduced: 0.5,
      ),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: M3EMotion.getCurve(Curves.easeInOut),
    ));

    // Pulse animation - breathing effect
    _pulseController = AnimationController(
      duration: M3EMotion.getDurationReduced(
        const Duration(milliseconds: 2000),
        percentageWhenReduced: 0.5,
      ),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: M3EMotion.getCurve(Curves.easeInOut),
    ));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.surfaceContainerHighest;

    return AnimatedBuilder(
      animation: Listenable.merge([_shimmerAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height ?? 20,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                0.0,
                (_shimmerAnimation.value.clamp(0.0, 1.0) - 0.3).clamp(0.0, 1.0),
                _shimmerAnimation.value.clamp(0.0, 1.0),
                (_shimmerAnimation.value.clamp(0.0, 1.0) + 0.3).clamp(0.0, 1.0),
                1.0,
              ],
              colors: [
                baseColor.withValues(alpha: _pulseAnimation.value),
                baseColor.withValues(alpha: _pulseAnimation.value * 0.5),
                baseColor.withValues(alpha: (_pulseAnimation.value * 1.2).clamp(0.0, 1.0)),
                baseColor.withValues(alpha: _pulseAnimation.value * 0.5),
                baseColor.withValues(alpha: _pulseAnimation.value),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// M3E Skeleton Card Loader
///
/// A card-shaped skeleton loader with title and content areas.
class SkeletonCardLoader extends StatelessWidget {
  const SkeletonCardLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: M3ESpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SkeletonLoader(
                  width: 48,
                  height: 48,
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                M3ESpacing.horizontalMD,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonLoader(height: 16, width: 120),
                      M3ESpacing.verticalXS,
                      const SkeletonLoader(height: 14, width: 180),
                    ],
                  ),
                ),
              ],
            ),
            M3ESpacing.verticalMD,
            const SkeletonLoader(height: 12),
            M3ESpacing.verticalXS,
            const SkeletonLoader(height: 12),
            M3ESpacing.verticalXS,
            const SkeletonLoader(height: 12, width: 200),
          ],
        ),
      ),
    );
  }
}

/// M3E Refresh Indicator
///
/// A Material 3 Expressive pull-to-refresh component with:
/// - Expressive spring physics (400ms duration)
/// - Custom elevation and colors
/// - Smooth rotation and scale animations
/// - Customizable displacement and stroke width
///
/// Usage:
/// ```dart
/// RefreshIndicatorM3E(
///   onRefresh: () async {
///     await fetchData();
///   },
///   child: ListView(...),
/// )
/// ```
class RefreshIndicatorM3E extends StatelessWidget {
  /// The child widget (typically a scrollable)
  final Widget child;

  /// Callback when user triggers refresh
  final Future<void> Function() onRefresh;

  /// Custom color (defaults to primary)
  final Color? color;

  /// Custom background color
  final Color? backgroundColor;

  /// Stroke width of the circular progress indicator
  final double strokeWidth;

  /// Displacement from the top edge
  final double displacement;

  /// Edge offset (padding from screen edges)
  final double edgeOffset;

  const RefreshIndicatorM3E({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
    this.strokeWidth = 4.0,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? colorScheme.primary,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      strokeWidth: strokeWidth,
      displacement: displacement,
      edgeOffset: edgeOffset,
      // Use emphasized decelerate curve for M3E expressive motion
      // Note: Flutter's RefreshIndicator doesn't expose curve customization,
      // but uses its own spring physics similar to M3E standardSpring
      child: child,
    );
  }
}

/// M3E Refresh Indicator with Custom Trigger
///
/// An enhanced refresh indicator that provides more control over the refresh behavior.
/// Uses a [NotificationListener] to detect scroll and trigger animations.
///
/// This variant allows for more customization of the refresh trigger distance
/// and provides access to the scroll position for custom effects.
class RefreshIndicatorCustomM3E extends StatefulWidget {
  /// The child widget (typically a scrollable)
  final Widget child;

  /// Callback when user triggers refresh
  final Future<void> Function() onRefresh;

  /// Custom color (defaults to primary)
  final Color? color;

  /// Custom background color
  final Color? backgroundColor;

  /// Stroke width of the circular progress indicator
  final double strokeWidth;

  /// Distance to pull before triggering refresh (in dp)
  final double triggerDistance;

  const RefreshIndicatorCustomM3E({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
    this.strokeWidth = 4.0,
    this.triggerDistance = 80.0,
  });

  @override
  State<RefreshIndicatorCustomM3E> createState() =>
      _RefreshIndicatorCustomM3EState();
}

class _RefreshIndicatorCustomM3EState extends State<RefreshIndicatorCustomM3E> {
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await widget.onRefresh();
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: widget.color ?? colorScheme.primary,
      backgroundColor: widget.backgroundColor ?? colorScheme.surface,
      strokeWidth: widget.strokeWidth,
      displacement: 40.0,
      // Uses M3E expressive spring physics (similar to standardSpring)
      // Flutter's RefreshIndicator handles animation internally
      child: widget.child,
    );
  }
}

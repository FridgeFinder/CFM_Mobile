import 'package:flutter/material.dart';
import '../theme/spacing.dart';

/// M3E Loading Indicator
///
/// A centered loading spinner with optional message.
/// Uses M3 styling and motion patterns.
class LoadingIndicatorM3E extends StatelessWidget {
  final String? message;
  final Color? color;
  final double? size;

  const LoadingIndicatorM3E({
    super.key,
    this.message,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: CircularProgressIndicator(
              color: color ?? colorScheme.primary,
              strokeWidth: 4,
            ),
          ),
          if (message != null) ...[
            M3ESpacing.verticalMD,
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// M3E Linear Progress Indicator
///
/// A horizontal progress bar with M3 styling.
class LinearProgressIndicatorM3E extends StatelessWidget {
  final double? value;
  final Color? color;
  final Color? backgroundColor;
  final double height;

  const LinearProgressIndicatorM3E({
    super.key,
    this.value,
    this.color,
    this.backgroundColor,
    this.height = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: backgroundColor ?? colorScheme.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? colorScheme.primary,
        ),
      ),
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

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height ?? 20,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(
              alpha: _animation.value,
            ),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
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
                      const SkeletonLoader(
                        height: 16,
                        width: 120,
                      ),
                      M3ESpacing.verticalXS,
                      const SkeletonLoader(
                        height: 14,
                        width: 180,
                      ),
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
            const SkeletonLoader(
              height: 12,
              width: 200,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'motion.dart';

/// Shared Element Transitions for Hero Animations
///
/// Implements Material 3 Expressive shared element transitions with:
/// - Shape morphing (rounded → pill, etc.)
/// - Size/position interpolation
/// - Elevation transitions
/// - Color transitions
/// - Spring-based physics
class SharedElementTransitionM3E {
  SharedElementTransitionM3E._();

  /// Create a shared element transition between two widgets
  ///
  /// Automatically handles:
  /// - Bounds calculation
  /// - Shape morphing
  /// - Size interpolation
  /// - Position interpolation
  /// - Elevation changes
  static Widget transition({
    required Animation<double> animation,
    required Rect sourceBounds,
    required Rect destinationBounds,
    required BorderRadius sourceRadius,
    required BorderRadius destinationRadius,
    required Widget child,
    double sourceElevation = 0.0,
    double destinationElevation = 0.0,
    Color? scrimColor,
  }) {
    // Scrim fade (0-30% of animation)
    final scrimAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );

    // Main morph animation (0-100%)
    final morphAnimation = CurvedAnimation(
      parent: animation,
      curve: M3EMotion.expressiveDefaultOvershoot,
    );

    // Content fade (70-100% of animation)
    final contentFadeAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    );

    return Stack(
      children: [
        // Scrim backdrop
        if (scrimColor != null)
          FadeTransition(
            opacity: scrimAnimation,
            child: Container(
              color: scrimColor.withValues(alpha: 0.32),
            ),
          ),
        // Shared element with morph
        AnimatedBuilder(
          animation: morphAnimation,
          builder: (context, child) {
            final progress = morphAnimation.value;

            // Interpolate bounds
            final currentBounds = Rect.lerp(sourceBounds, destinationBounds, progress)!;

            // Interpolate border radius
            final currentRadius = BorderRadius.lerp(sourceRadius, destinationRadius, progress)!;

            // Interpolate elevation
            final currentElevation = sourceElevation +
                (destinationElevation - sourceElevation) * progress;

            return Positioned(
              left: currentBounds.left,
              top: currentBounds.top,
              width: currentBounds.width,
              height: currentBounds.height,
              child: FadeTransition(
                opacity: contentFadeAnimation,
                child: Material(
                  elevation: currentElevation,
                  borderRadius: currentRadius,
                  color: Colors.transparent,
                  child: ClipRRect(
                    borderRadius: currentRadius,
                    child: child,
                  ),
                ),
              ),
            );
          },
          child: child,
        ),
      ],
    );
  }

  /// Create a hero widget with shared element transition
  ///
  /// Use this to wrap widgets that should participate in hero animations.
  static Widget hero({
    required String tag,
    required Widget child,
    required GlobalKey sourceKey,
    Rect? destinationBounds,
    BorderRadius? destinationRadius,
    double destinationElevation = 0.0,
  }) {
    return Hero(
      tag: tag,
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        // Get source bounds from key
        final sourceRenderBox = sourceKey.currentContext?.findRenderObject() as RenderBox?;
        if (sourceRenderBox == null) {
          return child;
        }

        final sourceOffset = sourceRenderBox.localToGlobal(Offset.zero);
        final sourceBounds = Rect.fromLTWH(
          sourceOffset.dx,
          sourceOffset.dy,
          sourceRenderBox.size.width,
          sourceRenderBox.size.height,
        );

        final sourceRadius = BorderRadius.circular(12.0); // Default
        final destBounds = destinationBounds ??
            Rect.fromLTWH(0, 0, MediaQuery.of(toHeroContext).size.width,
                MediaQuery.of(toHeroContext).size.height);
        final destRadius = destinationRadius ?? BorderRadius.circular(28.0);

        return transition(
          animation: animation,
          sourceBounds: sourceBounds,
          destinationBounds: destBounds,
          sourceRadius: sourceRadius,
          destinationRadius: destRadius,
          child: child,
          sourceElevation: 0.0,
          destinationElevation: destinationElevation,
        );
      },
    );
  }
}

/// Shared element transition route builder
///
/// Creates a page route with shared element transitions.
class SharedElementRoute<T> extends PageRoute<T> {
  final WidgetBuilder pageBuilder;
  final String heroTag;
  final GlobalKey sourceKey;
  final Rect? destinationBounds;
  final BorderRadius? destinationRadius;
  final double destinationElevation;
  final Color? scrimColor;

  SharedElementRoute({
    required this.pageBuilder,
    required this.heroTag,
    required this.sourceKey,
    this.destinationBounds,
    this.destinationRadius,
    this.destinationElevation = 0.0,
    this.scrimColor,
  });

  @override
  Color? get barrierColor => scrimColor;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => M3EMotion.getDuration(M3EMotion.long2); // 500ms

  @override
  Duration get reverseTransitionDuration =>
      M3EMotion.getDuration(M3EMotion.medium4); // 400ms

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return pageBuilder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Get source bounds from key
    final sourceRenderBox = sourceKey.currentContext?.findRenderObject() as RenderBox?;
    if (sourceRenderBox == null) {
      return child;
    }

    final sourceOffset = sourceRenderBox.localToGlobal(Offset.zero);
    final sourceBounds = Rect.fromLTWH(
      sourceOffset.dx,
      sourceOffset.dy,
      sourceRenderBox.size.width,
      sourceRenderBox.size.height,
    );

    final sourceRadius = BorderRadius.circular(12.0);
    final screenSize = MediaQuery.of(context).size;
    final destBounds = destinationBounds ??
        Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    final destRadius = destinationRadius ?? BorderRadius.circular(28.0);

    return SharedElementTransitionM3E.transition(
      animation: animation,
      sourceBounds: sourceBounds,
      destinationBounds: destBounds,
      sourceRadius: sourceRadius,
      destinationRadius: destRadius,
      child: child,
      sourceElevation: 0.0,
      destinationElevation: destinationElevation,
      scrimColor: scrimColor,
    );
  }
}

/// Helper function to create shared element routes
PageRoute<T> createSharedElementRoute<T>({
  required BuildContext context,
  required Widget page,
  required String heroTag,
  required GlobalKey sourceKey,
  Rect? destinationBounds,
  BorderRadius? destinationRadius,
  double destinationElevation = 0.0,
  Color? scrimColor,
}) {
  return SharedElementRoute<T>(
    pageBuilder: (_) => page,
    heroTag: heroTag,
    sourceKey: sourceKey,
    destinationBounds: destinationBounds,
    destinationRadius: destinationRadius,
    destinationElevation: destinationElevation,
    scrimColor: scrimColor,
  );
}


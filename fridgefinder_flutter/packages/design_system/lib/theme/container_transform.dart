import 'package:flutter/material.dart';
import 'motion.dart';
import 'elevation.dart';

/// Material 3 Expressive Container Transform System
///
/// Implements the full M3E container transform pattern for hero-style
/// element transformations (Card → Detail, List item → Full screen, etc.)
///
/// M3E Spec: 500ms total (300ms shape/position, 200ms content fade-through)
class ContainerTransformM3E {
  ContainerTransformM3E._();

  /// Create a container transform animation
  ///
  /// Morphs from source container to destination container with:
  /// - Shape interpolation
  /// - Size/position morph
  /// - Content fade-through
  /// - Elevation change
  static Widget transform({
    required Animation<double> animation,
    required Widget child,
    required Rect sourceBounds,
    required Rect destinationBounds,
    Color? scrimColor,
    double? elevation,
  }) {
    // Fade-through background scrim (0-30% of animation)
    final scrimAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );

    // Shape/position morph (0-100% with emphasized decelerate)
    final morphAnimation = CurvedAnimation(
      parent: animation,
      curve: M3EMotion.emphasizedDecelerate,
    );

    // Content fade-through (70-100% of animation)
    final contentFadeAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    );

    return Stack(
      children: [
        // Scrim overlay
        if (scrimColor != null)
          FadeTransition(
            opacity: scrimAnimation,
            child: Container(
              color: scrimColor.withValues(alpha: 0.32),
            ),
          ),
        // Transformed container
        AnimatedBuilder(
          animation: morphAnimation,
          builder: (context, child) {
            final progress = morphAnimation.value;
            
            // Interpolate bounds
            final currentBounds = Rect.lerp(sourceBounds, destinationBounds, progress)!;
            
            // Interpolate corner radius (from source to destination)
            final sourceRadius = BorderRadius.circular(12.0);
            final destRadius = BorderRadius.circular(28.0);
            final currentRadius = BorderRadius.lerp(sourceRadius, destRadius, progress)!;
            
            // Interpolate elevation
            final currentElevation = elevation != null
                ? elevation * progress
                : M3EElevation.level1 + (M3EElevation.level5 - M3EElevation.level1) * progress;

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

  /// Create container transform page route
  ///
  /// Use for: Card → Detail, List item → Full screen, FAB → Screen
  static PageRoute<T> createRoute<T>({
    required Widget page,
    required GlobalKey sourceKey,
    Duration? duration,
    Color? scrimColor,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? M3EMotion.getDuration(M3EMotion.long2),
      reverseTransitionDuration: duration ?? M3EMotion.getDuration(M3EMotion.medium4),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Get source bounds from key
        final sourceBounds = _getBoundsFromKey(sourceKey, context);
        final screenSize = MediaQuery.of(context).size;
        final destinationBounds = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
        
        return transform(
          animation: animation,
          child: child,
          sourceBounds: sourceBounds,
          destinationBounds: destinationBounds,
          scrimColor: scrimColor,
        );
      },
    );
  }

  /// Get bounds from a global key
  static Rect _getBoundsFromKey(GlobalKey key, BuildContext context) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return Rect.fromLTWH(0, 0, 100, 100); // Fallback
    }
    final offset = renderBox.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
      offset.dx,
      offset.dy,
      renderBox.size.width,
      renderBox.size.height,
    );
  }
}

/// Widget wrapper for container transform transitions
///
/// Automatically handles bounds calculation and morphing.
class ContainerTransformWrapper extends StatefulWidget {
  /// Source widget (the element that will transform)
  final Widget source;
  
  /// Destination widget (the element to transform into)
  final Widget destination;
  
  /// Whether the transform is active
  final bool isTransforming;
  
  /// Scrim color for background overlay
  final Color? scrimColor;

  const ContainerTransformWrapper({
    super.key,
    required this.source,
    required this.destination,
    required this.isTransforming,
    this.scrimColor,
  });

  @override
  State<ContainerTransformWrapper> createState() => _ContainerTransformWrapperState();
}

class _ContainerTransformWrapperState extends State<ContainerTransformWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final GlobalKey _sourceKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.long2),
      vsync: this,
    );
    if (widget.isTransforming) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ContainerTransformWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTransforming != oldWidget.isTransforming) {
      if (widget.isTransforming) {
        _controller.forward();
      } else {
        _controller.reverse();
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
    if (!widget.isTransforming) {
      return Container(
        key: _sourceKey,
        child: widget.source,
      );
    }

    final sourceBounds = _getBounds();
    final screenSize = MediaQuery.of(context).size;
    final destinationBounds = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);

    return ContainerTransformM3E.transform(
      animation: _controller,
      child: widget.destination,
      sourceBounds: sourceBounds,
      destinationBounds: destinationBounds,
      scrimColor: widget.scrimColor,
    );
  }

  Rect _getBounds() {
    final renderBox = _sourceKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return Rect.fromLTWH(0, 0, 100, 100);
    }
    final offset = renderBox.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
      offset.dx,
      offset.dy,
      renderBox.size.width,
      renderBox.size.height,
    );
  }
}


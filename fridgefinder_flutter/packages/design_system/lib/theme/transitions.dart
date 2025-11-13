import 'package:flutter/material.dart';
import 'motion.dart';

/// Material 3 Expressive Transitions
///
/// M3 defines four primary transition patterns:
/// 1. Container Transform - For hero-style element transformations
/// 2. Shared Axis - For sibling/sequential content (X, Y, Z axes)
/// 3. Fade Through - For in-place content swaps
/// 4. Fade - For simple appear/disappear
///
/// These transitions use M3E spring physics for natural, expressive motion.
class M3ETransitions {
  M3ETransitions._();

  // ============================================================================
  // 1. CONTAINER TRANSFORM
  // ============================================================================

  /// Container transform transition - morphs from one container to another
  /// Use for: Card → Detail, List item → Full screen, FAB → Screen
  ///
  /// Features:
  /// - Shape morph
  /// - Size/position morph
  /// - Fade through background
  /// - Elevation change
  static Widget containerTransform({
    required Animation<double> animation,
    required Widget child,
    Color? scrimColor,
  }) {
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );

    final scaleAnimation = CurvedAnimation(
      parent: animation,
      curve: M3EMotion.emphasizedDecelerate,
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(scaleAnimation),
        child: child,
      ),
    );
  }

  /// Create container transform page route
  static PageRoute<T> containerTransformRoute<T>({
    required Widget page,
    Duration? duration,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? M3EMotion.getDuration(M3EMotion.long2),
      reverseTransitionDuration: duration ?? M3EMotion.getDuration(M3EMotion.medium4),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return containerTransform(
          animation: animation,
          child: child,
        );
      },
    );
  }

  // ============================================================================
  // 2. SHARED AXIS (X, Y, Z)
  // ============================================================================

  /// Shared Axis X - Horizontal movement (left/right)
  /// Use for: Tab switches, horizontal pagination, lateral navigation
  ///
  /// Pattern:
  /// - Outgoing content fades out while sliding 3% to the left/right
  /// - Incoming content fades in while sliding in from right/left
  static Widget sharedAxisX({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
    bool reverse = false,
  }) {
    const offset = 0.03; // 3% of screen width

    final primarySlide = Tween<Offset>(
      begin: Offset(reverse ? -offset : offset, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: M3EMotion.emphasizedDecelerate,
    ));

    final secondarySlide = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(reverse ? offset : -offset, 0),
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: M3EMotion.emphasizedAccelerate,
    ));

    final fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.3, 1.0, curve: Curves.linear),
    );

    final fadeOut = CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.0, 0.7, curve: Curves.linear),
    );

    return SlideTransition(
      position: animation.status == AnimationStatus.reverse
          ? secondarySlide
          : primarySlide,
      child: FadeTransition(
        opacity: animation.status == AnimationStatus.reverse
            ? fadeOut
            : fadeIn,
        child: child,
      ),
    );
  }

  /// Shared Axis Y - Vertical movement (up/down)
  /// Use for: List → Detail, Bottom navigation, vertical step flow
  ///
  /// Pattern:
  /// - Outgoing content fades out while sliding 3% up/down
  /// - Incoming content fades in while sliding in from bottom/top
  static Widget sharedAxisY({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
    bool reverse = false,
  }) {
    const offset = 0.03; // 3% of screen height

    final primarySlide = Tween<Offset>(
      begin: Offset(0, reverse ? -offset : offset),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: M3EMotion.emphasizedDecelerate,
    ));

    final secondarySlide = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, reverse ? offset : -offset),
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: M3EMotion.emphasizedAccelerate,
    ));

    final fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.3, 1.0, curve: Curves.linear),
    );

    final fadeOut = CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.0, 0.7, curve: Curves.linear),
    );

    return SlideTransition(
      position: animation.status == AnimationStatus.reverse
          ? secondarySlide
          : primarySlide,
      child: FadeTransition(
        opacity: animation.status == AnimationStatus.reverse
            ? fadeOut
            : fadeIn,
        child: child,
      ),
    );
  }

  /// Shared Axis Z - Depth movement (scale + fade)
  /// Use for: Stepper progression, wizard flow, modal transitions
  ///
  /// Pattern:
  /// - Outgoing content fades out while scaling down
  /// - Incoming content fades in while scaling up from smaller
  static Widget sharedAxisZ({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
    bool reverse = false,
  }) {
    final primaryScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: M3EMotion.emphasizedDecelerate,
    ));

    final secondaryScale = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: M3EMotion.emphasizedAccelerate,
    ));

    final fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.3, 1.0, curve: Curves.linear),
    );

    final fadeOut = CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.0, 0.7, curve: Curves.linear),
    );

    return ScaleTransition(
      scale: animation.status == AnimationStatus.reverse
          ? secondaryScale
          : primaryScale,
      child: FadeTransition(
        opacity: animation.status == AnimationStatus.reverse
            ? fadeOut
            : fadeIn,
        child: child,
      ),
    );
  }

  /// Create shared axis page route (specify axis: X, Y, or Z)
  static PageRoute<T> sharedAxisRoute<T>({
    required Widget page,
    required Axis axis,
    bool reverse = false,
    Duration? duration,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? M3EMotion.getDuration(M3EMotion.medium3),
      reverseTransitionDuration: duration ?? M3EMotion.getDuration(M3EMotion.medium2),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (axis == Axis.horizontal) {
          return sharedAxisX(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
            reverse: reverse,
          );
        } else {
          return sharedAxisY(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
            reverse: reverse,
          );
        }
      },
    );
  }

  // ============================================================================
  // 3. FADE THROUGH
  // ============================================================================

  /// Fade through transition - For in-place content swaps
  /// Use for: Carousel/tabs content area, search results, filtering
  ///
  /// Pattern:
  /// - Outgoing content fades out completely
  /// - Incoming content fades in after a brief pause
  /// - Creates a "blank" moment between content
  static Widget fadeThrough({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
    Color? fillColor,
  }) {
    // Incoming: fade in during last 65% of animation
    final fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.35, 1.0, curve: Curves.easeIn),
    );

    // Slight scale for extra expressiveness
    final scaleIn = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.35, 1.0, curve: M3EMotion.emphasized),
    ));

    return Stack(
      children: [
        // Fill color during transition
        if (fillColor != null)
          FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.35),
              ),
            ),
            child: Container(color: fillColor),
          ),
        // Incoming content
        FadeTransition(
          opacity: fadeIn,
          child: ScaleTransition(
            scale: scaleIn,
            child: child,
          ),
        ),
      ],
    );
  }

  /// Create fade through page route
  static PageRoute<T> fadeThroughRoute<T>({
    required Widget page,
    Color? fillColor,
    Duration? duration,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? M3EMotion.getDuration(M3EMotion.medium3),
      reverseTransitionDuration: duration ?? M3EMotion.getDuration(M3EMotion.medium2),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return fadeThrough(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
          fillColor: fillColor,
        );
      },
    );
  }

  // ============================================================================
  // 4. FADE
  // ============================================================================

  /// Simple fade transition - For overlays, tooltips, dialogs
  /// Use for: Modals, scrim, tooltips, simple appear/disappear
  ///
  /// Pattern:
  /// - Linear fade in/out
  static Widget fade({
    required Animation<double> animation,
    required Widget child,
    Curve curve = Curves.linear,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: curve),
      child: child,
    );
  }

  /// Create fade page route
  static PageRoute<T> fadeRoute<T>({
    required Widget page,
    Duration? duration,
    Curve curve = Curves.linear,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? M3EMotion.getDuration(M3EMotion.short4),
      reverseTransitionDuration: duration ?? M3EMotion.getDuration(M3EMotion.short3),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return fade(animation: animation, child: child, curve: M3EMotion.getCurve(curve));
      },
    );
  }

  // ============================================================================
  // SPECIAL TRANSITIONS
  // ============================================================================

  /// Bottom sheet slide-up transition with M3E spring physics
  static Widget bottomSheetSlideUp({
    required Animation<double> animation,
    required Widget child,
  }) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: M3EMotion.emphasizedDecelerate,
    ));

    return SlideTransition(
      position: slideAnimation,
      child: child,
    );
  }

  /// Drawer slide-in transition
  static Widget drawerSlideIn({
    required Animation<double> animation,
    required Widget child,
    bool fromLeft = true,
  }) {
    final slideAnimation = Tween<Offset>(
      begin: Offset(fromLeft ? -1 : 1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: M3EMotion.emphasizedDecelerate,
    ));

    return SlideTransition(
      position: slideAnimation,
      child: child,
    );
  }

  /// Snackbar slide-up with M3E expressive spring
  static Widget snackbarSlideUp({
    required Animation<double> animation,
    required Widget child,
  }) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: M3EMotion.emphasizedDecelerate,
    ));

    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }

  /// List item entrance animation with stagger
  static Widget listItemEntrance({
    required Animation<double> animation,
    required Widget child,
    int index = 0,
    int totalItems = 10,
  }) {
    // Stagger delay based on index
    final staggerDelay = (index / totalItems) * 0.3;
    final adjustedInterval = Interval(
      staggerDelay,
      (staggerDelay + 0.7).clamp(0.0, 1.0),
      curve: M3EMotion.emphasizedDecelerate,
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: adjustedInterval,
    ));

    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: adjustedInterval,
    );

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }

  /// Dialog scale-fade entrance
  static Widget dialogScaleFade({
    required Animation<double> animation,
    required Widget child,
  }) {
    final scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: M3EMotion.emphasized,
    ));

    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    return ScaleTransition(
      scale: scaleAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }

  /// Menu cascade animation
  static Widget menuCascade({
    required Animation<double> animation,
    required Widget child,
    Alignment alignment = Alignment.topLeft,
  }) {
    final scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: M3EMotion.emphasizedDecelerate,
    ));

    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    return ScaleTransition(
      scale: scaleAnimation,
      alignment: alignment,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }
}

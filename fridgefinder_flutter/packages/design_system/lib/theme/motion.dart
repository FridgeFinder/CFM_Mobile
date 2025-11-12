import 'dart:math' as math;
import 'package:flutter/physics.dart';
import 'package:flutter/animation.dart';

/// Material 3 Expressive Motion System
///
/// M3E uses spring-based motion for more natural, expressive animations.
/// Standard M3 uses duration-based easing curves.
///
/// This system provides both approaches with smooth fallbacks.
class M3EMotion {
  M3EMotion._();

  // ============================================================================
  // SPRING PHYSICS (M3E Expressive)
  // ============================================================================

  /// Expressive spring - More bouncy, playful (stiffness: 250, damping: 25)
  /// Use for: Emphasized actions, delightful interactions, attention-grabbing moments
  static const SpringDescription expressiveSpring = SpringDescription(
    mass: 1.0,
    stiffness: 250.0,
    damping: 25.0,
  );

  /// Standard spring - Balanced, smooth (stiffness: 300, damping: 30)
  /// Use for: Most UI transitions, general interactions
  static const SpringDescription standardSpring = SpringDescription(
    mass: 1.0,
    stiffness: 300.0,
    damping: 30.0,
  );

  /// Gentle spring - Slow, soft settling (stiffness: 200, damping: 26)
  /// Use for: Large surfaces, bottom sheets, drawers
  static const SpringDescription gentleSpring = SpringDescription(
    mass: 1.0,
    stiffness: 200.0,
    damping: 26.0,
  );

  /// Responsive spring - Quick, snappy (stiffness: 400, damping: 35)
  /// Use for: Small components, toggles, chips, buttons
  static const SpringDescription responsiveSpring = SpringDescription(
    mass: 1.0,
    stiffness: 400.0,
    damping: 35.0,
  );

  // ============================================================================
  // DURATIONS (Fallback for platforms without spring support)
  // ============================================================================

  /// Short durations for quick, responsive actions
  static const Duration short1 = Duration(milliseconds: 50);
  static const Duration short2 = Duration(milliseconds: 100);
  static const Duration short3 = Duration(milliseconds: 150);
  static const Duration short4 = Duration(milliseconds: 200);

  /// Medium durations for standard transitions
  static const Duration medium1 = Duration(milliseconds: 250);
  static const Duration medium2 = Duration(milliseconds: 300);
  static const Duration medium3 = Duration(milliseconds: 350);
  static const Duration medium4 = Duration(milliseconds: 400);

  /// Long durations for emphasized, expressive transitions
  static const Duration long1 = Duration(milliseconds: 450);
  static const Duration long2 = Duration(milliseconds: 500);
  static const Duration long3 = Duration(milliseconds: 550);
  static const Duration long4 = Duration(milliseconds: 600);

  /// Extra long for large surface movements
  static const Duration extraLong1 = Duration(milliseconds: 700);
  static const Duration extraLong2 = Duration(milliseconds: 800);
  static const Duration extraLong3 = Duration(milliseconds: 900);
  static const Duration extraLong4 = Duration(milliseconds: 1000);

  // ============================================================================
  // EASING CURVES (Duration-based fallback)
  // ============================================================================

  /// Standard easing - Ease in and out with emphasis on acceleration
  /// Cubic bezier: (0.2, 0.0, 0, 1.0)
  static const Curve standard = Cubic(0.2, 0.0, 0, 1.0);

  /// Emphasized easing - More pronounced acceleration/deceleration
  /// Cubic bezier: (0.0, 0.0, 0, 1.0) - Emphasizes the final deceleration
  static const Curve emphasized = Cubic(0.0, 0.0, 0, 1.0);

  /// Emphasized decelerate - Quick start, gentle landing
  /// Cubic bezier: (0.05, 0.7, 0.1, 1.0)
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);

  /// Emphasized accelerate - Gentle start, quick exit
  /// Cubic bezier: (0.3, 0.0, 0.8, 0.15)
  static const Curve emphasizedAccelerate = Cubic(0.3, 0.0, 0.8, 0.15);

  /// Legacy easing (from M2) - Keep for backwards compatibility
  static const Curve legacy = Cubic(0.4, 0.0, 0.2, 1.0);

  // ============================================================================
  // HELPERS
  // ============================================================================

  /// Creates a spring simulation for a given spring description
  static SpringSimulation createSpringSimulation({
    required SpringDescription spring,
    required double start,
    required double end,
    double velocity = 0.0,
  }) {
    return SpringSimulation(
      spring,
      start,
      end,
      velocity,
    );
  }

  /// Get the estimated duration for a spring animation
  /// Useful for coordination with other animations
  static Duration getSpringDuration(SpringDescription spring) {
    // Approximate settling time based on damping ratio
    final dampingRatio = spring.damping / (2.0 * math.sqrt(spring.mass * spring.stiffness));

    if (dampingRatio < 1.0) {
      // Underdamped - has oscillation
      return const Duration(milliseconds: 600);
    } else if (dampingRatio == 1.0) {
      // Critically damped - no oscillation, fastest settling
      return const Duration(milliseconds: 400);
    } else {
      // Overdamped - slow settling
      return const Duration(milliseconds: 800);
    }
  }

  /// Creates a curved animation with appropriate M3E curve
  static Animation<double> createCurvedAnimation({
    required AnimationController controller,
    Curve? curve,
    Curve? reverseCurve,
  }) {
    return CurvedAnimation(
      parent: controller,
      curve: curve ?? emphasized,
      reverseCurve: reverseCurve ?? emphasized,
    );
  }
}

// ============================================================================
// MOTION PATTERNS (Common animation patterns ready to use)
// ============================================================================

/// Pre-configured motion patterns for common UI scenarios
class M3EMotionPatterns {
  M3EMotionPatterns._();

  /// Button press animation configuration
  static const Duration buttonPress = M3EMotion.short2;
  static const Curve buttonPressIn = M3EMotion.emphasizedAccelerate;
  static const Curve buttonPressOut = M3EMotion.emphasizedDecelerate;

  /// Card/Surface elevation change configuration
  static const Duration elevationChange = M3EMotion.short3;
  static const Curve elevationCurve = M3EMotion.standard;

  /// Ripple effect configuration
  static const Duration rippleDuration = M3EMotion.medium1;
  static const Curve rippleCurve = M3EMotion.standard;

  /// State layer (hover/focus/press) configuration
  static const Duration stateLayerIn = M3EMotion.short2;
  static const Duration stateLayerOut = M3EMotion.short3;
  static const Curve stateLayerCurve = Curves.linear;

  /// Dialog/Modal entrance configuration
  static const Duration modalEntrance = M3EMotion.medium3;
  static const Duration modalExit = M3EMotion.medium2;
  static const Curve modalCurve = M3EMotion.emphasized;

  /// Bottom sheet configuration
  static const SpringDescription bottomSheetSpring = M3EMotion.standardSpring;
  static const Duration bottomSheetFallback = M3EMotion.long2;

  /// Drawer slide configuration
  static const SpringDescription drawerSpring = M3EMotion.gentleSpring;
  static const Duration drawerFallback = M3EMotion.medium4;

  /// Chip select/deselect configuration
  static const Duration chipToggle = M3EMotion.short4;
  static const Curve chipCurve = M3EMotion.standard;

  /// Switch toggle configuration
  static const SpringDescription switchSpring = M3EMotion.responsiveSpring;
  static const Duration switchFallback = M3EMotion.medium1;

  /// Checkbox/Radio check configuration
  static const Duration checkDuration = M3EMotion.short4;
  static const Curve checkCurve = M3EMotion.emphasized;

  /// FAB expand/collapse configuration
  static const Duration fabTransform = M3EMotion.medium2;
  static const Curve fabCurve = M3EMotion.emphasized;

  /// Snackbar slide configuration
  static const SpringDescription snackbarSpring = M3EMotion.expressiveSpring;
  static const Duration snackbarFallback = M3EMotion.medium3;

  /// Tooltip fade configuration
  static const Duration tooltipIn = M3EMotion.short3;
  static const Duration tooltipOut = M3EMotion.short2;
  static const Curve tooltipCurve = Curves.linear;

  /// Menu cascade configuration
  static const Duration menuCascade = M3EMotion.short4;
  static const Curve menuCurve = M3EMotion.emphasizedDecelerate;

  /// Tab indicator slide configuration
  static const Duration tabIndicator = M3EMotion.medium1;
  static const Curve tabCurve = M3EMotion.standard;

  /// Loading spinner rotation configuration
  static const Duration spinnerRotation = Duration(milliseconds: 1332);
  static const Curve spinnerCurve = Curves.linear;

  /// Progress indicator configuration
  static const Duration progressUpdate = M3EMotion.medium2;
  static const Curve progressCurve = M3EMotion.standard;

  /// Carousel swipe configuration
  static const SpringDescription carouselSpring = M3EMotion.standardSpring;
  static const Duration carouselFallback = M3EMotion.medium3;
}

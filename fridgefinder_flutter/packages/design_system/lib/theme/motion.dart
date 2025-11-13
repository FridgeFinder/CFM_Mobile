import 'dart:math' as math;
import 'package:flutter/physics.dart';
import 'package:flutter/animation.dart';
import 'motion_settings.dart';

/// Material 3 Expressive Motion System
///
/// M3E uses spring-based motion for more natural, expressive animations.
/// Standard M3 uses duration-based easing curves.
///
/// This system provides both approaches with smooth fallbacks.
class M3EMotion {
  M3EMotion._();

  // ============================================================================
  // SPRING PHYSICS (M3E Expressive) - Research-Backed Constants
  // ============================================================================
  //
  // M3E uses two stiffness levels:
  // - StiffnessMedium: 1,500 (default for most animations)
  // - StiffnessHigh: 10,000 (fast, responsive micro-interactions)
  //
  // Damping Ratio determines bounce:
  // - Expressive (0.2-0.5): Noticeable overshoot, playful, consumer apps
  // - Standard (0.75-1.0): Minimal/no bounce, professional, business tools
  //
  // Formula: damping = dampingRatio × 2 × √(mass × stiffness)
  // ============================================================================

  // ---------------------------------------------------------------------------
  // SPATIAL TOKENS (WITH BOUNCE) - For position, size, orientation, shape
  // ---------------------------------------------------------------------------

  /// Expressive Fast Spatial: High stiffness (10,000), low damping (0.3)
  /// Use for: Quick micro-interactions with playful bounce (switches, chips)
  /// Duration: ~150-200ms with visible overshoot
  static const SpringDescription expressiveFastSpatial = SpringDescription(
    mass: 1.0,
    stiffness: 10000.0, // StiffnessHigh
    damping: 60.0, // dampingRatio 0.3
  );

  /// Expressive Default Spatial: Medium stiffness (1,500), medium damping (0.5)
  /// Use for: Standard expressive transitions (cards, dialogs, FABs)
  /// Duration: ~400-500ms with moderate bounce
  static const SpringDescription expressiveDefaultSpatial = SpringDescription(
    mass: 1.0,
    stiffness: 1500.0, // StiffnessMedium
    damping: 54.77, // dampingRatio 0.5 (medium bouncy)
  );

  /// Expressive Slow Spatial: Medium stiffness (1,500), low damping (0.3)
  /// Use for: Full-screen transitions, bottom sheets with emphasis
  /// Duration: ~600-800ms with more pronounced bounce
  static const SpringDescription expressiveSlowSpatial = SpringDescription(
    mass: 1.0,
    stiffness: 1500.0,
    damping: 32.86, // dampingRatio 0.3 (more bouncy)
  );

  /// Standard Fast Spatial: High stiffness (10,000), critical damping (1.0)
  /// Use for: Quick, professional micro-interactions (toggles, buttons)
  /// Duration: ~100-150ms with no bounce
  static const SpringDescription standardFastSpatial = SpringDescription(
    mass: 1.0,
    stiffness: 10000.0,
    damping: 200.0, // dampingRatio 1.0 (critically damped, no bounce)
  );

  /// Standard Default Spatial: Medium stiffness (1,500), near-critical damping (0.85)
  /// Use for: Professional UI transitions (modals, navigation)
  /// Duration: ~300-400ms with minimal bounce
  static const SpringDescription standardDefaultSpatial = SpringDescription(
    mass: 1.0,
    stiffness: 1500.0,
    damping: 65.83, // dampingRatio 0.85
  );

  /// Standard Slow Spatial: Medium stiffness (1,500), high damping (0.75)
  /// Use for: Large surface movements in business contexts
  /// Duration: ~500-600ms with very subtle bounce
  static const SpringDescription standardSlowSpatial = SpringDescription(
    mass: 1.0,
    stiffness: 1500.0,
    damping: 58.09, // dampingRatio 0.75
  );

  // ---------------------------------------------------------------------------
  // EFFECT TOKENS (NO BOUNCE) - For color, opacity
  // ---------------------------------------------------------------------------

  /// Expressive Fast Effect: High stiffness (10,000), overdamped (1.2)
  /// Use for: Quick color/opacity changes with smooth deceleration
  /// Duration: ~100-150ms with smooth ease-out
  static const SpringDescription expressiveFastEffect = SpringDescription(
    mass: 1.0,
    stiffness: 10000.0,
    damping: 240.0, // dampingRatio 1.2 (overdamped, smooth)
  );

  /// Expressive Default Effect: Medium stiffness (1,500), overdamped (1.2)
  /// Use for: Standard color/opacity transitions
  /// Duration: ~250-350ms with smooth ease-out
  static const SpringDescription expressiveDefaultEffect = SpringDescription(
    mass: 1.0,
    stiffness: 1500.0,
    damping: 92.95, // dampingRatio 1.2
  );

  /// Expressive Slow Effect: Medium stiffness (1,500), heavily overdamped (1.5)
  /// Use for: Gradual color shifts, fade transitions
  /// Duration: ~400-500ms with very smooth deceleration
  static const SpringDescription expressiveSlowEffect = SpringDescription(
    mass: 1.0,
    stiffness: 1500.0,
    damping: 116.19, // dampingRatio 1.5
  );

  /// Standard Effect (All Speeds): Critical damping for professional feel
  /// Use for: Any color/opacity change in business/professional contexts
  /// Duration: Varies by stiffness, always smooth with no bounce
  static const SpringDescription standardFastEffect = SpringDescription(
    mass: 1.0,
    stiffness: 10000.0,
    damping: 200.0, // dampingRatio 1.0
  );

  static const SpringDescription standardDefaultEffect = SpringDescription(
    mass: 1.0,
    stiffness: 1500.0,
    damping: 77.46, // dampingRatio 1.0
  );

  static const SpringDescription standardSlowEffect = SpringDescription(
    mass: 1.0,
    stiffness: 1500.0,
    damping: 77.46, // dampingRatio 1.0
  );

  // ---------------------------------------------------------------------------
  // LEGACY SPRINGS (Backwards compatibility - use new tokens above)
  // ---------------------------------------------------------------------------

  /// @deprecated Use expressiveDefaultSpatial instead
  static const SpringDescription expressiveSpring = expressiveDefaultSpatial;

  /// @deprecated Use standardDefaultSpatial instead
  static const SpringDescription standardSpring = standardDefaultSpatial;

  /// @deprecated Use standardSlowSpatial instead
  static const SpringDescription gentleSpring = standardSlowSpatial;

  /// @deprecated Use expressiveFastSpatial or standardFastSpatial instead
  static const SpringDescription responsiveSpring = expressiveFastSpatial;

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
  //
  // M3E introduces overshoot curves where y-values exceed 1.0, creating bounce
  // These approximate spring physics when springs aren't available
  // ============================================================================

  // ---------------------------------------------------------------------------
  // OVERSHOOT CURVES (M3E Expressive Fallbacks)
  // ---------------------------------------------------------------------------

  /// Expressive Fast Overshoot: Quick with noticeable bounce
  /// Cubic bezier: (0.34, 1.56, 0.64, 1.0) - y2=1.56 creates 56% overshoot
  /// Approximates expressiveFastSpatial spring (dampingRatio 0.3)
  static const Curve expressiveFastOvershoot = Cubic(0.34, 1.56, 0.64, 1.0);

  /// Expressive Default Overshoot: Standard timing with moderate bounce
  /// Cubic bezier: (0.05, 1.35, 0.3, 1.0) - y2=1.35 creates 35% overshoot
  /// Approximates expressiveDefaultSpatial spring (dampingRatio 0.5)
  static const Curve expressiveDefaultOvershoot = Cubic(0.05, 1.35, 0.3, 1.0);

  /// Expressive Slow Overshoot: Gradual with pronounced bounce
  /// Cubic bezier: (0.0, 1.45, 0.2, 1.0) - y2=1.45 creates 45% overshoot
  /// Approximates expressiveSlowSpatial spring (dampingRatio 0.3)
  static const Curve expressiveSlowOvershoot = Cubic(0.0, 1.45, 0.2, 1.0);

  // ---------------------------------------------------------------------------
  // SMOOTH CURVES (Standard/Effect Fallbacks)
  // ---------------------------------------------------------------------------

  /// Standard easing - Ease in and out with emphasis on acceleration
  /// Cubic bezier: (0.2, 0.0, 0, 1.0)
  /// No overshoot, professional feel for business contexts
  static const Curve standard = Cubic(0.2, 0.0, 0, 1.0);

  /// Emphasized easing - More pronounced acceleration/deceleration
  /// Cubic bezier: (0.0, 0.0, 0, 1.0) - Emphasizes the final deceleration
  /// Recommended for most M3E transitions without bounce
  static const Curve emphasized = Cubic(0.0, 0.0, 0, 1.0);

  /// Emphasized decelerate - Quick start, gentle landing
  /// Cubic bezier: (0.05, 0.7, 0.1, 1.0)
  /// Great for entrances and appearing elements
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);

  /// Emphasized accelerate - Gentle start, quick exit
  /// Cubic bezier: (0.3, 0.0, 0.8, 0.15)
  /// Great for exits and disappearing elements
  static const Curve emphasizedAccelerate = Cubic(0.3, 0.0, 0.8, 0.15);

  /// Effect Smooth - Overdamped feel for color/opacity (no overshoot)
  /// Cubic bezier: (0.4, 0.0, 0.2, 1.0)
  /// Use for effect tokens when springs aren't available
  static const Curve effectSmooth = Cubic(0.4, 0.0, 0.2, 1.0);

  /// Legacy easing (from M2) - Keep for backwards compatibility
  /// Cubic bezier: (0.4, 0.0, 0.2, 1.0)
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

  // ============================================================================
  // ACCESSIBILITY HELPERS (Reduce Motion)
  // ============================================================================

  /// Get motion-aware duration respecting user accessibility preferences
  static Duration getDuration(Duration normal) {
    return MotionSettings.getDuration(normal);
  }

  /// Get motion-aware duration with optional partial reduction
  static Duration getDurationReduced(
    Duration normal, {
    double percentageWhenReduced = 0.3,
  }) {
    return MotionSettings.getDurationReduced(
      normal,
      percentageWhenReduced: percentageWhenReduced,
    );
  }

  /// Get motion-aware curve respecting user accessibility preferences
  static Curve getCurve(Curve normal) {
    return MotionSettings.getCurve(normal);
  }

  /// Get motion-aware spring respecting user accessibility preferences
  static SpringDescription getSpring(SpringDescription normal) {
    return MotionSettings.getSpring(normal);
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

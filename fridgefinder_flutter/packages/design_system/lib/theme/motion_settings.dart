import 'package:flutter/material.dart';

/// M3E Motion Settings Manager
///
/// Handles accessibility requirements for motion-sensitive users.
/// WCAG 2.3.3: Motion animation triggered by interaction must be disableable.
///
/// Motion sensitivity affects 16% of people with disabilities, including:
/// - Vestibular disorders (inner ear balance disorders)
/// - Epilepsy (photosensitivity)
/// - Migraine-related motion sensitivity
///
/// This system provides:
/// - Global reduce motion setting
/// - Automatic duration reduction (60-80%)
/// - Curve linearization for reduced motion
/// - Intensity scaling for animations
/// - Spring physics dampening when reduced motion is enabled
class MotionSettings {
  MotionSettings._();

  /// Whether to reduce motion for accessibility
  static bool _reduceMotion = false;

  /// Get current reduce motion setting
  static bool get reduceMotion => _reduceMotion;

  /// Set reduce motion preference
  ///
  /// When enabled:
  /// - Animation durations reduced by 70% (e.g., 500ms → 150ms)
  /// - Curves linearized for predictable motion
  /// - Spring physics over-damped for minimal oscillation
  /// - Scale and position changes minimized
  static set reduceMotion(bool value) {
    _reduceMotion = value;
    _notifyListeners();
  }

  /// Toggle reduce motion on/off
  static void toggle() {
    _reduceMotion = !_reduceMotion;
    _notifyListeners();
  }

  // ============================================================================
  // DURATION HELPERS
  // ============================================================================

  /// Get motion-aware duration
  ///
  /// Returns zero duration when reduced motion is enabled,
  /// otherwise returns the provided normal duration.
  ///
  /// This completely disables animation, keeping layout and functionality intact.
  ///
  /// Usage:
  /// ```dart
  /// AnimationController(
  ///   duration: MotionSettings.getDuration(const Duration(milliseconds: 500)),
  ///   vsync: this,
  /// )
  /// ```
  static Duration getDuration(Duration normal) {
    if (!_reduceMotion) return normal;

    // Reduced motion: instant transition
    // This ensures no motion-triggered animation occurs
    return Duration.zero;
  }

  /// Get motion-aware duration with percentage reduction
  ///
  /// When reduced motion is disabled, returns normal duration.
  /// When reduced motion is enabled, returns percentage of normal duration.
  /// Default is 30% (70% reduction) to meet WCAG requirement.
  ///
  /// Usage:
  /// ```dart
  /// // For softer animations that can tolerate some motion
  /// final duration = MotionSettings.getDurationReduced(
  ///   const Duration(milliseconds: 500),
  ///   percentageWhenReduced: 0.3, // 30% of original = 150ms
  /// );
  /// ```
  static Duration getDurationReduced(
    Duration normal, {
    double percentageWhenReduced = 0.3,
  }) {
    if (!_reduceMotion) return normal;

    return Duration(
      milliseconds: (normal.inMilliseconds * percentageWhenReduced).toInt(),
    );
  }

  // ============================================================================
  // CURVE HELPERS
  // ============================================================================

  /// Get motion-aware curve
  ///
  /// Returns linear curve when reduced motion is enabled,
  /// otherwise returns the provided normal curve.
  ///
  /// Linear curves provide predictable, steady-paced motion
  /// without acceleration/deceleration effects that can be disorienting.
  ///
  /// Usage:
  /// ```dart
  /// CurvedAnimation(
  ///   parent: controller,
  ///   curve: MotionSettings.getCurve(Curves.easeInOut),
  /// )
  /// ```
  static Curve getCurve(Curve normal) {
    if (!_reduceMotion) return normal;
    return Curves.linear;
  }

  // ============================================================================
  // INTENSITY HELPERS
  // ============================================================================

  /// Get motion-aware intensity
  ///
  /// Reduces animation intensity (scale, offset, opacity changes) by percentage.
  /// Default is 30% (70% reduction).
  ///
  /// Intensity is applied to:
  /// - Scale values (0.8 becomes 0.94 with 70% reduction)
  /// - Offset distances (proportional reduction)
  /// - Opacity changes (20% opacity swing becomes 6%)
  ///
  /// Usage:
  /// ```dart
  /// final scaleBegin = MotionSettings.getIntensity(0.8);
  /// // With reduce motion: 0.8 + (1.0 - 0.8) * 0.3 = 0.94 (moves toward 1.0)
  /// ```
  static double getIntensity(
    double normal, {
    double reductionPercentage = 0.7,
  }) {
    if (!_reduceMotion) return normal;

    // Intensity reduction: move value closer to 1.0 (no change)
    // This preserves the effect direction while minimizing magnitude
    final diff = (normal - 1.0).abs();
    final reducedDiff = diff * (1.0 - reductionPercentage);

    return normal > 1.0
        ? 1.0 + reducedDiff
        : 1.0 - reducedDiff;
  }

  /// Get offset with reduced motion
  ///
  /// Reduces the distance of offset animations.
  /// Useful for slide transitions and spatial movements.
  ///
  /// Usage:
  /// ```dart
  /// final offset = MotionSettings.getOffset(
  ///   const Offset(0, 1),
  ///   reductionPercentage: 0.7,
  /// );
  /// // With reduce motion: Offset(0, 0.3) instead of Offset(0, 1)
  /// ```
  static Offset getOffset(
    Offset normal, {
    double reductionPercentage = 0.7,
  }) {
    if (!_reduceMotion) return normal;

    return Offset(
      normal.dx * (1.0 - reductionPercentage),
      normal.dy * (1.0 - reductionPercentage),
    );
  }

  // ============================================================================
  // SPRING PHYSICS HELPERS
  // ============================================================================

  /// Get spring description with reduce motion dampening
  ///
  /// When reduced motion is enabled, increases damping ratio
  /// to minimize oscillation and settle motion quickly.
  ///
  /// Usage in spring-based animations:
  /// ```dart
  /// final spring = MotionSettings.getSpring(
  ///   M3EMotion.standardSpring,
  /// );
  /// ```
  static SpringDescription getSpring(SpringDescription normal) {
    if (!_reduceMotion) return normal;

    // Increase damping by 50% to minimize oscillation
    // This makes spring animations settle without bouncing
    return SpringDescription(
      mass: normal.mass,
      stiffness: normal.stiffness * 0.8, // Slightly slower response
      damping: normal.damping * 1.5, // More damping = less oscillation
    );
  }

  // ============================================================================
  // LISTENER SYSTEM
  // ============================================================================

  static final List<VoidCallback> _listeners = [];

  /// Listen to reduce motion setting changes
  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Stop listening to reduce motion setting changes
  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners of setting change
  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Clear all listeners (useful for cleanup)
  static void clearListeners() {
    _listeners.clear();
  }

  // ============================================================================
  // DEBUG & TESTING
  // ============================================================================

  /// Reset to default settings (for testing)
  static void reset() {
    _reduceMotion = false;
    _notifyListeners();
  }
}

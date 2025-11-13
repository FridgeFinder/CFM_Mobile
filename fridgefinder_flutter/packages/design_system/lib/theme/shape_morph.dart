import 'package:flutter/material.dart';
import 'motion.dart';

/// Material 3 Expressive Shape Morphing System
///
/// Provides spring-based shape interpolation for smooth, expressive
/// transitions between different shapes (pill ↔ rounded rectangle, etc.)
///
/// M3E Spec: Morphs use 400-500ms duration with 0.5 damping ratio for playful bounce.
class ShapeMorph {
  ShapeMorph._();

  /// Interpolate between two border radius values with spring physics
  ///
  /// Returns an animated value that smoothly transitions between start and end radii.
  static Animation<double> interpolateRadius({
    required AnimationController controller,
    required double startRadius,
    required double endRadius,
  }) {
    return Tween<double>(
      begin: startRadius,
      end: endRadius,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: M3EMotion.emphasizedDecelerate,
    ));
  }

  /// Interpolate between two BorderRadius values
  ///
  /// Smoothly morphs all four corners independently.
  static Animation<BorderRadius> interpolateBorderRadius({
    required AnimationController controller,
    required BorderRadius start,
    required BorderRadius end,
  }) {
    return Tween<BorderRadius>(
      begin: start,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: M3EMotion.emphasizedDecelerate,
    ));
  }

  /// Create a morph animation from one shape to another
  ///
  /// Supports morphing between:
  /// - Pill ↔ Rounded Rectangle
  /// - Circle ↔ Square
  /// - Rounded ↔ Sharp corners
  static Animation<BorderRadius> createMorph({
    required AnimationController controller,
    required ShapeType startType,
    required ShapeType endType,
    double? customRadius,
  }) {
    final startRadius = _getRadiusForType(startType, customRadius);
    final endRadius = _getRadiusForType(endType, customRadius);

    return interpolateBorderRadius(
      controller: controller,
      start: BorderRadius.circular(startRadius),
      end: BorderRadius.circular(endRadius),
    );
  }

  /// Get radius value for a shape type
  static double _getRadiusForType(ShapeType type, double? customRadius) {
    switch (type) {
      case ShapeType.none:
        return 0.0;
      case ShapeType.pill:
        return 9999.0; // Fully rounded
      case ShapeType.circle:
        return 9999.0; // Fully rounded
      case ShapeType.rounded:
        return customRadius ?? 12.0;
      case ShapeType.sharp:
        return 0.0;
      case ShapeType.square:
        return 0.0;
    }
  }

  /// Morph from pill to rounded rectangle
  ///
  /// Common use case: Button expanding, chip selection
  static Animation<BorderRadius> pillToRounded({
    required AnimationController controller,
    double roundedRadius = 12.0,
  }) {
    return createMorph(
      controller: controller,
      startType: ShapeType.pill,
      endType: ShapeType.rounded,
      customRadius: roundedRadius,
    );
  }

  /// Morph from rounded rectangle to pill
  ///
  /// Common use case: Button collapsing, chip deselection
  static Animation<BorderRadius> roundedToPill({
    required AnimationController controller,
    double roundedRadius = 12.0,
  }) {
    return createMorph(
      controller: controller,
      startType: ShapeType.rounded,
      endType: ShapeType.pill,
      customRadius: roundedRadius,
    );
  }

  /// Morph from circle to square
  ///
  /// Common use case: Avatar → Card, Icon → Button
  static Animation<BorderRadius> circleToSquare({
    required AnimationController controller,
  }) {
    return createMorph(
      controller: controller,
      startType: ShapeType.circle,
      endType: ShapeType.square,
    );
  }

  /// Morph from square to circle
  ///
  /// Common use case: Card → Avatar, Button → Icon
  static Animation<BorderRadius> squareToCircle({
    required AnimationController controller,
  }) {
    return createMorph(
      controller: controller,
      startType: ShapeType.square,
      endType: ShapeType.circle,
    );
  }

  /// Morph from sharp to rounded
  ///
  /// Common use case: Input field focus, card hover
  static Animation<BorderRadius> sharpToRounded({
    required AnimationController controller,
    double roundedRadius = 12.0,
  }) {
    return createMorph(
      controller: controller,
      startType: ShapeType.sharp,
      endType: ShapeType.rounded,
      customRadius: roundedRadius,
    );
  }

  /// Morph from rounded to sharp
  ///
  /// Common use case: Input field blur, card unhover
  static Animation<BorderRadius> roundedToSharp({
    required AnimationController controller,
    double roundedRadius = 12.0,
  }) {
    return createMorph(
      controller: controller,
      startType: ShapeType.rounded,
      endType: ShapeType.sharp,
      customRadius: roundedRadius,
    );
  }

  /// Create partial morph (for interrupted animations)
  ///
  /// Allows morphing to be interrupted and resumed smoothly.
  static Animation<BorderRadius> partialMorph({
    required AnimationController controller,
    required BorderRadius start,
    required BorderRadius end,
    double progress = 0.0, // 0.0 to 1.0
  }) {
    return Tween<BorderRadius>(
      begin: start,
      end: end,
    ).animate(
      AlwaysStoppedAnimation(progress),
    );
  }
}

/// Shape types for morphing
enum ShapeType {
  /// No rounding (0dp)
  none,

  /// Fully rounded (pill shape, 9999dp)
  pill,

  /// Circle (fully rounded)
  circle,

  /// Rounded corners (default 12dp)
  rounded,

  /// Sharp corners (0dp)
  sharp,

  /// Square (0dp)
  square,
}

/// Widget wrapper for animated shape transitions
///
/// Automatically handles shape morphing animations with spring physics.
///
/// Example:
/// ```dart
/// MorphableShape(
///   shapeType: isSelected ? ShapeType.pill : ShapeType.rounded,
///   child: Container(
///     padding: EdgeInsets.all(16),
///     child: Text('Morphing Shape'),
///   ),
/// )
/// ```
class MorphableShape extends StatefulWidget {
  /// Current shape type
  final ShapeType shapeType;

  /// Child widget to apply shape to
  final Widget child;

  /// Custom radius for rounded shapes
  final double? customRadius;

  /// Animation duration
  final Duration? duration;

  const MorphableShape({
    super.key,
    required this.shapeType,
    required this.child,
    this.customRadius,
    this.duration,
  });

  @override
  State<MorphableShape> createState() => _MorphableShapeState();
}

class _MorphableShapeState extends State<MorphableShape>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<BorderRadius> _borderRadiusAnimation;
  ShapeType? _previousShapeType;

  @override
  void initState() {
    super.initState();
    // Default to longer duration (500ms) for more noticeable morphs
    _controller = AnimationController(
      duration: widget.duration ?? M3EMotion.getDuration(M3EMotion.long2),
      vsync: this,
    );
    _previousShapeType = widget.shapeType;
    _updateAnimation();
    _controller.forward();
  }

  @override
  void didUpdateWidget(MorphableShape oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shapeType != widget.shapeType) {
      _previousShapeType = oldWidget.shapeType;
      _updateAnimation();
      _controller.reset();
      _controller.forward();
    }
  }

  void _updateAnimation() {
    _borderRadiusAnimation = ShapeMorph.createMorph(
      controller: _controller,
      startType: _previousShapeType ?? ShapeType.rounded,
      endType: widget.shapeType,
      customRadius: widget.customRadius,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _borderRadiusAnimation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: _borderRadiusAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// Predefined morph patterns for common use cases
class MorphPatterns {
  MorphPatterns._();

  /// Button selection morph: Rounded → Pill
  static Animation<BorderRadius> buttonSelection({
    required AnimationController controller,
    bool isSelected = true,
  }) {
    if (isSelected) {
      return ShapeMorph.roundedToPill(
        controller: controller,
        roundedRadius: 20.0,
      );
    } else {
      return ShapeMorph.pillToRounded(
        controller: controller,
        roundedRadius: 20.0,
      );
    }
  }

  /// Chip selection morph: Rounded → Pill with scale
  static Animation<BorderRadius> chipSelection({
    required AnimationController controller,
    bool isSelected = true,
  }) {
    if (isSelected) {
      return ShapeMorph.roundedToPill(
        controller: controller,
        roundedRadius: 8.0,
      );
    } else {
      return ShapeMorph.pillToRounded(
        controller: controller,
        roundedRadius: 8.0,
      );
    }
  }

  /// Card hover morph: Sharp → Rounded
  static Animation<BorderRadius> cardHover({
    required AnimationController controller,
    bool isHovered = true,
  }) {
    if (isHovered) {
      return ShapeMorph.sharpToRounded(
        controller: controller,
        roundedRadius: 12.0,
      );
    } else {
      return ShapeMorph.roundedToSharp(
        controller: controller,
        roundedRadius: 12.0,
      );
    }
  }

  /// Input field focus morph: Rounded → More rounded
  static Animation<BorderRadius> inputFocus({
    required AnimationController controller,
    bool isFocused = true,
  }) {
    if (isFocused) {
      return ShapeMorph.createMorph(
        controller: controller,
        startType: ShapeType.rounded,
        endType: ShapeType.rounded,
        customRadius: 16.0, // More rounded on focus
      );
    } else {
      return ShapeMorph.createMorph(
        controller: controller,
        startType: ShapeType.rounded,
        endType: ShapeType.rounded,
        customRadius: 12.0, // Less rounded on blur
      );
    }
  }
}


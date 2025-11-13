import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/motion.dart';
import '../theme/spacing.dart';

/// M3E Morphing Shape Loading Indicator
///
/// A sophisticated, organic loading indicator that embodies M3E philosophy
/// through expressive shape transformations. Features multiple animation
/// variants with smooth shape morphing at 60fps.
///
/// Design Concepts:
/// 1. **Shape Morphing** - Smooth transitions between geometric shapes
/// 2. **Blob Morph** - Organic blob with bezier curve transformations
/// 3. **Connected Dots** - Dynamic pattern formation
/// 4. **Breathing Shape** - Living, pulsing geometry
/// 5. **Liquid Flow** - Fluid, flowing shapes
///
/// Example:
/// ```dart
/// MorphingLoadingIndicatorM3E.shapeMorph()
/// MorphingLoadingIndicatorM3E.blobMorph()
/// MorphingLoadingIndicatorM3E.connectedDots()
/// MorphingLoadingIndicatorM3E.breathing()
/// MorphingLoadingIndicatorM3E.liquidFlow()
/// ```
class MorphingLoadingIndicatorM3E extends StatefulWidget {
  /// Variant of the morphing animation
  final MorphingVariant variant;

  /// Size of the indicator (default: 64dp for fullscreen, 48dp for inline)
  final double size;

  /// Primary color (defaults to theme primary)
  final Color? color;

  /// Optional message to display below indicator
  final String? message;

  /// Whether this is a fullscreen variant
  final bool fullscreen;

  const MorphingLoadingIndicatorM3E({
    super.key,
    required this.variant,
    this.size = 64.0,
    this.color,
    this.message,
    this.fullscreen = false,
  });

  /// Shape morphing variant - circle → square → rounded square → circle
  const MorphingLoadingIndicatorM3E.shapeMorph({
    super.key,
    this.size = 64.0,
    this.color,
    this.message,
    this.fullscreen = false,
  }) : variant = MorphingVariant.shapeMorph;

  /// Blob morph variant - organic blob with bezier curves
  const MorphingLoadingIndicatorM3E.blobMorph({
    super.key,
    this.size = 64.0,
    this.color,
    this.message,
    this.fullscreen = false,
  }) : variant = MorphingVariant.blobMorph;

  /// Connected dots variant - 4 dots forming patterns
  const MorphingLoadingIndicatorM3E.connectedDots({
    super.key,
    this.size = 64.0,
    this.color,
    this.message,
    this.fullscreen = false,
  }) : variant = MorphingVariant.connectedDots;

  /// Breathing shape variant - shape that breathes by morphing corners
  const MorphingLoadingIndicatorM3E.breathing({
    super.key,
    this.size = 64.0,
    this.color,
    this.message,
    this.fullscreen = false,
  }) : variant = MorphingVariant.breathing;

  /// Liquid flow variant - flowing liquid-like shapes
  const MorphingLoadingIndicatorM3E.liquidFlow({
    super.key,
    this.size = 64.0,
    this.color,
    this.message,
    this.fullscreen = false,
  }) : variant = MorphingVariant.liquidFlow;

  /// Fullscreen shape morph
  const MorphingLoadingIndicatorM3E.fullscreenShapeMorph({
    super.key,
    this.color,
    this.message,
  })  : variant = MorphingVariant.shapeMorph,
        size = 64.0,
        fullscreen = true;

  /// Fullscreen blob morph
  const MorphingLoadingIndicatorM3E.fullscreenBlobMorph({
    super.key,
    this.color,
    this.message,
  })  : variant = MorphingVariant.blobMorph,
        size = 64.0,
        fullscreen = true;

  /// Inline shape morph (smaller, 48dp)
  const MorphingLoadingIndicatorM3E.inlineShapeMorph({
    super.key,
    this.color,
    this.message,
  })  : variant = MorphingVariant.shapeMorph,
        size = 48.0,
        fullscreen = false;

  /// Inline blob morph (smaller, 48dp)
  const MorphingLoadingIndicatorM3E.inlineBlobMorph({
    super.key,
    this.color,
    this.message,
  })  : variant = MorphingVariant.blobMorph,
        size = 48.0,
        fullscreen = false;

  @override
  State<MorphingLoadingIndicatorM3E> createState() =>
      _MorphingLoadingIndicatorM3EState();
}

class _MorphingLoadingIndicatorM3EState
    extends State<MorphingLoadingIndicatorM3E>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = widget.color ?? colorScheme.primary;

    Widget indicator;
    switch (widget.variant) {
      case MorphingVariant.shapeMorph:
        indicator = _ShapeMorphPainter(
          animation: _controller,
          color: effectiveColor,
          size: widget.size,
        );
        break;
      case MorphingVariant.blobMorph:
        indicator = _BlobMorphPainter(
          animation: _controller,
          color: effectiveColor,
          size: widget.size,
        );
        break;
      case MorphingVariant.connectedDots:
        indicator = _ConnectedDotsPainter(
          animation: _controller,
          color: effectiveColor,
          size: widget.size,
        );
        break;
      case MorphingVariant.breathing:
        indicator = _BreathingShapePainter(
          animation: _controller,
          color: effectiveColor,
          size: widget.size,
        );
        break;
      case MorphingVariant.liquidFlow:
        indicator = _LiquidFlowPainter(
          animation: _controller,
          color: effectiveColor,
          size: widget.size,
        );
        break;
    }

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        indicator,
        if (widget.message != null) ...[
          M3ESpacing.verticalMD,
          Text(
            widget.message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (widget.fullscreen) {
      return Center(child: content);
    }

    return content;
  }
}

/// Morphing animation variants
enum MorphingVariant {
  shapeMorph,
  blobMorph,
  connectedDots,
  breathing,
  liquidFlow,
}

/// Shape Morph Painter - Circle → Square → Rounded Square → Circle
class _ShapeMorphPainter extends StatelessWidget {
  final Animation<double> animation;
  final Color color;
  final double size;

  const _ShapeMorphPainter({
    required this.animation,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(size, size),
          painter: _ShapeMorphCustomPainter(
            progress: animation.value,
            color: color,
          ),
        );
      },
    );
  }
}

class _ShapeMorphCustomPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ShapeMorphCustomPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.7;

    // 4 phases: circle → square → rounded square → circle
    // Each phase: 0.25 duration
    final phase = (progress * 4) % 4;

    if (phase < 1) {
      // Phase 0: Circle → Square
      _drawCircleToSquare(canvas, paint, center, radius, phase);
    } else if (phase < 2) {
      // Phase 1: Square → Rounded Square
      _drawSquareToRounded(canvas, paint, center, radius, phase - 1);
    } else if (phase < 3) {
      // Phase 2: Rounded Square → Sharp Square
      _drawRoundedToSquare(canvas, paint, center, radius, phase - 2);
    } else {
      // Phase 3: Square → Circle
      _drawSquareToCircle(canvas, paint, center, radius, phase - 3);
    }
  }

  void _drawCircleToSquare(
      Canvas canvas, Paint paint, Offset center, double radius, double t) {
    // Apply emphasized decelerate curve
    final curvedT = M3EMotion.emphasizedDecelerate.transform(t);

    final path = Path();
    final points = <Offset>[];

    // Generate points that morph from circle to square
    for (int i = 0; i < 60; i++) {
      final angle = (i / 60) * 2 * math.pi;
      final x = math.cos(angle);
      final y = math.sin(angle);

      // Circle point
      final circlePoint = Offset(
        center.dx + x * radius,
        center.dy + y * radius,
      );

      // Square point (max of x or y)
      final squareRadius = radius / math.max(x.abs(), y.abs());
      final squarePoint = Offset(
        center.dx + x * squareRadius,
        center.dy + y * squareRadius,
      );

      // Interpolate
      points.add(Offset.lerp(circlePoint, squarePoint, curvedT)!);
    }

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawSquareToRounded(
      Canvas canvas, Paint paint, Offset center, double radius, double t) {
    final curvedT = M3EMotion.emphasizedDecelerate.transform(t);
    final cornerRadius = radius * 0.3 * curvedT;

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
      Radius.circular(cornerRadius),
    );

    canvas.drawRRect(rect, paint);
  }

  void _drawRoundedToSquare(
      Canvas canvas, Paint paint, Offset center, double radius, double t) {
    final curvedT = M3EMotion.emphasizedDecelerate.transform(t);
    final cornerRadius = radius * 0.3 * (1 - curvedT);

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
      Radius.circular(cornerRadius),
    );

    canvas.drawRRect(rect, paint);
  }

  void _drawSquareToCircle(
      Canvas canvas, Paint paint, Offset center, double radius, double t) {
    final curvedT = M3EMotion.emphasizedDecelerate.transform(t);

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < 60; i++) {
      final angle = (i / 60) * 2 * math.pi;
      final x = math.cos(angle);
      final y = math.sin(angle);

      // Square point
      final squareRadius = radius / math.max(x.abs(), y.abs());
      final squarePoint = Offset(
        center.dx + x * squareRadius,
        center.dy + y * squareRadius,
      );

      // Circle point
      final circlePoint = Offset(
        center.dx + x * radius,
        center.dy + y * radius,
      );

      // Interpolate
      points.add(Offset.lerp(squarePoint, circlePoint, curvedT)!);
    }

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ShapeMorphCustomPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Blob Morph Painter - Organic blob with bezier curves
class _BlobMorphPainter extends StatelessWidget {
  final Animation<double> animation;
  final Color color;
  final double size;

  const _BlobMorphPainter({
    required this.animation,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(size, size),
          painter: _BlobMorphCustomPainter(
            progress: animation.value,
            color: color,
          ),
        );
      },
    );
  }
}

class _BlobMorphCustomPainter extends CustomPainter {
  final double progress;
  final Color color;

  _BlobMorphCustomPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2 * 0.6;

    final path = Path();

    // Create organic blob with 8 control points
    final controlPoints = 8;
    final angleStep = (2 * math.pi) / controlPoints;

    final points = <Offset>[];
    for (int i = 0; i < controlPoints; i++) {
      final angle = i * angleStep + progress * 2 * math.pi;

      // Vary radius with sine waves for organic feel
      final radiusVariation = math.sin(progress * 4 * math.pi + i * 0.7) * 0.3;
      final radius = baseRadius * (1 + radiusVariation);

      // Add wobble
      final wobble = math.sin(progress * 6 * math.pi + i * 1.2) * 0.1;
      final effectiveRadius = radius * (1 + wobble);

      points.add(Offset(
        center.dx + math.cos(angle) * effectiveRadius,
        center.dy + math.sin(angle) * effectiveRadius,
      ));
    }

    // Draw smooth curves through points using quadratic bezier
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < controlPoints; i++) {
      final current = points[i];
      final next = points[(i + 1) % controlPoints];

      // Control point between current and next
      final controlPoint = Offset(
        (current.dx + next.dx) / 2 + math.sin(progress * 8 * math.pi + i) * 5,
        (current.dy + next.dy) / 2 + math.cos(progress * 8 * math.pi + i) * 5,
      );

      path.quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        next.dx,
        next.dy,
      );
    }

    path.close();
    canvas.drawPath(path, paint);

    // Add surface tint effect
    final tintPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final tintPath = Path();
    final tintRadius = baseRadius * 0.7;
    final tintPoints = <Offset>[];

    for (int i = 0; i < controlPoints; i++) {
      final angle = i * angleStep + progress * 2 * math.pi + math.pi / 8;
      final radiusVariation = math.sin(progress * 4 * math.pi + i * 0.7) * 0.2;
      final radius = tintRadius * (1 + radiusVariation);

      tintPoints.add(Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      ));
    }

    tintPath.moveTo(tintPoints[0].dx, tintPoints[0].dy);
    for (int i = 0; i < controlPoints; i++) {
      final current = tintPoints[i];
      final next = tintPoints[(i + 1) % controlPoints];
      final controlPoint = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );
      tintPath.quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        next.dx,
        next.dy,
      );
    }
    tintPath.close();

    canvas.drawPath(tintPath, tintPaint);
  }

  @override
  bool shouldRepaint(_BlobMorphCustomPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Connected Dots Painter - 4 dots forming patterns
class _ConnectedDotsPainter extends StatelessWidget {
  final Animation<double> animation;
  final Color color;
  final double size;

  const _ConnectedDotsPainter({
    required this.animation,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(size, size),
          painter: _ConnectedDotsCustomPainter(
            progress: animation.value,
            color: color,
          ),
        );
      },
    );
  }
}

class _ConnectedDotsCustomPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ConnectedDotsCustomPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.6;
    final dotRadius = size.width * 0.08;

    // 4 dots in a circle, rotating and pulsing
    final dots = <Offset>[];
    for (int i = 0; i < 4; i++) {
      final angle = (i / 4) * 2 * math.pi + progress * 2 * math.pi;
      final distance =
          radius * (1 + math.sin(progress * 4 * math.pi + i) * 0.2);
      dots.add(Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      ));
    }

    // Draw connecting lines
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < dots.length; i++) {
      for (int j = i + 1; j < dots.length; j++) {
        canvas.drawLine(dots[i], dots[j], linePaint);
      }
    }

    // Draw dots
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < dots.length; i++) {
      final pulseFactor = 1 + math.sin(progress * 4 * math.pi + i * 0.5) * 0.3;
      canvas.drawCircle(dots[i], dotRadius * pulseFactor, dotPaint);
    }

    // Draw center connection
    final centerPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      center,
      dotRadius * 0.5 * (1 + math.sin(progress * 4 * math.pi) * 0.3),
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(_ConnectedDotsCustomPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Breathing Shape Painter - Shape that breathes
class _BreathingShapePainter extends StatelessWidget {
  final Animation<double> animation;
  final Color color;
  final double size;

  const _BreathingShapePainter({
    required this.animation,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(size, size),
          painter: _BreathingShapeCustomPainter(
            progress: animation.value,
            color: color,
          ),
        );
      },
    );
  }
}

class _BreathingShapeCustomPainter extends CustomPainter {
  final double progress;
  final Color color;

  _BreathingShapeCustomPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2 * 0.65;

    // Breathing effect: expand and contract
    final breathCycle = math.sin(progress * 2 * math.pi);
    final breathFactor = 1 + breathCycle * 0.15;
    final radius = baseRadius * breathFactor;

    // Corner radius breathing
    final cornerCycle = math.sin(progress * 2 * math.pi + math.pi / 4);
    final cornerRadius = radius * 0.35 * (1 + cornerCycle * 0.5);

    // Rotation
    final rotation = progress * math.pi / 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: radius * 2, height: radius * 2),
      Radius.circular(cornerRadius),
    );

    canvas.drawRRect(rect, paint);

    // Inner breathing shape
    final innerPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final innerScale = 0.6 + math.cos(progress * 2 * math.pi) * 0.1;
    final innerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: radius * 2 * innerScale,
        height: radius * 2 * innerScale,
      ),
      Radius.circular(cornerRadius * innerScale),
    );

    canvas.drawRRect(innerRect, innerPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_BreathingShapeCustomPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Liquid Flow Painter - Flowing liquid-like shapes
class _LiquidFlowPainter extends StatelessWidget {
  final Animation<double> animation;
  final Color color;
  final double size;

  const _LiquidFlowPainter({
    required this.animation,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(size, size),
          painter: _LiquidFlowCustomPainter(
            progress: animation.value,
            color: color,
          ),
        );
      },
    );
  }
}

class _LiquidFlowCustomPainter extends CustomPainter {
  final double progress;
  final Color color;

  _LiquidFlowCustomPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2 * 0.6;

    // Draw 3 overlapping liquid blobs
    for (int i = 0; i < 3; i++) {
      final offset = i * (2 * math.pi / 3);
      final angle = progress * 2 * math.pi + offset;

      final blobCenter = Offset(
        center.dx + math.cos(angle) * baseRadius * 0.3,
        center.dy + math.sin(angle) * baseRadius * 0.3,
      );

      _drawLiquidBlob(
        canvas,
        blobCenter,
        baseRadius,
        progress + i * 0.33,
        color.withValues(alpha: 0.6),
      );
    }
  }

  void _drawLiquidBlob(Canvas canvas, Offset center, double radius,
      double phase, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final points = 6;
    final angleStep = (2 * math.pi) / points;

    final offsets = <Offset>[];
    for (int i = 0; i < points; i++) {
      final angle = i * angleStep + phase * 2 * math.pi;
      final wave = math.sin(phase * 6 * math.pi + i * 1.5) * 0.4;
      final r = radius * (0.7 + wave);

      offsets.add(Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      ));
    }

    path.moveTo(offsets[0].dx, offsets[0].dy);
    for (int i = 0; i < points; i++) {
      final current = offsets[i];
      final next = offsets[(i + 1) % points];
      final nextNext = offsets[(i + 2) % points];

      final controlPoint = Offset(
        (current.dx + next.dx) / 2 +
            (next.dx - current.dx) * 0.2 +
            math.sin(phase * 8 * math.pi + i) * 8,
        (current.dy + next.dy) / 2 +
            (next.dy - current.dy) * 0.2 +
            math.cos(phase * 8 * math.pi + i) * 8,
      );

      path.cubicTo(
        controlPoint.dx,
        controlPoint.dy,
        (next.dx + nextNext.dx) / 4 + (current.dx * 3) / 4,
        (next.dy + nextNext.dy) / 4 + (current.dy * 3) / 4,
        next.dx,
        next.dy,
      );
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LiquidFlowCustomPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A 3D dice roll animation widget
/// Uses transforms to simulate 3D rotation when rolling
class DiceRollAnimation extends StatefulWidget {
  final VoidCallback? onRollComplete;
  final bool isRolling;
  final double size;

  const DiceRollAnimation({
    super.key,
    this.onRollComplete,
    this.isRolling = false,
    this.size = 48,
  });

  @override
  State<DiceRollAnimation> createState() => _DiceRollAnimationState();
}

class _DiceRollAnimationState extends State<DiceRollAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationX;
  late Animation<double> _rotationY;
  late Animation<double> _rotationZ;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create tumbling rotation animations
    _rotationX = Tween<double>(
      begin: 0,
      end: math.pi * 4, // 2 full rotations
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotationY = Tween<double>(
      begin: 0,
      end: math.pi * 3, // 1.5 rotations
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotationZ = Tween<double>(
      begin: 0,
      end: math.pi * 2.5, // 1.25 rotations
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Add a slight scale bounce at the end
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 70),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onRollComplete?.call();
        _controller.reset();
      }
    });
  }

  @override
  void didUpdateWidget(DiceRollAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRolling && !oldWidget.isRolling) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Add perspective
          ..rotateX(_rotationX.value)
          ..rotateY(_rotationY.value)
          ..rotateZ(_rotationZ.value);

        // Apply uniform scale
        final scaleValue = _scale.value;
        matrix.multiply(
          Matrix4.diagonal3Values(scaleValue, scaleValue, scaleValue),
        );

        return Transform(
          alignment: Alignment.center,
          transform: matrix,
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Dice dots
            Center(
              child: Icon(
                Icons.casino,
                color: Theme.of(context).colorScheme.onPrimary,
                size: widget.size,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

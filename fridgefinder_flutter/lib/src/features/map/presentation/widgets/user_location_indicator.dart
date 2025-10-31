import 'package:flutter/material.dart';

/// A pulsating circle indicator for the user's current position
class UserLocationIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration animationDuration;

  const UserLocationIndicator({
    super.key,
    this.size = 30.0,
    this.color = const Color(0xFF2196F3), // Primary blue
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<UserLocationIndicator> createState() => _UserLocationIndicatorState();
}

class _UserLocationIndicatorState extends State<UserLocationIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulsating outer circle
            Container(
              width: widget.size * _scaleAnimation.value,
              height: widget.size * _scaleAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(
                  alpha: _opacityAnimation.value * 0.4,
                ),
                border: Border.all(
                  color: widget.color.withValues(
                    alpha: _opacityAnimation.value * 0.6,
                  ),
                  width: 1.5,
                ),
              ),
            ),
            // Inner solid circle
            Container(
              width: widget.size * 0.6,
              height: widget.size * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.3),
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            // Center dot
            Container(
              width: widget.size * 0.2,
              height: widget.size * 0.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}

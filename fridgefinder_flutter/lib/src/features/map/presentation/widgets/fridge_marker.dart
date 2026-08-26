import 'dart:async';

import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../../domain/models/fridge_domain.dart';
import '../../../../core/utils/fridge_icon_utils.dart';

/// Custom marker widget for displaying fridge on map
/// Uses SVG icons that match the web app design system
/// Includes health bar showing food level percentage
/// Features M3E springy entrance/exit animations
class FridgeMarker extends StatefulWidget {
  final FridgeDomain fridge;
  final bool isFollowed;
  final int? animationIndex; // For staggered entrance animation
  static const double markerSize = 40;
  static const double healthBarHeight = 6;
  static const double healthBarSpacing = 2;

  /// Shimmering, glowing gold color for followed fridges - #FFD700
  static const Color followedGold = Color(0xFFFFD700);

  const FridgeMarker({
    super.key,
    required this.fridge,
    this.isFollowed = false,
    this.animationIndex,
  });

  @override
  State<FridgeMarker> createState() => _FridgeMarkerState();
}

class _FridgeMarkerState extends State<FridgeMarker>
    with TickerProviderStateMixin {
  late AnimationController _pulseController; // For followed glow pulse
  late Animation<double> _pulseAnimation;

  late AnimationController _entranceController; // For entrance/exit animation
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _hasAnimated = false; // Track if entrance animation has been played
  Timer? _entranceDelayTimer;

  @override
  void initState() {
    super.initState();

    // Pulse animation for followed fridges
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Entrance/exit animation - M3E springy pop and grow
    // Duration: 700ms for smooth, noticeable, expressive entrance
    _entranceController = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.extraLong1), // 700ms
      vsync: this,
    );

    // Scale animation with smooth overshoot for springy "pop" effect
    // The expressiveDefaultOvershoot curve naturally handles 0 -> overshoot -> 1.0
    // with smooth transitions (no discrete segments)
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: M3EMotion.expressiveDefaultOvershoot,
      ),
    );

    // Fade animation for smooth appearance
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Start entrance animation with staggered delay (only on first appearance)
    // GlobalKeys ensure this initState is only called once per marker lifecycle
    if (!_hasAnimated) {
      _hasAnimated = true;

      // Limit stagger to first 20 markers to avoid excessive delays
      final effectiveIndex = widget.animationIndex != null
          ? (widget.animationIndex! % 20)
          : 0;
      final delay = Duration(milliseconds: effectiveIndex * 30); // 30ms stagger per marker

      // Held so dispose can cancel it - markers are created and destroyed as
      // the map pans, and an orphaned timer outlives the widget it fires on.
      _entranceDelayTimer = Timer(delay, () {
        if (mounted) {
          _entranceController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _entranceDelayTimer?.cancel();
    _pulseController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Color _getHealthBarColor(double foodPercentage) {
    // Match the pill filter colors based on food level
    if (foodPercentage >= 0.75) {
      return FridgeIconUtils.colorFromFoodLevel[3]!; // Green - Full
    } else if (foodPercentage >= 0.5) {
      return FridgeIconUtils.colorFromFoodLevel[2]!; // Yellow - Many
    } else if (foodPercentage > 0) {
      return FridgeIconUtils.colorFromFoodLevel[1]!; // Pink - Few
    } else {
      return FridgeIconUtils.colorFromFoodLevel[0]!; // White - Empty
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.fridge.latestFridgeReport;
    final foodPercentage =
        report?.foodPercentage ?? 1.0; // Default to full if no report
    // Clamp food percentage between 0 and 1
    final clampedPercentage = foodPercentage.clamp(0.0, 1.0);
    // Show health bar for all fridges with a report (food level is independent of condition)
    final showHealthBar = report != null;

    // Always reserve the health bar's space so every pin renders at the same
    // size, whether or not the fridge has a report to show a bar for.
    const iconSize = FridgeMarker.markerSize -
        FridgeMarker.healthBarHeight -
        FridgeMarker.healthBarSpacing;

    final markerContent = SizedBox(
      width: FridgeMarker.markerSize,
      height: FridgeMarker.markerSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Health bar - video game style. Fridges without a report keep the
          // same slot empty so their pin stays aligned and sized like the rest.
          if (showHealthBar)
            Container(
              width: FridgeMarker.markerSize,
              height: FridgeMarker.healthBarHeight,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.5),
                color: Colors.grey.shade800, // Dark background
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: clampedPercentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getHealthBarColor(clampedPercentage),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: FridgeMarker.healthBarHeight),
          const SizedBox(height: FridgeMarker.healthBarSpacing),
          // Fridge icon
          SizedBox(
            width: FridgeMarker.markerSize,
            height: iconSize,
            child: FridgeIconUtils.getFridgeIcon(
              fridge: widget.fridge,
              size: iconSize,
            ),
          ),
        ],
      ),
    );

    // Build marker with entrance animation
    Widget animatedMarker = AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.isFollowed
          ? AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: FridgeMarker.followedGold
                            .withValues(alpha: _pulseAnimation.value * 0.6),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: FridgeMarker.followedGold
                            .withValues(alpha: _pulseAnimation.value * 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: markerContent,
                );
              },
            )
          : markerContent,
    );

    return animatedMarker;
  }
}

import 'package:flutter/material.dart';
import '../../domain/models/fridge_domain.dart';
import '../../../../core/utils/fridge_icon_utils.dart';

/// Custom marker widget for displaying fridge on map
/// Uses SVG icons that match the web app design system
/// Includes health bar showing food level percentage
class FridgeMarker extends StatefulWidget {
  final FridgeDomain fridge;
  final bool isSubscribed;
  static const double markerSize = 40;
  static const double healthBarHeight = 6;
  static const double healthBarSpacing = 2;

  /// Vibrant green color for subscribed fridges - matches tertiary color #5FD65F
  static const Color subscribedGreen = Color(0xFF5FD65F);

  const FridgeMarker({
    super.key,
    required this.fridge,
    this.isSubscribed = false,
  });

  @override
  State<FridgeMarker> createState() => _FridgeMarkerState();
}

class _FridgeMarkerState extends State<FridgeMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
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

    // Calculate icon size to account for health bar if shown
    final iconSize = showHealthBar
        ? FridgeMarker.markerSize -
            FridgeMarker.healthBarHeight -
            FridgeMarker.healthBarSpacing
        : FridgeMarker.markerSize;

    final markerContent = SizedBox(
      width: FridgeMarker.markerSize,
      height: FridgeMarker.markerSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Health bar - video game style
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
            ),
          if (showHealthBar) SizedBox(height: FridgeMarker.healthBarSpacing),
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

    // Add thin pulsing green glow for subscribed fridges
    if (widget.isSubscribed) {
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: FridgeMarker.subscribedGreen
                      .withValues(alpha: _animation.value * 0.6),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: FridgeMarker.subscribedGreen
                      .withValues(alpha: _animation.value * 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: markerContent,
          );
        },
      );
    }

    return markerContent;
  }
}

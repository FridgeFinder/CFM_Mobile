import 'package:flutter/material.dart';
import '../../domain/models/fridge_domain.dart';
import '../../../../core/utils/fridge_icon_utils.dart';

/// Custom marker widget for displaying fridge on map
/// Uses SVG icons that match the web app design system
/// Includes health bar showing food level percentage
class FridgeMarker extends StatelessWidget {
  final FridgeDomain fridge;
  static const double markerSize = 40;
  static const double healthBarHeight = 4;
  static const double healthBarSpacing = 2;

  const FridgeMarker({super.key, required this.fridge});

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
    final report = fridge.latestFridgeReport;
    final foodPercentage = report?.foodPercentage ?? 1.0; // Default to full if no report
    // Clamp food percentage between 0 and 1
    final clampedPercentage = foodPercentage.clamp(0.0, 1.0);
    // Show health bar for all fridges with a report (food level is independent of condition)
    final showHealthBar = report != null;

    // Calculate icon size to account for health bar if shown
    final iconSize = showHealthBar ? markerSize - healthBarHeight - healthBarSpacing : markerSize;

    return SizedBox(
      width: markerSize,
      height: markerSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Health bar - video game style
          if (showHealthBar)
            Container(
              width: markerSize,
              height: healthBarHeight,
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
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            ),
          if (showHealthBar) SizedBox(height: healthBarSpacing),
          // Fridge icon
          SizedBox(
            width: markerSize,
            height: iconSize,
            child: FridgeIconUtils.getFridgeIcon(fridge: fridge, size: iconSize),
          ),
        ],
      ),
    );
  }
}

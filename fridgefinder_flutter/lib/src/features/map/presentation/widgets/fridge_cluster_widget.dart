import 'package:flutter/material.dart';

/// Custom cluster widget builder for fridge markers
/// Displays the number of fridges in each cluster
class FridgeClusterWidget extends StatelessWidget {
  final int markerCount;
  final bool isDarkMode;

  const FridgeClusterWidget({
    super.key,
    required this.markerCount,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark || isDarkMode;

    // Cluster size based on marker count
    final size = markerCount < 10
        ? 50.0
        : markerCount < 100
        ? 60.0
        : 70.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2196F3).withValues(
                alpha: 0.9,
              ) // Primary blue with transparency
            : const Color(0xFF2196F3), // Primary blue
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          markerCount.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: markerCount < 10
                ? 16
                : markerCount < 100
                ? 18
                : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

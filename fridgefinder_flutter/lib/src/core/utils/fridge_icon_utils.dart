import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../features/map/domain/models/fridge_domain.dart';
import '../../features/map/presentation/controllers/filter_condition.dart';

/// Utility class for generating fridge marker icons
/// Mirrors the logic from CFM_Frontend/src/components/organisms/browse/model/markersFrom.js
class FridgeIconUtils {
  // Colors for pin markers based on food percentage levels
  // Updated to use M3E vibrant semantic colors for better visual hierarchy
  static const Map<int, Color> colorFromFoodLevel = {
    0: Color(0xFFFFFFFF), // itemsEmpty - white (unchanged, neutral)
    1: Color(0xFFFF6B9D), // itemsFew - M3E Vibrant PINK (secondary) - few items
    2: Color(0xFFFFB300), // itemsMany - M3E Vibrant AMBER (warning) - many items
    3: Color(0xFF5FD65F), // itemsFull - M3E Vibrant GREEN (tertiary) - full/positive
  };

  // SVG template constants
  static const String _svgDecorationBackground =
      '<circle cx="18.25" cy="17.1" r="5.75" fill="#222"/>';

  static const String _svgDecorationDirty = '''
    <path fill="#fff" d="M20.545 15.532h-4.59c0 1.411.25 3.08.377 4.336.067.531.588.938 1.118.891.594-.003 1.189.006 1.783-.005.516-.037.942-.505.948-1.02a68.67 68.67 0 0 0 .364-4.202z" />
    <path stroke="#222" stroke-linecap="square" stroke-width=".653" d="M17.466 16.839v.261c0 .433.351.784.784.784v0a.784.784 0 0 0 .784-.784v-.261" />
    <circle cx="17.471" cy="13.964" r=".915" fill="#fff" />
    <circle cx="19.301" cy="14.617" r=".522" fill="#fff" />''';

  static const String _svgDecorationOutOfOrder = '''
    <path fill="#fff" d="M18.986 15.325c-.16.591.41.803.722 1.119.637-.247 1.087-.874 1.596-1.383.435.917.052 2.128-.849 2.62-.56.374-1.3.33-1.883.113l-2.355 2.353c-.754.703-1.683-.602-.91-1.143l2.25-2.251c-.455-.933-.042-2.135.851-2.63a2.046 2.046 0 0 1 1.868-.09l-1.29 1.292z" />''';

  static const String _svgFaceSmile = '''
    <path stroke="#222" stroke-width="1.263" d="M8.186 9.835c2.643 2.297 5.362 2.03 7.628 0" />
    <circle cx="7.086" cy="9.294" r="1.625" fill="#f53636" />
    <circle cx="16.904" cy="9.294" r="1.625" fill="#f53636" />
    <circle cx="10.417" cy="8.953" r=".735" fill="#222" />
    <circle cx="13.345" cy="8.953" r=".735" fill="#222" />''';

  static const String _svgFaceX = '''
    <path stroke="#222" stroke-linecap="round" stroke-width="1.263" d="m9.053 7.79 5.894 5.894m0-5.895-5.894 5.895" />''';

  /// Get food level index (0-3) from food percentage
  static int _getFoodLevelIndex(double foodPercentage) {
    if (foodPercentage >= 0.75) return 3;
    if (foodPercentage >= 0.5) return 2;
    if (foodPercentage > 0) return 1;
    return 0;
  }

  /// Generate SVG pin icon based on fridge data
  /// Used for both map markers and list view indicators
  static String generatePinSvg({
    required Color pinColor,
    required bool isSmileFace,
    required bool hasDecoration,
    required String decorationSvg,
    bool dashed = false,
  }) {
    final face = isSmileFace ? _svgFaceSmile : _svgFaceX;
    // Use "4,2" dashed pattern to match CFM_Frontend svgUrlPinNoReport
    final borderDash = dashed ? 'stroke-dasharray="4,2" ' : '';
    final decoration = hasDecoration ? decorationSvg : '';
    final background = hasDecoration ? _svgDecorationBackground : '';

    return '''<svg fill="${pinColor.toHexString()}" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
      <path stroke="#222" stroke-width="1.263" ${borderDash}d="M21.156 9.88c0 7.195-9.211 13.36-9.211 13.36S2.733 17.075 2.733 9.88a9.268 9.268 0 0 1 2.698-6.54A9.192 9.192 0 0 1 11.945.631a9.19 9.19 0 0 1 6.513 2.71 9.269 9.269 0 0 1 2.698 6.54z" />
      $face
      $background
      $decoration
    </svg>''';
  }

  /// Get the appropriate icon widget for a fridge
  /// If a report exists, icon is based on food level and condition decorations
  /// If no report exists, shows a dashed white pin
  static Widget getFridgeIcon({
    required FridgeDomain fridge,
    required double size,
  }) {
    final report = fridge.latestFridgeReport;

    // Handle special conditions when report exists
    // Color is ALWAYS based on food level, decorations show condition
    if (report != null) {
      // Get color from food level (not condition!)
      final foodColor = colorFromFoodLevel[_getFoodLevelIndex(report.foodPercentage)]!;

      switch (report.condition) {
        case FridgeCondition.notAtLocation:
          return _buildPinIcon(
            color: Color(0xFFD3D3D3),
            size: size,
            isSmileFace: false, // X face for not at location
            hasDecoration: false,
            decoration: '',
          );

        // Ghost fridges are filtered from API response, but kept for exhaustive switch
        case FridgeCondition.ghost:
          return _buildGhostIcon(size); // Kept for compatibility, but ghost fridges are filtered out

        case FridgeCondition.good:
          return _buildPinIcon(
            color: foodColor,
            size: size,
            isSmileFace: true,
            hasDecoration: false,
            decoration: '',
          );

        case FridgeCondition.dirty:
          // Dirty: food level color + dirty decoration overlay
          return _buildPinIcon(
            color: foodColor,
            size: size,
            isSmileFace: true,
            hasDecoration: true,
            decoration: _svgDecorationDirty,
          );

        case FridgeCondition.outOfOrder:
          // Out of order: food level color + servicing decoration overlay
          return _buildPinIcon(
            color: foodColor,
            size: size,
            isSmileFace: true,
            hasDecoration: true,
            decoration: _svgDecorationOutOfOrder,
          );
      }
    }

    // No report - show dashed pin with white background
    return _buildPinIcon(
      color: const Color(0xFFD3D3D3), // pale grey
      size: size,
      isSmileFace: true,
      hasDecoration: false,
      decoration: '',
      dashed: true,
    );
  }

  /// Build SVG pin icon widget
  static Widget _buildPinIcon({
    required Color color,
    required double size,
    required bool isSmileFace,
    required bool hasDecoration,
    required String decoration,
    bool dashed = false,
  }) {
    final svg = generatePinSvg(
      pinColor: color,
      isSmileFace: isSmileFace,
      hasDecoration: hasDecoration,
      decorationSvg: decoration,
      dashed: dashed,
    );

    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }

  /// Build ghost icon - matches CFM_Frontend svgUrlPinGhost style
  /// Ghost has a wavy outline and semi-transparent styling
  /// NOTE: Ghost fridges are filtered from API response, this is kept for compatibility
  static Widget _buildGhostIcon(double size) {
    // Ghost SVG from CFM_Frontend/src/theme/icons.js svgUrlPinGhost
    // Uses #e3f2fd99 fill (light blue with 60% opacity) and #22222299 stroke
    const ghostSvg =
        '''<svg fill="#e3f2fd99" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
      <path stroke="#22222299" stroke-width="1.358" d="M4.979 3.152C3.117 4.735 2.07 6.882 2.07 9.12c0 9.136.447 9.545 0 12.194-.45 2.674 4.063 2.674 4.063 0 0-2.523 3.611-2.523 3.611 0 0 2.292 4.514 2.292 4.514 0 0-2.523 3.611-2.523 3.611 0 0 2.292 4.514 2.292 4.063 0-.452-2.293 0-4.204 0-12.194 0-2.239-1.047-4.386-2.91-5.97-1.86-1.58-4.386-2.47-7.02-2.47-2.634 0-5.16.89-7.022 2.473z" />
      <circle cx="13.444" cy="9.389" r=".794" fill="#222" />
      <circle cx="10.303" cy="9.389" r=".794" fill="#222" />
    </svg>''';

    return SvgPicture.string(
      ghostSvg,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }

  /// Get status icon for list view
  static IconData getStatusIcon(FridgeCondition condition) {
    switch (condition) {
      case FridgeCondition.good:
        return Icons.check_circle;
      case FridgeCondition.dirty:
        return Icons.cleaning_services;
      case FridgeCondition.outOfOrder:
        return Icons.build_circle;
      case FridgeCondition.ghost: // Ghost fridges are filtered from API response
        return Icons.announcement; // Kept for exhaustive switch, but ghost fridges are filtered out
      case FridgeCondition.notAtLocation:
        return Icons.location_off;
    }
  }

  /// Get status color for list view - Using M3E vibrant semantic colors
  static Color getStatusColor(FridgeCondition condition) {
    switch (condition) {
      case FridgeCondition.good:
        return const Color(0xFF5FD65F); // M3E Vibrant GREEN - success/positive state
      case FridgeCondition.dirty:
        return const Color(0xFFFF7043); // M3E Vibrant CORAL - needs attention but not critical
      case FridgeCondition.outOfOrder:
        return const Color(0xFFFF7043); // M3E Vibrant CORAL - maintenance/alert state
      case FridgeCondition.ghost: // Ghost fridges are filtered from API response
        return Colors.purple; // Kept for exhaustive switch, but ghost fridges are filtered out
      case FridgeCondition.notAtLocation:
        return Color(0xFFD3D3D3);  // grey for notAtLocation
    }
  }

  /// Get status color for filter condition matching the map key
  /// Colors are based on food level only, not condition
  static Color getStatusColorForFilterCondition(FilterCondition condition) {
    switch (condition) {
      case FilterCondition.full:
        return colorFromFoodLevel[3]!; // Green - #97ED7D
      case FilterCondition.manyItems:
        return colorFromFoodLevel[2]!; // Yellow - #FFE55C
      case FilterCondition.fewItems:
        return colorFromFoodLevel[1]!; // Pink - #FFD4FF
      case FilterCondition.empty:
        return colorFromFoodLevel[0]!; // White - #FFFFFF
      case FilterCondition.needsCleaning:
      case FilterCondition.needsServicing:
        // These show food level colors, not special colors
        // Default to gray since we don't know food level in filter context
        return Colors.grey;
      case FilterCondition.notAtLocation:
        return Color(0xFFD3D3D3); // grey for notAtLocation
    }
  }

  /// Get a small SVG icon for use in filter pills
  /// Shows the visual representation of that condition type
  static Widget getConditionPillIcon(FilterCondition condition) {
    final svg = _generateConditionPillSvg(condition);
    return SvgPicture.string(svg, width: 18, height: 18, fit: BoxFit.contain);
  }

  /// Generate small SVG representation for each filter condition type
  static String _generateConditionPillSvg(FilterCondition condition) {
    switch (condition) {
      case FilterCondition.full:
        // Vibrant GREEN pin with smile (full food >= 75%)
        return generatePinSvg(
          pinColor: const Color(0xFF5FD65F), // M3E Vibrant GREEN
          isSmileFace: true,
          hasDecoration: false,
          decorationSvg: '',
        );

      case FilterCondition.manyItems:
        // Vibrant AMBER pin with smile (many items 50-74%)
        return generatePinSvg(
          pinColor: const Color(0xFFFFB300), // M3E Vibrant AMBER
          isSmileFace: true,
          hasDecoration: false,
          decorationSvg: '',
        );

      case FilterCondition.fewItems:
        // Vibrant PINK pin with smile (few items 1-49%)
        return generatePinSvg(
          pinColor: const Color(0xFFFF6B9D), // M3E Vibrant PINK
          isSmileFace: true,
          hasDecoration: false,
          decorationSvg: '',
        );

      case FilterCondition.empty:
        // White pin with smile (empty 0%)
        return generatePinSvg(
          pinColor: const Color(0xFFFFFFFF), // white
          isSmileFace: true,
          hasDecoration: false,
          decorationSvg: '',
        );

      case FilterCondition.needsCleaning:
        // Gray pin with dirty decoration (color comes from food level)
        return generatePinSvg(
          pinColor: Colors.grey.shade300,
          isSmileFace: true,
          hasDecoration: true,
          decorationSvg: _svgDecorationDirty,
        );

      case FilterCondition.needsServicing:
        // Gray pin with servicing decoration (color comes from food level)
        return generatePinSvg(
          pinColor: Colors.grey.shade300,
          isSmileFace: true,
          hasDecoration: true,
          decorationSvg: _svgDecorationOutOfOrder,
        );

      case FilterCondition.notAtLocation:
        // Gray pin with X face
        return generatePinSvg(
          pinColor: Color(0xFFD3D3D3), // gray for not at location
          isSmileFace: false, // X face instead of smile
          hasDecoration: false,
          decorationSvg: '',
        );
    }
  }
}

/// Extension to convert Color to hex string
extension ColorExtension on Color {
  String toHexString() {
    return '#${toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}

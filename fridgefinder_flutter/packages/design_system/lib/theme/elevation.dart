import 'package:flutter/material.dart';

/// Material 3 Elevation System
///
/// M3 uses a 6-level elevation system (0-5) with tonal elevation overlays
/// instead of M2's shadow-only approach. Surfaces get progressively lighter
/// tints as elevation increases.
///
/// M3E adds expressive state layers and smooth elevation transitions.
class M3EElevation {
  M3EElevation._();

  // ============================================================================
  // ELEVATION LEVELS
  // ============================================================================

  static const double level0 = 0.0; // Surface, no elevation
  static const double level1 = 1.0; // Cards, outlined buttons (hover/focus)
  static const double level2 = 3.0; // Menus, autocomplete
  static const double level3 = 6.0; // Snackbars, search bars
  static const double level4 = 8.0; // Bottom app bars, navigation bars
  static const double level5 = 12.0; // FABs, dialogs, modals

  // ============================================================================
  // COMPONENT-SPECIFIC ELEVATION
  // ============================================================================

  // Cards
  static const double cardDefault = level0;
  static const double cardHovered = level1;
  static const double cardDragged = level3;

  // Buttons
  static const double buttonDefault = level0;
  static const double buttonHovered = level1;
  static const double buttonPressed = level0;

  static const double buttonElevatedDefault = level1;
  static const double buttonElevatedHovered = level2;
  static const double buttonElevatedPressed = level1;

  // FAB
  static const double fabDefault = level3;
  static const double fabHovered = level4;
  static const double fabPressed = level3;

  // Dialogs & Modals
  static const double dialog = level3;
  static const double modal = level5;

  // Bottom Sheet
  static const double bottomSheet = level1;
  static const double bottomSheetModal = level3;

  // Side Sheet
  static const double sideSheet = level0;
  static const double sideSheetModal = level3;

  // Navigation
  static const double navigationBar = level3;
  static const double navigationDrawer = level0;
  static const double navigationRail = level0;

  // App Bars
  static const double appBarDefault = level0;
  static const double appBarScrolled = level2;

  // Menus
  static const double menu = level2;

  // Search
  static const double searchBar = level3;
  static const double searchBarHovered = level4;

  // Snackbar
  static const double snackbar = level3;

  // Tooltip
  static const double tooltip = level2;

  // Chips
  static const double chipDefault = level0;
  static const double chipElevated = level1;

  // ============================================================================
  // TONAL ELEVATION (M3 Surface Tint)
  // ============================================================================

  /// Get tonal elevation overlay color
  /// In M3, surfaces get a progressively lighter tint of primary color
  /// as elevation increases.
  ///
  /// The overlay opacity is calculated based on elevation level:
  /// - Level 0: 0% opacity
  /// - Level 1: 5% opacity (1dp)
  /// - Level 2: 8% opacity (3dp)
  /// - Level 3: 11% opacity (6dp)
  /// - Level 4: 12% opacity (8dp)
  /// - Level 5: 14% opacity (12dp)
  static Color getTonalElevationColor(Color surfaceTint, double elevation) {
    double opacity;

    if (elevation <= 0) {
      opacity = 0.0;
    } else if (elevation < 2) {
      opacity = 0.05; // Level 1
    } else if (elevation < 4) {
      opacity = 0.08; // Level 2
    } else if (elevation < 7) {
      opacity = 0.11; // Level 3
    } else if (elevation < 10) {
      opacity = 0.12; // Level 4
    } else {
      opacity = 0.14; // Level 5
    }

    return surfaceTint.withValues(alpha: opacity);
  }

  /// Apply tonal elevation to a surface color
  static Color applySurfaceTint({
    required Color surface,
    required Color surfaceTint,
    required double elevation,
  }) {
    final tintColor = getTonalElevationColor(surfaceTint, elevation);
    return Color.alphaBlend(tintColor, surface);
  }

  // ============================================================================
  // SHADOWS (M3 Shadow Specifications)
  // ============================================================================

  /// Get box shadow for a given elevation level
  static List<BoxShadow> getShadow(double elevation) {
    if (elevation <= 0) {
      return const [];
    }

    // M3 uses a 3-shadow system: umbra, penumbra, and ambient
    return [
      // Umbra shadow (dark, sharp, directly below)
      BoxShadow(
        color: Colors.black.withValues(alpha: _getUmbraOpacity(elevation)),
        offset: Offset(0, _getUmbraOffset(elevation)),
        blurRadius: _getUmbraBlur(elevation),
      ),
      // Penumbra shadow (medium, soft, slightly offset)
      BoxShadow(
        color: Colors.black.withValues(alpha: _getPenumbraOpacity(elevation)),
        offset: Offset(0, _getPenumbraOffset(elevation)),
        blurRadius: _getPenumbraBlur(elevation),
      ),
      // Ambient shadow (light, very soft, large)
      BoxShadow(
        color: Colors.black.withValues(alpha: _getAmbientOpacity(elevation)),
        offset: Offset(0, _getAmbientOffset(elevation)),
        blurRadius: _getAmbientBlur(elevation),
        spreadRadius: _getAmbientSpread(elevation),
      ),
    ];
  }

  // Shadow calculations based on elevation
  static double _getUmbraOpacity(double elevation) => 0.2 + (elevation / 100);
  static double _getUmbraOffset(double elevation) => elevation * 0.5;
  static double _getUmbraBlur(double elevation) => elevation * 1.0;

  static double _getPenumbraOpacity(double elevation) => 0.14 + (elevation / 150);
  static double _getPenumbraOffset(double elevation) => elevation * 0.8;
  static double _getPenumbraBlur(double elevation) => elevation * 1.5;

  static double _getAmbientOpacity(double elevation) => 0.12;
  static double _getAmbientOffset(double elevation) => elevation * 0.2;
  static double _getAmbientBlur(double elevation) => elevation * 2.0;
  static double _getAmbientSpread(double elevation) => elevation * 0.1;
}

/// Elevation transition animations
class M3EElevationTransition {
  M3EElevationTransition._();

  /// Create an animated elevation transition
  static Animation<double> createElevationAnimation({
    required AnimationController controller,
    required double begin,
    required double end,
    Curve curve = Curves.easeInOut,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
  }

  /// Create an animated shadow transition
  static Animation<List<BoxShadow>> createShadowAnimation({
    required AnimationController controller,
    required double beginElevation,
    required double endElevation,
    Curve curve = Curves.easeInOut,
  }) {
    return BoxShadowTween(
      begin: M3EElevation.getShadow(beginElevation),
      end: M3EElevation.getShadow(endElevation),
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
  }
}

/// Box shadow tween for animating shadows
class BoxShadowTween extends Tween<List<BoxShadow>> {
  BoxShadowTween({
    required List<BoxShadow> begin,
    required List<BoxShadow> end,
  }) : super(begin: begin, end: end);

  @override
  List<BoxShadow> lerp(double t) {
    final beginList = begin ?? [];
    final endList = end ?? [];
    final maxLength = beginList.length > endList.length
        ? beginList.length
        : endList.length;

    return List.generate(maxLength, (index) {
      final beginShadow = index < beginList.length
          ? beginList[index]
          : BoxShadow(color: Colors.transparent);
      final endShadow = index < endList.length
          ? endList[index]
          : BoxShadow(color: Colors.transparent);

      return BoxShadow.lerp(beginShadow, endShadow, t)!;
    });
  }
}

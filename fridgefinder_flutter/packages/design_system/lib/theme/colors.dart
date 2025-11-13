import 'package:flutter/material.dart';

/// Complete Material 3 Dynamic Color System
///
/// Material 3 uses the HCT (Hue, Chroma, Tone) color space to generate
/// harmonious color schemes that work in both light and dark modes.
class M3EColors {
  M3EColors._();

  // Primary palette generated from app primary (#88B3FF)
  static const Color primaryTone0 = Color(0xFF000000);
  static const Color primaryTone10 = Color(0xFF001A41);
  static const Color primaryTone20 = Color(0xFF002D6C);
  static const Color primaryTone30 = Color(0xFF004494);
  static const Color primaryTone40 = Color(0xFF005CBC);
  static const Color primaryTone50 = Color(0xFF0075E5);
  static const Color primaryTone60 = Color(0xFF4A91FF);
  static const Color primaryTone70 = Color(0xFF6FA7FF);
  static const Color primaryTone80 = Color(0xFF88B3FF); // App primary!
  static const Color primaryTone90 = Color(0xFFD3E3FF);
  static const Color primaryTone95 = Color(0xFFECF2FF);
  static const Color primaryTone99 = Color(0xFFFDFCFF);
  static const Color primaryTone100 = Color(0xFFFFFFFF);

  /// Generate color scheme from seed color
  ///
  /// Uses Flutter's ColorScheme.fromSeed which implements the
  /// Material 3 HCT color algorithm.
  static ColorScheme lightScheme({required Color seed}) {
    return ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );
  }

  /// Generate dark color scheme from seed color
  static ColorScheme darkScheme({required Color seed}) {
    return ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );
  }

  /// Apply surface tint based on elevation level
  ///
  /// Material 3 uses tonal elevation where elevated surfaces receive
  /// a slight tint of the primary color to indicate their elevation.
  ///
  /// Tint percentages by elevation level:
  /// - Level 0 (0dp): 0% tint
  /// - Level 1 (1dp): 5% tint
  /// - Level 2 (3dp): 8% tint
  /// - Level 3 (6dp): 11% tint
  /// - Level 4 (8dp): 12% tint
  /// - Level 5 (12dp): 14% tint
  static Color applySurfaceTint({
    required Color surface,
    required Color primary,
    required int elevationLevel,
  }) {
    final tintPercent = _getTintPercent(elevationLevel);
    return Color.lerp(surface, primary, tintPercent)!;
  }

  /// Get tint percentage for elevation level
  static double _getTintPercent(int level) {
    switch (level) {
      case 0:
        return 0.00;
      case 1:
        return 0.05;
      case 2:
        return 0.08;
      case 3:
        return 0.11;
      case 4:
        return 0.12;
      case 5:
        return 0.14;
      default:
        return 0.14;
    }
  }

  /// Map of elevation levels to tint opacity
  ///
  /// Use this for custom surface tinting calculations
  static const Map<int, double> surfaceTintOpacity = {
    0: 0.00,
    1: 0.05,
    2: 0.08,
    3: 0.11,
    4: 0.12,
    5: 0.14,
  };

  /// State layer opacities for interactive states
  ///
  /// These opacities are applied as color overlays to indicate
  /// interaction states like hover, focus, press, etc.
  static const Map<String, double> stateLayerOpacity = {
    'hover': 0.08,
    'focus': 0.12,
    'pressed': 0.12,
    'dragged': 0.16,
    'disabled-container': 0.12,
    'disabled-content': 0.38,
  };

  /// Get state layer color with proper opacity
  ///
  /// Example:
  /// ```dart
  /// final hoverColor = M3EColors.getStateLayerColor(
  ///   baseColor: Colors.blue,
  ///   state: 'hover',
  /// );
  /// ```
  static Color getStateLayerColor({
    required Color baseColor,
    required String state,
  }) {
    final opacity = stateLayerOpacity[state] ?? 0.0;
    return baseColor.withValues(alpha: opacity);
  }

  /// Apply state layer overlay to a surface color
  ///
  /// Combines surface color with state layer overlay for interactive states.
  /// Returns the resulting color after applying the state layer.
  static Color applyStateLayer({
    required Color surface,
    required Color onSurface,
    required String state,
  }) {
    final layerColor = getStateLayerColor(
      baseColor: onSurface,
      state: state,
    );
    return Color.alphaBlend(layerColor, surface);
  }

  /// Get primary color constant
  static const Color primary = Color(0xFF88B3FF);

  /// Get error color constant
  static const Color error = Color(0xFFBA1A1A);

  /// Create custom color scheme with specific primary color
  ///
  /// This creates a complete M3 color scheme with all 40+ color roles
  /// from a single seed color.
  static ColorScheme createCustomScheme({
    required Color primary,
    required Brightness brightness,
  }) {
    return ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    );
  }

  /// Validate contrast ratio between two colors
  ///
  /// Returns true if the contrast ratio meets WCAG AA standards:
  /// - Normal text: 4.5:1
  /// - Large text: 3:1
  /// - UI components: 3:1
  static bool meetsContrastRequirement({
    required Color foreground,
    required Color background,
    bool isLargeText = false,
  }) {
    final ratio = _calculateContrastRatio(foreground, background);
    final requiredRatio = isLargeText ? 3.0 : 4.5;
    return ratio >= requiredRatio;
  }

  /// Calculate contrast ratio between two colors
  ///
  /// Uses the WCAG formula: (L1 + 0.05) / (L2 + 0.05)
  /// where L1 is the lighter color's relative luminance
  static double _calculateContrastRatio(Color color1, Color color2) {
    final l1 = _getRelativeLuminance(color1);
    final l2 = _getRelativeLuminance(color2);

    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Calculate relative luminance of a color
  ///
  /// Uses the WCAG formula for relative luminance
  static double _getRelativeLuminance(Color color) {
    final r = _getChannelLuminance(color.r);
    final g = _getChannelLuminance(color.g);
    final b = _getChannelLuminance(color.b);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Get luminance for a single color channel
  static double _getChannelLuminance(double channel) {
    if (channel <= 0.03928) {
      return channel / 12.92;
    } else {
      return ((channel + 0.055) / 1.055) * ((channel + 0.055) / 1.055);
    }
  }
}

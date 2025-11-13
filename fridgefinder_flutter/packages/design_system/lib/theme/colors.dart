import 'package:flutter/material.dart';

/// Complete Material 3 Dynamic Color System
///
/// Material 3 uses the HCT (Hue, Chroma, Tone) color space to generate
/// harmonious color schemes that work in both light and dark modes.
class M3EColors {
  M3EColors._();

  // Primary palette - Vibrant M3E Electric Blue (#5B9FFF)
  // Enhanced from original #88B3FF with higher saturation for M3 Expressive
  static const Color primaryTone0 = Color(0xFF000000);
  static const Color primaryTone10 = Color(0xFF001D3A);
  static const Color primaryTone20 = Color(0xFF003062);
  static const Color primaryTone30 = Color(0xFF00468A);
  static const Color primaryTone40 = Color(0xFF2E6BC9);
  static const Color primaryTone50 = Color(0xFF4882E6);
  static const Color primaryTone60 = Color(0xFF5B9FFF); // New vibrant primary!
  static const Color primaryTone70 = Color(0xFF7BB4FF);
  static const Color primaryTone80 = Color(0xFF9BC7FF);
  static const Color primaryTone90 = Color(0xFFD0E4FF);
  static const Color primaryTone95 = Color(0xFFECF3FF);
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

  // Secondary palette - Vibrant M3E Pink/Magenta (#FF6B9D)
  // Integrated from fridge status "few items" pink (#FFD4FF)
  // Enhanced with higher saturation for M3 Expressive vibrancy
  static const Color secondaryTone0 = Color(0xFF000000);
  static const Color secondaryTone10 = Color(0xFF3E001F);
  static const Color secondaryTone20 = Color(0xFF630033);
  static const Color secondaryTone30 = Color(0xFF8B0049);
  static const Color secondaryTone40 = Color(0xFFB71E5F);
  static const Color secondaryTone50 = Color(0xFFE43876);
  static const Color secondaryTone60 = Color(0xFFFF6B9D); // Vibrant pink!
  static const Color secondaryTone70 = Color(0xFFFF8FB3);
  static const Color secondaryTone80 = Color(0xFFFFB1CA);
  static const Color secondaryTone90 = Color(0xFFFFD4E1);
  static const Color secondaryTone95 = Color(0xFFFFEBF2);
  static const Color secondaryTone99 = Color(0xFFFFFBFF);
  static const Color secondaryTone100 = Color(0xFFFFFFFF);

  // Tertiary palette - Vibrant M3E Green (#5FD65F)
  // Integrated from fridge status "full" green (#97ED7D)
  // Enhanced with higher saturation for M3 Expressive energy
  static const Color tertiaryTone0 = Color(0xFF000000);
  static const Color tertiaryTone10 = Color(0xFF002204);
  static const Color tertiaryTone20 = Color(0xFF003909);
  static const Color tertiaryTone30 = Color(0xFF00530F);
  static const Color tertiaryTone40 = Color(0xFF1B7028);
  static const Color tertiaryTone50 = Color(0xFF348E3F);
  static const Color tertiaryTone60 = Color(0xFF5FD65F); // Vibrant green!
  static const Color tertiaryTone70 = Color(0xFF7EE87E);
  static const Color tertiaryTone80 = Color(0xFF9BF49B);
  static const Color tertiaryTone90 = Color(0xFFB9FFB7);
  static const Color tertiaryTone95 = Color(0xFFD9FFD6);
  static const Color tertiaryTone99 = Color(0xFFF5FFF5);
  static const Color tertiaryTone100 = Color(0xFFFFFFFF);

  // Warning/Accent palette - Vibrant M3E Amber (#FFB300)
  // Integrated from fridge status "many items" yellow (#FFE55C)
  // Enhanced with more saturation for M3 Expressive boldness
  static const Color warningTone0 = Color(0xFF000000);
  static const Color warningTone10 = Color(0xFF2A1800);
  static const Color warningTone20 = Color(0xFF442B00);
  static const Color warningTone30 = Color(0xFF614000);
  static const Color warningTone40 = Color(0xFF815600);
  static const Color warningTone50 = Color(0xFFA36E00);
  static const Color warningTone60 = Color(0xFFFFB300); // Vibrant amber!
  static const Color warningTone70 = Color(0xFFFFCA3D);
  static const Color warningTone80 = Color(0xFFFFDD71);
  static const Color warningTone90 = Color(0xFFFFECA5);
  static const Color warningTone95 = Color(0xFFFFF6D9);
  static const Color warningTone99 = Color(0xFFFFFBF7);
  static const Color warningTone100 = Color(0xFFFFFFFF);

  // Alert palette - Vibrant M3E Coral/Orange (#FF7043)
  // Integrated from fridge status "dirty" orange concept
  // Balanced between error red and warning amber for attention-grabbing
  static const Color alertTone0 = Color(0xFF000000);
  static const Color alertTone10 = Color(0xFF3A0A00);
  static const Color alertTone20 = Color(0xFF5C1900);
  static const Color alertTone30 = Color(0xFF802900);
  static const Color alertTone40 = Color(0xFFA93B0E);
  static const Color alertTone50 = Color(0xFFD25227);
  static const Color alertTone60 = Color(0xFFFF7043); // Vibrant coral!
  static const Color alertTone70 = Color(0xFFFF8F6B);
  static const Color alertTone80 = Color(0xFFFFAD93);
  static const Color alertTone90 = Color(0xFFFFCCBA);
  static const Color alertTone95 = Color(0xFFFFE5DC);
  static const Color alertTone99 = Color(0xFFFFFBF9);
  static const Color alertTone100 = Color(0xFFFFFFFF);

  /// Get primary color constant - New vibrant electric blue
  static const Color primary = Color(0xFF5B9FFF);

  /// Get secondary color constant - Vibrant pink/magenta
  static const Color secondary = Color(0xFFFF6B9D);

  /// Get tertiary color constant - Vibrant green
  static const Color tertiary = Color(0xFF5FD65F);

  /// Get warning color constant - Vibrant amber
  static const Color warning = Color(0xFFFFB300);

  /// Get alert color constant - Vibrant coral/orange
  static const Color alert = Color(0xFFFF7043);

  /// Get error color constant
  static const Color error = Color(0xFFBA1A1A);

  // Fridge Status Colors - Original palette preserved for backward compatibility
  // These integrate seamlessly with the new M3E Expressive palette
  static const Color fridgeEmpty = Color(0xFFFFFFFF); // White
  static const Color fridgeFewItems = Color(0xFFFFD4FF); // Light pink
  static const Color fridgeManyItems = Color(0xFFFFE55C); // Light yellow
  static const Color fridgeFull = Color(0xFF97ED7D); // Light green

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

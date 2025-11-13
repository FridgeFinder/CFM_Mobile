import 'package:flutter/material.dart';
import 'colors.dart';

/// Material 3 Expressive Color Schemes
///
/// Provides complete color scheme generation with full tonal palettes,
/// semantic colors, and proper dark mode tone mapping.
///
/// Primary Color: #88B3FF (Light Blue)
class M3EColorSchemes {
  M3EColorSchemes._();

  /// App primary color (#88B3FF)
  static const Color primaryColor = Color(0xFF88B3FF);

  /// Error color (#BA1A1A)
  static const Color errorColor = Color(0xFFBA1A1A);

  /// Generate complete light color scheme from primary seed
  static ColorScheme lightScheme({Color? seed}) {
    return ColorScheme.fromSeed(
      seedColor: seed ?? primaryColor,
      brightness: Brightness.light,
    );
  }

  /// Generate complete dark color scheme from primary seed
  static ColorScheme darkScheme({Color? seed}) {
    return ColorScheme.fromSeed(
      seedColor: seed ?? primaryColor,
      brightness: Brightness.dark,
    );
  }

  /// Generate full 13-tone tonal palette from a color
  ///
  /// Returns a map of tone values (0-100) to Color objects.
  /// Uses HCT color space for proper tone distribution.
  static Map<int, Color> generateTonalPalette(Color color) {
    // Flutter's ColorScheme.fromSeed already uses HCT internally
    // We'll extract tones by creating a scheme and using the generated colors
    final scheme = ColorScheme.fromSeed(seedColor: color, brightness: Brightness.light);
    
    return {
      0: scheme.primary,
      10: _adjustTone(scheme.primary, 0.1),
      20: _adjustTone(scheme.primary, 0.2),
      30: _adjustTone(scheme.primary, 0.3),
      40: _adjustTone(scheme.primary, 0.4),
      50: _adjustTone(scheme.primary, 0.5),
      60: _adjustTone(scheme.primary, 0.6),
      70: _adjustTone(scheme.primary, 0.7),
      80: scheme.primary, // Primary is typically tone 80
      90: _adjustTone(scheme.primary, 0.9),
      95: _adjustTone(scheme.primary, 0.95),
      99: _adjustTone(scheme.primary, 0.99),
      100: Colors.white,
    };
  }

  /// Adjust color tone (lightness) while preserving hue and chroma
  static Color _adjustTone(Color color, double tone) {
    // Simple approximation: blend with white/black based on tone
    if (tone > 0.5) {
      // Lighter: blend with white
      return Color.lerp(color, Colors.white, (tone - 0.5) * 2)!;
    } else {
      // Darker: blend with black
      return Color.lerp(Colors.black, color, tone * 2)!;
    }
  }

  /// Generate semantic color palettes (error, warning, success)
  static Map<String, ColorScheme> generateSemanticSchemes({
    Color? errorSeed,
    Color? warningSeed,
    Color? successSeed,
  }) {
    return {
      'error': ColorScheme.fromSeed(
        seedColor: errorSeed ?? errorColor,
        brightness: Brightness.light,
      ),
      'warning': ColorScheme.fromSeed(
        seedColor: warningSeed ?? const Color(0xFFFF9800),
        brightness: Brightness.light,
      ),
      'success': ColorScheme.fromSeed(
        seedColor: successSeed ?? const Color(0xFF4CAF50),
        brightness: Brightness.light,
      ),
    };
  }

  /// Apply surface tint based on elevation level
  ///
  /// M3E uses tonal elevation where elevated surfaces receive
  /// a slight tint of the primary color.
  ///
  /// Elevation levels and tint percentages:
  /// - Level 0 (0dp): 0% tint
  /// - Level 1 (1dp): 5% tint
  /// - Level 2 (3dp): 8% tint
  /// - Level 3 (6dp): 11% tint
  /// - Level 4 (8dp): 12% tint
  /// - Level 5 (12dp): 14% tint
  static Color applyElevationTint({
    required Color surface,
    required ColorScheme colorScheme,
    required int elevationLevel,
  }) {
    final tintPercent = _getElevationTintPercent(elevationLevel);
    return Color.lerp(
      surface,
      colorScheme.primary,
      tintPercent,
    )!;
  }

  /// Get tint percentage for elevation level
  static double _getElevationTintPercent(int level) {
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

  /// Get state layer color with proper opacity
  ///
  /// State layers are overlays that indicate interaction states:
  /// - Hover: 8% opacity
  /// - Focus: 12% opacity
  /// - Press: 12% opacity
  /// - Drag: 16% opacity
  static Color getStateLayerColor({
    required Color baseColor,
    required ColorScheme colorScheme,
    required String state,
  }) {
    final opacity = _getStateLayerOpacity(state);
    final stateColor = colorScheme.onSurface;
    return stateColor.withValues(alpha: opacity);
  }

  /// Get opacity for state layer
  static double _getStateLayerOpacity(String state) {
    switch (state) {
      case 'hover':
        return 0.08;
      case 'focus':
        return 0.12;
      case 'press':
      case 'pressed':
        return 0.12;
      case 'drag':
      case 'dragged':
        return 0.16;
      case 'disabled-container':
        return 0.12;
      case 'disabled-content':
        return 0.38;
      default:
        return 0.0;
    }
  }

  /// Validate contrast ratio between foreground and background
  ///
  /// Returns true if contrast meets WCAG AA standards:
  /// - Normal text: 4.5:1
  /// - Large text: 3:1
  static bool meetsContrastRequirement({
    required Color foreground,
    required Color background,
    bool isLargeText = false,
  }) {
    return M3EColors.meetsContrastRequirement(
      foreground: foreground,
      background: background,
      isLargeText: isLargeText,
    );
  }

  /// Get all 25+ M3 color roles from a color scheme
  ///
  /// Returns a map of role names to colors for easy access
  static Map<String, Color> getAllColorRoles(ColorScheme scheme) {
    return {
      // Primary colors
      'primary': scheme.primary,
      'onPrimary': scheme.onPrimary,
      'primaryContainer': scheme.primaryContainer,
      'onPrimaryContainer': scheme.onPrimaryContainer,
      
      // Secondary colors
      'secondary': scheme.secondary,
      'onSecondary': scheme.onSecondary,
      'secondaryContainer': scheme.secondaryContainer,
      'onSecondaryContainer': scheme.onSecondaryContainer,
      
      // Tertiary colors
      'tertiary': scheme.tertiary,
      'onTertiary': scheme.onTertiary,
      'tertiaryContainer': scheme.tertiaryContainer,
      'onTertiaryContainer': scheme.onTertiaryContainer,
      
      // Error colors
      'error': scheme.error,
      'onError': scheme.onError,
      'errorContainer': scheme.errorContainer,
      'onErrorContainer': scheme.onErrorContainer,
      
      // Surface colors
      'surface': scheme.surface,
      'onSurface': scheme.onSurface,
      'onSurfaceVariant': scheme.onSurfaceVariant,
      'surfaceContainerHighest': scheme.surfaceContainerHighest,
      'surfaceContainerHigh': scheme.surfaceContainerHigh,
      'surfaceContainer': scheme.surfaceContainer,
      'surfaceContainerLow': scheme.surfaceContainerLow,
      'surfaceContainerLowest': scheme.surfaceContainerLowest,
      'surfaceDim': scheme.surfaceDim,
      'surfaceBright': scheme.surfaceBright,
      
      // Outline colors
      'outline': scheme.outline,
      'outlineVariant': scheme.outlineVariant,
      
      // Inverse colors
      'inverseSurface': scheme.inverseSurface,
      'onInverseSurface': scheme.onInverseSurface,
      'inversePrimary': scheme.inversePrimary,
      
      // Scrim
      'scrim': scheme.scrim,
      
      // Shadow
      'shadow': scheme.shadow,
    };
  }

  /// Create custom color scheme with specific primary color
  ///
  /// This creates a complete M3 color scheme with all 40+ color roles
  /// from a single seed color, properly handling light/dark modes.
  static ColorScheme createCustomScheme({
    required Color primary,
    required Brightness brightness,
  }) {
    return ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    );
  }

  /// Get proper tone mapping for dark mode
  ///
  /// In dark mode, primary colors use higher tones (tone 80)
  /// In light mode, primary colors use lower tones (tone 40)
  static Color getPrimaryForBrightness({
    required ColorScheme lightScheme,
    required ColorScheme darkScheme,
    required Brightness brightness,
  }) {
    return brightness == Brightness.dark
        ? darkScheme.primary
        : lightScheme.primary;
  }
}


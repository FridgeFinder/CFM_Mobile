import 'package:flutter/material.dart';

/// Material 3 Expressive Type Scale System
///
/// Material 3 Expressive defines a 30-style type scale:
/// - 15 baseline styles (Regular/Medium weight)
/// - 15 emphasized variants (Bold weight, +0.1sp letter-spacing)
///
/// Categories:
/// - Display: Large, prominent text
/// - Headline: High-emphasis, shorter text
/// - Title: Medium-emphasis text for UI elements
/// - Body: Main content text
/// - Label: Utilitarian text for UI elements
///
/// Each category has Large, Medium, and Small variants.
/// Each variant has a baseline style and an emphasized (Bold) version.
class M3ETypography {
  M3ETypography._();

  // ═══════════════════════════════════════════════════════════════════════════
  // Display Styles - For short, important text or numerals
  // ═══════════════════════════════════════════════════════════════════════════

  /// Display Large: 57px Regular
  ///
  /// Use for: Hero headlines, large numbers, most prominent text
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    height: 64 / 57, // Line height / Font size = 1.123
    letterSpacing: -0.25,
  );

  /// Display Large Emphasized: 57px Bold
  ///
  /// Bold variant with +0.1sp letter-spacing for maximum emphasis
  static const TextStyle displayLargeEmphasized = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    height: 64 / 57,
    letterSpacing: -0.15, // -0.25 + 0.1
  );

  /// Display Medium: 45px Regular
  ///
  /// Use for: Important headlines, secondary hero text
  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    height: 52 / 45, // 1.156
    letterSpacing: 0,
  );

  /// Display Medium Emphasized: 45px Bold
  ///
  /// Bold variant with +0.1sp letter-spacing for strong emphasis
  static const TextStyle displayMediumEmphasized = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w700,
    height: 52 / 45,
    letterSpacing: 0.1, // 0 + 0.1
  );

  /// Display Small: 36px Regular
  ///
  /// Use for: Smaller headlines, section dividers
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: 44 / 36, // 1.222
    letterSpacing: 0,
  );

  /// Display Small Emphasized: 36px Bold
  ///
  /// Bold variant with +0.1sp letter-spacing for emphasis
  static const TextStyle displaySmallEmphasized = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 44 / 36,
    letterSpacing: 0.1, // 0 + 0.1
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // Headline Styles - For short, high-emphasis text
  // ═══════════════════════════════════════════════════════════════════════════

  /// Headline Large: 32px Regular
  ///
  /// Use for: High-emphasis, short text like article titles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 40 / 32, // 1.25
    letterSpacing: 0,
  );

  /// Headline Large Emphasized: 32px Bold
  ///
  /// Bold variant with +0.1sp letter-spacing for maximum emphasis
  static const TextStyle headlineLargeEmphasized = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: 0.1, // 0 + 0.1
  );

  /// Headline Medium: 28px Regular
  ///
  /// Use for: High-emphasis, short text in smaller screens
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 36 / 28, // 1.286
    letterSpacing: 0,
  );

  /// Headline Medium Emphasized: 28px Bold
  ///
  /// Bold variant with +0.1sp letter-spacing for strong emphasis
  static const TextStyle headlineMediumEmphasized = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28,
    letterSpacing: 0.1, // 0 + 0.1
  );

  /// Headline Small: 24px Regular
  ///
  /// Use for: High-emphasis, short text like dialog titles
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 32 / 24, // 1.333
    letterSpacing: 0,
  );

  /// Headline Small Emphasized: 24px Bold
  ///
  /// Bold variant with +0.1sp letter-spacing for emphasis
  static const TextStyle headlineSmallEmphasized = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    letterSpacing: 0.1, // 0 + 0.1
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // Title Styles - For medium-emphasis text
  // ═══════════════════════════════════════════════════════════════════════════

  /// Title Large: 22px Regular
  ///
  /// Use for: Medium-emphasis text like card headers, list headers
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    height: 28 / 22, // 1.273
    letterSpacing: 0,
  );

  /// Title Large Emphasized: 22px Bold
  ///
  /// Bold variant with +0.1sp letter-spacing for emphasis
  static const TextStyle titleLargeEmphasized = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 28 / 22,
    letterSpacing: 0.1, // 0 + 0.1
  );

  /// Title Medium: 16px Medium
  ///
  /// Use for: Medium-emphasis text like app bar titles, card titles
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16, // 1.5
    letterSpacing: 0.15,
  );

  /// Title Medium Emphasized: 16px Bold
  ///
  /// Bold variant with +0.1sp letter-spacing for stronger emphasis
  static const TextStyle titleMediumEmphasized = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 24 / 16,
    letterSpacing: 0.25, // 0.15 + 0.1
  );

  /// Title Small: 14px Medium
  ///
  /// Use for: Medium-emphasis text like list tile titles
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14, // 1.429
    letterSpacing: 0.1,
  );

  /// Title Small Emphasized: 14px Bold
  ///
  /// Bold variant with +0.1sp letter-spacing for emphasis
  static const TextStyle titleSmallEmphasized = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 20 / 14,
    letterSpacing: 0.2, // 0.1 + 0.1
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // Body Styles - For longer passages of text
  // ═══════════════════════════════════════════════════════════════════════════

  /// Body Large: 16px Regular
  ///
  /// Use for: Long-form writing like articles, dialogs
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16, // 1.5
    letterSpacing: 0.5,
  );

  /// Body Large Emphasized: 16px Bold
  ///
  /// Bold variant with +0.1sp letter-spacing for emphasis
  static const TextStyle bodyLargeEmphasized = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 24 / 16,
    letterSpacing: 0.6, // 0.5 + 0.1
  );

  /// Body Medium: 14px Regular
  ///
  /// Use for: Primary body text in most contexts
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14, // 1.429
    letterSpacing: 0.25,
  );

  /// Body Medium Emphasized: 14px Bold
  ///
  /// Bold variant with +0.1sp letter-spacing for emphasis
  static const TextStyle bodyMediumEmphasized = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 20 / 14,
    letterSpacing: 0.35, // 0.25 + 0.1
  );

  /// Body Small: 12px Regular
  ///
  /// Use for: Secondary body text, captions, helper text
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12, // 1.333
    letterSpacing: 0.4,
  );

  /// Body Small Emphasized: 12px Bold
  ///
  /// Bold variant with +0.1sp letter-spacing for emphasis
  static const TextStyle bodySmallEmphasized = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 16 / 12,
    letterSpacing: 0.5, // 0.4 + 0.1
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // Label Styles - For utilitarian text
  // ═══════════════════════════════════════════════════════════════════════════

  /// Label Large: 14px Medium
  ///
  /// Use for: Buttons, tabs, filter chips, prominent labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14, // 1.429
    letterSpacing: 0.1,
  );

  /// Label Large Emphasized: 14px Bold
  ///
  /// Bold variant with +0.1sp letter-spacing for emphasis
  static const TextStyle labelLargeEmphasized = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 20 / 14,
    letterSpacing: 0.2, // 0.1 + 0.1
  );

  /// Label Medium: 12px Medium
  ///
  /// Use for: Secondary buttons, labels, badges
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12, // 1.333
    letterSpacing: 0.5,
  );

  /// Label Medium Emphasized: 12px Bold
  ///
  /// Bold variant with +0.1sp letter-spacing for emphasis
  static const TextStyle labelMediumEmphasized = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 16 / 12,
    letterSpacing: 0.6, // 0.5 + 0.1
  );

  /// Label Small: 11px Medium
  ///
  /// Use for: Small labels, timestamps, densely packed UI
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 16 / 11, // 1.455
    letterSpacing: 0.5,
  );

  /// Label Small Emphasized: 11px Bold
  ///
  /// Bold variant with +0.1sp letter-spacing for emphasis
  static const TextStyle labelSmallEmphasized = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 16 / 11,
    letterSpacing: 0.6, // 0.5 + 0.1
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // Utility Methods
  // ═══════════════════════════════════════════════════════════════════════════

  /// Create a complete Material 3 text theme
  ///
  /// This applies the M3 type scale to all text styles in the theme.
  /// Optionally provide custom colors for display and body text.
  ///
  /// Example:
  /// ```dart
  /// final textTheme = M3ETypography.createTextTheme(
  ///   displayColor: Colors.black87,
  ///   bodyColor: Colors.black87,
  /// );
  /// ```
  static TextTheme createTextTheme({
    Color? displayColor,
    Color? bodyColor,
  }) {
    return TextTheme(
      // Display
      displayLarge: displayLarge.copyWith(color: displayColor),
      displayMedium: displayMedium.copyWith(color: displayColor),
      displaySmall: displaySmall.copyWith(color: displayColor),

      // Headline
      headlineLarge: headlineLarge.copyWith(color: displayColor),
      headlineMedium: headlineMedium.copyWith(color: displayColor),
      headlineSmall: headlineSmall.copyWith(color: displayColor),

      // Title
      titleLarge: titleLarge.copyWith(color: bodyColor),
      titleMedium: titleMedium.copyWith(color: bodyColor),
      titleSmall: titleSmall.copyWith(color: bodyColor),

      // Body
      bodyLarge: bodyLarge.copyWith(color: bodyColor),
      bodyMedium: bodyMedium.copyWith(color: bodyColor),
      bodySmall: bodySmall.copyWith(color: bodyColor),

      // Label
      labelLarge: labelLarge.copyWith(color: bodyColor),
      labelMedium: labelMedium.copyWith(color: bodyColor),
      labelSmall: labelSmall.copyWith(color: bodyColor),
    );
  }

  /// Get responsive text style based on screen size
  ///
  /// Material 3 recommends slightly larger body text on larger screens.
  /// - Mobile (≤600px): Use bodyMedium (14px)
  /// - Tablet/Desktop (>600px): Use bodyLarge (16px)
  static TextStyle getResponsiveBody(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width <= 600 ? bodyMedium : bodyLarge;
  }

  /// Get text style with color applied
  ///
  /// Convenience method to apply a color to any text style.
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Scale text style for different densities
  ///
  /// Reduces font size slightly for compact density.
  /// - Default: No change
  /// - Comfortable: -1px
  /// - Compact: -2px
  static TextStyle scaledForDensity(
    TextStyle style, {
    int densityLevel = 0,
  }) {
    if (densityLevel == 0) return style;

    final reduction = densityLevel == -1 ? 1.0 : 2.0;
    return style.copyWith(fontSize: (style.fontSize ?? 14) - reduction);
  }
}

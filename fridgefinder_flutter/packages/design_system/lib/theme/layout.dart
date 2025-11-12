import 'package:flutter/material.dart';

/// Material 3 Layout System
///
/// M3 uses window size classes for responsive design that adapts across
/// different screen sizes and form factors.
///
/// Window Size Classes:
/// - Compact: Width < 600dp (phones in portrait)
/// - Medium: 600dp ≤ Width < 840dp (tablets in portrait, foldables)
/// - Expanded: Width ≥ 840dp (tablets in landscape, desktops)
class M3ELayout {
  M3ELayout._();

  // ============================================================================
  // BREAKPOINTS (Material 3 Window Size Classes)
  // ============================================================================

  /// Compact breakpoint (< 600dp)
  /// Typical: Phones in portrait mode
  static const double compactMaxWidth = 600.0;

  /// Medium breakpoint (600-839dp)
  /// Typical: Small tablets, phones in landscape, foldables
  static const double mediumMinWidth = 600.0;
  static const double mediumMaxWidth = 840.0;

  /// Expanded breakpoint (≥ 840dp)
  /// Typical: Large tablets, desktop
  static const double expandedMinWidth = 840.0;

  /// Large breakpoint (≥ 1200dp)
  /// Typical: Desktop, wide screens
  static const double largeMinWidth = 1200.0;

  /// Extra large breakpoint (≥ 1600dp)
  /// Typical: Ultra-wide displays
  static const double extraLargeMinWidth = 1600.0;

  // ============================================================================
  // WINDOW SIZE CLASS HELPERS
  // ============================================================================

  /// Get the current window size class
  static WindowSizeClass getWindowSizeClass(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < compactMaxWidth) {
      return WindowSizeClass.compact;
    } else if (width < mediumMaxWidth) {
      return WindowSizeClass.medium;
    } else if (width < largeMinWidth) {
      return WindowSizeClass.expanded;
    } else if (width < extraLargeMinWidth) {
      return WindowSizeClass.large;
    } else {
      return WindowSizeClass.extraLarge;
    }
  }

  /// Check if current window is compact
  static bool isCompact(BuildContext context) {
    return getWindowSizeClass(context) == WindowSizeClass.compact;
  }

  /// Check if current window is medium
  static bool isMedium(BuildContext context) {
    return getWindowSizeClass(context) == WindowSizeClass.medium;
  }

  /// Check if current window is expanded or larger
  static bool isExpanded(BuildContext context) {
    final windowClass = getWindowSizeClass(context);
    return windowClass == WindowSizeClass.expanded ||
        windowClass == WindowSizeClass.large ||
        windowClass == WindowSizeClass.extraLarge;
  }

  /// Check if current window is large or larger
  static bool isLarge(BuildContext context) {
    final windowClass = getWindowSizeClass(context);
    return windowClass == WindowSizeClass.large ||
        windowClass == WindowSizeClass.extraLarge;
  }

  // ============================================================================
  // ADAPTIVE VALUE HELPERS
  // ============================================================================

  /// Get adaptive value based on window size class
  static T getAdaptiveValue<T>(
    BuildContext context, {
    required T compact,
    T? medium,
    T? expanded,
    T? large,
    T? extraLarge,
  }) {
    final windowClass = getWindowSizeClass(context);

    switch (windowClass) {
      case WindowSizeClass.compact:
        return compact;
      case WindowSizeClass.medium:
        return medium ?? compact;
      case WindowSizeClass.expanded:
        return expanded ?? medium ?? compact;
      case WindowSizeClass.large:
        return large ?? expanded ?? medium ?? compact;
      case WindowSizeClass.extraLarge:
        return extraLarge ?? large ?? expanded ?? medium ?? compact;
    }
  }

  /// Get adaptive integer value
  static int getAdaptiveInt(
    BuildContext context, {
    required int compact,
    int? medium,
    int? expanded,
    int? large,
    int? extraLarge,
  }) {
    return getAdaptiveValue<int>(
      context,
      compact: compact,
      medium: medium,
      expanded: expanded,
      large: large,
      extraLarge: extraLarge,
    );
  }

  /// Get adaptive double value
  static double getAdaptiveDouble(
    BuildContext context, {
    required double compact,
    double? medium,
    double? expanded,
    double? large,
    double? extraLarge,
  }) {
    return getAdaptiveValue<double>(
      context,
      compact: compact,
      medium: medium,
      expanded: expanded,
      large: large,
      extraLarge: extraLarge,
    );
  }

  // ============================================================================
  // CONTENT WIDTH CONSTRAINTS
  // ============================================================================

  /// Maximum content width for optimal readability
  /// Based on M3 guidelines for text-heavy content
  static const double maxContentWidth = 840.0;

  /// Maximum width for forms and focused tasks
  static const double maxFormWidth = 600.0;

  /// Get content width constraints
  static BoxConstraints getContentConstraints(BuildContext context) {
    return BoxConstraints(
      maxWidth: getAdaptiveDouble(
        context,
        compact: double.infinity,
        medium: maxFormWidth,
        expanded: maxContentWidth,
      ),
    );
  }

  // ============================================================================
  // TOUCH TARGET SIZES
  // ============================================================================

  /// Minimum touch target size for Android (Material Design)
  static const double minTouchTargetAndroid = 48.0;

  /// Minimum touch target size for iOS (Human Interface Guidelines)
  static const double minTouchTargetIOS = 44.0;

  /// Get platform-appropriate minimum touch target
  static double getMinTouchTarget(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS
        ? minTouchTargetIOS
        : minTouchTargetAndroid;
  }

  /// Enforce minimum touch target size
  static Size enforceTouchTarget(BuildContext context, Size size) {
    final minSize = getMinTouchTarget(context);
    return Size(
      size.width < minSize ? minSize : size.width,
      size.height < minSize ? minSize : size.height,
    );
  }

  // ============================================================================
  // DENSITY SCALE
  // ============================================================================

  /// Get visual density based on window size class
  /// Compact devices get more spacing, expanded devices get denser layouts
  static VisualDensity getAdaptiveDensity(BuildContext context) {
    return getAdaptiveValue(
      context,
      compact: VisualDensity.standard, // More spacious on phones
      medium: VisualDensity.comfortable, // Balanced on tablets
      expanded: VisualDensity.compact, // Denser on desktop
    );
  }

  // ============================================================================
  // GRID SYSTEM
  // ============================================================================

  /// Get adaptive column count for grid layouts
  static int getGridColumns(BuildContext context) {
    return getAdaptiveInt(
      context,
      compact: 4, // 4 columns on phone
      medium: 8, // 8 columns on tablet
      expanded: 12, // 12 columns on desktop
    );
  }

  /// Get gutter width (spacing between grid columns)
  static double getGutterWidth(BuildContext context) {
    return getAdaptiveDouble(
      context,
      compact: 16.0,
      medium: 24.0,
      expanded: 24.0,
    );
  }

  /// Get margin width (outer spacing)
  static double getMarginWidth(BuildContext context) {
    return getAdaptiveDouble(
      context,
      compact: 16.0,
      medium: 24.0,
      expanded: 24.0,
    );
  }

  // ============================================================================
  // NAVIGATION LAYOUT
  // ============================================================================

  /// Get recommended navigation type based on window size
  static NavigationType getNavigationType(BuildContext context) {
    return getAdaptiveValue(
      context,
      compact: NavigationType.bottomNavigation,
      medium: NavigationType.navigationRail,
      expanded: NavigationType.navigationDrawer,
    );
  }

  /// Check if drawer should be permanent (always visible) or modal
  static bool shouldDrawerBePermanent(BuildContext context) {
    return isExpanded(context);
  }

  /// Check if navigation rail should be extended (with labels)
  static bool shouldRailBeExtended(BuildContext context) {
    return isLarge(context);
  }

  // ============================================================================
  // ORIENTATION HELPERS
  // ============================================================================

  /// Check if device is in portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Check if device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  // ============================================================================
  // SAFE AREA HELPERS
  // ============================================================================

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get view insets (keyboard, etc.)
  static EdgeInsets getViewInsets(BuildContext context) {
    return MediaQuery.of(context).viewInsets;
  }
}

/// Window size class enum
enum WindowSizeClass {
  compact, // < 600dp
  medium, // 600-839dp
  expanded, // 840-1199dp
  large, // 1200-1599dp
  extraLarge, // ≥ 1600dp
}

/// Navigation type based on window size
enum NavigationType {
  bottomNavigation, // Compact: Bottom navigation bar
  navigationRail, // Medium: Vertical navigation rail
  navigationDrawer, // Expanded: Navigation drawer (permanent or modal)
}

/// Adaptive layout builder
///
/// Builds different layouts based on window size class
class AdaptiveLayout extends StatelessWidget {
  final Widget Function(BuildContext context)? compact;
  final Widget Function(BuildContext context)? medium;
  final Widget Function(BuildContext context)? expanded;
  final Widget Function(BuildContext context)? large;
  final Widget Function(BuildContext context)? extraLarge;

  const AdaptiveLayout({
    super.key,
    this.compact,
    this.medium,
    this.expanded,
    this.large,
    this.extraLarge,
  });

  @override
  Widget build(BuildContext context) {
    final windowClass = M3ELayout.getWindowSizeClass(context);

    switch (windowClass) {
      case WindowSizeClass.compact:
        return (compact ?? medium ?? expanded ?? large ?? extraLarge!)(context);
      case WindowSizeClass.medium:
        return (medium ?? compact ?? expanded ?? large ?? extraLarge!)(context);
      case WindowSizeClass.expanded:
        return (expanded ?? medium ?? compact ?? large ?? extraLarge!)(context);
      case WindowSizeClass.large:
        return (large ?? expanded ?? medium ?? compact ?? extraLarge!)(context);
      case WindowSizeClass.extraLarge:
        return (extraLarge ?? large ?? expanded ?? medium ?? compact!)(context);
    }
  }
}

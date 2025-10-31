import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

/// Extension methods for theme detection and application
extension ThemeDetection on BuildContext {
  /// Detects if the current context is in dark mode
  /// Checks app theme setting and system preference
  bool get isDarkMode {
    final brightness = MediaQuery.of(this).platformBrightness;
    return brightness == Brightness.dark;
  }
}

/// Helper function to determine dark mode from theme and system preference
bool isDarkMode(BuildContext context, AppThemeMode themeMode) {
  return themeMode == AppThemeMode.dark ||
      (themeMode == AppThemeMode.system &&
          MediaQuery.of(context).platformBrightness == Brightness.dark);
}

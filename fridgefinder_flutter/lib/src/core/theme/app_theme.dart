import 'package:flutter/material.dart';

class AppTheme {
  // Light theme colors
  static const Color _lightPrimary = Color(0xFF2196F3); // Same blue as top bar
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightBackground = Color(0xFFFAFAFA);
  static const Color _lightError = Color(0xFFB3261E);

  // Dark theme colors - Softer palette inspired by Material Design 3, Spotify, Discord, YouTube
  static const Color _darkPrimary = Color(0xFF2196F3); // Light blue
  static const Color _darkSurface = Color(
    0xFF1E1E1E,
  ); // Slightly lighter surface
  static const Color _darkBackground = Color(0xFF121212); // Deep background
  static const Color _darkSurfaceContainer = Color(
    0xFF2A2A2A,
  ); // For elevated surfaces
  static const Color _darkSurfaceContainerHigh = Color(
    0xFF363636,
  ); // For higher elevation
  static const Color _darkError = Color(0xFFF28482);

  /// Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: _lightPrimary,
        surface: _lightSurface,
        error: _lightError,
        surfaceContainerHighest: const Color(0xFFF5F5F5),
      ),
      scaffoldBackgroundColor: _lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightSurface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _lightSurface,
        elevation: 8,
        selectedItemColor: _lightPrimary,
        unselectedItemColor: Colors.grey,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _lightPrimary,
          side: const BorderSide(color: _lightPrimary),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.black87),
        displayMedium: TextStyle(color: Colors.black87),
        displaySmall: TextStyle(color: Colors.black87),
        headlineLarge: TextStyle(color: Colors.black87),
        headlineMedium: TextStyle(color: Colors.black87),
        headlineSmall: TextStyle(color: Colors.black87),
        titleLarge: TextStyle(color: Colors.black87),
        titleMedium: TextStyle(color: Colors.black87),
        titleSmall: TextStyle(color: Colors.black87),
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
        bodySmall: TextStyle(color: Colors.grey),
        labelLarge: TextStyle(color: Colors.white),
      ),
    );
  }

  /// Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: _darkPrimary,
        surface: _darkSurface,
        error: _darkError,
        surfaceContainer: _darkSurfaceContainer,
        surfaceContainerHigh: _darkSurfaceContainerHigh,
        surfaceContainerHighest: _darkSurfaceContainerHigh,
      ),
      scaffoldBackgroundColor: _darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: _darkSurfaceContainer,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white70),
        titleTextStyle: const TextStyle(
          color: Colors.white70,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _darkSurfaceContainer,
        elevation: 8,
        selectedItemColor: _darkPrimary,
        unselectedItemColor: Colors.grey[600],
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: Colors.black87,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkPrimary,
          side: const BorderSide(color: _darkPrimary),
        ),
      ),
      cardTheme: CardThemeData(
        color: _darkSurfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white70),
        displayMedium: TextStyle(color: Colors.white70),
        displaySmall: TextStyle(color: Colors.white70),
        headlineLarge: TextStyle(color: Colors.white70),
        headlineMedium: TextStyle(color: Colors.white70),
        headlineSmall: TextStyle(color: Colors.white70),
        titleLarge: TextStyle(color: Colors.white70),
        titleMedium: TextStyle(color: Colors.white70),
        titleSmall: TextStyle(color: Colors.white70),
        bodyLarge: TextStyle(color: Colors.white70),
        bodyMedium: TextStyle(color: Colors.white70),
        bodySmall: TextStyle(color: Colors.grey),
        labelLarge: TextStyle(color: Colors.black87),
      ),
    );
  }
}

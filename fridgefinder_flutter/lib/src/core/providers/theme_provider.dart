import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum AppThemeMode { light, dark, system }

/// Notifier to manage theme mode state with persistence
class ThemeModeNotifier extends Notifier<AppThemeMode> {
  static const String _boxName = 'app_settings';
  static const String _themeKey = 'theme_mode';

  @override
  AppThemeMode build() {
    // Load theme asynchronously without blocking
    Future.microtask(() => _loadTheme());
    return AppThemeMode.system;
  }

  Future<void> _loadTheme() async {
    try {
      final settingsBox = await Hive.openBox<String>(_boxName);
      final savedTheme = settingsBox.get(_themeKey);

      if (savedTheme != null) {
        state = AppThemeMode.values.byName(savedTheme);
      }
    } catch (e) {
      // If Hive fails (e.g., in tests or if not initialized), keep default (system)
      // This is expected in test environments
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
    try {
      final settingsBox = await Hive.openBox<String>(_boxName);
      await settingsBox.put(_themeKey, mode.name);
    } catch (e) {
      // If Hive fails (e.g., in tests or if not initialized), just update state
      // This is expected in test environments
    }
  }
}

/// Riverpod provider for theme mode
final themeModeProvider = NotifierProvider<ThemeModeNotifier, AppThemeMode>(() {
  return ThemeModeNotifier();
});

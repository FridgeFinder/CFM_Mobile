import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/routing/router.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/providers/theme_provider.dart';
import 'src/core/providers/location_provider.dart';

class FridgeFinderApp extends ConsumerWidget {
  const FridgeFinderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Request location permissions when app starts
    ref.watch(locationPermissionProvider);

    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'FridgeFinder',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _toFlutterThemeMode(themeMode),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeMode _toFlutterThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

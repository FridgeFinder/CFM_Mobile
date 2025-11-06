import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/routing/router.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/providers/theme_provider.dart';
import 'src/core/utils/app_logger.dart';

class FridgeFinderApp extends ConsumerWidget {
  const FridgeFinderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // NOTE: Location permissions are now requested on-demand in the map screen
    // This follows App Store guidelines to request permissions with context

    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(appThemeModeProvider);

    return MaterialApp.router(
      title: 'FridgeFinder',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _toFlutterThemeMode(themeMode),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      // Global error boundary for better crash handling
      // Note: ErrorWidget.builder is not set here to avoid test framework conflicts
      // Error handling is done via FlutterError.onError in main.dart instead
      builder: (context, child) => child ?? const SizedBox(),
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

/// Riverpod observer for logging provider lifecycle in debug mode
final class RiverpodLogger extends ProviderObserver {
  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    logger.d(
      '[Riverpod] Added ${context.provider.name ?? context.provider.runtimeType}',
    );
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    logger.providerUpdate(
      context.provider.name ?? context.provider.runtimeType.toString(),
      newValue,
    );
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    logger.d(
      '[Riverpod] Disposed ${context.provider.name ?? context.provider.runtimeType}',
    );
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    logger.e(
      '[Riverpod] Error in ${context.provider.name ?? context.provider.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

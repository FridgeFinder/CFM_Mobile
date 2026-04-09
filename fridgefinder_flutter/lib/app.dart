import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/routing/router.dart';
import 'src/core/theme/m3e_theme.dart';
import 'src/core/providers/theme_provider.dart';
import 'src/core/providers/notification_providers.dart';
import 'src/core/providers/notification_navigation_provider.dart';
import 'src/core/services/local_notification_service.dart';
import 'src/core/utils/app_logger.dart';

class FridgeFinderApp extends ConsumerStatefulWidget {
  const FridgeFinderApp({super.key});

  @override
  ConsumerState<FridgeFinderApp> createState() => _FridgeFinderAppState();
}

class _FridgeFinderAppState extends ConsumerState<FridgeFinderApp> {
  // No initState needed — authUserProvider is a StreamProvider that
  // listens to FirebaseAuth.authStateChanges() automatically.
  // Previously, a redundant listener here invalidated authUserProvider
  // on every auth event, causing a dispose-and-resubscribe cycle that
  // briefly put userProfileProvider into data(null), which triggered
  // a false redirect to /complete-profile.

  @override
  Widget build(BuildContext context) {
    // NOTE: Location permissions are now requested on-demand in the map screen
    // This follows App Store guidelines to request permissions with context

    // Initialize FCM and Geofencing services (they auto-start based on auth state)
    ref.watch(fcmServiceProvider);
    ref.watch(geofencingServiceProvider);

    // Set ref for local notification service to handle navigation
    LocalNotificationService().setRef(ref);

    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(appThemeModeProvider);

    // Listen for notification navigation globally (works from any screen)
    ref.listen(notificationNavigationProvider, (previous, next) {
      if (next != null && mounted) {
        logger.i('🔔🔔🔔 NOTIFICATION NAV: Global navigation triggered for fridge: $next 🔔🔔🔔');
        // Navigate to map view if not already there
        final currentRoute = router.routerDelegate.currentConfiguration.uri
            .toString();
        if (currentRoute != '/') {
          logger.i('🔔🔔🔔 NOTIFICATION NAV: Navigating to map view from: $currentRoute 🔔🔔🔔');
          router.go('/');
        } else {
          logger.i('🔔🔔🔔 NOTIFICATION NAV: Already on map view 🔔🔔🔔');
        }
      }
    });

    return MaterialApp.router(
      title: 'FridgeFinder',
      // M3E Theme Configuration
      theme: M3ETheme.lightTheme,
      darkTheme: M3ETheme.darkTheme,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'src/routing/router.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/providers/theme_provider.dart';
import 'src/core/providers/notification_providers.dart';
import 'src/core/providers/auth_provider.dart';
import 'src/core/services/local_notification_service.dart';
import 'src/core/utils/app_logger.dart';

class FridgeFinderApp extends ConsumerStatefulWidget {
  const FridgeFinderApp({super.key});

  @override
  ConsumerState<FridgeFinderApp> createState() => _FridgeFinderAppState();
}

class _FridgeFinderAppState extends ConsumerState<FridgeFinderApp> {
  @override
  void initState() {
    super.initState();
    // Handle Firebase Auth deep links and redirect results
    _handleAuthRedirects();
    
    // Listen for auth state changes to refresh providers
    firebase_auth.FirebaseAuth.instance.authStateChanges().listen((user) {
      logger.d('[App] Auth state changed: ${user?.uid ?? "null"}');
      // Force refresh of auth providers when auth state changes
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.invalidate(authUserProvider);
          }
        });
      }
    });
  }

  void _handleAuthRedirects() {
    // Handle Firebase Auth redirect results (for web/Google Sign-In)
    firebase_auth.FirebaseAuth.instance
        .getRedirectResult()
        .then((result) {
      if (result.user != null) {
        logger.i('Firebase Auth redirect result: ${result.user?.uid}');
        // Auth state will update automatically via authUserProvider
        // Invalidate to force refresh
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ref.invalidate(authUserProvider);
            }
          });
        }
      }
    }).catchError((error) {
      logger.e('Firebase Auth redirect error: $error');
    });
  }

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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'src/core/utils/app_logger.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Set up global error handlers
  _setupErrorHandlers();

  // Run app with ProviderScope and observers
  runApp(
    ProviderScope(
      observers: [
        // Add Riverpod logging in debug mode
        if (kDebugMode) RiverpodLogger(),
      ],
      child: const FridgeFinderApp(),
    ),
  );
}

/// Set up global error handlers for better crash reporting
void _setupErrorHandlers() {
  // Catch all Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    // Log the error
    logger.e(
      'Flutter Error: ${details.exception}',
      error: details.exception,
      stackTrace: details.stack,
    );

    // In debug mode, use default error handling (shows red screen)
    // In release mode, log silently
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  // Catch all Dart errors outside Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.e('Dart Error: $error', error: error, stackTrace: stack);

    // Return true to prevent default error handling
    return true;
  };

  // Handle async errors that escape zones
  runZonedGuarded(
    () {
      // App initialization already done above
    },
    (error, stack) {
      logger.e('Async Error: $error', error: error, stackTrace: stack);
    },
  );
}

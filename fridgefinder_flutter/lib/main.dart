import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'src/core/config/firebase_options_resolver.dart';
import 'src/core/providers/environment_provider.dart';
import 'src/core/utils/app_logger.dart';

/// Top-level function for handling background messages (must be top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow;
    }
    logger.i('Background isolate reusing existing Firebase default app');
  }
  logger.i('Handling background message: ${message.messageId}');

  // Background messages are handled automatically by FCM
  // Local notifications will be shown by the system
  if (message.notification != null) {
    logger.i('Background notification: ${message.notification?.title}');
  }
}

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: '.env');
    logger.i('Environment variables loaded successfully');
  } catch (e) {
    logger.w(
      'Failed to load .env file: $e. Continuing without environment variables.',
    );
  }

  // Initialize Hive before Firebase-backed services start.
  await Hive.initFlutter();

  // Load startup environment (dev/prod) and configure services.
  final env = await loadStartupEnvironment();
  Environment.setBootstrapEnvironment(env);
  logger.i('Environment: ${env.name}');

  // Initialize Firebase with the selected environment's options.
  // If a native plugin pre-initialized a different default app, replace it
  // so Auth/Database/Messaging all point at the chosen environment.
  final firebaseOptions = FirebaseOptionsResolver.resolve(env);
  await _initializeFirebaseForEnvironment(firebaseOptions);

  // Set up background message handler (must be called before runApp)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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

Future<void> _initializeFirebaseForEnvironment(FirebaseOptions options) async {
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(options: options);
      logger.i('Initialized Firebase app for project: ${options.projectId}');
      return;
    } on FirebaseException catch (e) {
      if (e.code != 'duplicate-app') {
        rethrow;
      }

      // Some iOS startup paths can pre-create [DEFAULT] before Flutter sees it.
      // Continue below to validate project/appId and switch if needed.
      final existing = Firebase.app();
      logger.w(
        'Firebase [DEFAULT] already existed during init '
        '(project: ${existing.options.projectId}); validating environment.',
      );
    }
  }

  final existingApp = Firebase.app();
  final existingOptions = existingApp.options;
  final isSameProject = existingOptions.projectId == options.projectId;
  final isSameAppId = existingOptions.appId == options.appId;

  if (isSameProject && isSameAppId) {
    logger.i('Reusing Firebase app for project: ${existingOptions.projectId}');
    return;
  }

  logger.w(
    'Replacing pre-initialized Firebase app '
    '(project: ${existingOptions.projectId}) with selected environment '
    '(project: ${options.projectId}).',
  );

  try {
    await existingApp.delete();
  } on FirebaseException catch (e) {
    logger.w('Failed to delete pre-initialized Firebase app: ${e.code}');
  }

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: options);
    logger.i('Initialized Firebase app for project: ${options.projectId}');
    return;
  }

  final current = Firebase.app().options;
  final switched =
      current.projectId == options.projectId && current.appId == options.appId;
  if (!switched) {
    logger.w(
      'Firebase default app remained on project ${current.projectId}; '
      'app restart may be required to fully switch environments.',
    );
  }
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

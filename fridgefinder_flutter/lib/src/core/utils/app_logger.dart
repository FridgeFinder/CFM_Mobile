import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

/// Centralized logger for the FridgeFinder app
///
/// Usage:
/// ```dart
/// import 'package:fridgefinder_app/src/core/utils/app_logger.dart';
///
/// logger.d('Debug message');
/// logger.i('Info message');
/// logger.w('Warning message');
/// logger.e('Error message');
/// logger.f('Fatal error message');
/// ```
///
/// Log Levels:
/// - VERBOSE (trace): Very detailed logs (development only)
/// - DEBUG: Detailed information for debugging
/// - INFO: General informational messages
/// - WARNING: Warnings that don't prevent functionality
/// - ERROR: Errors that should be investigated
/// - FATAL (wtf): Critical errors that should never happen
final logger = Logger(
  filter: _AppLogFilter(),
  printer: PrettyPrinter(
    methodCount: 2, // Number of method calls to be displayed
    errorMethodCount: 8, // Number of method calls for errors
    lineLength: 120, // Width of the output
    colors: true, // Colorful log messages
    printEmojis: true, // Print emojis in console
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Print timestamp
  ),
  level: kDebugMode ? Level.debug : Level.info,
);

/// Custom log filter that only shows logs in debug mode
class _AppLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // In release mode, only log warnings and above
    if (kReleaseMode) {
      return event.level.index >= Level.warning.index;
    }

    // In debug/profile mode, log everything above the configured level
    return event.level.index >= level!.index;
  }
}

/// Production logger for release builds (minimal overhead)
/// Only logs errors and warnings
final productionLogger = Logger(
  filter: ProductionFilter(),
  printer: SimplePrinter(colors: false),
  level: Level.warning,
);

/// Filter that only logs in production mode
class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // Only log warnings and errors in production
    return kReleaseMode && event.level.index >= Level.warning.index;
  }
}

/// Extension methods for common logging patterns
extension LoggerExtensions on Logger {
  /// Log an API request
  void apiRequest(String method, String url, {Map<String, dynamic>? data}) {
    d('API $method $url${data != null ? '\nData: $data' : ''}');
  }

  /// Log an API response
  void apiResponse(String url, int statusCode, {dynamic data}) {
    if (statusCode >= 200 && statusCode < 300) {
      d('API Response $statusCode $url${data != null ? '\nData: $data' : ''}');
    } else {
      w('API Response $statusCode $url${data != null ? '\nData: $data' : ''}');
    }
  }

  /// Log a navigation event
  void navigation(String route, {Map<String, dynamic>? params}) {
    i('Navigate to $route${params != null ? '\nParams: $params' : ''}');
  }

  /// Log a provider state change
  void providerUpdate(String provider, dynamic value) {
    d('Provider Update: $provider = $value');
  }

  /// Log a user action
  void userAction(String action, {Map<String, dynamic>? details}) {
    i('User Action: $action${details != null ? '\nDetails: $details' : ''}');
  }
}

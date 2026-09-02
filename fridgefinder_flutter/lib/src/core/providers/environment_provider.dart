import 'package:flutter/foundation.dart' show kDebugMode, visibleForTesting;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'environment_provider.g.dart';

const String _appEnvOverride = String.fromEnvironment('APP_ENV');

ApiEnvironment? _parseEnvironmentOverride(String raw) {
  if (raw.isEmpty) {
    return null;
  }

  final normalized = raw.toLowerCase().trim();
  switch (normalized) {
    case 'dev':
      return ApiEnvironment.dev;
    case 'prod':
      return ApiEnvironment.prod;
    default:
      return null;
  }
}

enum ApiEnvironment {
  dev(
    'https://api-dev.communityfridgefinder.com/v1',
    'https://users-api-dev.communityfridgefinder.com/v1',
    'https://notifications-api-dev.communityfridgefinder.com/v1',
    'https://user-rewards-api-dev.communityfridgefinder.com/v1',
    'https://fridgefinder-app-dev.firebaseapp.com/finishSignUp',
    'com.fridgefinder.fridgefinderFlutterApp',
    'com.fridgefinder.fridgefinderapp',
  ),
  prod(
    'https://api-prod.communityfridgefinder.com/v1',
    'https://users-api-prod.communityfridgefinder.com/v1',
    'https://notifications-api-prod.communityfridgefinder.com/v1',
    'https://user-rewards-api-prod.communityfridgefinder.com/v1',
    'https://fridgefinder-app.firebaseapp.com/finishSignUp',
    'com.fridgefinder.fridgefinderFlutterApp',
    'com.fridgefinder.fridgefinderapp',
  );

  const ApiEnvironment(
    this.fridgeApiBaseUrl,
    this.usersApiBaseUrl,
    this.notificationsApiBaseUrl,
    this.rewardsApiBaseUrl,
    this.magicLinkUrl,
    this.appBundleId,
    this.androidPackageName,
  );
  final String fridgeApiBaseUrl;
  final String usersApiBaseUrl;
  final String notificationsApiBaseUrl;
  final String rewardsApiBaseUrl;
  final String magicLinkUrl;
  final String appBundleId;
  final String androidPackageName;
}

/// Reads the startup environment before Riverpod initializes.
/// Priority:
/// 1) APP_ENV=dev dart-define override
/// 2) APP_ENV=dev from .env in debug builds
/// 3) default to prod
///
/// This avoids silently booting the app into dev because of old local state or
/// an invalid/missing environment value. Release builds intentionally ignore
/// .env for environment selection because .env is bundled as an asset.
Future<ApiEnvironment> loadStartupEnvironment() async {
  return resolveStartupEnvironment(
    dotenvAppEnv: dotenv.isInitialized ? dotenv.maybeGet('APP_ENV') : null,
  );
}

@visibleForTesting
ApiEnvironment resolveStartupEnvironment({
  String dartDefineAppEnv = _appEnvOverride,
  String? dotenvAppEnv,
  bool includeDotenv = kDebugMode,
}) {
  final dartDefineOverride = _parseEnvironmentOverride(dartDefineAppEnv);
  if (dartDefineOverride != null) {
    return dartDefineOverride;
  }

  if (dartDefineAppEnv.trim().isNotEmpty) {
    return ApiEnvironment.prod;
  }

  if (includeDotenv) {
    final dotenvOverride = _parseEnvironmentOverride(dotenvAppEnv ?? '');
    if (dotenvOverride == ApiEnvironment.dev) {
      return ApiEnvironment.dev;
    }
  }

  return ApiEnvironment.prod;
}

/// Notifier to manage API environment selection with persistence
@riverpod
class Environment extends _$Environment {
  static ApiEnvironment _bootstrapEnvironment = ApiEnvironment.prod;

  /// Set the bootstrap environment before Riverpod initializes.
  /// Called from main.dart after loadStartupEnvironment().
  static void setBootstrapEnvironment(ApiEnvironment env) {
    _bootstrapEnvironment = env;
  }

  /// Getter for testing purposes.
  static ApiEnvironment get bootstrapEnvironment => _bootstrapEnvironment;

  @override
  ApiEnvironment build() {
    return _bootstrapEnvironment;
  }
}

/// Provider that returns the current API base URL
@riverpod
String apiBaseUrl(Ref ref) {
  final environment = ref.watch(environmentProvider);
  return environment.fridgeApiBaseUrl;
}

/// Provider that returns the current Users API base URL
@riverpod
String usersApiBaseUrl(Ref ref) {
  final environment = ref.watch(environmentProvider);
  return environment.usersApiBaseUrl;
}

/// Provider that returns the current Notifications API base URL
@riverpod
String notificationsApiBaseUrl(Ref ref) {
  final environment = ref.watch(environmentProvider);
  return environment.notificationsApiBaseUrl;
}

/// Provider that returns the current User Rewards API base URL
@riverpod
String rewardsApiBaseUrl(Ref ref) {
  final environment = ref.watch(environmentProvider);
  return environment.rewardsApiBaseUrl;
}

/// Provider that returns the current Firebase email-link redirect URL
@riverpod
String magicLinkUrl(Ref ref) {
  final environment = ref.watch(environmentProvider);
  return environment.magicLinkUrl;
}

/// Provider that returns the shared app bundle/package identifier
@riverpod
String appBundleId(Ref ref) {
  final environment = ref.watch(environmentProvider);
  return environment.appBundleId;
}

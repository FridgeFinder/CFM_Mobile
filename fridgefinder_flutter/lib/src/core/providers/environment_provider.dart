import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'environment_provider.g.dart';

const String _appEnvOverride = String.fromEnvironment('APP_ENV');
const String _settingsBoxName = 'app_settings';
const String _environmentKey = 'api_environment';

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
/// 1) APP_ENV dart-define override (dev|prod)
/// 2) persisted environment from app settings (dev|prod)
/// 3) default to prod
///
/// This avoids silently booting the app into dev because of an old persisted
/// value from a previous run.
Future<ApiEnvironment> loadPersistedEnvironment() async {
  final override = _parseEnvironmentOverride(_appEnvOverride);
  if (override != null) {
    return override;
  }

  try {
    final settingsBox = await Hive.openBox<String>(_settingsBoxName);
    final persistedRaw = settingsBox.get(_environmentKey);
    final persisted = persistedRaw == null
        ? null
        : _parseEnvironmentOverride(persistedRaw);
    if (persisted != null) {
      return persisted;
    }
  } catch (_) {
    // Fall through to dev default if persistence cannot be read.
  }

  return ApiEnvironment.prod;
}

/// Notifier to manage API environment selection with persistence
@riverpod
class Environment extends _$Environment {
  static ApiEnvironment _bootstrapEnvironment = ApiEnvironment.prod;

  /// Set the bootstrap environment before Riverpod initializes.
  /// Called from main.dart after loadPersistedEnvironment().
  static void setBootstrapEnvironment(ApiEnvironment env) {
    _bootstrapEnvironment = env;
  }

  /// Getter for testing purposes.
  static ApiEnvironment get bootstrapEnvironment => _bootstrapEnvironment;

  @override
  ApiEnvironment build() {
    return _bootstrapEnvironment;
  }

  Future<void> setEnvironment(ApiEnvironment environment) async {
    state = environment;
    try {
      final settingsBox = await Hive.openBox<String>(_settingsBoxName);
      await settingsBox.put(_environmentKey, environment.name);
    } catch (e) {
      // If Hive fails (e.g., in tests or if not initialized), just update state
    }
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

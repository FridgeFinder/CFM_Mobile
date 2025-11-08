import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'environment_provider.g.dart';

enum ApiEnvironment {
  dev('https://api-dev.communityfridgefinder.com/v1'),
  prod('https://api-prod.communityfridgefinder.com/v1');

  const ApiEnvironment(this.baseUrl);
  final String baseUrl;
}

/// Notifier to manage API environment selection with persistence
@riverpod
class Environment extends _$Environment {
  static const String _boxName = 'app_settings';
  static const String _environmentKey = 'api_environment';

  @override
  ApiEnvironment build() {
    // Load environment asynchronously without blocking
    Future.microtask(() => _loadEnvironment());
    return ApiEnvironment.prod; // Default to production
  }

  Future<void> _loadEnvironment() async {
    try {
      final settingsBox = await Hive.openBox<String>(_boxName);
      final savedEnv = settingsBox.get(_environmentKey);

      if (savedEnv != null) {
        state = ApiEnvironment.values.byName(savedEnv);
      }
    } catch (e) {
      // If Hive fails (e.g., in tests or if not initialized), keep default (prod)
      // This is expected in test environments
    }
  }

  Future<void> setEnvironment(ApiEnvironment environment) async {
    state = environment;
    try {
      final settingsBox = await Hive.openBox<String>(_boxName);
      await settingsBox.put(_environmentKey, environment.name);
    } catch (e) {
      // If Hive fails (e.g., in tests or if not initialized), just update state
      // This is expected in test environments
    }
  }
}

/// Provider that returns the current API base URL
@riverpod
String apiBaseUrl(Ref ref) {
  final environment = ref.watch(environmentProvider);
  return environment.baseUrl;
}

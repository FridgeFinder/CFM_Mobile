import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'environment_provider.g.dart';

enum ApiEnvironment {
  dev(
    'https://api-dev.communityfridgefinder.com/v1',
    'https://fridgefinder-app-dev-default-rtdb.firebaseio.com/',
  ),
  prod(
    'https://api-prod.communityfridgefinder.com/v1',
    'https://fridgefinder-app-default-rtdb.firebaseio.com/',
  );

  const ApiEnvironment(this.baseUrl, this.databaseUrl);
  final String baseUrl;
  final String databaseUrl;
}

/// Reads persisted environment from Hive BEFORE Riverpod starts.
/// Called in main.dart during bootstrap. Safe default: prod.
Future<ApiEnvironment> loadPersistedEnvironment() async {
  try {
    final box = await Hive.openBox<String>('app_settings');
    final saved = box.get('api_environment');
    if (saved == null) return ApiEnvironment.prod;
    return ApiEnvironment.values.byName(saved);
  } catch (_) {
    return ApiEnvironment.prod;
  }
}

/// Notifier to manage API environment selection with persistence
@riverpod
class Environment extends _$Environment {
  static const String _boxName = 'app_settings';
  static const String _environmentKey = 'api_environment';

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
      final settingsBox = await Hive.openBox<String>(_boxName);
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
  return environment.baseUrl;
}

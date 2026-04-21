import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fridgefinder_app/src/core/providers/environment_provider.dart';
import 'package:fridgefinder_app/src/core/providers/database_provider.dart';

void main() {
  group('Bootstrap integration', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('hive_bootstrap_test_');
      Hive.init(tempDir.path);
    });

    tearDown(() async {
      await Hive.close();
      DatabaseProvider.configure(ApiEnvironment.prod);
      Environment.setBootstrapEnvironment(ApiEnvironment.prod);
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('persist dev → loadPersistedEnvironment → configure → dev URL', () async {
      // Simulate user having previously selected dev
      final box = await Hive.openBox<String>('app_settings');
      await box.put('api_environment', 'dev');
      await box.close();

      // Bootstrap sequence (mirrors main.dart)
      final env = await loadPersistedEnvironment();
      Environment.setBootstrapEnvironment(env);
      DatabaseProvider.configure(env);

      expect(env, ApiEnvironment.dev);
      expect(
        DatabaseProvider.databaseUrl,
        'https://fridgefinder-app-dev-default-rtdb.firebaseio.com/',
      );
    });

    test('empty Hive → loadPersistedEnvironment → configure → prod URL', () async {
      // Bootstrap sequence with no saved preference
      final env = await loadPersistedEnvironment();
      Environment.setBootstrapEnvironment(env);
      DatabaseProvider.configure(env);

      expect(env, ApiEnvironment.prod);
      expect(
        DatabaseProvider.databaseUrl,
        'https://fridgefinder-app-default-rtdb.firebaseio.com/',
      );
    });
  });
}

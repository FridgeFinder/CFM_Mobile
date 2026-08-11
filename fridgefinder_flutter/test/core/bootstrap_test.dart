import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fridgefinder_app/src/core/providers/environment_provider.dart';

void main() {
  group('Bootstrap integration', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('hive_bootstrap_test_');
      Hive.init(tempDir.path);
      final box = await Hive.openBox<String>('app_settings');
      await box.delete('api_environment');
      await box.close();
      Environment.setBootstrapEnvironment(ApiEnvironment.prod);
    });

    tearDown(() async {
      await Hive.close();
      Environment.setBootstrapEnvironment(ApiEnvironment.prod);
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('persist dev → loadPersistedEnvironment -> dev environment', () async {
      // Simulate user having previously selected dev
      final box = await Hive.openBox<String>('app_settings');
      await box.put('api_environment', 'dev');
      await box.close();

      // Bootstrap sequence (mirrors main.dart)
      final env = await loadPersistedEnvironment();
      Environment.setBootstrapEnvironment(env);

      expect(env, ApiEnvironment.dev);
    });

    test('empty Hive → loadPersistedEnvironment -> prod environment', () async {
      // Bootstrap sequence with no saved preference
      final env = await loadPersistedEnvironment();
      Environment.setBootstrapEnvironment(env);

      expect(env, ApiEnvironment.prod);
    });
  });
}

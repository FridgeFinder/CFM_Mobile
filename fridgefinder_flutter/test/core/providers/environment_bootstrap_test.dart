import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fridgefinder_app/src/core/providers/environment_provider.dart';

void main() {
  group('loadStartupEnvironment()', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('hive_env_test_');
      Hive.init(tempDir.path);
    });

    tearDown(() async {
      await Hive.close();
      dotenv.clean();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('returns prod when Hive box is empty', () async {
      final env = await loadStartupEnvironment();
      expect(env, ApiEnvironment.prod);
    });

    test('returns prod when "dev" is persisted without APP_ENV=dev', () async {
      final box = await Hive.openBox<String>('app_settings');
      await box.put('api_environment', 'dev');
      await box.close();

      final env = await loadStartupEnvironment();
      expect(env, ApiEnvironment.prod);
    });

    test('returns prod when persisted value is invalid', () async {
      final box = await Hive.openBox<String>('app_settings');
      await box.put('api_environment', 'garbage_value');
      await box.close();

      final env = await loadStartupEnvironment();
      expect(env, ApiEnvironment.prod);
    });

    test('returns dev when debug .env contains APP_ENV=dev', () async {
      dotenv.testLoad(fileInput: 'APP_ENV=dev');

      final env = await loadStartupEnvironment();
      expect(env, ApiEnvironment.dev);
    });

    test('returns prod when debug .env contains APP_ENV=prod', () async {
      dotenv.testLoad(fileInput: 'APP_ENV=prod');

      final env = await loadStartupEnvironment();
      expect(env, ApiEnvironment.prod);
    });

    test('resolver ignores .env dev when dotenv fallback is disabled', () {
      final env = resolveStartupEnvironment(
        dotenvAppEnv: 'dev',
        includeDotenv: false,
      );

      expect(env, ApiEnvironment.prod);
    });

    test('resolver returns dev when dart define contains APP_ENV=dev', () {
      final env = resolveStartupEnvironment(
        dartDefineAppEnv: 'dev',
        dotenvAppEnv: 'prod',
        includeDotenv: false,
      );

      expect(env, ApiEnvironment.dev);
    });

    test('resolver returns prod when dart define overrides .env dev', () {
      final env = resolveStartupEnvironment(
        dartDefineAppEnv: 'prod',
        dotenvAppEnv: 'dev',
      );

      expect(env, ApiEnvironment.prod);
    });
  });

  group('Environment bootstrap', () {
    test('setBootstrapEnvironment changes build() return value', () {
      // Default is prod
      Environment.setBootstrapEnvironment(ApiEnvironment.dev);
      // We can't easily call build() without Riverpod, but we verify
      // the static field is set correctly via the getter
      expect(Environment.bootstrapEnvironment, ApiEnvironment.dev);

      // Reset
      Environment.setBootstrapEnvironment(ApiEnvironment.prod);
      expect(Environment.bootstrapEnvironment, ApiEnvironment.prod);
    });
  });
}

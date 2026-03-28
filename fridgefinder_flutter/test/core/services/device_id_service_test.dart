import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:fridgefinder_app/src/core/services/device_id_service.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('DeviceIdService', () {
    test('getDeviceId() returns a non-empty string', () async {
      final service = DeviceIdService();
      final deviceId = await service.getDeviceId();
      expect(deviceId, isNotEmpty);
    });

    test('getDeviceId() returns the same ID on second call (cached)', () async {
      final service = DeviceIdService();
      final first = await service.getDeviceId();
      final second = await service.getDeviceId();
      expect(first, equals(second));
    });

    test('first launch generates and stores a new ID in Hive', () async {
      final service = DeviceIdService();
      final deviceId = await service.getDeviceId();

      // Verify it was stored in Hive
      final box = await Hive.openBox<String>('device_settings');
      final storedId = box.get('device_id');
      expect(storedId, equals(deviceId));
    });

    test('subsequent launch returns stored value without generating new',
        () async {
      // Pre-populate Hive with a known ID
      final box = await Hive.openBox<String>('device_settings');
      await box.put('device_id', 'ios_existingdeviceid1');
      await box.close();

      // Create a fresh service instance (no in-memory cache)
      final service = DeviceIdService();
      final deviceId = await service.getDeviceId();
      expect(deviceId, equals('ios_existingdeviceid1'));
    });

    test('device ID has correct platform prefix format', () async {
      final service = DeviceIdService();
      final deviceId = await service.getDeviceId();
      // Should start with ios_ or android_
      expect(
        deviceId.startsWith('ios_') || deviceId.startsWith('android_'),
        isTrue,
      );
    });
  });
}

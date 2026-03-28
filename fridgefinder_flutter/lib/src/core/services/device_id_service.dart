import 'dart:io';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

/// Service for generating and caching a stable device ID.
///
/// The device ID is used as the key under `users/{uid}/fcmTokens/{deviceId}`
/// to support multi-device FCM token storage. Each device gets a unique,
/// stable ID that persists across app restarts via Hive.
class DeviceIdService {
  static const _boxName = 'device_settings';
  static const _deviceIdKey = 'device_id';
  String? _cachedDeviceId;

  /// Returns a stable device ID, generating one on first launch.
  ///
  /// Format: `{platform}_{16-char-hex}` (e.g., `ios_a1b2c3d4e5f6g7h8`)
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;
    final box = await Hive.openBox<String>(_boxName);
    var deviceId = box.get(_deviceIdKey);
    if (deviceId == null || deviceId.isEmpty) {
      final platform = Platform.isIOS ? 'ios' : 'android';
      deviceId =
          '${platform}_${const Uuid().v4().replaceAll('-', '').substring(0, 16)}';
      await box.put(_deviceIdKey, deviceId);
    }
    _cachedDeviceId = deviceId;
    return deviceId;
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_provider.freezed.dart';
part 'location_provider.g.dart';

/// A model to represent the user's location
@freezed
abstract class UserLocation with _$UserLocation {
  const UserLocation._();

  const factory UserLocation({
    required LatLng position,
    required double accuracy,
    required DateTime timestamp,
  }) = _UserLocation;
}

/// Provider to check and request location permissions
@riverpod
Future<LocationPermission> locationPermission(Ref ref) async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  return permission;
}

/// Provider to get the user's current location (single fetch)
@riverpod
Future<UserLocation?> userLocation(Ref ref) async {
  // Check if user has enabled location access in settings
  final locationAccessEnabled = ref.watch(locationAccessProvider);
  if (!locationAccessEnabled) {
    return null;
  }

  final permission = await ref.watch(locationPermissionProvider.future);

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return null;
  }

  try {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update only if moved 10+ meters
      ),
    );

    return UserLocation(
      position: LatLng(position.latitude, position.longitude),
      accuracy: position.accuracy,
      timestamp: DateTime.now(),
    );
  } catch (e) {
    // Silently fail if location access is denied or unavailable
    return null;
  }
}

/// Provider to stream the user's location in real-time
@riverpod
Stream<UserLocation?> userLocationStream(Ref ref) async* {
  // Check if user has enabled location access in settings
  final locationAccessEnabled = ref.watch(locationAccessProvider);
  if (!locationAccessEnabled) {
    yield null;
    return;
  }

  final permission = await ref.watch(locationPermissionProvider.future);

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    yield null;
    return;
  }

  try {
    final positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update only if moved 10+ meters
        timeLimit: Duration(minutes: 5), // Timeout after 5 minutes
      ),
    );

    await for (final position in positionStream) {
      yield UserLocation(
        position: LatLng(position.latitude, position.longitude),
        accuracy: position.accuracy,
        timestamp: DateTime.now(),
      );
    }
  } catch (e) {
    // Silently fail if location streaming is unavailable
    yield null;
  }
}

/// Notifier for managing location access permission toggle
@riverpod
class LocationAccess extends _$LocationAccess {
  @override
  bool build() => true; // Default to enabled

  void toggleAccess() {
    state = !state;
  }

  /// Set location access - if enabling, requests permissions
  /// If disabling, just turns off the toggle
  /// Returns a map with 'success' and optional 'openSettings' flags
  Future<Map<String, dynamic>> setAccessWithPermission(bool value) async {
    if (value) {
      // Enabling location access - check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();

      // If denied or not determined, try to request
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final isGranted =
          permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      if (isGranted) {
        state = true;
        return {'success': true};
      } else if (permission == LocationPermission.deniedForever) {
        // Permission permanently denied, need to guide to settings
        state = false;
        return {'success': false, 'openSettings': true};
      } else {
        // Permission denied, keep state as false
        state = false;
        return {'success': false, 'openSettings': false};
      }
    } else {
      // Disabling location access - just turn off
      state = false;
      return {'success': true, 'disabled': true};
    }
  }

  void setAccess(bool value) {
    state = value;
  }
}

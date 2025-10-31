import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// A model to represent the user's location
class UserLocation {
  final LatLng position;
  final double accuracy;
  final DateTime timestamp;

  UserLocation({
    required this.position,
    required this.accuracy,
    required this.timestamp,
  });

  @override
  String toString() =>
      'UserLocation(lat: ${position.latitude}, lng: ${position.longitude}, accuracy: $accuracy)';
}

/// Provider to check and request location permissions
final locationPermissionProvider = FutureProvider<LocationPermission>((
  ref,
) async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  return permission;
});

/// Provider to get the user's current location (single fetch)
final userLocationProvider = FutureProvider<UserLocation?>((ref) async {
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
});

/// Provider to stream the user's location in real-time
final userLocationStreamProvider = StreamProvider<UserLocation?>((ref) async* {
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
});

/// Notifier for managing location access permission toggle
class LocationAccessNotifier extends Notifier<bool> {
  @override
  bool build() => true; // Default to enabled

  void toggleAccess() {
    state = !state;
  }

  /// Set location access - if enabling, requests permissions
  /// If disabling, just turns off the toggle
  Future<bool> setAccessWithPermission(bool value) async {
    if (value) {
      // Enabling location access - request permissions
      final permission = await Geolocator.requestPermission();
      final isGranted =
          permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      if (isGranted) {
        state = true;
        return true;
      } else {
        // Permission denied, keep state as false
        state = false;
        return false;
      }
    } else {
      // Disabling location access - just turn off
      state = false;
      return true;
    }
  }

  void setAccess(bool value) {
    state = value;
  }
}

/// Provider to toggle user's location data access on/off
/// User can deny location data through settings even if permission is granted
final locationAccessProvider = NotifierProvider<LocationAccessNotifier, bool>(
  () => LocationAccessNotifier(),
);

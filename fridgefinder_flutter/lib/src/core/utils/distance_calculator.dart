import 'package:latlong2/latlong.dart';
import 'dart:math';

/// Enum for distance units
enum DistanceUnit {
  kilometers('km'),
  miles('mi');

  final String abbreviation;
  const DistanceUnit(this.abbreviation);
}

/// Utility class for calculating distances between geographic coordinates
class DistanceCalculator {
  /// Earth's radius in kilometers
  static const double earthRadiusKm = 6371;

  /// Conversion factor from km to miles
  static const double kmToMilesConversion = 0.621371;

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in kilometers
  static double calculateDistanceInKm(LatLng from, LatLng to) {
    final lat1Rad = _degreesToRadians(from.latitude);
    final lon1Rad = _degreesToRadians(from.longitude);
    final lat2Rad = _degreesToRadians(to.latitude);
    final lon2Rad = _degreesToRadians(to.longitude);

    final dLat = lat2Rad - lat1Rad;
    final dLon = lon2Rad - lon1Rad;

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadiusKm * c;

    return distance;
  }

  /// Calculate distance in miles
  static double calculateDistanceInMiles(LatLng from, LatLng to) {
    final km = calculateDistanceInKm(from, to);
    return km * kmToMilesConversion;
  }

  /// Format distance for display with specified unit
  /// Defaults to miles (US-based)
  static String formatDistance(
    double distanceKm, {
    DistanceUnit unit = DistanceUnit.miles,
  }) {
    final distance = unit == DistanceUnit.miles
        ? distanceKm * kmToMilesConversion
        : distanceKm;

    if (distance < 0.1) {
      return 'Less than 0.1 ${unit.abbreviation}';
    } else if (distance < 1) {
      return '${(distance * 100).round() / 100} ${unit.abbreviation}';
    } else {
      return '${(distance * 10).round() / 10} ${unit.abbreviation}';
    }
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}

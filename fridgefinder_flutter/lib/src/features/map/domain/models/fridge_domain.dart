import 'package:flutter/material.dart';

/// Domain model for a community fridge
class FridgeDomain {
  final String id;
  final String name;
  final bool verified;
  final FridgeLocationDomain location;
  final FridgeMaintainerDomain? maintainer;
  final String? notes;
  final String? photoUrl;
  final String? lastEdited; // Unix epoch timestamp as string
  final FridgeReportDomain? latestFridgeReport;

  const FridgeDomain({
    required this.id,
    required this.name,
    required this.verified,
    required this.location,
    this.maintainer,
    this.notes,
    this.photoUrl,
    this.lastEdited,
    this.latestFridgeReport,
  });

  /// Factory constructor for JSON deserialization
  /// Handles real API response format from FridgeFinder API
  factory FridgeDomain.fromJson(Map<String, dynamic> json) {
    return FridgeDomain(
      id: json['id'] as String,
      name: json['name'] as String,
      verified: json['verified'] as bool? ?? false,
      location: FridgeLocationDomain.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      maintainer: json['maintainer'] != null
          ? FridgeMaintainerDomain.fromJson(
              json['maintainer'] as Map<String, dynamic>,
            )
          : null,
      notes: json['notes'] as String?,
      photoUrl: json['photoUrl'] as String?,
      lastEdited: json['last_edited'] as String?,
      latestFridgeReport: json['latestFridgeReport'] != null
          ? FridgeReportDomain.fromJson(
              json['latestFridgeReport'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Get marker color based on latest report condition and food level
  /// If no report is available, uses verified status to determine color
  Color get markerColor {
    final report = latestFridgeReport;

    // If we have a report, use it to determine color
    if (report != null) {
      switch (report.condition) {
        case FridgeCondition.good:
          return report.foodPercentage > 0.5 ? Colors.green : Colors.orange;
        case FridgeCondition.dirty:
          return Colors.yellow;
        case FridgeCondition.outOfOrder:
          return Colors.orange;
        case FridgeCondition.ghost:
          return Colors.red;
        case FridgeCondition.notAtLocation:
          return Colors.black;
      }
    }

    // If no report, use verification status
    return verified ? Colors.blue : Colors.grey;
  }

  /// Get status text for UI display
  String get statusText {
    if (!verified) return 'Unverified';

    final report = latestFridgeReport;
    if (report == null) return 'No recent updates';

    switch (report.condition) {
      case FridgeCondition.good:
        return 'Good';
      case FridgeCondition.dirty:
        return 'Dirty';
      case FridgeCondition.outOfOrder:
        return 'Out of Order';
      case FridgeCondition.ghost:
        return 'Ghost Fridge';
      case FridgeCondition.notAtLocation:
        return 'Not at Location';
    }
  }

  /// Get food level description
  String get foodLevelText {
    final report = latestFridgeReport;
    if (report == null) return 'Unknown';

    final percentage = (report.foodPercentage * 100).round();
    if (percentage > 75) return 'Full ($percentage%)';
    if (percentage > 50) return 'Well Stocked ($percentage%)';
    if (percentage > 25) return 'Low ($percentage%)';
    return 'Very Low ($percentage%)';
  }

  @override
  String toString() => 'FridgeDomain(id: $id, name: $name)';
}

/// Fridge location information
class FridgeLocationDomain {
  final String? name;
  final String street;
  final String city;
  final String state;
  final String zip;
  final double geoLat;
  final double geoLng;

  const FridgeLocationDomain({
    this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
    required this.geoLat,
    required this.geoLng,
  });

  /// Factory constructor for JSON deserialization
  factory FridgeLocationDomain.fromJson(Map<String, dynamic> json) {
    return FridgeLocationDomain(
      name: json['name'] as String?,
      street: json['street'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zip: json['zip'] as String? ?? '',
      geoLat: (json['geoLat'] as num? ?? json['geo_lat'] as num? ?? 0)
          .toDouble(),
      geoLng: (json['geoLng'] as num? ?? json['geo_lng'] as num? ?? 0)
          .toDouble(),
    );
  }

  /// Full address string
  String get fullAddress => '$street, $city, $state $zip';

  /// Short address for lists
  String get shortAddress => '$city, $state';

  @override
  String toString() => 'FridgeLocation(city: $city)';
}

/// Fridge maintainer information
class FridgeMaintainerDomain {
  final String? name;
  final String? organization;
  final String? phone;
  final String? email;
  final String? instagram;
  final String? website;

  const FridgeMaintainerDomain({
    this.name,
    this.organization,
    this.phone,
    this.email,
    this.instagram,
    this.website,
  });

  /// Factory constructor for JSON deserialization
  factory FridgeMaintainerDomain.fromJson(Map<String, dynamic> json) {
    return FridgeMaintainerDomain(
      name: json['name'] as String?,
      organization: json['organization'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      instagram: json['instagram'] as String?,
      website: json['website'] as String?,
    );
  }

  @override
  String toString() => 'FridgeMaintainer(name: $name)';
}

/// Status report for a fridge
/// Matches the real FridgeFinder API report structure
class FridgeReportDomain {
  final String fridgeId;
  final FridgeCondition condition;
  final double foodPercentage; // 0-1 range
  final String? notes;
  final String? epochTimestamp; // Unix epoch as string
  final String? timestamp; // ISO8601 format

  const FridgeReportDomain({
    required this.fridgeId,
    required this.condition,
    required this.foodPercentage,
    this.notes,
    this.epochTimestamp,
    this.timestamp,
  });

  /// Factory constructor for JSON deserialization
  /// Handles real API response format
  factory FridgeReportDomain.fromJson(Map<String, dynamic> json) {
    return FridgeReportDomain(
      fridgeId: json['fridgeId'] as String? ?? '',
      condition: _parseCondition(json['condition'] as String?),
      foodPercentage: (json['foodPercentage'] as num? ?? 0).toDouble(),
      notes: json['notes'] as String?,
      epochTimestamp: json['epochTimestamp'] as String?,
      timestamp: json['timestamp'] as String?,
    );
  }

  static FridgeCondition _parseCondition(String? value) {
    switch (value) {
      case 'good':
        return FridgeCondition.good;
      case 'dirty':
        return FridgeCondition.dirty;
      case 'out of order':
        return FridgeCondition.outOfOrder;
      case 'ghost':
        return FridgeCondition.ghost;
      case 'not at location':
        return FridgeCondition.notAtLocation;
      default:
        return FridgeCondition.good;
    }
  }

  /// Convenience getter for report date
  DateTime? get reportDate {
    if (timestamp != null) {
      try {
        return DateTime.parse(timestamp!);
      } catch (e) {
        // Fall through to epoch timestamp
      }
    }

    if (epochTimestamp != null) {
      try {
        final epoch = int.parse(epochTimestamp!);
        return DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  /// Food percentage as integer (0-100)
  int get foodPercentageInt => (foodPercentage * 100).round();

  @override
  String toString() =>
      'FridgeReport(fridgeId: $fridgeId, condition: $condition)';
}

/// Enum for fridge condition status
/// Based on real FridgeFinder API condition values
enum FridgeCondition {
  good('good'),
  dirty('dirty'),
  outOfOrder('out of order'),
  ghost('ghost'),
  notAtLocation('not at location');

  const FridgeCondition(this.value);
  final String value;
}

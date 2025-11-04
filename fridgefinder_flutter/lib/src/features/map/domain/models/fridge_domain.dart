import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'fridge_domain.freezed.dart';
part 'fridge_domain.g.dart';

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

/// Fridge location information
@freezed
abstract class FridgeLocationDomain with _$FridgeLocationDomain {
  const FridgeLocationDomain._();

  const factory FridgeLocationDomain({
    String? name,
    @Default('') String street,
    @Default('') String city,
    @Default('') String state,
    @Default('') String zip,
    @Default(0.0) double geoLat,
    @Default(0.0) double geoLng,
  }) = _FridgeLocationDomain;

  factory FridgeLocationDomain.fromJson(Map<String, dynamic> json) =>
      _$FridgeLocationDomainFromJson(_normalizeLocationJson(json));

  /// Full address string
  String get fullAddress => '$street, $city, $state $zip';

  /// Short address for lists
  String get shortAddress => '$city, $state';
}

/// Helper function to normalize location JSON (handles both camelCase and snake_case)
Map<String, dynamic> _normalizeLocationJson(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);
  if (normalized.containsKey('geo_lat') && !normalized.containsKey('geoLat')) {
    normalized['geoLat'] = normalized['geo_lat'];
  }
  if (normalized.containsKey('geo_lng') && !normalized.containsKey('geoLng')) {
    normalized['geoLng'] = normalized['geo_lng'];
  }
  return normalized;
}

/// Fridge maintainer information
@freezed
abstract class FridgeMaintainerDomain with _$FridgeMaintainerDomain {
  const FridgeMaintainerDomain._();

  const factory FridgeMaintainerDomain({
    String? name,
    String? organization,
    String? phone,
    String? email,
    String? instagram,
    String? website,
  }) = _FridgeMaintainerDomain;

  factory FridgeMaintainerDomain.fromJson(Map<String, dynamic> json) =>
      _$FridgeMaintainerDomainFromJson(json);
}

/// Converter for FridgeCondition enum
class _FridgeConditionConverter
    implements JsonConverter<FridgeCondition, String> {
  const _FridgeConditionConverter();

  @override
  FridgeCondition fromJson(String json) {
    return _parseCondition(json);
  }

  @override
  String toJson(FridgeCondition object) {
    return object.value;
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
}

/// Status report for a fridge
/// Matches the real FridgeFinder API report structure
@freezed
abstract class FridgeReportDomain with _$FridgeReportDomain {
  const FridgeReportDomain._();

  const factory FridgeReportDomain({
    @Default('') String fridgeId,
    @_FridgeConditionConverter() required FridgeCondition condition,
    @Default(0.0) double foodPercentage, // 0-1 range
    String? notes,
    String? epochTimestamp, // Unix epoch as string
    String? timestamp, // ISO8601 format
  }) = _FridgeReportDomain;

  factory FridgeReportDomain.fromJson(Map<String, dynamic> json) =>
      _$FridgeReportDomainFromJson(json);

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
}

/// Domain model for a community fridge
@freezed
abstract class FridgeDomain with _$FridgeDomain {
  const FridgeDomain._(); // Required for custom methods

  const factory FridgeDomain({
    required String id,
    required String name,
    @Default(false) bool verified,
    required FridgeLocationDomain location,
    FridgeMaintainerDomain? maintainer,
    String? notes,
    String? photoUrl,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'last_edited')
    String? lastEdited, // Unix epoch timestamp as string
    FridgeReportDomain? latestFridgeReport,
  }) = _FridgeDomain;

  factory FridgeDomain.fromJson(Map<String, dynamic> json) =>
      _$FridgeDomainFromJson(json);

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
}

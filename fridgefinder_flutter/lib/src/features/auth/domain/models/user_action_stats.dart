import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_action_stats.freezed.dart';

@freezed
abstract class UserActionStats with _$UserActionStats {
  const factory UserActionStats({
    required String userId,
    required int totalPoints,
    required int fridgeReportCount,
    required int cleanedCount,
    required int filledCount,
    required int repairedCount,
    required DateTime lastUpdated,
  }) = _UserActionStats;

  factory UserActionStats.fromJson(Map<String, dynamic> json) {
    return UserActionStats(
      userId: json['userId'] as String,
      totalPoints: _intFromJson(json['totalPoints']),
      fridgeReportCount: _intFromJson(json['fridgeReportCount']),
      cleanedCount: _intFromJson(json['cleanedCount']),
      filledCount: _intFromJson(json['filledCount']),
      repairedCount: _intFromJson(json['repairedCount']),
      lastUpdated: _dateTimeFromJson(json['lastUpdated']),
    );
  }
}

int _intFromJson(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

DateTime _dateTimeFromJson(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
  if (value is int) {
    final isMilliseconds = value > 1000000000000;
    return DateTime.fromMillisecondsSinceEpoch(
      isMilliseconds ? value : value * 1000,
    );
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}

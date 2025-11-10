import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// Notification frequency options
enum NotificationFrequency {
  immediate('immediate'),
  daily('daily'),
  weekly('weekly');

  const NotificationFrequency(this.value);
  final String value;

  static NotificationFrequency fromString(String value) {
    return NotificationFrequency.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationFrequency.immediate,
    );
  }
}

/// Converter for NotificationFrequency enum
class NotificationFrequencyConverter
    implements JsonConverter<NotificationFrequency, String> {
  const NotificationFrequencyConverter();

  @override
  NotificationFrequency fromJson(String json) {
    return NotificationFrequency.fromString(json);
  }

  @override
  String toJson(NotificationFrequency object) {
    return object.value;
  }
}

/// User settings for notifications and geofencing
@freezed
abstract class UserSettings with _$UserSettings {
  const UserSettings._();

  const factory UserSettings({
    @Default(true) bool notificationsEnabled,
    @JsonKey(name: 'notificationFrequency', fromJson: _notificationFrequencyFromJson, toJson: _notificationFrequencyToJson)
    @Default(NotificationFrequency.immediate) NotificationFrequency notificationFrequency,
    @Default(false) bool geofencingEnabled,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
}

NotificationFrequency _notificationFrequencyFromJson(String json) {
  return NotificationFrequency.fromString(json);
}

String _notificationFrequencyToJson(NotificationFrequency frequency) {
  return frequency.value;
}

/// User profile model stored in Realtime Database
@freezed
abstract class UserProfile with _$UserProfile {
  const UserProfile._();

  const factory UserProfile({
    required String userId,
    String? email,
    String? phoneNumber,
    required String username,
    required bool isVolunteer,
    String? zipCode,
    @Default(0) int points,
    String? fcmToken,
    @JsonKey(fromJson: _userSettingsFromJson, toJson: _userSettingsToJson)
    @Default(UserSettings()) UserSettings settings,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    required DateTime createdAt,
    @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)
    DateTime? lastLoginAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

DateTime _dateTimeFromJson(String json) {
  return DateTime.parse(json);
}

String _dateTimeToJson(DateTime dateTime) {
  return dateTime.toIso8601String();
}

DateTime? _dateTimeFromJsonNullable(String? json) {
  return json != null ? DateTime.parse(json) : null;
}

String? _dateTimeToJsonNullable(DateTime? dateTime) {
  return dateTime?.toIso8601String();
}

// Helper functions for UserSettings serialization
UserSettings _userSettingsFromJson(Map<String, dynamic> json) {
  return UserSettings.fromJson(json);
}

Map<String, dynamic> _userSettingsToJson(UserSettings settings) {
  return settings.toJson();
}


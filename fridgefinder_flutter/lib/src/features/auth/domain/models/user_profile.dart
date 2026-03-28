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
    @Default(NotificationFrequency.immediate) NotificationFrequency notificationFrequency,
    @Default(false) bool geofencingEnabled,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
}

/// User profile model stored in Realtime Database
/// explicitToJson ensures nested objects (like UserSettings) are properly serialized
@Freezed(toJson: true, fromJson: true)
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
    Map<String, String>? fcmTokens,
    @Default(UserSettings()) UserSettings settings,
    required DateTime createdAt,
    DateTime? lastLoginAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}


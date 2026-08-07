import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

enum UserType {
  organizer('organizer'),
  host('host'),
  neighbor('neighbor'),
  volunteer('volunteer');

  const UserType(this.value);
  final String value;

  static UserType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'organizer':
        return UserType.organizer;
      case 'host':
        return UserType.host;
      case 'volunteer':
        return UserType.volunteer;
      case 'neighbor':
      default:
        return UserType.neighbor;
    }
  }
}

class UserTypeConverter implements JsonConverter<UserType, String> {
  const UserTypeConverter();

  @override
  UserType fromJson(String json) => UserType.fromString(json);

  @override
  String toJson(UserType object) => object.value;
}

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
    @Default(false) bool emailNotificationEnabled,
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
    @UserTypeConverter() @Default(UserType.neighbor) UserType userType,
    String? zipcode,
    @Default(0) int points,
    @Default(UserSettings()) UserSettings settings,
    required DateTime createdAt,
    DateTime? lastUpdated,
    DateTime? lastLoginAt,
  }) = _UserProfile;

  String? get zipCode => zipcode;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}


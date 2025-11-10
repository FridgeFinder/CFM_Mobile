// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) =>
    _UserSettings(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      notificationFrequency: json['notificationFrequency'] == null
          ? NotificationFrequency.immediate
          : _notificationFrequencyFromJson(
              json['notificationFrequency'] as String,
            ),
      geofencingEnabled: json['geofencingEnabled'] as bool? ?? false,
    );

Map<String, dynamic> _$UserSettingsToJson(_UserSettings instance) =>
    <String, dynamic>{
      'notificationsEnabled': instance.notificationsEnabled,
      'notificationFrequency': _notificationFrequencyToJson(
        instance.notificationFrequency,
      ),
      'geofencingEnabled': instance.geofencingEnabled,
    };

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  userId: json['userId'] as String,
  email: json['email'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  username: json['username'] as String,
  isVolunteer: json['isVolunteer'] as bool,
  zipCode: json['zipCode'] as String?,
  points: (json['points'] as num?)?.toInt() ?? 0,
  fcmToken: json['fcmToken'] as String?,
  settings: json['settings'] == null
      ? const UserSettings()
      : _userSettingsFromJson(json['settings'] as Map<String, dynamic>),
  createdAt: _dateTimeFromJson(json['createdAt'] as String),
  lastLoginAt: _dateTimeFromJsonNullable(json['lastLoginAt'] as String?),
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'username': instance.username,
      'isVolunteer': instance.isVolunteer,
      'zipCode': instance.zipCode,
      'points': instance.points,
      'fcmToken': instance.fcmToken,
      'settings': _userSettingsToJson(instance.settings),
      'createdAt': _dateTimeToJson(instance.createdAt),
      'lastLoginAt': _dateTimeToJsonNullable(instance.lastLoginAt),
    };

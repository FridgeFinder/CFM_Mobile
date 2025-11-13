// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) =>
    _UserSettings(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      notificationFrequency:
          $enumDecodeNullable(
            _$NotificationFrequencyEnumMap,
            json['notificationFrequency'],
          ) ??
          NotificationFrequency.immediate,
      geofencingEnabled: json['geofencingEnabled'] as bool? ?? false,
    );

Map<String, dynamic> _$UserSettingsToJson(_UserSettings instance) =>
    <String, dynamic>{
      'notificationsEnabled': instance.notificationsEnabled,
      'notificationFrequency':
          _$NotificationFrequencyEnumMap[instance.notificationFrequency]!,
      'geofencingEnabled': instance.geofencingEnabled,
    };

const _$NotificationFrequencyEnumMap = {
  NotificationFrequency.immediate: 'immediate',
  NotificationFrequency.daily: 'daily',
  NotificationFrequency.weekly: 'weekly',
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
      : UserSettings.fromJson(json['settings'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
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
      'settings': instance.settings.toJson(),
      'createdAt': instance.createdAt.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
    };

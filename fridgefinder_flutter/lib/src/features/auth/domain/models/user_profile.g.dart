// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) =>
    _UserSettings(
      emailNotificationEnabled:
          json['emailNotificationEnabled'] as bool? ?? false,
      geofencingEnabled: json['geofencingEnabled'] as bool? ?? false,
    );

Map<String, dynamic> _$UserSettingsToJson(_UserSettings instance) =>
    <String, dynamic>{
      'emailNotificationEnabled': instance.emailNotificationEnabled,
      'geofencingEnabled': instance.geofencingEnabled,
    };

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  userId: json['userId'] as String,
  email: json['email'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  username: json['username'] as String,
  userType: json['userType'] == null
      ? UserType.neighbor
      : const UserTypeConverter().fromJson(json['userType'] as String),
  zipcode: json['zipcode'] as String?,
  points: (json['points'] as num?)?.toInt() ?? 0,
  settings: json['settings'] == null
      ? const UserSettings()
      : UserSettings.fromJson(json['settings'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastUpdated: json['lastUpdated'] == null
      ? null
      : DateTime.parse(json['lastUpdated'] as String),
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
      'userType': const UserTypeConverter().toJson(instance.userType),
      'zipcode': instance.zipcode,
      'points': instance.points,
      'settings': instance.settings.toJson(),
      'createdAt': instance.createdAt.toIso8601String(),
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
    };

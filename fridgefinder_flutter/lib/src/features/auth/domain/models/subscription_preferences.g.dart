// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubscriptionPreferences _$SubscriptionPreferencesFromJson(
  Map<String, dynamic> json,
) => _SubscriptionPreferences(
  fridgeId: json['fridgeId'] as String,
  subscribedAt: DateTime.parse(json['subscribedAt'] as String),
  notificationPreferences: json['notificationPreferences'] == null
      ? const NotificationPreferences()
      : NotificationPreferences.fromJson(
          json['notificationPreferences'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$SubscriptionPreferencesToJson(
  _SubscriptionPreferences instance,
) => <String, dynamic>{
  'fridgeId': instance.fridgeId,
  'subscribedAt': instance.subscribedAt.toIso8601String(),
  'notificationPreferences': instance.notificationPreferences,
};

_NotificationPreferences _$NotificationPreferencesFromJson(
  Map<String, dynamic> json,
) => _NotificationPreferences(
  updatedWithFood: json['updatedWithFood'] as bool? ?? false,
  runningLow: json['runningLow'] as bool? ?? false,
  empty: json['empty'] as bool? ?? false,
  needsCleaning: json['needsCleaning'] as bool? ?? false,
  needsServicing: json['needsServicing'] as bool? ?? false,
  routineValidation: json['routineValidation'] as bool? ?? false,
);

Map<String, dynamic> _$NotificationPreferencesToJson(
  _NotificationPreferences instance,
) => <String, dynamic>{
  'updatedWithFood': instance.updatedWithFood,
  'runningLow': instance.runningLow,
  'empty': instance.empty,
  'needsCleaning': instance.needsCleaning,
  'needsServicing': instance.needsServicing,
  'routineValidation': instance.routineValidation,
};

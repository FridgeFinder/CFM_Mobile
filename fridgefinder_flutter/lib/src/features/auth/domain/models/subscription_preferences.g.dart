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
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
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
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'notificationPreferences': instance.notificationPreferences.toJson(),
};

_NotificationPreferences _$NotificationPreferencesFromJson(
  Map<String, dynamic> json,
) => _NotificationPreferences(
  contactTypePreferences: json['contactTypePreferences'] == null
      ? const ContactTypePreferences()
      : ContactTypePreferences.fromJson(
          json['contactTypePreferences'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$NotificationPreferencesToJson(
  _NotificationPreferences instance,
) => <String, dynamic>{
  'contactTypePreferences': instance.contactTypePreferences.toJson(),
};

_ContactTypePreferences _$ContactTypePreferencesFromJson(
  Map<String, dynamic> json,
) => _ContactTypePreferences(
  email: json['email'] == null
      ? const FridgeNotificationFlags()
      : FridgeNotificationFlags.fromJson(json['email'] as Map<String, dynamic>),
  device: json['device'] == null
      ? const FridgeNotificationFlags()
      : FridgeNotificationFlags.fromJson(
          json['device'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$ContactTypePreferencesToJson(
  _ContactTypePreferences instance,
) => <String, dynamic>{
  'email': instance.email.toJson(),
  'device': instance.device.toJson(),
};

_FridgeNotificationFlags _$FridgeNotificationFlagsFromJson(
  Map<String, dynamic> json,
) => _FridgeNotificationFlags(
  good: json['good'] as bool? ?? true,
  dirty: json['dirty'] as bool? ?? false,
  outOfOrder: json['outOfOrder'] as bool? ?? false,
  notAtLocation: json['notAtLocation'] as bool? ?? true,
  ghost: json['ghost'] as bool? ?? true,
  noFood: json['noFood'] as bool? ?? false,
  hasFood: json['hasFood'] as bool? ?? false,
);

Map<String, dynamic> _$FridgeNotificationFlagsToJson(
  _FridgeNotificationFlags instance,
) => <String, dynamic>{
  'good': instance.good,
  'dirty': instance.dirty,
  'outOfOrder': instance.outOfOrder,
  'notAtLocation': instance.notAtLocation,
  'ghost': instance.ghost,
  'noFood': instance.noFood,
  'hasFood': instance.hasFood,
};

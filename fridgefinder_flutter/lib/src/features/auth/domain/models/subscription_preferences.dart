import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_preferences.freezed.dart';
part 'subscription_preferences.g.dart';

/// Notification preferences for a subscribed fridge
/// toJson/fromJson params ensure nested NotificationPreferences is properly serialized
@Freezed(toJson: true, fromJson: true)
abstract class SubscriptionPreferences with _$SubscriptionPreferences {
  const SubscriptionPreferences._();

  const factory SubscriptionPreferences({
    required String fridgeId,
    required DateTime subscribedAt,
    DateTime? updatedAt,
    @Default(NotificationPreferences()) NotificationPreferences notificationPreferences,
  }) = _SubscriptionPreferences;

  factory SubscriptionPreferences.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPreferencesFromJson(json);
}

/// Notification preferences grouped by contact channel.
@freezed
abstract class NotificationPreferences with _$NotificationPreferences {
  const NotificationPreferences._();

  const factory NotificationPreferences({
    @Default(ContactTypePreferences()) ContactTypePreferences contactTypePreferences,
  }) = _NotificationPreferences;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);
}

@freezed
abstract class ContactTypePreferences with _$ContactTypePreferences {
  const ContactTypePreferences._();

  const factory ContactTypePreferences({
    @Default(FridgeNotificationFlags()) FridgeNotificationFlags email,
    @Default(FridgeNotificationFlags()) FridgeNotificationFlags device,
  }) = _ContactTypePreferences;

  factory ContactTypePreferences.fromJson(Map<String, dynamic> json) =>
      _$ContactTypePreferencesFromJson(json);
}

@freezed
abstract class FridgeNotificationFlags with _$FridgeNotificationFlags {
  const FridgeNotificationFlags._();

  const factory FridgeNotificationFlags({
    @Default(true) bool good,
    @Default(false) bool dirty,
    @Default(false) bool outOfOrder,
    @Default(true) bool notAtLocation,
    @Default(true) bool ghost,
    @Default(false) bool noFood,
    @Default(false) bool hasFood,
  }) = _FridgeNotificationFlags;

  factory FridgeNotificationFlags.fromJson(Map<String, dynamic> json) =>
      _$FridgeNotificationFlagsFromJson(json);
}


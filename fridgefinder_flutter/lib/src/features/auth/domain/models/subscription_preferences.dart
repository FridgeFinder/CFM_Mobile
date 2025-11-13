import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_preferences.freezed.dart';
part 'subscription_preferences.g.dart';

/// Notification preferences for a subscribed fridge
@freezed
abstract class SubscriptionPreferences with _$SubscriptionPreferences {
  const SubscriptionPreferences._();

  const factory SubscriptionPreferences({
    required String fridgeId,
    required DateTime subscribedAt,
    @Default(NotificationPreferences()) NotificationPreferences notificationPreferences,
  }) = _SubscriptionPreferences;

  factory SubscriptionPreferences.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPreferencesFromJson(json);
}

/// Individual notification preference settings
@freezed
abstract class NotificationPreferences with _$NotificationPreferences {
  const NotificationPreferences._();

  const factory NotificationPreferences({
    @Default(false) bool updatedWithFood,
    @Default(false) bool runningLow,
    @Default(false) bool empty,
    @Default(false) bool needsCleaning,
    @Default(false) bool needsServicing,
    @Default(false) bool routineValidation,
  }) = _NotificationPreferences;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);
}


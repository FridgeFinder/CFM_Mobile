// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_navigation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for handling notification navigation
/// When a notification is tapped, this provider stores the fridge ID
/// and MapScreen will listen to this and show the fridge details

@ProviderFor(NotificationNavigation)
const notificationNavigationProvider = NotificationNavigationProvider._();

/// Provider for handling notification navigation
/// When a notification is tapped, this provider stores the fridge ID
/// and MapScreen will listen to this and show the fridge details
final class NotificationNavigationProvider
    extends $NotifierProvider<NotificationNavigation, String?> {
  /// Provider for handling notification navigation
  /// When a notification is tapped, this provider stores the fridge ID
  /// and MapScreen will listen to this and show the fridge details
  const NotificationNavigationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationNavigationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationNavigationHash();

  @$internal
  @override
  NotificationNavigation create() => NotificationNavigation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$notificationNavigationHash() =>
    r'3925823b7e18b208212f595be11d05f7f29260eb';

/// Provider for handling notification navigation
/// When a notification is tapped, this provider stores the fridge ID
/// and MapScreen will listen to this and show the fridge details

abstract class _$NotificationNavigation extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

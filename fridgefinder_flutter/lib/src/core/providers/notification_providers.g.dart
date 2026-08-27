// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for FCM Service

@ProviderFor(fcmService)
const fcmServiceProvider = FcmServiceProvider._();

/// Provider for FCM Service

final class FcmServiceProvider
    extends $FunctionalProvider<FCMService, FCMService, FCMService>
    with $Provider<FCMService> {
  /// Provider for FCM Service
  const FcmServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fcmServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fcmServiceHash();

  @$internal
  @override
  $ProviderElement<FCMService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FCMService create(Ref ref) {
    return fcmService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FCMService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FCMService>(value),
    );
  }
}

String _$fcmServiceHash() => r'23ed2590eb80d1cc6b4f67f01ed4d70b5a4f32fd';

/// Provider for Geofencing Service

@ProviderFor(geofencingService)
const geofencingServiceProvider = GeofencingServiceProvider._();

/// Provider for Geofencing Service

final class GeofencingServiceProvider
    extends
        $FunctionalProvider<
          GeofencingService,
          GeofencingService,
          GeofencingService
        >
    with $Provider<GeofencingService> {
  /// Provider for Geofencing Service
  const GeofencingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geofencingServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geofencingServiceHash();

  @$internal
  @override
  $ProviderElement<GeofencingService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GeofencingService create(Ref ref) {
    return geofencingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeofencingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeofencingService>(value),
    );
  }
}

String _$geofencingServiceHash() => r'0cf1fb71b3c8627670feb9dee8e4c2f7fe9afdb0';

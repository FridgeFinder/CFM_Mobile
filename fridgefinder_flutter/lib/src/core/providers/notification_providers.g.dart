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

String _$fcmServiceHash() => r'b9c95d9629a7d7ed490a17ab5cd91e681fb472ca';

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

String _$geofencingServiceHash() => r'24f7ece3daefa3236e7a14f1dd25043e3b26558e';

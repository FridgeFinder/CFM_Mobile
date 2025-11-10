// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider to check and request location permissions

@ProviderFor(locationPermission)
const locationPermissionProvider = LocationPermissionProvider._();

/// Provider to check and request location permissions

final class LocationPermissionProvider
    extends
        $FunctionalProvider<
          AsyncValue<LocationPermission>,
          LocationPermission,
          FutureOr<LocationPermission>
        >
    with
        $FutureModifier<LocationPermission>,
        $FutureProvider<LocationPermission> {
  /// Provider to check and request location permissions
  const LocationPermissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationPermissionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationPermissionHash();

  @$internal
  @override
  $FutureProviderElement<LocationPermission> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LocationPermission> create(Ref ref) {
    return locationPermission(ref);
  }
}

String _$locationPermissionHash() =>
    r'aab462ab6c40a3eda599ae6d6a8800ea7475b6c5';

/// Provider to get the user's current location (single fetch)

@ProviderFor(userLocation)
const userLocationProvider = UserLocationProvider._();

/// Provider to get the user's current location (single fetch)

final class UserLocationProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserLocation?>,
          UserLocation?,
          FutureOr<UserLocation?>
        >
    with $FutureModifier<UserLocation?>, $FutureProvider<UserLocation?> {
  /// Provider to get the user's current location (single fetch)
  const UserLocationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userLocationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userLocationHash();

  @$internal
  @override
  $FutureProviderElement<UserLocation?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UserLocation?> create(Ref ref) {
    return userLocation(ref);
  }
}

String _$userLocationHash() => r'68ddbb8ad512c0ef3b9cfc59c2c5616623854331';

/// Provider to stream the user's location in real-time

@ProviderFor(userLocationStream)
const userLocationStreamProvider = UserLocationStreamProvider._();

/// Provider to stream the user's location in real-time

final class UserLocationStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserLocation?>,
          UserLocation?,
          Stream<UserLocation?>
        >
    with $FutureModifier<UserLocation?>, $StreamProvider<UserLocation?> {
  /// Provider to stream the user's location in real-time
  const UserLocationStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userLocationStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userLocationStreamHash();

  @$internal
  @override
  $StreamProviderElement<UserLocation?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<UserLocation?> create(Ref ref) {
    return userLocationStream(ref);
  }
}

String _$userLocationStreamHash() =>
    r'8f7a85a4ba6ec84899f97accc2624851d2f3251c';

/// Notifier for managing location access permission toggle

@ProviderFor(LocationAccess)
const locationAccessProvider = LocationAccessProvider._();

/// Notifier for managing location access permission toggle
final class LocationAccessProvider
    extends $NotifierProvider<LocationAccess, bool> {
  /// Notifier for managing location access permission toggle
  const LocationAccessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationAccessProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationAccessHash();

  @$internal
  @override
  LocationAccess create() => LocationAccess();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$locationAccessHash() => r'd520721b6fc488537fe352de0efc42e16e3557f5';

/// Notifier for managing location access permission toggle

abstract class _$LocationAccess extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

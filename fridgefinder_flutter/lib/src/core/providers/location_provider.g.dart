// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$locationPermissionHash() =>
    r'aab462ab6c40a3eda599ae6d6a8800ea7475b6c5';

/// Provider to check and request location permissions
///
/// Copied from [locationPermission].
@ProviderFor(locationPermission)
final locationPermissionProvider =
    AutoDisposeFutureProvider<LocationPermission>.internal(
  locationPermission,
  name: r'locationPermissionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationPermissionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocationPermissionRef
    = AutoDisposeFutureProviderRef<LocationPermission>;
String _$userLocationHash() => r'68ddbb8ad512c0ef3b9cfc59c2c5616623854331';

/// Provider to get the user's current location (single fetch)
///
/// Copied from [userLocation].
@ProviderFor(userLocation)
final userLocationProvider = AutoDisposeFutureProvider<UserLocation?>.internal(
  userLocation,
  name: r'userLocationProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userLocationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserLocationRef = AutoDisposeFutureProviderRef<UserLocation?>;
String _$userLocationStreamHash() =>
    r'8f7a85a4ba6ec84899f97accc2624851d2f3251c';

/// Provider to stream the user's location in real-time
///
/// Copied from [userLocationStream].
@ProviderFor(userLocationStream)
final userLocationStreamProvider =
    AutoDisposeStreamProvider<UserLocation?>.internal(
  userLocationStream,
  name: r'userLocationStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userLocationStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserLocationStreamRef = AutoDisposeStreamProviderRef<UserLocation?>;
String _$locationAccessHash() => r'c228a20cd4cc3c448dd0403f6720c73f446a49b3';

/// Notifier for managing location access permission toggle
///
/// Copied from [LocationAccess].
@ProviderFor(LocationAccess)
final locationAccessProvider =
    AutoDisposeNotifierProvider<LocationAccess, bool>.internal(
  LocationAccess.new,
  name: r'locationAccessProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationAccessHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocationAccess = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

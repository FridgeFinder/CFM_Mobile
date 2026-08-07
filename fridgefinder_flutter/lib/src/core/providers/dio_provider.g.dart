// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider for Dio HTTP client with proper configuration
/// Uses dynamic base URL from environment provider

@ProviderFor(dio)
const dioProvider = DioProvider._();

/// Riverpod provider for Dio HTTP client with proper configuration
/// Uses dynamic base URL from environment provider

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Riverpod provider for Dio HTTP client with proper configuration
  /// Uses dynamic base URL from environment provider
  const DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'421a0014967f4a606731b16cf642b5a2f87d23ca';

/// Riverpod provider for Users API Dio client

@ProviderFor(userDio)
const userDioProvider = UserDioProvider._();

/// Riverpod provider for Users API Dio client

final class UserDioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Riverpod provider for Users API Dio client
  const UserDioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userDioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userDioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return userDio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$userDioHash() => r'ce9b7f3c5af6c34c63d3cb6ecd92b7abcaafb25a';

/// Riverpod provider for Notifications API Dio client

@ProviderFor(notificationsDio)
const notificationsDioProvider = NotificationsDioProvider._();

/// Riverpod provider for Notifications API Dio client

final class NotificationsDioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Riverpod provider for Notifications API Dio client
  const NotificationsDioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsDioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsDioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return notificationsDio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$notificationsDioHash() => r'8c0e6439dae2e51d2681e8cbd5dc9228f8421d2d';

/// Riverpod provider for User Rewards API Dio client

@ProviderFor(rewardsDio)
const rewardsDioProvider = RewardsDioProvider._();

/// Riverpod provider for User Rewards API Dio client

final class RewardsDioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Riverpod provider for User Rewards API Dio client
  const RewardsDioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rewardsDioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rewardsDioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return rewardsDio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$rewardsDioHash() => r'6d64f5d1884fcf4b8eb863d458cea222ade3bd6b';

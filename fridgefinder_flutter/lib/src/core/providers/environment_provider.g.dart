// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier to manage API environment selection with persistence

@ProviderFor(Environment)
const environmentProvider = EnvironmentProvider._();

/// Notifier to manage API environment selection with persistence
final class EnvironmentProvider
    extends $NotifierProvider<Environment, ApiEnvironment> {
  /// Notifier to manage API environment selection with persistence
  const EnvironmentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'environmentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$environmentHash();

  @$internal
  @override
  Environment create() => Environment();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiEnvironment value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiEnvironment>(value),
    );
  }
}

String _$environmentHash() => r'fba7e98a3443cec680bb65f97b5be0cb0cc20fbf';

/// Notifier to manage API environment selection with persistence

abstract class _$Environment extends $Notifier<ApiEnvironment> {
  ApiEnvironment build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ApiEnvironment, ApiEnvironment>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ApiEnvironment, ApiEnvironment>,
              ApiEnvironment,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider that returns the current API base URL

@ProviderFor(apiBaseUrl)
const apiBaseUrlProvider = ApiBaseUrlProvider._();

/// Provider that returns the current API base URL

final class ApiBaseUrlProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Provider that returns the current API base URL
  const ApiBaseUrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiBaseUrlProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiBaseUrlHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return apiBaseUrl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$apiBaseUrlHash() => r'fc7def4dbb6de30f3fb7e161778877ba8bb59664';

/// Provider that returns the current Users API base URL

@ProviderFor(usersApiBaseUrl)
const usersApiBaseUrlProvider = UsersApiBaseUrlProvider._();

/// Provider that returns the current Users API base URL

final class UsersApiBaseUrlProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Provider that returns the current Users API base URL
  const UsersApiBaseUrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usersApiBaseUrlProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usersApiBaseUrlHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return usersApiBaseUrl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$usersApiBaseUrlHash() => r'01fe624a29326935f2f42ab9d8c6d86ca1e89b9c';

/// Provider that returns the current Notifications API base URL

@ProviderFor(notificationsApiBaseUrl)
const notificationsApiBaseUrlProvider = NotificationsApiBaseUrlProvider._();

/// Provider that returns the current Notifications API base URL

final class NotificationsApiBaseUrlProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Provider that returns the current Notifications API base URL
  const NotificationsApiBaseUrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsApiBaseUrlProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsApiBaseUrlHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return notificationsApiBaseUrl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$notificationsApiBaseUrlHash() =>
    r'9c6c7fe8be0ea31e55cc74118ad2f08d85d3cb9a';

/// Provider that returns the current User Rewards API base URL

@ProviderFor(rewardsApiBaseUrl)
const rewardsApiBaseUrlProvider = RewardsApiBaseUrlProvider._();

/// Provider that returns the current User Rewards API base URL

final class RewardsApiBaseUrlProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Provider that returns the current User Rewards API base URL
  const RewardsApiBaseUrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rewardsApiBaseUrlProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rewardsApiBaseUrlHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return rewardsApiBaseUrl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$rewardsApiBaseUrlHash() => r'bd1f7efad93b53bb62928b14fc83b8a5f564cb82';

/// Provider that returns the current Firebase email-link redirect URL

@ProviderFor(magicLinkUrl)
const magicLinkUrlProvider = MagicLinkUrlProvider._();

/// Provider that returns the current Firebase email-link redirect URL

final class MagicLinkUrlProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Provider that returns the current Firebase email-link redirect URL
  const MagicLinkUrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'magicLinkUrlProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$magicLinkUrlHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return magicLinkUrl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$magicLinkUrlHash() => r'30a8c1f991dc01c17c3413d8412dc97f3c294767';

/// Provider that returns the shared app bundle/package identifier

@ProviderFor(appBundleId)
const appBundleIdProvider = AppBundleIdProvider._();

/// Provider that returns the shared app bundle/package identifier

final class AppBundleIdProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Provider that returns the shared app bundle/package identifier
  const AppBundleIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appBundleIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appBundleIdHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return appBundleId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$appBundleIdHash() => r'c30a2d4551a9264ac8fc64996d4dbac58545833c';

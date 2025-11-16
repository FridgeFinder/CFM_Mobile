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

String _$environmentHash() => r'192d5740dc0531a8a9b4c793fd5da157ca4069ac';

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

String _$apiBaseUrlHash() => r'9cdc3371b499ae7cf33cfcde77ad9f2b939b0f19';

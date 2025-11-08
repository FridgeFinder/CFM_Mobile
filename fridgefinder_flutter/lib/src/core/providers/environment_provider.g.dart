// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$apiBaseUrlHash() => r'9cdc3371b499ae7cf33cfcde77ad9f2b939b0f19';

/// Provider that returns the current API base URL
///
/// Copied from [apiBaseUrl].
@ProviderFor(apiBaseUrl)
final apiBaseUrlProvider = AutoDisposeProvider<String>.internal(
  apiBaseUrl,
  name: r'apiBaseUrlProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$apiBaseUrlHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ApiBaseUrlRef = AutoDisposeProviderRef<String>;
String _$environmentHash() => r'192d5740dc0531a8a9b4c793fd5da157ca4069ac';

/// Notifier to manage API environment selection with persistence
///
/// Copied from [Environment].
@ProviderFor(Environment)
final environmentProvider =
    AutoDisposeNotifierProvider<Environment, ApiEnvironment>.internal(
  Environment.new,
  name: r'environmentProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$environmentHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Environment = AutoDisposeNotifier<ApiEnvironment>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

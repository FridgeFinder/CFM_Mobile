// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'neighborhood_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Singleton instance of [NeighborhoodService].

@ProviderFor(neighborhoodService)
const neighborhoodServiceProvider = NeighborhoodServiceProvider._();

/// Singleton instance of [NeighborhoodService].

final class NeighborhoodServiceProvider
    extends
        $FunctionalProvider<
          NeighborhoodService,
          NeighborhoodService,
          NeighborhoodService
        >
    with $Provider<NeighborhoodService> {
  /// Singleton instance of [NeighborhoodService].
  const NeighborhoodServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'neighborhoodServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$neighborhoodServiceHash();

  @$internal
  @override
  $ProviderElement<NeighborhoodService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NeighborhoodService create(Ref ref) {
    return neighborhoodService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NeighborhoodService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NeighborhoodService>(value),
    );
  }
}

String _$neighborhoodServiceHash() =>
    r'f4777c05288f7eb9915fc015a5ee5e6c9d1ecc85';

/// Resolves a neighborhood label for the given [fridgeId].
///
/// Watches [singleFridgeProvider] for lat/lng, then delegates to
/// [NeighborhoodService] which checks Hive cache → MapTiler API → fallback.

@ProviderFor(fridgeNeighborhood)
const fridgeNeighborhoodProvider = FridgeNeighborhoodFamily._();

/// Resolves a neighborhood label for the given [fridgeId].
///
/// Watches [singleFridgeProvider] for lat/lng, then delegates to
/// [NeighborhoodService] which checks Hive cache → MapTiler API → fallback.

final class FridgeNeighborhoodProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Resolves a neighborhood label for the given [fridgeId].
  ///
  /// Watches [singleFridgeProvider] for lat/lng, then delegates to
  /// [NeighborhoodService] which checks Hive cache → MapTiler API → fallback.
  const FridgeNeighborhoodProvider._({
    required FridgeNeighborhoodFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'fridgeNeighborhoodProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fridgeNeighborhoodHash();

  @override
  String toString() {
    return r'fridgeNeighborhoodProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as String;
    return fridgeNeighborhood(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FridgeNeighborhoodProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fridgeNeighborhoodHash() =>
    r'95d629d4864ab4b81bd8c870956a28df67bafcf9';

/// Resolves a neighborhood label for the given [fridgeId].
///
/// Watches [singleFridgeProvider] for lat/lng, then delegates to
/// [NeighborhoodService] which checks Hive cache → MapTiler API → fallback.

final class FridgeNeighborhoodFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String> {
  const FridgeNeighborhoodFamily._()
    : super(
        retry: null,
        name: r'fridgeNeighborhoodProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Resolves a neighborhood label for the given [fridgeId].
  ///
  /// Watches [singleFridgeProvider] for lat/lng, then delegates to
  /// [NeighborhoodService] which checks Hive cache → MapTiler API → fallback.

  FridgeNeighborhoodProvider call(String fridgeId) =>
      FridgeNeighborhoodProvider._(argument: fridgeId, from: this);

  @override
  String toString() => r'fridgeNeighborhoodProvider';
}

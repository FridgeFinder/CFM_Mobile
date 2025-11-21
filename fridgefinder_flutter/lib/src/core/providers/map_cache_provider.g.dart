// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_cache_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for cached tile provider using persistent Hive cache
/// This caches map tiles locally to reduce data usage and improve performance
/// Uses HiveCacheStore which stores tiles persistently on disk
///
/// Cache persists across app restarts, significantly reducing API usage
/// for returning users. Tiles are cached for up to 30 days.

@ProviderFor(cachedTileProvider)
const cachedTileProviderProvider = CachedTileProviderProvider._();

/// Provider for cached tile provider using persistent Hive cache
/// This caches map tiles locally to reduce data usage and improve performance
/// Uses HiveCacheStore which stores tiles persistently on disk
///
/// Cache persists across app restarts, significantly reducing API usage
/// for returning users. Tiles are cached for up to 30 days.

final class CachedTileProviderProvider
    extends
        $FunctionalProvider<
          AsyncValue<CachedTileProvider>,
          CachedTileProvider,
          FutureOr<CachedTileProvider>
        >
    with
        $FutureModifier<CachedTileProvider>,
        $FutureProvider<CachedTileProvider> {
  /// Provider for cached tile provider using persistent Hive cache
  /// This caches map tiles locally to reduce data usage and improve performance
  /// Uses HiveCacheStore which stores tiles persistently on disk
  ///
  /// Cache persists across app restarts, significantly reducing API usage
  /// for returning users. Tiles are cached for up to 30 days.
  const CachedTileProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cachedTileProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cachedTileProviderHash();

  @$internal
  @override
  $FutureProviderElement<CachedTileProvider> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CachedTileProvider> create(Ref ref) {
    return cachedTileProvider(ref);
  }
}

String _$cachedTileProviderHash() =>
    r'f6fe28c094f92057de7d7cb0146d5fe3cb4a7d4d';

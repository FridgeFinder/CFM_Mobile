// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_cache_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for cached tile provider using in-memory cache
/// This caches map tiles locally to reduce data usage and improve performance
/// Uses MemCacheStore which stores tiles in memory (LRU cache)
///
/// Note: For persistent storage across app restarts, consider implementing
/// a custom CacheStore using Hive. Current implementation uses memory cache
/// which is cleared when app closes.

@ProviderFor(cachedTileProvider)
const cachedTileProviderProvider = CachedTileProviderProvider._();

/// Provider for cached tile provider using in-memory cache
/// This caches map tiles locally to reduce data usage and improve performance
/// Uses MemCacheStore which stores tiles in memory (LRU cache)
///
/// Note: For persistent storage across app restarts, consider implementing
/// a custom CacheStore using Hive. Current implementation uses memory cache
/// which is cleared when app closes.

final class CachedTileProviderProvider
    extends
        $FunctionalProvider<
          CachedTileProvider,
          CachedTileProvider,
          CachedTileProvider
        >
    with $Provider<CachedTileProvider> {
  /// Provider for cached tile provider using in-memory cache
  /// This caches map tiles locally to reduce data usage and improve performance
  /// Uses MemCacheStore which stores tiles in memory (LRU cache)
  ///
  /// Note: For persistent storage across app restarts, consider implementing
  /// a custom CacheStore using Hive. Current implementation uses memory cache
  /// which is cleared when app closes.
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
  $ProviderElement<CachedTileProvider> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CachedTileProvider create(Ref ref) {
    return cachedTileProvider(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CachedTileProvider value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CachedTileProvider>(value),
    );
  }
}

String _$cachedTileProviderHash() =>
    r'8f65708a37c0a96fed9aa8f875fed98c0378c884';

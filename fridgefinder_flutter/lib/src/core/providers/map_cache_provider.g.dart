// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_cache_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cachedTileProviderHash() =>
    r'8f65708a37c0a96fed9aa8f875fed98c0378c884';

/// Provider for cached tile provider using in-memory cache
/// This caches map tiles locally to reduce data usage and improve performance
/// Uses MemCacheStore which stores tiles in memory (LRU cache)
///
/// Note: For persistent storage across app restarts, consider implementing
/// a custom CacheStore using Hive. Current implementation uses memory cache
/// which is cleared when app closes.
///
/// Copied from [cachedTileProvider].
@ProviderFor(cachedTileProvider)
final cachedTileProviderProvider =
    AutoDisposeProvider<CachedTileProvider>.internal(
  cachedTileProvider,
  name: r'cachedTileProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cachedTileProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CachedTileProviderRef = AutoDisposeProviderRef<CachedTileProvider>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

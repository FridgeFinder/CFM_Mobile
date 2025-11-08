import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_cache_provider.g.dart';

/// Provider for cached tile provider using in-memory cache
/// This caches map tiles locally to reduce data usage and improve performance
/// Uses MemCacheStore which stores tiles in memory (LRU cache)
///
/// Note: For persistent storage across app restarts, consider implementing
/// a custom CacheStore using Hive. Current implementation uses memory cache
/// which is cleared when app closes.
@riverpod
CachedTileProvider cachedTileProvider(Ref ref) {
  // Create in-memory cache store for map tiles
  // Max size: 50MB (sufficient for ~1000 tiles)
  // Max entry size: 2MB per tile (reasonable for map tiles)
  final cacheStore = MemCacheStore(
    maxSize: 50 * 1024 * 1024, // 50MB
    maxEntrySize: 2 * 1024 * 1024, // 2MB per tile
  );

  // Create cached tile provider with 30-day max stale period
  // Tiles older than 30 days will be refreshed
  return CachedTileProvider(
    maxStale: const Duration(days: 30),
    store: cacheStore,
  );
}

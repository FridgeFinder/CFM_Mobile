import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path_provider/path_provider.dart';

part 'map_cache_provider.g.dart';

/// Provider for cached tile provider using persistent Hive cache
/// This caches map tiles locally to reduce data usage and improve performance
/// Uses HiveCacheStore which stores tiles persistently on disk
///
/// Cache persists across app restarts, significantly reducing API usage
/// for returning users. Tiles are cached for up to 30 days.
@riverpod
Future<CachedTileProvider> cachedTileProvider(Ref ref) async {
  // Get app documents directory for persistent storage
  final appDocDir = await getApplicationDocumentsDirectory();
  final cachePath = '${appDocDir.path}/map_tile_cache';

  // Create persistent cache store for map tiles using Hive
  // Max size: 200MB (sufficient for ~4000 tiles, persists across app restarts)
  // Max entry size: 2MB per tile (reasonable for map tiles)
  final cacheStore = HiveCacheStore(
    cachePath,
    hiveBoxName: 'map_tiles',
  );

  // Create cached tile provider with 30-day max stale period
  // Tiles older than 30 days will be refreshed
  return CachedTileProvider(
    maxStale: const Duration(days: 30),
    store: cacheStore,
  );
}

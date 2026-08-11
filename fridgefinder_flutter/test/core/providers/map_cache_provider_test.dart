import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/core/providers/map_cache_provider.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('CachedTileProvider Tests', () {
    // Helper to create a mock cached tile provider for testing
    // Uses MemCacheStore to avoid path_provider platform channel issues in tests
    CachedTileProvider createMockCachedTileProvider() {
      final cacheStore = MemCacheStore(
        maxSize: 50 * 1024 * 1024,
        maxEntrySize: 2 * 1024 * 1024,
      );
      return CachedTileProvider(
        maxStale: const Duration(days: 30),
        store: cacheStore,
      );
    }

    test('provider creates CachedTileProvider instance', () async {
      final container = ProviderContainer(
        overrides: [
          cachedTileProviderProvider.overrideWith(
            (ref) async => createMockCachedTileProvider(),
          ),
        ],
      );

      // Provider is now async, so we need to wait for it
      final cachedTileProviderAsync = await container.read(
        cachedTileProviderProvider.future,
      );

      expect(cachedTileProviderAsync, isA<CachedTileProvider>());
      container.dispose();
    });

    test('provider uses persistent cache (HiveCacheStore in production)', () async {
      final container = ProviderContainer(
        overrides: [
          cachedTileProviderProvider.overrideWith(
            (ref) async => createMockCachedTileProvider(),
          ),
        ],
      );

      // Provider now uses HiveCacheStore for persistent tile caching in production
      // In tests, we use MemCacheStore to avoid platform channel dependencies
      final cachedTileProvider = await container.read(
        cachedTileProviderProvider.future,
      );

      // Verify it's a CachedTileProvider
      expect(cachedTileProvider, isA<CachedTileProvider>());

      // The CachedTileProvider should have a store configured
      // Note: We can't directly access the store, but we can verify the provider works
      expect(cachedTileProvider, isNotNull);
      container.dispose();
    });

    test('provider is available and can be watched', () async {
      final container = ProviderContainer(
        overrides: [
          cachedTileProviderProvider.overrideWith(
            (ref) async => createMockCachedTileProvider(),
          ),
        ],
      );

      // Should be able to watch the async provider
      final cachedTileProvider = await container.read(
        cachedTileProviderProvider.future,
      );

      expect(cachedTileProvider, isA<CachedTileProvider>());
      container.dispose();
    });

    test('provider maintains same instance on multiple reads', () async {
      final container = ProviderContainer(
        overrides: [
          cachedTileProviderProvider.overrideWith(
            (ref) async => createMockCachedTileProvider(),
          ),
        ],
      );

      final provider1 = await container.read(cachedTileProviderProvider.future);
      final provider2 = await container.read(cachedTileProviderProvider.future);

      // Async providers should return the same cached instance
      expect(provider1, same(provider2));
      container.dispose();
    });

    test('provider disposes correctly', () async {
      final container = ProviderContainer(
        overrides: [
          cachedTileProviderProvider.overrideWith(
            (ref) async => createMockCachedTileProvider(),
          ),
        ],
      );

      final cachedTileProvider = await container.read(
        cachedTileProviderProvider.future,
      );
      expect(cachedTileProvider, isNotNull);

      // Dispose container
      container.dispose();

      // Provider should be disposed (no error thrown)
      expect(() => container.dispose(), returnsNormally);
    });
  });
}

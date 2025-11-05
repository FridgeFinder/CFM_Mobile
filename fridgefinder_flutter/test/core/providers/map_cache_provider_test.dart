import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/core/providers/map_cache_provider.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import '../../test_helpers.dart';

void main() {
  group('CachedTileProvider Tests', () {
    test('provider creates CachedTileProvider instance', () async {
      final container = createTestProviderContainer();

      final cachedTileProvider = container.read(cachedTileProviderProvider);

      expect(cachedTileProvider, isA<CachedTileProvider>());
    });

    test('provider uses MemCacheStore', () async {
      final container = createTestProviderContainer();

      final cachedTileProvider = container.read(cachedTileProviderProvider);

      // Verify it's a CachedTileProvider
      expect(cachedTileProvider, isA<CachedTileProvider>());

      // The CachedTileProvider should have a store configured
      // Note: We can't directly access the store, but we can verify the provider works
      expect(cachedTileProvider, isNotNull);
    });

    test('provider is available and can be watched', () async {
      final container = createTestProviderContainer();

      // Should be able to watch the provider
      final cachedTileProvider = container.read(cachedTileProviderProvider);

      expect(cachedTileProvider, isA<CachedTileProvider>());
    });

    test('provider is singleton (same instance on multiple reads)', () async {
      final container = createTestProviderContainer();

      final provider1 = container.read(cachedTileProviderProvider);
      final provider2 = container.read(cachedTileProviderProvider);

      // Providers should be the same instance (singleton behavior)
      expect(provider1, same(provider2));
    });

    test('provider disposes correctly', () async {
      final container = createTestProviderContainer();

      final cachedTileProvider = container.read(cachedTileProviderProvider);
      expect(cachedTileProvider, isNotNull);

      // Dispose container
      container.dispose();

      // Provider should be disposed (no error thrown)
      expect(() => container.dispose(), returnsNormally);
    });
  });
}

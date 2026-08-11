import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/core/providers/theme_provider.dart';
import 'package:fridgefinder_app/src/core/providers/vector_tile_style_provider.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

void main() {
  group('VectorTileStyleProvider', () {
    // Helper to create a mock Style for testing
    Style createMockStyle() {
      final themeData = vtr.ThemeReader().read({
        'id': 'test',
        'version': 8,
        'sources': {
          'protomaps': {'type': 'vector'},
        },
        'layers': [
          {
            'id': 'test_fill',
            'type': 'fill',
            'source': 'protomaps',
            'source-layer': 'land',
            'paint': {'fill-color': '#ffffff'},
          },
        ],
      });
      return Style(
        theme: themeData,
        providers: TileProviders({
          'protomaps': NetworkVectorTileProvider(
            urlTemplate: 'https://example.com/{z}/{x}/{y}.mvt',
          ),
        }),
      );
    }

    test(
      'provider returns a non-null style object when overridden with mock',
      () async {
        final mockStyle = createMockStyle();
        final container = ProviderContainer(
          overrides: [
            vectorTileStyleProvider.overrideWith((ref) async => mockStyle),
          ],
        );
        addTearDown(container.dispose);

        final style = await container.read(vectorTileStyleProvider.future);
        expect(style, isNotNull);
        expect(style, isA<Style>());
      },
    );

    test(
      'provider throws when API key is missing (override to throw)',
      () async {
        final container = ProviderContainer(
          overrides: [
            vectorTileStyleProvider.overrideWith(
              (ref) async =>
                  throw Exception('Protomaps API key not configured'),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Listen to keep the provider alive during async resolution
        AsyncValue<Style>? lastState;
        final sub = container.listen(
          vectorTileStyleProvider,
          (prev, next) => lastState = next,
        );
        addTearDown(sub.close);

        // Trigger provider read and wait for microtask resolution
        container.read(vectorTileStyleProvider);
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(lastState, isNotNull);
        expect(lastState!.hasError, isTrue);
        expect(lastState!.error, isA<Exception>());
      },
    );

    test('provider caches style instance across multiple reads', () async {
      final mockStyle = createMockStyle();
      final container = ProviderContainer(
        overrides: [
          vectorTileStyleProvider.overrideWith((ref) async => mockStyle),
        ],
      );
      addTearDown(container.dispose);

      final style1 = await container.read(vectorTileStyleProvider.future);
      final style2 = await container.read(vectorTileStyleProvider.future);
      expect(style1, same(style2));
    });

    test('provider uses light flavor when app theme is light', () async {
      String? capturedFlavor;
      final mockStyle = createMockStyle();

      final container = ProviderContainer(
        overrides: [
          appThemeModeProvider.overrideWithValue(AppThemeMode.light),
          vectorTileStyleProvider.overrideWith((ref) async {
            final themeMode = ref.watch(appThemeModeProvider);
            final isDark = themeMode == AppThemeMode.dark;
            capturedFlavor = isDark ? 'dark' : 'light';
            return mockStyle;
          }),
        ],
      );
      addTearDown(container.dispose);

      await container.read(vectorTileStyleProvider.future);
      expect(capturedFlavor, 'light');
    });

    test('provider uses dark flavor when app theme is dark', () async {
      String? capturedFlavor;
      final mockStyle = createMockStyle();

      final container = ProviderContainer(
        overrides: [
          appThemeModeProvider.overrideWithValue(AppThemeMode.dark),
          vectorTileStyleProvider.overrideWith((ref) async {
            final themeMode = ref.watch(appThemeModeProvider);
            final isDark = themeMode == AppThemeMode.dark;
            capturedFlavor = isDark ? 'dark' : 'light';
            return mockStyle;
          }),
        ],
      );
      addTearDown(container.dispose);

      await container.read(vectorTileStyleProvider.future);
      expect(capturedFlavor, 'dark');
    });
  });
}

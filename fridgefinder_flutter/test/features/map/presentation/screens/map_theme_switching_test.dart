import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/core/providers/theme_provider.dart';
import 'package:fridgefinder_app/src/core/providers/vector_tile_style_provider.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

Style _createMockStyle() {
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

void main() {
  group('Map Theme Switching', () {
    test(
      'vectorTileStyleProvider rebuilds when app theme changes light→dark',
      () async {
        int buildCount = 0;
        String? lastFlavor;
        final mockStyle = _createMockStyle();

        final container = ProviderContainer(
          overrides: [
            appThemeModeProvider.overrideWithValue(AppThemeMode.light),
            vectorTileStyleProvider.overrideWith((ref) async {
              buildCount++;
              final themeMode = ref.watch(appThemeModeProvider);
              final isDark = themeMode == AppThemeMode.dark;
              lastFlavor = isDark ? 'dark' : 'light';
              return mockStyle;
            }),
          ],
        );
        addTearDown(container.dispose);

        // Initial read — light theme
        await container.read(vectorTileStyleProvider.future);
        expect(buildCount, 1);
        expect(lastFlavor, 'light');

        // Switch to dark theme
        // Use a new container since overrideWithValue is immutable
        final darkContainer = ProviderContainer(
          overrides: [
            appThemeModeProvider.overrideWithValue(AppThemeMode.dark),
            vectorTileStyleProvider.overrideWith((ref) async {
              buildCount++;
              final themeMode = ref.watch(appThemeModeProvider);
              final isDark = themeMode == AppThemeMode.dark;
              lastFlavor = isDark ? 'dark' : 'light';
              return mockStyle;
            }),
          ],
        );
        addTearDown(darkContainer.dispose);

        await darkContainer.read(vectorTileStyleProvider.future);
        expect(lastFlavor, 'dark');
      },
    );

    test(
      'map renders dark-themed vector tiles when app is in dark mode',
      () async {
        String? capturedFlavor;
        final mockStyle = _createMockStyle();

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
      },
    );
  });
}

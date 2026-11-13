import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/core/constants/map_tile_config.dart';
import 'package:fridgefinder_app/src/core/providers/theme_provider.dart';
import 'package:fridgefinder_app/src/core/providers/vector_tile_style_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapTileConfig zoom limits', () {
    test('camera can reach street level', () {
      expect(MapTileConfig.maxCameraZoom, 18.0);
    });

    test('camera limit is independent of, and deeper than, tile data zoom', () {
      expect(MapTileConfig.protomapsMaxDataZoom, 15);
      expect(
        MapTileConfig.maxCameraZoom,
        greaterThan(MapTileConfig.protomapsMaxDataZoom),
      );
    });

    test('preset zooms sit inside the camera range', () {
      for (final zoom in [
        MapTileConfig.initialCameraZoom,
        MapTileConfig.fridgeFocusZoom,
        MapTileConfig.userLocationZoom,
      ]) {
        expect(zoom, greaterThanOrEqualTo(MapTileConfig.minCameraZoom));
        expect(zoom, lessThanOrEqualTo(MapTileConfig.maxCameraZoom));
      }
    });
  });

  group('vectorTileStyleProvider (real provider, bundled theme)', () {
    setUp(() => dotenv.testLoad(fileInput: 'PROTOMAPS_API_KEY=test_key'));
    tearDown(() => dotenv.testLoad(fileInput: ''));

    for (final mode in [AppThemeMode.light, AppThemeMode.dark]) {
      test(
        '${mode.name}: requests tile data no deeper than Protomaps serves',
        () async {
          final container = ProviderContainer(
            overrides: [appThemeModeProvider.overrideWithValue(mode)],
          );
          addTearDown(container.dispose);

          final style = await container.read(vectorTileStyleProvider.future);

          expect(
            style.providers.get('protomaps').maximumZoom,
            MapTileConfig.protomapsMaxDataZoom,
          );
        },
      );
    }
  });
}

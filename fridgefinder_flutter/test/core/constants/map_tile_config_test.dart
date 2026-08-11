import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/core/constants/map_tile_config.dart';

void main() {
  group('MapTileConfig', () {
    group('getProtomapsApiKey', () {
      test('returns key from dotenv when present and valid', () {
        dotenv.testLoad(fileInput: 'PROTOMAPS_API_KEY=ed35b70061f4e4b1');
        expect(MapTileConfig.getProtomapsApiKey(), 'ed35b70061f4e4b1');
      });

      test('returns null when key is empty', () {
        dotenv.testLoad(fileInput: 'PROTOMAPS_API_KEY=');
        expect(MapTileConfig.getProtomapsApiKey(), isNull);
      });

      test('returns null when key is missing', () {
        dotenv.testLoad(fileInput: 'OTHER_KEY=value');
        expect(MapTileConfig.getProtomapsApiKey(), isNull);
      });

      test('returns null when key is placeholder', () {
        dotenv.testLoad(fileInput: 'PROTOMAPS_API_KEY=your_api_key_here');
        expect(MapTileConfig.getProtomapsApiKey(), isNull);
      });
    });

    group('getProtomapsTileUrl', () {
      test('returns correct MVT URL with key', () {
        dotenv.testLoad(fileInput: 'PROTOMAPS_API_KEY=testkey123');
        expect(
          MapTileConfig.getProtomapsTileUrl(),
          'https://api.protomaps.com/tiles/v4/{z}/{x}/{y}.mvt?key=testkey123',
        );
      });

      test('returns null when key missing', () {
        dotenv.testLoad(fileInput: 'OTHER_KEY=value');
        expect(MapTileConfig.getProtomapsTileUrl(), isNull);
      });
    });

    group('getProtomapsStyleUrl', () {
      test('returns light style URL', () {
        dotenv.testLoad(fileInput: 'PROTOMAPS_API_KEY=testkey123');
        expect(
          MapTileConfig.getProtomapsStyleUrl(flavor: 'light'),
          'https://api.protomaps.com/styles/v5/light/en.json?key=testkey123',
        );
      });

      test('returns dark style URL', () {
        dotenv.testLoad(fileInput: 'PROTOMAPS_API_KEY=testkey123');
        expect(
          MapTileConfig.getProtomapsStyleUrl(flavor: 'dark'),
          'https://api.protomaps.com/styles/v5/dark/en.json?key=testkey123',
        );
      });

      test('returns null when key missing', () {
        dotenv.testLoad(fileInput: 'OTHER_KEY=value');
        expect(MapTileConfig.getProtomapsStyleUrl(flavor: 'light'), isNull);
      });
    });

    group('getMapTilerApiKey', () {
      test('returns key when present and valid', () {
        dotenv.testLoad(fileInput: 'MAPTILER_API_KEY=tHUBQkHsMKOGq0AmHlpS');
        expect(MapTileConfig.getMapTilerApiKey(), 'tHUBQkHsMKOGq0AmHlpS');
      });

      test('returns null when key is placeholder', () {
        dotenv.testLoad(fileInput: 'MAPTILER_API_KEY=your_api_key_here');
        expect(MapTileConfig.getMapTilerApiKey(), isNull);
      });
    });

    group('getMapTilerStreetsUrl', () {
      test('returns raster URL with key', () {
        dotenv.testLoad(fileInput: 'MAPTILER_API_KEY=testkey456');
        expect(
          MapTileConfig.getMapTilerStreetsUrl(),
          'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=testkey456',
        );
      });

      test('returns null when key missing', () {
        dotenv.testLoad(fileInput: 'OTHER_KEY=value');
        expect(MapTileConfig.getMapTilerStreetsUrl(), isNull);
      });
    });

    group('openStreetMapUrl', () {
      test('is the standard OSM template', () {
        expect(
          MapTileConfig.openStreetMapUrl,
          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        );
      });
    });

    group('resolve', () {
      test('returns protomaps source when PROTOMAPS_API_KEY is valid', () {
        dotenv.testLoad(
          fileInput: 'PROTOMAPS_API_KEY=pmkey123\nMAPTILER_API_KEY=mtkey456',
        );
        final config = MapTileConfig.resolve();
        expect(config.source, MapTileSource.protomaps);
        expect(config.tileUrl, contains('protomaps.com'));
        expect(config.apiKey, 'pmkey123');
      });

      test('falls back to maptiler when only MAPTILER_API_KEY is valid', () {
        dotenv.testLoad(
          fileInput:
              'PROTOMAPS_API_KEY=your_api_key_here\nMAPTILER_API_KEY=mtkey456',
        );
        final config = MapTileConfig.resolve();
        expect(config.source, MapTileSource.maptiler);
        expect(config.tileUrl, contains('maptiler.com'));
        expect(config.apiKey, 'mtkey456');
      });

      test('falls back to openStreetMap when no API keys available', () {
        dotenv.testLoad(
          fileInput:
              'PROTOMAPS_API_KEY=your_api_key_here\nMAPTILER_API_KEY=your_api_key_here',
        );
        final config = MapTileConfig.resolve();
        expect(config.source, MapTileSource.openStreetMap);
        expect(config.tileUrl, contains('openstreetmap.org'));
        expect(config.apiKey, isNull);
      });
    });
  });
}

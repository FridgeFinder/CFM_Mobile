import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/core/providers/followed_fridges_provider.dart';
import 'package:fridgefinder_app/src/core/providers/location_provider.dart';
import 'package:fridgefinder_app/src/core/providers/map_cache_provider.dart';
import 'package:fridgefinder_app/src/core/providers/theme_provider.dart';
import 'package:fridgefinder_app/src/core/providers/vector_tile_style_provider.dart';
import 'package:fridgefinder_app/src/features/map/presentation/controllers/fridge_list_controller.dart';
import 'package:fridgefinder_app/src/features/map/presentation/screens/map_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

import '../../../../fixtures/fridge_fixtures.dart';
import '../../../../test_helpers.dart';

/// Street-level detail needs the camera to reach zoom 18.
const _streetLevelZoom = 18.0;

Style _createStyle() {
  final theme = vtr.ThemeReader().read({
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
    theme: theme,
    providers: TileProviders({
      'protomaps': NetworkVectorTileProvider(
        urlTemplate: 'https://example.com/{z}/{x}/{y}.mvt',
        maximumZoom: 15,
      ),
    }),
  );
}

/// Pumps the real [MapScreen] behind a router, with data and platform
/// providers replaced by in-memory fakes.
Future<void> _pumpMapScreen(WidgetTester tester) async {
  final router = GoRouter(
    routes: [GoRoute(path: '/', builder: (_, _) => const MapScreen())],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...getBaseTestOverrides(),
        // The real provider reads a Hive cache; serve fixtures directly.
        fridgeListProvider.overrideWith(
          (ref) async => FridgeFixtures.allFridges,
        ),
        userLocationStreamProvider.overrideWith((ref) => Stream.value(null)),
        followedFridgesProvider.overrideWith((ref) => Stream.value([])),
        appThemeModeProvider.overrideWithValue(AppThemeMode.light),
        cachedTileProviderProvider.overrideWith(
          (ref) async => CachedTileProvider(
            maxStale: const Duration(days: 30),
            store: MemCacheStore(),
          ),
        ),
        vectorTileStyleProvider.overrideWith((ref) async => _createStyle()),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  // Let the fridge list, tile provider and style futures resolve.
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Unmounts the screen and drains the tile layers' pending timers.
Future<void> _disposeMapScreen(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 5));
}

/// A build context below [FlutterMap], for reaching its controller/camera.
BuildContext _mapChildContext(WidgetTester tester) => tester.element(
  find
      .descendant(of: find.byType(FlutterMap), matching: find.byType(TileLayer))
      .first,
);

void main() {
  tearDown(() => dotenv.testLoad(fileInput: ''));

  group('MapScreen zoom limits — vector tiles (Protomaps)', () {
    setUp(() => dotenv.testLoad(fileInput: 'PROTOMAPS_API_KEY=test_key'));

    testWidgets('camera can zoom in to street level', (tester) async {
      await _pumpMapScreen(tester);

      final map = tester.widget<FlutterMap>(find.byType(FlutterMap));
      expect(map.options.maxZoom, _streetLevelZoom);
      await _disposeMapScreen(tester);
    });

    testWidgets('vector layer renders up to the camera maximum', (
      tester,
    ) async {
      await _pumpMapScreen(tester);

      final layer = tester.widget<VectorTileLayer>(
        find.byType(VectorTileLayer),
      );
      final map = tester.widget<FlutterMap>(find.byType(FlutterMap));
      // A lower layer maximum would blank the map before the camera stops.
      expect(layer.maximumZoom, map.options.maxZoom);
      await _disposeMapScreen(tester);
    });

    testWidgets('tile data is still requested no deeper than zoom 15', (
      tester,
    ) async {
      await _pumpMapScreen(tester);

      final layer = tester.widget<VectorTileLayer>(
        find.byType(VectorTileLayer),
      );
      expect(layer.tileProviders.get('protomaps').maximumZoom, 15);
      await _disposeMapScreen(tester);
    });

    testWidgets('moving to street level is not clamped', (tester) async {
      await _pumpMapScreen(tester);
      final context = _mapChildContext(tester);
      final controller = MapController.of(context);

      controller.move(controller.camera.center, _streetLevelZoom);
      await tester.pump();

      expect(controller.camera.zoom, _streetLevelZoom);
      await _disposeMapScreen(tester);
    });

    testWidgets('zoom is still clamped beyond street level', (tester) async {
      await _pumpMapScreen(tester);
      final context = _mapChildContext(tester);
      final controller = MapController.of(context);

      controller.move(controller.camera.center, 22);
      await tester.pump();

      expect(controller.camera.zoom, _streetLevelZoom);
      await _disposeMapScreen(tester);
    });
  });

  group('MapScreen zoom limits — raster fallback', () {
    setUp(() => dotenv.testLoad(fileInput: ''));

    testWidgets('camera can zoom in to street level', (tester) async {
      await _pumpMapScreen(tester);

      expect(find.byType(VectorTileLayer), findsNothing);
      final map = tester.widget<FlutterMap>(find.byType(FlutterMap));
      expect(map.options.maxZoom, _streetLevelZoom);
      await _disposeMapScreen(tester);
    });

    testWidgets('raster layer does not cut off below the camera maximum', (
      tester,
    ) async {
      await _pumpMapScreen(tester);

      final layer = tester.widget<TileLayer>(find.byType(TileLayer));
      expect(layer.maxZoom, greaterThanOrEqualTo(_streetLevelZoom));
      expect(layer.maxNativeZoom, greaterThanOrEqualTo(_streetLevelZoom));
      await _disposeMapScreen(tester);
    });

    testWidgets('moving to street level is not clamped', (tester) async {
      await _pumpMapScreen(tester);
      final context = _mapChildContext(tester);
      final controller = MapController.of(context);

      controller.move(controller.camera.center, _streetLevelZoom);
      await tester.pump();

      expect(controller.camera.zoom, _streetLevelZoom);
      await _disposeMapScreen(tester);
    });
  });
}

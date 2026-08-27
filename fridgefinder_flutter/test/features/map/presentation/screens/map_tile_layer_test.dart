import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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

/// Builds a minimal Consumer that uses the same .when() selection logic
/// as map_screen.dart, rendering Text indicators for each branch.
Widget _buildTileLayerSelector() {
  return MaterialApp(
    home: Scaffold(
      body: Consumer(
        builder: (context, ref, child) {
          final vectorStyleAsync = ref.watch(vectorTileStyleProvider);
          return vectorStyleAsync.when(
            data: (style) => const Text('vector_tile_layer'),
            loading: () => const Text('raster_fallback_loading'),
            error: (error, stack) => const Text('raster_fallback_error'),
          );
        },
      ),
    ),
  );
}

void main() {
  group('Map Tile Layer Selection', () {
    testWidgets(
      'selects VectorTileLayer when vectorTileStyleProvider resolves successfully',
      (tester) async {
        final mockStyle = _createMockStyle();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              vectorTileStyleProvider.overrideWith((ref) async => mockStyle),
            ],
            child: _buildTileLayerSelector(),
          ),
        );

        // Initially loading → shows raster fallback
        expect(find.text('raster_fallback_loading'), findsOneWidget);

        // Wait for async provider to resolve
        await tester.pumpAndSettle();

        // After resolution → shows vector tile layer
        expect(find.text('vector_tile_layer'), findsOneWidget);
      },
    );

    test(
      'AsyncValue.when() maps error to raster fallback (mirrors Consumer logic)',
      () {
        // Verify that the .when() branching used in map_screen.dart's Consumer
        // correctly selects the error branch for raster fallback.
        // The provider error state is tested in vector_tile_style_provider_test.dart.
        const AsyncValue<Style> errorState = AsyncValue.error(
          'Protomaps API key not configured',
          StackTrace.empty,
        );

        final result = errorState.when(
          data: (_) => 'vector_tile_layer',
          loading: () => 'raster_fallback_loading',
          error: (_, _) => 'raster_fallback_error',
        );

        expect(result, 'raster_fallback_error');
      },
    );

    testWidgets(
      'shows raster TileLayer while vectorTileStyleProvider is loading',
      (tester) async {
        // Use a Completer that won't resolve during initial pump
        final completer = Completer<Style>();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              vectorTileStyleProvider.overrideWith((ref) => completer.future),
            ],
            child: _buildTileLayerSelector(),
          ),
        );

        // Pump once to build - provider is still loading
        await tester.pump();

        // Should show raster fallback while loading
        expect(find.text('raster_fallback_loading'), findsOneWidget);
        expect(find.text('vector_tile_layer'), findsNothing);

        // Complete the future to clean up
        completer.complete(_createMockStyle());
        await tester.pumpAndSettle();
      },
    );
  });
}

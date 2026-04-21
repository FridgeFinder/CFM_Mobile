import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

import '../constants/map_tile_config.dart';
import '../utils/app_logger.dart';
import 'theme_provider.dart';

part 'vector_tile_style_provider.g.dart';

/// Provider that loads a bundled Protomaps v3 theme (compatible with
/// vector_tile_renderer v6) and wires it to the Protomaps hosted tile API.
/// Rebuilds when app theme changes (light/dark).
@riverpod
Future<Style> vectorTileStyle(Ref ref) async {
  final tileUrl = MapTileConfig.getProtomapsTileUrl();
  if (tileUrl == null) {
    throw Exception('Protomaps API key not configured');
  }

  final themeMode = ref.watch(appThemeModeProvider);
  final isDark = themeMode == AppThemeMode.dark;
  final flavor = isDark ? 'dark' : 'light';

  logger.i('Loading Protomaps $flavor theme from bundled assets');

  // Load bundled Protomaps v3 theme JSON (compatible with vector_tile_renderer)
  final jsonString =
      await rootBundle.loadString('assets/map_themes/protomaps_$flavor.json');
  final styleJson = json.decode(jsonString) as Map<String, dynamic>;

  // Build theme from the style JSON layers
  final theme = vtr.ThemeReader(
    logger: const vtr.Logger.console(),
  ).read(styleJson);

  logger.i('Tile URL: $tileUrl');
  logger.i(
    'Protomaps theme loaded: ${theme.layers.length} layers, '
    'tileSources: ${theme.tileSources}',
  );
  for (final layer in theme.layers) {
    logger.d('  Layer: ${layer.id} type=${layer.type}');
  }

  // Wire up the tile provider to the Protomaps hosted API
  final providers = TileProviders({
    'protomaps': NetworkVectorTileProvider(
      urlTemplate: tileUrl,
      maximumZoom: 15,
    ),
  });

  return Style(
    theme: theme,
    providers: providers,
  );
}

import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/app_logger.dart';

/// Sources for map tile providers, in order of preference
enum MapTileSource { protomaps, maptiler, openStreetMap }

/// Resolved tile configuration after evaluating available API keys
class ResolvedTileConfig {
  final MapTileSource source;
  final String tileUrl;
  final String? apiKey;

  const ResolvedTileConfig({
    required this.source,
    required this.tileUrl,
    this.apiKey,
  });
}

/// Map tile configuration with Protomaps vector tiles as primary,
/// MapTiler raster as secondary, and OpenStreetMap as final fallback.
class MapTileConfig {
  /// Get Protomaps API key from environment variables.
  /// Returns null if API key is not found, empty, or placeholder.
  static String? getProtomapsApiKey() {
    final apiKey = dotenv.env['PROTOMAPS_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_api_key_here') {
      logger.w('Protomaps API key not found or invalid in environment variables');
      return null;
    }
    return apiKey;
  }

  /// Build Protomaps MVT tile URL template.
  /// Returns null if API key is not available.
  static String? getProtomapsTileUrl() {
    final apiKey = getProtomapsApiKey();
    if (apiKey == null) return null;
    return 'https://api.protomaps.com/tiles/v4/{z}/{x}/{y}.mvt?key=$apiKey';
  }

  /// Build Protomaps style JSON URL for vector tile rendering.
  /// [flavor] should be 'light' or 'dark'.
  /// Returns null if API key is not available.
  static String? getProtomapsStyleUrl({required String flavor}) {
    final apiKey = getProtomapsApiKey();
    if (apiKey == null) return null;
    return 'https://api.protomaps.com/styles/v5/$flavor/en.json?key=$apiKey';
  }

  /// Get MapTiler API key from environment variables.
  /// Returns null if API key is not found, empty, or placeholder.
  static String? getMapTilerApiKey() {
    final apiKey = dotenv.env['MAPTILER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_api_key_here') {
      logger.w(
          'MapTiler API key not found or invalid in environment variables');
      return null;
    }
    return apiKey;
  }

  /// Build MapTiler Streets raster tile URL template.
  /// Returns null if API key is not available.
  static String? getMapTilerStreetsUrl() {
    final apiKey = getMapTilerApiKey();
    if (apiKey == null) return null;
    return 'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=$apiKey';
  }

  /// Fallback OpenStreetMap tile URL (no API key required)
  static const String openStreetMapUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Resolve the best available tile configuration.
  /// Priority: Protomaps → MapTiler → OpenStreetMap
  static ResolvedTileConfig resolve() {
    final protomapsKey = getProtomapsApiKey();
    if (protomapsKey != null) {
      return ResolvedTileConfig(
        source: MapTileSource.protomaps,
        tileUrl: getProtomapsTileUrl()!,
        apiKey: protomapsKey,
      );
    }

    final maptilerKey = getMapTilerApiKey();
    if (maptilerKey != null) {
      return ResolvedTileConfig(
        source: MapTileSource.maptiler,
        tileUrl: getMapTilerStreetsUrl()!,
        apiKey: maptilerKey,
      );
    }

    return const ResolvedTileConfig(
      source: MapTileSource.openStreetMap,
      tileUrl: openStreetMapUrl,
    );
  }
}

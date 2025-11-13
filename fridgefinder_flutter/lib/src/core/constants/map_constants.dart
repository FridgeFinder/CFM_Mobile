import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/app_logger.dart';

/// Map configuration constants for MapTiler tiles
class MapConstants {
  /// Get MapTiler API key from environment variables
  /// Returns null if API key is not found or empty
  static String? getMapTilerApiKey() {
    final apiKey = dotenv.env['MAPTILER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_api_key_here') {
      logger.w('MapTiler API key not found or invalid in environment variables');
      return null;
    }
    return apiKey;
  }

  /// Build MapTiler Streets tile URL template
  /// Returns the URL template with API key if available, null otherwise
  /// Format: https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key={apiKey}
  static String? getMapTilerStreetsUrl() {
    final apiKey = getMapTilerApiKey();
    if (apiKey == null) {
      return null;
    }
    return 'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=$apiKey';
  }

  /// Fallback OpenStreetMap tile URL (used when MapTiler API key is not available)
  static const String openStreetMapUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
}


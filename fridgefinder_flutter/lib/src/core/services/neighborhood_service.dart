import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/app_logger.dart';

/// Resolves fridge lat/lng to neighborhood labels via MapTiler reverse geocoding.
///
/// Fallback chain: Hive cache → MapTiler API → locationName → city
class NeighborhoodService {
  static const String _boxName = 'neighborhood_cache_v2';

  final Dio _dio;
  final String? _apiKeyOverride;

  NeighborhoodService({Dio? dio, String? apiKey})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
            )),
        _apiKeyOverride = apiKey;

  /// Returns a neighborhood label for the given fridge.
  ///
  /// Tries Hive cache first, then MapTiler API, then falls back to
  /// [locationName] or [city].
  Future<String> getNeighborhood({
    required String fridgeId,
    required double lat,
    required double lng,
    String? locationName,
    String city = '',
  }) async {
    // 1. Check cache
    final cached = await _readCache(fridgeId);
    if (cached != null) return cached;

    // 2. Try MapTiler API
    final geocoded = await _reverseGeocode(lat, lng);
    if (geocoded != null) {
      await _writeCache(fridgeId, geocoded);
      return geocoded;
    }

    // 3. Fallback to locationName or city
    final fallback = locationName ?? city;
    if (fallback.isNotEmpty) {
      await _writeCache(fridgeId, fallback);
    }
    return fallback;
  }

  Future<String?> _readCache(String fridgeId) async {
    try {
      final box = await Hive.openBox<String>(_boxName);
      return box.get(fridgeId);
    } catch (e) {
      logger.w('Neighborhood cache read failed: $e');
      return null;
    }
  }

  Future<void> _writeCache(String fridgeId, String value) async {
    try {
      final box = await Hive.openBox<String>(_boxName);
      await box.put(fridgeId, value);
    } catch (e) {
      logger.w('Neighborhood cache write failed: $e');
    }
  }

  /// Place types in preference order — most specific first.
  static const _preferredTypes = [
    'neighbourhood',
    'municipal_district',
    'joint_submunicipality',
    'place',
    'joint_municipality',
    'locality',
    'municipality',
  ];

  Future<String?> _reverseGeocode(double lat, double lng) async {
    try {
      final apiKey = _apiKeyOverride ?? dotenv.env['MAPTILER_API_KEY'];
      if (apiKey == null || apiKey.isEmpty || apiKey == 'your_api_key_here') {
        logger.w('MapTiler API key not available for reverse geocoding');
        return null;
      }

      final response = await _dio.get<Map<String, dynamic>>(
        'https://api.maptiler.com/geocoding/$lng,$lat.json',
        queryParameters: {'key': apiKey},
      );

      final features = response.data?['features'] as List<dynamic>?;
      if (features == null || features.isEmpty) return null;

      // Pick the most specific feature by preferred place type
      for (final type in _preferredTypes) {
        for (final feature in features) {
          final placeType = feature['place_type'] as List<dynamic>?;
          if (placeType != null && placeType.contains(type)) {
            return feature['text'] as String?;
          }
        }
      }

      // If no preferred type matched, return the first feature
      return features[0]['text'] as String?;
    } catch (e) {
      logger.w('MapTiler reverse geocoding failed: $e');
      return null;
    }
  }
}

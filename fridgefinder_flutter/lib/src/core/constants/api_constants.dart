/// API configuration constants
class ApiConstants {
  /// Development environment base URL
  static const String devUrl = 'https://api-dev.communityfridgefinder.com/v1';

  /// Production environment base URL
  static const String prodUrl = 'https://api-prod.communityfridgefinder.com/v1';

  /// Whether we're in development mode
  static const bool isDevelopment = true;

  /// API endpoints - Real FridgeFinder API endpoints
  static const String fridgesEndpoint = '/fridges';
  static const String fridgeDetailsEndpoint = '/fridges/{fridgeId}';
  static const String fridgeReportsEndpoint = '/fridges/{fridgeId}/reports';
  static const String photoUploadEndpoint = '/photo';

  /// HTTP timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);
}

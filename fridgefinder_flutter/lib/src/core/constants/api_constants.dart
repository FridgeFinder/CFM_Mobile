/// API configuration constants for Community Fridge Finder API
///
/// Note: This only applies to fridge data endpoints.
/// Firebase services (Auth, Messaging, Database, Functions) always use PRODUCTION.
/// See ENVIRONMENT_CONFIGURATION.md for details.
class ApiConstants {
  /// Development environment base URL for fridge data
  static const String devUrl = 'https://api-dev.communityfridgefinder.com/v1';

  /// Production environment base URL for fridge data
  static const String prodUrl = 'https://api-prod.communityfridgefinder.com/v1';

  /// API endpoints - Community Fridge Finder API
  static const String fridgesEndpoint = '/fridges';
  static const String fridgeDetailsEndpoint = '/fridges/{fridgeId}';
  static const String fridgeReportsEndpoint = '/fridges/{fridgeId}/reports';
  static const String photoUploadEndpoint = '/photo';

  /// HTTP timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);
}

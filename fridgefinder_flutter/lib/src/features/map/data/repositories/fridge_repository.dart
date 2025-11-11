import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../map/domain/models/fridge_domain.dart';
import '../../../map/domain/repositories/i_fridge_repository.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/utils/app_logger.dart';

part 'fridge_repository.g.dart';

/// Repository for fetching fridge data from real FridgeFinder API
/// Handles API communication and error handling
class FridgeRepository implements IFridgeRepository {
  final Dio _dio;

  FridgeRepository(this._dio);

  /// Fetch all fridges from the API
  /// Throws [NetworkException] on network errors
  /// Throws [ServerException] on server errors
  /// Based on real API: GET /v1/fridges
  /// Filters out ghost fridges from the response
  @override
  Future<List<FridgeDomain>> getFridges() async {
    try {
      final response = await _dio.get('/fridges');

      if (response.statusCode != 200) {
        throw ServerException(
          'Failed to fetch fridges: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      // Real API returns array directly, not wrapped in object
      final List<dynamic> data = response.data is List ? response.data : [];

      return data
          .map((json) => FridgeDomain.fromJson(json as Map<String, dynamic>))
          // Filter out ghost fridges from the initial response
          .where(
            (fridge) =>
                fridge.latestFridgeReport?.condition != FridgeCondition.ghost,
          )
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppException('Failed to fetch fridges: $e');
    }
  }

  /// Fetch a single fridge by ID
  /// Throws [NotFoundException] if fridge not found
  /// Throws [NetworkException] on network errors
  /// Based on real API: GET /v1/fridges/{fridgeId}
  @override
  Future<FridgeDomain> getFridge(String fridgeId) async {
    try {
      final response = await _dio.get('/fridges/$fridgeId');

      if (response.statusCode == 404) {
        throw NotFoundException('Fridge with ID $fridgeId not found');
      }

      if (response.statusCode != 200) {
        throw ServerException(
          'Failed to fetch fridge: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      // Real API returns fridge object directly
      return FridgeDomain.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppException('Failed to fetch fridge: $e');
    }
  }

  /// Submit a condition report for a fridge
  /// Throws [NetworkException] on network errors
  /// Based on real API: POST /v1/fridges/{fridgeId}/reports
  /// foodPercentage is in 0-1 range and will be converted to 0-3 API format
  /// If photoBytes is provided, uploads photo to /photo endpoint first, then includes URL in report
  /// Also writes to Realtime Database to trigger Cloud Functions
  @override
  Future<void> submitFridgeReport(
    String fridgeId,
    FridgeCondition condition,
    double foodPercentage,
    String? notes,
    List<int>? photoBytes,
  ) async {
    try {
      // Convert foodPercentage from 0-1 range to 0-3 integer for API
      final int foodLevel;
      if (foodPercentage >= 0.75) {
        foodLevel = 3; // Full
      } else if (foodPercentage >= 0.5) {
        foodLevel = 2; // Many items
      } else if (foodPercentage > 0) {
        foodLevel = 1; // Few items
      } else {
        foodLevel = 0; // Empty
      }

      // Upload photo first if provided, then use the returned URL in the report
      String? photoUrl;
      if (photoBytes != null && photoBytes.isNotEmpty) {
        // Upload to /photo endpoint (converts to WebP and sends raw bytes)
        // The uploadPhoto method handles WebP conversion
        final mimeType = 'image/jpeg'; // Original format, uploadPhoto will convert to WebP
        photoUrl = await uploadPhoto(photoBytes, mimeType);
        logger.d('Photo uploaded successfully, URL: $photoUrl');
      }

      final response = await _dio.post(
        '/fridges/$fridgeId/reports',
        data: {
          'condition': condition.value,
          'foodPercentage': foodLevel,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
          if (photoUrl != null && photoUrl.isNotEmpty) 'photoUrl': photoUrl,
        },
      );

      if (response.statusCode == null || response.statusCode! >= 400) {
        throw ServerException(
          'Failed to submit report: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      // Write to Realtime Database to trigger Cloud Functions
      // Include fridge name for better notifications
      FridgeDomain? fridge;
      try {
        fridge = await getFridge(fridgeId);
      } catch (e) {
        // If we can't get fridge, continue without name
        logger.w('Could not fetch fridge name for notification: $e');
      }

      await _writeStatusReportToDatabase(
        fridgeId: fridgeId,
        condition: condition.value,
        foodPercentage: foodPercentage,
        notes: notes,
        photoUrl: photoUrl,
        fridgeName: fridge?.name,
      );

      logger.i(
        'Status report submitted and written to database for fridge $fridgeId',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppException('Failed to submit fridge report: $e');
    }
  }

  /// Write status report to Realtime Database for Cloud Functions triggers
  Future<void> _writeStatusReportToDatabase({
    required String fridgeId,
    required String condition,
    required double foodPercentage,
    String? notes,
    String? photoUrl,
    String? fridgeName,
  }) async {
    try {
      final database = DatabaseProvider.databaseRef;
      final reportRef = database.child('statusReports').push();

      final reportData = {
        'fridgeId': fridgeId,
        'fridgeName': fridgeName, // Include fridge name for notifications
        'condition': condition,
        'foodPercentage': foodPercentage,
        'notes': notes,
        'photoUrl': photoUrl,
        'reportDate': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      await reportRef.set(reportData);
      logger.d('Status report written to Realtime Database');
    } catch (e) {
      // Don't throw - this is supplementary to the API call
      logger.w('Failed to write status report to database: $e');
    }
  }

  /// Upload a fridge photo
  /// Throws [NetworkException] on network errors
  /// Based on real API: POST /v1/photo
  /// Converts image to WebP and sends raw bytes with Content-Type: image/webp
  /// Desktop sends @FILE_LOCATION (file path via curl), mobile sends raw WebP bytes
  /// Returns the photo URL from the API response
  @override
  Future<String> uploadPhoto(List<int> imageBytes, String mimeType) async {
    try {
      // Convert image to WebP format first (required by backend)
      final webpBytes = await FlutterImageCompress.compressWithList(
        Uint8List.fromList(imageBytes),
        format: CompressFormat.webp,
        quality: 85,
      );

      if (webpBytes.isEmpty) {
        throw AppException('Failed to convert image to WebP');
      }

      logger.d('Converted image to WebP (${webpBytes.length} bytes), sending raw bytes');

      // Send raw WebP bytes directly (like curl --data '@FILE_LOCATION')
      // Backend expects: Content-Type: image/webp with raw file bytes as body
      final response = await _dio.post(
        '/photo',
        data: webpBytes, // Send raw WebP bytes, not base64
        options: Options(
          headers: {
            'Content-Type': 'image/webp',
          },
        ),
      );

      if (response.statusCode != 200) {
        final errorData = response.data;
        logger.e('Photo upload failed with status ${response.statusCode}');
        logger.e('Response data: $errorData');
        logger.e('Response data type: ${errorData.runtimeType}');
        throw ServerException(
          'Failed to upload photo: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      // Parse response to extract photo URL
      // API returns {'url': '...'} or {'photoUrl': '...'} or direct string
      if (response.data is String) {
        final url = response.data as String;
        if (url.isEmpty) {
          throw AppException('Photo upload succeeded but no URL returned');
        }
        logger.d('Photo upload successful, URL: $url');
        return url;
      } else if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final url = data['url'] as String? ?? data['photoUrl'] as String?;
        if (url == null || url.isEmpty) {
          logger.e('Photo upload response: ${response.data}');
          throw AppException('Photo upload succeeded but no URL in response');
        }
        logger.d('Photo upload successful, URL: $url');
        return url;
      }
      logger.e('Unexpected photo upload response format: ${response.data}');
      throw AppException('Unexpected response format from photo upload');
    } on DioException catch (e) {
      // Log the actual error response from the backend
      if (e.response != null) {
        logger.e('Photo upload DioException: Status ${e.response?.statusCode}, Data: ${e.response?.data}');
      } else {
        logger.e('Photo upload DioException: ${e.message}');
      }
      throw _handleDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      logger.e('Photo upload error: $e');
      throw AppException('Failed to upload photo: $e');
    }
  }

  /// Handle Dio exceptions and convert to app exceptions
  AppException _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException(
        'Connection timeout. Please check your internet connection.',
        originalError: e,
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return NetworkException(
        'Unable to connect to server. Please check your internet connection.',
        originalError: e,
      );
    }

    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;

    // Try to extract error message from API response
    String? apiErrorMessage;
    if (responseData != null) {
      try {
        if (responseData is Map<String, dynamic>) {
          // Common error message fields in API responses
          apiErrorMessage =
              responseData['message'] as String? ??
              responseData['error'] as String? ??
              responseData['errorMessage'] as String? ??
              responseData['msg'] as String?;
        } else if (responseData is String) {
          apiErrorMessage = responseData;
        }
      } catch (_) {
        // If parsing fails, use generic message
      }
    }

    if (statusCode != null) {
      if (statusCode >= 500) {
        return ServerException(
          apiErrorMessage ?? 'Server error occurred. Please try again later.',
          statusCode: statusCode,
          originalError: e,
        );
      }
      if (statusCode == 404) {
        return NotFoundException(
          apiErrorMessage ?? 'Resource not found.',
          originalError: e,
        );
      }
      if (statusCode == 401 || statusCode == 403) {
        return AuthException(
          apiErrorMessage ?? 'Authentication failed. Please log in again.',
          originalError: e,
        );
      }
      // Handle 4xx client errors (400, 422, etc.) with API error message
      if (statusCode >= 400 && statusCode < 500) {
        return ServerException(
          apiErrorMessage ??
              'Request failed. Please check your input and try again.',
          statusCode: statusCode,
          originalError: e,
        );
      }
    }

    return NetworkException(
      apiErrorMessage ?? 'Network error occurred. Please try again.',
      originalError: e,
    );
  }
}

/// Riverpod provider for FridgeRepository
@riverpod
FridgeRepository fridgeRepository(Ref ref) {
  return FridgeRepository(ref.watch(dioProvider));
}

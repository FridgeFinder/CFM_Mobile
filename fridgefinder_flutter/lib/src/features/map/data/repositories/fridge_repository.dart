import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../map/domain/models/fridge_domain.dart';
import '../../../map/domain/repositories/i_fridge_repository.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../../core/utils/app_logger.dart';

part 'fridge_repository.g.dart';

/// Repository for fetching fridge data from real FridgeFinder API
/// Handles API communication and error handling
class FridgeRepository implements IFridgeRepository {
  final Dio _dio;
  final Dio _usersDio;

  FridgeRepository(this._dio, this._usersDio);

  /// Fetch all fridges from the API
  /// Throws [NetworkException] on network errors
  /// Throws [ServerException] on server errors
  /// Based on current API: GET /fridges
  /// Filters out ghost fridges from the response
  @override
  Future<List<FridgeDomain>> getFridges({bool includeGhosts = false}) async {
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

      var fridges = data
          .map((json) => FridgeDomain.fromJson(json as Map<String, dynamic>));

      // Filter out ghost fridges unless explicitly included
      if (!includeGhosts) {
        fridges = fridges.where(
          (fridge) =>
              fridge.latestFridgeReport?.condition != FridgeCondition.ghost,
        );
      }

      return fridges.toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppException('Failed to fetch fridges: $e');
    }
  }

  /// Fetch a single fridge by ID
  /// Throws [NotFoundException] if fridge not found
  /// Throws [NetworkException] on network errors
  /// Based on current API: GET /fridges/{fridgeId}
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
  /// Based on current API: POST /fridges/{fridgeId}/reports
  /// foodPercentage is in 0-1 range and will be converted to 0-3 API format
  /// If photoBytes is provided, uploads photo to /photo endpoint first, then includes URL in report
  /// Includes authenticated userId when available
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

      final currentUserId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
        final userIdPayload = currentUserId == null
          ? null
          : <String, dynamic>{'userId': currentUserId};

      final response = await _dio.post(
        '/fridges/$fridgeId/reports',
        data: {
          'condition': condition.value,
          'foodPercentage': foodLevel,
          ...?userIdPayload,
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

      if (currentUserId != null) {
        // Best-effort role transition after the report succeeds.
        // This is intentionally async and must never block report UX.
        unawaited(_promoteNeighborToVolunteer(currentUserId));
      }

      logger.i('Status report submitted for fridge $fridgeId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppException('Failed to submit fridge report: $e');
    }
  }

  /// Upload a fridge photo
  /// Throws [NetworkException] on network errors
  /// Based on current API: POST /photo
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

  Future<void> _promoteNeighborToVolunteer(String userId) async {
    try {
      final userResponse = await _usersDio.get('/users/$userId');
      final userPayload = _extractUserPayload(userResponse.data);
      if (userPayload == null) {
        logger.w(
          'Could not evaluate userType for volunteer promotion: no user payload for $userId',
        );
        return;
      }

      final currentUserType = userPayload['userType']?.toString().trim().toLowerCase();
      if (currentUserType != 'neighbor') {
        return;
      }

      await _usersDio.patch('/users/$userId', data: {'userType': 'Volunteer'});
      logger.i('Promoted user $userId from neighbor to Volunteer.');
    } on DioException catch (e) {
      logger.w(
        'Failed to promote user $userId to volunteer: ${e.response?.statusCode} ${e.message}',
      );
    } catch (e) {
      logger.w('Failed to promote user $userId to volunteer: $e');
    }
  }

  Map<String, dynamic>? _extractUserPayload(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return null;
    }

    if (data['user'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data['user'] as Map<String, dynamic>);
    }

    if (data['data'] is Map<String, dynamic>) {
      final nested = data['data'] as Map<String, dynamic>;
      if (nested['user'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(nested['user'] as Map<String, dynamic>);
      }
      if (nested.containsKey('userId')) {
        return Map<String, dynamic>.from(nested);
      }
    }

    if (data.containsKey('userId')) {
      return Map<String, dynamic>.from(data);
    }

    return null;
  }
}

/// Riverpod provider for FridgeRepository
@riverpod
FridgeRepository fridgeRepository(Ref ref) {
  return FridgeRepository(ref.watch(dioProvider), ref.watch(userDioProvider));
}

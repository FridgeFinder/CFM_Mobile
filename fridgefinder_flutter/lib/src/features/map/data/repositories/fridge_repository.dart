import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../map/domain/models/fridge_domain.dart';
import '../../../map/domain/repositories/i_fridge_repository.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/providers/dio_provider.dart';

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
  @override
  Future<void> submitFridgeReport(
    String fridgeId,
    FridgeCondition condition,
    double foodPercentage,
    String? notes,
  ) async {
    try {
      final response = await _dio.post(
        '/fridges/$fridgeId/reports',
        data: {
          'condition': condition.value,
          'foodPercentage': foodPercentage,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == null || response.statusCode! >= 400) {
        throw ServerException(
          'Failed to submit report: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppException('Failed to submit fridge report: $e');
    }
  }

  /// Upload a fridge photo
  /// Throws [NetworkException] on network errors
  /// Based on real API: POST /v1/photo
  @override
  Future<String> uploadPhoto(List<int> imageBytes, String mimeType) async {
    try {
      final response = await _dio.post(
        '/photo',
        data: Stream.fromIterable(imageBytes.map((e) => [e])),
        options: Options(
          contentType: mimeType,
          headers: {'Content-Type': mimeType},
        ),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          'Failed to upload photo: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      // Parse response to extract photo URL
      // Could be {'url': '...'} or {'photoUrl': '...'} or direct string
      if (response.data is String) {
        return response.data as String;
      } else if (response.data is Map) {
        return response.data['url'] ?? response.data['photoUrl'] ?? '';
      }
      return '';
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
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
    if (statusCode != null) {
      if (statusCode >= 500) {
        return ServerException(
          'Server error occurred. Please try again later.',
          statusCode: statusCode,
          originalError: e,
        );
      }
      if (statusCode == 404) {
        return NotFoundException('Resource not found.', originalError: e);
      }
      if (statusCode == 401 || statusCode == 403) {
        return AuthException(
          'Authentication failed. Please log in again.',
          originalError: e,
        );
      }
    }

    return NetworkException(
      'Network error occurred. Please try again.',
      originalError: e,
    );
  }
}

/// Riverpod provider for FridgeRepository
@riverpod
FridgeRepository fridgeRepository(Ref ref) {
  return FridgeRepository(ref.watch(dioProvider));
}

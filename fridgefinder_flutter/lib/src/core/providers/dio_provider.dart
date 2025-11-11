import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/api_constants.dart';
import '../utils/app_logger.dart';
import 'environment_provider.dart';

part 'dio_provider.g.dart';

/// Riverpod provider for Dio HTTP client with proper configuration
/// Uses dynamic base URL from environment provider
@riverpod
Dio dio(Ref ref) {
  final baseUrl = ref.watch(apiBaseUrlProvider);

  final dioInstance = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add connectivity check interceptor (runs before every request)
  dioInstance.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Check internet connectivity before making request
        final connectivityResult = await Connectivity().checkConnectivity();

        // Check if there's no connectivity
        if (connectivityResult == ConnectivityResult.none) {
          logger.w(
            'No internet connection - Request blocked: ${options.method} ${options.path}',
          );
          return handler.reject(
            DioException(
              requestOptions: options,
              error:
                  'No internet connection. Please check your network settings.',
              type: DioExceptionType.connectionError,
            ),
          );
        }

        // Only log data if it's a Map (JSON), not Stream or FormData (file uploads)
        Map<String, dynamic>? dataToLog;
        if (options.data is Map<String, dynamic>) {
          dataToLog = options.data as Map<String, dynamic>;
        } else if (options.data is FormData) {
          dataToLog = {
            '_type': 'FormData',
            '_fields': (options.data as FormData).fields.length,
          };
        } else if (options.data != null) {
          // Handle Stream, List<int>, or other binary data types
          dataToLog = {'_type': 'Binary data'};
        }
        
        logger.apiRequest(
          options.method,
          '${options.baseUrl}${options.path}',
          data: dataToLog,
        );

        return handler.next(options);
      },
      onResponse: (response, handler) {
        logger.apiResponse(
          response.requestOptions.path,
          response.statusCode ?? 0,
          data: response.data,
        );
        return handler.next(response);
      },
      onError: (error, handler) {
        logger.e(
          'API Error: ${error.message}',
          error: error,
          stackTrace: error.stackTrace,
        );
        return handler.next(error);
      },
    ),
  );

  // Add Dio's built-in logging interceptor in debug mode for detailed logs
  if (kDebugMode) {
    dioInstance.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: true,
        responseHeader: true,
        logPrint: (obj) => logger.d(obj), // Use our logger instead of print
      ),
    );
  }

  return dioInstance;
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
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
  return _buildDio(ref.watch(apiBaseUrlProvider));
}

/// Riverpod provider for Users API Dio client
@riverpod
Dio userDio(Ref ref) {
  return _buildDio(ref.watch(usersApiBaseUrlProvider));
}

/// Riverpod provider for Notifications API Dio client
@riverpod
Dio notificationsDio(Ref ref) {
  return _buildDio(ref.watch(notificationsApiBaseUrlProvider));
}

/// Riverpod provider for User Rewards API Dio client
@riverpod
Dio rewardsDio(Ref ref) {
  return _buildDio(ref.watch(rewardsApiBaseUrlProvider));
}

Dio _buildDio(String baseUrl) {
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
        // Attach Firebase JWT when available.
        final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          try {
            final token = await currentUser.getIdToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
              logger.d(
                'Attached Firebase ID token for uid ${currentUser.uid} '
                'to ${options.baseUrl}${options.path}',
              );
            } else {
              logger.w(
                'Firebase ID token was empty for uid ${currentUser.uid} '
                'on ${options.baseUrl}${options.path}',
              );
            }
          } catch (e) {
            logger.w('Could not attach auth token: $e');
          }
        } else {
          logger.w(
            'No Firebase user available when calling '
            '${options.baseUrl}${options.path}',
          );
        }

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
      onError: (error, handler) async {
        logger.e(
          'API Error: ${error.message}',
          error: error,
          stackTrace: error.stackTrace,
        );

        final statusCode = error.response?.statusCode;
        final requestOptions = error.requestOptions;
        final shouldRetry = (statusCode == 401 || statusCode == 403) &&
            requestOptions.extra['retry'] != true;

        if (shouldRetry) {
          final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            try {
              final refreshedToken = await currentUser.getIdToken(true);
              if (refreshedToken != null && refreshedToken.isNotEmpty) {
                requestOptions.headers['Authorization'] = 'Bearer $refreshedToken';
                requestOptions.extra['retry'] = true;
                logger.i(
                  'Retrying request after auth refresh for '
                  '${requestOptions.baseUrl}${requestOptions.path}',
                );
                final retryResponse = await dioInstance.fetch(requestOptions);
                return handler.resolve(retryResponse);
              }
            } catch (e) {
              logger.w('Failed to refresh auth token for retry: $e');
            }
          }
        }

        return handler.next(error);
      },
    ),
  );

  // Add Dio's built-in logging interceptor in debug mode for detailed logs
  if (kDebugMode) {
    dioInstance.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        error: true,
        requestHeader: false,
        responseHeader: false,
        logPrint: (obj) => logger.d(obj), // Use our logger instead of print
      ),
    );
  }

  return dioInstance;
}

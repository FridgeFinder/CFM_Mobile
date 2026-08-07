import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../domain/models/subscription_preferences.dart';

part 'notifications_repository.g.dart';

class NotificationsRepository {
  NotificationsRepository(this._dio);

  final Dio _dio;

  Future<List<SubscriptionPreferences>> getAllForUser(String userId) async {
    try {
      final response = await _dio.get('/users/$userId/fridge-notifications');
      final notifications = _extractNotificationsList(response.data);

      return notifications
          .whereType<Map<String, dynamic>>()
          .map(_fromApi)
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to load fridge notifications');
    }
  }

  Future<SubscriptionPreferences?> getForFridge({
    required String userId,
    required String fridgeId,
  }) async {
    try {
      final response = await _dio.get('/users/$userId/fridge-notifications/$fridgeId');
      final data = _extractSingleNotification(response.data);
      if (data == null) return null;
      return _fromApi(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw _handleDioError(e, 'Failed to load fridge notification');
    }
  }

  Future<SubscriptionPreferences> followFridge({
    required String userId,
    required String fridgeId,
    required NotificationPreferences preferences,
  }) async {
    try {
      final response = await _dio.post(
        '/users/$userId/fridge-notifications/$fridgeId',
        data: _toApiInput(preferences),
      );
      final data = _extractSingleNotification(response.data);
      if (data == null) {
        throw ServerException('Unexpected response creating fridge notification');
      }
      return _fromApi(data);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to follow fridge');
    }
  }

  Future<SubscriptionPreferences> updatePreferences({
    required String userId,
    required String fridgeId,
    required NotificationPreferences preferences,
  }) async {
    try {
      final response = await _dio.patch(
        '/users/$userId/fridge-notifications/$fridgeId',
        data: _toApiInput(preferences),
      );
      final data = _extractSingleNotification(response.data);
      if (data == null) {
        throw ServerException('Unexpected response updating fridge notification');
      }
      return _fromApi(data);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to update fridge notification preferences');
    }
  }

  Future<void> unfollowFridge({
    required String userId,
    required String fridgeId,
  }) async {
    try {
      await _dio.delete('/users/$userId/fridge-notifications/$fridgeId');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to unfollow fridge');
    }
  }

  SubscriptionPreferences _fromApi(Map<String, dynamic> json) {
    final contactType = json['contactTypePreferences'];
    final preferences = NotificationPreferences(
      contactTypePreferences: _parseContactTypePreferences(
        contactType is Map<String, dynamic> ? contactType : const <String, dynamic>{},
      ),
    );

    return SubscriptionPreferences(
      fridgeId: (json['fridgeId'] as String?) ?? '',
      subscribedAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse((json['updatedAt'] as String?) ?? ''),
      notificationPreferences: preferences,
    );
  }

  ContactTypePreferences _parseContactTypePreferences(Map<String, dynamic> json) {
    return ContactTypePreferences(
      email: _parseFlags(json['email']),
      device: _parseFlags(json['device']),
    );
  }

  FridgeNotificationFlags _parseFlags(Object? value) {
    final json = value is Map<String, dynamic> ? value : const <String, dynamic>{};

    return FridgeNotificationFlags(
      good: (json['good'] as bool?) ?? true,
      dirty: (json['dirty'] as bool?) ?? false,
      outOfOrder: (json['outOfOrder'] as bool?) ?? false,
      notAtLocation: (json['notAtLocation'] as bool?) ?? true,
      ghost: (json['ghost'] as bool?) ?? true,
      noFood: (json['noFood'] as bool?) ?? false,
      hasFood: (json['hasFood'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> _toApiInput(NotificationPreferences preferences) {
    return {
      'contactTypePreferences': {
        'email': _flagsToJson(preferences.contactTypePreferences.email),
        'device': _flagsToJson(preferences.contactTypePreferences.device),
      },
    };
  }

  Map<String, dynamic> _flagsToJson(FridgeNotificationFlags flags) {
    return {
      'dirty': flags.dirty,
      'outOfOrder': flags.outOfOrder,
      'noFood': flags.noFood,
      'hasFood': flags.hasFood,
    };
  }

  AppException _handleDioError(DioException e, String defaultMessage) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;

    String? apiMessage;
    if (responseData is Map<String, dynamic>) {
      final errorObj = responseData['error'];
      if (errorObj is Map<String, dynamic>) {
        apiMessage = errorObj['message'] as String?;
      }
      apiMessage ??= responseData['message'] as String?;
    } else if (responseData is String) {
      apiMessage = responseData;
    }

    if (statusCode == 401 || statusCode == 403) {
      return AuthException(apiMessage ?? defaultMessage, originalError: e);
    }

    if (statusCode == 404) {
      return NotFoundException(apiMessage ?? defaultMessage, originalError: e);
    }

    if (statusCode == 409) {
      return ServerException(
        apiMessage ?? defaultMessage,
        statusCode: statusCode,
        originalError: e,
      );
    }

    if (statusCode != null && statusCode >= 400 && statusCode < 500) {
      return ServerException(
        apiMessage ?? defaultMessage,
        statusCode: statusCode,
        originalError: e,
      );
    }

    return NetworkException(apiMessage ?? defaultMessage, originalError: e);
  }

  List<dynamic> _extractNotificationsList(dynamic data) {
    if (data is List) return data;
    if (data is! Map<String, dynamic>) return const <dynamic>[];

    if (data['notifications'] is List) return data['notifications'] as List;
    if (data['fridgeNotifications'] is List) {
      return data['fridgeNotifications'] as List;
    }

    if (data['data'] is List) return data['data'] as List;
    if (data['data'] is Map<String, dynamic>) {
      final nested = data['data'] as Map<String, dynamic>;
      if (nested['notifications'] is List) return nested['notifications'] as List;
      if (nested['fridgeNotifications'] is List) {
        return nested['fridgeNotifications'] as List;
      }
    }

    return const <dynamic>[];
  }

  Map<String, dynamic>? _extractSingleNotification(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    if (_looksLikeNotification(data)) return data;

    if (data['notification'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data['notification'] as Map<String, dynamic>);
    }
    if (data['fridgeNotification'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(
        data['fridgeNotification'] as Map<String, dynamic>,
      );
    }
    if (data['data'] is Map<String, dynamic>) {
      final nested = data['data'] as Map<String, dynamic>;
      if (_looksLikeNotification(nested)) return Map<String, dynamic>.from(nested);
      if (nested['notification'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(
          nested['notification'] as Map<String, dynamic>,
        );
      }
      if (nested['fridgeNotification'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(
          nested['fridgeNotification'] as Map<String, dynamic>,
        );
      }
    }

    return null;
  }

  bool _looksLikeNotification(Map<String, dynamic> json) {
    return json.containsKey('fridgeId') || json.containsKey('contactTypePreferences');
  }
}

@riverpod
NotificationsRepository notificationsRepository(Ref ref) {
  return NotificationsRepository(ref.watch(notificationsDioProvider));
}

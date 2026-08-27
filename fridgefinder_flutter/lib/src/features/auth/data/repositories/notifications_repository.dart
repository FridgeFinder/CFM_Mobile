import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../domain/models/fridge_notification_preferences.dart';

part 'notifications_repository.g.dart';

class NotificationsRepository {
  NotificationsRepository(this._dio);

  final Dio _dio;

  Future<List<FridgeNotificationPreferences>> getAllForUser(String userId) async {
    try {
      final response = await _dio.get('/users/$userId/fridge-notifications');
      final notifications = _extractNotificationsList(response.data);

      return notifications
          .whereType<Map<String, dynamic>>()
          .map(_fromApi)
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const <FridgeNotificationPreferences>[];
      }
      throw _handleDioError(e, 'Failed to load fridge notifications');
    }
  }

  Future<FridgeNotificationPreferences?> getForFridge({
    required String userId,
    required String fridgeId,
  }) async {
    try {
      final response = await _dio.get(
        '/users/$userId/fridge-notifications/$fridgeId',
      );
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

  Future<FridgeNotificationPreferences> followFridge({
    required String userId,
    required String fridgeId,
    required NotificationPreferences preferences,
  }) async {
    try {
      final payload = _toApiInput(preferences);
      final response = await _dio.post(
        '/users/$userId/fridge-notifications/$fridgeId',
        data: payload,
      );
      final data = _extractSingleNotification(response.data);
      if (data == null) {
        return FridgeNotificationPreferences(
          fridgeId: fridgeId,
          notificationPreferences: preferences,
        );
      }
      return _fromApi(data);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to follow fridge');
    }
  }

  Future<FridgeNotificationPreferences> updatePreferences({
    required String userId,
    required String fridgeId,
    required NotificationPreferences preferences,
  }) async {
    try {
      final payload = _toApiInput(preferences);
      final response = await _dio.patch(
        '/users/$userId/fridge-notifications/$fridgeId',
        data: payload,
      );
      final data = _extractSingleNotification(response.data);
      if (data == null) {
        return FridgeNotificationPreferences(
          fridgeId: fridgeId,
          notificationPreferences: preferences,
        );
      }
      return _fromApi(data);
    } on DioException catch (e) {
      throw _handleDioError(
        e,
        'Failed to update fridge notification preferences',
      );
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

  FridgeNotificationPreferences _fromApi(Map<String, dynamic> json) {
    final preferences = NotificationPreferences(
      contactTypePreferences: _parseContactTypePreferences(
        _extractPreferencesPayload(json),
      ),
    );

    return FridgeNotificationPreferences(
      fridgeId: _extractFridgeId(json),
      updatedAt: _parseDateTime(_extractDateValue(json, 'updatedAt')),
      notificationPreferences: preferences,
    );
  }

  ContactTypePreferences _parseContactTypePreferences(
    Map<String, dynamic> json,
  ) {
    return ContactTypePreferences(
      email: _parseFlags(json['email']),
      device: _parseFlags(json['device']),
    );
  }

  FridgeNotificationFlags _parseFlags(Object? value) {
    final json = value is Map<String, dynamic>
        ? value
        : const <String, dynamic>{};

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

  String _extractFridgeId(Map<String, dynamic> json) {
    final value = json['fridgeId'];
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }

    final fridgeValue = json['fridge'];
    if (fridgeValue is Map<String, dynamic>) {
      final nestedId = _extractFridgeId(fridgeValue);
      if (nestedId.isNotEmpty) {
        return nestedId;
      }
    }

    return '';
  }

  Map<String, dynamic> _extractPreferencesPayload(Map<String, dynamic> json) {
    final direct = json['contactTypePreferences'];
    if (direct is Map<String, dynamic>) {
      return direct;
    }

    return const <String, dynamic>{};
  }

  String? _extractDateValue(Map<String, dynamic> json, String key) {
    final direct = json[key];
    if (direct is String && direct.isNotEmpty) {
      return direct;
    }

    return null;
  }

  DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
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
    if (data is! Map<String, dynamic>) return const <dynamic>[];

    if (data['notifications'] is List) {
      return data['notifications'] as List;
    }

    return const <dynamic>[];
  }

  Map<String, dynamic>? _extractSingleNotification(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (_looksLikeNotification(data)) return data;
    }

    return null;
  }

  bool _looksLikeNotification(Map<String, dynamic> json) {
    return json.containsKey('fridgeId') ||
        json.containsKey('userId') ||
        json.containsKey('contactTypePreferences');
  }
}

@riverpod
NotificationsRepository notificationsRepository(Ref ref) {
  return NotificationsRepository(ref.watch(notificationsDioProvider));
}

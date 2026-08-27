import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/features/auth/data/repositories/notifications_repository.dart';
import 'package:fridgefinder_app/src/features/auth/domain/models/fridge_notification_preferences.dart';

class _TestHttpClientAdapter implements HttpClientAdapter {
  _TestHttpClientAdapter(this.body, {this.onRequest, this.statusCode = 200});

  final String body;
  final void Function(RequestOptions options)? onRequest;
  final int statusCode;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    onRequest?.call(options);

    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('NotificationsRepository', () {
    test('parses subscriptions from documented list payloads', () async {
      final dio = Dio()
        ..httpClientAdapter = _TestHttpClientAdapter(
          jsonEncode({
            'notifications': [
              {
                'fridgeId': 'fridge-123',
                'createdAt': '2024-01-01T00:00:00.000Z',
                'updatedAt': '2024-01-02T00:00:00.000Z',
                'contactTypePreferences': {
                  'email': {'dirty': true},
                  'device': {'good': false},
                },
              },
            ],
          }),
        );

      final repository = NotificationsRepository(dio);

      final subscriptions = await repository.getAllForUser('user-123');

      expect(subscriptions, hasLength(1));
      expect(subscriptions.single.fridgeId, 'fridge-123');
      expect(
        subscriptions
            .single
            .notificationPreferences
            .contactTypePreferences
            .email
            .dirty,
        isTrue,
      );
      expect(
        subscriptions
            .single
            .notificationPreferences
            .contactTypePreferences
            .device
            .good,
        isFalse,
      );
    });

    test('returns empty list for undocumented wrapped list payloads', () async {
      final dio = Dio()
        ..httpClientAdapter = _TestHttpClientAdapter(
          jsonEncode({
            'data': {
              'notifications': [
                {
                  'fridgeId': 'fridge-999',
                  'updatedAt': '2024-01-02T00:00:00.000Z',
                  'contactTypePreferences': {
                    'email': {'dirty': true},
                    'device': {'hasFood': true},
                  },
                },
              ],
            },
          }),
        );

      final repository = NotificationsRepository(dio);
      final subscriptions = await repository.getAllForUser('user-123');

      expect(subscriptions, isEmpty);
    });

    test('uses the expected follow API route', () async {
      final requestedPaths = <String>[];
      final requestBodies = <dynamic>[];
      final dio = Dio()
        ..httpClientAdapter = _TestHttpClientAdapter(
          jsonEncode({
            'userId': 'user-123',
            'fridgeId': 'fridge-123',
            'createdAt': '2024-01-01T00:00:00.000Z',
            'updatedAt': '2024-01-02T00:00:00.000Z',
            'contactTypePreferences': {
              'email': {'dirty': true},
              'device': {'good': false},
            },
          }),
          onRequest: (options) {
            requestedPaths.add(options.path);
            requestBodies.add(options.data);
          },
        );

      final repository = NotificationsRepository(dio);

      final subscription = await repository.followFridge(
        userId: 'user-123',
        fridgeId: 'fridge-123',
        preferences: NotificationPreferences(
          contactTypePreferences: ContactTypePreferences(
            email: const FridgeNotificationFlags(dirty: true),
            device: const FridgeNotificationFlags(good: false),
          ),
        ),
      );

      expect(requestedPaths, ['/users/user-123/fridge-notifications/fridge-123']);
      expect(subscription.fridgeId, 'fridge-123');
      final body = requestBodies.single as Map<String, dynamic>;
      final prefs = body['contactTypePreferences'] as Map<String, dynamic>;
      expect(prefs.containsKey('email'), isTrue);
      expect(prefs.containsKey('device'), isTrue);

      final email = prefs['email'] as Map<String, dynamic>;
      final device = prefs['device'] as Map<String, dynamic>;

      // We only send the fields currently used by app preferences.
      expect(email.containsKey('dirty'), isTrue);
      expect(email.containsKey('outOfOrder'), isTrue);
      expect(email.containsKey('noFood'), isTrue);
      expect(email.containsKey('hasFood'), isTrue);
      expect(email.containsKey('good'), isFalse);
      expect(email.containsKey('notAtLocation'), isFalse);
      expect(email.containsKey('ghost'), isFalse);

      expect(device.containsKey('dirty'), isTrue);
      expect(device.containsKey('outOfOrder'), isTrue);
      expect(device.containsKey('noFood'), isTrue);
      expect(device.containsKey('hasFood'), isTrue);
      expect(device.containsKey('good'), isFalse);
      expect(device.containsKey('notAtLocation'), isFalse);
      expect(device.containsKey('ghost'), isFalse);
    });

    test('returns fallback follow object for undocumented wrapped response', () async {
      final dio = Dio()
        ..httpClientAdapter = _TestHttpClientAdapter(
          jsonEncode({
            'data': {
              'userId': 'user-123',
              'fridgeId': 'fridge-abc',
              'updatedAt': '2024-01-02T00:00:00.000Z',
              'contactTypePreferences': {
                'email': {'good': true, 'noFood': true, 'hasFood': false},
              },
            },
          }),
          statusCode: 201,
        );

      final repository = NotificationsRepository(dio);
      final result = await repository.followFridge(
        userId: 'user-123',
        fridgeId: 'fridge-abc',
        preferences: const NotificationPreferences(),
      );

      expect(result.fridgeId, 'fridge-abc');
      expect(result.updatedAt, isNull);
    });

    test('treats empty follow response body as success', () async {
      final dio = Dio()
        ..httpClientAdapter = _TestHttpClientAdapter('', statusCode: 201);

      final repository = NotificationsRepository(dio);
      const prefs = NotificationPreferences();
      final result = await repository.followFridge(
        userId: 'user-123',
        fridgeId: 'fridge-empty',
        preferences: prefs,
      );

      expect(result.fridgeId, 'fridge-empty');
      expect(result.notificationPreferences, prefs);
    });

  });
}

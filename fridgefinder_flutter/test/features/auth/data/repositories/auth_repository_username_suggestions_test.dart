import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fridgefinder_app/src/features/auth/data/repositories/auth_repository.dart';
import 'package:fridgefinder_app/src/features/auth/presentation/widgets/username_generator.dart';

class _FakeFirebaseAuth implements firebase_auth.FirebaseAuth {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeGoogleSignIn implements GoogleSignIn {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockUsernameSuggestionsAdapter implements HttpClientAdapter {
  final Map<String, dynamic>? responseData;
  final DioException? error;
  final void Function(RequestOptions options)? onRequest;

  MockUsernameSuggestionsAdapter({this.responseData, this.error, this.onRequest});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    onRequest?.call(options);
    if (error != null) {
      throw error!;
    }

    final jsonBytes = utf8.encode(jsonEncode(responseData ?? {}));
    return ResponseBody.fromBytes(
      jsonBytes,
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio createDio(MockUsernameSuggestionsAdapter adapter) {
  final dio = Dio();
  dio.httpClientAdapter = adapter;
  return dio;
}

void main() {
  group('AuthRepository username suggestions', () {
    test('hits /users/username-suggestions with the requested count', () async {
      final adapter = MockUsernameSuggestionsAdapter(
        onRequest: (options) {
          expect(options.path, '/users/username-suggestions');
          expect(options.queryParameters, {'count': 2});
        },
        responseData: {
          'suggestions': ['ActiveApple-1234', 'BraveBerry-8891'],
          'count': 2,
        },
      );

      final repository = AuthRepository(
        auth: _FakeFirebaseAuth(),
        dio: createDio(adapter),
        googleSignIn: _FakeGoogleSignIn(),
      );

      final suggestions = await repository.getUsernameSuggestions(count: 2);

      expect(suggestions, ['ActiveApple-1234', 'BraveBerry-8891']);
    });

    test('throws when the API returns fewer suggestions than requested', () async {
      final adapter = MockUsernameSuggestionsAdapter(
        responseData: {
          'suggestions': ['OnlyOneAvailable'],
          'count': 1,
        },
      );

      final repository = AuthRepository(
        auth: _FakeFirebaseAuth(),
        dio: createDio(adapter),
        googleSignIn: _FakeGoogleSignIn(),
      );

      await expectLater(
        repository.getUsernameSuggestions(count: 2),
        throwsA(isA<FormatException>()),
      );
    });

    test('UsernameGenerator uses suggestions returned by the API', () async {
      final adapter = MockUsernameSuggestionsAdapter(
        responseData: {
          'suggestions': ['ApiSuggestedUser-1', 'ApiSuggestedUser-2'],
          'count': 2,
        },
      );

      final repository = AuthRepository(
        auth: _FakeFirebaseAuth(),
        dio: createDio(adapter),
        googleSignIn: _FakeGoogleSignIn(),
      );
      final generator = UsernameGenerator(repository);

      expect(await generator.generateUniqueUsername(), 'ApiSuggestedUser-1');
      expect(
        await generator.generateUsernameOptions(count: 2),
        ['ApiSuggestedUser-1', 'ApiSuggestedUser-2'],
      );
    });
  });
}

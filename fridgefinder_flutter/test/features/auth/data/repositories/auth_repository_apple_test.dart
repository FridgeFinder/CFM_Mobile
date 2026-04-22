import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:fridgefinder_app/src/features/auth/data/repositories/auth_repository.dart';

/// Mock Firebase User for testing
class _MockFirebaseUser implements firebase_auth.User {
  @override
  final String uid;
  @override
  final String? email;

  _MockFirebaseUser({required this.uid, this.email});

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Mock UserCredential for testing
class _MockUserCredential implements firebase_auth.UserCredential {
  @override
  final firebase_auth.User? user;

  _MockUserCredential({required this.user});

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Mock AuthRepository with Apple sign-in support for testing interface contract
class MockAuthRepositoryWithApple implements AuthRepository {
  bool _shouldFail = false;
  bool _shouldCancel = false;
  bool _shouldBeUnavailable = false;
  bool _shouldFailReauth = false;

  void setFailure(bool fail) => _shouldFail = fail;
  void setCancelled(bool cancel) => _shouldCancel = cancel;
  void setUnavailable(bool unavailable) => _shouldBeUnavailable = unavailable;
  void setReauthFailure(bool fail) => _shouldFailReauth = fail;

  @override
  Future<firebase_auth.UserCredential> signInWithApple() async {
    if (_shouldBeUnavailable) {
      throw const AppleSignInNotAvailableException();
    }
    if (_shouldCancel) {
      throw const SignInCancelledException();
    }
    if (_shouldFail) {
      throw Exception('Network error during Apple sign-in');
    }
    return _MockUserCredential(
      user: _MockFirebaseUser(
        uid: 'apple-test-user',
        email: 'test@privaterelay.appleid.com',
      ),
    );
  }

  @override
  Future<void> reauthenticateWithApple() async {
    if (_shouldFailReauth) {
      throw Exception('Re-authentication failed');
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockAuthRepositoryWithApple repository;

  setUp(() {
    repository = MockAuthRepositoryWithApple();
  });

  group('signInWithApple', () {
    test('returns UserCredential on success', () async {
      final credential = await repository.signInWithApple();
      expect(credential, isNotNull);
      expect(credential.user, isNotNull);
      expect(credential.user!.uid, 'apple-test-user');
      expect(credential.user!.email, 'test@privaterelay.appleid.com');
    });

    test('throws SignInCancelledException when cancelled', () async {
      repository.setCancelled(true);
      expect(
        () => repository.signInWithApple(),
        throwsA(isA<SignInCancelledException>()),
      );
    });

    test('throws on network error', () async {
      repository.setFailure(true);
      expect(
        () => repository.signInWithApple(),
        throwsA(isA<Exception>()),
      );
    });

    test('throws AppleSignInNotAvailableException when not available', () async {
      repository.setUnavailable(true);
      expect(
        () => repository.signInWithApple(),
        throwsA(isA<AppleSignInNotAvailableException>()),
      );
    });
  });

  group('reauthenticateWithApple', () {
    test('completes successfully', () async {
      await expectLater(repository.reauthenticateWithApple(), completes);
    });

    test('throws on failure', () async {
      repository.setReauthFailure(true);
      expect(
        () => repository.reauthenticateWithApple(),
        throwsA(isA<Exception>()),
      );
    });
  });
}

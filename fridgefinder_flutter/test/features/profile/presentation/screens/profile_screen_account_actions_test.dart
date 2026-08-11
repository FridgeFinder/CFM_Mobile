import 'package:design_system/design_system.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgefinder_app/src/core/providers/auth_provider.dart';
import 'package:fridgefinder_app/src/core/providers/environment_provider.dart';
import 'package:fridgefinder_app/src/core/providers/location_provider.dart';
import 'package:fridgefinder_app/src/core/providers/notification_providers.dart';
import 'package:fridgefinder_app/src/core/providers/points_provider.dart';
import 'package:fridgefinder_app/src/core/providers/theme_provider.dart';
import 'package:fridgefinder_app/src/core/services/fcm_service.dart';
import 'package:fridgefinder_app/src/features/auth/data/repositories/auth_repository.dart';
import 'package:fridgefinder_app/src/features/auth/domain/models/user_profile.dart';
import 'package:fridgefinder_app/src/features/profile/presentation/profile_screen.dart';
import '../../../../helpers/test_helpers.dart';

class _TestUser implements firebase_auth.User {
  _TestUser({required this.uid});

  @override
  final String uid;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _TestFirebaseAuth implements firebase_auth.FirebaseAuth {
  _TestFirebaseAuth(this.user);

  final firebase_auth.User? user;

  @override
  firebase_auth.User? get currentUser => user;

  @override
  Stream<firebase_auth.User?> authStateChanges() => Stream.value(user);

  @override
  Future<void> signOut() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _TestAuthRepository extends AuthRepository {
  _TestAuthRepository({
    this.signOutShouldThrow = false,
    this.deleteShouldThrow = false,
  }) : super(
          auth: _TestFirebaseAuth(_TestUser(uid: 'user-123')),
          dio: Dio(),
        );

  final bool signOutShouldThrow;
  final bool deleteShouldThrow;

  int signOutCallCount = 0;
  int deleteAccountCallCount = 0;
  String? lastDeletedUserId;

  @override
  Future<void> signOut() async {
    signOutCallCount += 1;
    if (signOutShouldThrow) {
      throw Exception('sign out failed');
    }
  }

  @override
  Future<void> deleteAccount(String userId) async {
    deleteAccountCallCount += 1;
    lastDeletedUserId = userId;
    if (deleteShouldThrow) {
      throw Exception('delete failed');
    }
  }
}

class _TestFirebaseMessaging implements FirebaseMessaging {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _TestFcmService extends FCMService {
  _TestFcmService({required AuthRepository authRepository})
      : super(
          authRepository: authRepository,
          messaging: _TestFirebaseMessaging(),
        );

  int deleteTokenCallCount = 0;

  @override
  Future<bool?> getCachedDeviceNotificationsEnabled() async => false;

  @override
  Future<bool> getDeviceNotificationsEnabled() async => false;

  @override
  Future<bool> setDeviceNotificationsEnabled(bool enabled) async => enabled;

  @override
  Future<void> deleteToken() async {
    deleteTokenCallCount += 1;
  }
}

UserProfile _buildProfile() {
  return UserProfile(
    userId: 'user-123',
    username: 'Test User',
    userType: UserType.volunteer,
    points: 42,
    settings: const UserSettings(),
    createdAt: DateTime(2024, 1, 1),
  );
}

Widget _buildTestApp({
  required _TestAuthRepository authRepository,
  required _TestFcmService fcmService,
}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWith((ref) => authRepository),
      fcmServiceProvider.overrideWith((ref) => fcmService),
      authUserProvider.overrideWith((ref) => Stream.value(_TestUser(uid: 'user-123'))),
      currentAuthUserProvider.overrideWith(
        (ref) => AsyncValue.data(_TestUser(uid: 'user-123')),
      ),
      isAuthenticatedProvider.overrideWith((ref) => true),
      userProfileProvider.overrideWith((ref) => Future.value(_buildProfile())),
      userPointsProvider.overrideWith((ref) => Future.value(42)),
      appThemeModeProvider.overrideWithValue(AppThemeMode.system),
      environmentProvider.overrideWithValue(ApiEnvironment.prod),
      locationAccessProvider.overrideWithValue(false),
    ],
    child: const MaterialApp(home: ProfileScreen()),
  );
}

void main() {
  setUpAll(() async {
    await initHiveForTesting();
  });

  tearDownAll(() async {
    await cleanupHive();
  });

  group('ProfileScreen account actions', () {
    testWidgets('opens and cancels sign out dialog without side effects', (
      tester,
    ) async {
      final authRepository = _TestAuthRepository();
      final fcmService = _TestFcmService(authRepository: authRepository);

      await tester.pumpWidget(
        _buildTestApp(authRepository: authRepository, fcmService: fcmService),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      expect(find.text('Sign Out?'), findsOneWidget);
      expect(find.text('Are you sure you want to sign out?'), findsOneWidget);

      await tester.tap(find.text('Cancel').first);
      await tester.pumpAndSettle();

      expect(find.text('Sign Out?'), findsNothing);
      expect(authRepository.signOutCallCount, 0);
      expect(fcmService.deleteTokenCallCount, 0);
    });

    testWidgets('confirms sign out and calls token deletion + auth sign out', (
      tester,
    ) async {
      final authRepository = _TestAuthRepository();
      final fcmService = _TestFcmService(authRepository: authRepository);

      await tester.pumpWidget(
        _buildTestApp(authRepository: authRepository, fcmService: fcmService),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Sign Out'));
      await tester.pumpAndSettle();

      expect(authRepository.signOutCallCount, 1);
      expect(fcmService.deleteTokenCallCount, 1);
      expect(find.text('Sign Out?'), findsNothing);
    });

    testWidgets('delete account dialog sequence can be cancelled at final step', (
      tester,
    ) async {
      final authRepository = _TestAuthRepository();
      final fcmService = _TestFcmService(authRepository: authRepository);

      await tester.pumpWidget(
        _buildTestApp(authRepository: authRepository, fcmService: fcmService),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(OutlinedButton, 'Delete Account'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Account?'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Final Confirmation'), findsOneWidget);
      await tester.tap(find.text('Cancel').first);
      await tester.pumpAndSettle();

      expect(find.text('Final Confirmation'), findsNothing);
      expect(authRepository.deleteAccountCallCount, 0);
      expect(authRepository.signOutCallCount, 0);
      expect(fcmService.deleteTokenCallCount, 0);
    });

    testWidgets('delete account error shows message and stops further actions', (
      tester,
    ) async {
      final authRepository = _TestAuthRepository(deleteShouldThrow: true);
      final fcmService = _TestFcmService(authRepository: authRepository);

      await tester.pumpWidget(
        _buildTestApp(authRepository: authRepository, fcmService: fcmService),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(OutlinedButton, 'Delete Account'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Delete Account'));
      await tester.pumpAndSettle();

      expect(authRepository.deleteAccountCallCount, 1);
      expect(authRepository.lastDeletedUserId, 'user-123');
      expect(authRepository.signOutCallCount, 0);
      expect(fcmService.deleteTokenCallCount, 0);
      expect(find.text('Final Confirmation'), findsNothing);
      expect(find.text('Delete Account?'), findsNothing);
    });
  });
}

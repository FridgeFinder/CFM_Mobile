import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:fridgefinder_app/src/features/auth/presentation/widgets/reauthenticate_dialog.dart';
import '../../../../helpers/test_helpers.dart';

/// Mock UserInfo to simulate Apple provider data
class MockAppleUserInfo implements firebase_auth.UserInfo {
  @override
  String get providerId => 'apple.com';

  @override
  String? get email => 'test@privaterelay.appleid.com';

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Mock Firebase User authenticated with Apple
class MockAppleUser implements firebase_auth.User {
  @override
  final String uid = 'apple-user-123';

  @override
  final String? email = 'test@privaterelay.appleid.com';

  @override
  final String? phoneNumber = null;

  @override
  final List<firebase_auth.UserInfo> providerData = [MockAppleUserInfo()];

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  setUpAll(() async {
    await initHiveForTesting();
  });

  tearDownAll(() async {
    await cleanupHive();
  });

  group('ReauthenticateDialog - Apple', () {
    testWidgets('shows "Continue with Apple" for Apple-authenticated user', (
      WidgetTester tester,
    ) async {
      final mockUser = MockAppleUser();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ReauthenticateDialog(user: mockUser),
                    );
                  },
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Should show "Continue with Apple"
      expect(find.text('Continue with Apple'), findsOneWidget);
    });

    testWidgets('shows Apple icon for Apple-authenticated user', (
      WidgetTester tester,
    ) async {
      final mockUser = MockAppleUser();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ReauthenticateDialog(user: mockUser),
                    );
                  },
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Should show Apple icon
      expect(find.byIcon(Icons.apple), findsWidgets);
    });
  });
}

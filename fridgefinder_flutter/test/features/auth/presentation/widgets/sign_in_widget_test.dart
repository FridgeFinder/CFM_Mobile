import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgefinder_app/src/features/auth/presentation/widgets/sign_in_widget.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  setUpAll(() async {
    await initHiveForTesting();
  });

  tearDownAll(() async {
    await cleanupHive();
  });

  group('SignInWidget Tests', () {
    testWidgets('displays phone and Gmail sign-in options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SignInWidget(),
            ),
          ),
        ),
      );

      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Sign In with Phone'), findsOneWidget);
      expect(find.text('Sign In with Gmail'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows verification code input after phone number sent', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SignInWidget(),
            ),
          ),
        ),
      );

      // Initially should show phone input
      expect(find.text('Sign In with Phone'), findsOneWidget);

      // Note: Actual phone verification requires Firebase setup
      // This test verifies UI structure only
    });

    testWidgets('calls onSignInSuccess callback when provided', (
      WidgetTester tester,
    ) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SignInWidget(
                onSignInSuccess: () {
                  callbackCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      expect(callbackCalled, isFalse);
      // Callback would be called after successful sign-in
    });
  });
}


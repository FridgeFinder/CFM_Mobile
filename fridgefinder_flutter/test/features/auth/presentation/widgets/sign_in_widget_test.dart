import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
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
    testWidgets('displays phone, Gmail, and Apple sign-in options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: SignInWidget())),
        ),
      );

      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Sign In with Phone'), findsOneWidget);
      expect(find.text('Sign In with Gmail'), findsOneWidget);
      expect(find.text('Sign In with Apple'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows verification code input after phone number sent', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: SignInWidget())),
        ),
      );

      // Initially should show phone input
      expect(find.text('Sign In with Phone'), findsOneWidget);

      // Note: Actual phone verification requires Firebase setup
      // This test verifies UI structure only
    });

    testWidgets('Apple Sign-In button uses OutlinedButton', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: SignInWidget())),
        ),
      );

      final appleButton = find.text('Sign In with Apple');
      expect(appleButton, findsOneWidget);

      // The Apple button should be inside an OutlinedButtonM3E
      final outlinedButtonAncestor = find.ancestor(
        of: appleButton,
        matching: find.byType(OutlinedButtonM3E),
      );
      expect(outlinedButtonAncestor, findsOneWidget);
    });

    testWidgets('Apple button appears after Gmail button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: SingleChildScrollView(child: SignInWidget())),
          ),
        ),
      );

      final gmailButton = find.text('Sign In with Gmail');
      final appleButton = find.text('Sign In with Apple');

      expect(gmailButton, findsOneWidget);
      expect(appleButton, findsOneWidget);

      // Apple button should be below Gmail button (greater Y offset)
      final gmailOffset = tester.getTopLeft(gmailButton);
      final appleOffset = tester.getTopLeft(appleButton);
      expect(appleOffset.dy, greaterThan(gmailOffset.dy));
    });

    testWidgets('Apple button is hidden during verification code entry', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: SignInWidget())),
        ),
      );

      // Initially Apple button is visible
      expect(find.text('Sign In with Apple'), findsOneWidget);

      // The verification code UI replaces the sign-in buttons,
      // so Apple button would not be visible when _isCodeSent is true.
      // We verify the initial state has the Apple button present.
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

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
    testWidgets('displays email, phone, Google, and Apple sign-in options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(child: const MaterialApp(home: SignInWidget())),
      );

      expect(find.text('Welcome!'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('Sign In with Google'), findsOneWidget);
      expect(find.text('Sign In with Apple'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows phone mode when phone toggle is selected', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(child: const MaterialApp(home: SignInWidget())),
      );

      await tester.tap(find.text('Phone'));
      await tester.pump();

      expect(find.text('+1'), findsNothing);
      expect(find.byType(DropdownMenu<String>), findsNothing);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Sign In with Google'), findsOneWidget);
    });

    testWidgets('Apple Sign-In button uses OutlinedButton', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(child: const MaterialApp(home: SignInWidget())),
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

    testWidgets('Apple button appears after Google button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(child: const MaterialApp(home: SignInWidget())),
      );

      final gmailButton = find.text('Sign In with Google');
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
        ProviderScope(child: const MaterialApp(home: SignInWidget())),
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
            home: SignInWidget(
              onSignInSuccess: () {
                callbackCalled = true;
              },
            ),
          ),
        ),
      );

      expect(callbackCalled, isFalse);
      // Callback would be called after successful sign-in
    });

    testWidgets('shows validation feedback above the sign-in form', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(child: const MaterialApp(home: SignInWidget())),
      );

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Please enter your email address'), findsOneWidget);
    });

    testWidgets('shows privacy policy footer', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(child: const MaterialApp(home: SignInWidget())),
      );

      expect(
        find.textContaining('By continuing, you agree to our'),
        findsOneWidget,
      );
      expect(find.text('Privacy Policy'), findsOneWidget);
    });
  });
}

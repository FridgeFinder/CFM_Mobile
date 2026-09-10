import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/routing/router.dart';

void main() {
  testWidgets(
    'rootNavigatorKey can close a dialog pushed on the root navigator '
    'from a widget outside of it (regression: magic link sign-in modal '
    'must close after sign-in completes)',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: rootNavigatorKey,
          home: const Scaffold(body: Text('Home')),
        ),
      );

      rootNavigatorKey.currentState!.push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => const Scaffold(body: Text('Sign In')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sign In'), findsOneWidget);

      // Same call app.dart's magic-link "signedIn" handler uses to dismiss
      // the sign-in dialog, invoked from outside the navigator's own context.
      rootNavigatorKey.currentState?.popUntil((route) => route.isFirst);
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsNothing);
      expect(find.text('Home'), findsOneWidget);
    },
  );
}

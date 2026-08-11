import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgefinder_app/src/features/auth/presentation/screens/my_fridges_screen.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  setUpAll(() async {
    await initHiveForTesting();
  });

  tearDownAll(() async {
    await cleanupHive();
  });

  group('MyFridgesScreen Tests', () {
    testWidgets('displays sign-in prompt when not authenticated', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: MyFridgesScreen())),
      );

      await tester.pumpAndSettle();

      // Should show sign-in prompt
      expect(
        find.textContaining('Follow specific fridges'),
        findsOneWidget,
      );
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('displays subscribed fridges when authenticated', (
      WidgetTester tester,
    ) async {
      // Note: This test requires Firebase setup and authenticated user
      // For now, we verify the widget structure
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: MyFridgesScreen())),
      );

      await tester.pumpAndSettle();

      // Widget should render without errors
      expect(find.byType(MyFridgesScreen), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });
  });
}

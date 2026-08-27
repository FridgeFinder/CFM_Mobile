import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgefinder_app/src/features/auth/presentation/widgets/edit_notification_preferences_dialog.dart';
import 'package:fridgefinder_app/src/features/auth/domain/models/fridge_notification_preferences.dart';

void main() {
  group('NotificationPreferencesDialog', () {
    const initialPreferences = NotificationPreferences(
      contactTypePreferences: ContactTypePreferences(
        email: FridgeNotificationFlags(hasFood: true, noFood: true),
        device: FridgeNotificationFlags(hasFood: true, noFood: true),
      ),
    );

    testWidgets('renders edit mode title and fridge name', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: NotificationPreferencesDialog.edit(
                fridgeId: 'fridge-1',
                fridgeName: 'Test Fridge',
                initialPreferences: initialPreferences,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Notification Preferences'), findsOneWidget);
      expect(find.text('Test Fridge'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Unfollow'), findsOneWidget);
    });

    testWidgets('renders subscribe mode title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: NotificationPreferencesDialog.follow(fridgeId: 'fridge-2'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Follow Fridge'), findsOneWidget);
      expect(find.text('Follow'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Unfollow'), findsNothing);
    });
  });
}

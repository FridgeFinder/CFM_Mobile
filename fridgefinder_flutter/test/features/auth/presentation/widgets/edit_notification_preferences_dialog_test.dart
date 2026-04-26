import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgefinder_app/src/features/auth/presentation/widgets/edit_notification_preferences_dialog.dart';
import 'package:fridgefinder_app/src/features/auth/domain/models/subscription_preferences.dart';
import 'package:fridgefinder_app/src/core/providers/subscriptions_provider.dart';

void main() {
  group('EditNotificationPreferencesDialog Tests', () {
    const testFridgeId = 'test-fridge-123';
    const testFridgeName = 'Test Community Fridge';
    const initialPreferences = NotificationPreferences(
      updatedWithFood: true,
      runningLow: true,
      empty: false,
      needsCleaning: false,
      needsServicing: false,
      routineValidation: false,
    );

    testWidgets('Dialog displays initial preferences correctly', (WidgetTester tester) async {
      final testNotifier = TestSubscriptionManagerNotifier();

      final container = ProviderContainer(
        overrides: [
          subscriptionManagerProvider.overrideWith(() => testNotifier),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => EditNotificationPreferencesDialog(
                  fridgeId: testFridgeId,
                  fridgeName: testFridgeName,
                  initialPreferences: initialPreferences,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify dialog title and fridge name
      expect(find.text('Notification Preferences'), findsOneWidget);
      expect(find.text(testFridgeName), findsOneWidget);

      // Verify all preference options are displayed
      expect(find.text('Updated with Food'), findsOneWidget);
      expect(find.text('Running Low'), findsOneWidget);
      expect(find.text('Empty'), findsOneWidget);
      expect(find.text('Needs Cleaning'), findsOneWidget);
      expect(find.text('Needs Servicing'), findsOneWidget);
      expect(find.text('Routine Validation'), findsOneWidget);

      // Verify Save and Cancel buttons
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      container.dispose();
    });

    testWidgets('Cancel button closes dialog without saving', (WidgetTester tester) async {
      final testNotifier = TestSubscriptionManagerNotifier();

      final container = ProviderContainer(
        overrides: [
          subscriptionManagerProvider.overrideWith(() => testNotifier),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => EditNotificationPreferencesDialog(
                          fridgeId: testFridgeId,
                          fridgeName: testFridgeName,
                          initialPreferences: initialPreferences,
                        ),
                      );
                    },
                    child: const Text('Show Dialog'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.byType(EditNotificationPreferencesDialog), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.byType(EditNotificationPreferencesDialog), findsNothing);

      // Verify update was not called
      expect(testNotifier.updateCalled, isFalse);

      container.dispose();
    });

    testWidgets('Save button updates preferences and closes dialog WITHOUT hanging', (WidgetTester tester) async {
      bool updateCalled = false;
      NotificationPreferences? savedPreferences;

      final testNotifier = TestSubscriptionManagerNotifier(
        onUpdatePreferences: (fridgeId, preferences) async {
          updateCalled = true;
          savedPreferences = preferences;
          // Simulate network delay
          await Future.delayed(const Duration(milliseconds: 100));
        },
      );

      final container = ProviderContainer(
        overrides: [
          subscriptionManagerProvider.overrideWith(() => testNotifier),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => EditNotificationPreferencesDialog(
                          fridgeId: testFridgeId,
                          fridgeName: testFridgeName,
                          initialPreferences: initialPreferences,
                        ),
                      );
                    },
                    child: const Text('Show Dialog'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.byType(EditNotificationPreferencesDialog), findsOneWidget);

      // Toggle one preference (Needs Cleaning)
      // Find the Row containing "Needs Cleaning" text
      final needsCleaningRow = find.ancestor(
        of: find.text('Needs Cleaning'),
        matching: find.byType(Row),
      );
      // Find the Switch within that Row
      final needsCleaningSwitch = find.descendant(
        of: needsCleaningRow,
        matching: find.byType(Switch),
      );
      await tester.tap(needsCleaningSwitch);
      await tester.pumpAndSettle();

      // Tap Save button
      await tester.tap(find.text('Save'));
      await tester.pump(); // Start the save operation

      // CRITICAL TEST: Verify loading indicator appears in Save button
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for save operation to complete
      await tester.pumpAndSettle();

      // CRITICAL TEST: Verify NO loading indicators remain after save
      expect(
        find.byType(CircularProgressIndicator),
        findsNothing,
        reason: 'NO loading indicators should remain after saving - this is the bug!',
      );

      // Verify dialog is closed
      expect(find.byType(EditNotificationPreferencesDialog), findsNothing);

      // Verify success snackbar appears
      expect(find.text('Notification preferences updated'), findsOneWidget);

      // Verify update was called with correct preferences
      expect(updateCalled, isTrue);
      expect(savedPreferences?.needsCleaning, isTrue);
      expect(savedPreferences?.updatedWithFood, isTrue);
      expect(savedPreferences?.runningLow, isTrue);

      container.dispose();
    });

    testWidgets('Save button shows error on failure WITHOUT hanging', (WidgetTester tester) async {
      final testNotifier = TestSubscriptionManagerNotifier(
        onUpdatePreferences: (fridgeId, preferences) async {
          await Future.delayed(const Duration(milliseconds: 50));
          throw Exception('Network error');
        },
      );

      final container = ProviderContainer(
        overrides: [
          subscriptionManagerProvider.overrideWith(() => testNotifier),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => EditNotificationPreferencesDialog(
                          fridgeId: testFridgeId,
                          fridgeName: testFridgeName,
                          initialPreferences: initialPreferences,
                        ),
                      );
                    },
                    child: const Text('Show Dialog'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Tap Save button
      await tester.tap(find.text('Save'));
      await tester.pump();

      // Verify loading indicator appears
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for error handling
      await tester.pumpAndSettle();

      // CRITICAL TEST: Verify NO loading indicators remain after error
      expect(
        find.byType(CircularProgressIndicator),
        findsNothing,
        reason: 'NO loading indicators should remain even after an error',
      );

      // Verify dialog is still open (not closed on error)
      expect(find.byType(EditNotificationPreferencesDialog), findsOneWidget);

      // Verify error snackbar appears
      expect(find.textContaining('Error updating preferences'), findsOneWidget);

      container.dispose();
    });

    testWidgets('Multiple switches can be toggled', (WidgetTester tester) async {
      final testNotifier = TestSubscriptionManagerNotifier();

      final container = ProviderContainer(
        overrides: [
          subscriptionManagerProvider.overrideWith(() => testNotifier),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: EditNotificationPreferencesDialog(
                fridgeId: testFridgeId,
                fridgeName: testFridgeName,
                initialPreferences: initialPreferences,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find switches and toggle them
      // Find Empty switch
      final emptyRow = find.ancestor(
        of: find.text('Empty'),
        matching: find.byType(Row),
      );
      final emptySwitch = find.descendant(
        of: emptyRow,
        matching: find.byType(Switch),
      );

      // Find Needs Cleaning switch
      final needsCleaningRow = find.ancestor(
        of: find.text('Needs Cleaning'),
        matching: find.byType(Row),
      );
      final needsCleaningSwitch = find.descendant(
        of: needsCleaningRow,
        matching: find.byType(Switch),
      );

      // Toggle Empty (off -> on)
      await tester.tap(emptySwitch);
      await tester.pumpAndSettle();

      // Toggle Needs Cleaning (off -> on)
      await tester.tap(needsCleaningSwitch);
      await tester.pumpAndSettle();

      // Verify no errors occurred
      expect(tester.takeException(), isNull);

      container.dispose();
    });
  });
}

/// Test notifier for subscription manager
class TestSubscriptionManagerNotifier extends SubscriptionManager {
  final Future<void> Function(String fridgeId, NotificationPreferences preferences)? onUpdatePreferences;
  bool updateCalled = false;

  TestSubscriptionManagerNotifier({this.onUpdatePreferences});

  @override
  Future<void> updateNotificationPreferences(
    String fridgeId,
    NotificationPreferences preferences,
  ) async {
    updateCalled = true;
    if (onUpdatePreferences != null) {
      await onUpdatePreferences!(fridgeId, preferences);
    }
  }
}

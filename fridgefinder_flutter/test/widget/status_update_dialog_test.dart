import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import '../fixtures/fridge_fixtures.dart';
import 'package:fridgefinder_app/src/features/profile/presentation/widgets/status_update_form.dart';

/// Test to reproduce and fix the RenderBox layout error
void main() {
  testWidgets('StatusUpdateForm in Dialog renders without layout errors', (
    WidgetTester tester,
  ) async {
    final testFridge = FridgeFixtures.verifiedFridgeWithFood;

    // Build the exact dialog structure from the app
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: Padding(
                            padding: EdgeInsets.all(M3ESpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Report Status Update',
                                  style: M3ETypography.headlineSmall,
                                ),
                                SizedBox(height: M3ESpacing.md),
                                Expanded(
                                  child: StatusUpdateForm(fridge: testFridge),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      ),
    );

    // Tap button to open dialog
    await tester.tap(find.text('Open Dialog'));

    // This is where the error should occur if not fixed
    await tester.pumpAndSettle();

    // If we get here without errors, the layout is working
    expect(find.text('Report Status Update'), findsOneWidget);
    expect(find.text('Fridge Condition'), findsOneWidget);

    debugPrint(
      '✅ Test passed - StatusUpdateForm dialog rendered without RenderBox layout errors',
    );
  });
}

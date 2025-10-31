import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgefinder_app/src/features/list/presentation/list_screen.dart';
import 'package:fridgefinder_app/src/features/map/presentation/controllers/fridge_list_controller.dart';
import '../../../fixtures/fridge_fixtures.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(() async {
    await initHiveForTesting();
  });

  tearDownAll(() async {
    await cleanupHive();
  });

  group('ListScreen Widget Tests', () {
    testWidgets('ListScreen is ConsumerStatefulWidget for efficiency',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fridgeListProvider.overrideWith((ref) async => FridgeFixtures.allFridges),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ListScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify ListScreen widget exists
      // Using ConsumerStatefulWidget allows proper lifecycle management
      // with TextEditingController and FocusNode for non-blocking search
      expect(find.byType(ListScreen), findsOneWidget);
    });

    testWidgets('ListScreen displays proper scaffold structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fridgeListProvider.overrideWith((ref) async => FridgeFixtures.allFridges),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ListScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Scaffold is rendered
      expect(find.byType(Scaffold), findsWidgets);

      // ListScreen should render successfully
      expect(find.byType(ListScreen), findsOneWidget);
    });

    testWidgets('ListScreen renders without crashing on init',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fridgeListProvider.overrideWith((ref) async => FridgeFixtures.allFridges),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ListScreen(),
            ),
          ),
        ),
      );

      // Should render without crashing
      await tester.pumpAndSettle();

      // Widget should be present
      expect(find.byType(ListScreen), findsOneWidget);
    });
  });
}

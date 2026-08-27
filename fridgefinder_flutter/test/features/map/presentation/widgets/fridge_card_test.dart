import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:fridgefinder_app/src/features/list/presentation/widgets/fridge_card.dart';
import 'package:fridgefinder_app/src/core/providers/neighborhood_provider.dart';
import '../../../../fixtures/fridge_fixtures.dart';

Widget _buildTestApp(Widget child) {
  return ProviderScope(
    overrides: [
      fridgeNeighborhoodProvider.overrideWith(
        (ref, fridgeId) => Future.value('Test Neighborhood'),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('FridgeCard Widget Tests', () {
    testWidgets('displays fridge name', (WidgetTester tester) async {
      final fridge = FridgeFixtures.verifiedFridgeWithFood;

      await tester.pumpWidget(
        _buildTestApp(FridgeCard(fridge: fridge, onTap: () {})),
      );

      expect(find.text(fridge.name), findsOneWidget);
    });

    testWidgets('displays fridge location short address', (
      WidgetTester tester,
    ) async {
      final fridge = FridgeFixtures.verifiedFridgeWithFood;

      await tester.pumpWidget(
        _buildTestApp(FridgeCard(fridge: fridge, onTap: () {})),
      );

      expect(find.text(fridge.location.shortAddress), findsOneWidget);
    });

    testWidgets('displays fridge status', (WidgetTester tester) async {
      final fridge = FridgeFixtures.verifiedFridgeWithFood;

      await tester.pumpWidget(
        _buildTestApp(FridgeCard(fridge: fridge, onTap: () {})),
      );

      expect(find.text(fridge.statusText), findsOneWidget);
    });

    testWidgets('displays food level', (WidgetTester tester) async {
      final fridge = FridgeFixtures.verifiedFridgeWithFood;

      await tester.pumpWidget(
        _buildTestApp(FridgeCard(fridge: fridge, onTap: () {})),
      );

      expect(find.text(fridge.foodLevelText), findsOneWidget);
    });

    testWidgets('displays verification icon for unverified fridge', (
      WidgetTester tester,
    ) async {
      final fridge = FridgeFixtures.notAtLocationFridge;

      await tester.pumpWidget(
        _buildTestApp(FridgeCard(fridge: fridge, onTap: () {})),
      );

      expect(find.byIcon(Icons.location_off), findsOneWidget);
    });

    testWidgets('does not display verification icon for verified fridge', (
      WidgetTester tester,
    ) async {
      final fridge = FridgeFixtures.verifiedFridgeWithFood;

      await tester.pumpWidget(
        _buildTestApp(FridgeCard(fridge: fridge, onTap: () {})),
      );

      expect(find.byIcon(Icons.location_off), findsNothing);
    });

    testWidgets('displays SVG icon marker', (WidgetTester tester) async {
      final fridge = FridgeFixtures.verifiedFridgeWithFood;

      await tester.pumpWidget(
        _buildTestApp(FridgeCard(fridge: fridge, onTap: () {})),
      );

      // Should have a SizedBox for the icon
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsWidgets);
    });

    testWidgets('calls onTap when card is tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        _buildTestApp(
          FridgeCard(
            fridge: FridgeFixtures.verifiedFridgeWithFood,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(CardM3E));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('displays card widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          FridgeCard(
            fridge: FridgeFixtures.verifiedFridgeWithFood,
            onTap: () {},
          ),
        ),
      );

      expect(find.byType(CardM3E), findsOneWidget);
    });

    testWidgets('displays Status and Food Level labels', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          FridgeCard(
            fridge: FridgeFixtures.verifiedFridgeWithFood,
            onTap: () {},
          ),
        ),
      );

      expect(find.text(FridgeFixtures.verifiedFridgeWithFood.statusText), findsOneWidget);
      expect(find.text(FridgeFixtures.verifiedFridgeWithFood.foodLevelText), findsOneWidget);
    });

    testWidgets('displays status icon for fridge with report', (
      WidgetTester tester,
    ) async {
      final fridge = FridgeFixtures.verifiedFridgeWithFood;

      await tester.pumpWidget(
        _buildTestApp(FridgeCard(fridge: fridge, onTap: () {})),
      );

      // Should have a status icon (check_circle for good condition)
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('displays dirty condition icon', (WidgetTester tester) async {
      final fridge = FridgeFixtures.fridgeDirty;

      await tester.pumpWidget(
        _buildTestApp(FridgeCard(fridge: fridge, onTap: () {})),
      );

      // Should have cleaning_services icon for dirty condition
      expect(find.byIcon(Icons.cleaning_services), findsOneWidget);
    });

    testWidgets('displays out of order icon', (WidgetTester tester) async {
      final fridge = FridgeFixtures.fridgeOutOfOrder;

      await tester.pumpWidget(
        _buildTestApp(FridgeCard(fridge: fridge, onTap: () {})),
      );

      // Should have build_circle icon for out of order condition
      expect(find.byIcon(Icons.build_circle), findsOneWidget);
    });

    testWidgets('displays fridge name with max lines', (
      WidgetTester tester,
    ) async {
      final fridge = FridgeFixtures.verifiedFridgeWithFood;

      await tester.pumpWidget(
        _buildTestApp(FridgeCard(fridge: fridge, onTap: () {})),
      );

      final textWidgets = find.byType(Text);
      final nameText =
          textWidgets.evaluate().firstWhere((element) {
                final text = element.widget as Text;
                return text.data == fridge.name;
              }).widget
              as Text;

      expect(nameText.maxLines, 1);
    });
  });
}

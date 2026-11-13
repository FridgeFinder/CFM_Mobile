import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgefinder_app/src/features/profile/presentation/widgets/status_update_form.dart';
import 'package:fridgefinder_app/src/features/map/domain/models/fridge_domain.dart';
import 'package:design_system/design_system.dart';
import 'package:fridgefinder_app/src/features/map/data/repositories/fridge_repository.dart';
import '../../../../fixtures/fridge_fixtures.dart';
import '../../../../test_helpers.dart';

/// Records the food level of every submitted report.
class _RecordingFridgeRepository extends MockFridgeRepository {
  final List<double> submittedFoodLevels = [];

  @override
  Future<void> submitFridgeReport(
    String fridgeId,
    FridgeCondition condition,
    double foodPercentage,
    String? notes,
    List<int>? photoBytes,
  ) async {
    submittedFoodLevels.add(foodPercentage);
  }
}

/// Helper to pump a StatusUpdateForm inside a minimal app shell.
Widget _buildTestApp({
  required FridgeDomain fridge,
  ValueChanged<bool>? onDirtyChanged,
  ScaffoldMessengerState? parentMessenger,
  FridgeRepository? repository,
}) {
  return ProviderScope(
    overrides: [
      if (repository != null)
        fridgeRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: StatusUpdateForm(
          fridge: fridge,
          onDirtyChanged: onDirtyChanged,
          parentMessenger: parentMessenger,
        ),
      ),
    ),
  );
}

void main() {
  // ---------------------------------------------------------------------------
  // Cycle 1: Standardize Condition Labels
  // ---------------------------------------------------------------------------
  group('Condition labels', () {
    testWidgets('displays "Good" not "Good - Operational"', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(fridge: FridgeFixtures.verifiedFridgeWithFood),
      );
      await tester.pumpAndSettle();

      expect(find.text('Good'), findsOneWidget);
      expect(find.text('Good - Operational'), findsNothing);
    });

    testWidgets('displays "Needs Cleaning" not "Dirty - Needs Cleaning"', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(fridge: FridgeFixtures.verifiedFridgeWithFood),
      );
      await tester.pumpAndSettle();

      expect(find.text('Needs Cleaning'), findsOneWidget);
      expect(find.text('Dirty - Needs Cleaning'), findsNothing);
    });

    testWidgets('displays "Needs Repairs"', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(fridge: FridgeFixtures.verifiedFridgeWithFood),
      );
      await tester.pumpAndSettle();

      expect(find.text('Needs Repairs'), findsOneWidget);
    });

    testWidgets('displays "Not at Location"', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(fridge: FridgeFixtures.verifiedFridgeWithFood),
      );
      await tester.pumpAndSettle();

      expect(find.text('Not at Location'), findsOneWidget);
    });

    testWidgets('does not display ghost condition option', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(fridge: FridgeFixtures.verifiedFridgeWithFood),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ghost - No Longer There'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Cycle 2: Make Condition Required
  // ---------------------------------------------------------------------------
  group('Condition required', () {
    testWidgets('label says "Fridge Condition" without "(Optional)"', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(fridge: FridgeFixtures.verifiedFridgeWithFood),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fridge Condition'), findsOneWidget);
      expect(find.text('Fridge Condition (Optional)'), findsNothing);
    });

    testWidgets('Next button disabled when no condition selected (step 0)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(fridge: FridgeFixtures.verifiedFridgeWithFood),
      );
      await tester.pumpAndSettle();

      // Find the FilledButtonM3E containing 'Next'
      final nextButton = find.widgetWithText(FilledButtonM3E, 'Next');
      expect(nextButton, findsOneWidget);

      final button = tester.widget<FilledButtonM3E>(nextButton);
      expect(button.onPressed, isNull, reason: 'Next should be disabled');
    });

    testWidgets('Next button enabled after selecting a condition', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(fridge: FridgeFixtures.verifiedFridgeWithFood),
      );
      await tester.pumpAndSettle();

      // Tap the "Good" radio option (rendered as ListTile by RadioM3E)
      await tester.tap(find.text('Good'));
      await tester.pumpAndSettle();

      final nextButton = find.widgetWithText(FilledButtonM3E, 'Next');
      final button = tester.widget<FilledButtonM3E>(nextButton);
      expect(button.onPressed, isNotNull, reason: 'Next should be enabled');
    });
  });

  // ---------------------------------------------------------------------------
  // Cycle 3: Food Level — No Pre-fill, Require Interaction
  // ---------------------------------------------------------------------------
  group('Food level step', () {
    Future<void> navigateToFoodStep(WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestApp(fridge: FridgeFixtures.verifiedFridgeWithFood),
      );
      await tester.pumpAndSettle();

      // Select a condition to enable Next
      await tester.tap(find.text('Good'));
      await tester.pumpAndSettle();

      // Tap Next to go to step 1 (Food Level)
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    testWidgets('slider starts at 0.0, not pre-filled from fridge data', (
      tester,
    ) async {
      await navigateToFoodStep(tester);

      // Find the SliderM3E and verify it wraps a Slider at 0.0
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);
      final sliderWidget = tester.widget<Slider>(slider);
      expect(sliderWidget.value, 0.0);
    });

    testWidgets('Next button disabled until slider is touched', (tester) async {
      await navigateToFoodStep(tester);

      final nextButton = find.widgetWithText(FilledButtonM3E, 'Next');
      final button = tester.widget<FilledButtonM3E>(nextButton);
      expect(
        button.onPressed,
        isNull,
        reason: 'Next should be disabled until slider touched',
      );
    });

    testWidgets('Next button enabled after dragging slider', (tester) async {
      await navigateToFoodStep(tester);

      // Drag the slider to the right
      final slider = find.byType(Slider);
      // Drag enough to change value
      await tester.drag(slider, const Offset(100, 0));
      await tester.pumpAndSettle();

      final nextButton = find.widgetWithText(FilledButtonM3E, 'Next');
      final button = tester.widget<FilledButtonM3E>(nextButton);
      expect(
        button.onPressed,
        isNotNull,
        reason: 'Next should be enabled after slider touch',
      );
    });

    /// Taps the slider track at its far-left ("Empty") end.
    Future<void> tapEmptyEnd(WidgetTester tester) async {
      final rect = tester.getRect(find.byType(Slider));
      await tester.tapAt(rect.centerLeft + const Offset(4, 0));
      await tester.pumpAndSettle();
    }

    bool nextEnabled(WidgetTester tester) =>
        tester
            .widget<FilledButtonM3E>(
              find.widgetWithText(FilledButtonM3E, 'Next'),
            )
            .onPressed !=
        null;

    testWidgets('tapping the Empty end enables Next with the slider at 0', (
      tester,
    ) async {
      await navigateToFoodStep(tester);

      await tapEmptyEnd(tester);

      expect(tester.widget<Slider>(find.byType(Slider)).value, 0.0);
      expect(
        nextEnabled(tester),
        isTrue,
        reason: 'Choosing Empty is a valid answer without moving the slider',
      );
    });

    testWidgets('dragging up and back down to Empty keeps Next enabled', (
      tester,
    ) async {
      await navigateToFoodStep(tester);

      await tester.drag(find.byType(Slider), const Offset(200, 0));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Slider), const Offset(-600, 0));
      await tester.pumpAndSettle();

      expect(tester.widget<Slider>(find.byType(Slider)).value, 0.0);
      expect(nextEnabled(tester), isTrue);
    });

    testWidgets('choosing Empty marks the form dirty', (tester) async {
      bool? lastDirty;
      await tester.pumpWidget(
        _buildTestApp(
          fridge: FridgeFixtures.verifiedFridgeWithFood,
          onDirtyChanged: (v) => lastDirty = v,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Good'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      lastDirty = null;
      await tapEmptyEnd(tester);

      expect(lastDirty, isTrue);
    });

    testWidgets('submitting after choosing Empty reports food level 0', (
      tester,
    ) async {
      final repository = _RecordingFridgeRepository();
      await tester.pumpWidget(
        _buildTestApp(
          fridge: FridgeFixtures.verifiedFridgeWithFood,
          repository: repository,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Good'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      await tapEmptyEnd(tester);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Submit Update'));
      await tester.tap(find.text('Submit Update'));
      await tester.pumpAndSettle();

      expect(repository.submittedFoodLevels, [0.0]);
    });

    testWidgets('submitting after dragging up reports the chosen level', (
      tester,
    ) async {
      final repository = _RecordingFridgeRepository();
      await tester.pumpWidget(
        _buildTestApp(
          fridge: FridgeFixtures.verifiedFridgeWithFood,
          repository: repository,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Good'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(Slider), const Offset(2000, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Submit Update'));
      await tester.tap(find.text('Submit Update'));
      await tester.pumpAndSettle();

      expect(repository.submittedFoodLevels, [1.0]);
    });
  });

  // ---------------------------------------------------------------------------
  // Cycle 5: Dirty state callback
  // ---------------------------------------------------------------------------
  group('Dirty state (onDirtyChanged)', () {
    testWidgets('fires true after selecting a condition', (tester) async {
      bool? lastDirty;
      await tester.pumpWidget(
        _buildTestApp(
          fridge: FridgeFixtures.verifiedFridgeWithFood,
          onDirtyChanged: (v) => lastDirty = v,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Good'));
      await tester.pumpAndSettle();

      expect(lastDirty, isTrue);
    });

    testWidgets('fires true after typing notes', (tester) async {
      bool? lastDirty;
      await tester.pumpWidget(
        _buildTestApp(
          fridge: FridgeFixtures.verifiedFridgeWithFood,
          onDirtyChanged: (v) => lastDirty = v,
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to step 0 → select condition → step 1 → touch slider → step 2
      await tester.tap(find.text('Good'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Drag slider
      await tester.drag(find.byType(Slider), const Offset(100, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Type notes
      lastDirty = null;
      await tester.enterText(find.byType(TextField).first, 'Some notes');
      await tester.pumpAndSettle();

      expect(lastDirty, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Cycle 6: No Hardcoded Colors
  // ---------------------------------------------------------------------------
  group('Hardcoded colors', () {
    test('source file contains no hardcoded Color(0xFF... values', () {
      final file = File(
        'lib/src/features/profile/presentation/widgets/status_update_form.dart',
      );
      final contents = file.readAsStringSync();

      // The only Color(0xFF...) allowed is 0xFFFFFFFF (white) used in _getFoodLevelColor
      final matches = RegExp(
        r'Color\(0xFF(?!FFFFFF\b)[0-9A-Fa-f]{6}\)',
      ).allMatches(contents);
      expect(
        matches.length,
        0,
        reason:
            'Found hardcoded Color values: ${matches.map((m) => m.group(0)).toList()}',
      );
    });
  });
}

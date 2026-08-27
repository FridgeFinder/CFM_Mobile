import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/components/fab_m3e.dart';

void main() {
  group('FABM3E Basic Tests', () {
    testWidgets('renders FAB with icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FABM3E(
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(FABM3E), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders small, regular, and large FABs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                FABM3E(
                  icon: Icons.add,
                  size: FABSize.small,
                  onPressed: () {},
                ),
                FABM3E(
                  icon: Icons.add,
                  size: FABSize.regular,
                  onPressed: () {},
                ),
                FABM3E(
                  icon: Icons.add,
                  size: FABSize.large,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(FABM3E), findsNWidgets(3));
    });

    testWidgets('renders extended FAB with label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FABM3E(
              icon: Icons.add,
              label: 'Create',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Create'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders tonal variant', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FABM3E(
              icon: Icons.edit,
              tonal: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(FABM3E), findsOneWidget);
    });
  });

  group('IconButtonM3E Basic Tests', () {
    testWidgets('renders standard icon button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconButtonM3E(
              icon: Icons.favorite,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(IconButtonM3E), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('renders all variants', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                IconButtonM3E(
                  icon: Icons.favorite,
                  variant: IconButtonVariant.standard,
                  onPressed: () {},
                ),
                IconButtonM3E(
                  icon: Icons.favorite,
                  variant: IconButtonVariant.filled,
                  onPressed: () {},
                ),
                IconButtonM3E(
                  icon: Icons.favorite,
                  variant: IconButtonVariant.tonal,
                  onPressed: () {},
                ),
                IconButtonM3E(
                  icon: Icons.favorite,
                  variant: IconButtonVariant.outlined,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(IconButtonM3E), findsNWidgets(4));
    });

    testWidgets('renders with custom colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconButtonM3E(
              icon: Icons.star,
              variant: IconButtonVariant.filled,
              backgroundColor: Colors.blue,
              color: Colors.white,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(IconButtonM3E), findsOneWidget);
    });
  });

  group('ExtendedFABM3E Basic Tests', () {
    testWidgets('renders extended FAB', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExtendedFABM3E(
              icon: Icons.edit,
              label: 'Edit',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(ExtendedFABM3E), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('renders in expanded and collapsed states', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ExtendedFABM3E(
                  icon: Icons.edit,
                  label: 'Edit',
                  expanded: true,
                  onPressed: () {},
                ),
                ExtendedFABM3E(
                  icon: Icons.edit,
                  label: 'Edit',
                  expanded: false,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(ExtendedFABM3E), findsNWidgets(2));
    });
  });

  group('FABMenuM3E Basic Tests', () {
    testWidgets('renders FAB menu', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FABMenuM3E(
              icon: Icons.add,
              items: [
                FABMenuItem(
                  icon: Icons.photo,
                  label: 'Photo',
                  onPressed: () {},
                ),
                FABMenuItem(
                  icon: Icons.video_library,
                  label: 'Video',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(FABMenuM3E), findsOneWidget);
    });

    testWidgets('renders with different directions', (WidgetTester tester) async {
      for (final direction in FABMenuDirection.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FABMenuM3E(
                icon: Icons.add,
                direction: direction,
                items: [
                  FABMenuItem(
                    icon: Icons.photo,
                    label: 'Photo',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(FABMenuM3E), findsOneWidget);

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });
  });

  group('FABMenuItem Tests', () {
    test('creates FABMenuItem with required fields', () {
      final item = FABMenuItem(
        icon: Icons.photo,
        label: 'Photo',
        onPressed: () {},
      );

      expect(item.icon, Icons.photo);
      expect(item.label, 'Photo');
      expect(item.onPressed, isNotNull);
    });

    test('creates FABMenuItem without label', () {
      final item = FABMenuItem(
        icon: Icons.photo,
        onPressed: () {},
      );

      expect(item.icon, Icons.photo);
      expect(item.label, isNull);
    });

    test('creates FABMenuItem with custom colors', () {
      final item = FABMenuItem(
        icon: Icons.photo,
        onPressed: () {},
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      );

      expect(item.backgroundColor, Colors.blue);
      expect(item.foregroundColor, Colors.white);
    });
  });

  group('Enum Tests', () {
    test('FABSize enum has all variants', () {
      expect(FABSize.values.length, 5);
      expect(FABSize.values, contains(FABSize.xs));
      expect(FABSize.values, contains(FABSize.small));
      expect(FABSize.values, contains(FABSize.regular));
      expect(FABSize.values, contains(FABSize.large));
      expect(FABSize.values, contains(FABSize.xl));
    });

    test('IconButtonVariant enum has all variants', () {
      expect(IconButtonVariant.values.length, 4);
      expect(IconButtonVariant.values, contains(IconButtonVariant.standard));
      expect(IconButtonVariant.values, contains(IconButtonVariant.filled));
      expect(IconButtonVariant.values, contains(IconButtonVariant.tonal));
      expect(IconButtonVariant.values, contains(IconButtonVariant.outlined));
    });

    test('FABMenuDirection enum has all variants', () {
      expect(FABMenuDirection.values.length, 4);
      expect(FABMenuDirection.values, contains(FABMenuDirection.up));
      expect(FABMenuDirection.values, contains(FABMenuDirection.down));
      expect(FABMenuDirection.values, contains(FABMenuDirection.left));
      expect(FABMenuDirection.values, contains(FABMenuDirection.right));
    });
  });

  group('FABSpec Tests', () {
    test('FABSpec contains correct properties', () {
      const spec = FABSpec(
        size: 56.0,
        iconSize: 24.0,
        cornerRadius: 16.0,
      );

      expect(spec.size, 56.0);
      expect(spec.iconSize, 24.0);
      expect(spec.cornerRadius, 16.0);
    });
  });
}

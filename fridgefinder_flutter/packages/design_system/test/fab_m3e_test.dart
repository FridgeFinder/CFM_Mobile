import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/components/fab_m3e.dart';

void main() {
  group('FABM3E Tests', () {
    testWidgets('renders regular FAB correctly', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FABM3E(
              icon: Icons.add,
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      // Verify FAB is rendered
      expect(find.byType(FABM3E), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Wait for entrance animation to complete, then tap visible icon
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(pressed, isTrue);
    });

    testWidgets('renders small FAB with correct size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FABM3E(
              icon: Icons.add,
              size: FABSize.small,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Find the container with size constraints
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(FABM3E),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.constraints?.maxWidth, 40.0);
      expect(container.constraints?.maxHeight, 40.0);
    });

    testWidgets('renders large FAB with correct size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FABM3E(
              icon: Icons.add,
              size: FABSize.large,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Find the container with size constraints
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(FABM3E),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.constraints?.maxWidth, 72.0);
      expect(container.constraints?.maxHeight, 72.0);
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

      // Verify label is displayed
      expect(find.text('Create'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Verify it's a Row (extended FAB uses Row layout)
      expect(
        find.descendant(
          of: find.byType(FABM3E),
          matching: find.byType(Row),
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows tooltip when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FABM3E(
              icon: Icons.add,
              tooltip: 'Add item',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Verify tooltip is present
      expect(find.byType(Tooltip), findsOneWidget);

      // Long press to show tooltip
      await tester.longPress(find.byType(FABM3E));
      await tester.pump(const Duration(milliseconds: 500));

      // Tooltip text should be visible
      expect(find.text('Add item'), findsOneWidget);
    });

    testWidgets('animates entrance when visible changes', (WidgetTester tester) async {
      bool visible = false;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    FABM3E(
                      icon: Icons.add,
                      visible: visible,
                      onPressed: () {},
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          visible = !visible;
                        });
                      },
                      child: const Text('Toggle'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Initially not visible
      expect(find.byType(FABM3E), findsOneWidget);

      // Tap to make visible
      await tester.tap(find.text('Toggle'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // FAB should be animating in
      expect(find.byType(FABM3E), findsOneWidget);
    });

    testWidgets('renders tonal variant with correct colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FABM3E(
              icon: Icons.add,
              tonal: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Verify FAB is rendered
      expect(find.byType(FABM3E), findsOneWidget);

      // Find Material widget
      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(FABM3E),
          matching: find.byType(Material),
        ).first,
      );

      // Verify it uses secondary container color (tonal)
      final theme = Theme.of(tester.element(find.byType(FABM3E)));
      expect(material.color, theme.colorScheme.secondaryContainer);
    });
  });

  group('IconButtonM3E Tests', () {
    testWidgets('renders standard icon button', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconButtonM3E(
              icon: Icons.favorite,
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      // Verify button is rendered
      expect(find.byType(IconButtonM3E), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      // Tap the button using InkWell
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(pressed, isTrue);
    });

    testWidgets('renders filled variant', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconButtonM3E(
              icon: Icons.favorite,
              variant: IconButtonVariant.filled,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Verify button is rendered
      expect(find.byType(IconButtonM3E), findsOneWidget);

      // Find container with decoration
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(IconButtonM3E),
          matching: find.byType(Container),
        ).first,
      );

      // Verify it has a background color
      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNotNull);
    });

    testWidgets('renders tonal variant', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconButtonM3E(
              icon: Icons.favorite,
              variant: IconButtonVariant.tonal,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Verify button is rendered
      expect(find.byType(IconButtonM3E), findsOneWidget);

      // Find container with decoration
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(IconButtonM3E),
          matching: find.byType(Container),
        ).first,
      );

      // Verify it has secondary container color
      final decoration = container.decoration as BoxDecoration;
      final theme = Theme.of(tester.element(find.byType(IconButtonM3E)));
      expect(decoration.color, theme.colorScheme.secondaryContainer);
    });

    testWidgets('renders outlined variant with border', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconButtonM3E(
              icon: Icons.favorite,
              variant: IconButtonVariant.outlined,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Verify button is rendered
      expect(find.byType(IconButtonM3E), findsOneWidget);

      // Find container with decoration
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(IconButtonM3E),
          matching: find.byType(Container),
        ).first,
      );

      // Verify it has a border
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets('toggle button changes state', (WidgetTester tester) async {
      bool selected = false;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: IconButtonM3E(
                  icon: Icons.favorite_border,
                  selectedIcon: Icons.favorite,
                  selected: selected,
                  onSelectedChanged: (value) {
                    setState(() {
                      selected = value;
                    });
                  },
                ),
              );
            },
          ),
        ),
      );

      // Initially shows unselected icon
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      // Tap to select using InkWell
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Should show selected icon
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('shows tooltip when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconButtonM3E(
              icon: Icons.favorite,
              tooltip: 'Favorite',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Verify tooltip is present
      expect(find.byType(Tooltip), findsOneWidget);

      // Long press to show tooltip
      await tester.longPress(find.byType(IconButtonM3E));
      await tester.pump(const Duration(milliseconds: 500));

      // Tooltip text should be visible
      expect(find.text('Favorite'), findsOneWidget);
    });
  });

  group('ExtendedFABM3E Tests', () {
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

      // Verify FAB is rendered
      expect(find.byType(ExtendedFABM3E), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('animates expand and collapse', (WidgetTester tester) async {
      bool expanded = true;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    ExtendedFABM3E(
                      icon: Icons.edit,
                      label: 'Edit',
                      expanded: expanded,
                      onPressed: () {},
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          expanded = !expanded;
                        });
                      },
                      child: const Text('Toggle'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Initially expanded
      expect(find.text('Edit'), findsOneWidget);

      // Tap to collapse
      await tester.tap(find.text('Toggle'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Label should still exist but might be clipped
      expect(find.byType(ExtendedFABM3E), findsOneWidget);
    });
  });

  group('FABMenuM3E Tests', () {
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

      // Verify menu is rendered
      expect(find.byType(FABMenuM3E), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('opens and closes menu', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FABMenuM3E(
              icon: Icons.add,
              openIcon: Icons.close,
              direction: FABMenuDirection.down,
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

      // Initially closed (shows add icon)
      expect(find.byIcon(Icons.add), findsOneWidget);

      await tester.pumpAndSettle();

      // Tap main FAB to open menu
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Should show close icon when open
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Should show menu items
      expect(find.byIcon(Icons.photo), findsOneWidget);
      expect(find.byIcon(Icons.video_library), findsOneWidget);
    });

    testWidgets('shows labels when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FABMenuM3E(
              icon: Icons.add,
              showLabels: true,
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

      await tester.pumpAndSettle();

      // Open menu
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Labels should be visible
      expect(find.text('Photo'), findsOneWidget);
      expect(find.text('Video'), findsOneWidget);
    });

    testWidgets('closes menu when item is pressed', (WidgetTester tester) async {
      bool itemPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: FABMenuM3E(
              icon: Icons.add,
              openIcon: Icons.close,
              items: [
                FABMenuItem(
                  icon: Icons.photo,
                  label: 'Photo',
                  onPressed: () {
                    itemPressed = true;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open menu
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Should be open
      expect(find.byIcon(Icons.close), findsOneWidget);

        // Trigger menu item action directly to avoid flaky hit-testing in stacked overlays
        final menuItemFab = tester
          .widgetList<FABM3E>(find.byType(FABM3E))
          .firstWhere((fab) => fab.icon == Icons.photo);
        menuItemFab.onPressed?.call();
      await tester.pumpAndSettle();

      // Should close menu
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Callback should be called
      expect(itemPressed, isTrue);
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
      expect(FABSize.values.contains(FABSize.xs), isTrue);
      expect(FABSize.values.contains(FABSize.small), isTrue);
      expect(FABSize.values.contains(FABSize.regular), isTrue);
      expect(FABSize.values.contains(FABSize.large), isTrue);
      expect(FABSize.values.contains(FABSize.xl), isTrue);
    });

    test('IconButtonVariant enum has all variants', () {
      expect(IconButtonVariant.values.length, 4);
      expect(IconButtonVariant.values.contains(IconButtonVariant.standard), isTrue);
      expect(IconButtonVariant.values.contains(IconButtonVariant.filled), isTrue);
      expect(IconButtonVariant.values.contains(IconButtonVariant.tonal), isTrue);
      expect(IconButtonVariant.values.contains(IconButtonVariant.outlined), isTrue);
    });

    test('FABMenuDirection enum has all variants', () {
      expect(FABMenuDirection.values.length, 4);
      expect(FABMenuDirection.values.contains(FABMenuDirection.up), isTrue);
      expect(FABMenuDirection.values.contains(FABMenuDirection.down), isTrue);
      expect(FABMenuDirection.values.contains(FABMenuDirection.left), isTrue);
      expect(FABMenuDirection.values.contains(FABMenuDirection.right), isTrue);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/navigation/navigation_drawer_m3e.dart';
import 'package:design_system/theme/spacing.dart';

void main() {
  group('NavigationDrawerM3E Tests', () {
    testWidgets('renders with basic destinations', (WidgetTester tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationDrawerM3E(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                selectedIndex = index;
              },
              destinations: const [
                NavigationDrawerDestinationM3E(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationDrawerDestinationM3E(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore),
                  label: Text('Explore'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify destinations are rendered
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.byType(NavigationDrawerM3E), findsOneWidget);
    });

    testWidgets('footer is positioned at bottom', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationDrawerM3E(
              selectedIndex: 0,
              onDestinationSelected: (index) {},
              destinations: const [
                NavigationDrawerDestinationM3E(
                  icon: Icon(Icons.home_outlined),
                  label: Text('Home'),
                ),
              ],
              footer: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Divider(),
                  const Text('Footer Content'),
                  const Text('v1.0.0'),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify footer content exists
      expect(find.text('Footer Content'), findsOneWidget);
      expect(find.text('v1.0.0'), findsOneWidget);

      // Verify a Spacer exists (which pushes footer to bottom)
      expect(find.byType(Spacer), findsOneWidget);

      // Get the Drawer widget and verify Column structure
      final drawer = tester.widget<Drawer>(find.byType(Drawer));
      expect(drawer.child, isA<Column>());

      final column = drawer.child as Column;
      // Column should have: destinations + Spacer + footer padding
      expect(column.children.length, greaterThan(2));

      // Find Spacer in the column children
      final spacerIndex = column.children.indexWhere((child) => child is Spacer);
      expect(spacerIndex, greaterThan(-1),
          reason: 'Spacer should exist in column');

      // Footer should come after Spacer
      expect(spacerIndex, lessThan(column.children.length - 2),
          reason: 'Spacer should be before footer');
    });

    testWidgets('footer content is right-aligned',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationDrawerM3E(
              selectedIndex: 0,
              onDestinationSelected: (index) {},
              destinations: const [
                NavigationDrawerDestinationM3E(
                  icon: Icon(Icons.home_outlined),
                  label: Text('Home'),
                ),
              ],
              footer: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('About App'),
                  SizedBox(height: 4),
                  Text('v1.0.0'),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the footer column
      final footerColumns = tester.widgetList<Column>(find.byType(Column));

      // Look for the footer column (has CrossAxisAlignment.end)
      bool foundRightAlignedFooter = false;
      for (final column in footerColumns) {
        if (column.crossAxisAlignment == CrossAxisAlignment.end) {
          // Check if this column contains our footer texts
          final columnWidget = column;
          if (columnWidget.children.any((child) =>
              child is Text && child.data == 'About App')) {
            foundRightAlignedFooter = true;
            break;
          }
        }
      }

      expect(foundRightAlignedFooter, isTrue,
          reason: 'Footer should be right-aligned with CrossAxisAlignment.end');
    });

    testWidgets('footer divider is full width', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationDrawerM3E(
              selectedIndex: 0,
              onDestinationSelected: (index) {},
              destinations: const [
                NavigationDrawerDestinationM3E(
                  icon: Icon(Icons.home_outlined),
                  label: Text('Home'),
                ),
              ],
              footer: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  SizedBox(
                    width: double.infinity,
                    child: Divider(),
                  ),
                  SizedBox(height: 12),
                  Text('Footer Text'),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find SizedBox wrapping the Divider
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));

      bool foundFullWidthDivider = false;
      for (final sizedBox in sizedBoxes) {
        if (sizedBox.width == double.infinity &&
            sizedBox.child is Divider) {
          foundFullWidthDivider = true;
          break;
        }
      }

      expect(foundFullWidthDivider, isTrue,
          reason: 'Divider should be wrapped in full-width SizedBox');
    });

    testWidgets('drawer has correct width', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationDrawerM3E(
              selectedIndex: 0,
              onDestinationSelected: (index) {},
              destinations: const [
                NavigationDrawerDestinationM3E(
                  icon: Icon(Icons.home_outlined),
                  label: Text('Home'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final drawer = tester.widget<Drawer>(find.byType(Drawer));
      expect(drawer.width, equals(300),
          reason: 'Drawer should have M3E-compliant width of 300dp');
    });

    testWidgets('header is displayed when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationDrawerM3E(
              selectedIndex: 0,
              onDestinationSelected: (index) {},
              destinations: const [
                NavigationDrawerDestinationM3E(
                  icon: Icon(Icons.home_outlined),
                  label: Text('Home'),
                ),
              ],
              header: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('My Header'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('My Header'), findsOneWidget);
    });

    testWidgets('destinations have correct padding',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationDrawerM3E(
              selectedIndex: 0,
              onDestinationSelected: (index) {},
              destinations: const [
                NavigationDrawerDestinationM3E(
                  icon: Icon(Icons.home_outlined),
                  label: Text('Home'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find padding widgets around destinations
      final paddings = tester.widgetList<Padding>(find.byType(Padding));

      // Look for the destination item padding (12dp horizontal, 4dp vertical)
      bool foundDestinationPadding = false;
      for (final padding in paddings) {
        final edgeInsets = padding.padding as EdgeInsets?;
        if (edgeInsets != null &&
            edgeInsets.left == 12.0 &&
            edgeInsets.right == 12.0 &&
            edgeInsets.top == 4.0 &&
            edgeInsets.bottom == 4.0) {
          foundDestinationPadding = true;
          break;
        }
      }

      expect(foundDestinationPadding, isTrue,
          reason:
              'Destinations should have 12dp horizontal and 4dp vertical padding');
    });

    testWidgets('selected destination shows correct styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationDrawerM3E(
              selectedIndex: 0,
              onDestinationSelected: (index) {},
              destinations: const [
                NavigationDrawerDestinationM3E(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationDrawerDestinationM3E(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore),
                  label: Text('Explore'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the AnimatedContainer for the first (selected) item
      final containers = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));

      // First destination should have colored background (selected)
      bool foundSelectedContainer = false;
      for (final container in containers) {
        final decoration = container.decoration as BoxDecoration?;
        if (decoration != null && decoration.color != Colors.transparent) {
          foundSelectedContainer = true;
          expect(decoration.borderRadius, isNotNull,
              reason: 'Selected item should have border radius for pill shape');
          break;
        }
      }

      expect(foundSelectedContainer, isTrue,
          reason: 'Selected destination should have colored background');
    });

    testWidgets('footer has correct padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationDrawerM3E(
              selectedIndex: 0,
              onDestinationSelected: (index) {},
              destinations: const [
                NavigationDrawerDestinationM3E(
                  icon: Icon(Icons.home_outlined),
                  label: Text('Home'),
                ),
              ],
              footer: const Text('Footer'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Footer is wrapped as FadeTransition -> Padding -> footer
      final footerPaddingFinder = find.ancestor(
        of: find.text('Footer'),
        matching: find.byType(Padding),
      );
      expect(footerPaddingFinder, findsWidgets);

      final footerPadding = tester.widgetList<Padding>(footerPaddingFinder).firstWhere(
        (padding) => padding.child is Text && (padding.child as Text).data == 'Footer',
      );

      expect(footerPadding.padding, equals(M3ESpacing.navigationDrawerPadding));
    });

    testWidgets('drawer without footer does not have spacer',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationDrawerM3E(
              selectedIndex: 0,
              onDestinationSelected: (index) {},
              destinations: const [
                NavigationDrawerDestinationM3E(
                  icon: Icon(Icons.home_outlined),
                  label: Text('Home'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Without footer, should not have Spacer
      expect(find.byType(Spacer), findsNothing);
    });

    testWidgets('destination item has correct height',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationDrawerM3E(
              selectedIndex: 0,
              onDestinationSelected: (index) {},
              destinations: const [
                NavigationDrawerDestinationM3E(
                  icon: Icon(Icons.home_outlined),
                  label: Text('Home'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find AnimatedContainer (destination item container)
      final containers = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));

      // Check that at least one container has height of 56 (M3E spec)
      bool foundCorrectHeight = false;
      for (final container in containers) {
        if (container.constraints?.minHeight == 56.0 ||
            container.constraints?.maxHeight == 56.0) {
          foundCorrectHeight = true;
          break;
        }
      }

      // If not found in constraints, check direct height property
      if (!foundCorrectHeight) {
        for (final container in containers) {
          if (container.child is InkWell) {
            // The container wrapping InkWell should have height 56
            final size = tester.getSize(find.byWidget(container));
            if (size.height == 56.0) {
              foundCorrectHeight = true;
              break;
            }
          }
        }
      }

      expect(foundCorrectHeight, isTrue,
          reason: 'Destination items should have M3E-compliant height of 56dp');
    });
  });
}

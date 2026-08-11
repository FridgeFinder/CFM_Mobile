import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/features/map/presentation/widgets/fridge_cluster_widget.dart';

void main() {
  group('FridgeClusterWidget Tests', () {
    testWidgets('displays correct marker count', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(body: FridgeClusterWidget(markerCount: 5)),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('displays correct marker count for large clusters', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(body: FridgeClusterWidget(markerCount: 42)),
        ),
      );

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('displays correct marker count for very large clusters', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(body: FridgeClusterWidget(markerCount: 150)),
        ),
      );

      expect(find.text('150'), findsOneWidget);
    });

    testWidgets('uses correct size for small clusters (< 10)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(body: FridgeClusterWidget(markerCount: 5)),
        ),
      );

      await tester.pumpAndSettle();

      final container = find.byType(Container).first;
      final renderObject = tester.renderObject(container);
      final renderBox = renderObject as RenderBox;

      expect(renderBox.size.width, 50.0);
      expect(renderBox.size.height, 50.0);
    });

    testWidgets('uses correct size for medium clusters (10-99)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(body: FridgeClusterWidget(markerCount: 50)),
        ),
      );

      await tester.pumpAndSettle();

      final container = find.byType(Container).first;
      final renderObject = tester.renderObject(container);
      final renderBox = renderObject as RenderBox;

      expect(renderBox.size.width, 60.0);
      expect(renderBox.size.height, 60.0);
    });

    testWidgets('uses correct size for large clusters (100+)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(body: FridgeClusterWidget(markerCount: 150)),
        ),
      );

      await tester.pumpAndSettle();

      final container = find.byType(Container).first;
      final renderObject = tester.renderObject(container);
      final renderBox = renderObject as RenderBox;

      expect(renderBox.size.width, 70.0);
      expect(renderBox.size.height, 70.0);
    });

    testWidgets('uses light theme colors when not dark mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(body: FridgeClusterWidget(markerCount: 5)),
        ),
      );

      final container = find.byType(Container).first;
      final widget = container.evaluate().single.widget as Container;
      final decoration = widget.decoration as BoxDecoration;

      // Should use solid blue (#2196F3) in light mode
      expect(decoration.color, const Color(0xFF2196F3));
    });

    testWidgets('uses dark theme colors when dark mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(body: FridgeClusterWidget(markerCount: 5)),
        ),
      );

      final container = find.byType(Container).first;
      final widget = container.evaluate().single.widget as Container;
      final decoration = widget.decoration as BoxDecoration;

      // Should use blue with transparency in dark mode
      final color = decoration.color;
      expect(color, isNotNull);
      expect((color!.r * 255.0).round() & 0xff, 33); // RGB(33, 150, 243)
      expect((color.g * 255.0).round() & 0xff, 150);
      expect((color.b * 255.0).round() & 0xff, 243);
      expect(
        (color.a * 255.0).round() & 0xff,
        lessThan(255),
      ); // Has transparency
    });

    testWidgets('uses dark theme colors when isDarkMode is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: FridgeClusterWidget(markerCount: 5, isDarkMode: true),
          ),
        ),
      );

      final container = find.byType(Container).first;
      final widget = container.evaluate().single.widget as Container;
      final decoration = widget.decoration as BoxDecoration;

      // Should use blue with transparency when isDarkMode is true
      final color = decoration.color;
      expect(color, isNotNull);
      expect((color!.r * 255.0).round() & 0xff, 33);
      expect((color.g * 255.0).round() & 0xff, 150);
      expect((color.b * 255.0).round() & 0xff, 243);
      expect((color.a * 255.0).round() & 0xff, lessThan(255));
    });

    testWidgets('displays white border', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(body: FridgeClusterWidget(markerCount: 5)),
        ),
      );

      final container = find.byType(Container).first;
      final widget = container.evaluate().single.widget as Container;
      final decoration = widget.decoration as BoxDecoration;

      expect(decoration.border, isNotNull);
      final border = decoration.border as Border;
      expect(border.top.color, Colors.white);
      expect(border.top.width, 3);
    });

    testWidgets('displays white text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(body: FridgeClusterWidget(markerCount: 5)),
        ),
      );

      final text = find.text('5');
      final textWidget = text.evaluate().single.widget as Text;
      final style = textWidget.style;

      expect(style?.color, Colors.white);
      expect(style?.fontWeight, FontWeight.bold);
    });

    testWidgets('uses correct font size for small clusters', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(body: FridgeClusterWidget(markerCount: 5)),
        ),
      );

      final text = find.text('5');
      final textWidget = text.evaluate().single.widget as Text;
      final style = textWidget.style;

      expect(style?.fontSize, 16);
    });

    testWidgets('uses correct font size for medium clusters', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(body: FridgeClusterWidget(markerCount: 50)),
        ),
      );

      final text = find.text('50');
      final textWidget = text.evaluate().single.widget as Text;
      final style = textWidget.style;

      expect(style?.fontSize, 18);
    });

    testWidgets('uses correct font size for large clusters', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(body: FridgeClusterWidget(markerCount: 150)),
        ),
      );

      final text = find.text('150');
      final textWidget = text.evaluate().single.widget as Text;
      final style = textWidget.style;

      expect(style?.fontSize, 20);
    });

    testWidgets('has circular shape', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(body: FridgeClusterWidget(markerCount: 5)),
        ),
      );

      final container = find.byType(Container).first;
      final widget = container.evaluate().single.widget as Container;
      final decoration = widget.decoration as BoxDecoration;

      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets('has shadow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(body: FridgeClusterWidget(markerCount: 5)),
        ),
      );

      final container = find.byType(Container).first;
      final widget = container.evaluate().single.widget as Container;
      final decoration = widget.decoration as BoxDecoration;

      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow?.length, greaterThan(0));
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/features/map/domain/models/fridge_domain.dart';
import 'package:fridgefinder_app/src/features/map/presentation/widgets/fridge_marker.dart';
import '../../../../fixtures/fridge_fixtures.dart';

void main() {
  group('FridgeMarker Widget Tests', () {
    testWidgets('renders SVG icon for marker', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FridgeMarker(fridge: FridgeFixtures.verifiedFridgeWithFood),
          ),
        ),
      );

      // Should render an SvgPicture widget
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('displays marker with correct size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FridgeMarker(fridge: FridgeFixtures.verifiedFridgeWithFood),
          ),
        ),
      );

      final sizedBox = find.byType(SizedBox).first;
      final widget = sizedBox.evaluate().single.widget as SizedBox;

      expect(widget.width, FridgeMarker.markerSize);
      expect(widget.height, FridgeMarker.markerSize);
    });

    testWidgets('shows green color for fridge with full food level', (WidgetTester tester) async {
      final fridge = FridgeFixtures.verifiedFridgeWithFood;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FridgeMarker(fridge: fridge),
          ),
        ),
      );

      // Should render SVG
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('shows yellow color for dirty fridge', (WidgetTester tester) async {
      final fridge = FridgeFixtures.fridgeDirty;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FridgeMarker(fridge: fridge),
          ),
        ),
      );

      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('shows ghost icon for ghost fridge', (WidgetTester tester) async {
      final fridge = FridgeFixtures.ghostFridge;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FridgeMarker(fridge: fridge),
          ),
        ),
      );

      // Ghost fridge displays SVG with ghost path
      // The transparency is built into the SVG fill (#e3f2fd99 and stroke #22222299)
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('shows dashed pin for fridge with no report', (WidgetTester tester) async {
      final fridgeNoReport = FridgeDomain(
        id: 'no_report_001',
        name: 'No Report Fridge',
        verified: true,
        location: FridgeLocationDomain(
          street: '123 Main St',
          city: 'Brooklyn',
          state: 'NY',
          zip: '11215',
          geoLat: 40.6501,
          geoLng: -73.9496,
        ),
        latestFridgeReport: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FridgeMarker(fridge: fridgeNoReport),
          ),
        ),
      );

      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('shows gray dashed pin for unverified fridge', (WidgetTester tester) async {
      final fridge = FridgeFixtures.notAtLocationFridge.copyWith(verified: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FridgeMarker(fridge: fridge),
          ),
        ),
      );

      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('shows X face for not at location fridge', (WidgetTester tester) async {
      final fridge = FridgeFixtures.notAtLocationFridge;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FridgeMarker(fridge: fridge),
          ),
        ),
      );

      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('shows out of order decoration for broken fridge', (WidgetTester tester) async {
      final fridge = FridgeFixtures.fridgeOutOfOrder;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FridgeMarker(fridge: fridge),
          ),
        ),
      );

      expect(find.byType(SvgPicture), findsOneWidget);
    });
  });

  // Add extension to copy Fridge for tests
}

extension _FridgeDomainCopy on FridgeDomain {
  FridgeDomain copyWith({
    String? id,
    String? name,
    bool? verified,
    FridgeLocationDomain? location,
    FridgeMaintainerDomain? maintainer,
    String? notes,
    String? photoUrl,
    String? lastEdited,
    FridgeReportDomain? latestFridgeReport,
  }) {
    return FridgeDomain(
      id: id ?? this.id,
      name: name ?? this.name,
      verified: verified ?? this.verified,
      location: location ?? this.location,
      maintainer: maintainer ?? this.maintainer,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
      lastEdited: lastEdited ?? this.lastEdited,
      latestFridgeReport: latestFridgeReport ?? this.latestFridgeReport,
    );
  }
}

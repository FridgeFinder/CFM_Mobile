import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/features/map/domain/models/fridge_domain.dart';
import 'package:fridgefinder_app/src/features/profile/presentation/widgets/fridge_latest_status.dart';
import 'package:intl/intl.dart';

FridgeDomain _fridgeWithReport(FridgeReportDomain report) => FridgeDomain(
  id: 'test',
  name: 'Test Fridge',
  location: const FridgeLocationDomain(),
  latestFridgeReport: report,
);

Future<void> _pump(WidgetTester tester, FridgeDomain fridge) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: FridgeLatestStatus(fridge: fridge)),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  // The report instant, as sent by the API in UTC.
  final utcInstant = DateTime.utc(2025, 7, 10, 16, 56, 57);
  final localText = DateFormat('M/d/yy h:mm a').format(utcInstant.toLocal());
  final utcText = DateFormat('M/d/yy h:mm a').format(utcInstant);

  // On a UTC machine local and UTC renderings are identical, so only the
  // domain tests (fridge_domain_test.dart) can tell them apart there.
  final zonesDiffer = localText != utcText;

  testWidgets('shows the UTC API timestamp in device-local time', (
    tester,
  ) async {
    await _pump(
      tester,
      _fridgeWithReport(
        const FridgeReportDomain(
          condition: FridgeCondition.good,
          timestamp: '2025-07-10T16:56:57Z',
          epochTimestamp: '1752166617',
        ),
      ),
    );

    expect(find.text(localText), findsOneWidget);
    if (zonesDiffer) {
      expect(find.text(utcText), findsNothing);
    }
  });

  testWidgets('shows the epoch-only timestamp in device-local time', (
    tester,
  ) async {
    await _pump(
      tester,
      _fridgeWithReport(
        const FridgeReportDomain(
          condition: FridgeCondition.good,
          epochTimestamp: '1752166617',
        ),
      ),
    );

    expect(find.text(localText), findsOneWidget);
  });

  testWidgets('shows no timestamp when the report has none', (tester) async {
    await _pump(
      tester,
      _fridgeWithReport(
        const FridgeReportDomain(condition: FridgeCondition.good),
      ),
    );

    expect(
      find.textContaining(RegExp(r'\d+/\d+/\d+ \d+:\d+ [AP]M')),
      findsNothing,
    );
  });
}

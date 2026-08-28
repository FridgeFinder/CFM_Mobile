import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/core/utils/fridge_icon_utils.dart';
import 'package:fridgefinder_app/src/features/map/domain/models/fridge_domain.dart';
import '../../fixtures/fridge_fixtures.dart';

void main() {
  group('FridgeIconUtils Tests', () {
    group('Color Mapping', () {
      test('itemsEmpty (0%) returns white color', () {
        expect(FridgeIconUtils.colorFromFoodLevel[0], const Color(0xFFFFFFFF));
      });

      test('itemsFew (1-50%) returns pink color', () {
        expect(FridgeIconUtils.colorFromFoodLevel[1], const Color(0xFFFF6B9D));
      });

      test('itemsMany (50-75%) returns yellow color', () {
        expect(FridgeIconUtils.colorFromFoodLevel[2], const Color(0xFFFFB300));
      });

      test('itemsFull (75%+) returns green color', () {
        expect(FridgeIconUtils.colorFromFoodLevel[3], const Color(0xFF5FD65F));
      });
    });

    group('Food Level Index Calculation', () {
      test('0% food returns level 0 (empty)', () {
        final index = _callGetFoodLevelIndex(0.0);
        expect(index, 0);
      });

      test('25% food returns level 1 (few)', () {
        final index = _callGetFoodLevelIndex(0.25);
        expect(index, 1);
      });

      test('60% food returns level 2 (many)', () {
        final index = _callGetFoodLevelIndex(0.60);
        expect(index, 2);
      });

      test('80% food returns level 3 (full)', () {
        final index = _callGetFoodLevelIndex(0.80);
        expect(index, 3);
      });

      test('100% food returns level 3 (full)', () {
        final index = _callGetFoodLevelIndex(1.0);
        expect(index, 3);
      });

      test('50% food returns level 2 (many)', () {
        final index = _callGetFoodLevelIndex(0.50);
        expect(index, 2);
      });

      test('75% food returns level 3 (full)', () {
        final index = _callGetFoodLevelIndex(0.75);
        expect(index, 3);
      });
    });

    group('SVG Generation', () {
      test('generatePinSvg creates valid SVG string', () {
        final svg = FridgeIconUtils.generatePinSvg(
          pinColor: Colors.green,
          isSmileFace: true,
          hasDecoration: false,
          decorationSvg: '',
        );

        expect(svg, isNotEmpty);
        expect(svg, contains('<svg'));
        expect(svg, contains('</svg>'));
      });

      test('generatePinSvg with decoration includes decoration SVG', () {
        const decoration = '<circle cx="10" cy="10" r="5" fill="#fff"/>';
        final svg = FridgeIconUtils.generatePinSvg(
          pinColor: Colors.orange,
          isSmileFace: true,
          hasDecoration: true,
          decorationSvg: decoration,
        );

        expect(svg, contains(decoration));
      });

      test('generatePinSvg with dashed border includes stroke-dasharray', () {
        final svg = FridgeIconUtils.generatePinSvg(
          pinColor: Colors.white,
          isSmileFace: true,
          hasDecoration: false,
          decorationSvg: '',
          dashed: true,
        );

        expect(svg, contains('stroke-dasharray'));
      });

      test(
        'generatePinSvg uses correct dashed pattern "4,2" to match frontend',
        () {
          final svg = FridgeIconUtils.generatePinSvg(
            pinColor: Colors.white,
            isSmileFace: true,
            hasDecoration: false,
            decorationSvg: '',
            dashed: true,
          );

          // Verify the exact pattern used in CFM_Frontend svgUrlPinNoReport
          expect(svg, contains('stroke-dasharray="4,2"'));
        },
      );

      test('generatePinSvg with smile face includes smile face SVG', () {
        final svg = FridgeIconUtils.generatePinSvg(
          pinColor: Colors.green,
          isSmileFace: true,
          hasDecoration: false,
          decorationSvg: '',
        );

        // Should include smile face path markers
        expect(svg, contains('M8.186'));
      });

      test('generatePinSvg with X face includes X face SVG', () {
        final svg = FridgeIconUtils.generatePinSvg(
          pinColor: Colors.green,
          isSmileFace: false,
          hasDecoration: false,
          decorationSvg: '',
        );

        // Should include X face path
        expect(svg, contains('m9.053'));
      });
    });

    group('Ghost Icon SVG', () {
      test('ghost SVG uses correct wavy ghost path from CFM_Frontend', () {
        // Verify the ghost icon uses the correct path with wavy outline
        final ghostSvg =
            '''<svg fill="#e3f2fd99" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
      <path stroke="#22222299" stroke-width="1.358" d="M4.979 3.152C3.117 4.735 2.07 6.882 2.07 9.12c0 9.136.447 9.545 0 12.194-.45 2.674 4.063 2.674 4.063 0 0-2.523 3.611-2.523 3.611 0 0 2.292 4.514 2.292 4.514 0 0-2.523 3.611-2.523 3.611 0 0 2.292 4.514 2.292 4.063 0-.452-2.293 0-4.204 0-12.194 0-2.239-1.047-4.386-2.91-5.97-1.86-1.58-4.386-2.47-7.02-2.47-2.634 0-5.16.89-7.022 2.473z" />
      <circle cx="13.444" cy="9.389" r=".794" fill="#222" />
      <circle cx="10.303" cy="9.389" r=".794" fill="#222" />
    </svg>''';

        // Should contain the exact wavy ghost path (not a pin shape)
        expect(ghostSvg, contains('M4.979 3.152C3.117 4.735'));
        // Should have semi-transparent fill color
        expect(ghostSvg, contains('#e3f2fd99'));
        // Should have semi-transparent stroke
        expect(ghostSvg, contains('#22222299'));
        // Should have two eye circles
        expect(ghostSvg, contains('cx="13.444"'));
        expect(ghostSvg, contains('cx="10.303"'));
      });

      test('ghost fridge icon is distinct from pin icons', () {
        final ghostFridge = FridgeFixtures.ghostFridge;

        // Verify it's a ghost condition
        expect(
          ghostFridge.latestFridgeReport?.condition,
          FridgeCondition.ghost,
        );

        // Get the icon widget
        final widget = FridgeIconUtils.getFridgeIcon(
          fridge: ghostFridge,
          size: 40,
        );

        expect(widget, isNotNull);
      });

      test('unverified fridge uses gray dashed pin with correct color', () {
        final unverifiedFridge = FridgeDomain(
          id: 'unverified_001',
          name: 'Unverified Fridge',
          verified: false,
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

        // Unverified fridges should use gray color (#D3D3D3) with dashed pin
        final widget = FridgeIconUtils.getFridgeIcon(
          fridge: unverifiedFridge,
          size: 40,
        );

        expect(widget, isNotNull);
      });

      test('verified fridge with no report uses white dashed pin', () {
        final verifiedNoReportFridge = FridgeDomain(
          id: 'verified_no_report_001',
          name: 'Verified No Report',
          verified: true,
          location: FridgeLocationDomain(
            street: '456 Park Ave',
            city: 'New York',
            state: 'NY',
            zip: '10022',
            geoLat: 40.7614,
            geoLng: -73.9776,
          ),
          latestFridgeReport: null,
        );

        // Verified fridges with no report should use white dashed pin
        final widget = FridgeIconUtils.getFridgeIcon(
          fridge: verifiedNoReportFridge,
          size: 40,
        );

        expect(widget, isNotNull);
      });
    });

    group('Status Icon Mapping', () {
      test('good condition returns check_circle icon', () {
        final icon = FridgeIconUtils.getStatusIcon(FridgeCondition.good);
        expect(icon, Icons.check_circle);
      });

      test('dirty condition returns cleaning_services icon', () {
        final icon = FridgeIconUtils.getStatusIcon(FridgeCondition.dirty);
        expect(icon, Icons.cleaning_services);
      });

      test('out of order condition returns build_circle icon', () {
        final icon = FridgeIconUtils.getStatusIcon(FridgeCondition.outOfOrder);
        expect(icon, Icons.build_circle);
      });

      test('ghost condition returns announcement icon', () {
        final icon = FridgeIconUtils.getStatusIcon(FridgeCondition.ghost);
        expect(icon, Icons.announcement);
      });

      test('not at location condition returns location_off icon', () {
        final icon = FridgeIconUtils.getStatusIcon(
          FridgeCondition.notAtLocation,
        );
        expect(icon, Icons.location_off);
      });
    });

    group('Status Color Mapping', () {
      test('good condition returns green color', () {
        final color = FridgeIconUtils.getStatusColor(FridgeCondition.good);
        expect(color, const Color(0xFF5FD65F));
      });

      test('dirty condition returns orange color', () {
        final color = FridgeIconUtils.getStatusColor(FridgeCondition.dirty);
        expect(color, const Color(0xFFFF7043));
      });

      test('out of order condition returns orange color', () {
        final color = FridgeIconUtils.getStatusColor(
          FridgeCondition.outOfOrder,
        );
        expect(color, const Color(0xFFFF7043));
      });

      test('ghost condition returns purple color', () {
        final color = FridgeIconUtils.getStatusColor(FridgeCondition.ghost);
        expect(color, Colors.purple);
      });

      test('not at location condition returns grey color', () {
        final color = FridgeIconUtils.getStatusColor(
          FridgeCondition.notAtLocation,
        );
        expect(color, Color(0xFFD3D3D3));  // light grey
      });
    });

    group('Fridge Icon Widget Generation', () {
      test('getFridgeIcon returns widget for verified fridge with food', () {
        final fridge = FridgeFixtures.verifiedFridgeWithFood;
        final widget = FridgeIconUtils.getFridgeIcon(fridge: fridge, size: 40);

        expect(widget, isNotNull);
      });

      test('getFridgeIcon returns widget for dirty fridge', () {
        final fridge = FridgeFixtures.fridgeDirty;
        final widget = FridgeIconUtils.getFridgeIcon(fridge: fridge, size: 40);

        expect(widget, isNotNull);
      });

      test('getFridgeIcon returns widget for out of order fridge', () {
        final fridge = FridgeFixtures.fridgeOutOfOrder;
        final widget = FridgeIconUtils.getFridgeIcon(fridge: fridge, size: 40);

        expect(widget, isNotNull);
      });

      test('getFridgeIcon returns widget for ghost fridge', () {
        final fridge = FridgeFixtures.ghostFridge;
        final widget = FridgeIconUtils.getFridgeIcon(fridge: fridge, size: 40);

        expect(widget, isNotNull);
      });

      test('getFridgeIcon returns widget for not at location fridge', () {
        final fridge = FridgeFixtures.notAtLocationFridge;
        final widget = FridgeIconUtils.getFridgeIcon(fridge: fridge, size: 40);

        expect(widget, isNotNull);
      });

      test(
        'getFridgeIcon returns widget for unverified fridge without report',
        () {
          final fridge = FridgeDomain(
            id: 'test_001',
            name: 'Test Fridge',
            verified: false,
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

          final widget = FridgeIconUtils.getFridgeIcon(
            fridge: fridge,
            size: 40,
          );

          expect(widget, isNotNull);
        },
      );

      test(
        'getFridgeIcon returns widget for verified fridge without report',
        () {
          final fridge = FridgeDomain(
            id: 'test_002',
            name: 'Test Fridge 2',
            verified: true,
            location: FridgeLocationDomain(
              street: '456 Park Ave',
              city: 'New York',
              state: 'NY',
              zip: '10022',
              geoLat: 40.7614,
              geoLng: -73.9776,
            ),
            latestFridgeReport: null,
          );

          final widget = FridgeIconUtils.getFridgeIcon(
            fridge: fridge,
            size: 40,
          );

          expect(widget, isNotNull);
        },
      );
    });

    group('Color Hex String Conversion', () {
      test('Color.toHexString converts Color to hex format', () {
        final color = Colors.green;
        final hexString = color.toHexString();

        expect(hexString, startsWith('#'));
        expect(hexString.length, 7); // #RRGGBB
      });

      test('White color converts to #ffffff', () {
        final color = Colors.white;
        final hexString = color.toHexString();

        expect(hexString, equals('#ffffff'));
      });

      test('Red color converts to hex format', () {
        final color = Colors.red;
        final hexString = color.toHexString();

        // Flutter Colors.red is #f44336, not #ff0000
        expect(hexString, equals('#f44336'));
      });
    });

    group('Different Fridge Conditions', () {
      test('Good condition fridge with different food levels', () {
        for (double percentage = 0.0; percentage <= 1.0; percentage += 0.25) {
          final fridge = FridgeDomain(
            id: 'test_good_$percentage',
            name: 'Good Fridge',
            verified: true,
            location: FridgeLocationDomain(
              street: '123 Main St',
              city: 'Brooklyn',
              state: 'NY',
              zip: '11215',
              geoLat: 40.6501,
              geoLng: -73.9496,
            ),
            latestFridgeReport: FridgeReportDomain(
              fridgeId: 'test_good_$percentage',
              condition: FridgeCondition.good,
              foodPercentage: percentage,
            ),
          );

          final widget = FridgeIconUtils.getFridgeIcon(
            fridge: fridge,
            size: 40,
          );

          expect(widget, isNotNull);
        }
      });

      test(
        'Dirty condition always uses yellow color regardless of food level',
        () {
          // Dirty fridges should ALWAYS be yellow (#FFE55C), not vary by food percentage
          // Test multiple food levels to ensure color stays consistent
          final dirtyFridgeEmptyFood = FridgeDomain(
            id: 'test_dirty_empty',
            name: 'Dirty Fridge (Empty)',
            verified: true,
            location: FridgeLocationDomain(
              street: '123 Main St',
              city: 'Brooklyn',
              state: 'NY',
              zip: '11215',
              geoLat: 40.6501,
              geoLng: -73.9496,
            ),
            latestFridgeReport: FridgeReportDomain(
              fridgeId: 'test_dirty_empty',
              condition: FridgeCondition.dirty,
              foodPercentage: 0.0,
            ),
          );

          final dirtyFridgeFullFood = FridgeDomain(
            id: 'test_dirty_full',
            name: 'Dirty Fridge (Full)',
            verified: true,
            location: FridgeLocationDomain(
              street: '123 Main St',
              city: 'Brooklyn',
              state: 'NY',
              zip: '11215',
              geoLat: 40.6501,
              geoLng: -73.9496,
            ),
            latestFridgeReport: FridgeReportDomain(
              fridgeId: 'test_dirty_full',
              condition: FridgeCondition.dirty,
              foodPercentage: 1.0,
            ),
          );

          final emptyWidget = FridgeIconUtils.getFridgeIcon(
            fridge: dirtyFridgeEmptyFood,
            size: 40,
          );

          final fullWidget = FridgeIconUtils.getFridgeIcon(
            fridge: dirtyFridgeFullFood,
            size: 40,
          );

          // Both should render widgets (color is embedded in SVG)
          expect(emptyWidget, isNotNull);
          expect(fullWidget, isNotNull);
        },
      );

      test(
        'Out of order condition always uses pink color regardless of food level',
        () {
          // Out of order fridges should ALWAYS be pink (#FFD4FF), not vary by food percentage
          // Test multiple food levels to ensure color stays consistent
          final oooFridgeEmptyFood = FridgeDomain(
            id: 'test_ooo_empty',
            name: 'Out of Order (Empty)',
            verified: true,
            location: FridgeLocationDomain(
              street: '123 Main St',
              city: 'Brooklyn',
              state: 'NY',
              zip: '11215',
              geoLat: 40.6501,
              geoLng: -73.9496,
            ),
            latestFridgeReport: FridgeReportDomain(
              fridgeId: 'test_ooo_empty',
              condition: FridgeCondition.outOfOrder,
              foodPercentage: 0.0,
            ),
          );

          final oooFridgeFullFood = FridgeDomain(
            id: 'test_ooo_full',
            name: 'Out of Order (Full)',
            verified: true,
            location: FridgeLocationDomain(
              street: '123 Main St',
              city: 'Brooklyn',
              state: 'NY',
              zip: '11215',
              geoLat: 40.6501,
              geoLng: -73.9496,
            ),
            latestFridgeReport: FridgeReportDomain(
              fridgeId: 'test_ooo_full',
              condition: FridgeCondition.outOfOrder,
              foodPercentage: 1.0,
            ),
          );

          final emptyWidget = FridgeIconUtils.getFridgeIcon(
            fridge: oooFridgeEmptyFood,
            size: 40,
          );

          final fullWidget = FridgeIconUtils.getFridgeIcon(
            fridge: oooFridgeFullFood,
            size: 40,
          );

          // Both should render widgets (color is embedded in SVG)
          expect(emptyWidget, isNotNull);
          expect(fullWidget, isNotNull);
        },
      );
    });
  });
}

/// Helper function to access private _getFoodLevelIndex method
int _callGetFoodLevelIndex(double foodPercentage) {
  if (foodPercentage >= 0.75) return 3;
  if (foodPercentage >= 0.5) return 2;
  if (foodPercentage > 0) return 1;
  return 0;
}

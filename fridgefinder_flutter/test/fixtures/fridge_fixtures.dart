import 'package:fridgefinder_app/src/features/map/domain/models/fridge_domain.dart';

/// Test fixtures for Fridge domain model
/// Based on real FridgeFinder API response examples
class FridgeFixtures {
  /// Sample fridge from real API: Living Gallery
  static final verifiedFridgeWithFood = FridgeDomain(
    id: 'livinggallery',
    name: 'Living Gallery',
    verified: true,
    location: FridgeLocationDomain(
      street: '1094 Broadway',
      city: 'New York',
      state: 'NY',
      zip: '11221',
      geoLat: 40.694207,
      geoLng: -73.930599,
    ),
    maintainer: FridgeMaintainerDomain(
      instagram: 'https://www.instagram.com/the_living_gallery',
      website: 'http://linktr.ee/Thelivinggallery',
    ),
    photoUrl: 'https://community-fridge-map-images-prod.s3.amazonaws.com/96c3a513-17b3-4760-983b-3ae7525d5deb.webp',
    lastEdited: '1667513900',
    latestFridgeReport: FridgeReportDomain(
      fridgeId: 'livinggallery',
      condition: FridgeCondition.good,
      foodPercentage: 1.0,
      notes: 'Fridge has been cleaned',
      epochTimestamp: '1752166617',
      timestamp: '2025-07-10T16:56:57Z',
    ),
  );

  /// Sample fridge from real API: B'ShERT NYC Fridge
  static final notAtLocationFridge = FridgeDomain(
    id: 'bshertnycfridge',
    name: 'B\'ShERT NYC Fridge',
    verified: false,
    location: FridgeLocationDomain(
      street: '1596 Church Ave',
      city: 'Brooklyn',
      state: 'NY',
      zip: '11226',
      geoLat: 40.648444,
      geoLng: -73.965528,
    ),
    maintainer: FridgeMaintainerDomain(
      instagram: 'https://www.instagram.com/onelovecommunityfridge/',
    ),
    photoUrl: 'https://community-fridge-map-images-prod.s3.amazonaws.com/61dac313-d8d9-413c-ba93-e543dd9c3a82.webp',
    lastEdited: '1734389815',
    latestFridgeReport: FridgeReportDomain(
      fridgeId: 'bshertnycfridge',
      condition: FridgeCondition.notAtLocation,
      foodPercentage: 0.0,
      notes: 'as of last night',
      epochTimestamp: '1758155742',
      timestamp: '2025-09-18T00:35:42Z',
    ),
  );

  /// Sample fridge with dirty condition
  static final fridgeDirty = FridgeDomain(
    id: 'dirty_fridge_001',
    name: 'Test Dirty Fridge',
    verified: false,
    location: FridgeLocationDomain(
      street: '123 Main St',
      city: 'Brooklyn',
      state: 'NY',
      zip: '11215',
      geoLat: 40.6501,
      geoLng: -73.9496,
    ),
    maintainer: FridgeMaintainerDomain(
      name: 'Community Volunteer',
      email: 'volunteer@example.com',
    ),
    latestFridgeReport: FridgeReportDomain(
      fridgeId: 'dirty_fridge_001',
      condition: FridgeCondition.dirty,
      foodPercentage: 0.3,
      notes: 'Needs cleaning',
      epochTimestamp: '1751900400',
      timestamp: '2025-07-07T12:00:00Z',
    ),
  );

  /// Sample fridge that is out of order
  static final fridgeOutOfOrder = FridgeDomain(
    id: 'broken_fridge_001',
    name: 'Broken Fridge',
    verified: false,
    location: FridgeLocationDomain(
      street: '456 Park Ave',
      city: 'New York',
      state: 'NY',
      zip: '10022',
      geoLat: 40.7614,
      geoLng: -73.9776,
    ),
    latestFridgeReport: FridgeReportDomain(
      fridgeId: 'broken_fridge_001',
      condition: FridgeCondition.outOfOrder,
      foodPercentage: 0.0,
      notes: 'Compressor not working',
      epochTimestamp: '1751814000',
      timestamp: '2025-07-06T12:00:00Z',
    ),
  );

  /// Sample ghost fridge (no longer at location)
  static final ghostFridge = FridgeDomain(
    id: 'ghost_fridge_001',
    name: 'Ghost Fridge',
    verified: false,
    location: FridgeLocationDomain(
      street: '789 Elm St',
      city: 'Queens',
      state: 'NY',
      zip: '11375',
      geoLat: 40.7282,
      geoLng: -73.8648,
    ),
    latestFridgeReport: FridgeReportDomain(
      fridgeId: 'ghost_fridge_001',
      condition: FridgeCondition.ghost,
      foodPercentage: 0.0,
      notes: 'Fridge is no longer at this location',
      epochTimestamp: '1751500000',
      timestamp: '2025-07-02T12:00:00Z',
    ),
  );

  /// List of all sample fridges
  static final List<FridgeDomain> allFridges = [
    verifiedFridgeWithFood,
    notAtLocationFridge,
    fridgeDirty,
    fridgeOutOfOrder,
    ghostFridge,
  ];

  /// Get sample fridge by ID
  static FridgeDomain? getFridgeById(String id) {
    try {
      return allFridges.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }
}

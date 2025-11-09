import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../map/domain/models/fridge_domain.dart';
import '../../../map/domain/repositories/i_fridge_repository.dart';
import '../../../../core/exceptions/app_exception.dart';

/// Mock repository for development and testing
/// Simulates API responses using in-memory data
class MockFridgeRepository implements IFridgeRepository {
  // Simulated data store
  final Map<String, FridgeDomain> _fridges = {};
  bool _shouldFail = false;
  String? _failureMessage;

  MockFridgeRepository() {
    _initializeMockData();
  }

  /// Initialize with mock data
  /// Based on real FridgeFinder API response format
  void _initializeMockData() {
    // Create some sample fridges for testing
    final fridge1 = FridgeDomain(
      id: 'living_gallery_mock',
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
      photoUrl:
          'https://community-fridge-map-images-prod.s3.amazonaws.com/96c3a513-17b3-4760-983b-3ae7525d5deb.webp',
      lastEdited: '1667513900',
      latestFridgeReport: FridgeReportDomain(
        fridgeId: 'living_gallery_mock',
        condition: FridgeCondition.good,
        foodPercentage: 0.85,
        notes: 'Well stocked, clean condition',
        epochTimestamp: '1752166617',
        timestamp: '2025-07-10T16:56:57Z',
      ),
    );

    final fridge2 = FridgeDomain(
      id: 'collective_focus_mock',
      name: 'Collective Focus Resource Hub',
      verified: true,
      location: FridgeLocationDomain(
        street: '1046 Broadway',
        city: 'New York',
        state: 'NY',
        zip: '11221',
        geoLat: 40.6972,
        geoLng: -73.9354,
      ),
      maintainer: FridgeMaintainerDomain(
        instagram: 'https://www.instagram.com/collectivefocushub',
      ),
      photoUrl: 'https://via.placeholder.com/300x300?text=Collective+Focus',
      latestFridgeReport: FridgeReportDomain(
        fridgeId: 'collective_focus_mock',
        condition: FridgeCondition.good,
        foodPercentage: 0.45,
        notes: 'Moderate stock, clean',
        epochTimestamp: '1751814000',
        timestamp: '2025-07-06T12:00:00Z',
      ),
    );

    final fridge3 = FridgeDomain(
      id: 'community_care_mock',
      name: 'Community Care Center',
      verified: false,
      location: FridgeLocationDomain(
        street: '500 5th Avenue',
        city: 'New York',
        state: 'NY',
        zip: '10110',
        geoLat: 40.7549,
        geoLng: -73.9840,
      ),
      maintainer: FridgeMaintainerDomain(
        organization: 'Community Care',
        email: 'contact@communitycare.org',
      ),
      photoUrl: 'https://via.placeholder.com/300x300?text=Community+Care',
      latestFridgeReport: FridgeReportDomain(
        fridgeId: 'community_care_mock',
        condition: FridgeCondition.dirty,
        foodPercentage: 0.1,
        notes: 'Needs cleaning',
        epochTimestamp: '1751727600',
        timestamp: '2025-07-05T12:00:00Z',
      ),
    );

    final fridge4 = FridgeDomain(
      id: 'downtown_food_share_mock',
      name: 'Downtown Food Share',
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
        instagram: 'https://www.instagram.com/dtfoodshare',
      ),
      photoUrl: 'https://via.placeholder.com/300x300?text=Downtown+Food+Share',
      latestFridgeReport: FridgeReportDomain(
        fridgeId: 'downtown_food_share_mock',
        condition: FridgeCondition.outOfOrder,
        foodPercentage: 0.0,
        notes: 'Equipment malfunction, closed for repairs',
        epochTimestamp: '1751641200',
        timestamp: '2025-07-04T12:00:00Z',
      ),
    );

    _fridges['living_gallery_mock'] = fridge1;
    _fridges['collective_focus_mock'] = fridge2;
    _fridges['community_care_mock'] = fridge3;
    _fridges['downtown_food_share_mock'] = fridge4;
  }

  /// Set whether subsequent calls should fail
  void setShouldFail(bool shouldFail, [String? message]) {
    _shouldFail = shouldFail;
    _failureMessage = message ?? 'Mock error occurred';
  }

  /// Simulate network delay
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Check if should fail and throw exception
  void _checkShouldFail() {
    if (_shouldFail) {
      throw NetworkException(_failureMessage ?? 'Mock error occurred');
    }
  }

  /// Get all fridges
  @override
  Future<List<FridgeDomain>> getFridges() async {
    _checkShouldFail();
    await _simulateNetworkDelay();
    return _fridges.values.toList();
  }

  /// Get single fridge by ID
  @override
  Future<FridgeDomain> getFridge(String id) async {
    _checkShouldFail();
    await _simulateNetworkDelay();

    final fridge = _fridges[id];
    if (fridge == null) {
      throw NotFoundException('Fridge with ID $id not found');
    }
    return fridge;
  }

  /// Submit fridge report (update status)
  @override
  Future<void> submitFridgeReport(
    String fridgeId,
    FridgeCondition condition,
    double foodPercentage,
    String? notes,
    String? photoUrl,
  ) async {
    _checkShouldFail();
    await _simulateNetworkDelay();

    final fridge = _fridges[fridgeId];
    if (fridge == null) {
      throw NotFoundException('Fridge with ID $fridgeId not found');
    }

    // Create new report
    final now = DateTime.now();
    final newReport = FridgeReportDomain(
      fridgeId: fridgeId,
      condition: condition,
      foodPercentage: foodPercentage,
      notes: notes,
      photoUrl: photoUrl,
      epochTimestamp: (now.millisecondsSinceEpoch ~/ 1000).toString(),
      timestamp: now.toIso8601String(),
    );

    // Update fridge with new report
    final updatedFridge = FridgeDomain(
      id: fridge.id,
      name: fridge.name,
      verified: fridge.verified,
      location: fridge.location,
      maintainer: fridge.maintainer,
      notes: fridge.notes,
      photoUrl: fridge.photoUrl,
      lastEdited: (now.millisecondsSinceEpoch ~/ 1000).toString(),
      latestFridgeReport: newReport,
    );

    _fridges[fridgeId] = updatedFridge;
  }

  /// Upload a photo (mock implementation)
  @override
  Future<String> uploadPhoto(List<int> imageBytes, String mimeType) async {
    _checkShouldFail();
    await _simulateNetworkDelay();

    // Return a mock photo URL
    return 'https://mock.fridgefinder.com/photos/mock_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  /// Search fridges (simple name/city matching)
  Future<List<FridgeDomain>> searchFridges(String query) async {
    _checkShouldFail();
    await _simulateNetworkDelay();

    final lowerQuery = query.toLowerCase();
    return _fridges.values
        .where(
          (f) =>
              f.name.toLowerCase().contains(lowerQuery) ||
              f.location.city.toLowerCase().contains(lowerQuery) ||
              f.location.state.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }
}

/// Provider for mock repository (for development/testing)
final mockFridgeRepositoryProvider = Provider<MockFridgeRepository>((ref) {
  return MockFridgeRepository();
});

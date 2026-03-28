import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:fridgefinder_app/src/features/map/data/repositories/fridge_repository.dart';
import 'package:fridgefinder_app/src/features/map/domain/models/fridge_domain.dart';
import 'package:fridgefinder_app/src/core/providers/dio_provider.dart';
import 'package:fridgefinder_app/src/core/providers/environment_provider.dart';
import 'package:fridgefinder_app/src/features/map/presentation/controllers/map_filter_controller.dart';
import 'package:fridgefinder_app/src/features/map/presentation/controllers/filter_condition.dart';
import 'package:fridgefinder_app/src/core/providers/location_provider.dart';
import 'fixtures/fridge_fixtures.dart';

/// Mock repository that returns fixture data
class MockFridgeRepository implements FridgeRepository {
  @override
  Future<List<FridgeDomain>> getFridges({bool includeGhosts = false}) async {
    if (includeGhosts) {
      return FridgeFixtures.allFridges;
    }
    return FridgeFixtures.allFridges
        .where((f) => f.latestFridgeReport?.condition != FridgeCondition.ghost)
        .toList();
  }

  @override
  Future<FridgeDomain> getFridge(String id) async {
    final fridge = FridgeFixtures.getFridgeById(id);
    if (fridge == null) {
      throw Exception('Fridge not found: $id');
    }
    return fridge;
  }

  @override
  Future<void> submitFridgeReport(
    String fridgeId,
    FridgeCondition condition,
    double foodPercentage,
    String? notes,
    List<int>? photoBytes,
  ) async {
    // Mock implementation - just return
  }

  @override
  Future<String> uploadPhoto(List<int> imageBytes, String mimeType) async {
    // Mock implementation - return a dummy URL
    return 'https://example.com/photo.jpg';
  }
}

/// Create a Dio instance for testing without connectivity checks
Dio createTestDio() {
  return Dio(
    BaseOptions(
      baseUrl: 'https://api-prod.communityfridgefinder.com/v1',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      sendTimeout: const Duration(seconds: 5),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  // Note: No connectivity interceptor in tests - avoids platform channel calls
}

/// Get base provider overrides for testing (dio, environment, etc.)
/// Returns a list that can be spread into ProviderScope.overrides
List<dynamic> getBaseTestOverrides({FridgeRepository? fridgeRepository, Dio? dio}) {
  TestWidgetsFlutterBinding.ensureInitialized();

  final repository = fridgeRepository ?? MockFridgeRepository();
  final dioInstance = dio ?? createTestDio();

  // Create a default filter state for testing
  final defaultFilterState = MapFilterState(
    selectedConditions: FilterCondition.values.toSet(),
    searchQuery: '',
    includeGhosts: false,
  );

  return [
    // Override dio provider to avoid connectivity_plus platform channel calls
    dioProvider.overrideWithValue(dioInstance),
    fridgeRepositoryProvider.overrideWithValue(repository),
    // Override environment provider to avoid Hive dependencies in unit tests
    environmentProvider.overrideWithValue(ApiEnvironment.prod),
    apiBaseUrlProvider.overrideWith(
      (ref) => 'https://api-prod.communityfridgefinder.com/v1',
    ),
    // Override mapFilterProvider to provide synchronous default state (avoids Hive async loading)
    mapFilterProvider.overrideWith(() => _MockMapFilter(defaultFilterState)),
    // Override userLocationProvider to return null (no location needed for list tests)
    userLocationProvider.overrideWith((ref) => Future.value(null)),
    // Note: fridgesSortedByDistanceProvider should be overridden in individual tests
    // AFTER fridgeListProvider override to ensure proper dependency resolution
  ];
}

/// Mock MapFilter implementation for testing
class _MockMapFilter extends MapFilter {
  final MapFilterState _initialState;

  _MockMapFilter(this._initialState);

  @override
  Future<MapFilterState> build() async {
    return _initialState;
  }
}

/// Helper to create a ProviderContainer with mocked dependencies for testing
ProviderContainer createTestProviderContainer({
  FridgeRepository? fridgeRepository,
  Dio? dio,
}) {
  TestWidgetsFlutterBinding.ensureInitialized();

  final repository = fridgeRepository ?? MockFridgeRepository();
  final dioInstance = dio ?? createTestDio();

  // Create a default filter state for testing
  final defaultFilterState = MapFilterState(
    selectedConditions: FilterCondition.values.toSet(),
    searchQuery: '',
    includeGhosts: false,
  );

  final container = ProviderContainer(
    overrides: [
      // Override dio provider to avoid connectivity_plus platform channel calls
      dioProvider.overrideWithValue(dioInstance),
      fridgeRepositoryProvider.overrideWithValue(repository),
      // Override environment provider to avoid Hive dependencies in unit tests
      environmentProvider.overrideWithValue(ApiEnvironment.prod),
      apiBaseUrlProvider.overrideWith(
        (ref) => 'https://api-prod.communityfridgefinder.com/v1',
      ),
      // Override mapFilterProvider to provide synchronous default state (avoids Hive async loading)
      mapFilterProvider.overrideWith(() => _MockMapFilter(defaultFilterState)),
      // Override userLocationProvider to return null (no location needed for unit tests)
      userLocationProvider.overrideWith((ref) => Future.value(null)),
    ],
  );

  return container;
}

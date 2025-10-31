import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgefinder_app/src/features/map/data/repositories/fridge_repository.dart';
import 'package:fridgefinder_app/src/features/map/domain/models/fridge_domain.dart';
import 'fixtures/fridge_fixtures.dart';

/// Mock repository that returns fixture data
class MockFridgeRepository implements FridgeRepository {
  @override
  Future<List<FridgeDomain>> getFridges() async {
    return FridgeFixtures.allFridges;
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
  ) async {
    // Mock implementation - just return
  }

  @override
  Future<String> uploadPhoto(List<int> imageBytes, String mimeType) async {
    // Mock implementation - return a dummy URL
    return 'https://example.com/photo.jpg';
  }
}

/// Helper to create a ProviderContainer with mocked dependencies for testing
ProviderContainer createTestProviderContainer({
  FridgeRepository? fridgeRepository,
}) {
  final repository = fridgeRepository ?? MockFridgeRepository();

  final container = ProviderContainer(
    overrides: [
      fridgeRepositoryProvider.overrideWithValue(repository),
    ],
  );

  return container;
}

/// Helper to wait for an async provider to complete
Future<T> waitForAsyncProvider<T>(
  ProviderContainer container,
  FutureProvider<T> provider, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final future = container.read(provider.future);
  return future.timeout(timeout);
}

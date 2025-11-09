import '../models/fridge_domain.dart';

/// Abstract interface for fridge repository
/// Allows for easy testing and mocking with dependency inversion
abstract class IFridgeRepository {
  /// Fetch all fridges from the data source
  /// Throws exceptions on errors
  Future<List<FridgeDomain>> getFridges();

  /// Fetch a single fridge by ID
  /// Throws [NotFoundException] if fridge not found
  /// Throws exceptions on errors
  Future<FridgeDomain> getFridge(String fridgeId);

  /// Submit a condition report for a fridge
  /// Throws exceptions on errors
  Future<void> submitFridgeReport(
    String fridgeId,
    FridgeCondition condition,
    double foodPercentage,
    String? notes,
    String? photoUrl,
  );

  /// Upload a fridge photo
  /// Returns the URL of the uploaded photo
  /// Throws exceptions on errors
  Future<String> uploadPhoto(List<int> imageBytes, String mimeType);
}

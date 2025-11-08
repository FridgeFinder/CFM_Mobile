import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:latlong2/latlong.dart';
import '../../data/repositories/fridge_repository.dart';
import '../../domain/models/fridge_domain.dart';
import '../../../../core/providers/location_provider.dart';
import '../../../../core/utils/distance_calculator.dart' as distance_utils;
import '../../../../core/utils/fuzzy_search.dart';
import 'map_filter_controller.dart'; // Provides mapFilterProvider

part 'fridge_list_controller.g.dart';

/// Controller for managing the list of all fridges
/// Uses real FridgeFinder API to fetch data
@riverpod
Future<List<FridgeDomain>> fridgeList(Ref ref) async {
  final repository = ref.watch(fridgeRepositoryProvider);
  return repository.getFridges();
}

/// Notifier for managing a single selected fridge ID
@riverpod
class SelectedFridgeId extends _$SelectedFridgeId {
  @override
  String? build() => null;

  void setSelectedFridgeId(String? id) {
    state = id;
  }

  void clearSelection() {
    state = null;
  }
}

/// Controller for getting the currently selected fridge data
@riverpod
FridgeDomain? selectedFridge(Ref ref) {
  final selectedId = ref.watch(selectedFridgeIdProvider);
  if (selectedId == null) return null;

  final fridgesAsync = ref.watch(fridgeListProvider);
  return fridgesAsync.whenOrNull(
    data: (fridges) {
      try {
        return fridges.firstWhere((f) => f.id == selectedId);
      } catch (e) {
        return null;
      }
    },
  );
}

/// Notifier for managing search query
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void setSearchQuery(String query) {
    state = query;
  }

  void clearSearch() {
    state = '';
  }
}

/// Controller for filtered fridges based on search
@riverpod
List<FridgeDomain> filteredFridges(Ref ref) {
  final fridgesAsync = ref.watch(fridgeListProvider);
  final query = ref.watch(searchQueryProvider);

  return fridgesAsync.whenOrNull(
        data: (fridges) {
          if (query.isEmpty) return fridges;

          final lowerQuery = query.toLowerCase();
          return fridges
              .where(
                (f) =>
                    f.name.toLowerCase().contains(lowerQuery) ||
                    f.location.city.toLowerCase().contains(lowerQuery) ||
                    f.location.state.toLowerCase().contains(lowerQuery),
              )
              .toList();
        },
      ) ??
      [];
}

/// Provider for getting a specific fridge
/// Uses real FridgeFinder API to fetch specific fridge data
@riverpod
Future<FridgeDomain> singleFridge(Ref ref, String fridgeId) async {
  final repository = ref.watch(fridgeRepositoryProvider);
  return repository.getFridge(fridgeId);
}

/// Helper model to hold a fridge and its distance from user
class FridgeWithDistance {
  final FridgeDomain fridge;
  final double? distanceKm;

  FridgeWithDistance({required this.fridge, required this.distanceKm});
}

/// Provider to get fridges sorted by distance from user
/// Returns fridges sorted by distance (closest first) if location is available
/// Otherwise returns fridges in original order
/// Uses memoization to avoid recalculating distances on every rebuild
@riverpod
List<FridgeWithDistance> fridgesSortedByDistance(Ref ref) {
  final fridgesAsync = ref.watch(fridgeListProvider);
  // Only watch the user location value, not the entire AsyncValue
  final userLocationAsync = ref.watch(userLocationProvider);
  final userLocation = userLocationAsync.whenOrNull(
    data: (loc) => loc?.position,
  );

  return fridgesAsync.whenOrNull(
        data: (fridges) {
          if (userLocation == null) {
            // Location not available, return fridges without distance
            return fridges
                .map((f) => FridgeWithDistance(fridge: f, distanceKm: null))
                .toList();
          }

          // Calculate distances and sort
          final fridgesWithDistances = fridges.map((fridge) {
            final fridgeLocation = LatLng(
              fridge.location.geoLat,
              fridge.location.geoLng,
            );
            final distance =
                distance_utils.DistanceCalculator.calculateDistanceInKm(
                  userLocation,
                  fridgeLocation,
                );
            return FridgeWithDistance(fridge: fridge, distanceKm: distance);
          }).toList();

          // Sort by distance (closest first)
          fridgesWithDistances.sort((a, b) {
            if (a.distanceKm == null && b.distanceKm == null) return 0;
            if (a.distanceKm == null) return 1;
            if (b.distanceKm == null) return -1;
            return a.distanceKm!.compareTo(b.distanceKm!);
          });

          return fridgesWithDistances;
        },
      ) ??
      [];
}

/// Provider for filtered fridges based on map filter state (pill filters + fuzzy search)
/// Applies pill condition filters first, then fuzzy search on remaining fridges
@riverpod
List<FridgeDomain> mapFilteredFridges(Ref ref) {
  final fridgesAsync = ref.watch(fridgeListProvider);
  final filterStateAsync = ref.watch(mapFilterProvider);

  return filterStateAsync.whenOrNull(
        data: (filterState) {
          return fridgesAsync.whenOrNull(
                data: (fridges) {
                  // First, filter by selected conditions (pill filters)
                  var filtered = fridges.where((fridge) {
                    // Check if any of the selected filter conditions match this fridge
                    return filterState.selectedConditions.any((
                      filterCondition,
                    ) {
                      return filterCondition.matches(fridge);
                    });
                  }).toList();

                  // Then apply fuzzy search
                  if (filterState.searchQuery.isEmpty) {
                    return filtered;
                  }

                  final searchQuery = filterState.searchQuery.toLowerCase();
                  return filtered.where((fridge) {
                    return FuzzySearch.isFuzzyMatch(searchQuery, fridge.name) ||
                        FuzzySearch.isFuzzyMatch(
                          searchQuery,
                          fridge.location.city,
                        ) ||
                        FuzzySearch.isFuzzyMatch(
                          searchQuery,
                          fridge.location.state,
                        );
                  }).toList();
                },
              ) ??
              [];
        },
      ) ??
      [];
}

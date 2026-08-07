import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:latlong2/latlong.dart';
import '../../data/repositories/fridge_repository.dart';
import '../../domain/models/fridge_domain.dart';
import '../../../../core/providers/location_provider.dart';
import '../../../../core/providers/subscriptions_provider.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/distance_calculator.dart' as distance_utils;
import '../../../../core/utils/fuzzy_search.dart';
import 'map_filter_controller.dart'; // Provides mapFilterProvider

part 'fridge_list_controller.g.dart';

const _fridgeListCacheBoxName = 'fridge_list_cache';
const _fridgeListCacheKey = 'all_fridges';

Future<bool> _ensureHiveInitialized() async {
  try {
    await Hive.initFlutter();
    return true;
  } on MissingPluginException catch (_) {
    return false;
  } catch (e) {
    if (e.toString().contains('already initialized')) {
      return true;
    }
    logger.w('Unable to initialize Hive: $e');
    return false;
  }
}

List<FridgeDomain>? _lastFridgeListSnapshot;

Future<Box<String>?> _openFridgeListCacheBox() async {
  try {
    if (!await _ensureHiveInitialized()) {
      return null;
    }
    if (Hive.isBoxOpen(_fridgeListCacheBoxName)) {
      return Hive.box<String>(_fridgeListCacheBoxName);
    }
    return await Hive.openBox<String>(_fridgeListCacheBoxName);
  } catch (e) {
    if (e.toString().contains('initialize Hive') ||
        e.toString().contains('You need to initialize Hive')) {
      return null;
    }
    logger.w('Unable to open fridge list cache box: $e');
    return null;
  }
}

List<FridgeDomain> _decodeFridgeList(String? rawJson) {
  if (rawJson == null || rawJson.isEmpty) return const [];

  try {
    final decoded = jsonDecode(rawJson);
    if (decoded is! List) return const [];

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(FridgeDomain.fromJson)
        .toList();
  } catch (e) {
    logger.w('Unable to decode fridge list cache: $e');
    return const [];
  }
}

String _encodeFridgeList(List<FridgeDomain> fridges) {
  final normalized = fridges.map((fridge) => fridge.toJson()).toList()
    ..sort((a, b) {
      final idA = a['id'] as String? ?? '';
      final idB = b['id'] as String? ?? '';
      return idA.compareTo(idB);
    });

  return jsonEncode(normalized);
}

/// Controller for managing the list of all fridges
/// Uses real FridgeFinder API to fetch data
@riverpod
Future<List<FridgeDomain>> fridgeList(Ref ref) async {
  final repository = ref.read(fridgeRepositoryProvider);
  var isDisposed = false;
  ref.onDispose(() {
    isDisposed = true;
  });

  if (_lastFridgeListSnapshot != null) {
    unawaited(
      _refreshFridgeListFromApi(
        repository: repository,
        isDisposed: () => isDisposed,
        onDataChanged: () {
          if (isDisposed || !ref.mounted) return;
          ref.invalidateSelf();
        },
      ),
    );
    return _lastFridgeListSnapshot!;
  }

  final cacheBox = await _openFridgeListCacheBox();
  final cachedRaw = cacheBox?.get(_fridgeListCacheKey);
  final cachedFridges = _decodeFridgeList(cachedRaw);

  Future<void> refreshFromApi() async {
    final repository = ref.read(fridgeRepositoryProvider);
    await _refreshFridgeListFromApi(
      repository: repository,
      cacheBox: cacheBox,
      cachedRaw: cachedRaw,
      isDisposed: () => isDisposed,
      onDataChanged: () {
        if (isDisposed || !ref.mounted) return;
        ref.invalidateSelf();
      },
    );
  }

  // Return cache immediately and refresh in background to avoid tab-switch jank.
  if (cachedFridges.isNotEmpty) {
    _lastFridgeListSnapshot = cachedFridges;
    unawaited(refreshFromApi());
    return cachedFridges;
  }

  // Always fetch all fridges including ghosts — ghost filtering is done
  // downstream in filteredFridgesProvider/mapFilteredFridgesProvider to
  // avoid refetching from the API on every filter change.
  final fridges = await repository.getFridges(includeGhosts: true);
  if (cacheBox != null) {
    final latestRaw = _encodeFridgeList(fridges);
    await cacheBox.put(_fridgeListCacheKey, latestRaw);
  }
  _lastFridgeListSnapshot = fridges;
  return fridges;
}

Future<void> _refreshFridgeListFromApi(
  {
  required FridgeRepository repository,
  Box<String>? cacheBox,
  String? cachedRaw,
  required bool Function() isDisposed,
  required void Function() onDataChanged,
}) async {
  try {
    if (isDisposed()) return;
    final latestFridges = await repository.getFridges(includeGhosts: true);
    final previousRaw = _lastFridgeListSnapshot == null
        ? null
        : _encodeFridgeList(_lastFridgeListSnapshot!);
    _lastFridgeListSnapshot = latestFridges;
    if (isDisposed()) return;

    final latestRaw = _encodeFridgeList(latestFridges);
    if (cacheBox != null && latestRaw != cachedRaw) {
      await cacheBox.put(_fridgeListCacheKey, latestRaw);
    } else if (cacheBox == null && latestRaw != cachedRaw) {
      // Intentionally do nothing here; the in-memory snapshot is already updated.
    }

    if (latestRaw != previousRaw) {
      onDataChanged();
    }
  } catch (e) {
    logger.w('Failed to refresh fridge list from API: $e');
  }
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
  final filterStateAsync = ref.watch(mapFilterProvider);
  final includeGhosts = filterStateAsync.whenOrNull(data: (d) => d.includeGhosts) ?? false;

  return fridgesAsync.whenOrNull(
        data: (fridges) {
          // Filter out ghosts unless explicitly included
          var result = includeGhosts
              ? fridges
              : fridges.where((f) => f.latestFridgeReport?.condition != FridgeCondition.ghost).toList();

          if (query.isEmpty) return result;

          final lowerQuery = query.toLowerCase();
          return result
              .where(
                (f) =>
                    f.name.toLowerCase().contains(lowerQuery) ||
                    f.location.street.toLowerCase().contains(lowerQuery) ||
                    f.location.city.toLowerCase().contains(lowerQuery) ||
                    f.location.state.toLowerCase().contains(lowerQuery) ||
                    f.location.zip.toLowerCase().contains(lowerQuery),
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

/// Provider for filtered fridges based on map filter state (pill filters + subscribed filter + fuzzy search)
/// Applies pill condition filters first, then subscribed filter, then fuzzy search on remaining fridges
@riverpod
List<FridgeDomain> mapFilteredFridges(Ref ref) {
  final fridgesAsync = ref.watch(fridgeListProvider);
  final filterStateAsync = ref.watch(mapFilterProvider);
  final subscriptionsAsync = ref.watch(subscribedFridgesProvider);

  return filterStateAsync.whenOrNull(
        data: (filterState) {
          return fridgesAsync.whenOrNull(
                data: (fridges) {
                  // Filter out ghosts unless explicitly included
                  final baseList = filterState.includeGhosts
                      ? fridges
                      : fridges.where((f) => f.latestFridgeReport?.condition != FridgeCondition.ghost).toList();

                  // First, filter by selected conditions (pill filters)
                  // If no conditions selected, show all fridges
                  var filtered = filterState.selectedConditions.isEmpty
                      ? baseList
                      : baseList.where((fridge) {
                          // Check if any of the selected filter conditions match this fridge
                          return filterState.selectedConditions.any((
                            filterCondition,
                          ) {
                            return filterCondition.matches(fridge);
                          });
                        }).toList();

                  // Then apply subscribed filter if active
                  if (filterState.followingOnly) {
                    final subscribedFridgeIds = subscriptionsAsync.whenOrNull(
                      data: (subs) => subs.map((s) => s.fridgeId).toSet(),
                    ) ?? <String>{};

                    filtered = filtered.where((fridge) {
                      return subscribedFridgeIds.contains(fridge.id);
                    }).toList();
                  }

                  // Then apply fuzzy search
                  if (filterState.searchQuery.isEmpty) {
                    return filtered;
                  }

                  final searchQuery = filterState.searchQuery.toLowerCase();
                  return filtered.where((fridge) {
                    return FuzzySearch.isFuzzyMatch(searchQuery, fridge.name) ||
                        FuzzySearch.isFuzzyMatch(
                          searchQuery,
                          fridge.location.street,
                        ) ||
                        FuzzySearch.isFuzzyMatch(
                          searchQuery,
                          fridge.location.city,
                        ) ||
                        FuzzySearch.isFuzzyMatch(
                          searchQuery,
                          fridge.location.state,
                        ) ||
                        FuzzySearch.isFuzzyMatch(
                          searchQuery,
                          fridge.location.zip,
                        );
                  }).toList();
                },
              ) ??
              [];
        },
      ) ??
      [];
}

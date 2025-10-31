import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'filter_condition.dart';

/// Filter state for map view
/// Tracks which filter conditions are selected to filter the display
class MapFilterState {
  final Set<FilterCondition> selectedConditions;
  final String searchQuery;

  const MapFilterState({
    required this.selectedConditions,
    required this.searchQuery,
  });

  MapFilterState copyWith({
    Set<FilterCondition>? selectedConditions,
    String? searchQuery,
  }) {
    return MapFilterState(
      selectedConditions: selectedConditions ?? this.selectedConditions,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Check if filter state is at default (all conditions selected, no search)
  bool get isDefault {
    return selectedConditions.length == FilterCondition.values.length &&
        searchQuery.isEmpty;
  }

  /// Get list of deselected filter conditions for display
  List<FilterCondition> get deselectedConditions {
    return FilterCondition.values
        .where((c) => !selectedConditions.contains(c))
        .toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapFilterState &&
          runtimeType == other.runtimeType &&
          selectedConditions == other.selectedConditions &&
          searchQuery == other.searchQuery;

  @override
  int get hashCode => selectedConditions.hashCode ^ searchQuery.hashCode;
}

/// Notifier for managing map filter state with persistence using Hive
class MapFilterNotifier extends AsyncNotifier<MapFilterState> {
  static const String _boxName = 'map_filter_state';
  static const String _conditionsKey = 'selected_conditions';
  static const String _searchKey = 'search_query';
  static const Duration _searchDebounceDelay = Duration(milliseconds: 150);

  Timer? _searchDebounceTimer;

  @override
  Future<MapFilterState> build() async {
    // Cancel timer on provider disposal
    ref.onDispose(() {
      _searchDebounceTimer?.cancel();
    });
    return _loadFromStorage();
  }

  /// Load filter state from Hive
  Future<MapFilterState> _loadFromStorage() async {
    try {
      final box = await Hive.openBox(_boxName);

      // Load selected conditions
      final conditionStrings = box.get(_conditionsKey) as List?;
      final selectedConditions =
          (conditionStrings == null || conditionStrings.isEmpty)
          ? FilterCondition.values
                .toSet() // Default: all selected
          : conditionStrings
                .cast<String>()
                .map(
                  (str) => FilterCondition.values.firstWhere(
                    (c) => c.value == str,
                    orElse: () => FilterCondition.goodWithFood,
                  ),
                )
                .toSet();

      // Load search query
      final searchQuery = box.get(_searchKey, defaultValue: '') as String;

      return MapFilterState(
        selectedConditions: selectedConditions,
        searchQuery: searchQuery,
      );
    } catch (e) {
      // If loading fails, return default state (all conditions selected)
      return MapFilterState(
        selectedConditions: FilterCondition.values.toSet(),
        searchQuery: '',
      );
    }
  }

  /// Save filter state to Hive
  Future<void> _saveToStorage(MapFilterState state) async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(
        _conditionsKey,
        state.selectedConditions.map((c) => c.value).toList(),
      );
      await box.put(_searchKey, state.searchQuery);
    } catch (e) {
      // Silently fail - storage is not critical
    }
  }

  /// Toggle a filter condition
  Future<void> toggleCondition(FilterCondition condition) async {
    final currentState = state.whenOrNull(data: (d) => d);
    if (currentState == null) return;

    final newConditions = <FilterCondition>{...currentState.selectedConditions};
    if (newConditions.contains(condition)) {
      newConditions.remove(condition);
    } else {
      newConditions.add(condition);
    }

    final newState = currentState.copyWith(selectedConditions: newConditions);
    state = AsyncValue.data(newState);
    await _saveToStorage(newState);
  }

  /// Set search query with debouncing
  Future<void> setSearchQuery(String query) async {
    // Cancel previous debounce timer
    _searchDebounceTimer?.cancel();

    // Create new debounce timer
    _searchDebounceTimer = Timer(_searchDebounceDelay, () async {
      final currentState = state.whenOrNull(data: (d) => d);
      if (currentState == null) return;

      final newState = currentState.copyWith(searchQuery: query);
      state = AsyncValue.data(newState);
      await _saveToStorage(newState);
    });
  }

  /// Clear search query
  Future<void> clearSearch() async {
    final currentState = state.whenOrNull(data: (d) => d);
    if (currentState == null) return;

    _searchDebounceTimer?.cancel();

    final newState = currentState.copyWith(searchQuery: '');
    state = AsyncValue.data(newState);
    await _saveToStorage(newState);
  }

  /// Select all conditions
  Future<void> selectAllConditions() async {
    final currentState = state.whenOrNull(data: (d) => d);
    if (currentState == null) return;

    final newState = currentState.copyWith(
      selectedConditions: FilterCondition.values.toSet(),
    );
    state = AsyncValue.data(newState);
    await _saveToStorage(newState);
  }

  /// Deselect all conditions
  Future<void> deselectAllConditions() async {
    final currentState = state.whenOrNull(data: (d) => d);
    if (currentState == null) return;

    final newState = currentState.copyWith(
      selectedConditions: <FilterCondition>{},
    );
    state = AsyncValue.data(newState);
    await _saveToStorage(newState);
  }
}

/// Provider for map filter state
final mapFilterProvider =
    AsyncNotifierProvider<MapFilterNotifier, MapFilterState>(
      () => MapFilterNotifier(),
    );

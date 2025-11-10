import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'filter_condition.dart';

part 'map_filter_controller.freezed.dart';
part 'map_filter_controller.g.dart';

/// Filter state for map view
/// Tracks which filter conditions are selected to filter the display
@freezed
abstract class MapFilterState with _$MapFilterState {
  const MapFilterState._();

  const factory MapFilterState({
    required Set<FilterCondition> selectedConditions,
    @Default('') String searchQuery,
    @Default(false) bool subscribedOnly,
  }) = _MapFilterState;

  /// Check if filter state is at default (no conditions selected, no search, no subscribed filter)
  /// Default state shows everything
  bool get isDefault {
    return selectedConditions.isEmpty && searchQuery.isEmpty && !subscribedOnly;
  }

  /// Get list of deselected filter conditions for display
  List<FilterCondition> get deselectedConditions {
    return FilterCondition.values
        .where((c) => !selectedConditions.contains(c))
        .toList();
  }
}

/// Notifier for managing map filter state with persistence using Hive
@riverpod
class MapFilter extends _$MapFilter {
  static const String _boxName = 'map_filter_state';
  static const String _conditionsKey = 'selected_conditions';
  static const String _searchKey = 'search_query';
  static const String _subscribedOnlyKey = 'subscribed_only';
  static const String _versionKey = 'storage_version';
  static const int _currentVersion = 3; // Increment when filter logic changes (v3: added subscribedOnly)
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

      // Check storage version - if mismatch, reset to default and update version
      final savedVersion = box.get(_versionKey) as int?;
      if (savedVersion != _currentVersion) {
        // Version mismatch or first run - reset to default and save new version
        await box.put(_versionKey, _currentVersion);
        await box.delete(_conditionsKey);
        await box.delete(_searchKey);
        await box.delete(_subscribedOnlyKey);

        return const MapFilterState(
          selectedConditions: <FilterCondition>{}, // Default: none selected (shows everything)
          searchQuery: '',
          subscribedOnly: false,
        );
      }

      // Load selected conditions
      final conditionStrings = box.get(_conditionsKey) as List?;
      final selectedConditions =
          (conditionStrings == null)
          ? <FilterCondition>{} // Default: none selected (shows everything)
          : conditionStrings
                .cast<String>()
                .map(
                  (str) => FilterCondition.values.firstWhere(
                    (c) => c.value == str,
                    orElse: () => FilterCondition.full,
                  ),
                )
                .toSet();

      // Load search query
      final searchQuery = box.get(_searchKey, defaultValue: '') as String;

      // Load subscribed only filter
      final subscribedOnly = box.get(_subscribedOnlyKey, defaultValue: false) as bool;

      return MapFilterState(
        selectedConditions: selectedConditions,
        searchQuery: searchQuery,
        subscribedOnly: subscribedOnly,
      );
    } catch (e) {
      // If loading fails, return default state (no conditions selected = show all)
      return const MapFilterState(
        selectedConditions: <FilterCondition>{},
        searchQuery: '',
        subscribedOnly: false,
      );
    }
  }

  /// Save filter state to Hive
  Future<void> _saveToStorage(MapFilterState state) async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_versionKey, _currentVersion); // Always save current version
      await box.put(
        _conditionsKey,
        state.selectedConditions.map((c) => c.value).toList(),
      );
      await box.put(_searchKey, state.searchQuery);
      await box.put(_subscribedOnlyKey, state.subscribedOnly);
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

  /// Toggle subscribed only filter
  Future<void> toggleSubscribedOnly() async {
    final currentState = state.whenOrNull(data: (d) => d);
    if (currentState == null) return;

    final newState = currentState.copyWith(
      subscribedOnly: !currentState.subscribedOnly,
    );
    state = AsyncValue.data(newState);
    await _saveToStorage(newState);
  }
}

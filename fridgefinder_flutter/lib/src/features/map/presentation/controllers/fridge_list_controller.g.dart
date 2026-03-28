// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fridge_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing the list of all fridges
/// Uses real FridgeFinder API to fetch data

@ProviderFor(fridgeList)
const fridgeListProvider = FridgeListProvider._();

/// Controller for managing the list of all fridges
/// Uses real FridgeFinder API to fetch data

final class FridgeListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FridgeDomain>>,
          List<FridgeDomain>,
          FutureOr<List<FridgeDomain>>
        >
    with
        $FutureModifier<List<FridgeDomain>>,
        $FutureProvider<List<FridgeDomain>> {
  /// Controller for managing the list of all fridges
  /// Uses real FridgeFinder API to fetch data
  const FridgeListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fridgeListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fridgeListHash();

  @$internal
  @override
  $FutureProviderElement<List<FridgeDomain>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FridgeDomain>> create(Ref ref) {
    return fridgeList(ref);
  }
}

String _$fridgeListHash() => r'0098bff8b97de9c1d33798fac93ac1aa5d118b46';

/// Notifier for managing a single selected fridge ID

@ProviderFor(SelectedFridgeId)
const selectedFridgeIdProvider = SelectedFridgeIdProvider._();

/// Notifier for managing a single selected fridge ID
final class SelectedFridgeIdProvider
    extends $NotifierProvider<SelectedFridgeId, String?> {
  /// Notifier for managing a single selected fridge ID
  const SelectedFridgeIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedFridgeIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedFridgeIdHash();

  @$internal
  @override
  SelectedFridgeId create() => SelectedFridgeId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedFridgeIdHash() => r'de033b1e9ded5e7e1ebaf7321983e4e1fae7e30c';

/// Notifier for managing a single selected fridge ID

abstract class _$SelectedFridgeId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Controller for getting the currently selected fridge data

@ProviderFor(selectedFridge)
const selectedFridgeProvider = SelectedFridgeProvider._();

/// Controller for getting the currently selected fridge data

final class SelectedFridgeProvider
    extends $FunctionalProvider<FridgeDomain?, FridgeDomain?, FridgeDomain?>
    with $Provider<FridgeDomain?> {
  /// Controller for getting the currently selected fridge data
  const SelectedFridgeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedFridgeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedFridgeHash();

  @$internal
  @override
  $ProviderElement<FridgeDomain?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FridgeDomain? create(Ref ref) {
    return selectedFridge(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FridgeDomain? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FridgeDomain?>(value),
    );
  }
}

String _$selectedFridgeHash() => r'6d87e9801d6d6ed899edeba0110bf857ca02337e';

/// Notifier for managing search query

@ProviderFor(SearchQuery)
const searchQueryProvider = SearchQueryProvider._();

/// Notifier for managing search query
final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  /// Notifier for managing search query
  const SearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryHash();

  @$internal
  @override
  SearchQuery create() => SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryHash() => r'b4834155c01e84bb2d3ee66ef85973a9458eb958';

/// Notifier for managing search query

abstract class _$SearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Controller for filtered fridges based on search

@ProviderFor(filteredFridges)
const filteredFridgesProvider = FilteredFridgesProvider._();

/// Controller for filtered fridges based on search

final class FilteredFridgesProvider
    extends
        $FunctionalProvider<
          List<FridgeDomain>,
          List<FridgeDomain>,
          List<FridgeDomain>
        >
    with $Provider<List<FridgeDomain>> {
  /// Controller for filtered fridges based on search
  const FilteredFridgesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredFridgesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredFridgesHash();

  @$internal
  @override
  $ProviderElement<List<FridgeDomain>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<FridgeDomain> create(Ref ref) {
    return filteredFridges(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<FridgeDomain> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<FridgeDomain>>(value),
    );
  }
}

String _$filteredFridgesHash() => r'6a3cb1900b0c759e64766622531bbb104a526662';

/// Provider for getting a specific fridge
/// Uses real FridgeFinder API to fetch specific fridge data

@ProviderFor(singleFridge)
const singleFridgeProvider = SingleFridgeFamily._();

/// Provider for getting a specific fridge
/// Uses real FridgeFinder API to fetch specific fridge data

final class SingleFridgeProvider
    extends
        $FunctionalProvider<
          AsyncValue<FridgeDomain>,
          FridgeDomain,
          FutureOr<FridgeDomain>
        >
    with $FutureModifier<FridgeDomain>, $FutureProvider<FridgeDomain> {
  /// Provider for getting a specific fridge
  /// Uses real FridgeFinder API to fetch specific fridge data
  const SingleFridgeProvider._({
    required SingleFridgeFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'singleFridgeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$singleFridgeHash();

  @override
  String toString() {
    return r'singleFridgeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<FridgeDomain> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FridgeDomain> create(Ref ref) {
    final argument = this.argument as String;
    return singleFridge(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SingleFridgeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$singleFridgeHash() => r'b2b1f601ece5543fb65f22d78e50390bbf7cef67';

/// Provider for getting a specific fridge
/// Uses real FridgeFinder API to fetch specific fridge data

final class SingleFridgeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<FridgeDomain>, String> {
  const SingleFridgeFamily._()
    : super(
        retry: null,
        name: r'singleFridgeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for getting a specific fridge
  /// Uses real FridgeFinder API to fetch specific fridge data

  SingleFridgeProvider call(String fridgeId) =>
      SingleFridgeProvider._(argument: fridgeId, from: this);

  @override
  String toString() => r'singleFridgeProvider';
}

/// Provider to get fridges sorted by distance from user
/// Returns fridges sorted by distance (closest first) if location is available
/// Otherwise returns fridges in original order
/// Uses memoization to avoid recalculating distances on every rebuild

@ProviderFor(fridgesSortedByDistance)
const fridgesSortedByDistanceProvider = FridgesSortedByDistanceProvider._();

/// Provider to get fridges sorted by distance from user
/// Returns fridges sorted by distance (closest first) if location is available
/// Otherwise returns fridges in original order
/// Uses memoization to avoid recalculating distances on every rebuild

final class FridgesSortedByDistanceProvider
    extends
        $FunctionalProvider<
          List<FridgeWithDistance>,
          List<FridgeWithDistance>,
          List<FridgeWithDistance>
        >
    with $Provider<List<FridgeWithDistance>> {
  /// Provider to get fridges sorted by distance from user
  /// Returns fridges sorted by distance (closest first) if location is available
  /// Otherwise returns fridges in original order
  /// Uses memoization to avoid recalculating distances on every rebuild
  const FridgesSortedByDistanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fridgesSortedByDistanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fridgesSortedByDistanceHash();

  @$internal
  @override
  $ProviderElement<List<FridgeWithDistance>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<FridgeWithDistance> create(Ref ref) {
    return fridgesSortedByDistance(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<FridgeWithDistance> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<FridgeWithDistance>>(value),
    );
  }
}

String _$fridgesSortedByDistanceHash() =>
    r'13ec2fb5e4a5950f8272bc3814bf2da83bf624e2';

/// Provider for filtered fridges based on map filter state (pill filters + subscribed filter + fuzzy search)
/// Applies pill condition filters first, then subscribed filter, then fuzzy search on remaining fridges

@ProviderFor(mapFilteredFridges)
const mapFilteredFridgesProvider = MapFilteredFridgesProvider._();

/// Provider for filtered fridges based on map filter state (pill filters + subscribed filter + fuzzy search)
/// Applies pill condition filters first, then subscribed filter, then fuzzy search on remaining fridges

final class MapFilteredFridgesProvider
    extends
        $FunctionalProvider<
          List<FridgeDomain>,
          List<FridgeDomain>,
          List<FridgeDomain>
        >
    with $Provider<List<FridgeDomain>> {
  /// Provider for filtered fridges based on map filter state (pill filters + subscribed filter + fuzzy search)
  /// Applies pill condition filters first, then subscribed filter, then fuzzy search on remaining fridges
  const MapFilteredFridgesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapFilteredFridgesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapFilteredFridgesHash();

  @$internal
  @override
  $ProviderElement<List<FridgeDomain>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<FridgeDomain> create(Ref ref) {
    return mapFilteredFridges(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<FridgeDomain> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<FridgeDomain>>(value),
    );
  }
}

String _$mapFilteredFridgesHash() =>
    r'c7d3f4a132f6f5be1b01a1c16567c6ca31973837';

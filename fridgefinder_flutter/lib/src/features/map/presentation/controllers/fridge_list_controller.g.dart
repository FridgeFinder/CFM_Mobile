// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fridge_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fridgeListHash() => r'e6d119460ce1c8543ecc9d96dede179778e2948d';

/// Controller for managing the list of all fridges
/// Uses real FridgeFinder API to fetch data
///
/// Copied from [fridgeList].
@ProviderFor(fridgeList)
final fridgeListProvider =
    AutoDisposeFutureProvider<List<FridgeDomain>>.internal(
  fridgeList,
  name: r'fridgeListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$fridgeListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FridgeListRef = AutoDisposeFutureProviderRef<List<FridgeDomain>>;
String _$selectedFridgeHash() => r'6d87e9801d6d6ed899edeba0110bf857ca02337e';

/// Controller for getting the currently selected fridge data
///
/// Copied from [selectedFridge].
@ProviderFor(selectedFridge)
final selectedFridgeProvider = AutoDisposeProvider<FridgeDomain?>.internal(
  selectedFridge,
  name: r'selectedFridgeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedFridgeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SelectedFridgeRef = AutoDisposeProviderRef<FridgeDomain?>;
String _$filteredFridgesHash() => r'd0458cef32e9fb43e2ba42d8cdf9fc7281ddee46';

/// Controller for filtered fridges based on search
///
/// Copied from [filteredFridges].
@ProviderFor(filteredFridges)
final filteredFridgesProvider =
    AutoDisposeProvider<List<FridgeDomain>>.internal(
  filteredFridges,
  name: r'filteredFridgesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredFridgesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredFridgesRef = AutoDisposeProviderRef<List<FridgeDomain>>;
String _$singleFridgeHash() => r'b2b1f601ece5543fb65f22d78e50390bbf7cef67';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for getting a specific fridge
/// Uses real FridgeFinder API to fetch specific fridge data
///
/// Copied from [singleFridge].
@ProviderFor(singleFridge)
const singleFridgeProvider = SingleFridgeFamily();

/// Provider for getting a specific fridge
/// Uses real FridgeFinder API to fetch specific fridge data
///
/// Copied from [singleFridge].
class SingleFridgeFamily extends Family<AsyncValue<FridgeDomain>> {
  /// Provider for getting a specific fridge
  /// Uses real FridgeFinder API to fetch specific fridge data
  ///
  /// Copied from [singleFridge].
  const SingleFridgeFamily();

  /// Provider for getting a specific fridge
  /// Uses real FridgeFinder API to fetch specific fridge data
  ///
  /// Copied from [singleFridge].
  SingleFridgeProvider call(
    String fridgeId,
  ) {
    return SingleFridgeProvider(
      fridgeId,
    );
  }

  @override
  SingleFridgeProvider getProviderOverride(
    covariant SingleFridgeProvider provider,
  ) {
    return call(
      provider.fridgeId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'singleFridgeProvider';
}

/// Provider for getting a specific fridge
/// Uses real FridgeFinder API to fetch specific fridge data
///
/// Copied from [singleFridge].
class SingleFridgeProvider extends AutoDisposeFutureProvider<FridgeDomain> {
  /// Provider for getting a specific fridge
  /// Uses real FridgeFinder API to fetch specific fridge data
  ///
  /// Copied from [singleFridge].
  SingleFridgeProvider(
    String fridgeId,
  ) : this._internal(
          (ref) => singleFridge(
            ref as SingleFridgeRef,
            fridgeId,
          ),
          from: singleFridgeProvider,
          name: r'singleFridgeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$singleFridgeHash,
          dependencies: SingleFridgeFamily._dependencies,
          allTransitiveDependencies:
              SingleFridgeFamily._allTransitiveDependencies,
          fridgeId: fridgeId,
        );

  SingleFridgeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.fridgeId,
  }) : super.internal();

  final String fridgeId;

  @override
  Override overrideWith(
    FutureOr<FridgeDomain> Function(SingleFridgeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SingleFridgeProvider._internal(
        (ref) => create(ref as SingleFridgeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        fridgeId: fridgeId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<FridgeDomain> createElement() {
    return _SingleFridgeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SingleFridgeProvider && other.fridgeId == fridgeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, fridgeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SingleFridgeRef on AutoDisposeFutureProviderRef<FridgeDomain> {
  /// The parameter `fridgeId` of this provider.
  String get fridgeId;
}

class _SingleFridgeProviderElement
    extends AutoDisposeFutureProviderElement<FridgeDomain>
    with SingleFridgeRef {
  _SingleFridgeProviderElement(super.provider);

  @override
  String get fridgeId => (origin as SingleFridgeProvider).fridgeId;
}

String _$fridgesSortedByDistanceHash() =>
    r'13ec2fb5e4a5950f8272bc3814bf2da83bf624e2';

/// Provider to get fridges sorted by distance from user
/// Returns fridges sorted by distance (closest first) if location is available
/// Otherwise returns fridges in original order
/// Uses memoization to avoid recalculating distances on every rebuild
///
/// Copied from [fridgesSortedByDistance].
@ProviderFor(fridgesSortedByDistance)
final fridgesSortedByDistanceProvider =
    AutoDisposeProvider<List<FridgeWithDistance>>.internal(
  fridgesSortedByDistance,
  name: r'fridgesSortedByDistanceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fridgesSortedByDistanceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FridgesSortedByDistanceRef
    = AutoDisposeProviderRef<List<FridgeWithDistance>>;
String _$mapFilteredFridgesHash() =>
    r'd06bbcc8830b26ed278237a0b85bccada8150993';

/// Provider for filtered fridges based on map filter state (pill filters + fuzzy search)
/// Applies pill condition filters first, then fuzzy search on remaining fridges
///
/// Copied from [mapFilteredFridges].
@ProviderFor(mapFilteredFridges)
final mapFilteredFridgesProvider =
    AutoDisposeProvider<List<FridgeDomain>>.internal(
  mapFilteredFridges,
  name: r'mapFilteredFridgesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mapFilteredFridgesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MapFilteredFridgesRef = AutoDisposeProviderRef<List<FridgeDomain>>;
String _$selectedFridgeIdHash() => r'de033b1e9ded5e7e1ebaf7321983e4e1fae7e30c';

/// Notifier for managing a single selected fridge ID
///
/// Copied from [SelectedFridgeId].
@ProviderFor(SelectedFridgeId)
final selectedFridgeIdProvider =
    AutoDisposeNotifierProvider<SelectedFridgeId, String?>.internal(
  SelectedFridgeId.new,
  name: r'selectedFridgeIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedFridgeIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedFridgeId = AutoDisposeNotifier<String?>;
String _$searchQueryHash() => r'b4834155c01e84bb2d3ee66ef85973a9458eb958';

/// Notifier for managing search query
///
/// Copied from [SearchQuery].
@ProviderFor(SearchQuery)
final searchQueryProvider =
    AutoDisposeNotifierProvider<SearchQuery, String>.internal(
  SearchQuery.new,
  name: r'searchQueryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$searchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchQuery = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

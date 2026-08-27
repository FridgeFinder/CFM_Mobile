// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_filter_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing map filter state with persistence using Hive

@ProviderFor(MapFilter)
const mapFilterProvider = MapFilterProvider._();

/// Notifier for managing map filter state with persistence using Hive
final class MapFilterProvider
    extends $AsyncNotifierProvider<MapFilter, MapFilterState> {
  /// Notifier for managing map filter state with persistence using Hive
  const MapFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapFilterHash();

  @$internal
  @override
  MapFilter create() => MapFilter();
}

String _$mapFilterHash() => r'31b72828710f2028136d1cff073f520dde4b9e34';

/// Notifier for managing map filter state with persistence using Hive

abstract class _$MapFilter extends $AsyncNotifier<MapFilterState> {
  FutureOr<MapFilterState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<MapFilterState>, MapFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MapFilterState>, MapFilterState>,
              AsyncValue<MapFilterState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

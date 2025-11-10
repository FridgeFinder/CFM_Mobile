// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drawer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for tracking drawer state
/// MainShell updates this when drawer opens/closes

@ProviderFor(DrawerState)
const drawerStateProvider = DrawerStateProvider._();

/// Provider for tracking drawer state
/// MainShell updates this when drawer opens/closes
final class DrawerStateProvider extends $NotifierProvider<DrawerState, bool> {
  /// Provider for tracking drawer state
  /// MainShell updates this when drawer opens/closes
  const DrawerStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'drawerStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$drawerStateHash();

  @$internal
  @override
  DrawerState create() => DrawerState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$drawerStateHash() => r'1a7ea4d4c05c60710226484c362895e6f383aa2c';

/// Provider for tracking drawer state
/// MainShell updates this when drawer opens/closes

abstract class _$DrawerState extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for tracking if bottom sheet should be closed
/// Set to true to trigger bottom sheet closure

@ProviderFor(BottomSheetCloseTrigger)
const bottomSheetCloseTriggerProvider = BottomSheetCloseTriggerProvider._();

/// Provider for tracking if bottom sheet should be closed
/// Set to true to trigger bottom sheet closure
final class BottomSheetCloseTriggerProvider
    extends $NotifierProvider<BottomSheetCloseTrigger, int> {
  /// Provider for tracking if bottom sheet should be closed
  /// Set to true to trigger bottom sheet closure
  const BottomSheetCloseTriggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bottomSheetCloseTriggerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bottomSheetCloseTriggerHash();

  @$internal
  @override
  BottomSheetCloseTrigger create() => BottomSheetCloseTrigger();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$bottomSheetCloseTriggerHash() =>
    r'5700caf19f597bc96979731a27c19f9304ccafca';

/// Provider for tracking if bottom sheet should be closed
/// Set to true to trigger bottom sheet closure

abstract class _$BottomSheetCloseTrigger extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

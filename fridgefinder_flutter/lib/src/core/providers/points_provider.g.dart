// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'points_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for user's points

@ProviderFor(userPoints)
const userPointsProvider = UserPointsProvider._();

/// Provider for user's points

final class UserPointsProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Provider for user's points
  const UserPointsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userPointsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userPointsHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return userPoints(ref);
  }
}

String _$userPointsHash() => r'41decca7c923d8f3aec0baff64c8f5692643036f';

/// Notifier for managing points

@ProviderFor(PointsManager)
const pointsManagerProvider = PointsManagerProvider._();

/// Notifier for managing points
final class PointsManagerProvider
    extends $AsyncNotifierProvider<PointsManager, void> {
  /// Notifier for managing points
  const PointsManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pointsManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pointsManagerHash();

  @$internal
  @override
  PointsManager create() => PointsManager();
}

String _$pointsManagerHash() => r'4d39943958c2f1dd6dd0a89fd1a58039870b2dbb';

/// Notifier for managing points

abstract class _$PointsManager extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}

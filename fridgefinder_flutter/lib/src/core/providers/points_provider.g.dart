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
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
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
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return userPoints(ref);
  }
}

String _$userPointsHash() => r'07b4af30dd17d5f0a00df429c6f145a97b749330';

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

String _$pointsManagerHash() => r'57b66979abcd385a09d9385f24aca76dba5b3e30';

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

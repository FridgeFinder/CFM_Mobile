// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_rewards_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userRewardsRepository)
const userRewardsRepositoryProvider = UserRewardsRepositoryProvider._();

final class UserRewardsRepositoryProvider
    extends
        $FunctionalProvider<
          UserRewardsRepository,
          UserRewardsRepository,
          UserRewardsRepository
        >
    with $Provider<UserRewardsRepository> {
  const UserRewardsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userRewardsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userRewardsRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserRewardsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserRewardsRepository create(Ref ref) {
    return userRewardsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserRewardsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserRewardsRepository>(value),
    );
  }
}

String _$userRewardsRepositoryHash() =>
    r'20dca04a3141e0acc6c74e17a62b2dd5cd4b9395';

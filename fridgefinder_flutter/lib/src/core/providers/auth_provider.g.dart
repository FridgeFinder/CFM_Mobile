// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for AuthRepository

@ProviderFor(authRepository)
const authRepositoryProvider = AuthRepositoryProvider._();

/// Provider for AuthRepository

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// Provider for AuthRepository
  const AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'22fc0d03b89a59e112b7d39093f330eeb7417497';

/// Provider for current Firebase Auth user

@ProviderFor(authUser)
const authUserProvider = AuthUserProvider._();

/// Provider for current Firebase Auth user

final class AuthUserProvider
    extends
        $FunctionalProvider<
          AsyncValue<firebase_auth.User?>,
          firebase_auth.User?,
          Stream<firebase_auth.User?>
        >
    with
        $FutureModifier<firebase_auth.User?>,
        $StreamProvider<firebase_auth.User?> {
  /// Provider for current Firebase Auth user
  const AuthUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authUserHash();

  @$internal
  @override
  $StreamProviderElement<firebase_auth.User?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<firebase_auth.User?> create(Ref ref) {
    return authUser(ref);
  }
}

String _$authUserHash() => r'dcab000a047790ae422fec96858a0f4b887844a8';

/// Provider for current authenticated user (nullable)
/// This watches the auth state stream and returns the current user

@ProviderFor(currentAuthUser)
const currentAuthUserProvider = CurrentAuthUserProvider._();

/// Provider for current authenticated user (nullable)
/// This watches the auth state stream and returns the current user

final class CurrentAuthUserProvider
    extends
        $FunctionalProvider<
          AsyncValue<firebase_auth.User?>,
          AsyncValue<firebase_auth.User?>,
          AsyncValue<firebase_auth.User?>
        >
    with $Provider<AsyncValue<firebase_auth.User?>> {
  /// Provider for current authenticated user (nullable)
  /// This watches the auth state stream and returns the current user
  const CurrentAuthUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentAuthUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentAuthUserHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<firebase_auth.User?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<firebase_auth.User?> create(Ref ref) {
    return currentAuthUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<firebase_auth.User?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<firebase_auth.User?>>(
        value,
      ),
    );
  }
}

String _$currentAuthUserHash() => r'06969c84ef3be0f2a77accdf346ed15925c41135';

/// Provider for user profile

@ProviderFor(userProfile)
const userProfileProvider = UserProfileProvider._();

/// Provider for user profile

final class UserProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserProfile?>,
          UserProfile?,
          FutureOr<UserProfile?>
        >
    with $FutureModifier<UserProfile?>, $FutureProvider<UserProfile?> {
  /// Provider for user profile
  const UserProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProfileHash();

  @$internal
  @override
  $FutureProviderElement<UserProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UserProfile?> create(Ref ref) {
    return userProfile(ref);
  }
}

String _$userProfileHash() => r'3cb5884614cfbe2b599889b33c1441fc945390c9';

/// Provider for checking if user is authenticated
/// Watches the auth state stream to reactively update

@ProviderFor(isAuthenticated)
const isAuthenticatedProvider = IsAuthenticatedProvider._();

/// Provider for checking if user is authenticated
/// Watches the auth state stream to reactively update

final class IsAuthenticatedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider for checking if user is authenticated
  /// Watches the auth state stream to reactively update
  const IsAuthenticatedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAuthenticatedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAuthenticatedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isAuthenticated(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAuthenticatedHash() => r'5d11c591acebeb1c703d1b318d396598f404a230';

/// Provider for checking if profile is complete
/// Profile is complete if:
/// - Username is set (non-empty)
/// - Profile object exists

@ProviderFor(isProfileComplete)
const isProfileCompleteProvider = IsProfileCompleteProvider._();

/// Provider for checking if profile is complete
/// Profile is complete if:
/// - Username is set (non-empty)
/// - Profile object exists

final class IsProfileCompleteProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Provider for checking if profile is complete
  /// Profile is complete if:
  /// - Username is set (non-empty)
  /// - Profile object exists
  const IsProfileCompleteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isProfileCompleteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isProfileCompleteHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return isProfileComplete(ref);
  }
}

String _$isProfileCompleteHash() => r'eca04169572691d9e5950154ac7073d670a0683f';

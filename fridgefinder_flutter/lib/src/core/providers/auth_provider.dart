import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/domain/models/user_profile.dart';
import '../utils/app_logger.dart';

part 'auth_provider.g.dart';

/// Provider for AuthRepository
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository();
}

/// Provider for current Firebase Auth user
@riverpod
Stream<firebase_auth.User?> authUser(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  logger.d('[AuthProvider] Setting up auth state stream');
  return repository.authStateChanges.map((user) {
    logger.d('[AuthProvider] Auth state changed: ${user?.uid ?? "null"}');
    return user;
  });
}

/// Provider for current authenticated user (nullable)
/// This watches the auth state stream and returns the current user
@riverpod
AsyncValue<firebase_auth.User?> currentAuthUser(Ref ref) {
  // Watch the stream provider - it returns AsyncValue automatically
  final authUserAsync = ref.watch(authUserProvider);
  logger.d('[AuthProvider] currentAuthUser state: ${authUserAsync.when(
    data: (user) => user?.uid ?? 'null',
    loading: () => 'loading',
    error: (err, _) => 'error: $err',
  )}');
  return authUserAsync;
}

/// Provider for user profile
@riverpod
Future<UserProfile?> userProfile(Ref ref) async {
  final authUserAsync = ref.watch(currentAuthUserProvider);
  // Extract user from AsyncValue
  final authUser = authUserAsync.when(
    data: (user) => user,
    loading: () => null,
    error: (_, _) => null,
  );
  if (authUser == null) {
    logger.d('[AuthProvider] No auth user, returning null profile');
    return null;
  }

  logger.d('[AuthProvider] Fetching profile for user: ${authUser.uid}');
  final repository = ref.watch(authRepositoryProvider);
  final profile = await repository.getUserProfile(authUser.uid);

  // Update last login if profile exists
  if (profile != null) {
    logger.d('[AuthProvider] Profile found: ${profile.username}');
    repository.updateLastLogin(authUser.uid);
  } else {
    logger.d('[AuthProvider] No profile found for user: ${authUser.uid}');
  }

  return profile;
}

/// Provider for checking if user is authenticated
/// Watches the auth state stream to reactively update
@riverpod
bool isAuthenticated(Ref ref) {
  final authUserAsync = ref.watch(authUserProvider);
  // Extract boolean from AsyncValue
  final isAuth = authUserAsync.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, _) {
      // Log error but return false
      logger.w('[AuthProvider] Error in auth stream, treating as not authenticated');
      return false;
    },
  );
  logger.d('[AuthProvider] isAuthenticated: $isAuth');
  return isAuth;
}

/// Provider for checking if profile is complete
/// Profile is complete if:
/// - Username is set (non-empty)
/// - isVolunteer is set (always required)
/// - zipCode is set if user is a volunteer
@riverpod
Future<bool> isProfileComplete(Ref ref) async {
  final profileAsync = ref.watch(userProfileProvider);

  return profileAsync.when(
    data: (profile) {
      if (profile == null) {
        logger.d('[AuthProvider] Profile is null, incomplete');
        return false;
      }

      // Check if username is set
      if (profile.username.isEmpty) {
        logger.d('[AuthProvider] Username is empty, profile incomplete');
        return false;
      }

      logger.d('[AuthProvider] Profile is complete');
      return true;
    },
    loading: () {
      logger.d('[AuthProvider] Profile loading, treating as incomplete');
      return false;
    },
    error: (_, _) {
      logger.w('[AuthProvider] Error loading profile, treating as incomplete');
      return false;
    },
  );
}


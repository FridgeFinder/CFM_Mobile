import 'dart:async';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/domain/models/user_profile.dart';
import 'dio_provider.dart';
import '../utils/app_logger.dart';

part 'auth_provider.g.dart';

const _profileCacheBoxName = 'profile_cache';
String _profileCacheKey(String userId) => 'profile_$userId';

Future<Box<String>?> _openProfileCacheBox() async {
  try {
    return await Hive.openBox<String>(_profileCacheBoxName);
  } catch (e) {
    logger.w('[AuthProvider] Unable to open profile cache box: $e');
    return null;
  }
}

/// Provider for AuthRepository
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(dio: ref.watch(userDioProvider));
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
/// Returns cached data immediately, then refreshes from the API in the background.
/// Re-builds only when the API response differs from the cached value.
@riverpod
Future<UserProfile?> userProfile(Ref ref) async {
  var isDisposed = false;
  ref.onDispose(() => isDisposed = true);

  final authUserAsync = ref.watch(currentAuthUserProvider);
  final authUser = authUserAsync.when(
    data: (user) => user,
    loading: () => null,
    error: (_, _) => null,
  );
  if (authUser == null) {
    logger.d('[AuthProvider] No auth user, returning null profile');
    return null;
  }

  final cacheBox = await _openProfileCacheBox();
  if (isDisposed || !ref.mounted) return null;

  final cacheKey = _profileCacheKey(authUser.uid);
  final cachedJson = cacheBox?.get(cacheKey);
  UserProfile? cachedProfile;
  if (cachedJson != null) {
    try {
      cachedProfile = UserProfile.fromJson(
        jsonDecode(cachedJson) as Map<String, dynamic>,
      );
    } catch (e) {
      logger.w('[AuthProvider] Failed to deserialize cached profile: $e');
    }
  }

  final repository = ref.read(authRepositoryProvider);

  if (cachedProfile != null) {
    // Return cached immediately, refresh in the background.
    unawaited(() async {
      try {
        if (isDisposed || !ref.mounted) return;
        final freshProfile = await repository.getUserProfile(authUser.uid);
        if (isDisposed || !ref.mounted) return;

        if (freshProfile != null) {
          final freshJson = jsonEncode(freshProfile.toJson());
          if (freshJson != cachedJson) {
            await cacheBox?.put(cacheKey, freshJson);
            if (isDisposed || !ref.mounted) return;
            ref.invalidateSelf();
          }
        } else {
          // Profile no longer exists — clear cache and rebuild.
          await cacheBox?.delete(cacheKey);
          if (isDisposed || !ref.mounted) return;
          ref.invalidateSelf();
        }
      } catch (e) {
        logger.e('[AuthProvider] Error refreshing profile from API: $e');
      }
    }());

    logger.d('[AuthProvider] Returning cached profile for: ${authUser.uid}');
    return cachedProfile;
  }

  // No cache — blocking fetch on first load.
  logger.d('[AuthProvider] No cache, fetching profile for: ${authUser.uid}');
  final profile = await repository.getUserProfile(authUser.uid);
  if (profile != null) {
    logger.d('[AuthProvider] Profile found: ${profile.username}');
    try {
      await cacheBox?.put(cacheKey, jsonEncode(profile.toJson()));
    } catch (e) {
      logger.w('[AuthProvider] Failed to write profile cache: $e');
    }
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
/// - Profile object exists
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


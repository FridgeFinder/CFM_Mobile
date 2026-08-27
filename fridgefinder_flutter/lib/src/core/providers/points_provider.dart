import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_provider.dart';
import '../../features/auth/data/repositories/user_rewards_repository.dart';
import '../utils/app_logger.dart';

part 'points_provider.g.dart';

const _pointsCacheBoxName = 'points_cache';

final Map<String, int> _inMemoryPointsCache = {};

String _pointsCacheKey(String userId) => 'points_$userId';

Future<Box<int>?> _openPointsCacheBox() async {
  try {
    return await Hive.openBox<int>(_pointsCacheBoxName);
  } catch (e) {
    logger.w('Unable to open points cache box: $e');
    return null;
  }
}

/// Provider for user's points
@riverpod
Future<int> userPoints(Ref ref) async {
  var isDisposed = false;
  ref.onDispose(() {
    isDisposed = true;
  });

  final profile = await ref.watch(userProfileProvider.future);
  final authUserAsync = ref.watch(currentAuthUserProvider);
  final authUser = authUserAsync.when(
    data: (user) => user,
    loading: () => null,
    error: (_, _) => null,
  );

  final userId = profile?.userId ?? authUser?.uid;
  if (userId == null) {
    return 0;
  }

  final cacheBox = await _openPointsCacheBox();
  if (isDisposed || !ref.mounted) {
    return 0;
  }

  final cacheKey = _pointsCacheKey(userId);
  final cachedPoints =
      cacheBox?.get(cacheKey, defaultValue: 0) ??
      _inMemoryPointsCache[cacheKey] ??
      0;

  Future<void> refreshFromApi() async {
    try {
      if (isDisposed || !ref.mounted) return;
      final repository = ref.read(userRewardsRepositoryProvider);
      final stats = await repository.getUserActionStats(userId);
      if (isDisposed || !ref.mounted) return;

      final latestPoints = stats?.totalPoints ?? 0;

      if (cacheBox != null) {
        final storedPoints = cacheBox.get(cacheKey, defaultValue: 0) ?? 0;
        if (latestPoints != storedPoints) {
          await cacheBox.put(cacheKey, latestPoints);
          if (isDisposed || !ref.mounted) return;
          ref.invalidateSelf();
        }
      } else if (latestPoints != cachedPoints) {
        _inMemoryPointsCache[cacheKey] = latestPoints;
        if (isDisposed || !ref.mounted) return;
        ref.invalidateSelf();
      }
    } catch (e) {
      logger.e('Error loading points from rewards API: $e');
    }
  }

  // Refresh once immediately in the background when points are requested
  // (for example when the user opens the profile page).
  unawaited(refreshFromApi());

  // Return cached value immediately to avoid profile points flicker.
  return cachedPoints;
}

/// Notifier for managing points
@riverpod
class PointsManager extends _$PointsManager {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Refresh points from the backend after a user action.
  Future<void> refreshPointsFromBackend() async {
    logger.i('Refreshing points from rewards API.');
    ref.invalidate(userPointsProvider);
  }
}


import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_provider.dart';
import 'database_provider.dart';
import '../utils/app_logger.dart';

part 'points_provider.g.dart';

/// Provider for user's points
@riverpod
Stream<int> userPoints(Ref ref) async* {
  final authUserAsync = ref.watch(currentAuthUserProvider);
  final authUser = authUserAsync.when(
    data: (user) => user,
    loading: () => null,
    error: (_, _) => null,
  );
  if (authUser == null) {
    yield 0;
    return;
  }

  final database = DatabaseProvider.databaseRef;
  final pointsRef = database.child('users').child(authUser.uid).child('points');

  yield* pointsRef.onValue.map((event) {
    if (!event.snapshot.exists) {
      return 0;
    }
    final value = event.snapshot.value;
    if (value is int) {
      return value;
    }
    return 0;
  });
}

/// Notifier for managing points
@riverpod
class PointsManager extends _$PointsManager {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Award points to user
  Future<void> awardPoints(int points) async {
    try {
      final authUserAsync = ref.read(currentAuthUserProvider);
      final authUser = authUserAsync.when(
        data: (user) => user,
        loading: () => null,
        error: (_, _) => null,
      );
      if (authUser == null) {
        throw Exception('User must be authenticated');
      }

      final database = DatabaseProvider.databaseRef;
      final pointsRef = database.child('users').child(authUser.uid).child('points');

      // Get current points
      final snapshot = await pointsRef.get();
      final currentPoints = snapshot.exists && snapshot.value is int
          ? snapshot.value as int
          : 0;

      // Update points atomically
      await pointsRef.set(currentPoints + points);
      logger.i('Awarded $points points. Total: ${currentPoints + points}');
    } catch (e) {
      logger.e('Error awarding points: $e');
      rethrow;
    }
  }

  /// Calculate and award points for status report
  Future<void> awardPointsForStatusReport({
    required bool wasDirty,
    required bool isNowGood,
    required double previousFoodPercentage,
    required double newFoodPercentage,
    required bool isVolunteer,
  }) async {
    if (!isVolunteer) return;

    int points = 10; // Base points

    // Cleaning bonus
    if (wasDirty && isNowGood) {
      points += 20;
    }

    // Stocking bonus
    final foodIncrease = newFoodPercentage - previousFoodPercentage;
    if (foodIncrease > 0.3 || (previousFoodPercentage == 0 && newFoodPercentage > 0.5)) {
      points += 30;
    }

    await awardPoints(points);
  }
}


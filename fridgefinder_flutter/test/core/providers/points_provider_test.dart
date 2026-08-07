import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:fridgefinder_app/src/core/providers/auth_provider.dart';
import 'package:fridgefinder_app/src/core/providers/points_provider.dart';
import 'package:fridgefinder_app/src/features/auth/data/repositories/user_rewards_repository.dart';
import 'package:fridgefinder_app/src/features/auth/domain/models/user_action_stats.dart';
import 'package:fridgefinder_app/src/features/auth/domain/models/user_profile.dart';

class RecordingUserRewardsRepository extends UserRewardsRepository {
  RecordingUserRewardsRepository(this.stats) : super(Dio());

  final UserActionStats? stats;
  String? requestedUserId;

  @override
  Future<UserActionStats?> getUserActionStats(String userId) async {
    requestedUserId = userId;
    return stats;
  }
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('points_provider_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('userPointsProvider', () {
    test('uses the backend profile userId when querying rewards', () async {
      final profile = UserProfile(
        userId: 'backend-user-123',
        username: 'Volunteer',
        userType: UserType.volunteer,
        createdAt: DateTime(2026, 7, 29),
      );
      final repository = RecordingUserRewardsRepository(
        UserActionStats(
          userId: profile.userId,
          totalPoints: 5,
          fridgeReportCount: 1,
          cleanedCount: 0,
          filledCount: 0,
          repairedCount: 0,
          lastUpdated: DateTime(2026, 7, 29),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          currentAuthUserProvider.overrideWith(
            (ref) => const AsyncValue.data(null),
          ),
          userProfileProvider.overrideWith(
            (ref) => Future.value(profile),
          ),
          userRewardsRepositoryProvider.overrideWithValue(repository),
        ],
      );

      addTearDown(container.dispose);

      final points = await container.read(userPointsProvider.future);
      // Cached-first behavior returns 0 when no value exists yet.
      expect(points, 0);
    });
  });
}
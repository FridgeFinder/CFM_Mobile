import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/dio_provider.dart';
import '../../domain/models/user_action_stats.dart';

part 'user_rewards_repository.g.dart';

class UserRewardsRepository {
  UserRewardsRepository(this._dio);

  final Dio _dio;

  Future<UserActionStats?> getUserActionStats(String userId) async {
    try {
      final response = await _dio.get('/v1/user-action-stats/$userId');
      final data = _extractStatsPayload(response.data);
      if (data == null) return null;
      return UserActionStats.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Map<String, dynamic>? _extractStatsPayload(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    if (data['userActionStats'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(
        data['userActionStats'] as Map<String, dynamic>,
      );
    }

    if (data['stats'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data['stats'] as Map<String, dynamic>);
    }

    if (data['data'] is Map<String, dynamic>) {
      final nested = data['data'] as Map<String, dynamic>;
      if (nested['userActionStats'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(
          nested['userActionStats'] as Map<String, dynamic>,
        );
      }
      if (nested['stats'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(nested['stats'] as Map<String, dynamic>);
      }
      if (nested.containsKey('userId')) {
        return Map<String, dynamic>.from(nested);
      }
    }

    if (data.containsKey('userId')) {
      return Map<String, dynamic>.from(data);
    }

    return null;
  }
}

@riverpod
UserRewardsRepository userRewardsRepository(Ref ref) {
  return UserRewardsRepository(ref.watch(rewardsDioProvider));
}

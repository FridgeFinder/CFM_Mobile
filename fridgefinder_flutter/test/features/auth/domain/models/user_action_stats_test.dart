import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/features/auth/domain/models/user_action_stats.dart';

void main() {
  test('UserActionStats.fromJson accepts string numeric fields', () {
    final stats = UserActionStats.fromJson({
      'userId': 'user-1',
      'totalPoints': '5',
      'fridgeReportCount': '2',
      'cleanedCount': 1,
      'filledCount': 0,
      'repairedCount': '3',
      'lastUpdated': '2026-07-29T12:00:00.000Z',
    });

    expect(stats.userId, 'user-1');
    expect(stats.totalPoints, 5);
    expect(stats.fridgeReportCount, 2);
    expect(stats.cleanedCount, 1);
    expect(stats.repairedCount, 3);
    expect(stats.lastUpdated.toUtc(), DateTime.parse('2026-07-29T12:00:00.000Z'));
  });
}
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/features/auth/domain/models/user_profile.dart';

void main() {
  group('UserProfile - fcmTokens field', () {
    test('fromJson with old fcmToken string deserializes — fcmToken is set, fcmTokens is null',
        () {
      final json = {
        'userId': 'user1',
        'username': 'testuser',
        'isVolunteer': false,
        'fcmToken': 'old_token_string',
        'createdAt': '2024-01-01T00:00:00.000',
      };

      final profile = UserProfile.fromJson(json);
      expect(profile.fcmToken, equals('old_token_string'));
      expect(profile.fcmTokens, isNull);
    });

    test('fromJson with new fcmTokens map deserializes correctly', () {
      final json = {
        'userId': 'user1',
        'username': 'testuser',
        'isVolunteer': false,
        'fcmTokens': {'dev1': 'tok1', 'dev2': 'tok2'},
        'createdAt': '2024-01-01T00:00:00.000',
      };

      final profile = UserProfile.fromJson(json);
      expect(profile.fcmTokens, isNotNull);
      expect(profile.fcmTokens!['dev1'], equals('tok1'));
      expect(profile.fcmTokens!['dev2'], equals('tok2'));
    });

    test('fromJson with BOTH fields populates both', () {
      final json = {
        'userId': 'user1',
        'username': 'testuser',
        'isVolunteer': false,
        'fcmToken': 'latest_token',
        'fcmTokens': {'dev1': 'tok1'},
        'createdAt': '2024-01-01T00:00:00.000',
      };

      final profile = UserProfile.fromJson(json);
      expect(profile.fcmToken, equals('latest_token'));
      expect(profile.fcmTokens, isNotNull);
      expect(profile.fcmTokens!['dev1'], equals('tok1'));
    });

    test('toJson includes fcmTokens when set', () {
      final profile = UserProfile(
        userId: 'user1',
        username: 'testuser',
        isVolunteer: false,
        fcmToken: 'tok',
        fcmTokens: {'dev1': 'tok1'},
        createdAt: DateTime(2024, 1, 1),
      );

      final json = profile.toJson();
      expect(json['fcmTokens'], isNotNull);
      expect((json['fcmTokens'] as Map)['dev1'], equals('tok1'));
    });

    test('toJson excludes fcmTokens when null', () {
      final profile = UserProfile(
        userId: 'user1',
        username: 'testuser',
        isVolunteer: false,
        createdAt: DateTime(2024, 1, 1),
      );

      final json = profile.toJson();
      expect(json['fcmTokens'], isNull);
    });

    test('copyWith works for fcmTokens', () {
      final profile = UserProfile(
        userId: 'user1',
        username: 'testuser',
        isVolunteer: false,
        createdAt: DateTime(2024, 1, 1),
      );

      final updated = profile.copyWith(
        fcmTokens: {'dev1': 'tok1', 'dev2': 'tok2'},
      );

      expect(updated.fcmTokens, isNotNull);
      expect(updated.fcmTokens!.length, equals(2));
      expect(profile.fcmTokens, isNull); // original unchanged
    });
  });
}

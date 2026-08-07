import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/features/auth/domain/models/user_profile.dart';

void main() {
  group('UserProfile model', () {
    test('fromJson parses current shape', () {
      final json = {
        'userId': 'user1',
        'username': 'testuser',
        'userType': 'volunteer',
        'zipcode': '94107',
        'points': 12,
        'settings': {
          'emailNotificationEnabled': true,
          'geofencingEnabled': true,
        },
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      final profile = UserProfile.fromJson(json);
      expect(profile.userId, 'user1');
      expect(profile.userType, UserType.volunteer);
      expect(profile.zipcode, '94107');
      expect(profile.zipCode, '94107');
      expect(profile.points, 12);
      expect(profile.settings.emailNotificationEnabled, isTrue);
      expect(profile.settings.geofencingEnabled, isTrue);
    });

    test('toJson writes current shape', () {
      final profile = UserProfile(
        userId: 'user2',
        username: 'neighbor-user',
        userType: UserType.neighbor,
        zipcode: '10001',
        points: 3,
        settings: const UserSettings(
          emailNotificationEnabled: false,
          geofencingEnabled: false,
        ),
        createdAt: DateTime.utc(2025, 1, 1),
      );

      final json = profile.toJson();
      expect(json['userType'], 'neighbor');
      expect(json['zipcode'], '10001');
      expect(json['points'], 3);
      expect(json.containsKey('fcmToken'), isFalse);
      expect(json.containsKey('fcmTokens'), isFalse);
    });

    test('copyWith updates userType and zipcode', () {
      final profile = UserProfile(
        userId: 'user3',
        username: 'copy-user',
        userType: UserType.neighbor,
        createdAt: DateTime.utc(2025, 1, 1),
      );

      final updated = profile.copyWith(
        userType: UserType.host,
        zipcode: '30301',
      );

      expect(updated.userType, UserType.host);
      expect(updated.zipcode, '30301');
      expect(profile.userType, UserType.neighbor);
      expect(profile.zipcode, isNull);
    });
  });
}

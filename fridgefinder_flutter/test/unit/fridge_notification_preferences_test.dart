import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/features/auth/domain/models/fridge_notification_preferences.dart';

void main() {
  group('FridgeNotificationPreferences', () {
    test('fromJson works without a legacy subscribedAt field', () {
      final json = {
        'fridgeId': 'fridge-123',
        'updatedAt': '2024-01-01T00:00:00.000Z',
        'notificationPreferences': {
          'contactTypePreferences': {
            'email': {'good': true, 'dirty': false, 'outOfOrder': false},
            'device': {'good': true, 'dirty': false, 'outOfOrder': false},
          },
        },
      };

      final preferences = FridgeNotificationPreferences.fromJson(json);

      expect(preferences.fridgeId, 'fridge-123');
      expect(preferences.updatedAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
      expect(
        preferences.notificationPreferences.contactTypePreferences.email.good,
        isTrue,
      );
    });
  });
}

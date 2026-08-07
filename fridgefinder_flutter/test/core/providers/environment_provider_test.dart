import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/core/providers/environment_provider.dart';

void main() {
  group('ApiEnvironment', () {
    test('prod fridgeApiBaseUrl is production API', () {
      expect(
        ApiEnvironment.prod.fridgeApiBaseUrl,
        'https://api-prod.communityfridgefinder.com/v1',
      );
    });

    test('dev fridgeApiBaseUrl is development API', () {
      expect(
        ApiEnvironment.dev.fridgeApiBaseUrl,
        'https://api-dev.communityfridgefinder.com/v1',
      );
    });

    test('prod usersApiBaseUrl is production user API', () {
      expect(
        ApiEnvironment.prod.usersApiBaseUrl,
        'https://users-api-prod.communityfridgefinder.com/v1',
      );
    });

    test('prod notificationsApiBaseUrl is production notifications API', () {
      expect(
        ApiEnvironment.prod.notificationsApiBaseUrl,
        'https://notifications-api-prod.communityfridgefinder.com/v1',
      );
    });

    test('prod rewardsApiBaseUrl is production rewards API', () {
      expect(
        ApiEnvironment.prod.rewardsApiBaseUrl,
        'https://user-rewards-api-prod.communityfridgefinder.com',
      );
    });

    test('dev usersApiBaseUrl is development user API', () {
      expect(
        ApiEnvironment.dev.usersApiBaseUrl,
        'https://users-api-dev.communityfridgefinder.com/v1',
      );
    });

    test('dev notificationsApiBaseUrl is development notifications API', () {
      expect(
        ApiEnvironment.dev.notificationsApiBaseUrl,
        'https://notifications-api-dev.communityfridgefinder.com/v1',
      );
    });

    test('dev rewardsApiBaseUrl is development rewards API', () {
      expect(
        ApiEnvironment.dev.rewardsApiBaseUrl,
        'https://user-rewards-api-dev.communityfridgefinder.com',
      );
    });

    test('prod databaseUrl is production RTDB', () {
      expect(
        ApiEnvironment.prod.databaseUrl,
        'https://fridgefinder-app-default-rtdb.firebaseio.com/',
      );
    });

    test('dev databaseUrl is development RTDB', () {
      expect(
        ApiEnvironment.dev.databaseUrl,
        'https://fridgefinder-app-dev-default-rtdb.firebaseio.com/',
      );
    });
  });
}

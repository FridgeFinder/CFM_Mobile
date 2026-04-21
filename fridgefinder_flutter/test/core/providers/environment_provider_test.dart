import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/core/providers/environment_provider.dart';

void main() {
  group('ApiEnvironment', () {
    test('prod baseUrl is production API', () {
      expect(
        ApiEnvironment.prod.baseUrl,
        'https://api-prod.communityfridgefinder.com/v1',
      );
    });

    test('dev baseUrl is development API', () {
      expect(
        ApiEnvironment.dev.baseUrl,
        'https://api-dev.communityfridgefinder.com/v1',
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

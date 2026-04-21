import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/core/providers/database_provider.dart';
import 'package:fridgefinder_app/src/core/providers/environment_provider.dart';

void main() {
  group('DatabaseProvider', () {
    tearDown(() {
      // Reset to prod after each test to prevent pollution
      DatabaseProvider.configure(ApiEnvironment.prod);
    });

    test('default URL is prod (backward compatible)', () {
      expect(
        DatabaseProvider.databaseUrl,
        'https://fridgefinder-app-default-rtdb.firebaseio.com/',
      );
    });

    test('configure(dev) switches to dev URL', () {
      DatabaseProvider.configure(ApiEnvironment.dev);
      expect(
        DatabaseProvider.databaseUrl,
        'https://fridgefinder-app-dev-default-rtdb.firebaseio.com/',
      );
    });

    test('configure(prod) switches to prod URL', () {
      DatabaseProvider.configure(ApiEnvironment.dev);
      DatabaseProvider.configure(ApiEnvironment.prod);
      expect(
        DatabaseProvider.databaseUrl,
        'https://fridgefinder-app-default-rtdb.firebaseio.com/',
      );
    });
  });
}

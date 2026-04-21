import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/core/config/firebase_options_resolver.dart';
import 'package:fridgefinder_app/src/core/providers/environment_provider.dart';

void main() {
  group('FirebaseOptionsResolver', () {
    test('prod env resolves to project ID fridgefinder-app', () {
      final options = FirebaseOptionsResolver.resolve(ApiEnvironment.prod);
      expect(options.projectId, 'fridgefinder-app');
    });

    test('dev env resolves to project ID fridgefinder-app-dev', () {
      final options = FirebaseOptionsResolver.resolve(ApiEnvironment.dev);
      expect(options.projectId, 'fridgefinder-app-dev');
    });
  });
}

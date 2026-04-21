import 'package:firebase_core/firebase_core.dart';
import '../../../firebase_options.dart' as prod;
import '../../../firebase_options_dev.dart' as dev;
import '../providers/environment_provider.dart';

class FirebaseOptionsResolver {
  static FirebaseOptions resolve(ApiEnvironment environment) {
    switch (environment) {
      case ApiEnvironment.prod:
        return prod.DefaultFirebaseOptions.currentPlatform;
      case ApiEnvironment.dev:
        return dev.DefaultFirebaseOptions.currentPlatform;
    }
  }
}

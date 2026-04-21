import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'environment_provider.dart';

/// Provider for Firebase Realtime Database instance.
///
/// Defaults to production. Call [configure] during bootstrap to switch
/// to the dev project's RTDB when the user has selected dev environment.
class DatabaseProvider {
  static String _databaseUrl =
      'https://fridgefinder-app-default-rtdb.firebaseio.com/';

  /// Current database URL (exposed for testing).
  static String get databaseUrl => _databaseUrl;

  /// Configure the database URL based on the selected environment.
  /// Called once during app bootstrap in main.dart.
  static void configure(ApiEnvironment environment) {
    _databaseUrl = environment.databaseUrl;
  }

  static DatabaseReference get databaseRef {
    return FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: _databaseUrl,
    ).ref();
  }
}

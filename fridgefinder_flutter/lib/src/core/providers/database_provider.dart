import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

/// Provider for Firebase Realtime Database instance
///
/// PRODUCTION ENVIRONMENT ONLY
/// This always uses the production Firebase Realtime Database.
/// Not affected by fridge data API environment setting.
/// Database URL: https://fridgefinder-app-default-rtdb.firebaseio.com/
class DatabaseProvider {
  static const String _databaseUrl =
      'https://fridgefinder-app-default-rtdb.firebaseio.com/';

  static DatabaseReference get databaseRef {
    return FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: _databaseUrl,
    ).ref();
  }
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../providers/database_provider.dart';
import '../utils/app_logger.dart';

/// Utility class for testing push notifications
/// These methods can be called from debug screens or test scripts
class TestNotificationUtils {
  /// Send a test FCM notification directly to the current user's FCM token
  /// This bypasses Cloud Functions for quick testing
  static Future<void> sendTestFCMNotification({
    required String fridgeId,
    String? fridgeName,
    String? title,
    String? body,
  }) async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) {
        logger.e('No user logged in. Please sign in first.');
        return;
      }

      // Get user's FCM token from database (prefer new multi-device path)
      final database = DatabaseProvider.databaseRef;
      final userRef = database.child('users').child(user.uid);
      final tokensSnapshot = await userRef.child('fcmTokens').once();
      final tokensMap = tokensSnapshot.snapshot.value as Map<dynamic, dynamic>?;
      String? fcmToken;
      if (tokensMap != null && tokensMap.isNotEmpty) {
        fcmToken = tokensMap.values.first as String;
      } else {
        // Fallback to old single-token path
        final snapshot = await userRef.child('fcmToken').once();
        fcmToken = snapshot.snapshot.value as String?;
      }
      if (fcmToken == null) {
        logger.e('No FCM token found for user. Please follow a fridge first.');
        return;
      }

      logger.i('Sending test FCM notification to token: ${fcmToken.substring(0, 20)}...');

      // Note: Direct FCM sending requires Firebase Admin SDK
      // This is a placeholder - actual implementation would use Cloud Functions
      // or Firebase Admin SDK from a backend service
      logger.w('Direct FCM sending requires Firebase Admin SDK.');
      logger.i('To test FCM notifications:');
      logger.i('1. Use Firebase Console > Cloud Messaging > Send test message');
      logger.i('2. Submit a normal status update from the app UI to exercise end-to-end notifications');
      logger.i('3. Or use Firebase Console test messaging with a real token');
    } catch (e) {
      logger.e('Error sending test FCM notification: $e');
      rethrow;
    }
  }

  /// Legacy helper kept for API compatibility with the debug screen.
  /// Direct RTDB status report writes are disabled in favor of API-first flows.
  static Future<String> createTestStatusReport({
    required String fridgeId,
    String? fridgeName,
    required String condition,
    required double foodPercentage,
    String? notes,
    String? photoUrl,
    String? title,
    String? body,
  }) async {
    logger.w(
      'createTestStatusReport is disabled. Submit a real fridge status update via API flow instead.',
    );
    throw UnsupportedError(
      'createTestStatusReport is disabled. Submit a status update from the app UI instead.',
    );
  }

  /// Get current user's FCM token
  static Future<String?> getCurrentUserFCMToken() async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) {
        logger.e('No user logged in.');
        return null;
      }

      // Try to get from Firebase Messaging first
      try {
        final messaging = FirebaseMessaging.instance;
        final token = await messaging.getToken();
        if (token != null && token.isNotEmpty) {
          logger.i('FCM Token from FirebaseMessaging: ${token.substring(0, 20)}...');
          return token;
        }
      } catch (e) {
        // On iOS, APNS token might not be available yet - this is OK, fall back to database
        logger.d('Could not get token from FirebaseMessaging (may be iOS APNS issue): $e');
      }

      // Fallback to database
      final database = DatabaseProvider.databaseRef;
      final snapshot = await database
          .child('users')
          .child(user.uid)
          .child('fcmToken')
          .once();
      
      final dbToken = snapshot.snapshot.value as String?;
      if (dbToken != null && dbToken.isNotEmpty) {
        logger.i('FCM Token from database: ${dbToken.substring(0, 20)}...');
        return dbToken;
      } else {
        logger.w('No FCM token found in database.');
      }

      return null;
    } catch (e) {
      logger.e('Error getting FCM token: $e');
      return null;
    }
  }

  /// Check if user is subscribed to a fridge
  static Future<bool> isSubscribedToFridge(String fridgeId) async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) {
        return false;
      }

      final database = DatabaseProvider.databaseRef;
      final snapshot = await database
          .child('users')
          .child(user.uid)
          .child('subscribedFridges')
          .child(fridgeId)
          .once();

      return snapshot.snapshot.exists;
    } catch (e) {
      logger.e('Error checking subscription: $e');
      return false;
    }
  }

  /// Get all fridges the user is subscribed to
  static Future<List<String>> getSubscribedFridges() async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) {
        return [];
      }

      final database = DatabaseProvider.databaseRef;
      final snapshot = await database
          .child('users')
          .child(user.uid)
          .child('subscribedFridges')
          .once();

      if (!snapshot.snapshot.exists) {
        return [];
      }

      final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        return [];
      }

      return data.keys.map((key) => key.toString()).toList();
    } catch (e) {
      logger.e('Error getting subscribed fridges: $e');
      return [];
    }
  }

  /// Print notification testing information
  static Future<void> printNotificationTestInfo() async {
    logger.i('=== Notification Testing Info ===');
    
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      logger.w('No user logged in. Please sign in first.');
      return;
    }

    logger.i('User ID: ${user.uid}');
    
    final token = await getCurrentUserFCMToken();
    if (token != null) {
      logger.i('FCM Token: ${token.substring(0, 30)}...');
    } else {
      logger.w('No FCM token found. Follow a fridge to generate one.');
    }

    final followedFridges = await getSubscribedFridges();
    logger.i('Followed Fridges: ${followedFridges.length}');
    for (final fridgeId in followedFridges) {
      logger.i('  - $fridgeId');
    }

    logger.i('=== End Notification Testing Info ===');
  }
}


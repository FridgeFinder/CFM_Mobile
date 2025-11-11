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

      // Get user's FCM token from database
      final database = DatabaseProvider.databaseRef;
      final userRef = database.child('users').child(user.uid);
      final snapshot = await userRef.child('fcmToken').once();
      
      final fcmToken = snapshot.snapshot.value as String?;
      if (fcmToken == null) {
        logger.e('No FCM token found for user. Please subscribe to a fridge first.');
        return;
      }

      logger.i('Sending test FCM notification to token: ${fcmToken.substring(0, 20)}...');

      // Note: Direct FCM sending requires Firebase Admin SDK
      // This is a placeholder - actual implementation would use Cloud Functions
      // or Firebase Admin SDK from a backend service
      logger.w('Direct FCM sending requires Firebase Admin SDK.');
      logger.i('To test FCM notifications:');
      logger.i('1. Use Firebase Console > Cloud Messaging > Send test message');
      logger.i('2. Or create a status report in the database (see createTestStatusReport)');
      logger.i('3. Or use the test notification button in the app');

      // For now, we'll create a test status report which will trigger Cloud Functions
      await createTestStatusReport(
        fridgeId: fridgeId,
        fridgeName: fridgeName ?? 'Test Fridge',
        condition: 'good',
        foodPercentage: 0.0,
        title: title,
        body: body,
      );
    } catch (e) {
      logger.e('Error sending test FCM notification: $e');
      rethrow;
    }
  }

  /// Create a test status report in Realtime Database
  /// This will trigger the Cloud Function onFridgeStatusUpdate
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
    try {
      final database = DatabaseProvider.databaseRef;
      final reportRef = database.child('statusReports').push();

      final reportData = <String, dynamic>{
        'fridgeId': fridgeId,
        'fridgeName': fridgeName ?? 'Test Fridge',
        'condition': condition,
        'foodPercentage': foodPercentage,
        'reportDate': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (photoUrl != null && photoUrl.isNotEmpty) 'photoUrl': photoUrl,
        // Add custom notification fields if provided
        if (title != null) 'testTitle': title,
        if (body != null) 'testBody': body,
      };

      await reportRef.set(reportData);
      final reportId = reportRef.key!;
      
      logger.i('Test status report created: $reportId');
      logger.i('This will trigger Cloud Function: onFridgeStatusUpdate');
      logger.i('Users subscribed to fridge $fridgeId will receive notifications');

      return reportId;
    } catch (e) {
      logger.e('Error creating test status report: $e');
      rethrow;
    }
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
      logger.w('No FCM token found. Subscribe to a fridge to generate one.');
    }

    final subscribedFridges = await getSubscribedFridges();
    logger.i('Subscribed Fridges: ${subscribedFridges.length}');
    for (final fridgeId in subscribedFridges) {
      logger.i('  - $fridgeId');
    }

    logger.i('=== End Notification Testing Info ===');
  }
}


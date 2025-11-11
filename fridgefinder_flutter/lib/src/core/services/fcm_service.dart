import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/app_logger.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../providers/database_provider.dart';
import 'local_notification_service.dart';

/// Top-level function for handling background messages (must be top-level)
/// This is declared in main.dart but kept here for reference

/// Service for managing Firebase Cloud Messaging
///
/// PRODUCTION ENVIRONMENT ONLY
/// This always uses production FCM (FirebaseMessaging.instance).
/// Not affected by fridge data API environment setting.
class FCMService {
  final FirebaseMessaging _messaging;
  final AuthRepository _authRepository;
  final LocalNotificationService _localNotifications;

  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<NotificationSettings>? _settingsSubscription;

  FCMService({
    FirebaseMessaging? messaging,
    AuthRepository? authRepository,
    LocalNotificationService? localNotifications,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _authRepository = authRepository ?? AuthRepository(),
       _localNotifications = localNotifications ?? LocalNotificationService();

  /// Initialize FCM service (without requesting permissions)
  /// Permissions should be requested when user subscribes to first fridge
  Future<void> initialize() async {
    try {
      // Initialize local notifications first
      await _localNotifications.initialize();

      // Set up message handlers (these work even without permissions)
      // Handle foreground messages
      _messageSubscription = FirebaseMessaging.onMessage.listen(
        _handleForegroundMessage,
      );

      // Handle notification taps
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check if app was opened from a notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      // Background message handler is set up in main.dart

      // Set up token refresh listener (important for iOS - captures token when APNS becomes available)
      _tokenSubscription ??= _messaging.onTokenRefresh.listen((newToken) async {
        logger.i('FCM token refreshed/became available: ${newToken.substring(0, 20)}...');
        await _saveFCMToken(newToken);
      });

      // Check if permissions are already granted and get token if so
      final settings = await _messaging.getNotificationSettings();
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Try to get token, but don't fail if APNS not ready (iOS)
        try {
          final token = await _messaging.getToken();
          if (token != null && token.isNotEmpty) {
            await _saveFCMToken(token);
            logger.i('FCM token obtained during initialization');
          }
        } catch (e) {
          // On iOS, APNS token might not be ready - that's OK, listener will catch it
          if (Platform.isIOS && e.toString().contains('apns-token-not-set')) {
            logger.d('APNS token not ready during initialization - listener will save token when available');
          } else {
            logger.w('Could not get FCM token during initialization: $e');
          }
        }
      }

      logger.i('FCM service initialized');
    } catch (e) {
      logger.e('Error initializing FCM: $e');
    }
  }

  /// Request notification permissions and get FCM token
  /// Should be called when user subscribes to their first fridge
  /// On iOS, handles APNS token availability gracefully
  Future<bool> requestPermissionsAndGetToken() async {
    try {
      // Request notification permissions
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      logger.i(
        'Notification permission status: ${settings.authorizationStatus}',
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Try to get token - returns false if APNS not ready (iOS), but listener is set up
        final tokenObtained = await _requestTokenAndSave();
        
        if (tokenObtained) {
          logger.i('FCM token obtained and saved successfully');
        } else if (Platform.isIOS) {
          logger.w('Permissions granted but APNS token not ready. Token will be saved automatically when available.');
        }
        
        // Always return true if permissions were granted
        // Token will be saved automatically via listener when available
        return true;
      } else {
        logger.w('Notification permissions not granted');
        return false;
      }
    } catch (e) {
      logger.e('Error requesting FCM permissions: $e');
      // Provide helpful error message for iOS APNS issues
      if (Platform.isIOS && e.toString().contains('apns-token-not-set')) {
        logger.w('iOS APNS token not ready. This is normal - token will be saved automatically when available.');
        return true; // Return true because permissions were likely granted
      }
      return false;
    }
  }

  /// Request FCM token and save it to user profile
  /// On iOS, waits for APNS token to be available before getting FCM token
  /// Returns true if token was obtained, false if APNS token not ready (iOS only)
  Future<bool> _requestTokenAndSave({int retryCount = 0}) async {
    const maxRetries = 5;
    const retryDelay = Duration(seconds: 2);

    // Set up token refresh listener FIRST (before trying to get token)
    // This ensures we capture the token when it becomes available
    _tokenSubscription ??= _messaging.onTokenRefresh.listen((newToken) async {
      logger.i('FCM token refreshed/became available: ${newToken.substring(0, 20)}...');
      await _saveFCMToken(newToken);
    });

    try {
      // Get FCM token
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        logger.i('FCM token obtained: ${token.substring(0, 20)}...');
        await _saveFCMToken(token);
        return true;
      } else {
        logger.w('FCM token is null or empty');
        if (Platform.isIOS && retryCount < maxRetries) {
          logger.d('Retrying token request... (attempt ${retryCount + 1}/$maxRetries)');
          await Future.delayed(retryDelay);
          return _requestTokenAndSave(retryCount: retryCount + 1);
        }
        return false;
      }
    } catch (e) {
      final errorStr = e.toString();
      final isAPNSError = errorStr.contains('apns-token-not-set');
      
      // Check if it's an APNS token error on iOS
      if (Platform.isIOS && isAPNSError && retryCount < maxRetries) {
        logger.d('APNS token not ready, retrying in ${retryDelay.inSeconds} seconds... (attempt ${retryCount + 1}/$maxRetries)');
        await Future.delayed(retryDelay);
        return _requestTokenAndSave(retryCount: retryCount + 1);
      }
      
      // If APNS token error after all retries, don't throw - just return false
      // The listener is already set up, so token will be saved when available
      if (Platform.isIOS && isAPNSError) {
        logger.w('APNS token not ready after $maxRetries retries. Token will be saved automatically when available.');
        return false; // Don't throw - listener will handle it
      }
      
      logger.e('Error getting FCM token: $e');
      rethrow; // Re-throw non-APNS errors
    }
  }

  /// Save FCM token to user profile in Realtime Database
  Future<void> _saveFCMToken(String token) async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) {
        logger.w('Cannot save FCM token: user not authenticated');
        return;
      }

      logger.d('Saving FCM token for user: ${currentUser.uid}');

      // Try to get existing profile first
      try {
        final profile = await _authRepository.getUserProfile(currentUser.uid);
        if (profile != null) {
          // Update existing profile
          final updatedProfile = profile.copyWith(fcmToken: token);
          await _authRepository.updateUserProfile(updatedProfile);
          logger.i('FCM token saved to user profile');
          return;
        }
      } catch (e) {
        logger.d('Could not get user profile (may not exist yet): $e');
      }

      // Profile doesn't exist yet - save token directly to database
      // This can happen if user signs in but profile creation is delayed
      try {
        final database = DatabaseProvider.databaseRef;
        await database
            .child('users')
            .child(currentUser.uid)
            .child('fcmToken')
            .set(token);
        logger.i('FCM token saved directly to database (profile not yet created)');
      } catch (e) {
        logger.e('Error saving FCM token directly to database: $e');
        rethrow;
      }
    } catch (e) {
      logger.e('Error saving FCM token: $e');
      rethrow;
    }
  }

  /// Public method to save FCM token (called after profile creation)
  Future<void> saveFCMToken(String token) async {
    await _saveFCMToken(token);
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    logger.i('Foreground message received: ${message.messageId}');

    // Show local notification for foreground messages
    if (message.notification != null) {
      final notification = message.notification!;
      final notificationId =
          message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch;

      _localNotifications.showNotification(
        id: notificationId,
        title: notification.title ?? 'FridgeFinder',
        body: notification.body ?? '',
        payload: message.data,
      );

      logger.i('Local notification shown: ${notification.title}');
    }
  }

  /// Handle notification tap
  /// Navigation is handled by LocalNotificationService which has access to WidgetRef
  void _handleNotificationTap(RemoteMessage message) {
    logger.i('Notification tapped: ${message.messageId}');

    // Handle navigation based on notification data
    if (message.data.containsKey('fridgeId')) {
      final fridgeId = message.data['fridgeId'] as String;
      logger.i('Opening fridge: $fridgeId');
      // Navigation will be handled by LocalNotificationService when notification is tapped
      // Set the fridge ID in the notification navigation provider
      _localNotifications.handleNotificationTap(fridgeId);
    }
  }

  /// Delete FCM token (on sign out)
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      logger.i('FCM token deleted');
    } catch (e) {
      logger.e('Error deleting FCM token: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _tokenSubscription?.cancel();
    _messageSubscription?.cancel();
    _settingsSubscription?.cancel();
  }
}

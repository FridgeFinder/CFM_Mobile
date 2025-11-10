import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/app_logger.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../providers/database_provider.dart';
import 'local_notification_service.dart';

/// Top-level function for handling background messages (must be top-level)
/// This is declared in main.dart but kept here for reference

/// Service for managing Firebase Cloud Messaging
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

      // Check if permissions are already granted and get token if so
      final settings = await _messaging.getNotificationSettings();
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await _requestTokenAndSave();
      }

      logger.i('FCM service initialized');
    } catch (e) {
      logger.e('Error initializing FCM: $e');
    }
  }

  /// Request notification permissions and get FCM token
  /// Should be called when user subscribes to their first fridge
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
        await _requestTokenAndSave();
        return true;
      } else {
        logger.w('Notification permissions not granted');
        return false;
      }
    } catch (e) {
      logger.e('Error requesting FCM permissions: $e');
      return false;
    }
  }

  /// Request FCM token and save it to user profile
  Future<void> _requestTokenAndSave() async {
    try {
      // Get FCM token
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveFCMToken(token);
        logger.i('FCM token obtained: ${token.substring(0, 20)}...');

        // Listen for token refresh (if not already listening)
        _tokenSubscription ??= _messaging.onTokenRefresh.listen((newToken) async {
          await _saveFCMToken(newToken);
          logger.i('FCM token refreshed');
        });
      }
    } catch (e) {
      logger.e('Error getting FCM token: $e');
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

      // Try to get existing profile first
      final profile = await _authRepository.getUserProfile(currentUser.uid);
      if (profile != null) {
        // Update existing profile
        final updatedProfile = profile.copyWith(fcmToken: token);
        await _authRepository.updateUserProfile(updatedProfile);
        logger.d('FCM token saved to user profile');
      } else {
        // Profile doesn't exist yet - save token directly to database
        // This can happen if user signs in but profile creation is delayed
        try {
          final database = DatabaseProvider.databaseRef;
          await database
              .child('users')
              .child(currentUser.uid)
              .child('fcmToken')
              .set(token);
          logger.d('FCM token saved directly to database (profile not yet created)');
        } catch (e) {
          logger.e('Error saving FCM token directly: $e');
        }
      }
    } catch (e) {
      logger.e('Error saving FCM token: $e');
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

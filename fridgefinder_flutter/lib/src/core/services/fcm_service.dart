import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import '../utils/app_logger.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../providers/database_provider.dart';
import 'device_id_service.dart';
import 'local_notification_service.dart';

/// Top-level function for handling background messages (must be top-level)
/// This is declared in main.dart but kept here for reference

/// Service for managing Firebase Cloud Messaging
///
/// Uses the currently selected Firebase environment (dev/prod)
/// initialized during app bootstrap in main.dart.
///
/// Multi-device support: tokens are stored at `users/{uid}/fcmTokens/{deviceId}`
/// with dual-write to `users/{uid}/fcmToken` for backend compatibility.
class FCMService with WidgetsBindingObserver {
  final FirebaseMessaging _messaging;
  final AuthRepository _authRepository;
  final LocalNotificationService _localNotifications;
  final DeviceIdService _deviceIdService;
  final DatabaseReference _database;

  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<NotificationSettings>? _settingsSubscription;

  // Track when we last verified the token to avoid excessive checks
  DateTime? _lastTokenVerification;
  static const _tokenVerificationCooldown = Duration(minutes: 5);

  // In-memory cache of current FCM token
  String? _currentToken;

  /// Current cached FCM token (null if not yet obtained or after sign-out)
  String? get currentToken => _currentToken;

  // Guard against redundant initialization
  bool _isInitialized = false;

  FCMService({
    FirebaseMessaging? messaging,
    AuthRepository? authRepository,
    LocalNotificationService? localNotifications,
    DeviceIdService? deviceIdService,
    DatabaseReference? database,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _authRepository = authRepository ?? AuthRepository(),
       _localNotifications = localNotifications ?? LocalNotificationService(),
       _deviceIdService = deviceIdService ?? DeviceIdService(),
       _database = database ?? DatabaseProvider.databaseRef {
    // Register lifecycle observer to handle app resume
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app resumes from background, verify token is saved
    // This is especially important for iOS where APNS token might become available after app launch
    if (state == AppLifecycleState.resumed) {
      logger.d('App resumed - checking FCM token status');
      _onAppResumed();
    }
  }

  /// Handle app resume - verify token is saved (with cooldown to avoid excessive checks)
  Future<void> _onAppResumed() async {
    try {
      // Check cooldown to avoid excessive verifications
      if (_lastTokenVerification != null) {
        final timeSinceLastCheck = DateTime.now().difference(_lastTokenVerification!);
        if (timeSinceLastCheck < _tokenVerificationCooldown) {
          logger.d('Token verification skipped - checked ${timeSinceLastCheck.inSeconds}s ago');
          return;
        }
      }

      _lastTokenVerification = DateTime.now();

      // Only verify if permissions are granted
      final settings = await _messaging.getNotificationSettings();
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await _verifyTokenSaved();
      }
    } catch (e) {
      logger.e('Error handling app resume: $e');
    }
  }

  /// Initialize FCM service (without requesting permissions)
  /// Permissions should be requested when user subscribes to first fridge
  Future<void> initialize() async {
    if (_isInitialized) return;

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
        // Migrate old fcmToken → fcmTokens/{deviceId} if needed
        await _migrateOldToken();

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

        // Verify token is saved in database, retry if missing
        await _verifyTokenSaved();
      }

      _isInitialized = true;
      logger.i('FCM service initialized');
    } catch (e) {
      logger.e('Error initializing FCM: $e');
    }
  }

  /// Migrate old single `fcmToken` field to `fcmTokens/{deviceId}` map.
  /// Called once during initialization. No-op if old field doesn't exist.
  Future<void> _migrateOldToken() async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) return;
      final userRef = _database.child('users').child(currentUser.uid);
      final snapshot = await userRef.child('fcmToken').get();
      if (snapshot.exists && snapshot.value != null) {
        final oldToken = snapshot.value as String;
        if (oldToken.isNotEmpty) {
          final deviceId = await _deviceIdService.getDeviceId();
          await userRef.child('fcmTokens').child(deviceId).set(oldToken);
          await userRef.child('fcmToken').remove();
          _currentToken = oldToken;
          logger.i('Migrated old fcmToken to fcmTokens/$deviceId');
        }
      }
    } catch (e) {
      logger.e('Error migrating old FCM token: $e');
    }
  }

  /// Verify that FCM token is saved in database
  /// If permissions are granted but token is missing, attempt to retrieve and save it
  Future<void> _verifyTokenSaved() async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) return;

      // Check if token exists in database at new multi-device path
      final deviceId = await _deviceIdService.getDeviceId();
      final tokenSnapshot = await _database
          .child('users')
          .child(currentUser.uid)
          .child('fcmTokens')
          .child(deviceId)
          .get();

      if (!tokenSnapshot.exists || tokenSnapshot.value == null || (tokenSnapshot.value as String).isEmpty) {
        logger.w('FCM token not found in database - attempting to retrieve and save');

        // Try to get and save token
        try {
          // CRITICAL FIX: On iOS, request APNS token first
          if (Platform.isIOS) {
            final apnsToken = await _messaging.getAPNSToken();
            if (apnsToken == null) {
              logger.w('APNS token not available during verification - listener will save when ready');
              return;
            }
            logger.d('APNS token verified during token verification');
          }

          final token = await _messaging.getToken();
          if (token != null && token.isNotEmpty) {
            await _saveFCMToken(token);
            logger.i('Missing FCM token retrieved and saved');
          } else {
            logger.w('FCM token still not available - listener will save when ready');
          }
        } catch (e) {
          if (Platform.isIOS && e.toString().contains('apns-token-not-set')) {
            logger.d('APNS token not ready during verification - listener will save when available');
          } else {
            logger.e('Error retrieving FCM token during verification: $e');
          }
        }
      } else {
        logger.d('FCM token verified in database');
      }
    } catch (e) {
      logger.e('Error verifying FCM token: $e');
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
      // CRITICAL FIX: On iOS, request APNS token first
      if (Platform.isIOS) {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          logger.w('APNS token is null - retrying...');
          if (retryCount < maxRetries) {
            await Future.delayed(retryDelay);
            return _requestTokenAndSave(retryCount: retryCount + 1);
          }
          logger.w('APNS token not available after $maxRetries retries. Token will be saved when available.');
          return false;
        }
        logger.d('APNS token obtained: ${apnsToken.substring(0, 20)}...');
      }

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

  /// Save FCM token to database using targeted child writes.
  ///
  /// Writes to both:
  /// - `users/{uid}/fcmTokens/{deviceId}` (new multi-device path)
  /// - `users/{uid}/fcmToken` (old path, dual-write for backend compat)
  ///
  /// Does NOT use `updateUserProfile` to avoid shallow merge race conditions.
  Future<void> _saveFCMToken(String token) async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) {
        logger.w('Cannot save FCM token: user not authenticated');
        return;
      }

      final deviceId = await _deviceIdService.getDeviceId();
      final userRef = _database.child('users').child(currentUser.uid);

      // Write to new multi-device path
      await userRef.child('fcmTokens').child(deviceId).set(token);
      // Dual-write to old path for backend compat (remove after backend migration)
      await userRef.child('fcmToken').set(token);

      _currentToken = token;
      logger.i('FCM token saved for device $deviceId');
    } catch (e) {
      logger.e('Error saving FCM token: $e');
      rethrow;
    }
  }

  /// Public method to save FCM token (called after profile creation)
  Future<void> saveFCMToken(String token) async {
    await _saveFCMToken(token);
  }

  /// Public method to manually refresh and verify FCM token
  /// Useful for:
  /// - Recovering from token save failures
  /// - Ensuring token is saved after iOS APNS token becomes available
  /// - Manual retry from user settings
  /// Returns true if token was successfully saved
  Future<bool> refreshAndVerifyToken() async {
    try {
      logger.i('Manual token refresh requested');

      // Check current permission status
      final settings = await _messaging.getNotificationSettings();
      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional) {
        logger.w('Cannot refresh token - permissions not granted');
        return false;
      }

      // Attempt to get and save token
      try {
        // CRITICAL FIX: On iOS, request APNS token first
        if (Platform.isIOS) {
          final apnsToken = await _messaging.getAPNSToken();
          if (apnsToken == null) {
            logger.w('APNS token not available during manual refresh - listener will save when ready');
            return false;
          }
          logger.d('APNS token verified during manual refresh');
        }

        final token = await _messaging.getToken();
        if (token != null && token.isNotEmpty) {
          await _saveFCMToken(token);
          logger.i('Token manually refreshed and saved: ${token.substring(0, 20)}...');
          return true;
        } else {
          logger.w('Token refresh returned null/empty token');
          return false;
        }
      } catch (e) {
        if (Platform.isIOS && e.toString().contains('apns-token-not-set')) {
          logger.w('APNS token not ready during manual refresh - listener will save when available');
          // Return false because we couldn't get the token
          return false;
        }
        logger.e('Error during manual token refresh: $e');
        return false;
      }
    } catch (e) {
      logger.e('Error refreshing FCM token: $e');
      return false;
    }
  }

  /// Check if FCM token exists in database for this device
  /// Returns true if token exists and is not empty
  Future<bool> hasTokenInDatabase() async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) return false;

      final deviceId = await _deviceIdService.getDeviceId();
      final tokenSnapshot = await _database
          .child('users')
          .child(currentUser.uid)
          .child('fcmTokens')
          .child(deviceId)
          .get();

      return tokenSnapshot.exists &&
             tokenSnapshot.value != null &&
             (tokenSnapshot.value as String).isNotEmpty;
    } catch (e) {
      logger.e('Error checking token in database: $e');
      return false;
    }
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

  /// Delete FCM token for this device (call before sign out).
  ///
  /// Removes only this device's entry from `fcmTokens/{deviceId}`,
  /// cancels token refresh subscription, deletes FCM token from
  /// Firebase servers, clears badge, and resets local state.
  Future<void> deleteToken() async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser != null) {
        final deviceId = await _deviceIdService.getDeviceId();
        final userRef = _database.child('users').child(currentUser.uid);
        // Remove this device's entry only
        await userRef.child('fcmTokens').child(deviceId).remove();
        // Note: leave fcmToken field for other-device backend compat
      }

      // Cancel token refresh subscription (fixes stale closure on re-login)
      _tokenSubscription?.cancel();
      _tokenSubscription = null;

      // Delete FCM token from Firebase servers
      await _messaging.deleteToken();

      // Clear local state
      _currentToken = null;
      _isInitialized = false;

      logger.i('FCM token deleted and state cleared');
    } catch (e) {
      logger.e('Error deleting FCM token: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _tokenSubscription?.cancel();
    _messageSubscription?.cancel();
    _settingsSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }
}

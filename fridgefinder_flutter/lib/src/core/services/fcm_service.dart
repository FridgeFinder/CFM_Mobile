import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/app_logger.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import 'device_id_service.dart';
import 'local_notification_service.dart';

/// Top-level function for handling background messages (must be top-level)
/// This is declared in main.dart but kept here for reference

/// Service for managing Firebase Cloud Messaging
///
/// Uses the currently selected Firebase environment (dev/prod)
/// initialized during app bootstrap in main.dart.
///
/// Device tokens are registered through the Users API device endpoints.
class FCMService with WidgetsBindingObserver {
  static const _deviceNotificationCacheBoxName = 'device_notification_state_cache';

  final FirebaseMessaging _messaging;
  final AuthRepository _authRepository;
  final LocalNotificationService _localNotifications;
  final DeviceIdService _deviceIdService;

  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<NotificationSettings>? _settingsSubscription;

  // Track when we last verified the token to avoid excessive checks
  DateTime? _lastTokenVerification;
  static const _tokenVerificationCooldown = Duration(minutes: 5);

  // In-memory cache of current FCM token
  String? _currentToken;
  bool? _cachedDeviceNotificationsEnabled;
  String? _cachedDeviceNotificationsKey;

  /// Current cached FCM token (null if not yet obtained or after sign-out)
  String? get currentToken => _currentToken;

  String _deviceNotificationCacheKey({
    required String userId,
    required String installationId,
  }) => 'device_notifications_${userId}_$installationId';

  Future<Box<bool>?> _openDeviceNotificationCacheBox() async {
    try {
      return await Hive.openBox<bool>(_deviceNotificationCacheBoxName);
    } catch (e) {
      logger.w('Unable to open device notification cache box: $e');
      return null;
    }
  }

  Future<bool?> _getCachedDeviceNotificationState({
    required String userId,
    required String installationId,
  }) async {
    final cacheKey = _deviceNotificationCacheKey(
      userId: userId,
      installationId: installationId,
    );

    if (_cachedDeviceNotificationsKey == cacheKey &&
        _cachedDeviceNotificationsEnabled != null) {
      return _cachedDeviceNotificationsEnabled;
    }

    final box = await _openDeviceNotificationCacheBox();
    final cachedValue = box?.get(cacheKey);
    if (cachedValue != null) {
      _cachedDeviceNotificationsKey = cacheKey;
      _cachedDeviceNotificationsEnabled = cachedValue;
    }
    return cachedValue;
  }

  Future<void> _setCachedDeviceNotificationState({
    required String userId,
    required String installationId,
    required bool enabled,
  }) async {
    final cacheKey = _deviceNotificationCacheKey(
      userId: userId,
      installationId: installationId,
    );

    _cachedDeviceNotificationsKey = cacheKey;
    _cachedDeviceNotificationsEnabled = enabled;

    final box = await _openDeviceNotificationCacheBox();
    await box?.put(cacheKey, enabled);
  }

  Future<void> _clearCachedDeviceNotificationState({
    required String userId,
    required String installationId,
  }) async {
    final cacheKey = _deviceNotificationCacheKey(
      userId: userId,
      installationId: installationId,
    );
    if (_cachedDeviceNotificationsKey == cacheKey) {
      _cachedDeviceNotificationsKey = null;
      _cachedDeviceNotificationsEnabled = null;
    }

    final box = await _openDeviceNotificationCacheBox();
    await box?.delete(cacheKey);
  }

  // Guard against redundant initialization
  bool _isInitialized = false;

  FCMService({
    FirebaseMessaging? messaging,
    required AuthRepository authRepository,
    LocalNotificationService? localNotifications,
    DeviceIdService? deviceIdService,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _authRepository = authRepository,
       _localNotifications = localNotifications ?? LocalNotificationService(),
       _deviceIdService = deviceIdService ?? DeviceIdService() {
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

      final settings = await _messaging.getNotificationSettings();
      await syncDeviceNotificationState(settings: settings);

      // Only verify token if permissions are granted
      if (_isNotificationsAuthorized(settings)) {
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
      await syncDeviceNotificationState(settings: settings);

      if (_isNotificationsAuthorized(settings)) {
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

  /// Verify that the current device has a token registered in Users API.
  Future<void> _verifyTokenSaved() async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) return;

      final deviceId = await _deviceIdService.getDeviceId();
      final device = await _authRepository.getUserDevice(
        userId: currentUser.uid,
        installationId: deviceId,
      );

      final token = device?['token'];
      if (token is! String || token.isEmpty) {
        logger.w('FCM token not found in Users API - attempting to retrieve and save');

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
        _currentToken = token;
        logger.d('FCM token verified in Users API');
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
        await syncDeviceNotificationState(settings: settings);
        return true;
      } else {
        logger.w('Notification permissions not granted');
        await syncDeviceNotificationState(settings: settings);
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

  /// Save FCM token to Users API device registration endpoint.
  Future<void> _saveFCMToken(String token) async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) {
        logger.w('Cannot save FCM token: user not authenticated');
        return;
      }

      final deviceId = await _deviceIdService.getDeviceId();
      final platform = Platform.isIOS ? 'ios' : 'android';
      await _authRepository.registerUserDevice(
        userId: currentUser.uid,
        installationId: deviceId,
        token: token,
        platform: platform,
      );

      // Keep device notification flag aligned after token registration.
      await syncDeviceNotificationState();

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

  /// Check if this device has an FCM token registered in Users API.
  Future<bool> hasTokenInDatabase() async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) return false;

      final deviceId = await _deviceIdService.getDeviceId();
      final device = await _authRepository.getUserDevice(
        userId: currentUser.uid,
        installationId: deviceId,
      );

      final token = device?['token'];
      return token is String && token.isNotEmpty;
    } catch (e) {
      logger.e('Error checking token in database: $e');
      return false;
    }
  }

  bool _isNotificationsAuthorized(NotificationSettings settings) {
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Sync the current device's notification-enabled state to the Users API.
  Future<void> syncDeviceNotificationState({NotificationSettings? settings}) async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) return;

      final resolvedSettings = settings ?? await _messaging.getNotificationSettings();
      final enabled = _isNotificationsAuthorized(resolvedSettings);
      final deviceId = await _deviceIdService.getDeviceId();

      await _authRepository.updateUserDevice(
        userId: currentUser.uid,
        installationId: deviceId,
        notificationsEnabled: enabled,
        lastSeenAt: DateTime.now(),
      );
    } catch (e) {
      logger.w('Unable to sync device notification state: $e');
    }
  }

  /// Returns effective device-level push status (OS permission + device flag).
  Future<bool> getDeviceNotificationsEnabled() async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) return false;

      final settings = await _messaging.getNotificationSettings();
      final systemEnabled = _isNotificationsAuthorized(settings);
      if (!systemEnabled) return false;

      final deviceId = await _deviceIdService.getDeviceId();
      final device = await _authRepository.getUserDevice(
        userId: currentUser.uid,
        installationId: deviceId,
      );

      final backendFlag = device?['notificationsEnabled'];
      bool enabled;
      if (backendFlag is bool) {
        enabled = backendFlag && systemEnabled;
      } else {
        // Backward-compatible fallback while older rows may lack this flag.
        enabled = systemEnabled;
      }

      await _setCachedDeviceNotificationState(
        userId: currentUser.uid,
        installationId: deviceId,
        enabled: enabled,
      );
      return enabled;
    } catch (e) {
      logger.w('Error reading device notification state: $e');
      return false;
    }
  }

  /// Returns last known cached device-level push status for fast UI paint.
  /// Returns null when there is no cached value yet.
  Future<bool?> getCachedDeviceNotificationsEnabled() async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) return null;

      final deviceId = await _deviceIdService.getDeviceId();
      return _getCachedDeviceNotificationState(
        userId: currentUser.uid,
        installationId: deviceId,
      );
    } catch (e) {
      logger.w('Error reading cached device notification state: $e');
      return null;
    }
  }

  /// Updates device-level notification preference and handles permission prompt when enabling.
  Future<bool> setDeviceNotificationsEnabled(bool enabled) async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) return false;

      if (enabled) {
        final granted = await requestPermissionsAndGetToken();
        if (!granted) {
          await syncDeviceNotificationState();
          return false;
        }

        await syncDeviceNotificationState();
        return getDeviceNotificationsEnabled();
      }

      final deviceId = await _deviceIdService.getDeviceId();
      await _authRepository.updateUserDevice(
        userId: currentUser.uid,
        installationId: deviceId,
        notificationsEnabled: false,
        lastSeenAt: DateTime.now(),
      );
      await _setCachedDeviceNotificationState(
        userId: currentUser.uid,
        installationId: deviceId,
        enabled: false,
      );
      return false;
    } catch (e) {
      logger.e('Error updating device notification state: $e');
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
  /// Unregisters this device via Users API,
  /// cancels token refresh subscription, deletes FCM token from
  /// Firebase servers, clears badge, and resets local state.
  Future<void> deleteToken() async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser != null) {
        final deviceId = await _deviceIdService.getDeviceId();
        await _authRepository.unregisterUserDevice(
          userId: currentUser.uid,
          installationId: deviceId,
        );
        await _clearCachedDeviceNotificationState(
          userId: currentUser.uid,
          installationId: deviceId,
        );
      }

      // Cancel token refresh subscription (fixes stale closure on re-login)
      _tokenSubscription?.cancel();
      _tokenSubscription = null;

      // Delete FCM token from Firebase servers
      await _messaging.deleteToken();

      // Clear local state
      _currentToken = null;
      _cachedDeviceNotificationsEnabled = null;
      _cachedDeviceNotificationsKey = null;
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

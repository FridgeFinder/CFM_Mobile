import 'dart:io';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/app_logger.dart';
import '../providers/notification_navigation_provider.dart';

/// Service for managing local notifications
class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  WidgetRef? _ref;

  /// Set the WidgetRef for navigation handling
  void setRef(WidgetRef ref) {
    _ref = ref;
  }

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize the plugin
      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized == false) {
        logger.w('Failed to initialize local notifications');
        return;
      }

      // Create Android notification channel
      if (Platform.isAndroid) {
        await _createAndroidChannel();
      }

      // Request permissions (iOS)
      if (Platform.isIOS) {
        final iosPlugin = _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        if (iosPlugin != null) {
          final result = await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          logger.i('iOS notification permissions: $result');
        }
      }

      _initialized = true;
      logger.i('Local notifications initialized');
    } catch (e) {
      logger.e('Error initializing local notifications: $e');
    }
  }

  /// Create Android notification channel
  Future<void> _createAndroidChannel() async {
    const androidChannel = AndroidNotificationChannel(
      'fridgefinder_notifications', // id
      'FridgeFinder Notifications', // name
      description: 'Notifications for fridge updates and alerts',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Show a notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      // Check permissions before showing notification
      if (Platform.isIOS) {
        final iosPlugin = _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        if (iosPlugin != null) {
          final permissionStatus = await iosPlugin.checkPermissions();
          logger.d('iOS notification permissions: $permissionStatus');
          
          // Check if notifications are enabled
          // permissionStatus can be null, so handle it safely
          final isEnabled = permissionStatus?.isEnabled;
          if (isEnabled != true) {
            logger.w('iOS notifications not enabled. Requesting permissions...');
            final result = await iosPlugin.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
            logger.i('iOS permission request result: $result');
            
            // Check if permissions were granted
            // requestPermissions returns a bool
            if (result != true) {
              logger.e('iOS notification permissions not granted. Cannot show notification.');
              throw Exception('Notification permissions not granted. Please enable notifications in Settings.');
            }
          }
        }
      }

      const androidDetails = AndroidNotificationDetails(
        'fridgefinder_notifications',
        'FridgeFinder Notifications',
        channelDescription: 'Notifications for fridge updates and alerts',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        id,
        title,
        body,
        details,
        payload: payload != null ? jsonEncode(payload) : null,
      );

      logger.i('Local notification shown successfully: $title');
    } catch (e) {
      logger.e('Error showing notification: $e');
      rethrow; // Re-throw so caller knows it failed
    }
  }

  /// Handle notification tap from FCM (called by FCMService)
  void handleNotificationTap(String fridgeId) {
    if (_ref != null) {
      logger.i('FCM notification tapped for fridge: $fridgeId');
      _ref!.read(notificationNavigationProvider.notifier).setFridgeId(fridgeId);
    } else {
      logger.w('Cannot handle notification tap: WidgetRef not set');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    logger.i('Notification tapped: ${response.payload}');
    
    // Parse payload to extract fridgeId
    if (response.payload != null && _ref != null) {
      try {
        // Parse JSON payload
        final payloadMap = jsonDecode(response.payload!) as Map<String, dynamic>;
        final fridgeId = payloadMap['fridgeId'] as String?;
        
        if (fridgeId != null) {
          logger.i('Local notification tapped for fridge: $fridgeId');
          _ref!.read(notificationNavigationProvider.notifier).setFridgeId(fridgeId);
        }
      } catch (e) {
        logger.e('Error parsing notification payload: $e');
      }
    }
  }

  /// Cancel a specific notification
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  /// Get the notifications plugin (for testing/diagnostics)
  FlutterLocalNotificationsPlugin get notificationsPlugin => _notifications;

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}


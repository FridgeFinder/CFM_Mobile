import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../utils/app_logger.dart';
import '../providers/database_provider.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/map/domain/models/fridge_domain.dart';
import '../../features/map/domain/repositories/i_fridge_repository.dart';
import 'local_notification_service.dart';

/// Service for managing geofencing and location-based notifications
class GeofencingService {
  final AuthRepository _authRepository;
  final IFridgeRepository _fridgeRepository;
  final LocalNotificationService _localNotifications;

  StreamSubscription<Position>? _locationSubscription;
  bool _isMonitoring = false;
  Timer? _checkTimer;

  // Track recently notified fridges to avoid spam
  final Set<String> _recentlyNotifiedFridges = {};
  static const Duration _notificationCooldown = Duration(minutes: 30);

  // 4 blocks radius ≈ 400 meters (roughly)
  static const double _geofenceRadiusMeters = 400.0;

  GeofencingService({
    AuthRepository? authRepository,
    required IFridgeRepository fridgeRepository,
    LocalNotificationService? localNotifications,
  }) : _authRepository = authRepository ?? AuthRepository(),
       _fridgeRepository = fridgeRepository,
       _localNotifications = localNotifications ?? LocalNotificationService();

  /// Start monitoring location for geofencing
  Future<void> startMonitoring() async {
    if (_isMonitoring) {
      logger.w('Geofencing already monitoring');
      return;
    }

    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) {
        logger.w('Cannot start geofencing: user not authenticated');
        return;
      }

      final profile = await _authRepository.getUserProfile(currentUser.uid);
      if (profile == null || !profile.settings.geofencingEnabled) {
        logger.d('Geofencing disabled for user');
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        logger.w('Location permission not granted for geofencing');
        return;
      }

      // Request background location permission
      if (permission == LocationPermission.whileInUse) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.always) {
        logger.w('Background location permission required for geofencing');
        return;
      }

      _isMonitoring = true;

      // Start location stream
      _locationSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 50, // Update every 50 meters
            ),
          ).listen(
            (position) => _checkNearbyFridges(position),
            onError: (error) {
              logger.e('Location stream error: $error');
            },
          );

      logger.i('Geofencing monitoring started');
    } catch (e) {
      logger.e('Error starting geofencing: $e');
      _isMonitoring = false;
    }
  }

  /// Stop monitoring location
  void stopMonitoring() {
    _isMonitoring = false;
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _checkTimer?.cancel();
    _checkTimer = null;
    _recentlyNotifiedFridges.clear(); // Clear notification tracking
    logger.i('Geofencing monitoring stopped');
  }

  /// Check nearby fridges and send notifications if needed
  Future<void> _checkNearbyFridges(Position position) async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) return;

      final profile = await _authRepository.getUserProfile(currentUser.uid);
      if (profile == null || !profile.settings.geofencingEnabled) {
        stopMonitoring();
        return;
      }

      // Get user's subscribed fridges for notification preferences
      final database = DatabaseProvider.databaseRef;
      final subscriptionsSnapshot = await database
          .child('users')
          .child(currentUser.uid)
          .child('subscribedFridges')
          .get();

      // Create a map of subscribed fridge IDs to their notification preferences
      final Map<String, Map<Object?, Object?>> subscriptions = {};
      if (subscriptionsSnapshot.exists) {
        final subscriptionsData =
            subscriptionsSnapshot.value as Map<Object?, Object?>;
        for (final entry in subscriptionsData.entries) {
          final fridgeId = entry.key as String;
          final subscriptionData = entry.value as Map<Object?, Object?>;
          final notificationPrefs =
              subscriptionData['notificationPreferences']
                  as Map<Object?, Object?>?;
          if (notificationPrefs != null) {
            subscriptions[fridgeId] = notificationPrefs;
          }
        }
      }

      // Get all fridges (not just subscribed ones)
      final fridges = await _fridgeRepository.getFridges();

      // Check proximity to all fridges
      for (final fridge in fridges) {
        // Calculate distance to this fridge
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          fridge.location.geoLat,
          fridge.location.geoLng,
        );

        // Check if within geofence radius
        if (distance <= _geofenceRadiusMeters) {
          // Only send notifications for subscribed fridges
          final notificationPrefs = subscriptions[fridge.id];
          if (notificationPrefs != null) {
            await _checkAndNotifyFridgeNeeds(fridge, notificationPrefs);
          } else {
            // Log that user is near a non-subscribed fridge (for potential future features)
            logger.d(
              'User near non-subscribed fridge: ${fridge.name} (${distance.toStringAsFixed(0)}m away)',
            );
          }
        }
      }
    } catch (e) {
      logger.e('Error checking nearby fridges: $e');
    }
  }

  /// Check if fridge needs attention and send notification
  Future<void> _checkAndNotifyFridgeNeeds(
    FridgeDomain fridge,
    Map<Object?, Object?> notificationPrefs,
  ) async {
    try {
      final latestReport = fridge.latestFridgeReport;
      if (latestReport == null) return;

      final needs = <String>[];

      // Check notification preferences
      if (notificationPrefs['runningLow'] == true &&
          latestReport.foodPercentage < 0.25) {
        needs.add('running low on food');
      }

      if (notificationPrefs['empty'] == true &&
          latestReport.foodPercentage == 0.0) {
        needs.add('empty');
      }

      if (notificationPrefs['needsCleaning'] == true &&
          latestReport.condition == FridgeCondition.dirty) {
        needs.add('needs cleaning');
      }

      if (notificationPrefs['needsServicing'] == true &&
          latestReport.condition == FridgeCondition.outOfOrder) {
        needs.add('needs servicing');
      }

      // Check routine validation (more than 2 days since last update)
      if (notificationPrefs['routineValidation'] == true &&
          latestReport.reportDate != null) {
        final daysSinceUpdate = DateTime.now()
            .difference(latestReport.reportDate!)
            .inDays;
        if (daysSinceUpdate > 2) {
          needs.add('routine validation ($daysSinceUpdate days since update)');
        }
      }

      if (needs.isNotEmpty) {
        await _sendGeofenceNotification(fridge, needs);
      }
    } catch (e) {
      logger.e('Error checking fridge needs: $e');
    }
  }

  /// Send geofence notification
  Future<void> _sendGeofenceNotification(
    FridgeDomain fridge,
    List<String> needs,
  ) async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) return;

      // Check if we've notified about this fridge recently
      final notificationKey = '${fridge.id}_${needs.join("_")}';
      if (_recentlyNotifiedFridges.contains(notificationKey)) {
        logger.d(
          'Skipping geofence notification - recently notified about ${fridge.name}',
        );
        return;
      }

      // Get user's FCM token (for future backend integration)
      final profile = await _authRepository.getUserProfile(currentUser.uid);
      if (profile == null) return;

      // Check if notifications are enabled
      if (!profile.settings.notificationsEnabled) {
        logger.d(
          'Notifications disabled for user - skipping geofence notification',
        );
        return;
      }

      // Send local notification
      final needsText = needs.join(', ');
      final notificationId = fridge.id.hashCode;

      await _localNotifications.showNotification(
        id: notificationId,
        title: '${fridge.name} needs attention',
        body: 'You\'re near a fridge that $needsText',
        payload: {
          'fridgeId': fridge.id,
          'type': 'geofence',
          'needs': needs.join(','),
        },
      );

      // Mark as recently notified
      _recentlyNotifiedFridges.add(notificationKey);

      // Remove from recently notified set after cooldown period
      Timer(_notificationCooldown, () {
        _recentlyNotifiedFridges.remove(notificationKey);
      });

      logger.i(
        'Geofence notification sent: ${fridge.name} needs ${needs.join(", ")}',
      );

      // In a production app, you would also send this via your backend FCM server
      // to ensure delivery even if the app is closed
    } catch (e) {
      logger.e('Error sending geofence notification: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
  }
}

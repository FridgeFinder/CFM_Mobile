import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../utils/app_logger.dart';
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

  // Track last notification date per fridge to enforce once-per-day limit
  // Key format: "fridgeId_notificationType" -> DateTime of last notification
  final Map<String, DateTime> _lastNotificationDates = {};

  // Daily cleanup timer to prevent memory buildup
  Timer? _cleanupTimer;

  // 4 blocks radius ≈ 400 meters (roughly)
  static const double _geofenceRadiusMeters = 400.0;

  GeofencingService({
    required AuthRepository authRepository,
    required IFridgeRepository fridgeRepository,
    LocalNotificationService? localNotifications,
  }) : _authRepository = authRepository,
       _fridgeRepository = fridgeRepository,
       _localNotifications = localNotifications ?? LocalNotificationService();

  /// Start monitoring location for geofencing
  Future<void> startMonitoring() async {
    if (_isMonitoring) {
      logger.w('Geofencing already monitoring');
      return;
    }

    // Start daily cleanup timer (runs every 24 hours)
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(hours: 24), (_) {
      _cleanupOldNotifications();
    });

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
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    // Keep notification history even when stopped (persists across sessions)
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

      // Get all fridges
      final fridges = await _fridgeRepository.getFridges();

      // Check proximity to ALL fridges (not just subscribed ones)
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
          // Check and notify for ANY fridge that needs attention
          await _checkAndNotifyFridgeNeeds(fridge, distance);
        }
      }
    } catch (e) {
      logger.e('Error checking nearby fridges: $e');
    }
  }

  /// Check if fridge needs attention and send notification
  Future<void> _checkAndNotifyFridgeNeeds(
    FridgeDomain fridge,
    double distanceMeters,
  ) async {
    try {
      final latestReport = fridge.latestFridgeReport;
      if (latestReport == null) return;

      // Convert meters to feet
      final distanceFeet = (distanceMeters * 3.28084).round();

      // Determine the type of notification needed (prioritize in this order)
      String? notificationType;
      String? notificationMessage;

      // 1. Check if needs cleaning
      if (latestReport.condition == FridgeCondition.dirty) {
        notificationType = 'cleaning';
        notificationMessage =
            'This fridge $distanceFeet feet away needs cleaning! Earn 20-50 points by heading there and taking care of it';
      }
      // 2. Check if empty (needs stocking)
      else if (latestReport.foodPercentage == 0.0) {
        notificationType = 'stocking';
        notificationMessage =
            'This fridge $distanceFeet feet away could use some food- be a hero and earn 30-60 points by stocking it and posting a status update';
      }
      // 3. Check routine validation (more than 2 days since last update)
      else if (latestReport.reportDate != null) {
        final daysSinceUpdate = DateTime.now()
            .difference(latestReport.reportDate!)
            .inDays;
        if (daysSinceUpdate > 2) {
          notificationType = 'routine';
          notificationMessage =
              'This fridge super closeby hasn\'t been updated recently- snap a quick pic and send a status report to keep the neighborhood informed and fed :) Earn 10 points!';
        }
      }

      if (notificationType != null && notificationMessage != null) {
        await _sendGeofenceNotification(
          fridge,
          notificationType,
          notificationMessage,
          distanceFeet,
        );
      }
    } catch (e) {
      logger.e('Error checking fridge needs: $e');
    }
  }

  /// Send geofence notification locally.
  /// Cloud Functions triggering is intentionally disabled in mobile app.
  Future<void> _sendGeofenceNotification(
    FridgeDomain fridge,
    String notificationType,
    String notificationMessage,
    int distanceFeet,
  ) async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) return;

      // Check if we've already notified about this fridge today
      final notificationKey = '${fridge.id}_$notificationType';
      final now = DateTime.now();
      final lastNotification = _lastNotificationDates[notificationKey];

      if (lastNotification != null) {
        final isSameDay = lastNotification.year == now.year &&
                          lastNotification.month == now.month &&
                          lastNotification.day == now.day;

        if (isSameDay) {
          logger.d(
            'Skipping geofence notification - already notified about ${fridge.name} ($notificationType) today',
          );
          return;
        }
      }

      // Get user profile to check settings
      final profile = await _authRepository.getUserProfile(currentUser.uid);
      if (profile == null) return;

      final notificationId = fridge.id.hashCode + notificationType.hashCode;
      await _localNotifications.showNotification(
        id: notificationId,
        title: '${fridge.name} needs help!',
        body: notificationMessage,
        payload: {
          'fridgeId': fridge.id,
          'type': 'geofence',
          'needType': notificationType,
          'distanceFeet': distanceFeet.toString(),
        },
      );
      logger.i(
        'Local geofence notification sent: ${fridge.name} needs $notificationType ($distanceFeet ft away)',
      );

      // Mark notification as sent for today
      _lastNotificationDates[notificationKey] = now;

      logger.d(
        'Recorded notification for ${fridge.name} ($notificationType) at ${now.toString()}',
      );
    } catch (e) {
      logger.e('Error sending geofence notification: $e');
    }
  }

  /// Clean up notification records older than 7 days to prevent memory buildup
  void _cleanupOldNotifications() {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    _lastNotificationDates.removeWhere((key, date) {
      return date.isBefore(sevenDaysAgo);
    });

    logger.d(
      'Cleaned up old notification records. Remaining: ${_lastNotificationDates.length}',
    );
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:design_system/design_system.dart';
import '../../../core/utils/test_notification_utils.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/notification_providers.dart';
import '../../../core/providers/notification_navigation_provider.dart';
import '../../../core/services/local_notification_service.dart';
import '../../../features/map/data/repositories/fridge_repository.dart';
import '../../../core/utils/app_logger.dart';
import '../../../common_widgets/loading_messages.dart';

/// Debug screen for testing push notifications and geofencing
/// Only available in debug mode
class TestNotificationScreen extends ConsumerStatefulWidget {
  const TestNotificationScreen({super.key});

  @override
  ConsumerState<TestNotificationScreen> createState() =>
      _TestNotificationScreenState();
}

class _TestNotificationScreenState
    extends ConsumerState<TestNotificationScreen> {
  String? _selectedFridgeId;
  String? _fcmToken;
  List<String> _followedFridges = [];
  bool _isLoading = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _loadTestInfo();
  }

  Future<void> _checkNotificationPermissions() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final messaging = FirebaseMessaging.instance;
      final fcmSettings = await messaging.getNotificationSettings();

      String message = '=== Notification Permissions Status ===\n\n';
      message +=
          'FCM Authorization Status: ${fcmSettings.authorizationStatus}\n';
      message += 'Alert: ${fcmSettings.alert}\n';
      message += 'Badge: ${fcmSettings.badge}\n';
      message += 'Sound: ${fcmSettings.sound}\n\n';

      // Check local notification permissions (iOS)
      if (Platform.isIOS) {
        try {
          final localNotifications = LocalNotificationService();
          final iosPlugin = localNotifications.notificationsPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();
          if (iosPlugin != null) {
            final localPerms = await iosPlugin.checkPermissions();
            message += 'Local Notification Permissions:\n';
            // Display the actual permission values
            // localPerms may be null, so check first
            if (localPerms != null) {
              // Display permission status
              message += 'Enabled: ${localPerms.isEnabled}\n';
              message += 'Full details: $localPerms\n';
            } else {
              message += 'Permission status is null\n';
            }
          } else {
            message += 'Local Notification Plugin: Not available\n';
          }
        } catch (e) {
          message += 'Error checking local permissions: $e\n';
        }
      }

      // Try to get FCM token
      try {
        final token = await messaging.getToken();
        if (token != null) {
          message += '\nFCM Token: ${token.substring(0, 30)}...\n';
        } else {
          message += '\nFCM Token: Not available\n';
        }
      } catch (e) {
        message += '\nFCM Token Error: $e\n';
      }

      message += '\n=== End Status ===';

      setState(() {
        _isLoading = false;
        _statusMessage = message;
      });
    } catch (e) {
      logger.e('Error checking permissions: $e');
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error checking permissions: $e';
      });
    }
  }

  Future<void> _loadTestInfo() async {
    setState(() => _isLoading = true);
    try {
      final token = await TestNotificationUtils.getCurrentUserFCMToken();
      final fridges = await TestNotificationUtils.getSubscribedFridges();

      setState(() {
        _fcmToken = token;
        _followedFridges = fridges;
        if (fridges.isNotEmpty && _selectedFridgeId == null) {
          _selectedFridgeId = fridges.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      logger.e('Error loading test info: $e');
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error: $e';
      });
    }
  }

  Future<void> _requestPermissionsAndGetToken() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final fcmService = ref.read(fcmServiceProvider);
      final permissionsGranted = await fcmService
          .requestPermissionsAndGetToken();

      if (permissionsGranted) {
        // Reload token after requesting permissions
        await Future.delayed(const Duration(milliseconds: 500));
        final token = await TestNotificationUtils.getCurrentUserFCMToken();

        setState(() {
          _isLoading = false;
          _fcmToken = token;
          if (token != null) {
            _statusMessage =
                '✅ Notification permissions granted!\n'
                'FCM token saved successfully.\n'
                'Token: ${token.substring(0, 30)}...';
          } else {
            _statusMessage =
                '⚠️ Permissions granted but token not yet available.\n'
                'Try refreshing in a moment.';
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _statusMessage =
              '❌ Notification permissions not granted.\n'
              'Please enable notifications in Settings.';
        });
      }
    } catch (e) {
      logger.e('Error requesting permissions: $e');
      final errorMessage = e.toString();

      // Handle iOS APNS token not ready error gracefully
      if (errorMessage.contains('apns-token-not-set')) {
        setState(() {
          _isLoading = false;
          _statusMessage =
              '⚠️ Permissions granted!\n'
              'On iOS, the APNS token may take a moment to be ready.\n'
              'The FCM token will be saved automatically when available.\n'
              'Try refreshing in a few seconds, or restart the app.';
        });
      } else {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Error requesting permissions: $e';
        });
      }
    }
  }

  Future<void> _createTestStatusReport() async {
    if (_selectedFridgeId == null) {
      _showMessage('Please select a fridge first');
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final reportId = await TestNotificationUtils.createTestStatusReport(
        fridgeId: _selectedFridgeId!,
        fridgeName: 'Test Fridge',
        condition: 'good',
        foodPercentage:
            0.0, // Empty - should trigger notification if user follows fridge
      );

      setState(() {
        _isLoading = false;
        _statusMessage =
            'Test status report created: $reportId\n'
            'Cloud Function will trigger and send notifications to followers.';
      });
    } catch (e) {
      logger.e('Error creating test status report: $e');
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error: $e';
      });
    }
  }

  Future<void> _testLocalNotification() async {
    if (_selectedFridgeId == null) {
      _showMessage('Please select a fridge first');
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final localNotifications = LocalNotificationService();

      // Log before showing notification
      logger.i(
        'Attempting to show local notification for fridge: $_selectedFridgeId',
      );

      await localNotifications.showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: 'Test Notification',
        body: 'This is a test local notification for fridge $_selectedFridgeId',
        payload: {'fridgeId': _selectedFridgeId!},
      );

      logger.i('Local notification show() completed successfully');

      setState(() {
        _isLoading = false;
        _statusMessage =
            '✅ Local notification sent!\n'
            'If you don\'t see it:\n'
            '1. Check Notification Center (swipe down from top)\n'
            '2. Make sure app is not in Do Not Disturb mode\n'
            '3. Check iOS Settings > FridgeFinder > Notifications\n'
            '4. Try backgrounding the app and sending again';
      });
    } catch (e) {
      logger.e('Error sending local notification: $e');
      setState(() {
        _isLoading = false;
        _statusMessage =
            '❌ Error: $e\n'
            'Make sure notification permissions are granted in Settings.';
      });
    }
  }

  Future<void> _testGeofencingNotification() async {
    if (_selectedFridgeId == null) {
      _showMessage('Please select a fridge first');
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      // Get current location
      final position = await Geolocator.getCurrentPosition();

      // Get fridge repository to fetch fridge details
      final fridgeRepository = ref.read(fridgeRepositoryProvider);
      final fridge = await fridgeRepository.getFridge(_selectedFridgeId!);

      // Manually check if we're near the fridge
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        fridge.location.geoLat,
        fridge.location.geoLng,
      );

      if (distance > 400) {
        setState(() {
          _isLoading = false;
          _statusMessage =
              'You are ${distance.toStringAsFixed(0)}m away from the fridge.\n'
              'Geofencing notifications trigger when within 400m.\n'
              'To test, you need to be closer to the fridge location.';
        });
        return;
      }

      // If we're close enough, manually trigger the notification logic
      // This simulates what happens when entering a geofence
      final localNotifications = LocalNotificationService();
      await localNotifications.showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: '${fridge.name} needs attention',
        body: 'You are near a fridge that may need help',
        payload: {'fridgeId': _selectedFridgeId!},
      );

      setState(() {
        _isLoading = false;
        _statusMessage =
            'Geofencing notification sent!\n'
            'Distance: ${distance.toStringAsFixed(0)}m';
      });
    } catch (e) {
      logger.e('Error testing geofencing: $e');
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error: $e';
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    // Listen for notification navigation - close this screen when notification is tapped
    ref.listen(notificationNavigationProvider, (previous, next) {
      if (next != null && mounted) {
        logger.i('TestNotificationScreen: Notification tapped, closing screen');
        Navigator.of(context).pop();
      }
    });

    if (!isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Test Notifications')),
        body: const Center(child: Text('Please sign in to test notifications')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Test Notifications')),
      body: _isLoading
          ? LoadingIndicatorM3E(message: getRandomLoadingMessage())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // FCM Token Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FCM Token',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          if (_fcmToken != null)
                            Container(
                              constraints: const BoxConstraints(maxHeight: 60),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SelectableText(
                                  _fcmToken!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'No FCM token found. Follow a fridge to generate one, or request permissions manually.',
                                  style: TextStyle(color: Colors.orange),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: _requestPermissionsAndGetToken,
                                  icon: const Icon(Icons.notifications_active),
                                  label: const Text(
                                    'Request Permissions & Get Token',
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _loadTestInfo,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh Info'),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _checkNotificationPermissions,
                            icon: const Icon(Icons.info_outline),
                            label: const Text('Check Notification Permissions'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Subscribed Fridges
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Followed Fridges',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          if (_followedFridges.isEmpty)
                            const Text(
                              'No followed fridges. Follow a fridge first.',
                              style: TextStyle(color: Colors.orange),
                            )
                          else
                            DropdownButtonFormField<String>(
                              // ignore: deprecated_member_use
                              value: _selectedFridgeId,
                              decoration: const InputDecoration(
                                labelText: 'Select Fridge',
                                border: OutlineInputBorder(),
                              ),
                              items: _followedFridges.map((fridgeId) {
                                return DropdownMenuItem(
                                  value: fridgeId,
                                  child: Text(
                                    fridgeId,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedFridgeId = value);
                              },
                              isExpanded: true,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Test Buttons
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Test Notifications',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _createTestStatusReport,
                              icon: const Icon(Icons.cloud_upload),
                              label: const Text('Create Test Status Report'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Creates a status report in Realtime Database.\n'
                            'This triggers Cloud Function: onFridgeStatusUpdate',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _testLocalNotification,
                              icon: const Icon(Icons.notifications),
                              label: const Text('Test Local Notification'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Sends a local notification directly.\n'
                            'Tests notification display and navigation.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _testGeofencingNotification,
                              icon: const Icon(Icons.location_on),
                              label: const Text('Test Geofencing Notification'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tests geofencing notification.\n'
                            'Requires being within 400m of the fridge.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_statusMessage != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _statusMessage!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Instructions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Testing Instructions',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '1. Follow a fridge from the map or list\n'
                            '2. Copy your FCM token (shown above)\n'
                            '3. Use Firebase Console to send a test message:\n'
                            '   - Go to Firebase Console > Cloud Messaging\n'
                            '   - Click "Send test message"\n'
                            '   - Paste your FCM token\n'
                            '   - Add data: {"type": "fridge_update", "fridgeId": "your-fridge-id"}\n'
                            '4. Or create a test status report (button above)\n'
                            '5. Test local notifications directly\n'
                            '6. Test geofencing by being near a fridge',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

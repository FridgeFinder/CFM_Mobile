import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/providers/subscriptions_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../domain/models/subscription_preferences.dart';
import '../../../../core/utils/app_logger.dart';

/// Dialog for subscribing to a fridge with notification preferences
class SubscriptionDialog extends ConsumerStatefulWidget {
  final String fridgeId;
  final bool isVolunteer;
  final SubscriptionPreferences? existingSubscription;

  const SubscriptionDialog({
    super.key,
    required this.fridgeId,
    required this.isVolunteer,
    this.existingSubscription,
  });

  @override
  ConsumerState<SubscriptionDialog> createState() => _SubscriptionDialogState();
}

class _SubscriptionDialogState extends ConsumerState<SubscriptionDialog> {
  late NotificationPreferences _preferences;

  @override
  void initState() {
    super.initState();
    if (widget.existingSubscription != null) {
      _preferences = widget.existingSubscription!.notificationPreferences;
    } else {
      // Default preferences based on volunteer status
      _preferences = NotificationPreferences(
        updatedWithFood: !widget.isVolunteer, // Non-volunteers get food updates
        runningLow: widget.isVolunteer,
        empty: widget.isVolunteer,
        needsCleaning: widget.isVolunteer,
        needsServicing: widget.isVolunteer,
        routineValidation: widget.isVolunteer,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingSubscription != null
          ? 'Edit Subscription'
          : 'Subscribe to Fridge'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select what notifications you want to receive:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Updated with food'),
              value: _preferences.updatedWithFood,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(
                    updatedWithFood: value ?? false,
                  );
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Running low on food'),
              value: _preferences.runningLow,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(
                    runningLow: value ?? false,
                  );
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Empty'),
              value: _preferences.empty,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(
                    empty: value ?? false,
                  );
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Needs cleaning'),
              value: _preferences.needsCleaning,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(
                    needsCleaning: value ?? false,
                  );
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Needs servicing'),
              value: _preferences.needsServicing,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(
                    needsServicing: value ?? false,
                  );
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Routine validation (>2 days since update)'),
              value: _preferences.routineValidation,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(
                    routineValidation: value ?? false,
                  );
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              // Check if this is the first subscription
              final subscriptions = await ref.read(subscribedFridgesProvider.future);
              final isFirstSubscription = subscriptions.isEmpty;

              // Request permissions on first subscription
              if (isFirstSubscription) {
                // Request notification permission
                final notificationStatus = await FirebaseMessaging.instance.requestPermission(
                  alert: true,
                  badge: true,
                  sound: true,
                );
                logger.i('Notification permission: ${notificationStatus.authorizationStatus}');

                // Ask about geofencing with explanation
                if (context.mounted) {
                  final enableGeofencing = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Enable Geofencing?'),
                      content: const Text(
                        'Get notifications when near fridges needing attention (within 2-block radius). '
                        'This requires location access to always be enabled in the background.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('No Thanks'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Enable'),
                        ),
                      ],
                    ),
                  );

                  // Request location permission if user wants geofencing
                  if (enableGeofencing == true) {
                    final locationStatus = await Permission.locationAlways.request();
                    logger.i('Location permission: $locationStatus');

                    // Update user profile to enable geofencing
                    if (locationStatus.isGranted) {
                      final userProfile = ref.read(userProfileProvider).value;
                      if (userProfile != null) {
                        final repository = ref.read(authRepositoryProvider);
                        final updatedProfile = userProfile.copyWith(
                          settings: userProfile.settings.copyWith(
                            geofencingEnabled: true,
                          ),
                        );
                        await repository.updateUserProfile(updatedProfile);
                        ref.invalidate(userProfileProvider);
                      }
                    }
                  }
                }
              }

              // Subscribe to fridge
              final manager = ref.read(subscriptionManagerProvider.notifier);
              await manager.subscribeToFridge(widget.fridgeId, _preferences);

              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Subscribed to fridge')),
                );
              }
            } catch (e) {
              logger.e('Error subscribing: $e');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            }
          },
          child: Text(widget.existingSubscription != null ? 'Update' : 'Subscribe'),
        ),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:design_system/design_system.dart';
import '../../domain/models/subscription_preferences.dart';
import '../../../../core/providers/subscriptions_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/utils/app_logger.dart';

enum NotificationPreferencesMode { subscribe, edit }

/// Consolidated dialog for notification preferences (both subscribe and edit)
/// Uses toggle-based UI with icons and switches for better UX
class NotificationPreferencesDialog extends ConsumerStatefulWidget {
  final NotificationPreferencesMode mode;
  final String fridgeId;
  final String? fridgeName;
  final bool? isVolunteer;
  final NotificationPreferences initialPreferences;

  const NotificationPreferencesDialog({
    super.key,
    required this.mode,
    required this.fridgeId,
    this.fridgeName,
    this.isVolunteer,
    required this.initialPreferences,
  });

  /// Factory constructor for subscribe mode
  factory NotificationPreferencesDialog.subscribe({
    required String fridgeId,
    required bool isVolunteer,
    NotificationPreferences? existingPreferences,
  }) {
    final preferences = existingPreferences ??
        NotificationPreferences(
          updatedWithFood: !isVolunteer, // Non-volunteers get food updates
          runningLow: isVolunteer,
          empty: isVolunteer,
          needsCleaning: isVolunteer,
          needsServicing: isVolunteer,
          routineValidation: isVolunteer,
        );

    return NotificationPreferencesDialog(
      mode: NotificationPreferencesMode.subscribe,
      fridgeId: fridgeId,
      isVolunteer: isVolunteer,
      initialPreferences: preferences,
    );
  }

  /// Factory constructor for edit mode
  factory NotificationPreferencesDialog.edit({
    required String fridgeId,
    required String fridgeName,
    required NotificationPreferences initialPreferences,
  }) {
    return NotificationPreferencesDialog(
      mode: NotificationPreferencesMode.edit,
      fridgeId: fridgeId,
      fridgeName: fridgeName,
      initialPreferences: initialPreferences,
    );
  }

  /// Backwards compatibility constructor for EditNotificationPreferencesDialog
  /// @deprecated Use NotificationPreferencesDialog.edit() instead
  factory NotificationPreferencesDialog.editLegacy({
    Key? key,
    required String fridgeId,
    required String fridgeName,
    required NotificationPreferences initialPreferences,
  }) {
    return NotificationPreferencesDialog(
      key: key,
      mode: NotificationPreferencesMode.edit,
      fridgeId: fridgeId,
      fridgeName: fridgeName,
      initialPreferences: initialPreferences,
    );
  }

  @override
  ConsumerState<NotificationPreferencesDialog> createState() =>
      _NotificationPreferencesDialogState();
}

class _NotificationPreferencesDialogState
    extends ConsumerState<NotificationPreferencesDialog> {
  late NotificationPreferences _preferences;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _preferences = widget.initialPreferences;
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);

    if (widget.mode == NotificationPreferencesMode.edit) {
      await _handleEditMode();
    } else {
      await _handleSubscribeMode();
    }
  }

  Future<void> _handleEditMode() async {
    try {
      await ref.read(subscriptionManagerProvider.notifier).updateNotificationPreferences(
            widget.fridgeId,
            _preferences,
          );

      if (mounted) {
        setState(() => _isLoading = false);
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop(true);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Notification preferences updated'),
            backgroundColor: Color(0xFF5FD65F), // M3E Vibrant GREEN for success
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating preferences: $e'),
            backgroundColor: const Color(0xFFFF7043), // M3E Vibrant CORAL for error
          ),
        );
      }
    }
  }

  Future<void> _handleSubscribeMode() async {
    try {
      // Check if this is the first subscription
      final subscriptions = await ref.read(subscribedFridgesProvider.future);
      final isFirstSubscription = subscriptions.isEmpty;

      // Request permissions on first subscription
      if (isFirstSubscription) {
        await _handleFirstSubscriptionPermissions();
        if (!mounted) return;
      }

      // Subscribe to fridge
      final manager = ref.read(subscriptionManagerProvider.notifier);
      await manager.followFridge(widget.fridgeId, _preferences);

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Now following fridge')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFFF7043), // M3E Vibrant CORAL for error
          ),
        );
      }
    }
  }

  Future<void> _handleFirstSubscriptionPermissions() async {
    // Request notification permission
    final notificationStatus = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    logger.i('Notification permission: ${notificationStatus.authorizationStatus}');

    // Only ask about geofencing if user is a volunteer
    final userProfile = ref.read(userProfileProvider).value;
    final isVolunteer = userProfile?.isVolunteer ?? widget.isVolunteer ?? false;

    if (!isVolunteer || !mounted) return;

    final enableGeofencing = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: M3EShapes.dialog,
        title: Text('Enable Geofencing?', style: M3ETypography.headlineSmall),
        content: Text(
          'Get notifications when near fridges needing attention (within 2-block radius). '
          'This requires location access to always be enabled in the background.',
          style: M3ETypography.bodyMedium,
        ),
        actions: [
          TextButtonM3E(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No Thanks'),
          ),
          FilledButtonM3E(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Enable'),
          ),
        ],
      ),
    );

    if (enableGeofencing != true || !mounted) return;

    await _handleGeofencingPermissions();
  }

  Future<void> _handleGeofencingPermissions() async {
    // Use Geolocator for better iOS handling
    LocationPermission permission = await Geolocator.checkPermission();
    logger.i('Current Geolocator permission: $permission');

    // If we already have "always", great!
    if (permission == LocationPermission.always) {
      logger.i('Already have "Always" permission');
      await _enableGeofencingInProfile();
      return;
    }

    // Request permission - this handles iOS two-step flow better
    logger.i('Requesting location permission (will show iOS prompts)...');
    permission = await Geolocator.requestPermission();
    logger.i('After request, permission: $permission');

    if (!mounted) return;

    // On iOS, if user granted "While Using", we need to guide them to enable "Always"
    if (permission == LocationPermission.whileInUse) {
      logger.i('User granted "While Using" - need to upgrade to "Always"');

      // Try requesting "Always" - might work on some iOS versions
      final alwaysStatus = await Permission.locationAlways.request();
      logger.i('Attempted Always upgrade: $alwaysStatus');

      if (!mounted) return;

      // Check if upgrade succeeded
      if (alwaysStatus.isGranted || alwaysStatus.isLimited) {
        logger.i('Successfully upgraded to Always!');
        permission = LocationPermission.always;
        await _enableGeofencingInProfile();
      } else {
        // iOS didn't show the upgrade prompt - guide to Settings
        logger.w('iOS will not show upgrade prompt - user must use Settings');
        await _showAlwaysLocationDialog();
      }
      return;
    }

    // Check if permission was denied
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      logger.w('Location permission denied: $permission');
      if (mounted) {
        if (permission == LocationPermission.deniedForever) {
          await _showLocationDeniedDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission is required for geofencing.'),
            ),
          );
        }
      }
      return;
    }

    // At this point we should have "always" permission
    if (permission == LocationPermission.always) {
      await _enableGeofencingInProfile();
    }
  }

  Future<void> _enableGeofencingInProfile() async {
    final userProfile = ref.read(userProfileProvider).value;
    if (userProfile != null) {
      final repository = ref.read(authRepositoryProvider);
      final updatedProfile = userProfile.copyWith(
        settings: userProfile.settings.copyWith(
          geofencingEnabled: true,
        ),
      );
      await repository.updateUserProfile(updatedProfile);

      if (mounted) {
        ref.invalidate(userProfileProvider);
        logger.i('Geofencing enabled in user profile');
      }
    }
  }

  Future<void> _showAlwaysLocationDialog() async {
    final shouldOpenSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: M3EShapes.dialog,
        title: Text('Enable "Always Allow" Location', style: M3ETypography.headlineSmall),
        content: Text(
          'For geofencing to work, you need to enable "Always" location access.\n\n'
          'Please tap "Open Settings" and change location to "Always".',
          style: M3ETypography.bodyMedium,
        ),
        actions: [
          TextButtonM3E(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButtonM3E(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );

    if (shouldOpenSettings == true) {
      await openAppSettings();
    }
  }

  Future<void> _showLocationDeniedDialog() async {
    final shouldOpenSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: M3EShapes.dialog,
        title: Text('Enable Location Access', style: M3ETypography.headlineSmall),
        content: Text(
          'Geofencing requires location access to notify you when you\'re near fridges needing help.\n\n'
          'Please tap "Open Settings" and enable location access for FridgeFinder.',
          style: M3ETypography.bodyMedium,
        ),
        actions: [
          TextButtonM3E(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButtonM3E(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );

    if (shouldOpenSettings == true) {
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine dialog title based on mode
    final dialogTitle = widget.mode == NotificationPreferencesMode.edit
        ? 'Notification Preferences'
        : 'Follow Fridge';

    return AlertDialog(
      shape: M3EShapes.dialog,
      title: widget.fridgeName != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dialogTitle,
                  style: M3ETypography.headlineSmall,
                ),
                M3ESpacing.verticalXXS,
                Text(
                  widget.fridgeName!,
                  style: M3ETypography.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            )
          : Text(dialogTitle, style: M3ETypography.headlineSmall),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select which updates you want to receive:',
              style: M3ETypography.bodySmall,
            ),
            M3ESpacing.verticalMD,
            _buildPreferenceSwitch(
              title: 'Updated with Food',
              subtitle: 'When the fridge is restocked',
              value: _preferences.updatedWithFood,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(updatedWithFood: value);
                });
              },
              icon: Icons.shopping_basket,
            ),
            _buildPreferenceSwitch(
              title: 'Running Low',
              subtitle: 'When food supplies are running low',
              value: _preferences.runningLow,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(runningLow: value);
                });
              },
              icon: Icons.trending_down,
            ),
            _buildPreferenceSwitch(
              title: 'Empty',
              subtitle: 'When the fridge is empty',
              value: _preferences.empty,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(empty: value);
                });
              },
              icon: Icons.inbox,
            ),
            _buildPreferenceSwitch(
              title: 'Needs Cleaning',
              subtitle: 'When the fridge needs cleaning',
              value: _preferences.needsCleaning,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(needsCleaning: value);
                });
              },
              icon: Icons.cleaning_services,
            ),
            _buildPreferenceSwitch(
              title: 'Needs Servicing',
              subtitle: 'When the fridge needs maintenance',
              value: _preferences.needsServicing,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(needsServicing: value);
                });
              },
              icon: Icons.build,
            ),
            _buildPreferenceSwitch(
              title: 'Routine Validation',
              subtitle: 'When a status check is needed',
              value: _preferences.routineValidation,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(routineValidation: value);
                });
              },
              icon: Icons.fact_check,
            ),
          ],
        ),
      ),
      actions: [
        TextButtonM3E(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButtonM3E(
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicatorM3E.small(),
                )
              : Text(widget.mode == NotificationPreferencesMode.edit ? 'Save' : 'Follow'),
        ),
      ],
    );
  }

  Widget _buildPreferenceSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: M3ESpacing.sm),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
          M3ESpacing.horizontalSM,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: M3ETypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  subtitle,
                  style: M3ETypography.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          SwitchM3E(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// Backwards compatibility class that redirects to NotificationPreferencesDialog.edit()
/// @deprecated Use NotificationPreferencesDialog.edit() instead
class EditNotificationPreferencesDialog extends NotificationPreferencesDialog {
  const EditNotificationPreferencesDialog({
    super.key,
    required super.fridgeId,
    required String fridgeName,
    required super.initialPreferences,
  }) : super(
          mode: NotificationPreferencesMode.edit,
          fridgeName: fridgeName,
        );
}

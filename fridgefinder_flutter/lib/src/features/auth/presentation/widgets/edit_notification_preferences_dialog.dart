import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:design_system/design_system.dart';
import '../../domain/models/subscription_preferences.dart';
import '../../../../core/providers/notification_providers.dart';
import '../../../../core/providers/subscriptions_provider.dart';
import '../../../../core/utils/app_logger.dart';

enum NotificationPreferencesMode { subscribe, edit }

/// Consolidated dialog for notification preferences (both subscribe and edit)
/// Uses toggle-based UI with icons and switches for better UX
class NotificationPreferencesDialog extends ConsumerStatefulWidget {
  final NotificationPreferencesMode mode;
  final String fridgeId;
  final String? fridgeName;
  final NotificationPreferences initialPreferences;

  const NotificationPreferencesDialog({
    super.key,
    required this.mode,
    required this.fridgeId,
    this.fridgeName,
    required this.initialPreferences,
  });

  /// Factory constructor for subscribe mode
  factory NotificationPreferencesDialog.subscribe({
    required String fridgeId,
    NotificationPreferences? existingPreferences,
  }) {
    final preferences = existingPreferences ?? const NotificationPreferences();

    return NotificationPreferencesDialog(
      mode: NotificationPreferencesMode.subscribe,
      fridgeId: fridgeId,
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

  Future<void> _handleUnfollow(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: M3EShapes.dialog,
        title: Text('Unfollow?', style: M3ETypography.headlineSmall),
        content: const Text('You will no longer receive notifications about this fridge.'),
        actions: [
          TextButtonM3E(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF7043),
            ),
            child: const Text('Unfollow'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      final manager = ref.read(subscriptionManagerProvider.notifier);
      await manager.unfollowFridge(widget.fridgeId);
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(this.context).pop(true);
        ScaffoldMessenger.of(this.context).showSnackBar(
          const SnackBar(content: Text('Unfollowed fridge')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _handleEditMode() async {
    try {
      await _ensureNotificationsEnabledPrompt();
      if (!mounted) return;

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
      await _ensureNotificationsEnabledPrompt();
      if (!mounted) return;

      // Subscribe to fridge
      final manager = ref.read(subscriptionManagerProvider.notifier);
      await manager.followFridge(widget.fridgeId, _preferences);

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop(true);
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

  Future<void> _ensureNotificationsEnabledPrompt() async {
    final fcmService = ref.read(fcmServiceProvider);

    final initiallyEnabled = await fcmService.getDeviceNotificationsEnabled();
    if (initiallyEnabled) {
      return;
    }

    final enabledAfterPrompt = await fcmService.setDeviceNotificationsEnabled(true);
    logger.i('Device notification state after prompt: $enabledAfterPrompt');

    if (!mounted) return;

    if (enabledAfterPrompt) {
      return;
    }

    await _showNotificationsDisabledDialog();

    // Geofencing opt-in is temporarily disabled for first-time follow.
    // Users can still enable geofencing later from Profile settings.
  }

  Future<void> _showNotificationsDisabledDialog() async {
    final shouldOpenSettings = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: M3EShapes.dialog,
        title: Text('Enable Notifications', style: M3ETypography.headlineSmall),
        content: Text(
          'Notifications are currently disabled for FridgeFinder. '
          'Enable them in Settings to receive fridge alerts.',
          style: M3ETypography.bodyMedium,
        ),
        actions: [
          TextButtonM3E(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Not Now'),
          ),
          FilledButtonM3E(
            onPressed: () => Navigator.of(ctx).pop(true),
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
              'Select which updates you want to receive by channel:',
              style: M3ETypography.bodySmall,
            ),
            M3ESpacing.verticalMD,
            _buildChannelSection(
              title: 'Push Notifications',
              channel: _preferences.contactTypePreferences.device,
              onChanged: (channel) {
                setState(() {
                  _preferences = _preferences.copyWith(
                    contactTypePreferences: _preferences.contactTypePreferences.copyWith(
                      device: channel,
                    ),
                  );
                });
              },
            ),
            M3ESpacing.verticalSM,
            _buildChannelSection(
              title: 'Email Notifications',
              channel: _preferences.contactTypePreferences.email,
              onChanged: (channel) {
                setState(() {
                  _preferences = _preferences.copyWith(
                    contactTypePreferences: _preferences.contactTypePreferences.copyWith(
                      email: channel,
                    ),
                  );
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        if (widget.mode == NotificationPreferencesMode.edit)
          TextButton(
            onPressed: _isLoading ? null : () => _handleUnfollow(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF7043), // M3E alert/destructive
            ),
            child: const Text('Unfollow'),
          ),
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

  Widget _buildChannelSection({
    required String title,
    required FridgeNotificationFlags channel,
    required ValueChanged<FridgeNotificationFlags> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: M3ETypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        M3ESpacing.verticalXS,
        _buildPreferenceSwitch(
          title: 'Out of Order',
          subtitle: 'When fridge requires maintenance',
          value: channel.outOfOrder,
          onChanged: (value) => onChanged(channel.copyWith(outOfOrder: value)),
          icon: Icons.build,
        ),
        _buildPreferenceSwitch(
          title: 'Needs Cleaning',
          subtitle: 'When fridge is marked dirty',
          value: channel.dirty,
          onChanged: (value) => onChanged(channel.copyWith(dirty: value)),
          icon: Icons.cleaning_services,
        ),
        _buildPreferenceSwitch(
          title: 'No Food',
          subtitle: 'When fridge is empty',
          value: channel.noFood,
          onChanged: (value) => onChanged(channel.copyWith(noFood: value)),
          icon: Icons.inbox,
        ),
        _buildPreferenceSwitch(
          title: 'Has Food',
          subtitle: 'When fridge has available food',
          value: channel.hasFood,
          onChanged: (value) => onChanged(channel.copyWith(hasFood: value)),
          icon: Icons.shopping_basket,
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



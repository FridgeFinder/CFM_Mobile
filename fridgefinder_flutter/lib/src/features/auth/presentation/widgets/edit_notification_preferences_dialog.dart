import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:design_system/design_system.dart';
import '../../domain/models/fridge_notification_preferences.dart';
import '../../../../core/providers/notification_providers.dart';
import '../../../../core/providers/followed_fridges_provider.dart';

enum NotificationPreferencesMode { follow, edit }

/// Consolidated dialog for notification preferences (both follow and edit)
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

  /// Factory constructor for follow mode
  factory NotificationPreferencesDialog.follow({
    required String fridgeId,
    NotificationPreferences? existingPreferences,
  }) {
    final preferences = existingPreferences ?? const NotificationPreferences();

    return NotificationPreferencesDialog(
      mode: NotificationPreferencesMode.follow,
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

  void _closeDialog() {
    Navigator.of(context).pop(false);
  }

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
      await _handleFollowMode();
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
      final manager = ref.read(followManagerProvider.notifier);
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

      await ref.read(followManagerProvider.notifier).updateNotificationPreferences(
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

  Future<void> _handleFollowMode() async {
    try {
      await _ensureNotificationsEnabledPrompt();
      if (!mounted) return;

      // Follow to fridge
      final manager = ref.read(followManagerProvider.notifier);
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
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final statusBarIconBrightness =
      brightness == Brightness.dark ? Brightness.light : Brightness.dark;
    final statusBarBrightness =
      brightness == Brightness.dark ? Brightness.dark : Brightness.light;

    // Determine dialog title based on mode
    final dialogTitle = widget.mode == NotificationPreferencesMode.edit
        ? 'Notification Preferences'
        : 'Follow Fridge';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: colorScheme.surface,
        statusBarIconBrightness: statusBarIconBrightness,
        statusBarBrightness: statusBarBrightness,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: M3ESpacing.sm,
                    right: M3ESpacing.sm,
                  ),
                  child: IconButton(
                    onPressed: _isLoading ? null : _closeDialog,
                    tooltip: 'Close notification preferences',
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.pressed) ||
                            states.contains(WidgetState.hovered) ||
                            states.contains(WidgetState.focused)) {
                          return const Color.fromRGBO(0, 0, 0, 0.15);
                        }

                        return const Color.fromRGBO(0, 0, 0, 0.08);
                      }),
                      foregroundColor: WidgetStatePropertyAll(
                        colorScheme.onSurfaceVariant,
                      ),
                      fixedSize: const WidgetStatePropertyAll(Size(36, 36)),
                      shape: const WidgetStatePropertyAll(CircleBorder()),
                    ),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    M3ESpacing.md,
                    M3ESpacing.xs,
                    M3ESpacing.md,
                    M3ESpacing.lg,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            dialogTitle,
                            style: M3ETypography.headlineSmall.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (widget.fridgeName != null) ...[
                            M3ESpacing.verticalXXS,
                            Text(
                              widget.fridgeName!,
                              style: M3ETypography.bodyMedium.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                          M3ESpacing.verticalMD,
                          // Text(
                          //   'Select which updates you want to receive by channel:',
                          //   style: M3ETypography.bodySmall,
                          // ),
                          M3ESpacing.verticalMD,
                          _buildColumnHeaders(),
                          ..._notificationRows.map(_buildNotificationRow),
                          M3ESpacing.verticalMD,
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isLoading ? null : _closeDialog,
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 40),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    backgroundColor: colorScheme.surfaceContainerHighest,
                                    foregroundColor: colorScheme.onSurfaceVariant,
                                    side: BorderSide(color: colorScheme.outlineVariant),
                                    shape: const StadiumBorder(),
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              M3ESpacing.horizontalXS,
                              Expanded(
                                child: FilledButtonM3E(
                                  onPressed: _isLoading ? null : _handleSave,
                                  child: _isLoading
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicatorM3E.small(),
                                        )
                                      : Text(
                                          widget.mode == NotificationPreferencesMode.edit
                                              ? 'Save'
                                              : 'Follow',
                                        ),
                                ),
                              ),
                            ],
                          ),
                          if (widget.mode == NotificationPreferencesMode.edit) ...[
                            M3ESpacing.verticalXS,
                            Center(
                              child: TextButton(
                                onPressed:
                                    _isLoading ? null : () => _handleUnfollow(context),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      const Color(0xFFFF7043), // M3E alert/destructive
                                ),
                                child: const Text('Unfollow Fridge'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Column headers above the Push / Email switch columns.
  Widget _buildColumnHeaders() {
    final colorScheme = Theme.of(context).colorScheme;
    final headerStyle = M3ETypography.bodySmall.copyWith(
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurfaceVariant,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: M3ESpacing.xxs),
      child: Row(
        children: [
          const Expanded(child: SizedBox.shrink()),
          SizedBox(width: 56, child: Center(child: Text('Push', style: headerStyle))),
          SizedBox(width: 56, child: Center(child: Text('Email', style: headerStyle))),
        ],
      ),
    );
  }

  Widget _buildNotificationRow(_NotificationRowConfig row) {
    final device = _preferences.contactTypePreferences.device;
    final email = _preferences.contactTypePreferences.email;

    return Padding(
      padding: EdgeInsets.only(bottom: M3ESpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.title,
                  style: M3ETypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  row.subtitle,
                  style: M3ETypography.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 56,
            child: Center(
              child: _buildToggleButton(
                icon: Icons.phone_android,
                active: row.getValue(device),
                tooltip: 'Toggle push notifications for ${row.title}',
                onTap: () {
                  setState(() {
                    _preferences = _preferences.copyWith(
                      contactTypePreferences: _preferences.contactTypePreferences.copyWith(
                        device: row.setValue(device, !row.getValue(device)),
                      ),
                    );
                  });
                },
              ),
            ),
          ),
          SizedBox(
            width: 56,
            child: Center(
              child: _buildToggleButton(
                icon: Icons.mail_outline,
                active: row.getValue(email),
                tooltip: 'Toggle email notifications for ${row.title}',
                onTap: () {
                  setState(() {
                    _preferences = _preferences.copyWith(
                      contactTypePreferences: _preferences.contactTypePreferences.copyWith(
                        email: row.setValue(email, !row.getValue(email)),
                      ),
                    );
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Toggle button styled like the website's push/email icon toggles.
  Widget _buildToggleButton({
    required IconData icon,
    required bool active,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: active ? colorScheme.primary : colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: active ? colorScheme.primary : colorScheme.outlineVariant,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              icon,
              size: 20,
              color: active ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// Row definition pairing a notification type with its flag getter/setter.
class _NotificationRowConfig {
  final String title;
  final String subtitle;
  final bool Function(FridgeNotificationFlags) getValue;
  final FridgeNotificationFlags Function(FridgeNotificationFlags, bool) setValue;

  const _NotificationRowConfig({
    required this.title,
    required this.subtitle,
    required this.getValue,
    required this.setValue,
  });
}

const _notificationRows = [
  _NotificationRowConfig(
    title: 'Needs Repairs',
    subtitle: 'Alert me when repairs are needed',
    getValue: _getOutOfOrder,
    setValue: _setOutOfOrder,
  ),
  _NotificationRowConfig(
    title: 'Needs Cleaning',
    subtitle: 'Alert me when cleaning is needed',
    getValue: _getDirty,
    setValue: _setDirty,
  ),
  _NotificationRowConfig(
    title: 'Out of Food',
    subtitle: 'Alert me when food runs out',
    getValue: _getNoFood,
    setValue: _setNoFood,
  ),
  _NotificationRowConfig(
    title: 'New Food Added',
    subtitle: 'Alert me when food is restocked',
    getValue: _getHasFood,
    setValue: _setHasFood,
  ),
];

bool _getOutOfOrder(FridgeNotificationFlags f) => f.outOfOrder;
FridgeNotificationFlags _setOutOfOrder(FridgeNotificationFlags f, bool v) =>
    f.copyWith(outOfOrder: v);
bool _getDirty(FridgeNotificationFlags f) => f.dirty;
FridgeNotificationFlags _setDirty(FridgeNotificationFlags f, bool v) => f.copyWith(dirty: v);
bool _getNoFood(FridgeNotificationFlags f) => f.noFood;
FridgeNotificationFlags _setNoFood(FridgeNotificationFlags f, bool v) => f.copyWith(noFood: v);
bool _getHasFood(FridgeNotificationFlags f) => f.hasFood;
FridgeNotificationFlags _setHasFood(FridgeNotificationFlags f, bool v) => f.copyWith(hasFood: v);



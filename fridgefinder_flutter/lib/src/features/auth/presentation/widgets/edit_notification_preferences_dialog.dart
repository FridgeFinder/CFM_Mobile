import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/subscription_preferences.dart';
import '../../../../core/providers/subscriptions_provider.dart';

/// Dialog for editing notification preferences for a subscribed fridge
class EditNotificationPreferencesDialog extends ConsumerStatefulWidget {
  final String fridgeId;
  final String fridgeName;
  final NotificationPreferences initialPreferences;

  const EditNotificationPreferencesDialog({
    super.key,
    required this.fridgeId,
    required this.fridgeName,
    required this.initialPreferences,
  });

  @override
  ConsumerState<EditNotificationPreferencesDialog> createState() =>
      _EditNotificationPreferencesDialogState();
}

class _EditNotificationPreferencesDialogState
    extends ConsumerState<EditNotificationPreferencesDialog> {
  late NotificationPreferences _preferences;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _preferences = widget.initialPreferences;
  }

  Future<void> _savePreferences() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(subscriptionManagerProvider.notifier).updateNotificationPreferences(
            widget.fridgeId,
            _preferences,
          );

      if (mounted) {
        // Set loading to false BEFORE popping to hide loading indicator during close animation
        setState(() => _isLoading = false);

        // Capture ScaffoldMessenger reference BEFORE popping dialog
        final messenger = ScaffoldMessenger.of(context);

        Navigator.of(context).pop(true);

        // Show SnackBar using captured messenger
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Notification preferences updated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating preferences: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Notification Preferences'),
          const SizedBox(height: 4),
          Text(
            widget.fridgeName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select which updates you want to receive:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
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
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _savePreferences,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

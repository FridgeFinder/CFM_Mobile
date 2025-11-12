import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:design_system/design_system.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/environment_provider.dart';
import '../../../core/providers/location_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/points_provider.dart';
import '../../../features/auth/domain/models/user_profile.dart';
import '../../../features/auth/presentation/widgets/sign_in_widget.dart';
import '../../../features/auth/presentation/widgets/reauthenticate_dialog.dart';
import 'test_notification_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);
    final environment = ref.watch(environmentProvider);
    final locationAccessEnabled = ref.watch(locationAccessProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: M3ESpacing.all(M3ESpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Section (if authenticated)
              Consumer(
                builder: (context, ref, child) {
                  final isAuthenticated = ref.watch(isAuthenticatedProvider);
                  final userProfileAsync = ref.watch(userProfileProvider);
                  final userPointsAsync = ref.watch(userPointsProvider);

                  if (!isAuthenticated) {
                    return CardM3E(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Account',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          M3ESpacing.verticalMD,
                          Text(
                            'Sign in to subscribe to fridges and track your volunteer points',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          M3ESpacing.verticalMD,
                          FilledButtonM3E(
                            icon: Icons.login,
                            onPressed: () {
                              DialogM3E.showCustom(
                                context: context,
                                child: Padding(
                                  padding: M3ESpacing.all(M3ESpacing.xl),
                                  child: SignInWidget(),
                                ),
                              );
                            },
                            child: const Text('Sign In'),
                          ),
                        ],
                      ),
                    );
                  }

                  return userProfileAsync.when(
                    loading: () => const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    error: (_, _) => const SizedBox.shrink(),
                    data: (profile) {
                      if (profile == null) return const SizedBox.shrink();

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    child: Text(
                                      profile.username
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          profile.username,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                        ),
                                        if (profile.isVolunteer)
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.volunteer_activism,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Volunteer',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (profile.isVolunteer) ...[
                                const SizedBox(height: 16),
                                userPointsAsync.when(
                                  loading: () => const SizedBox.shrink(),
                                  error: (_, _) => const SizedBox.shrink(),
                                  data: (points) => Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.stars,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '$points points',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              // Notification Settings
                              _buildNotificationSettings(context, ref, profile),
                              const SizedBox(height: 16),
                              // Sign Out Button
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _showSignOutDialog(context, ref),
                                icon: const Icon(Icons.logout),
                                label: const Text('Sign Out'),
                              ),
                              const SizedBox(height: 12),
                              // Delete Account Button
                              OutlinedButton.icon(
                                onPressed: () => _showDeleteAccountDialog(
                                  context,
                                  ref,
                                  profile.userId,
                                ),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  'Delete Account',
                                  style: TextStyle(color: Colors.red),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location Settings',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Allow Location Access',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Enable to show distances and sort fridges by proximity',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: locationAccessEnabled,
                            onChanged: (value) async {
                              final result = await ref
                                  .read(locationAccessProvider.notifier)
                                  .setAccessWithPermission(value);

                              if (context.mounted) {
                                if (result['openSettings'] == true) {
                                  // Guide user to settings
                                  final shouldOpenSettings = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Location Permission Required'),
                                      content: const Text(
                                        'Location access is disabled. '
                                        'Please enable it in Settings to see distances and sort fridges by proximity.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: const Text('Open Settings'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (shouldOpenSettings == true) {
                                    await openAppSettings();
                                  }
                                } else if (result['disabled'] == true) {
                                  // User disabled location
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Location access disabled. '
                                        'To revoke location permission, go to Settings.'),
                                      duration: Duration(seconds: 4),
                                    ),
                                  );
                                } else if (result['success'] == false && result['openSettings'] != true) {
                                  // Permission denied but not permanently
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Location permission is required'),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // API Environment Settings Section - Only show in debug mode
              if (kDebugMode) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Debug Tools',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () async {
                            try {
                              final repository = ref.read(
                                authRepositoryProvider,
                              );
                              await repository.signOut();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Signed out - Auth state reset',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset Auth State (Sign Out)'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const TestNotificationScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.notifications_active),
                          label: const Text('Test Notifications'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'API Environment',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Current: ${environment.name.toUpperCase()}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select API environment',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        // Environment Options
                        _buildEnvironmentOption(
                          context: context,
                          ref: ref,
                          title: 'Production',
                          subtitle: 'api-prod.communityfridgefinder.com',
                          environment: ApiEnvironment.prod,
                          isSelected: environment == ApiEnvironment.prod,
                          icon: Icons.cloud,
                        ),
                        const SizedBox(height: 12),
                        _buildEnvironmentOption(
                          context: context,
                          ref: ref,
                          title: 'Development',
                          subtitle: 'api-dev.communityfridgefinder.com',
                          environment: ApiEnvironment.dev,
                          isSelected: environment == ApiEnvironment.dev,
                          icon: Icons.construction,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Theme Settings Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme Settings',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Choose your preferred theme',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      // Theme Mode Options
                      _buildThemeOption(
                        context: context,
                        ref: ref,
                        title: 'System',
                        subtitle: 'Follow device settings',
                        mode: AppThemeMode.system,
                        isSelected: themeMode == AppThemeMode.system,
                        icon: Icons.brightness_auto,
                      ),
                      const SizedBox(height: 12),
                      _buildThemeOption(
                        context: context,
                        ref: ref,
                        title: 'Light',
                        subtitle: 'Always use light theme',
                        mode: AppThemeMode.light,
                        isSelected: themeMode == AppThemeMode.light,
                        icon: Icons.light_mode,
                      ),
                      const SizedBox(height: 12),
                      _buildThemeOption(
                        context: context,
                        ref: ref,
                        title: 'Dark',
                        subtitle: 'Always use dark theme',
                        mode: AppThemeMode.dark,
                        isSelected: themeMode == AppThemeMode.dark,
                        icon: Icons.dark_mode,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnvironmentOption({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required ApiEnvironment environment,
    required bool isSelected,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () {
        ref.read(environmentProvider.notifier).setEnvironment(environment);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required AppThemeMode mode,
    required bool isSelected,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () {
        ref.read(appThemeModeProvider.notifier).setThemeMode(mode);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notification Settings',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Push Notifications',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Receive notifications about your subscribed fridges',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Switch(
              value: profile.settings.notificationsEnabled,
              onChanged: (value) async {
                try {
                  // Request permission if enabling
                  if (value) {
                    final messaging = FirebaseMessaging.instance;

                    // Check current notification settings
                    final currentSettings = await messaging.getNotificationSettings();

                    if (currentSettings.authorizationStatus == AuthorizationStatus.denied ||
                        currentSettings.authorizationStatus == AuthorizationStatus.notDetermined) {
                      // Request permission
                      final settings = await messaging.requestPermission(
                        alert: true,
                        badge: true,
                        sound: true,
                      );

                      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
                          settings.authorizationStatus != AuthorizationStatus.provisional) {
                        if (context.mounted) {
                          // If permanently denied, guide to settings
                          final shouldOpenSettings = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Notification Permission Required'),
                              content: const Text(
                                'Push notifications are disabled. '
                                'Please enable them in Settings to receive updates about your subscribed fridges.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
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
                        return;
                      }
                    }
                  } else {
                    // Disabling - just update the setting
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications disabled. '
                            'To revoke notification permission, go to Settings.'),
                          duration: Duration(seconds: 4),
                        ),
                      );
                    }
                  }

                  final updatedProfile = profile.copyWith(
                    settings: profile.settings.copyWith(
                      notificationsEnabled: value,
                    ),
                  );
                  final repository = ref.read(authRepositoryProvider);
                  await repository.updateUserProfile(updatedProfile);
                  ref.invalidate(userProfileProvider);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Only show geofencing toggle for volunteers
        if (profile.isVolunteer) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Geofencing',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Get notified when near fridges needing attention',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Switch(
              value: profile.settings.geofencingEnabled,
              onChanged: (value) async {
                try {
                  // Request location permission if enabling
                  if (value) {
                    // Use Geolocator for location permissions (handles iOS two-step flow)
                    LocationPermission permission = await Geolocator.checkPermission();
                    debugPrint('Geofencing toggle - current permission: $permission');

                    // Check if we already have 'always' permission
                    if (permission == LocationPermission.always) {
                      debugPrint('Already have "always" permission, enabling geofencing');
                      // Already have always permission, proceed
                    } else if (permission == LocationPermission.denied ||
                               permission == LocationPermission.whileInUse) {
                      // Request permission (this will show system dialog)
                      debugPrint('Requesting location permission...');
                      permission = await Geolocator.requestPermission();
                      debugPrint('After request, permission: $permission');

                      // Check if we got at least whileInUse or always
                      if (permission == LocationPermission.denied ||
                          permission == LocationPermission.deniedForever) {
                        if (context.mounted) {
                          if (permission == LocationPermission.deniedForever) {
                            // Guide to settings
                            final shouldOpenSettings = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Enable Location Access'),
                                content: const Text(
                                  'Geofencing requires location access to notify you when you\'re near fridges needing help.\n\n'
                                  'Please tap "Open Settings" and enable location access for FridgeFinder.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Open Settings'),
                                  ),
                                ],
                              ),
                            );

                            if (shouldOpenSettings == true) {
                              await Geolocator.openAppSettings();
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Location permission is required for geofencing'),
                              ),
                            );
                          }
                        }
                        return;
                      }

                      // If we got whileInUse, show info about upgrading to always
                      if (permission == LocationPermission.whileInUse && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Geofencing enabled. For background notifications, '
                              'change to "Always Allow" in Settings.',
                            ),
                            duration: Duration(seconds: 5),
                          ),
                        );
                      }
                    } else if (permission == LocationPermission.deniedForever) {
                      // Permanently denied, guide to settings
                      debugPrint('Location permission permanently denied');
                      if (context.mounted) {
                        final shouldOpenSettings = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Enable Location Access'),
                            content: const Text(
                              'Geofencing requires location access to notify you when you\'re near fridges needing help.\n\n'
                              'Please tap "Open Settings" and enable location access for FridgeFinder.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Open Settings'),
                              ),
                            ],
                          ),
                        );

                        if (shouldOpenSettings == true) {
                          await Geolocator.openAppSettings();
                        }
                      }
                      return;
                    }
                  } else {
                    // Disabling - just update the setting
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Geofencing disabled'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }

                  final updatedProfile = profile.copyWith(
                    settings: profile.settings.copyWith(geofencingEnabled: value),
                  );
                  final repository = ref.read(authRepositoryProvider);
                  await repository.updateUserProfile(updatedProfile);
                  ref.invalidate(userProfileProvider);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        ],
        Text(
          'Notification Frequency',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        SegmentedButton<NotificationFrequency>(
          showSelectedIcon: false,
          style: ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          segments: [
            ButtonSegment(
              value: NotificationFrequency.immediate,
              label: SizedBox(
                width: 80,
                child: Center(
                  child: Text(
                    'Immediate',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            ButtonSegment(
              value: NotificationFrequency.daily,
              label: SizedBox(
                width: 80,
                child: Center(
                  child: Text(
                    'Daily',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            ButtonSegment(
              value: NotificationFrequency.weekly,
              label: SizedBox(
                width: 80,
                child: Center(
                  child: Text(
                    'Weekly',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
          selected: {profile.settings.notificationFrequency},
          onSelectionChanged: (Set<NotificationFrequency> selected) async {
            if (selected.isNotEmpty) {
              try {
                final updatedProfile = profile.copyWith(
                  settings: profile.settings.copyWith(
                    notificationFrequency: selected.first,
                  ),
                );
                final repository = ref.read(authRepositoryProvider);
                await repository.updateUserProfile(updatedProfile);
                ref.invalidate(userProfileProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification frequency updated')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            }
          },
        ),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final repository = ref.read(authRepositoryProvider);
                await repository.signOut();

                // Invalidate providers to update UI
                ref.invalidate(authUserProvider);
                ref.invalidate(userProfileProvider);
                ref.invalidate(isAuthenticatedProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Signed out successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error signing out: $e')),
                  );
                }
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'Are you sure you want to delete your account? This will permanently delete your profile, subscriptions, and points. Your status reports will be anonymized but kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showFinalDeleteConfirmation(context, ref, userId);
            },
            child: const Text('Continue', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Text(
          'This action cannot be undone. Your account and all associated data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Get repository and user references FIRST, before any navigation
              final repository = ref.read(authRepositoryProvider);
              final authUser = ref.read(currentAuthUserProvider);
              final user = authUser.value;

              if (user == null) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Not authenticated')),
                  );
                }
                return;
              }

              // Show re-authentication dialog (on top of the confirmation dialog)
              if (!context.mounted) return;

              final reauthenticated = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => ReauthenticateDialog(user: user),
              );

              debugPrint('Re-authentication result: $reauthenticated');

              if (reauthenticated != true) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account deletion cancelled'),
                    ),
                  );
                }
                return;
              }

              // If re-authentication succeeded, close the confirmation dialog first
              if (!context.mounted) {
                debugPrint('Context not mounted after reauth, aborting deletion');
                return;
              }

              // Close the confirmation dialog
              Navigator.of(context).pop();

              // Wait a frame for the dialog to fully close
              await Future.delayed(const Duration(milliseconds: 100));

              // If re-authentication succeeded, proceed with deletion
              debugPrint('Proceeding with account deletion for user: $userId');

              if (!context.mounted) {
                debugPrint('Context not mounted after closing dialog, aborting deletion');
                return;
              }

              debugPrint('Context is mounted, showing loading indicator');

              // Show loading indicator
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 16),
                      Text('Deleting account...'),
                    ],
                  ),
                  duration: Duration(seconds: 30),
                ),
              );

              debugPrint('Loading indicator shown, calling deleteAccount');

              // Get ScaffoldMessenger before deletion to ensure it persists
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              try {
                debugPrint('About to call deleteAccount with userId: $userId');

                await repository.deleteAccount(userId);

                debugPrint('Account deleted successfully from deleteAccount call');

                // Clear loading indicator and show success message
                // Use the messenger we captured before deletion
                scaffoldMessenger.clearSnackBars();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Account deleted successfully'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );

                debugPrint('Account deletion complete - Firebase will auto-update auth state');
              } catch (e) {
                debugPrint('Error deleting account: $e');

                if (context.mounted) {
                  String errorMessage = 'Error deleting account: $e';

                  // Check if it's a requires-recent-login error (shouldn't happen after reauth)
                  if (e.toString().contains('requires-recent-login')) {
                    errorMessage = 'Please try again. Your session may have expired.';
                  }

                  // Clear any previous snackbars
                  ScaffoldMessenger.of(context).clearSnackBars();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

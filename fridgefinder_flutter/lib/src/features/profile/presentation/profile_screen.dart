import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:design_system/design_system.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/environment_provider.dart';
import '../../../core/providers/location_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/points_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/auth/domain/models/user_profile.dart';
import '../../../features/auth/presentation/widgets/sign_in_widget.dart';
import '../../../features/auth/presentation/widgets/reauthenticate_dialog.dart';
import '../../../common_widgets/loading_messages.dart';
import 'test_notification_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Local state for optimistic updates
  bool? _localNotificationsEnabled;
  bool? _localGeofencingEnabled;
  // NotificationFrequency? _localNotificationFrequency; // TODO: Restore when frequency UI is re-enabled

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(appThemeModeProvider);
    final environment = ref.watch(environmentProvider);
    final locationAccessEnabled = ref.watch(locationAccessProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: M3ESpacing.lg,
            right: M3ESpacing.lg,
            top: M3ESpacing.sm,
            bottom: M3ESpacing.lg,
          ),
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
                            'Sign in to follow fridges and track your volunteer points',
                            style: M3ETypography.bodyMedium,
                          ),
                          M3ESpacing.verticalMD,
                          FilledButtonM3E(
                            icon: Icons.login,
                            onPressed: () {
                              DialogM3E.showCustom(
                                context: context,
                                barrierDismissible: true,
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

                  // Keep showing previous data during refresh to prevent jank
                  final profile = userProfileAsync.hasValue
                      ? userProfileAsync.value
                      : null;

                  // Only show loading on initial load (no cached data)
                  if (profile == null && userProfileAsync.isLoading) {
                    return LoadingIndicatorM3E(
                      message: getRandomLoadingMessage(),
                    );
                  }

                  if (profile == null) return const SizedBox.shrink();

                  return CardM3E(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              child: Text(
                                profile.username.substring(0, 1).toUpperCase(),
                                style: M3ETypography.titleMedium,
                              ),
                            ),
                            M3ESpacing.horizontalMD,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.username,
                                    style: M3ETypography.titleLarge,
                                  ),
                                  if (profile.isVolunteer)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.volunteer_activism,
                                          size: 16,
                                        ),
                                        M3ESpacing.horizontalXS,
                                        Text(
                                          'Volunteer',
                                          style: M3ETypography.bodySmall,
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (profile.isVolunteer) ...[
                          M3ESpacing.verticalMD,
                          userPointsAsync.when(
                            loading: () => const SizedBox.shrink(),
                            error: (_, _) => const SizedBox.shrink(),
                            data: (points) => Container(
                              padding: M3ESpacing.all(M3ESpacing.sm),
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
                                  M3ESpacing.horizontalXS,
                                  Text(
                                    '$points points',
                                    style: M3ETypography.titleMedium.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        M3ESpacing.verticalMD,
                        // Notification Settings
                        SizedBox(
                          width: double.infinity,
                          child: _buildNotificationSettings(
                            context,
                            ref,
                            profile,
                          ),
                        ),
                        M3ESpacing.verticalMD,
                        // Sign Out Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButtonM3E(
                            onPressed: () => _showSignOutDialog(context, ref),
                            icon: Icons.logout,
                            child: const Text('Sign Out'),
                          ),
                        ),
                        M3ESpacing.verticalSM,
                        // Delete Account Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _showDeleteAccountDialog(
                              context,
                              ref,
                              profile.userId,
                            ),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Delete Account'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              M3ESpacing.verticalMD,
              CardM3E(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Allow Location Access',
                                style: M3ETypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              M3ESpacing.verticalXS,
                              Text(
                                'Enable to show distances and sort fridges by proximity',
                                style: M3ETypography.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        SwitchM3E(
                          value: locationAccessEnabled,
                          onChanged: (value) async {
                            final result = await ref
                                .read(locationAccessProvider.notifier)
                                .setAccessWithPermission(value);

                            if (context.mounted) {
                              if (result['openSettings'] == true) {
                                // Guide user to settings
                                final shouldOpenSettings =
                                    await DialogM3E.showCustom<bool>(
                                      context: context,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Location Permission Required',
                                            style: M3ETypography.headlineSmall,
                                          ),
                                          M3ESpacing.verticalMD,
                                          Text(
                                            'Location access is disabled. '
                                            'Please enable it in Settings to see distances and sort fridges by proximity.',
                                            style: M3ETypography.bodyMedium,
                                          ),
                                          M3ESpacing.verticalXL,
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              TextButtonM3E(
                                                onPressed: () => Navigator.of(
                                                  context,
                                                ).pop(false),
                                                child: const Text('Cancel'),
                                              ),
                                              M3ESpacing.horizontalXS,
                                              FilledButtonM3E(
                                                onPressed: () => Navigator.of(
                                                  context,
                                                ).pop(true),
                                                child: const Text(
                                                  'Open Settings',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );

                                if (shouldOpenSettings == true) {
                                  await openAppSettings();
                                }
                              } else if (result['disabled'] == true) {
                                // User disabled location
                                showSnackbarM3E(
                                  context: context,
                                  message:
                                      'Location access disabled. '
                                      'To revoke location permission, go to Settings.',
                                  duration: SnackbarDuration.long_,
                                );
                              } else if (result['success'] == false &&
                                  result['openSettings'] != true) {
                                // Permission denied but not permanently
                                showSnackbarM3E(
                                  context: context,
                                  message: 'Location permission is required',
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
              // API Environment Settings Section - Only show in debug mode
              if (kDebugMode) ...[
                M3ESpacing.verticalMD,
                CardM3E(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OutlinedButtonM3E(
                        onPressed: () async {
                          try {
                            final repository = ref.read(authRepositoryProvider);
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
                        icon: Icons.refresh,
                        child: const Text('Reset Auth State (Sign Out)'),
                      ),
                      M3ESpacing.verticalSM,
                      OutlinedButtonM3E(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TestNotificationScreen(),
                            ),
                          );
                        },
                        icon: Icons.notifications_active,
                        child: const Text('Test Notifications'),
                      ),
                    ],
                  ),
                ),
                M3ESpacing.verticalMD,
                CardM3E(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current: ${environment.name.toUpperCase()}',
                        style: M3ETypography.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      M3ESpacing.verticalMD,
                      Text(
                        'Select API environment',
                        style: M3ETypography.bodyMedium,
                      ),
                      M3ESpacing.verticalMD,
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
                      M3ESpacing.verticalSM,
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
                M3ESpacing.verticalMD,
              ],
              // Theme Settings Section
              CardM3E(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose your preferred theme',
                      style: M3ETypography.bodyMedium,
                    ),
                    M3ESpacing.verticalMD,
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
                    M3ESpacing.verticalSM,
                    _buildThemeOption(
                      context: context,
                      ref: ref,
                      title: 'Light',
                      subtitle: 'Always use light theme',
                      mode: AppThemeMode.light,
                      isSelected: themeMode == AppThemeMode.light,
                      icon: Icons.light_mode,
                    ),
                    M3ESpacing.verticalSM,
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
              M3ESpacing.verticalMD,
              // Privacy Policy Section
              CardM3E(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.privacy_tip_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        M3ESpacing.horizontalSM,
                        Text(
                          'Privacy & Legal',
                          style: M3ETypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    M3ESpacing.verticalSM,
                    Text(
                      'Learn how we protect and handle your data',
                      style: M3ETypography.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    M3ESpacing.verticalMD,
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButtonM3E(
                        onPressed: () async {
                          final uri = Uri.parse(AppConstants.privacyPolicyUrl);
                          if (!await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          )) {
                            if (context.mounted) {
                              showSnackbarM3E(
                                context: context,
                                message: 'Could not open privacy policy',
                              );
                            }
                          }
                        },
                        icon: Icons.open_in_new,
                        child: const Text('View Privacy Policy'),
                      ),
                    ),
                  ],
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
                    style: M3ETypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  Text(subtitle, style: M3ETypography.bodySmall),
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
                    style: M3ETypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  Text(subtitle, style: M3ETypography.bodySmall),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Notification Settings',
          style: M3ETypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        M3ESpacing.verticalSM,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Push Notifications', style: M3ETypography.bodyLarge),
                  Text(
                    'Receive notifications about your followed fridges',
                    style: M3ETypography.bodyMedium,
                  ),
                ],
              ),
            ),
            SwitchM3E(
              value:
                  _localNotificationsEnabled ??
                  profile.settings.notificationsEnabled,
              onChanged: (value) async {
                // Optimistic update - change UI immediately
                setState(() => _localNotificationsEnabled = value);

                try {
                  // Request permission if enabling
                  if (value) {
                    final messaging = FirebaseMessaging.instance;

                    // Check current notification settings
                    final currentSettings = await messaging
                        .getNotificationSettings();

                    if (currentSettings.authorizationStatus ==
                            AuthorizationStatus.denied ||
                        currentSettings.authorizationStatus ==
                            AuthorizationStatus.notDetermined) {
                      // Request permission
                      final settings = await messaging.requestPermission(
                        alert: true,
                        badge: true,
                        sound: true,
                      );

                      if (settings.authorizationStatus !=
                              AuthorizationStatus.authorized &&
                          settings.authorizationStatus !=
                              AuthorizationStatus.provisional) {
                        if (context.mounted) {
                          // If permanently denied, guide to settings
                          final shouldOpenSettings =
                              await DialogM3E.showCustom<bool>(
                                context: context,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Notification Permission Required',
                                      style: M3ETypography.headlineSmall,
                                    ),
                                    M3ESpacing.verticalMD,
                                    Text(
                                      'Push notifications are disabled. '
                                      'Please enable them in Settings to receive updates about your followed fridges.',
                                      style: M3ETypography.bodyMedium,
                                    ),
                                    M3ESpacing.verticalXL,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButtonM3E(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        M3ESpacing.horizontalXS,
                                        FilledButtonM3E(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text('Open Settings'),
                                        ),
                                      ],
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
                          content: Text(
                            'Notifications disabled. '
                            'To revoke notification permission, go to Settings.',
                          ),
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

                  // Invalidate to refresh data, but local state prevents jank
                  ref.invalidate(userProfileProvider);

                  // Clear local state after a delay to let new data load
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      setState(() => _localNotificationsEnabled = null);
                    }
                  });
                } catch (e) {
                  // On error, revert local state and show error
                  if (mounted) {
                    setState(() => _localNotificationsEnabled = !value);
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
            ),
          ],
        ),
        M3ESpacing.verticalSM,
        // Only show geofencing toggle for volunteers
        if (profile.isVolunteer) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Geofencing', style: M3ETypography.bodyLarge),
                    Text(
                      'Get notified when near fridges needing attention',
                      style: M3ETypography.bodyMedium,
                    ),
                  ],
                ),
              ),
              SwitchM3E(
                value:
                    _localGeofencingEnabled ??
                    profile.settings.geofencingEnabled,
                onChanged: (value) async {
                  // Optimistic update - change UI immediately
                  setState(() => _localGeofencingEnabled = value);

                  try {
                    // Request location permission if enabling
                    if (value) {
                      // Use Geolocator for location permissions (handles iOS two-step flow)
                      LocationPermission permission =
                          await Geolocator.checkPermission();
                      debugPrint(
                        'Geofencing toggle - current permission: $permission',
                      );

                      // Check if we already have 'always' permission
                      if (permission == LocationPermission.always) {
                        debugPrint(
                          'Already have "always" permission, enabling geofencing',
                        );
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
                            if (permission ==
                                LocationPermission.deniedForever) {
                              // Guide to settings
                              final shouldOpenSettings =
                                  await DialogM3E.showCustom<bool>(
                                    context: context,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Enable Location Access',
                                          style: M3ETypography.headlineSmall,
                                        ),
                                        M3ESpacing.verticalMD,
                                        Text(
                                          'Geofencing requires location access to notify you when you\'re near fridges needing help.\n\n'
                                          'Please tap "Open Settings" and enable location access for FridgeFinder.',
                                          style: M3ETypography.bodyMedium,
                                        ),
                                        M3ESpacing.verticalXL,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButtonM3E(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            M3ESpacing.horizontalXS,
                                            FilledButtonM3E(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(true),
                                              child: const Text(
                                                'Open Settings',
                                              ),
                                            ),
                                          ],
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
                                  content: Text(
                                    'Location permission is required for geofencing',
                                  ),
                                ),
                              );
                            }
                          }
                          return;
                        }

                        // If we got whileInUse, show info about upgrading to always
                        if (permission == LocationPermission.whileInUse &&
                            context.mounted) {
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
                      } else if (permission ==
                          LocationPermission.deniedForever) {
                        // Permanently denied, guide to settings
                        debugPrint('Location permission permanently denied');
                        if (context.mounted) {
                          final shouldOpenSettings = await DialogM3E.showCustom<bool>(
                            context: context,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Enable Location Access',
                                  style: M3ETypography.headlineSmall,
                                ),
                                M3ESpacing.verticalMD,
                                Text(
                                  'Geofencing requires location access to notify you when you\'re near fridges needing help.\n\n'
                                  'Please tap "Open Settings" and enable location access for FridgeFinder.',
                                  style: M3ETypography.bodyMedium,
                                ),
                                M3ESpacing.verticalXL,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButtonM3E(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    M3ESpacing.horizontalXS,
                                    FilledButtonM3E(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Open Settings'),
                                    ),
                                  ],
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
                      settings: profile.settings.copyWith(
                        geofencingEnabled: value,
                      ),
                    );
                    final repository = ref.read(authRepositoryProvider);
                    await repository.updateUserProfile(updatedProfile);

                    // Invalidate to refresh data, but local state prevents jank
                    ref.invalidate(userProfileProvider);

                    // Clear local state after a delay to let new data load
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        setState(() => _localGeofencingEnabled = null);
                      }
                    });
                  } catch (e) {
                    // On error, revert local state and show error
                    if (mounted) {
                      setState(() => _localGeofencingEnabled = !value);
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
              ),
            ],
          ),
          M3ESpacing.verticalSM,
        ],
        // TODO: Notification Frequency - Hidden until batching implementation complete
        // Requires: Cloud Function batching logic, scheduled functions, pending notifications queue
        // See: NOTIFICATION_SYSTEM_DOCUMENTATION.md section on "Implement Notification Frequency"
        //
        // Uncomment this section when backend batching is implemented:
        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: [
        //     Text('Notification Frequency', style: M3ETypography.bodyLarge),
        //     M3ESpacing.verticalXS,
        //     SegmentedButtonM3E<NotificationFrequency>(
        //       showSelectedIcon: false,
        //       emptySelectionAllowed: false,
        //       segments: const [
        //         ButtonSegment(
        //           value: NotificationFrequency.immediate,
        //           label: Text('Immediate'),
        //         ),
        //         ButtonSegment(
        //           value: NotificationFrequency.daily,
        //           label: Text('Daily'),
        //         ),
        //         ButtonSegment(
        //           value: NotificationFrequency.weekly,
        //           label: Text('Weekly'),
        //         ),
        //       ],
        //       selected: {
        //         _localNotificationFrequency ??
        //             profile.settings.notificationFrequency,
        //       },
        //       onSelectionChanged: (Set<NotificationFrequency> selected) async {
        //         if (selected.isNotEmpty) {
        //           setState(() => _localNotificationFrequency = selected.first);
        //           try {
        //             final updatedProfile = profile.copyWith(
        //               settings: profile.settings.copyWith(
        //                 notificationFrequency: selected.first,
        //               ),
        //             );
        //             final repository = ref.read(authRepositoryProvider);
        //             await repository.updateUserProfile(updatedProfile);
        //             ref.invalidate(userProfileProvider);
        //             Future.delayed(const Duration(milliseconds: 500), () {
        //               if (mounted) {
        //                 setState(() => _localNotificationFrequency = null);
        //               }
        //             });
        //             if (context.mounted) {
        //               ScaffoldMessenger.of(context).showSnackBar(
        //                 const SnackBar(
        //                   content: Text('Notification frequency updated'),
        //                 ),
        //               );
        //             }
        //           } catch (e) {
        //             if (mounted) {
        //               setState(
        //                 () => _localNotificationFrequency =
        //                     profile.settings.notificationFrequency,
        //               );
        //             }
        //             if (context.mounted) {
        //               ScaffoldMessenger.of(
        //                 context,
        //               ).showSnackBar(SnackBar(content: Text('Error: $e')));
        //             }
        //           }
        //         }
        //       },
        //     ),
        //   ],
        // ),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    DialogM3E.showCustom(
      context: context,
      child: Builder(
        builder: (dialogContext) => Padding(
          padding: M3ESpacing.all(M3ESpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sign Out?', style: M3ETypography.headlineSmall),
              M3ESpacing.verticalMD,
              Text(
                'Are you sure you want to sign out?',
                style: M3ETypography.bodyMedium,
              ),
              M3ESpacing.verticalXL,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButtonM3E(
                    onPressed: () {
                      try {
                        Navigator.of(dialogContext, rootNavigator: true).pop();
                      } catch (e) {
                        debugPrint('Error closing dialog: $e');
                      }
                    },
                    child: const Text('Cancel'),
                  ),
                  M3ESpacing.horizontalXS,
                  FilledButtonM3E(
                    onPressed: () async {
                      try {
                        Navigator.of(dialogContext, rootNavigator: true).pop();
                      } catch (e) {
                        debugPrint('Error closing dialog: $e');
                      }
                      try {
                        final repository = ref.read(authRepositoryProvider);
                        await repository.signOut();
                      } catch (e) {
                        if (context.mounted) {
                          showSnackbarM3E(
                            context: context,
                            message: 'Error signing out: $e',
                            backgroundColor: Theme.of(context).colorScheme.error,
                            foregroundColor: Theme.of(context).colorScheme.onError,
                          );
                        }
                      }
                    },
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) {
    DialogM3E.showCustom(
      context: context,
      child: Padding(
        padding: M3ESpacing.all(M3ESpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delete Account?', style: M3ETypography.headlineSmall),
            M3ESpacing.verticalMD,
            Text(
              'Are you sure you want to delete your account? This will permanently delete your profile, subscriptions, and points. Your status reports will be anonymized but kept.',
              style: M3ETypography.bodyMedium,
            ),
            M3ESpacing.verticalXL,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButtonM3E(
                  onPressed: () {
                    try {
                      Navigator.of(context, rootNavigator: true).pop();
                    } catch (e) {
                      debugPrint('Error closing dialog: $e');
                    }
                  },
                  child: const Text('Cancel'),
                ),
                M3ESpacing.horizontalXS,
                FilledButton(
                  onPressed: () {
                    // Close the first dialog using root navigator
                    try {
                      Navigator.of(context, rootNavigator: true).pop();
                    } catch (e) {
                      debugPrint('Error closing first delete dialog: $e');
                    }
                    _showFinalDeleteConfirmation(context, ref, userId);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFinalDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) {
    DialogM3E.showCustom(
      context: context,
      child: Padding(
        padding: M3ESpacing.all(M3ESpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Final Confirmation', style: M3ETypography.headlineSmall),
            M3ESpacing.verticalMD,
            Text(
              'This action cannot be undone. Your account and all associated data will be permanently deleted.',
              style: M3ETypography.bodyMedium,
            ),
            M3ESpacing.verticalXL,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButtonM3E(
                  onPressed: () {
                    try {
                      Navigator.of(context, rootNavigator: true).pop();
                    } catch (e) {
                      debugPrint('Error closing dialog: $e');
                    }
                  },
                  child: const Text('Cancel'),
                ),
                M3ESpacing.horizontalXS,
                FilledButton(
                  onPressed: () async {
                    // Get repository and user references FIRST, before any navigation
                    final repository = ref.read(authRepositoryProvider);
                    final authUser = ref.read(currentAuthUserProvider);
                    final user = authUser.value;

                    if (user == null) {
                      if (context.mounted) {
                        try {
                          Navigator.of(context, rootNavigator: true).pop();
                        } catch (e) {
                          debugPrint('Error closing dialog: $e');
                        }
                        showSnackbarM3E(
                          context: context,
                          message: 'Not authenticated',
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
                        try {
                          Navigator.of(context, rootNavigator: true).pop();
                        } catch (e) {
                          debugPrint('Error closing dialog: $e');
                        }
                        showSnackbarM3E(
                          context: context,
                          message: 'Account deletion cancelled',
                        );
                      }
                      return;
                    }

                    // If re-authentication succeeded, proceed with deletion
                    if (!context.mounted) {
                      debugPrint(
                        'Context not mounted after reauth, aborting deletion',
                      );
                      return;
                    }

                    debugPrint(
                      'Proceeding with account deletion for user: $userId',
                    );
                    debugPrint('Context is mounted, showing loading indicator');

                    // Show loading indicator
                    showSnackbarM3E(
                      context: context,
                      message: 'Deleting account...',
                      duration: SnackbarDuration.long_,
                      icon: const Icon(Icons.hourglass_bottom),
                    );

                    debugPrint(
                      'Loading indicator shown, calling deleteAccount',
                    );

                    try {
                      debugPrint(
                        'About to call deleteAccount with userId: $userId',
                      );

                      await repository.deleteAccount(userId);

                      debugPrint(
                        'Account deleted successfully from deleteAccount call',
                      );

                      // Show success message and navigate away
                      if (context.mounted) {
                        // Close the confirmation dialog using root navigator
                        try {
                          Navigator.of(context, rootNavigator: true).pop();
                          debugPrint('Dialog closed successfully');
                        } catch (e) {
                          debugPrint('Error closing dialog: $e');
                        }

                        // Wait a moment to allow dialog to close
                        await Future.delayed(const Duration(milliseconds: 300));

                        if (context.mounted) {
                          showSnackbarM3E(
                            context: context,
                            message: 'Account deleted successfully',
                            icon: const Icon(Icons.check_circle),
                            backgroundColor: Colors.green,
                            duration: SnackbarDuration.short_,
                          );

                          // Wait a moment for the message to be visible, then navigate to home
                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );

                          if (context.mounted) {
                            debugPrint(
                              'Navigating to home after account deletion',
                            );
                            context.go('/');
                          }
                        }
                      }

                      debugPrint(
                        'Account deletion complete - Firebase will auto-update auth state',
                      );
                    } catch (e) {
                      debugPrint('Error deleting account: $e');

                      if (context.mounted) {
                        String errorMessage = 'Error deleting account: $e';

                        // Check if it's a requires-recent-login error (shouldn't happen after reauth)
                        if (e.toString().contains('requires-recent-login')) {
                          errorMessage =
                              'Please try again. Your session may have expired.';
                        }

                        // Close the dialog first so user can see the error and try again
                        try {
                          Navigator.of(context, rootNavigator: true).pop();
                          debugPrint('Dialog closed after error');
                        } catch (e) {
                          debugPrint(
                            'Error closing dialog after deletion error: $e',
                          );
                        }

                        showSnackbarM3E(
                          context: context,
                          message: errorMessage,
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onError,
                          duration: SnackbarDuration.long_,
                        );
                      }
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  child: const Text('Delete Account'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

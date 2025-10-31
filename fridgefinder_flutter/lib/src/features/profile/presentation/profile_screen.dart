import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/environment_provider.dart';
import '../../../core/providers/location_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final environment = ref.watch(environmentProvider);
    final locationAccessEnabled = ref.watch(locationAccessProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Settings Section
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
                              await ref
                                  .read(locationAccessProvider.notifier)
                                  .setAccessWithPermission(value);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // API Environment Settings Section
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        ref.read(themeModeProvider.notifier).setThemeMode(mode);
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
}

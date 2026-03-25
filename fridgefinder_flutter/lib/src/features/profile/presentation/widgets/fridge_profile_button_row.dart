import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:design_system/design_system.dart';
import '../../../map/domain/models/fridge_domain.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/subscriptions_provider.dart';
import '../../../auth/presentation/widgets/edit_notification_preferences_dialog.dart';
import '../../../auth/presentation/widgets/sign_in_widget.dart';

/// Follow/Unfollow + Directions button row.
/// Watches `isFridgeSubscribedProvider` only.
class FridgeProfileButtonRow extends ConsumerWidget {
  final FridgeDomain fridge;

  const FridgeProfileButtonRow({super.key, required this.fridge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final isSubscribedAsync = ref.watch(isFridgeSubscribedProvider(fridge.id));

    if (!isAuthenticated) {
      return _buildButtonRow(
        context: context,
        followButton: _buildFollowButton(
          context: context,
          onPressed: () => _showSignInAndFollowDialog(context, ref),
        ),
        directionsButton: _buildDirectionsButton(context),
      );
    }

    return isSubscribedAsync.when(
      loading: () => const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicatorM3E.small(strokeWidth: 2)),
      ),
      error: (_, _) => const SizedBox(height: 40),
      data: (isSubscribed) {
        if (isSubscribed) {
          return _buildButtonRow(
            context: context,
            followButton: _buildUnfollowButton(
              context: context,
              onPressed: () => _showUnfollowDialog(context, ref),
            ),
            directionsButton: _buildDirectionsButton(context),
          );
        }

        return _buildButtonRow(
          context: context,
          followButton: _buildFollowButton(
            context: context,
            onPressed: () => _showFollowDialog(context, ref),
          ),
          directionsButton: _buildDirectionsButton(context),
        );
      },
    );
  }

  Widget _buildButtonRow({
    required BuildContext context,
    required Widget followButton,
    required Widget directionsButton,
  }) {
    return Row(
      children: [
        Expanded(child: followButton),
        SizedBox(width: M3ESpacing.sm),
        Expanded(child: directionsButton),
      ],
    );
  }

  Widget _buildFollowButton({
    required BuildContext context,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 40,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: M3EColors.follow,
          foregroundColor: Colors.black87,
        ),
        icon: const Icon(Icons.favorite_border, size: 20),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Follow', style: M3ETypography.labelLarge.copyWith(color: Colors.black87)),
        ),
      ),
    );
  }

  Widget _buildUnfollowButton({
    required BuildContext context,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 40,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: M3EColors.secondary,
          side: const BorderSide(color: M3EColors.secondary),
        ),
        icon: const Icon(Icons.favorite, size: 20),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Unfollow', style: M3ETypography.labelLarge.copyWith(color: M3EColors.secondary)),
        ),
      ),
    );
  }

  Widget _buildDirectionsButton(BuildContext context) {
    return OutlinedButtonM3E(
      onPressed: () => _openDirections(context),
      icon: Icons.directions,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text('Directions', style: M3ETypography.labelLarge),
      ),
    );
  }

  Future<void> _showFollowDialog(BuildContext context, WidgetRef ref) async {
    try {
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      if (!isAuthenticated) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please sign in to follow')),
          );
        }
        return;
      }

      final userProfileAsync = await ref.read(userProfileProvider.future);
      if (userProfileAsync == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please complete your profile first')),
          );
        }
        return;
      }

      final subscriptionAsync = await ref.read(
        fridgeSubscriptionPreferencesProvider(fridge.id).future,
      );

      if (!context.mounted) return;

      await showDialog(
        context: context,
        builder: (dialogContext) => NotificationPreferencesDialog.subscribe(
          fridgeId: fridge.id,
          isVolunteer: userProfileAsync.isVolunteer,
          existingPreferences: subscriptionAsync?.notificationPreferences,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showSignInAndFollowDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(M3ESpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Sign In to Follow', style: M3ETypography.headlineSmall),
                  SizedBox(height: M3ESpacing.md),
                  const Text('Sign in to follow this fridge and receive notifications.'),
                  SizedBox(height: M3ESpacing.xl),
                  SignInWidget(
                    onSignInSuccess: () {
                      if (context.mounted) {
                        _showFollowDialog(context, ref);
                      }
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(dialogContext).pop(),
                tooltip: 'Close',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnfollowDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await DialogM3E.showConfirmation(
      context: context,
      title: 'Unfollow?',
      message: 'Are you sure you want to unfollow this fridge? You will no longer receive notifications about it.',
      confirmText: 'Unfollow',
      isDestructive: true,
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final manager = ref.read(subscriptionManagerProvider.notifier);
      await manager.unfollowFridge(fridge.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unfollowed fridge')),
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

  Future<void> _openDirections(BuildContext context) async {
    final lat = fridge.location.geoLat;
    final lng = fridge.location.geoLng;
    final address = Uri.encodeComponent(fridge.location.fullAddress);

    final mapOptions = <_MapAppOption>[
      _MapAppOption(
        name: 'Google Maps',
        icon: Icons.map,
        url: Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng'),
        appUrl: Uri.parse('comgooglemaps://?q=$lat,$lng'),
      ),
      _MapAppOption(
        name: 'Apple Maps',
        icon: Icons.map,
        url: Uri.parse('https://maps.apple.com/?q=$address&ll=$lat,$lng'),
        appUrl: Uri.parse('maps://?q=$address&ll=$lat,$lng'),
      ),
      _MapAppOption(
        name: 'Waze',
        icon: Icons.navigation,
        url: null,
        appUrl: Uri.parse('waze://?ll=$lat,$lng&navigate=yes'),
      ),
    ];

    final availableOptions = <_MapAppOption>[];
    for (final option in mapOptions) {
      if (await canLaunchUrl(option.appUrl)) {
        availableOptions.add(option);
      } else if (option.url != null && await canLaunchUrl(option.url!)) {
        availableOptions.add(option);
      }
    }

    if (!context.mounted) return;

    if (availableOptions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No map apps available')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(M3ESpacing.md),
              child: Text('Choose a map app', style: M3ETypography.labelLarge),
            ),
            ...availableOptions.map(
              (option) => ListTile(
                leading: Icon(option.icon),
                title: Text(option.name),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    if (await canLaunchUrl(option.appUrl)) {
                      await launchUrl(option.appUrl, mode: LaunchMode.externalApplication);
                    } else if (option.url != null) {
                      await launchUrl(option.url!, mode: LaunchMode.externalApplication);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to open ${option.name}')),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapAppOption {
  final String name;
  final IconData icon;
  final Uri? url;
  final Uri appUrl;

  const _MapAppOption({
    required this.name,
    required this.icon,
    required this.url,
    required this.appUrl,
  });
}

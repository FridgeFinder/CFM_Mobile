import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:design_system/design_system.dart';
import '../../../map/domain/models/fridge_domain.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/followed_fridges_provider.dart';
import '../../../auth/presentation/widgets/edit_notification_preferences_dialog.dart';
import '../../../auth/presentation/widgets/sign_in_widget.dart';

/// Follow/Unfollow + Directions button row.
/// Watches `isFridgeFollowedProvider` only.
class FridgeProfileButtonRow extends ConsumerWidget {
  final FridgeDomain fridge;

  const FridgeProfileButtonRow({super.key, required this.fridge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final condition = fridge.latestFridgeReport?.condition;

    // Ghost fridges: hide follow button entirely
    if (condition == FridgeCondition.ghost) {
      return _buildButtonRow(
        context: context,
        followButton: const SizedBox.shrink(),
        directionsButton: _buildDirectionsButton(context),
      );
    }

    // Not-at-location fridges: show disabled follow button
    if (condition == FridgeCondition.notAtLocation) {
      return _buildButtonRow(
        context: context,
        followButton: Semantics(
          label: 'Follow disabled, fridge not at location',
          child: _buildFollowButton(
            context: context,
            onPressed: null,
            label: 'Not at Location',
          ),
        ),
        directionsButton: _buildDirectionsButton(context),
      );
    }

    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final isFollowed = ref.watch(isFridgeFollowedProvider(fridge.id));

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

    if (isFollowed) {
      return _buildButtonRow(
        context: context,
        followButton: _buildEditAlertsButton(
          context: context,
          onPressed: () => _showEditAlertsDialog(context, ref),
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
    VoidCallback? onPressed,
    String label = 'Follow',
  }) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: M3EColors.follow,
        foregroundColor: Colors.black87,
      ),
      icon: const Icon(Icons.favorite_border, size: 20),
      label: Text(
        label,
        style: M3ETypography.labelLarge.copyWith(color: Colors.black87),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEditAlertsButton({
    required BuildContext context,
    required VoidCallback onPressed,
  }) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: M3EColors.follow,
        foregroundColor: Colors.black87,
      ),
      icon: const Icon(Icons.notifications, size: 20),
      label: Text(
        'Edit Alerts',
        style: M3ETypography.labelLarge.copyWith(color: Colors.black87),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDirectionsButton(BuildContext context) {
    return OutlinedButtonM3E(
      onPressed: () => _openDirections(context),
      icon: Icons.directions,
      child: Text(
        'Directions',
        style: M3ETypography.labelLarge,
        overflow: TextOverflow.ellipsis,
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

      final alertPreferences = ref.read(
        fridgeAlertPreferencesProvider(fridge.id),
      );

      if (!context.mounted) return;

      final didFollow = await showDialog<bool>(
        context: context,
        barrierColor: Colors.transparent,
        builder: (dialogContext) => NotificationPreferencesDialog.follow(
          fridgeId: fridge.id,
          existingPreferences: alertPreferences?.notificationPreferences,
        ),
      );

      if (didFollow == true && context.mounted) {
        _refreshFollowState(ref);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showSignInAndFollowDialog(BuildContext context, WidgetRef ref) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (routeContext) => SignInWidget(
          onSignInSuccess: () {
            if (context.mounted) {
              _showFollowDialog(context, ref);
            }
          },
        ),
      ),
    );
  }

  Future<void> _showEditAlertsDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final alertPreferences = ref.read(
        fridgeAlertPreferencesProvider(fridge.id),
      );

      if (!context.mounted || alertPreferences == null) return;

      final didUpdate = await showDialog<bool>(
        context: context,
        barrierColor: Colors.transparent,
        builder: (dialogContext) => NotificationPreferencesDialog.edit(
          fridgeId: fridge.id,
          fridgeName: fridge.name,
          initialPreferences: alertPreferences.notificationPreferences,
        ),
      );

      if (didUpdate == true && context.mounted) {
        _refreshFollowState(ref);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _refreshFollowState(WidgetRef ref) {
    ref.invalidate(followedFridgesProvider);
    ref.invalidate(isFridgeFollowedProvider(fridge.id));
    ref.invalidate(fridgeAlertPreferencesProvider(fridge.id));
  }

  Future<void> _openDirections(BuildContext context) async {
    final lat = fridge.location.geoLat;
    final lng = fridge.location.geoLng;
    final address = Uri.encodeComponent(fridge.location.fullAddress);

    final mapOptions = <_MapAppOption>[
      _MapAppOption(
        name: 'Google Maps',
        icon: Icons.map,
        url: Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
        ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No map apps available')));
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
                      await launchUrl(
                        option.appUrl,
                        mode: LaunchMode.externalApplication,
                      );
                    } else if (option.url != null) {
                      await launchUrl(
                        option.url!,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to open ${option.name}'),
                        ),
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

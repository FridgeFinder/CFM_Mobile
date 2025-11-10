import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../map/domain/models/fridge_domain.dart';
import '../../map/presentation/widgets/fridge_marker.dart';
import './widgets/status_update_form.dart';
import '../../../core/providers/location_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/subscriptions_provider.dart';
import '../../../core/providers/drawer_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/distance_calculator.dart' as distance_utils;
import '../../../core/utils/fridge_icon_utils.dart';
import '../../auth/presentation/widgets/subscription_dialog.dart';
import '../../auth/presentation/widgets/sign_in_widget.dart';
import '../../auth/presentation/widgets/edit_notification_preferences_dialog.dart';

/// Model for map app options in the direction chooser
class MapAppOption {
  final String name;
  final IconData icon;
  final Uri? url; // Web URL fallback
  final Uri appUrl; // App-specific URL scheme

  const MapAppOption({
    required this.name,
    required this.icon,
    required this.url,
    required this.appUrl,
  });
}

/// Bottom sheet modal displaying detailed fridge information
class FridgeProfileSheet extends ConsumerStatefulWidget {
  final FridgeDomain fridge;

  const FridgeProfileSheet({super.key, required this.fridge});

  @override
  ConsumerState<FridgeProfileSheet> createState() => _FridgeProfileSheetState();
}

class _FridgeProfileSheetState extends ConsumerState<FridgeProfileSheet>
    with SingleTickerProviderStateMixin {
  String? _lastRoute;
  int _lastCloseTrigger = 0;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    // Store initial route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final router = GoRouter.of(context);
        _lastRoute = router.routerDelegate.currentConfiguration.uri.toString();
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userLocationAsync = ref.watch(userLocationProvider);
    final drawerOpen = ref.watch(drawerStateProvider);
    final closeTrigger = ref.watch(bottomSheetCloseTriggerProvider);

    // Check for route changes, drawer open, or close trigger
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final router = GoRouter.of(context);
      final currentRoute = router.routerDelegate.currentConfiguration.uri
          .toString();

      // Close if route changed, drawer opened, or close trigger fired
      if ((_lastRoute != null && _lastRoute != currentRoute) ||
          (drawerOpen) ||
          (closeTrigger > _lastCloseTrigger)) {
        Navigator.of(context).pop();
        return;
      }

      // Update state
      _lastRoute = currentRoute;
      _lastCloseTrigger = closeTrigger;
    });

    // Calculate distance if user location is available
    double? distance;
    if (userLocationAsync.value != null) {
      final userLocation = userLocationAsync.value!.position;
      final fridgeLocation = LatLng(
        widget.fridge.location.geoLat,
        widget.fridge.location.geoLng,
      );
      distance = distance_utils.DistanceCalculator.calculateDistanceInKm(
        userLocation,
        fridgeLocation,
      );
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      final isSubscribedAsync = ref.watch(
                        isFridgeSubscribedProvider(widget.fridge.id),
                      );
                      final isSubscribed =
                          isSubscribedAsync.whenOrNull(
                            data: (subscribed) => subscribed,
                          ) ??
                          false;

                      final iconWidget = SizedBox(
                        width: 48,
                        height: 48,
                        child: FridgeIconUtils.getFridgeIcon(
                          fridge: widget.fridge,
                          size: 48,
                        ),
                      );

                      // Add green glow if subscribed
                      if (isSubscribed) {
                        return AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: FridgeMarker.subscribedGreen
                                        .withValues(
                                          alpha: _glowAnimation.value * 0.6,
                                        ),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                  BoxShadow(
                                    color: FridgeMarker.subscribedGreen
                                        .withValues(
                                          alpha: _glowAnimation.value * 0.4,
                                        ),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: iconWidget,
                            );
                          },
                        );
                      }
                      return iconWidget;
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.fridge.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Wrap(
                          spacing: 4,
                          runSpacing: 2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (widget.fridge.latestFridgeReport != null)
                              Icon(
                                FridgeIconUtils.getStatusIcon(
                                  widget.fridge.latestFridgeReport!.condition,
                                ),
                                size: 14,
                                color: FridgeIconUtils.getStatusColor(
                                  widget.fridge.latestFridgeReport!.condition,
                                ),
                              ),
                            Text(
                              widget.fridge.statusText,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                            ),
                            if (distance != null) ...[
                              Text(
                                '•',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                    ),
                              ),
                              Text(
                                '${(distance * distance_utils.DistanceCalculator.kmToMilesConversion * 10).round() / 10} mi away',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Subscribe/Unsubscribe Button (in header)
                  Consumer(
                    builder: (context, ref, child) {
                      final isAuthenticated = ref.watch(
                        isAuthenticatedProvider,
                      );
                      final isSubscribedAsync = ref.watch(
                        isFridgeSubscribedProvider(widget.fridge.id),
                      );

                      // If not authenticated, show subscribe button
                      if (!isAuthenticated) {
                        return FilledButton.icon(
                          onPressed: () =>
                              _showSignInAndSubscribeDialog(context, ref),
                          icon: const Icon(Icons.favorite_border, size: 18),
                          label: const Text('Subscribe'),
                          style: FilledButton.styleFrom(
                            backgroundColor: FridgeMarker.subscribedGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            textStyle: const TextStyle(fontSize: 14),
                          ),
                        );
                      }

                      return isSubscribedAsync.when(
                        loading: () => const SizedBox(
                          width: 80,
                          height: 60,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        error: (_, _) => const SizedBox(width: 80, height: 60),
                        data: (isSubscribed) {
                          return isSubscribed
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          _showEditNotificationsDialog(
                                            context,
                                            ref,
                                          ),
                                      icon: const Icon(
                                        Icons.notifications,
                                        size: 14,
                                      ),
                                      label: const Text('Edit'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 12,
                                        ),
                                        minimumSize: const Size(0, 28),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          _showUnsubscribeDialog(context, ref),
                                      icon: const Icon(
                                        Icons.favorite,
                                        size: 14,
                                        color: Colors.red,
                                      ),
                                      label: const Text(
                                        'Unsub',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Colors.red,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 12,
                                        ),
                                        minimumSize: const Size(0, 28),
                                      ),
                                    ),
                                  ],
                                )
                              : FilledButton.icon(
                                  onPressed: () =>
                                      _showSubscribeDialog(context, ref),
                                  icon: const Icon(
                                    Icons.favorite_border,
                                    size: 16,
                                  ),
                                  label: const Text('Subscribe'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor:
                                        FridgeMarker.subscribedGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    textStyle: const TextStyle(fontSize: 12),
                                    minimumSize: const Size(0, 28),
                                  ),
                                );
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Address Section
              _buildSection(
                context: context,
                icon: Icons.location_on,
                title: 'Location',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.fridge.location.fullAddress,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              // Fridge Photo
              if (widget.fridge.photoUrl != null)
                _buildSection(
                  context: context,
                  icon: Icons.image,
                  title: 'Photo',
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.fridge.photoUrl!,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 250,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Photo unavailable',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

              // Latest Report Section
              if (widget.fridge.latestFridgeReport != null)
                _buildSection(
                  context: context,
                  icon: Icons.report,
                  title: 'Latest Report',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Condition',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    FridgeIconUtils.getStatusIcon(
                                      widget
                                          .fridge
                                          .latestFridgeReport!
                                          .condition,
                                    ),
                                    size: 18,
                                    color: FridgeIconUtils.getStatusColor(
                                      widget
                                          .fridge
                                          .latestFridgeReport!
                                          .condition,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget
                                        .fridge
                                        .latestFridgeReport!
                                        .condition
                                        .value,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: FridgeIconUtils.getStatusColor(
                                            widget
                                                .fridge
                                                .latestFridgeReport!
                                                .condition,
                                          ),
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Food Level',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              Text(
                                '${widget.fridge.latestFridgeReport!.foodPercentageInt}%',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (widget.fridge.latestFridgeReport!.notes != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notes',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.fridge.latestFridgeReport!.notes!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      if (widget.fridge.latestFridgeReport!.reportDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Last updated: ${_formatDate(widget.fridge.latestFridgeReport!.reportDate!)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                    ],
                  ),
                ),

              // Status Section (simplified)
              if (widget.fridge.latestFridgeReport == null)
                _buildSection(
                  context: context,
                  icon: Icons.info_outline,
                  title: 'Status',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Condition',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            widget.fridge.statusText,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Food Level',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            widget.fridge.foodLevelText,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Maintainer Section
              if (widget.fridge.maintainer != null &&
                  (widget.fridge.maintainer!.organization != null ||
                      widget.fridge.maintainer!.email != null ||
                      widget.fridge.maintainer!.phone != null ||
                      widget.fridge.maintainer!.name != null))
                _buildSection(
                  context: context,
                  icon: Icons.person,
                  title: 'Maintainer',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.fridge.maintainer?.name != null)
                        Text(widget.fridge.maintainer!.name!),
                      if (widget.fridge.maintainer?.organization != null)
                        Text(widget.fridge.maintainer!.organization!),
                      if (widget.fridge.maintainer?.email != null)
                        Text(widget.fridge.maintainer!.email!),
                      if (widget.fridge.maintainer?.phone != null)
                        Text(widget.fridge.maintainer!.phone!),
                      if (widget.fridge.maintainer?.instagram != null)
                        Text(widget.fridge.maintainer!.instagram!),
                      if (widget.fridge.maintainer?.website != null)
                        Text(widget.fridge.maintainer!.website!),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Status Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showStatusUpdateDialog(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('Report Status Update'),
                ),
              ),

              const SizedBox(height: 16),

              // Directions Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openDirections(context),
                  icon: const Icon(Icons.directions),
                  label: const Text('Get Directions'),
                ),
              ),

              const SizedBox(height: 12),

              // Share Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _share(context),
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 8),
          Padding(padding: const EdgeInsets.only(left: 28.0), child: child),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Status Update'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: StatusUpdateForm(fridge: widget.fridge),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _share(BuildContext context) async {
    // Create slug from fridge name (lowercase, no spaces)
    final slug = widget.fridge.name.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '',
    );
    final fridgeUrl = 'https://www.fridgefinder.app/fridge/$slug';

    try {
      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: fridgeUrl));

      // Show native share dialog
      await Share.share(
        '${widget.fridge.name}\n${widget.fridge.location.fullAddress}\n\nView on FridgeFinder: $fridgeUrl',
        subject: 'Check out this community fridge: ${widget.fridge.name}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share: $e')));
      }
    }
  }

  Future<void> _openDirections(BuildContext context) async {
    final lat = widget.fridge.location.geoLat;
    final lng = widget.fridge.location.geoLng;
    final address = Uri.encodeComponent(widget.fridge.location.fullAddress);

    // Define map app options with their URLs
    final mapOptions = <MapAppOption>[
      MapAppOption(
        name: 'Google Maps',
        icon: Icons.map,
        url: Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
        ),
        appUrl: Uri.parse('comgooglemaps://?q=$lat,$lng'),
      ),
      MapAppOption(
        name: 'Apple Maps',
        icon: Icons.map,
        url: Uri.parse('https://maps.apple.com/?q=$address&ll=$lat,$lng'),
        appUrl: Uri.parse('maps://?q=$address&ll=$lat,$lng'),
      ),
      MapAppOption(
        name: 'Waze',
        icon: Icons.navigation,
        url: null, // Waze doesn't have a web fallback
        appUrl: Uri.parse('waze://?ll=$lat,$lng&navigate=yes'),
      ),
    ];

    // Check which apps are available
    final availableOptions = <MapAppOption>[];
    for (final option in mapOptions) {
      // Try app URL first, then web URL
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

    // Show bottom sheet with available options
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Choose a map app',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...availableOptions.map(
              (option) => ListTile(
                leading: Icon(option.icon),
                title: Text(option.name),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    // Try app URL first
                    if (await canLaunchUrl(option.appUrl)) {
                      await launchUrl(
                        option.appUrl,
                        mode: LaunchMode.externalApplication,
                      );
                    } else if (option.url != null) {
                      // Fall back to web URL
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  Future<void> _showSubscribeDialog(BuildContext context, WidgetRef ref) async {
    try {
      // Check if user is authenticated
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      if (!isAuthenticated) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please sign in to subscribe')),
          );
        }
        return;
      }

      // Wait for user profile and subscription data
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
        fridgeSubscriptionPreferencesProvider(widget.fridge.id).future,
      );

      if (!context.mounted) return;

      await showDialog(
        context: context,
        builder: (dialogContext) => SubscriptionDialog(
          fridgeId: widget.fridge.id,
          isVolunteer: userProfileAsync.isVolunteer,
          existingSubscription: subscriptionAsync,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading subscription: $e')),
        );
      }
    }
  }

  void _showSignInAndSubscribeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sign In to Subscribe',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sign in to subscribe to this fridge and receive notifications.',
                  ),
                  const SizedBox(height: 24),
                  SignInWidget(
                    onSignInSuccess: () {
                      // Close sign-in dialog
                      Navigator.of(dialogContext).pop();
                      // Show subscribe dialog
                      if (context.mounted) {
                        _showSubscribeDialog(context, ref);
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

  Future<void> _showEditNotificationsDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      // Show loading dialog using root navigator to ensure proper stacking
      // ignore: unawaited_futures
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (dialogContext) =>
            const Center(child: CircularProgressIndicator()),
      );

      // Get current notification preferences
      final subscription = await ref.read(
        fridgeSubscriptionPreferencesProvider(widget.fridge.id).future,
      );

      // Close loading dialog using root navigator - CRITICAL: must match how it was shown
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Small delay to ensure loading dialog is fully dismissed before showing next dialog
      await Future.delayed(const Duration(milliseconds: 50));

      if (subscription == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Not subscribed to this fridge')),
          );
        }
        return;
      }

      // Show the edit dialog (also using root navigator for consistency)
      if (context.mounted) {
        await showDialog<bool>(
          context: context,
          useRootNavigator: true,
          builder: (context) => EditNotificationPreferencesDialog(
            fridgeId: widget.fridge.id,
            fridgeName: widget.fridge.name,
            initialPreferences: subscription.notificationPreferences,
          ),
        );
      }
    } catch (error) {
      // Close loading dialog if it's still open
      if (context.mounted) {
        // Try to pop using root navigator, but catch any errors if there's nothing to pop
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {
          // Dialog might already be closed
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading preferences: $error')),
        );
      }
    }
  }

  void _showUnsubscribeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsubscribe?'),
        content: const Text(
          'Are you sure you want to unsubscribe from this fridge? You will no longer receive notifications about it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final manager = ref.read(subscriptionManagerProvider.notifier);
                await manager.unsubscribeFromFridge(widget.fridge.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Unsubscribed from fridge')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text(
              'Unsubscribe',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

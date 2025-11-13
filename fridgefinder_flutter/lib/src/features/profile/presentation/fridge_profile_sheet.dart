import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:design_system/design_system.dart';
import '../../map/domain/models/fridge_domain.dart';
import '../../map/presentation/controllers/fridge_list_controller.dart';
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
import '../../../common_widgets/loading_messages.dart';
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
    // Initialize animation controller with M3E duration
    _glowController = AnimationController(
      duration: M3EMotion.extraLong2, // M3E expressive duration
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

    // Watch fridge data from provider to get latest updates, fallback to widget.fridge
    final fridgeAsync = ref.watch(singleFridgeProvider(widget.fridge.id));
    final fridge = fridgeAsync.whenOrNull(data: (f) => f) ?? widget.fridge;

    // Determine which photo to show - prioritize report photo if available
    final photoUrl = fridge.latestFridgeReport?.photoUrl ?? fridge.photoUrl;

    // Calculate distance if user location is available
    double? distance;
    if (userLocationAsync.value != null) {
      final userLocation = userLocationAsync.value!.position;
      final fridgeLocation = LatLng(
        fridge.location.geoLat,
        fridge.location.geoLng,
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
      builder: (context, scrollController) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // M3E Drag Handle - 32x4dp with 4dp corners
          const DragHandleM3E(),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.all(M3ESpacing.xl), // 24dp edges
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              // Header - M3E Two-row layout (icon+title on row 1, buttons on row 2)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Icon + Title + Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Icon - 48dp with glow effect for subscribed fridges
                      Consumer(
                        builder: (context, ref, child) {
                          final isSubscribedAsync = ref.watch(
                            isFridgeSubscribedProvider(fridge.id),
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
                              fridge: fridge,
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
                                        color: M3EColors.tertiary // Vibrant GREEN #5FD65F
                                            .withValues(
                                              alpha: _glowAnimation.value * 0.6,
                                            ),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                      BoxShadow(
                                        color: M3EColors.tertiary // Vibrant GREEN #5FD65F
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
                      SizedBox(width: M3ESpacing.md), // 16dp between icon and content
                      // Content Column - Title, Address, Status (no buttons here)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Fridge Title - titleLarge (22px) with max 2 lines
                            Text(
                              fridge.name,
                              style: M3ETypography.titleLarge, // 22px Regular
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: M3ESpacing.xxs), // 4dp between title and address
                            // Address - bodyMedium (14px) with max 2 lines
                            Text(
                              fridge.location.fullAddress,
                              style: M3ETypography.bodyMedium.copyWith( // 14px
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: M3ESpacing.xs), // 8dp between groups
                            // Status Row - labelMedium (12px Medium) with icon and distance
                            Row(
                              children: [
                                // Status icon and text
                                if (fridge.latestFridgeReport != null)
                                  Icon(
                                    FridgeIconUtils.getStatusIcon(
                                      fridge.latestFridgeReport!.condition,
                                    ),
                                    size: 12,
                                    color: FridgeIconUtils.getStatusColor(
                                      fridge.latestFridgeReport!.condition,
                                    ),
                                  ),
                                if (fridge.latestFridgeReport != null)
                                  SizedBox(width: M3ESpacing.xxs), // 4dp icon-text gap
                                Flexible(
                                  child: Text(
                                    fridge.statusText,
                                    style: M3ETypography.labelMedium.copyWith( // 12px Medium
                                      color: fridge.latestFridgeReport != null
                                          ? FridgeIconUtils.getStatusColor(
                                              fridge.latestFridgeReport!.condition,
                                            )
                                          : Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Distance (if available)
                                if (distance != null) ...[
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: M3ESpacing.xxs), // 4dp
                                    child: Text(
                                      '•',
                                      style: M3ETypography.labelMedium.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${(distance * distance_utils.DistanceCalculator.kmToMilesConversion * 10).round() / 10} mi',
                                    style: M3ETypography.labelMedium.copyWith( // 12px Medium
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: M3ESpacing.md), // 16dp between rows
                  // Row 2: Subscribe/Edit/Unsubscribe Buttons (full width, side by side)
                  Consumer(
                    builder: (context, ref, child) {
                      final isAuthenticated = ref.watch(
                        isAuthenticatedProvider,
                      );
                      final isSubscribedAsync = ref.watch(
                        isFridgeSubscribedProvider(fridge.id),
                      );

                      // If not authenticated, show subscribe button with GREEN tertiary color
                      if (!isAuthenticated) {
                        return SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () =>
                                _showSignInAndSubscribeDialog(context, ref),
                            style: FilledButton.styleFrom(
                              backgroundColor: M3EColors.tertiary, // GREEN #5FD65F for positive subscribe action
                              foregroundColor: Colors.black87, // Dark text for contrast on light green
                              minimumSize: const Size(0, 40),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.favorite_border, size: 24, color: Colors.black87),
                                const SizedBox(width: 8),
                                Text(
                                  'Subscribe',
                                  style: M3ETypography.labelLarge.copyWith(color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return isSubscribedAsync.when(
                        loading: () => const SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: Center(
                            child: CircularProgressIndicatorM3E.small(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        error: (error, stackTrace) => const SizedBox(
                          width: double.infinity,
                          height: 40,
                        ),
                        data: (isSubscribed) {
                          return isSubscribed
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButtonM3E(
                                        onPressed: () =>
                                            _showEditNotificationsDialog(
                                              context,
                                              ref,
                                            ),
                                        icon: Icons.notifications,
                                        child: Text(
                                          'Edit Alerts',
                                          style: M3ETypography.labelLarge,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: M3ESpacing.sm), // 12dp between buttons
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            _showUnsubscribeDialog(context, ref),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: M3EColors.secondary, // PINK for favorite/heart action
                                          side: BorderSide(color: M3EColors.secondary),
                                          minimumSize: const Size(0, 40),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.favorite, size: 24, color: M3EColors.secondary),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Unsubscribe',
                                              style: M3ETypography.labelLarge.copyWith(
                                                color: M3EColors.secondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: () =>
                                        _showSubscribeDialog(context, ref),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: M3EColors.tertiary, // GREEN #5FD65F for positive subscribe action
                                      foregroundColor: Colors.black87,
                                      minimumSize: const Size(0, 40),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.favorite_border, size: 24, color: Colors.black87),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Subscribe',
                                          style: M3ETypography.labelLarge.copyWith(color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                        },
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: M3ESpacing.xl), // 24dp between header and content

              // Fridge Photo - Show report photo if available, otherwise main photo
              if (photoUrl != null)
                _buildSection(
                  context: context,
                  icon: Icons.image,
                  title: 'Photo',
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        photoUrl,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        // Use report timestamp as key to force refresh when report updates
                        key: ValueKey(
                          '${photoUrl}_${fridge.latestFridgeReport?.timestamp ?? fridge.latestFridgeReport?.epochTimestamp ?? ''}',
                        ),
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
                                  style: M3ETypography.bodySmall,
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
              if (fridge.latestFridgeReport != null)
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
                                style: M3ETypography.bodySmall.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    FridgeIconUtils.getStatusIcon(
                                      fridge.latestFridgeReport!.condition,
                                    ),
                                    size: 18,
                                    color: FridgeIconUtils.getStatusColor(
                                      fridge.latestFridgeReport!.condition,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    fridge.latestFridgeReport!.condition.value,
                                    style: M3ETypography.bodyLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: FridgeIconUtils.getStatusColor(
                                        fridge.latestFridgeReport!.condition,
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
                                style: M3ETypography.bodySmall.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '${fridge.latestFridgeReport!.foodPercentageInt}%',
                                style: M3ETypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (fridge.latestFridgeReport!.notes != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notes',
                              style: M3ETypography.bodySmall.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              fridge.latestFridgeReport!.notes!,
                              style: M3ETypography.bodyMedium,
                            ),
                          ],
                        ),
                      if (fridge.latestFridgeReport!.reportDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Last updated: ${_formatDate(fridge.latestFridgeReport!.reportDate!)}',
                            style: M3ETypography.bodySmall.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              // Status Section (simplified)
              if (fridge.latestFridgeReport == null)
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
                            style: M3ETypography.bodySmall,
                          ),
                          Text(
                            fridge.statusText,
                            style: M3ETypography.bodyMedium.copyWith(
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
                            style: M3ETypography.bodySmall,
                          ),
                          Text(
                            fridge.foodLevelText,
                            style: M3ETypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Maintainer Section
              if (fridge.maintainer != null &&
                  (fridge.maintainer!.organization != null ||
                      fridge.maintainer!.email != null ||
                      fridge.maintainer!.phone != null ||
                      fridge.maintainer!.name != null))
                _buildSection(
                  context: context,
                  icon: Icons.person,
                  title: 'Maintainer',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (fridge.maintainer?.name != null)
                        Text(fridge.maintainer!.name!),
                      if (fridge.maintainer?.organization != null)
                        Text(fridge.maintainer!.organization!),
                      if (fridge.maintainer?.email != null)
                        Text(fridge.maintainer!.email!),
                      if (fridge.maintainer?.phone != null)
                        Text(fridge.maintainer!.phone!),
                      if (fridge.maintainer?.instagram != null)
                        Text(fridge.maintainer!.instagram!),
                      if (fridge.maintainer?.website != null)
                        Text(fridge.maintainer!.website!),
                    ],
                  ),
                ),

              SizedBox(height: M3ESpacing.xl), // 24dp

              // Status Update Button - M3E Tonal button (40dp height)
              SizedBox(
                width: double.infinity,
                child: FilledTonalButtonM3E(
                  onPressed: () => _showStatusUpdateDialog(context),
                  icon: Icons.edit,
                  child: Text(
                    'Report Status Update',
                    style: M3ETypography.labelLarge,
                  ),
                ),
              ),

              SizedBox(height: M3ESpacing.md), // 16dp between elements

              // Directions Button - M3E Filled button (40dp height)
              SizedBox(
                width: double.infinity,
                child: FilledButtonM3E(
                  onPressed: () => _openDirections(context),
                  icon: Icons.directions,
                  child: Text(
                    'Get Directions',
                    style: M3ETypography.labelLarge,
                  ),
                ),
              ),

              SizedBox(height: M3ESpacing.sm), // 12dp dense spacing

              // Share Button - M3E Text button (40dp height)
              SizedBox(
                width: double.infinity,
                child: TextButtonM3E(
                  onPressed: () => _share(context),
                  icon: Icons.share,
                  child: Text(
                    'Share',
                    style: M3ETypography.labelLarge,
                  ),
                ),
              ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
      padding: EdgeInsets.only(bottom: M3ESpacing.lg), // 20dp
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              SizedBox(width: M3ESpacing.xs), // 8dp
              Text(
                title,
                style: M3ETypography.labelLarge, // 14px Medium
              ),
            ],
          ),
          SizedBox(height: M3ESpacing.xs), // 8dp
          Padding(
            padding: EdgeInsets.only(left: M3ESpacing.xxl), // 28dp
            child: child,
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context) {
    // Get current fridge data from provider
    final fridgeAsync = ref.read(singleFridgeProvider(widget.fridge.id));
    final fridge = fridgeAsync.whenOrNull(data: (f) => f) ?? widget.fridge;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Padding(
            padding: EdgeInsets.all(M3ESpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Report Status Update',
                  style: M3ETypography.headlineSmall,
                ),
                SizedBox(height: M3ESpacing.md),
                // Form - takes remaining space
                Expanded(
                  child: StatusUpdateForm(fridge: fridge),
                ),
              ],
            ),
          ),
        ),
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
              padding: EdgeInsets.all(M3ESpacing.md), // 16dp
              child: Text(
                'Choose a map app',
                style: M3ETypography.labelLarge, // 14px Medium
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
        builder: (dialogContext) => NotificationPreferencesDialog.subscribe(
          fridgeId: widget.fridge.id,
          isVolunteer: userProfileAsync.isVolunteer,
          existingPreferences: subscriptionAsync?.notificationPreferences,
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
                    style: M3ETypography.headlineSmall, // 24px
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sign in to subscribe to this fridge and receive notifications.',
                  ),
                  const SizedBox(height: 24),
                  SignInWidget(
                    onSignInSuccess: () {
                      // SignInWidget already closes itself, just show the next dialog
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
            LoadingIndicatorM3E(message: getRandomLoadingMessage()),
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
          builder: (context) => NotificationPreferencesDialog.edit(
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

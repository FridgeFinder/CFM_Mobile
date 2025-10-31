import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../map/domain/models/fridge_domain.dart';
import './widgets/status_update_form.dart';
import '../../../core/providers/location_provider.dart';
import '../../../core/utils/distance_calculator.dart' as distance_utils;
import '../../../core/utils/fridge_icon_utils.dart';

/// Bottom sheet modal displaying detailed fridge information
class FridgeProfileSheet extends ConsumerWidget {
  final FridgeDomain fridge;

  const FridgeProfileSheet({super.key, required this.fridge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userLocationAsync = ref.watch(userLocationProvider);

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
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: FridgeIconUtils.getFridgeIcon(
                      fridge: fridge,
                      size: 48,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fridge.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Row(
                          children: [
                            if (fridge.latestFridgeReport != null) ...[
                              Icon(
                                FridgeIconUtils.getStatusIcon(
                                  fridge.latestFridgeReport!.condition,
                                ),
                                size: 14,
                                color: FridgeIconUtils.getStatusColor(
                                  fridge.latestFridgeReport!.condition,
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              fridge.statusText,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                            ),
                            if (distance != null) ...[
                              Text(
                                ' • ',
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
                  if (!fridge.verified)
                    Tooltip(
                      message: 'Not yet verified',
                      child: Icon(
                        Icons.help_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
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
                      fridge.location.fullAddress,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              // Fridge Photo
              if (fridge.photoUrl != null)
                _buildSection(
                  context: context,
                  icon: Icons.image,
                  title: 'Photo',
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        fridge.photoUrl!,
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: FridgeIconUtils.getStatusColor(
                                            fridge
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
                                '${fridge.latestFridgeReport!.foodPercentageInt}%',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
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
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              fridge.latestFridgeReport!.notes!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      if (fridge.latestFridgeReport!.reportDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Last updated: ${_formatDate(fridge.latestFridgeReport!.reportDate!)}',
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
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            fridge.statusText,
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
                            fridge.foodLevelText,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
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
        content: StatusUpdateForm(fridge: fridge),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _share(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share feature coming soon for ${fridge.name}')),
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
}

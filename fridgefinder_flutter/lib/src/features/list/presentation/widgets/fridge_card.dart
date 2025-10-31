import 'package:flutter/material.dart';
import '../../../map/domain/models/fridge_domain.dart';
import '../../../../core/utils/fridge_icon_utils.dart';

/// Card widget for displaying a fridge in the list
/// Uses the same icon system as the map for consistency
class FridgeCard extends StatelessWidget {
  final FridgeDomain fridge;
  final VoidCallback onTap;
  final double? distanceKm;
  static const double iconSize = 48;

  const FridgeCard({
    super.key,
    required this.fridge,
    required this.onTap,
    this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    final report = fridge.latestFridgeReport;
    final statusIcon = report != null
        ? FridgeIconUtils.getStatusIcon(report.condition)
        : Icons.help;
    final statusColor = report != null
        ? FridgeIconUtils.getStatusColor(report.condition)
        : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Icon Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SVG marker icon - same as map
                  SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: FridgeIconUtils.getFridgeIcon(
                      fridge: fridge,
                      size: iconSize,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fridge.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fridge.location.shortAddress,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!fridge.verified)
                    Tooltip(
                      message: 'Not verified',
                      child: Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Status, Food Level, and Distance Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status with icon
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(statusIcon, size: 16, color: statusColor),
                          const SizedBox(width: 6),
                          Text(
                            fridge.statusText,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: statusColor,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Food Level
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Food Level',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        fridge.foodLevelText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Distance
                  if (distanceKm != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Distance',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        Text(
                          '${(distanceKm! * 0.621371 * 10).round() / 10} mi',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

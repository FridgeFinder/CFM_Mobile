import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:design_system/design_system.dart';
import '../../../map/domain/models/fridge_domain.dart';
import '../../../map/presentation/controllers/fridge_list_controller.dart';
import '../../../../core/providers/location_provider.dart';
import '../../../../core/providers/neighborhood_provider.dart';
import '../../../../core/utils/distance_calculator.dart' as distance_utils;
import 'fridge_hero_icon.dart';

/// Header section: hero icon, name, address, neighborhood, distance.
/// Watches `singleFridgeProvider` and `userLocationProvider`.
class FridgeProfileHeader extends ConsumerWidget {
  final FridgeDomain fridge;

  const FridgeProfileHeader({super.key, required this.fridge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for live fridge updates
    final fridgeAsync = ref.watch(singleFridgeProvider(fridge.id));
    final liveFridge = fridgeAsync.whenOrNull(data: (f) => f) ?? fridge;

    // Calculate distance only in this widget
    final userLocationAsync = ref.watch(userLocationProvider);
    double? distance;
    if (userLocationAsync.value != null) {
      final userLocation = userLocationAsync.value!.position;
      final fridgeLocation = LatLng(
        liveFridge.location.geoLat,
        liveFridge.location.geoLng,
      );
      distance = distance_utils.DistanceCalculator.calculateDistanceInKm(
        userLocation,
        fridgeLocation,
      );
    }

    // Neighborhood: reverse-geocoded label with cache, falls back to name/city
    final neighborhoodAsync = ref.watch(fridgeNeighborhoodProvider(liveFridge.id));
    final neighborhood = neighborhoodAsync.whenOrNull(data: (n) => n)
        ?? liveFridge.location.name
        ?? liveFridge.location.city;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FridgeHeroIcon(fridge: liveFridge),
        SizedBox(width: M3ESpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fridge Name
              Text(
                liveFridge.name,
                style: M3ETypography.headlineSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: M3ESpacing.xxs),
              // Address
              Text(
                liveFridge.location.fullAddress,
                style: M3ETypography.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: M3ESpacing.xxs),
              // Neighborhood + Distance row
              Row(
                children: [
                  if (neighborhood.isNotEmpty) ...[
                    Icon(
                      Icons.location_city,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: M3ESpacing.xxs),
                    Flexible(
                      child: Text(
                        neighborhood,
                        style: M3ETypography.labelMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  if (neighborhood.isNotEmpty && distance != null) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: M3ESpacing.xs),
                      child: Text(
                        '•',
                        style: M3ETypography.labelMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                  if (distance != null)
                    Text(
                      '${(distance * distance_utils.DistanceCalculator.kmToMilesConversion * 10).round() / 10} mi',
                      style: M3ETypography.labelMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/neighborhood_service.dart';
import '../../features/map/presentation/controllers/fridge_list_controller.dart';

part 'neighborhood_provider.g.dart';

/// Singleton instance of [NeighborhoodService].
@riverpod
NeighborhoodService neighborhoodService(Ref ref) {
  return NeighborhoodService();
}

/// Resolves a neighborhood label for the given [fridgeId].
///
/// Watches [singleFridgeProvider] for lat/lng, then delegates to
/// [NeighborhoodService] which checks Hive cache → MapTiler API → fallback.
@riverpod
Future<String> fridgeNeighborhood(Ref ref, String fridgeId) async {
  final fridge = await ref.watch(singleFridgeProvider(fridgeId).future);
  final service = ref.watch(neighborhoodServiceProvider);

  return service.getNeighborhood(
    fridgeId: fridge.id,
    lat: fridge.location.geoLat,
    lng: fridge.location.geoLng,
    locationName: fridge.location.name,
    city: fridge.location.city,
  );
}

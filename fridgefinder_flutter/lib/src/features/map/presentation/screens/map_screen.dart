import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import '../../domain/models/fridge_domain.dart';
import '../controllers/fridge_list_controller.dart';
import '../controllers/map_filter_controller.dart';
import '../widgets/fridge_marker.dart';
import '../widgets/fridge_cluster_widget.dart';
import '../widgets/user_location_indicator.dart';
import '../widgets/map_search_panel.dart';
import '../widgets/filter_status_indicator.dart';
import '../widgets/filter_pills_row.dart';
import '../../../profile/presentation/fridge_profile_sheet.dart';
import '../../../../common_widgets/index.dart' as common_widgets;
import '../../../../core/providers/location_provider.dart';
import '../../../../core/providers/map_cache_provider.dart';

/// Map screen showing all community fridges on a map
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  late MapController _mapController;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  bool _isFilterPanelExpanded = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _showFridgeProfile(FridgeDomain fridge) {
    ref.read(selectedFridgeIdProvider.notifier).setSelectedFridgeId(fridge.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FridgeProfileSheet(fridge: fridge),
    );
  }

  void _toggleFilterPanel() {
    setState(() {
      _isFilterPanelExpanded = !_isFilterPanelExpanded;
      if (_isFilterPanelExpanded) {
        // Auto-focus search bar when expanding
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _searchFocusNode.requestFocus();
          }
        });
      } else {
        // Unfocus search bar when collapsing
        _searchFocusNode.unfocus();
      }
    });
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;

    try {
      // Geocode the location query
      final locations = await locationFromAddress(query);

      if (locations.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location not found: $query'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Move map to first result
      final location = locations.first;
      _mapController.move(
        LatLng(location.latitude, location.longitude),
        14.0,
      );

      // Clear the search bar after successfully moving to location
      // This prevents the location query from filtering fridge names
      _searchController.clear();
      ref.read(mapFilterProvider.notifier).clearSearch();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Moved to: $query'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to search location: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fridgesAsync = ref.watch(fridgeListProvider);
    final userLocationAsync = ref.watch(userLocationProvider);
    final userLocationStream = ref.watch(userLocationStreamProvider);
    final locationAccessEnabled = ref.watch(locationAccessProvider);
    final filteredFridges = ref.watch(mapFilteredFridgesProvider);

    return Scaffold(
      body: fridgesAsync.when(
        loading: () => const common_widgets.LoadingIndicator(
          message: 'Loading fridges...',
        ),
        error: (error, stackTrace) => common_widgets.ErrorView(
          message: error.toString(),
          onRetry: () => ref.refresh(fridgeListProvider),
        ),
        data: (fridges) {
          if (fridges.isEmpty) {
            return common_widgets.EmptyStateView(
              title: 'No Fridges Found',
              message: 'There are no community fridges in your area yet.',
              icon: Icons.location_off,
            );
          }

          // Determine initial map center: user location or first fridge
          LatLng initialCenter = LatLng(
            fridges[0].location.geoLat,
            fridges[0].location.geoLng,
          );

          if (userLocationAsync.value != null) {
            initialCenter = userLocationAsync.value!.position;
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: 13.0,
                  maxZoom: 18.0,
                  minZoom: 10.0,
                ),
                children: [
                  // Tile layer with caching
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.fridgefinder',
                    tileProvider: ref.watch(cachedTileProviderProvider),
                  ),
                  // User location marker with pulsating circle
                  userLocationStream.when(
                    data: (userLocation) {
                      if (userLocation != null) {
                        return MarkerLayer(
                          markers: [
                            Marker(
                              point: userLocation.position,
                              child: UserLocationIndicator(),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  // Fridge markers with clustering - use filtered fridges
                  MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      maxClusterRadius: 40,
                      size: const Size(50, 50),
                      markers: filteredFridges
                          .map(
                            (fridge) => Marker(
                              point: LatLng(
                                fridge.location.geoLat,
                                fridge.location.geoLng,
                              ),
                              width: FridgeMarker.markerSize,
                              height: FridgeMarker.markerSize,
                              child: FridgeMarker(fridge: fridge),
                            ),
                          )
                          .toList(),
                      builder: (context, markers) {
                        return FridgeClusterWidget(
                          markerCount: markers.length,
                          isDarkMode:
                              Theme.of(context).brightness == Brightness.dark,
                        );
                      },
                      onMarkerTap: (marker) {
                        // Find the fridge corresponding to this marker
                        final markerPoint = marker.point;
                        final fridge = filteredFridges.firstWhere(
                          (fridge) =>
                              fridge.location.geoLat == markerPoint.latitude &&
                              fridge.location.geoLng == markerPoint.longitude,
                        );
                        _showFridgeProfile(fridge);
                      },
                    ),
                  ),
                ],
              ),
              // Always-visible filter pills at top of map
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const FilterPillsRow(),
                ),
              ),
              // Search panel - overlays above map, below filter pills
              Positioned(
                top: 48, // Below the filter pills row (height 48)
                left: 0,
                right: 0,
                child: MapSearchPanel(
                  searchController: _searchController,
                  searchFocusNode: _searchFocusNode,
                  isExpanded: _isFilterPanelExpanded,
                  onToggleExpanded: _toggleFilterPanel,
                  onLocationSearch: _searchLocation,
                ),
              ),
              // Center to user location button (above search button)
              Positioned(
                bottom: 80,
                right: 16,
                child: FloatingActionButton(
                  foregroundColor: Colors.white,
                  onPressed: () async {
                    // If location access is disabled, request permission first
                    if (!locationAccessEnabled) {
                      final permissionGranted = await ref
                          .read(locationAccessProvider.notifier)
                          .setAccessWithPermission(true);

                      if (!permissionGranted) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Location permission denied. Enable in settings to use this feature.',
                              ),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                        return;
                      }
                      // Permission granted and toggle turned on
                      // Wait for location data to be fetched
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Getting your location...'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }

                      // Give the location provider time to fetch the location
                      // Check periodically for up to 5 seconds
                      int attempts = 0;
                      while (attempts < 10) {
                        await Future.delayed(const Duration(milliseconds: 500));

                        // Re-read the latest location state
                        final updatedLocation = ref
                            .read(userLocationProvider)
                            .whenOrNull(data: (location) => location);

                        if (updatedLocation != null) {
                          if (context.mounted) {
                            _mapController.move(updatedLocation.position, 15.0);
                          }
                          return;
                        }
                        attempts++;
                      }

                      // Location still not available after 5 seconds
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Unable to get location. Please try again.',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                      return;
                    }

                    // Location access already enabled - center map to user location if available
                    if (userLocationAsync.value != null) {
                      _mapController.move(
                        userLocationAsync.value!.position,
                        15.0,
                      );
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Getting your location...'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  child: const Icon(Icons.my_location),
                ),
              ),
              // Filter status indicator at bottom left
              const FilterStatusIndicator(),
              // Search/Filter button in bottom right
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  foregroundColor: Colors.white,
                  onPressed: _toggleFilterPanel,
                  child: AnimatedRotation(
                    turns: _isFilterPanelExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      _isFilterPanelExpanded
                          ? Icons.arrow_upward
                          : Icons.search,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

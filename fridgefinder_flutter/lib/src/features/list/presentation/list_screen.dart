import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:design_system/design_system.dart';
import '../../map/domain/models/fridge_domain.dart';
import '../../map/presentation/controllers/fridge_list_controller.dart';
import '../../map/presentation/controllers/map_filter_controller.dart';
import '../../map/presentation/widgets/filter_pills_row.dart';
import './widgets/fridge_card.dart';
import '../../profile/presentation/fridge_profile_sheet.dart';
import '../../../common_widgets/index.dart' as common_widgets;
import '../../../core/utils/distance_calculator.dart' as distance_utils;
import '../../../core/providers/subscriptions_provider.dart';

/// List screen showing all community fridges in a scrollable list
/// Shares filter state with map view through mapFilterProvider
class ListScreen extends ConsumerStatefulWidget {
  const ListScreen({super.key});

  @override
  ConsumerState<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends ConsumerState<ListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _listAnimationController;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  LatLng? _selectedLocation;
  String? _locationName;
  static const double _locationProximityKm = 1.5; // Show fridges within 1.5km

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

    // Initialize animation controller for list entrance
    _listAnimationController = AnimationController(
      duration: M3EMotion.long2,
      vsync: this,
    );

    // Start animation on mount
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _listAnimationController.dispose();
    super.dispose();
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
            backgroundColor: const Color(
              0xFFFFB300,
            ), // M3E Vibrant AMBER for warning
          ),
        );
        return;
      }

      // Set location filter
      final location = locations.first;
      setState(() {
        _selectedLocation = LatLng(location.latitude, location.longitude);
        _locationName = query;
      });

      // Clear the search bar after successfully finding location
      _searchController.clear();
      ref.read(mapFilterProvider.notifier).clearSearch();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Showing fridges near: $query'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to search location: ${e.toString()}'),
          backgroundColor: const Color(
            0xFFFF7043,
          ), // M3E Vibrant CORAL for error
        ),
      );
    }
  }

  void _clearLocation() {
    setState(() {
      _selectedLocation = null;
      _locationName = null;
    });
  }

  void _showFridgeProfile(
    BuildContext context,
    WidgetRef ref,
    FridgeDomain fridge,
  ) {
    ref.read(selectedFridgeIdProvider.notifier).setSelectedFridgeId(fridge.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FridgeProfileSheet(fridge: fridge),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch shared filter state (same as map view)
    final filterStateAsync = ref.watch(mapFilterProvider);
    // Use select() to watch only fridges with distance data, avoiding unnecessary rebuilds
    final fridgesWithDistance = ref.watch(
      fridgesSortedByDistanceProvider.select((fridges) => fridges),
    );
    // Also watch the original fridges to check for loading/error states
    final fridgesAsync = ref.watch(fridgeListProvider);
    // Watch subscriptions for green glow
    final subscriptionsAsync = ref.watch(subscribedFridgesProvider);

    return GestureDetector(
      onTap: () {
        // Unfocus any focused widget when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: fridgesAsync.when(
          loading: () => const common_widgets.LoadingIndicator(),
          error: (error, stackTrace) => common_widgets.ErrorView(
            message: error.toString(),
            onRetry: () => ref.refresh(fridgeListProvider),
          ),
          data: (_) {
            return filterStateAsync.when(
              data: (filterState) {
                if (_searchController.text != filterState.searchQuery) {
                  _searchController.value = TextEditingValue(
                    text: filterState.searchQuery,
                    selection: TextSelection.collapsed(
                      offset: filterState.searchQuery.length,
                    ),
                  );
                }

                // Compute subscribedFridgeIds ONCE at the beginning to use for both filtering and green glow
                final subscribedFridgeIds = subscriptionsAsync.when(
                  data: (subs) => subs.map((s) => s.fridgeId).toSet(),
                  loading: () => <String>{},
                  error: (_, _) => <String>{},
                );

                // Apply filter conditions first, then subscribed filter, then location proximity, then fuzzy search
                // If no conditions selected, show all fridges (same as map view)
                var filtered = filterState.selectedConditions.isEmpty
                    ? fridgesWithDistance
                    : fridgesWithDistance.where((fridgeWithDistance) {
                        return filterState.selectedConditions.any((
                          filterCondition,
                        ) {
                          return filterCondition.matches(
                            fridgeWithDistance.fridge,
                          );
                        });
                      }).toList();

                // Apply subscribed filter if active
                if (filterState.subscribedOnly) {
                  filtered = filtered.where((fridgeWithDistance) {
                    return subscribedFridgeIds.contains(
                      fridgeWithDistance.fridge.id,
                    );
                  }).toList();
                }

                // Apply location proximity filter if location is selected
                if (_selectedLocation != null) {
                  filtered = filtered.where((fridgeWithDistance) {
                    final fridge = fridgeWithDistance.fridge;
                    final fridgeLocation = LatLng(
                      fridge.location.geoLat,
                      fridge.location.geoLng,
                    );
                    final distance =
                        distance_utils.DistanceCalculator.calculateDistanceInKm(
                          _selectedLocation!,
                          fridgeLocation,
                        );
                    return distance <= _locationProximityKm;
                  }).toList();
                }

                // Apply fuzzy search if query is not empty (and no location selected)
                // Don't fuzzy search when location is active
                if (filterState.searchQuery.isNotEmpty &&
                    _selectedLocation == null) {
                  final searchQuery = filterState.searchQuery.toLowerCase();
                  filtered = filtered.where((fridgeWithDistance) {
                    final fridge = fridgeWithDistance.fridge;
                    return fridge.name.toLowerCase().contains(searchQuery) ||
                        fridge.location.city.toLowerCase().contains(
                          searchQuery,
                        ) ||
                        fridge.location.state.toLowerCase().contains(
                          searchQuery,
                        );
                  }).toList();
                }

                return Column(
                  children: [
                    // Filter Pills - shared with map view
                    const FilterPillsRow(),

                    // Search Bar with M3E styling
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: M3ESpacing.md,
                        vertical: M3ESpacing.xs,
                      ),
                      child: SearchBarM3E(
                        controller: _searchController,
                        hintText: 'Search by name or location...',
                        leadingIcon: Icons.search,
                        expandedByDefault: true,
                        onChanged: (query) {
                          ref
                              .read(mapFilterProvider.notifier)
                              .setSearchQuery(query);
                        },
                        onSubmitted: _searchLocation,
                      ),
                    ),

                    // Location pill (shown when location is selected)
                    if (_locationName != null)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          M3ESpacing.sm,
                          0,
                          M3ESpacing.sm,
                          M3ESpacing.sm,
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: M3ESpacing.sm,
                            vertical: M3ESpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue, width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 18,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Near: $_locationName',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.blue,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: _clearLocation,
                              ),
                            ],
                          ),
                        ),
                      ),

                    // List of Fridges
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: common_widgets.EmptyStateView(
                                title:
                                    filterState.searchQuery.isEmpty &&
                                        filterState.selectedConditions.isEmpty
                                    ? 'No Fridges Found'
                                    : 'No results',
                                message:
                                    filterState.searchQuery.isEmpty &&
                                        filterState.selectedConditions.isEmpty
                                    ? 'There are no community fridges in your area yet.'
                                    : 'No fridges match your filters.',
                                icon: Icons.search_off,
                                action:
                                    filterState.searchQuery.isNotEmpty ||
                                        filterState
                                            .selectedConditions
                                            .isNotEmpty
                                    ? ElevatedButton(
                                        onPressed: () {
                                          _searchController.clear();
                                          final notifier = ref.read(
                                            mapFilterProvider.notifier,
                                          );
                                          notifier.clearSearch();
                                          notifier.deselectAllConditions();
                                        },
                                        child: const Text('Clear Filters'),
                                      )
                                    : null,
                              ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.symmetric(
                                horizontal: M3ESpacing.md,
                              ),
                              separatorBuilder: (context, index) =>
                                  M3ESpacing.verticalSM,
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final fridgeWithDistance = filtered[index];
                                // Wrap each card with staggered entrance animation
                                return M3ETransitions.listItemEntrance(
                                  animation: _listAnimationController,
                                  index: index,
                                  totalItems: filtered.length.clamp(
                                    0,
                                    10,
                                  ), // Limit stagger to first 10
                                  child: FridgeCard(
                                    fridge: fridgeWithDistance.fridge,
                                    distanceKm: fridgeWithDistance.distanceKm,
                                    isSubscribed: subscribedFridgeIds.contains(
                                      fridgeWithDistance.fridge.id,
                                    ),
                                    onTap: () => _showFridgeProfile(
                                      context,
                                      ref,
                                      fridgeWithDistance.fridge,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}

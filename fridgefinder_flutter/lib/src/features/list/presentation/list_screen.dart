import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import '../../map/domain/models/fridge_domain.dart';
import '../../map/presentation/controllers/fridge_list_controller.dart';
import '../../map/presentation/controllers/map_filter_controller.dart';
import '../../map/presentation/widgets/filter_pills_row.dart';
import './widgets/fridge_card.dart';
import '../../profile/presentation/fridge_profile_sheet.dart';
import '../../../common_widgets/index.dart' as common_widgets;
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

  @override
  void initState() {
    super.initState();
    // Initialize search controller from shared filter state so it has the
    // correct text immediately (e.g. when navigating from map with active search)
    final initialQuery = ref.read(mapFilterProvider).whenOrNull(data: (s) => s.searchQuery) ?? '';
    _searchController = TextEditingController(text: initialQuery);
    _searchFocusNode = FocusNode();

    // Initialize animation controller for list entrance
    _listAnimationController = AnimationController(
      duration: M3EMotion.long2,
      vsync: this,
    );

    // Delay animation start until after first frame renders (so it's more noticeable)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Add a small extra delay so the animation is visible
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            _listAnimationController.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _listAnimationController.dispose();
    super.dispose();
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

  Future<void> _handlePullToRefresh() async {
    ref.invalidate(fridgeListProvider);
    ref.invalidate(subscribedFridgesProvider);

    await Future.wait([
      ref.read(fridgeListProvider.future),
      ref.read(subscribedFridgesProvider.future),
    ]);
  }

  Widget _buildRefreshableEmptyState({
    required BuildContext context,
    required Widget child,
  }) {
    return RefreshIndicator(
      onRefresh: _handlePullToRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: Center(child: child),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch shared filter state (same as map view)
    final filterStateAsync = ref.watch(mapFilterProvider);

    // Sync search controller with shared filter state via ref.listen (side-effect).
    // Fires when provider changes from other pages (e.g. map search).
    ref.listen(mapFilterProvider, (prev, next) {
      final query = next.whenOrNull(data: (s) => s.searchQuery) ?? '';
      if (_searchController.text != query) {
        _searchController.value = TextEditingValue(
          text: query,
          selection: TextSelection.collapsed(offset: query.length),
        );
      }
    });
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

                // Compute subscribedFridgeIds ONCE at the beginning to use for both filtering and green glow
                final subscribedFridgeIds = subscriptionsAsync.when(
                  data: (subs) => subs.map((s) => s.fridgeId).toSet(),
                  loading: () => <String>{},
                  error: (_, _) => <String>{},
                );

                // Filter out ghosts unless explicitly included (same as map view)
                final baseList = filterState.includeGhosts
                    ? fridgesWithDistance
                    : fridgesWithDistance.where((fw) => fw.fridge.latestFridgeReport?.condition != FridgeCondition.ghost).toList();

                // Apply filter conditions first, then subscribed filter, then search
                // If no conditions selected, show all fridges (same as map view)
                var filtered = filterState.selectedConditions.isEmpty
                    ? baseList
                    : baseList.where((fridgeWithDistance) {
                        return filterState.selectedConditions.any((
                          filterCondition,
                        ) {
                          return filterCondition.matches(
                            fridgeWithDistance.fridge,
                          );
                        });
                      }).toList();

                // Apply subscribed filter if active
                if (filterState.followingOnly) {
                  filtered = filtered.where((fridgeWithDistance) {
                    return subscribedFridgeIds.contains(
                      fridgeWithDistance.fridge.id,
                    );
                  }).toList();
                }

                // Apply search filter
                if (filterState.searchQuery.isNotEmpty) {
                  final searchQuery = filterState.searchQuery.toLowerCase();
                  filtered = filtered.where((fridgeWithDistance) {
                    final fridge = fridgeWithDistance.fridge;
                    return fridge.name.toLowerCase().contains(searchQuery) ||
                        fridge.location.street.toLowerCase().contains(
                          searchQuery,
                        ) ||
                        fridge.location.city.toLowerCase().contains(
                          searchQuery,
                        ) ||
                        fridge.location.state.toLowerCase().contains(
                          searchQuery,
                        ) ||
                        fridge.location.zip.toLowerCase().contains(
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
                        hintText: 'Search by name, address, or zip...',
                        leadingIcon: Icons.search,
                        expandedByDefault: true,
                        onChanged: (query) {
                          ref
                              .read(mapFilterProvider.notifier)
                              .setSearchQuery(query);
                        },
                        onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      ),
                    ),

                    // List of Fridges
                    Expanded(
                      child: filtered.isEmpty
                          ? _buildRefreshableEmptyState(
                              context: context,
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
                          : RefreshIndicator(
                              onRefresh: _handlePullToRefresh,
                              child: ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../map/domain/models/fridge_domain.dart';
import '../../map/presentation/controllers/fridge_list_controller.dart';
import '../../map/presentation/controllers/map_filter_controller.dart';
import '../../map/presentation/widgets/filter_pills_row.dart';
import './widgets/fridge_card.dart';
import '../../profile/presentation/fridge_profile_sheet.dart';
import '../../../common_widgets/index.dart' as common_widgets;

/// List screen showing all community fridges in a scrollable list
/// Shares filter state with map view through mapFilterProvider
class ListScreen extends ConsumerStatefulWidget {
  const ListScreen({super.key});

  @override
  ConsumerState<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends ConsumerState<ListScreen> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
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

    return Scaffold(
      body: fridgesAsync.when(
        loading: () => const common_widgets.LoadingIndicator(
          message: 'Loading fridges...',
        ),
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

              // Apply filter conditions first, then fuzzy search
              var filtered = fridgesWithDistance.where((fridgeWithDistance) {
                return filterState.selectedConditions.any((filterCondition) {
                  return filterCondition.matches(fridgeWithDistance.fridge);
                });
              }).toList();

              // Apply fuzzy search if query is not empty
              if (filterState.searchQuery.isNotEmpty) {
                final searchQuery = filterState.searchQuery.toLowerCase();
                filtered = filtered.where((fridgeWithDistance) {
                  final fridge = fridgeWithDistance.fridge;
                  return fridge.name.toLowerCase().contains(searchQuery) ||
                      fridge.location.city.toLowerCase().contains(
                        searchQuery,
                      ) ||
                      fridge.location.state.toLowerCase().contains(searchQuery);
                }).toList();
              }

              return Column(
                children: [
                  // Filter Pills - shared with map view
                  const FilterPillsRow(),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Search by name or location...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: filterState.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _searchController.clear();
                                  ref
                                      .read(mapFilterProvider.notifier)
                                      .clearSearch();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (query) {
                        ref
                            .read(mapFilterProvider.notifier)
                            .setSearchQuery(query);
                      },
                    ),
                  ),

                  // List of Fridges
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: common_widgets.EmptyStateView(
                              title:
                                  filterState.searchQuery.isEmpty &&
                                      filterState.selectedConditions.length == 6
                                  ? 'No Fridges Found'
                                  : 'No results',
                              message:
                                  filterState.searchQuery.isEmpty &&
                                      filterState.selectedConditions.length == 6
                                  ? 'There are no community fridges in your area yet.'
                                  : 'No fridges match your filters.',
                              icon: Icons.search_off,
                              action:
                                  filterState.searchQuery.isNotEmpty ||
                                      filterState.selectedConditions.length < 6
                                  ? ElevatedButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        final notifier = ref.read(
                                          mapFilterProvider.notifier,
                                        );
                                        notifier.clearSearch();
                                        notifier.selectAllConditions();
                                      },
                                      child: const Text('Clear Filters'),
                                    )
                                  : null,
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final fridgeWithDistance = filtered[index];
                              return FridgeCard(
                                fridge: fridgeWithDistance.fridge,
                                distanceKm: fridgeWithDistance.distanceKm,
                                onTap: () => _showFridgeProfile(
                                  context,
                                  ref,
                                  fridgeWithDistance.fridge,
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
    );
  }
}

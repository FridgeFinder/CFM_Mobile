import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/filter_condition.dart';
import '../controllers/map_filter_controller.dart';
import '../../../../core/providers/theme_provider.dart';
import 'filter_pill_button.dart';

/// Filter panel widget for map view
/// Displays horizontally-scrollable filter pills and search bar
class MapFilterPanel extends ConsumerWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  const MapFilterPanel({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.isExpanded,
    required this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(mapFilterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Determine if dark mode
    final isDarkMode =
        themeMode == AppThemeMode.dark ||
        (themeMode == AppThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return filterState.when(
      data: (state) {
        // Sync search controller with filter state when it changes
        if (searchController.text != state.searchQuery) {
          searchController.text = state.searchQuery;
        }

        final bgColor = isDarkMode ? Colors.grey[900] : Colors.white;
        final textColor = isDarkMode ? Colors.white : Colors.black87;
        final borderColor = isDarkMode ? Colors.grey[700] : Colors.grey[300];

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          // Compact height: pills + search bar
          height: isExpanded ? 110 : 0,
          child: isExpanded
              ? ClipRect(
                  child: Container(
                    color: bgColor,
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child: Column(
                      children: [
                        // Filter pills row - compact
                        SizedBox(
                          height: 36,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                ...FilterCondition.values.map(
                                  (condition) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    child: FilterPillButton(
                                      condition: condition,
                                      isSelected: state.selectedConditions
                                          .contains(condition),
                                      onPressed: () {
                                        ref
                                            .read(mapFilterProvider.notifier)
                                            .toggleCondition(condition);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Search bar - compact
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            focusNode: searchFocusNode,
                            style: TextStyle(color: textColor, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search fridges...',
                              hintStyle: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                size: 20,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                              suffixIcon: state.searchQuery.isNotEmpty
                                  ? IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(
                                        Icons.close,
                                        size: 18,
                                        color: isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                      onPressed: () {
                                        searchController.clear();
                                        ref
                                            .read(mapFilterProvider.notifier)
                                            .clearSearch();
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(color: borderColor!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              isDense: true,
                            ),
                            onChanged: (query) {
                              ref
                                  .read(mapFilterProvider.notifier)
                                  .setSearchQuery(query);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

import 'package:flutter/material.dart';
import 'search_bar_m3e.dart';

/// Example usage of SearchBarM3E components
///
/// This file demonstrates all the features and variants of the M3E Search Bar.
/// Use this as a reference for implementing search in your application.
class SearchBarM3EExamples extends StatefulWidget {
  const SearchBarM3EExamples({super.key});

  @override
  State<SearchBarM3EExamples> createState() => _SearchBarM3EExamplesState();
}

class _SearchBarM3EExamplesState extends State<SearchBarM3EExamples> {
  final _controller1 = TextEditingController();
  final _controller2 = TextEditingController();
  final _controller3 = TextEditingController();

  String _lastSearch = '';

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SearchBarM3E Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Example 1: Basic Search Bar
          _buildExampleSection(
            title: '1. Basic Search Bar',
            description: 'A simple search bar with default settings',
            child: SearchBarM3E(
              controller: _controller1,
              hintText: 'Search for fridges...',
              onChanged: (value) {
                debugPrint('Search changed: $value');
              },
              onSubmitted: (value) {
                setState(() {
                  _lastSearch = value;
                });
                debugPrint('Search submitted: $value');
              },
            ),
          ),

          const SizedBox(height: 24),

          // Example 2: Auto-focus Search Bar
          _buildExampleSection(
            title: '2. Auto-focus Search Bar',
            description: 'Automatically focuses and expands on mount',
            child: SearchBarM3E(
              controller: _controller2,
              hintText: 'Search automatically focused...',
              autoFocus: true,
              onChanged: (value) {
                debugPrint('Auto-focus search: $value');
              },
            ),
          ),

          const SizedBox(height: 24),

          // Example 3: Search Bar with Voice Search
          _buildExampleSection(
            title: '3. Search Bar with Voice Search',
            description: 'Includes a voice search button',
            child: SearchBarM3E(
              hintText: 'Try voice search...',
              showVoiceSearch: true,
              onVoiceSearch: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Voice search activated!')),
                );
              },
              onSubmitted: (value) {
                debugPrint('Voice-enabled search: $value');
              },
            ),
          ),

          const SizedBox(height: 24),

          // Example 4: Search Bar with Custom Leading Icon
          _buildExampleSection(
            title: '4. Custom Leading Icon',
            description: 'Uses a different icon instead of search',
            child: SearchBarM3E(
              hintText: 'Search locations...',
              leadingIcon: Icons.location_on,
              onSubmitted: (value) {
                debugPrint('Location search: $value');
              },
            ),
          ),

          const SizedBox(height: 24),

          // Example 5: Search Bar with Custom Trailing Widget
          _buildExampleSection(
            title: '5. Custom Trailing Widget',
            description: 'Uses a custom widget in the trailing position',
            child: SearchBarM3E(
              hintText: 'Search with filter...',
              trailing: IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filter button pressed')),
                  );
                },
              ),
              onSubmitted: (value) {
                debugPrint('Filtered search: $value');
              },
            ),
          ),

          const SizedBox(height: 24),

          // Example 6: Expanded by Default
          _buildExampleSection(
            title: '6. Expanded by Default',
            description: 'Starts in expanded state without focus',
            child: SearchBarM3E(
              hintText: 'Already expanded...',
              expandedByDefault: true,
              onSubmitted: (value) {
                debugPrint('Expanded search: $value');
              },
            ),
          ),

          const SizedBox(height: 24),

          // Example 7: Compact Search Bar
          _buildExampleSection(
            title: '7. Compact Search Bar',
            description: 'Smaller variant (48dp height) for constrained spaces',
            child: CompactSearchBarM3E(
              controller: _controller3,
              hintText: 'Compact search...',
              onSubmitted: (value) {
                debugPrint('Compact search: $value');
              },
            ),
          ),

          const SizedBox(height: 24),

          // Example 8: Search Bar with Suggestions
          _buildExampleSection(
            title: '8. Search Bar with Suggestions',
            description: 'Displays suggestions as user types',
            child: SearchBarWithSuggestionsM3E(
              hintText: 'Search community fridges...',
              suggestions: [
                'Community Fridge A - Downtown',
                'Community Fridge B - Midtown',
                'Community Fridge C - Uptown',
                'Food Pantry Central',
                'Free Food Fridge North',
                'Neighborhood Food Share',
              ],
              onSuggestionSelected: (suggestion) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selected: $suggestion')),
                );
              },
              onSubmitted: (value) {
                debugPrint('Suggestion search: $value');
              },
            ),
          ),

          const SizedBox(height: 24),

          // Example 9: Search Bar with Custom Suggestion Builder
          _buildExampleSection(
            title: '9. Custom Suggestion Builder',
            description: 'Uses custom widgets for suggestions',
            child: SearchBarWithSuggestionsM3E(
              hintText: 'Search with custom suggestions...',
              suggestions: [
                'Apple',
                'Banana',
                'Cherry',
                'Date',
                'Elderberry',
              ],
              suggestionBuilder: (context, suggestion) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(suggestion[0]),
                  ),
                  title: Text(suggestion),
                  subtitle: Text('Tap to select $suggestion'),
                  trailing: const Icon(Icons.arrow_forward),
                  dense: true,
                );
              },
              onSuggestionSelected: (suggestion) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selected: $suggestion')),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Example 10: Disabled Search Bar
          _buildExampleSection(
            title: '10. Disabled Search Bar',
            description: 'Shows disabled state styling',
            child: const SearchBarM3E(
              hintText: 'Disabled search...',
              enabled: false,
            ),
          ),

          const SizedBox(height: 24),

          // Search Results Display
          if (_lastSearch.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Last Search Result:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastSearch,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExampleSection({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

/// Standalone example page demonstrating SearchBarM3E in a real scenario
class SearchPageExample extends StatefulWidget {
  const SearchPageExample({super.key});

  @override
  State<SearchPageExample> createState() => _SearchPageExampleState();
}

class _SearchPageExampleState extends State<SearchPageExample> {
  final _searchController = TextEditingController();
  List<String> _searchResults = [];
  bool _isSearching = false;

  final List<String> _allFridges = [
    'Community Fridge - Downtown Location',
    'Community Fridge - Midtown Center',
    'Community Fridge - Uptown Square',
    'Food Pantry - Central District',
    'Free Food Fridge - North End',
    'Neighborhood Food Share - East Side',
    'Public Fridge - West Village',
    'Sharing Fridge - South Park',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchResults = _allFridges
              .where((fridge) =>
                  fridge.toLowerCase().contains(query.toLowerCase()))
              .toList();
          _isSearching = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Fridges'),
      ),
      body: Column(
        children: [
          // Search Bar at the top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBarM3E(
              controller: _searchController,
              hintText: 'Search for community fridges...',
              autoFocus: true,
              showVoiceSearch: true,
              onVoiceSearch: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Voice search activated!')),
                );
              },
              onChanged: _performSearch,
              onSubmitted: _performSearch,
            ),
          ),

          // Search Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'Start typing to search...'
                              : 'No results found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final fridge = _searchResults[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              leading: const Icon(Icons.kitchen),
                              title: Text(fridge),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Selected: $fridge'),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

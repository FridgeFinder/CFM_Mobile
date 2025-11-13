import 'package:flutter/material.dart';
import 'navigation_drawer_m3e.dart';

/// Example implementation of NavigationDrawerM3E
///
/// This file demonstrates various usage patterns for the NavigationDrawerM3E
/// component including:
/// - Standard drawer with destinations
/// - Modal drawer variant
/// - Drawer with header and footer
/// - Section headers and dividers
/// - Badge indicators
/// - Disabled destinations
///
/// Run this example to see the navigation drawer in action.

class NavigationDrawerM3EExampleScreen extends StatefulWidget {
  const NavigationDrawerM3EExampleScreen({super.key});

  @override
  State<NavigationDrawerM3EExampleScreen> createState() =>
      _NavigationDrawerM3EExampleScreenState();
}

class _NavigationDrawerM3EExampleScreenState
    extends State<NavigationDrawerM3EExampleScreen> {
  int _selectedIndex = 0;
  int _modalSelectedIndex = 0;

  // Example destinations for the standard drawer
  final List<NavigationDrawerDestinationM3E> _standardDestinations = const [
    NavigationDrawerDestinationM3E(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: Text('Home'),
    ),
    NavigationDrawerDestinationM3E(
      icon: Icon(Icons.explore_outlined),
      selectedIcon: Icon(Icons.explore),
      label: Text('Explore'),
    ),
    NavigationDrawerDestinationM3E(
      icon: Icon(Icons.notifications_outlined),
      selectedIcon: Icon(Icons.notifications),
      label: Text('Notifications'),
      badge: Badge(
        label: Text('3'),
      ),
    ),
    NavigationDrawerDestinationM3E(
      icon: Icon(Icons.message_outlined),
      selectedIcon: Icon(Icons.message),
      label: Text('Messages'),
      badge: Badge(
        smallSize: 8,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NavigationDrawerM3E Examples'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: 'Open drawer',
          ),
        ),
      ),
      drawer: _buildStandardDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildStandardDrawer() {
    return NavigationDrawerM3E(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedIndex = index);
        Navigator.pop(context); // Close drawer after selection
      },
      destinations: _standardDestinations,
      header: _buildDrawerHeader(),
      footer: _buildDrawerFooter(),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              Icons.person,
              size: 32,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'John Doe',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
          Text(
            'john.doe@example.com',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerFooter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: const Text('Settings'),
          onTap: () {
            Navigator.pop(context);
            // Navigate to settings
          },
        ),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('Help & Feedback'),
          onTap: () {
            Navigator.pop(context);
            // Navigate to help
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Selected: ${_getSelectedDestinationName()}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _showModalDrawerExample,
            icon: const Icon(Icons.menu),
            label: const Text('Show Modal Drawer'),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _showComplexDrawerExample,
            icon: const Icon(Icons.menu_book),
            label: const Text('Show Complex Drawer'),
          ),
        ],
      ),
    );
  }

  String _getSelectedDestinationName() {
    if (_selectedIndex < _standardDestinations.length) {
      final destination = _standardDestinations[_selectedIndex];
      if (destination.label is Text) {
        return (destination.label as Text).data ?? 'Unknown';
      }
    }
    return 'Unknown';
  }

  void _showModalDrawerExample() {
    showModalNavigationDrawer(
      context: context,
      builder: (context) => NavigationDrawerM3E(
        selectedIndex: _modalSelectedIndex,
        onDestinationSelected: (index) {
          setState(() => _modalSelectedIndex = index);
          Navigator.pop(context);
        },
        destinations: const [
          NavigationDrawerDestinationM3E(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: Text('Dashboard'),
          ),
          NavigationDrawerDestinationM3E(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: Text('Analytics'),
          ),
          NavigationDrawerDestinationM3E(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: Text('Users'),
          ),
          NavigationDrawerDestinationM3E(
            icon: Icon(Icons.inventory_outlined),
            selectedIcon: Icon(Icons.inventory),
            label: Text('Products'),
          ),
        ],
        header: Container(
          height: 120,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Center(
            child: Text(
              'Modal Drawer',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
      ),
    );
  }

  void _showComplexDrawerExample() {
    showModalNavigationDrawer(
      context: context,
      builder: (context) => _ComplexDrawerExample(),
    );
  }
}

/// Example of a complex drawer with sections, dividers, and disabled items
class _ComplexDrawerExample extends StatefulWidget {
  @override
  State<_ComplexDrawerExample> createState() => _ComplexDrawerExampleState();
}

class _ComplexDrawerExampleState extends State<_ComplexDrawerExample> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationDrawerM3E(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
      destinations: [
        // Main Section
        const NavigationDrawerDestinationM3E(
          icon: Icon(Icons.inbox_outlined),
          selectedIcon: Icon(Icons.inbox),
          label: Text('Inbox'),
          badge: Badge(
            label: Text('24'),
          ),
        ),
        const NavigationDrawerDestinationM3E(
          icon: Icon(Icons.star_outline),
          selectedIcon: Icon(Icons.star),
          label: Text('Starred'),
        ),
        const NavigationDrawerDestinationM3E(
          icon: Icon(Icons.send_outlined),
          selectedIcon: Icon(Icons.send),
          label: Text('Sent'),
        ),
        const NavigationDrawerDestinationM3E(
          icon: Icon(Icons.drafts_outlined),
          selectedIcon: Icon(Icons.drafts),
          label: Text('Drafts'),
          badge: Badge(
            label: Text('5'),
          ),
        ),

        // Folders Section (wrapped to display as a destination but act as divider)
        const NavigationDrawerDestinationM3E(
          icon: Icon(Icons.folder_outlined),
          selectedIcon: Icon(Icons.folder),
          label: Text('Work'),
        ),
        const NavigationDrawerDestinationM3E(
          icon: Icon(Icons.folder_outlined),
          selectedIcon: Icon(Icons.folder),
          label: Text('Personal'),
        ),
        const NavigationDrawerDestinationM3E(
          icon: Icon(Icons.folder_outlined),
          selectedIcon: Icon(Icons.folder),
          label: Text('Archive'),
        ),

        // Disabled example (if you want to show but not allow selection)
        const NavigationDrawerDestinationM3E(
          icon: Icon(Icons.delete_outlined),
          selectedIcon: Icon(Icons.delete),
          label: Text('Trash'),
          enabled: false,
        ),
      ],
      header: Container(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(
              Icons.mail,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Text(
              'Mail',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Create new folder'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Standalone example demonstrating section headers and dividers
class NavigationDrawerWithSectionsExample extends StatefulWidget {
  const NavigationDrawerWithSectionsExample({super.key});

  @override
  State<NavigationDrawerWithSectionsExample> createState() =>
      _NavigationDrawerWithSectionsExampleState();
}

class _NavigationDrawerWithSectionsExampleState
    extends State<NavigationDrawerWithSectionsExample> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawer with Sections'),
      ),
      drawer: Drawer(
        width: 360,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
            Container(
              height: 120,
              color: Theme.of(context).colorScheme.primaryContainer,
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomLeft,
              child: Text(
                'My App',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
            ),

            // Main section
            const NavigationDrawerSectionHeaderM3E(label: 'MAIN'),
            _buildDrawerItem(0, Icons.home_outlined, Icons.home, 'Home'),
            _buildDrawerItem(1, Icons.search, Icons.search, 'Search'),
            _buildDrawerItem(
                2, Icons.library_music_outlined, Icons.library_music, 'Library'),

            // Divider
            const NavigationDrawerDividerM3E(),

            // Playlists section
            const NavigationDrawerSectionHeaderM3E(label: 'PLAYLISTS'),
            _buildDrawerItem(
                3, Icons.favorite_outline, Icons.favorite, 'Liked Songs'),
            _buildDrawerItem(4, Icons.album_outlined, Icons.album, 'Albums'),
            _buildDrawerItem(5, Icons.person_outline, Icons.person, 'Artists'),

            // Divider
            const NavigationDrawerDividerM3E(),

            // Settings section
            const NavigationDrawerSectionHeaderM3E(label: 'MORE'),
            _buildDrawerItem(
                6, Icons.settings_outlined, Icons.settings, 'Settings'),
            _buildDrawerItem(7, Icons.help_outline, Icons.help, 'Help'),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Selected index: $_selectedIndex',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    int index,
    IconData icon,
    IconData selectedIcon,
    String label,
  ) {
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected
            ? Theme.of(context).colorScheme.secondaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: () {
            setState(() => _selectedIndex = index);
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(28),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onSecondaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Minimal example for quick reference
void showMinimalDrawerExample(BuildContext context) {
  showModalNavigationDrawer(
    context: context,
    builder: (context) => NavigationDrawerM3E(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        // Handle navigation
        Navigator.pop(context);
      },
      destinations: const [
        NavigationDrawerDestinationM3E(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationDrawerDestinationM3E(
          icon: Icon(Icons.search),
          label: Text('Search'),
        ),
        NavigationDrawerDestinationM3E(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
      ],
    ),
  );
}

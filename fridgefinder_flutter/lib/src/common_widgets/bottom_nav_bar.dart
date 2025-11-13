import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:design_system/design_system.dart';

/// Bottom navigation bar for main navigation using M3E components
class AppBottomNavBar extends ConsumerWidget {
  final String currentRoute;

  const AppBottomNavBar({super.key, required this.currentRoute});

  void _navigate(BuildContext context, String route) {
    if (currentRoute != route) {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NavigationBarEnhancedM3E(
      selectedIndex: _getIndexForRoute(currentRoute),
      onDestinationSelected: (index) {
        final routes = ['/', '/list', '/my-fridges', '/profile'];
        _navigate(context, routes[index]);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map),
          label: 'Map',
          tooltip: 'View fridges on map',
        ),
        NavigationDestination(
          icon: Icon(Icons.list_outlined),
          selectedIcon: Icon(Icons.list),
          label: 'List',
          tooltip: 'Browse fridge list',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_outline),
          selectedIcon: Icon(Icons.favorite),
          label: 'My Fridges',
          tooltip: 'Your subscribed fridges',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
          tooltip: 'Settings and profile',
        ),
      ],
    );
  }

  int _getIndexForRoute(String route) {
    switch (route) {
      case '/':
        return 0;
      case '/list':
        return 1;
      case '/my-fridges':
        return 2;
      case '/profile':
        return 3;
      default:
        return 0;
    }
  }
}

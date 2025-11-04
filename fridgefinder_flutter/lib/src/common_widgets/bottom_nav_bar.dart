import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation bar for main navigation
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
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.map, color: onSurfaceVariant),
          activeIcon: Icon(Icons.map, color: primaryColor, size: 28),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list, color: onSurfaceVariant),
          activeIcon: Icon(Icons.list, color: primaryColor, size: 28),
          label: 'List',
        ),
        // TODO: Re-enable Favorites nav item in v1.1 after implementing user accounts
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.favorite, color: onSurfaceVariant),
        //   activeIcon: Icon(Icons.favorite, color: primaryColor, size: 28),
        //   label: 'Favorites',
        // ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: onSurfaceVariant),
          activeIcon: Icon(Icons.person, color: primaryColor, size: 28),
          label: 'Profile',
        ),
      ],
      currentIndex: _getIndexForRoute(currentRoute),
      type: BottomNavigationBarType.fixed,
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: onSurfaceVariant,
      elevation: 8.0,
      enableFeedback: true,
      onTap: (index) {
        // Updated routes array - removed '/favorites'
        final routes = ['/', '/list', '/profile'];
        _navigate(context, routes[index]);
      },
    );
  }

  int _getIndexForRoute(String route) {
    switch (route) {
      case '/':
        return 0;
      case '/list':
        return 1;
      // Removed '/favorites' route - will be added in v1.1
      case '/profile':
        return 2;
      default:
        return 0;
    }
  }
}

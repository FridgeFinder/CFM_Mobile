import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/map/presentation/screens/map_screen.dart';
import '../features/list/presentation/list_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../common_widgets/main_shell.dart';

// Placeholder screens for unimplemented features
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text('Favorites Screen - Coming Soon')),
    );
  }
}

/// Custom page transition that prevents default transition and lets MainShell handle it
CustomTransitionPage<void> _buildPageWithTransition(
  String route,
  Widget child,
) {
  return CustomTransitionPage<void>(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Don't animate here - MainShell handles all animations
      // Just return the child to prevent default fade transition
      return child;
    },
    transitionDuration: Duration.zero,
  );
}

// Router configuration
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(currentRoute: state.matchedLocation, child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                _buildPageWithTransition('/', const MapScreen()),
          ),
          GoRoute(
            path: '/list',
            pageBuilder: (context, state) =>
                _buildPageWithTransition('/list', const ListScreen()),
          ),
          GoRoute(
            path: '/favorites',
            pageBuilder: (context, state) =>
                _buildPageWithTransition('/favorites', const FavoritesScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                _buildPageWithTransition('/profile', const ProfileScreen()),
          ),
        ],
      ),
    ],
  );
});

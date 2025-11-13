import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import '../features/map/presentation/screens/map_screen.dart';
import '../features/list/presentation/list_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/auth/presentation/screens/my_fridges_screen.dart';
import '../common_widgets/main_shell.dart';
import '../common_widgets/loading_messages.dart';

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
    redirect: (context, state) {
      // Handle Firebase Auth deep links - redirect to home
      final uri = state.uri;
      if (uri.toString().contains('firebaseauth') || 
          uri.toString().contains('fridgefinder-app.firebaseapp.com')) {
        // This is a Firebase Auth callback - ignore it and go to home
        // The auth state will be handled by Firebase Auth automatically
        return '/';
      }
      return null; // No redirect needed
    },
    errorBuilder: (context, state) {
      // Handle unknown routes - redirect to home instead of showing error
      // This handles Firebase Auth deep links that don't match our routes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          GoRouter.of(context).go('/');
        }
      });
      return Scaffold(
        body: LoadingIndicatorM3E(
          message: getRandomLoadingMessage(),
        ),
      );
    },
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
            path: '/my-fridges',
            pageBuilder: (context, state) =>
                _buildPageWithTransition('/my-fridges', const MyFridgesScreen()),
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

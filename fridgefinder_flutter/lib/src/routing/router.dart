import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import '../features/map/presentation/screens/map_screen.dart';
import '../features/list/presentation/list_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/auth/presentation/screens/my_fridges_screen.dart';
import '../features/auth/presentation/screens/profile_completion_screen.dart';
import '../common_widgets/main_shell.dart';
import '../common_widgets/loading_messages.dart';
import '../core/providers/auth_provider.dart';

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

/// Notifier that listens to auth state changes and notifies router to rebuild
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    // Listen to auth user stream and notify when it changes
    _ref.listen(authUserProvider, (previous, next) {
      notifyListeners();
    });

    // Listen to user profile changes and notify when it changes
    _ref.listen(userProfileProvider, (previous, next) {
      notifyListeners();
    });
  }

  final Ref _ref;
}

// Router configuration
final routerProvider = Provider<GoRouter>((ref) {
  // Create notifier that triggers router refresh on auth changes
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      // Handle Firebase Auth deep links - redirect to home
      final uri = state.uri;
      if (uri.toString().contains('firebaseauth') ||
          uri.toString().contains('fridgefinder-app.firebaseapp.com')) {
        // This is a Firebase Auth callback - ignore it and go to home
        // The auth state will be handled by Firebase Auth automatically
        return '/';
      }

      final currentPath = state.matchedLocation;

      // Skip check if already on profile completion screen
      if (currentPath == '/complete-profile') {
        return null;
      }

      // Check auth state directly to handle loading states properly
      final authUserAsync = ref.read(authUserProvider);

      return authUserAsync.when(
        data: (authUser) {
          // If no auth user, allow navigation (not authenticated)
          if (authUser == null) {
            return null;
          }

          // User is authenticated, check profile directly
          final profileAsync = ref.read(userProfileProvider);

          return profileAsync.when(
            data: (profile) {
              // Check if profile is incomplete
              if (profile == null) {
                // No profile at all
                return '/complete-profile';
              }

              // Check if username is set
              if (profile.username.isEmpty) {
                return '/complete-profile';
              }

              // Check if zipCode is set when user is a volunteer
              if (profile.isVolunteer &&
                  (profile.zipCode == null || profile.zipCode!.isEmpty)) {
                return '/complete-profile';
              }

              // Profile is complete
              return null;
            },
            loading: () => null, // Don't redirect while profile is loading
            error: (_, _) => null, // Don't redirect on error
          );
        },
        loading: () => null, // Don't redirect while auth is loading
        error: (_, _) => null, // Don't redirect on auth error
      );
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
      // Profile completion screen - outside of shell (no nav bar)
      GoRoute(
        path: '/complete-profile',
        builder: (context, state) => const ProfileCompletionScreen(),
      ),
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

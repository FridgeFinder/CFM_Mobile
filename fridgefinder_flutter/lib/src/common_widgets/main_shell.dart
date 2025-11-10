import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './bottom_nav_bar.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/drawer_provider.dart';
import '../core/providers/subscriptions_provider.dart';
import '../features/auth/presentation/widgets/sign_in_widget.dart';

/// Main shell layout that keeps the bottom navigation bar constant
/// while allowing the page content to transition with directional slides
class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  final String currentRoute;

  const MainShell({super.key, required this.child, required this.currentRoute});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> with TickerProviderStateMixin {
  late int _currentIndex;
  late int _previousIndex;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isDrawerOpen = false;
  late AnimationController _drawerAnimationController;

  @override
  void initState() {
    super.initState();
    _currentIndex = _getIndexForRoute(widget.currentRoute);
    _previousIndex = _currentIndex;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOutCubic,
          ),
        );

    _drawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute) {
      _previousIndex = _currentIndex;
      _currentIndex = _getIndexForRoute(widget.currentRoute);

      // Determine direction and animate
      final isMovingRight = _currentIndex > _previousIndex;
      final beginOffset = isMovingRight
          ? const Offset(1.0, 0.0) // Enter from right
          : const Offset(-1.0, 0.0); // Enter from left

      _slideAnimation = Tween<Offset>(begin: beginOffset, end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOutCubic,
            ),
          );

      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _drawerAnimationController.dispose();
    super.dispose();
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

  String _getTitleForRoute(String route) {
    switch (route) {
      case '/':
        return 'Fridge Map';
      case '/list':
        return 'Fridge List';
      case '/my-fridges':
        return 'My Fridges';
      case '/profile':
        return 'Profile';
      default:
        return 'FridgeFinder';
    }
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
    // Update drawer state provider immediately
    ref.read(drawerStateProvider.notifier).setOpen(_isDrawerOpen);
    if (_isDrawerOpen) {
      _drawerAnimationController.forward();
    } else {
      _drawerAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final drawerAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _drawerAnimationController,
            curve: Curves.easeInOutCubic,
          ),
        );

    return Stack(
      children: [
        Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3), // Keep blue color in all themes
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      SizedBox(
                        height: 60,
                        width: 60,
                        child: Image.asset(
                          'assets/images/logo.webp',
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Page Title
                      Expanded(
                        child: Center(
                          child: Text(
                            _getTitleForRoute(widget.currentRoute),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      // Hamburger Menu
                      IconButton(
                        icon: const Icon(Icons.menu),
                        color: Colors.white,
                        onPressed: _toggleDrawer,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: SlideTransition(position: _slideAnimation, child: widget.child),
          bottomNavigationBar: AppBottomNavBar(
            currentRoute: widget.currentRoute,
          ),
        ),
        // Drawer overlay
        if (_isDrawerOpen)
          GestureDetector(
            onTap: _toggleDrawer,
            child: AnimatedBuilder(
              animation: _drawerAnimationController,
              builder: (context, child) {
                final opacity = 1.0 - (_drawerAnimationController.value * 0.3);
                return Container(
                  color: Colors.black.withValues(alpha: 0.5 * (1.0 - opacity)),
                );
              },
            ),
          ),
        // Navigation drawer
        SlideTransition(
          position: drawerAnimation,
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Container(
                width: 280,
                height: double.infinity,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: SafeArea(
                  child: Column(
                    children: [
                      // Close button
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _toggleDrawer,
                          ),
                        ),
                      ),
                      // Menu items
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          children: [
                            _buildMenuTile(
                              context: context,
                              icon: Icons.map,
                              title: 'Fridge Map',
                              subtitle: 'View fridges on map',
                              isSelected: widget.currentRoute == '/',
                              route: '/',
                              onTap: () {
                                _toggleDrawer();
                                GoRouter.of(context).go('/');
                              },
                            ),
                            _buildMenuTile(
                              context: context,
                              icon: Icons.list,
                              title: 'Fridge List',
                              subtitle: 'Browse all fridges',
                              isSelected: widget.currentRoute == '/list',
                              route: '/list',
                              onTap: () {
                                _toggleDrawer();
                                GoRouter.of(context).go('/list');
                              },
                            ),
                            _buildMenuTile(
                              context: context,
                              icon: Icons.favorite,
                              title: 'My Fridges',
                              subtitle: 'Your subscribed fridges',
                              isSelected: widget.currentRoute == '/my-fridges',
                              route: '/my-fridges',
                              onTap: () {
                                _toggleDrawer();
                                GoRouter.of(context).go('/my-fridges');
                              },
                            ),
                            _buildMenuTile(
                              context: context,
                              icon: Icons.person,
                              title: 'Profile',
                              subtitle: 'Settings & preferences',
                              isSelected: widget.currentRoute == '/profile',
                              route: '/profile',
                              onTap: () {
                                _toggleDrawer();
                                GoRouter.of(context).go('/profile');
                              },
                            ),
                          ],
                        ),
                      ),
                      // Footer with auth widget
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(color: Theme.of(context).dividerColor),
                            const SizedBox(height: 12),
                            Consumer(
                              builder: (context, ref, child) {
                                final isAuthenticated = ref.watch(isAuthenticatedProvider);
                                final userProfileAsync = ref.watch(userProfileProvider);
                                
                                if (!isAuthenticated) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          _toggleDrawer();
                                          showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              child: Padding(
                                                padding: const EdgeInsets.all(24.0),
                                                child: SignInWidget(),
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.login),
                                        label: const Text('Sign In'),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  );
                                }
                                
                                return userProfileAsync.when(
                                  loading: () => const SizedBox.shrink(),
                                  error: (_, _) => const SizedBox.shrink(),
                                  data: (profile) {
                                    if (profile == null) return const SizedBox.shrink();
                                    
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 16,
                                              child: Text(
                                                profile.username.substring(0, 1).toUpperCase(),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    profile.username,
                                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  if (profile.isVolunteer)
                                                    Text(
                                                      'Volunteer',
                                                      style: Theme.of(context).textTheme.bodySmall,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        OutlinedButton.icon(
                                          onPressed: () async {
                                            try {
                                              final repository = ref.read(authRepositoryProvider);
                                              await repository.signOut();

                                              // Invalidate providers to update UI
                                              ref.invalidate(authUserProvider);
                                              ref.invalidate(userProfileProvider);
                                              ref.invalidate(isAuthenticatedProvider);
                                              ref.invalidate(subscribedFridgesProvider);

                                              _toggleDrawer();
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Error signing out: $e')),
                                                );
                                              }
                                            }
                                          },
                                          icon: const Icon(Icons.logout),
                                          label: const Text('Sign Out'),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            Text(
                              'About FridgeFinder',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'v1.0.0',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required String route,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? Colors.white
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isSelected
                ? Colors.white70
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap,
      ),
    );
  }
}

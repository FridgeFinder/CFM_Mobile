import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import './bottom_nav_bar.dart';
import '../common_widgets/index.dart' as common_widgets;
import '../core/providers/auth_provider.dart';
import '../core/providers/drawer_provider.dart';
import '../core/providers/subscriptions_provider.dart';
import '../features/auth/presentation/widgets/sign_in_widget.dart';

/// Main shell layout that keeps the bottom navigation bar constant
/// while allowing the page content to transition with M3E fade through pattern
class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  final String currentRoute;

  const MainShell({super.key, required this.child, required this.currentRoute});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isDrawerOpen = false;
  late AnimationController _drawerAnimationController;

  @override
  void initState() {
    super.initState();

    // Use M3E medium3 duration for fade through (350ms)
    _animationController = AnimationController(
      duration: M3EMotion.medium3,
      vsync: this,
    );

    // Fade through pattern: fade in during last 65% of animation
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeIn),
    );

    // Slight scale for expressiveness (92% to 100%)
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.35, 1.0, curve: M3EMotion.emphasized),
      ),
    );

    _drawerAnimationController = AnimationController(
      duration: M3EMotionPatterns.drawerFallback, // Use M3E duration
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute) {
      // Trigger fade through animation for same-level navigation (bottom nav)
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _drawerAnimationController.dispose();
    super.dispose();
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
            curve: M3EMotion.emphasizedDecelerate,
          ),
        );

    return Stack(
      children: [
        Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Container(
              decoration: BoxDecoration(
                // M3E-compliant gradient using tonal palette values
                // Subtle gradient using lighter blue tones
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF88B3FF), // primaryTone80 (lighter, at top)
                    Color(
                      0xFF6FA7FF,
                    ), // primaryTone70 (slightly darker, at bottom)
                  ],
                  stops: [0.0, 0.9], // Concentrate darker color toward bottom
                ),
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
                            style: M3ETypography.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      // Hamburger Menu
                      InteractiveIconButtonM3E(
                        icon: Icons.menu,
                        iconColor: Colors.white,
                        onPressed: _toggleDrawer,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: widget.currentRoute == '/'
              ? widget
                    .child // Skip animations for map screen to prevent rendering issues
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: widget.child,
                  ),
                ),
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
        // Navigation drawer - M3E compliant
        SlideTransition(
          position: drawerAnimation,
          child: Align(
            alignment: Alignment.centerRight,
            child: SafeArea(
              child: NavigationDrawerM3E(
                selectedIndex: _getIndexForRoute(widget.currentRoute),

                onDestinationSelected: (index) {
                  final routes = ['/', '/list', '/my-fridges', '/profile'];
                  _toggleDrawer();
                  GoRouter.of(context).go(routes[index]);
                },
                destinations: const [
                  NavigationDrawerDestinationM3E(
                    icon: Icon(Icons.map_outlined),
                    selectedIcon: Icon(Icons.map),
                    label: Text('Fridge Map'),
                  ),
                  NavigationDrawerDestinationM3E(
                    icon: Icon(Icons.list_outlined),
                    selectedIcon: Icon(Icons.list),
                    label: Text('Fridge List'),
                  ),
                  NavigationDrawerDestinationM3E(
                    icon: Icon(Icons.favorite_outline),
                    selectedIcon: Icon(Icons.favorite),
                    label: Text('My Fridges'),
                  ),
                  NavigationDrawerDestinationM3E(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: Text('Profile'),
                  ),
                ],
                header: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Menu', style: M3ETypography.titleLarge),
                      InteractiveIconButtonM3E(
                        icon: Icons.close,
                        onPressed: _toggleDrawer,
                      ),
                    ],
                  ),
                ),
                footer: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Keep divider full width
                    SizedBox(
                      width: double.infinity,
                      child: Divider(color: Theme.of(context).dividerColor),
                    ),
                    const SizedBox(height: 12),
                    Consumer(
                      builder: (context, ref, child) {
                        final isAuthenticated = ref.watch(
                          isAuthenticatedProvider,
                        );
                        final userProfileAsync = ref.watch(userProfileProvider);

                        if (!isAuthenticated) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              OutlinedButtonM3E(
                                onPressed: () {
                                  _toggleDrawer();
                                  DialogM3E.showCustom(
                                    context: context,
                                    child: Padding(
                                      padding: M3ESpacing.all(M3ESpacing.xl),
                                      child: SignInWidget(),
                                    ),
                                  );
                                },
                                icon: Icons.login,
                                child: const Text('Sign In'),
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        }

                        return userProfileAsync.when(
                          loading: () =>
                              const common_widgets.LoadingIndicator(),
                          error: (_, _) => const SizedBox.shrink(),
                          data: (profile) {
                            if (profile == null) return const SizedBox.shrink();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      child: Text(
                                        profile.username
                                            .substring(0, 1)
                                            .toUpperCase(),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          profile.username,
                                          style: M3ETypography.bodyMedium
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                              ),
                                        ),
                                        if (profile.isVolunteer)
                                          Text(
                                            'Volunteer',
                                            style: M3ETypography.bodySmall
                                                .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                OutlinedButtonM3E(
                                  onPressed: () async {
                                    try {
                                      final repository = ref.read(
                                        authRepositoryProvider,
                                      );
                                      await repository.signOut();

                                      // Invalidate providers to update UI
                                      ref.invalidate(authUserProvider);
                                      ref.invalidate(userProfileProvider);
                                      ref.invalidate(isAuthenticatedProvider);
                                      ref.invalidate(subscribedFridgesProvider);

                                      _toggleDrawer();
                                    } catch (e) {
                                      if (context.mounted) {
                                        showSnackbarM3E(
                                          context: context,
                                          message: 'Error signing out: $e',
                                        );
                                      }
                                    }
                                  },
                                  icon: Icons.logout,
                                  child: const Text('Sign Out'),
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
                      style: M3ETypography.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'v1.0.0',
                      style: M3ETypography.labelSmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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

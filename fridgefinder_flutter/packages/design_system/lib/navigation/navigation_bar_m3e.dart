import 'package:flutter/material.dart';
import '../theme/elevation.dart';
import '../theme/motion.dart';
import '../theme/spacing.dart';

/// Material 3 Expressive Navigation Bar
///
/// A navigation bar that follows M3E specifications with enhanced height,
/// expressive animations, and proper elevation handling.
///
/// **M3E Specifications:**
/// - Height: 80dp (increased from 56dp in MD2)
/// - 3-5 destinations maximum
/// - Icon size: 24x24dp
/// - Spacing: 6dp above icon, 10dp under text, 6dp below icon
/// - Active indicator: Pill-shaped, filled with secondaryContainer
/// - Elevation: Level 3 (6dp) with surface tint
/// - Smooth slide animation between destinations (300ms with responsive spring)
///
/// **Visual Design:**
/// - Background: surface color
/// - Selected item: secondaryContainer indicator with primary color icon
/// - Unselected item: onSurfaceVariant icon color
/// - Label: Always shown (NavigationDestinationLabelBehavior.alwaysShow)
/// - Typography: labelMedium for labels
///
/// **Example Usage:**
/// ```dart
/// NavigationBarM3E(
///   selectedIndex: _selectedIndex,
///   onDestinationSelected: (index) {
///     setState(() {
///       _selectedIndex = index;
///     });
///   },
///   destinations: const [
///     NavigationDestination(
///       icon: Icon(Icons.home_outlined),
///       selectedIcon: Icon(Icons.home),
///       label: 'Home',
///     ),
///     NavigationDestination(
///       icon: Icon(Icons.search_outlined),
///       selectedIcon: Icon(Icons.search),
///       label: 'Search',
///     ),
///     NavigationDestination(
///       icon: Icon(Icons.person_outlined),
///       selectedIcon: Icon(Icons.person),
///       label: 'Profile',
///     ),
///   ],
/// )
/// ```
///
/// **Advanced Usage with Custom Styling:**
/// ```dart
/// NavigationBarM3E(
///   selectedIndex: _selectedIndex,
///   onDestinationSelected: _handleDestinationSelected,
///   destinations: _destinations,
///   backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
///   elevation: M3EElevation.level4,
///   height: 88.0, // Custom height
///   indicatorColor: Theme.of(context).colorScheme.primaryContainer,
///   animationDuration: const Duration(milliseconds: 250),
/// )
/// ```
///
/// **Accessibility:**
/// - Each destination should have a clear, descriptive label
/// - Icons should be semantically meaningful
/// - The component supports screen readers and keyboard navigation
/// - Selected state is properly announced
///
/// **Best Practices:**
/// - Use 3-5 destinations (as per M3 guidelines)
/// - Provide both icon and selectedIcon variants for better visual feedback
/// - Keep labels concise (1-2 words)
/// - Use outlined icons for unselected state, filled icons for selected state
/// - Ensure sufficient color contrast for accessibility
class NavigationBarM3E extends StatelessWidget {
  /// The index of the currently selected destination.
  ///
  /// Must be a valid index (0 to destinations.length - 1).
  final int selectedIndex;

  /// Called when a destination is selected.
  ///
  /// Provides the index of the selected destination.
  final ValueChanged<int> onDestinationSelected;

  /// The list of navigation destinations.
  ///
  /// Must contain 3-5 destinations as per M3 guidelines.
  /// Each destination should include:
  /// - icon: The icon to display when not selected
  /// - selectedIcon: The icon to display when selected (optional, defaults to icon)
  /// - label: The text label for the destination
  final List<NavigationDestination> destinations;

  /// The background color of the navigation bar.
  ///
  /// Defaults to Theme.of(context).colorScheme.surface.
  final Color? backgroundColor;

  /// The elevation of the navigation bar.
  ///
  /// Defaults to M3EElevation.level3 (6.0dp) as per M3E specifications.
  final double? elevation;

  /// The height of the navigation bar.
  ///
  /// Defaults to 80.0dp as per M3E specifications (increased from 56dp in MD2).
  final double? height;

  /// The color of the selection indicator.
  ///
  /// Defaults to Theme.of(context).colorScheme.secondaryContainer.
  final Color? indicatorColor;

  /// The shape of the selection indicator.
  ///
  /// Defaults to a stadium shape (pill-shaped) as per M3 specifications.
  final ShapeBorder? indicatorShape;

  /// The duration of the slide animation between destinations.
  ///
  /// Defaults to 300ms as per M3E specifications.
  final Duration? animationDuration;

  /// Whether to show shadows for elevation.
  ///
  /// When true, shows box shadows in addition to surface tint.
  /// Defaults to true for better depth perception.
  final bool showShadow;

  /// The label behavior for navigation destinations.
  ///
  /// Defaults to NavigationDestinationLabelBehavior.alwaysShow as per M3E specs.
  final NavigationDestinationLabelBehavior? labelBehavior;

  /// Creates a Material 3 Expressive navigation bar.
  ///
  /// The [selectedIndex], [onDestinationSelected], and [destinations] parameters
  /// are required.
  ///
  /// The [destinations] list must contain between 3-5 items as per M3 guidelines.
  const NavigationBarM3E({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.backgroundColor,
    this.elevation,
    this.height,
    this.indicatorColor,
    this.indicatorShape,
    this.animationDuration,
    this.showShadow = true,
    this.labelBehavior,
  }) : assert(
         destinations.length >= 3 && destinations.length <= 5,
         'NavigationBarM3E must have between 3-5 destinations per M3 guidelines',
       );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // M3E defaults
    final effectiveHeight = height ?? M3ESpacing.navigationBarHeight;
    final effectiveElevation = elevation ?? M3EElevation.navigationBar;
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.surface;
    final effectiveIndicatorColor =
        indicatorColor ?? colorScheme.secondaryContainer;
    final effectiveAnimationDuration =
        animationDuration ??
        M3EMotion.medium4; // 400ms for smoother transitions

    // Calculate surface with tonal elevation
    final surfaceWithTint = M3EElevation.applySurfaceTint(
      surface: effectiveBackgroundColor,
      surfaceTint: colorScheme.primary,
      elevation: effectiveElevation,
    );

    return Container(
      height: effectiveHeight,
      decoration: BoxDecoration(
        color: surfaceWithTint,
        boxShadow: showShadow
            ? M3EElevation.getShadow(effectiveElevation)
            : null,
      ),
      child: SafeArea(
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: destinations,
          backgroundColor: Colors.transparent,
          elevation: 0, // We handle elevation in the Container
          height: effectiveHeight,
          indicatorColor: effectiveIndicatorColor,
          indicatorShape:
              indicatorShape ?? const StadiumBorder(), // Pill-shaped indicator
          labelBehavior:
              labelBehavior ?? NavigationDestinationLabelBehavior.alwaysShow,
          // Apply animation duration through theme
          animationDuration: effectiveAnimationDuration,
        ),
      ),
    );
  }
}

/// Extended Navigation Bar with additional customization options
///
/// Provides more control over the navigation bar appearance and behavior,
/// including custom icon colors, label styles, and overlay behavior.
///
/// **Example:**
/// ```dart
/// NavigationBarM3EExtended(
///   selectedIndex: _currentIndex,
///   onDestinationSelected: _onDestinationSelected,
///   destinations: _destinations,
///   selectedIconColor: Colors.deepPurple,
///   unselectedIconColor: Colors.grey,
///   selectedLabelStyle: TextStyle(
///     fontWeight: FontWeight.bold,
///     fontSize: 14,
///   ),
///   overlayColor: WidgetStateProperty.resolveWith((states) {
///     if (states.contains(WidgetState.pressed)) {
///       return Colors.blue.withOpacity(0.12);
///     }
///     if (states.contains(WidgetState.hovered)) {
///       return Colors.blue.withOpacity(0.08);
///     }
///     return null;
///   }),
/// )
/// ```
class NavigationBarM3EExtended extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  final Color? backgroundColor;
  final double? elevation;
  final double? height;
  final Color? indicatorColor;
  final ShapeBorder? indicatorShape;
  final Duration? animationDuration;
  final bool showShadow;
  final NavigationDestinationLabelBehavior? labelBehavior;

  // Extended properties
  final Color? selectedIconColor;
  final Color? unselectedIconColor;
  final TextStyle? selectedLabelStyle;
  final TextStyle? unselectedLabelStyle;
  final WidgetStateProperty<Color?>? overlayColor;
  final double? iconSize;

  const NavigationBarM3EExtended({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.backgroundColor,
    this.elevation,
    this.height,
    this.indicatorColor,
    this.indicatorShape,
    this.animationDuration,
    this.showShadow = true,
    this.labelBehavior,
    this.selectedIconColor,
    this.unselectedIconColor,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    this.overlayColor,
    this.iconSize,
  }) : assert(
         destinations.length >= 3 && destinations.length <= 5,
         'NavigationBarM3EExtended must have between 3-5 destinations',
       );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveHeight = height ?? M3ESpacing.navigationBarHeight;
    final effectiveElevation = elevation ?? M3EElevation.navigationBar;
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.surface;
    final effectiveIndicatorColor =
        indicatorColor ?? colorScheme.secondaryContainer;
    final effectiveAnimationDuration =
        animationDuration ??
        M3EMotion.medium4; // 400ms for smoother transitions

    final surfaceWithTint = M3EElevation.applySurfaceTint(
      surface: effectiveBackgroundColor,
      surfaceTint: colorScheme.primary,
      elevation: effectiveElevation,
    );

    // Create custom theme for the navigation bar
    final navigationBarTheme = NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      height: effectiveHeight,
      indicatorColor: effectiveIndicatorColor,
      indicatorShape: indicatorShape ?? const StadiumBorder(),
      labelBehavior:
          labelBehavior ?? NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(
            color: selectedIconColor ?? colorScheme.onSecondaryContainer,
            size: iconSize ?? 24.0,
          );
        }
        return IconThemeData(
          color: unselectedIconColor ?? colorScheme.onSurfaceVariant,
          size: iconSize ?? 24.0,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final baseStyle = theme.textTheme.labelMedium;
        if (states.contains(WidgetState.selected)) {
          return selectedLabelStyle ??
              baseStyle?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              );
        }
        return unselectedLabelStyle ??
            baseStyle?.copyWith(color: colorScheme.onSurfaceVariant);
      }),
    );

    return Container(
      height: effectiveHeight,
      decoration: BoxDecoration(
        color: surfaceWithTint,
        boxShadow: showShadow
            ? M3EElevation.getShadow(effectiveElevation)
            : null,
      ),
      child: SafeArea(
        child: Theme(
          data: theme.copyWith(navigationBarTheme: navigationBarTheme),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: destinations,
            animationDuration: effectiveAnimationDuration,
            overlayColor: overlayColor,
          ),
        ),
      ),
    );
  }
}

/// Adaptive Navigation Bar that changes behavior based on screen size
///
/// Shows a bottom navigation bar on mobile and a navigation rail on tablet/desktop.
/// Automatically adapts to the available screen width.
///
/// **Example:**
/// ```dart
/// AdaptiveNavigationBarM3E(
///   selectedIndex: _currentIndex,
///   onDestinationSelected: _onDestinationSelected,
///   destinations: _destinations,
///   breakpoint: 840, // Custom breakpoint for rail vs bar
/// )
/// ```
class AdaptiveNavigationBarM3E extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  final double breakpoint;
  final Color? backgroundColor;
  final double? elevation;
  final Color? indicatorColor;
  final bool showLabels;

  const AdaptiveNavigationBarM3E({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.breakpoint = 840.0,
    this.backgroundColor,
    this.elevation,
    this.indicatorColor,
    this.showLabels = true,
  }) : assert(
         destinations.length >= 3 && destinations.length <= 5,
         'AdaptiveNavigationBarM3E must have between 3-5 destinations',
       );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final useRail = width >= breakpoint;

    if (useRail) {
      // Use NavigationRail for larger screens
      return _buildNavigationRail(context);
    } else {
      // Use NavigationBar for smaller screens
      return NavigationBarM3E(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
        backgroundColor: backgroundColor,
        elevation: elevation,
        indicatorColor: indicatorColor,
      );
    }
  }

  Widget _buildNavigationRail(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: showLabels
          ? NavigationRailLabelType.all
          : NavigationRailLabelType.none,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      indicatorColor: indicatorColor ?? colorScheme.secondaryContainer,
      destinations: destinations
          .map(
            (dest) => NavigationRailDestination(
              icon: dest.icon,
              selectedIcon: dest.selectedIcon ?? dest.icon,
              label: Text(dest.label),
            ),
          )
          .toList(),
    );
  }
}

/// Helper class for creating navigation destinations with consistent styling
///
/// Provides factory methods for common navigation destination patterns.
class NavigationDestinationM3E {
  NavigationDestinationM3E._();

  /// Creates a standard navigation destination with outlined/filled icon pair
  ///
  /// **Example:**
  /// ```dart
  /// NavigationDestinationM3E.standard(
  ///   icon: Icons.home_outlined,
  ///   selectedIcon: Icons.home,
  ///   label: 'Home',
  /// )
  /// ```
  static NavigationDestination standard({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    String? tooltip,
    bool enabled = true,
  }) {
    return NavigationDestination(
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon),
      label: label,
      tooltip: tooltip,
      enabled: enabled,
    );
  }

  /// Creates a navigation destination with a badge
  ///
  /// **Example:**
  /// ```dart
  /// NavigationDestinationM3E.withBadge(
  ///   icon: Icons.notifications_outlined,
  ///   selectedIcon: Icons.notifications,
  ///   label: 'Notifications',
  ///   badgeLabel: '5',
  /// )
  /// ```
  static NavigationDestination withBadge({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    String? badgeLabel,
    bool showBadge = true,
    String? tooltip,
    bool enabled = true,
  }) {
    return NavigationDestination(
      icon: Badge(
        label: badgeLabel != null ? Text(badgeLabel) : null,
        isLabelVisible: showBadge,
        child: Icon(icon),
      ),
      selectedIcon: Badge(
        label: badgeLabel != null ? Text(badgeLabel) : null,
        isLabelVisible: showBadge,
        child: Icon(selectedIcon),
      ),
      label: label,
      tooltip: tooltip,
      enabled: enabled,
    );
  }

  /// Creates a navigation destination with a notification dot
  ///
  /// **Example:**
  /// ```dart
  /// NavigationDestinationM3E.withDot(
  ///   icon: Icons.message_outlined,
  ///   selectedIcon: Icons.message,
  ///   label: 'Messages',
  ///   showDot: hasNewMessages,
  /// )
  /// ```
  static NavigationDestination withDot({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    bool showDot = true,
    Color? dotColor,
    String? tooltip,
    bool enabled = true,
  }) {
    return NavigationDestination(
      icon: Badge(
        isLabelVisible: showDot,
        backgroundColor: dotColor,
        child: Icon(icon),
      ),
      selectedIcon: Badge(
        isLabelVisible: showDot,
        backgroundColor: dotColor,
        child: Icon(selectedIcon),
      ),
      label: label,
      tooltip: tooltip,
      enabled: enabled,
    );
  }
}

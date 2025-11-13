import 'package:flutter/material.dart';
import '../theme/motion.dart';
import '../theme/spacing.dart';

/// Material 3 Expressive Navigation Drawer
///
/// A navigation drawer that follows M3E specifications with enhanced animations
/// and proper styling.
///
/// SPECIFICATIONS:
/// - Width: 360dp (increased from MD2's 304dp)
/// - Item height: 56dp per destination
/// - Active indicator: Pill-shaped, full width minus 24dp margins
/// - Background: surfaceContainerLow color
/// - Selected item indicator: secondaryContainer with full/pill shape
///
/// ANIMATIONS:
/// - Slide in: 350ms with M3EMotion.gentleSpring from left
/// - Indicator slide: 300ms with M3EMotion.responsiveSpring
/// - Scrim fade: 300ms for modal variant
///
/// Example usage:
///
/// ```dart
/// NavigationDrawerM3E(
///   selectedIndex: _selectedIndex,
///   onDestinationSelected: (index) {
///     setState(() => _selectedIndex = index);
///   },
///   destinations: const [
///     NavigationDrawerDestinationM3E(
///       icon: Icon(Icons.home_outlined),
///       selectedIcon: Icon(Icons.home),
///       label: Text('Home'),
///     ),
///     NavigationDrawerDestinationM3E(
///       icon: Icon(Icons.explore_outlined),
///       selectedIcon: Icon(Icons.explore),
///       label: Text('Explore'),
///     ),
///   ],
///   header: DrawerHeader(
///     child: Column(
///       crossAxisAlignment: CrossAxisAlignment.start,
///       children: [
///         Icon(Icons.flutter_dash, size: 48),
///         SizedBox(height: 8),
///         Text('My App', style: TextStyle(fontSize: 24)),
///       ],
///     ),
///   ),
/// )
/// ```
class NavigationDrawerM3E extends StatefulWidget {
  /// The index of the currently selected destination.
  final int selectedIndex;

  /// Called when a destination is selected.
  final ValueChanged<int> onDestinationSelected;

  /// The list of destinations to display in the drawer.
  final List<NavigationDrawerDestinationM3E> destinations;

  /// Optional header widget displayed at the top of the drawer.
  ///
  /// Typically a [DrawerHeader] with 16:9 aspect ratio recommended.
  final Widget? header;

  /// Optional footer widget displayed at the bottom of the drawer.
  ///
  /// A [Spacer] is automatically added before the footer to push it to the bottom.
  final Widget? footer;

  /// The background color of the drawer.
  ///
  /// Defaults to [ColorScheme.surfaceContainerLow].
  final Color? backgroundColor;

  /// The elevation of the drawer.
  ///
  /// Defaults to 1.0 for standard, 0.0 for modal (handled by Drawer widget).
  final double? elevation;

  /// Creates a Material 3 Expressive navigation drawer.
  const NavigationDrawerM3E({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.header,
    this.footer,
    this.backgroundColor,
    this.elevation,
  });

  @override
  State<NavigationDrawerM3E> createState() => _NavigationDrawerM3EState();
}

class _NavigationDrawerM3EState extends State<NavigationDrawerM3E>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    // Cascade entrance animation (500ms total with stagger)
    _entranceController = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.long2), // 500ms
      vsync: this,
    );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      width: 300, // M3E spec: increased from MD2's 304dp
      backgroundColor:
          widget.backgroundColor ?? colorScheme.surfaceContainerLow,
      elevation: widget.elevation,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with fade animation
          if (widget.header != null)
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _entranceController,
                curve: const Interval(
                  0.0,
                  0.2,
                  curve: M3EMotion.emphasizedDecelerate,
                ),
              ),
              child: widget.header!,
            ),

          // Add top padding if no header
          if (widget.header == null) M3ESpacing.verticalSM,

          // Destinations with cascade entrance animation
          ...widget.destinations.asMap().entries.map((entry) {
            final index = entry.key;
            final destination = entry.value;
            final isSelected = index == widget.selectedIndex;

            // Stagger delay: 40ms per item
            final staggerDelay = (index / widget.destinations.length) * 0.3;
            final itemAnimation = CurvedAnimation(
              parent: _entranceController,
              curve: Interval(
                staggerDelay.clamp(0.0, 0.7),
                (staggerDelay + 0.7).clamp(0.0, 1.0),
                curve: M3EMotion.expressiveDefaultOvershoot,
              ),
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-0.3, 0), // Slide from left
                end: Offset.zero,
              ).animate(itemAnimation),
              child: FadeTransition(
                opacity: itemAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0, // 12dp margins for pill indicator
                    vertical:
                        4.0, // 4dp between items (totals to 8dp with both sides)
                  ),
                  child: _NavigationDrawerItem(
                    destination: destination,
                    isSelected: isSelected,
                    onTap: () => widget.onDestinationSelected(index),
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  ),
                ),
              ),
            );
          }),

          // Spacer to push footer to bottom
          if (widget.footer != null) const Spacer(),

          // Footer with fade animation
          if (widget.footer != null)
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _entranceController,
                curve: const Interval(
                  0.8,
                  1.0,
                  curve: M3EMotion.emphasizedDecelerate,
                ),
              ),
              child: Padding(
                padding: M3ESpacing.navigationDrawerPadding,
                child: widget.footer!,
              ),
            ),
          if (widget.footer != null) M3ESpacing.verticalSM,
        ],
      ),
    );
  }
}

/// A destination in a Material 3 Expressive navigation drawer.
///
/// Represents a single navigation item with an icon, label, and optional badge.
class NavigationDrawerDestinationM3E {
  /// The icon to display when this destination is not selected.
  final Widget icon;

  /// The icon to display when this destination is selected.
  ///
  /// If null, [icon] will be used for both selected and unselected states.
  final Widget? selectedIcon;

  /// The label text for this destination.
  final Widget label;

  /// Optional badge to display on this destination.
  ///
  /// Typically a [Badge] widget with a count or indicator.
  final Widget? badge;

  /// Whether this destination is enabled.
  ///
  /// If false, the destination will be grayed out and non-interactive.
  final bool enabled;

  /// Creates a navigation drawer destination.
  const NavigationDrawerDestinationM3E({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.badge,
    this.enabled = true,
  });
}

/// Internal widget for rendering individual navigation drawer items
class _NavigationDrawerItem extends StatefulWidget {
  final NavigationDrawerDestinationM3E destination;
  final bool isSelected;
  final VoidCallback onTap;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _NavigationDrawerItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  State<_NavigationDrawerItem> createState() => _NavigationDrawerItemState();
}

class _NavigationDrawerItemState extends State<_NavigationDrawerItem>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Spring-based scale animation for press feedback
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: M3EMotion.responsiveSpring.toCurve(),
      ),
    );

    if (widget.isSelected) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_NavigationDrawerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.destination.enabled;
    final iconColor = widget.isSelected
        ? widget.colorScheme.onSecondaryContainer
        : isEnabled
        ? widget.colorScheme.onSurfaceVariant
        : widget.colorScheme.onSurface.withValues(alpha: 0.38);

    final labelColor = widget.isSelected
        ? widget.colorScheme.onSurface
        : isEnabled
        ? widget.colorScheme.onSurfaceVariant
        : widget.colorScheme.onSurface.withValues(alpha: 0.38);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? widget.onTap : null,
          onTapDown: isEnabled ? (_) => _controller.forward() : null,
          onTapUp: isEnabled ? (_) => _controller.reverse() : null,
          onTapCancel: isEnabled ? () => _controller.reverse() : null,
          borderRadius: BorderRadius.circular(28), // Full pill shape
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: M3EMotion.responsiveSpring.toCurve(),
            height: 56, // M3E spec: 56dp item height
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? widget.colorScheme.secondaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(28), // Full pill shape
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Icon with badge
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: IconTheme(
                    key: ValueKey(widget.isSelected),
                    data: IconThemeData(
                      color: iconColor,
                      size: 24, // M3E spec: 24dp icon size
                    ),
                    child:
                        widget.isSelected &&
                            widget.destination.selectedIcon != null
                        ? widget.destination.selectedIcon!
                        : widget.destination.icon,
                  ),
                ),

                // Badge
                if (widget.destination.badge != null) ...[
                  M3ESpacing.horizontalXXS,
                  widget.destination.badge!,
                ],

                M3ESpacing.horizontalSM,

                // Label
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    curve: M3EMotion.standard,
                    style: widget.textTheme.labelLarge!.copyWith(
                      color: labelColor,
                      fontWeight: widget.isSelected
                          ? FontWeight
                                .w600 // Emphasize selected
                          : FontWeight.w500,
                    ),
                    child: widget.destination.label,
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

/// Modal Navigation Drawer with scrim
///
/// A modal variant that appears over content with a scrim backdrop.
/// Automatically includes slide-in animation and scrim fade.
///
/// Example usage:
///
/// ```dart
/// // Show modal drawer
/// showModalNavigationDrawer(
///   context: context,
///   builder: (context) => NavigationDrawerM3E(
///     selectedIndex: _selectedIndex,
///     onDestinationSelected: (index) {
///       setState(() => _selectedIndex = index);
///       Navigator.pop(context);
///     },
///     destinations: const [
///       NavigationDrawerDestinationM3E(
///         icon: Icon(Icons.home_outlined),
///         selectedIcon: Icon(Icons.home),
///         label: Text('Home'),
///       ),
///     ],
///   ),
/// );
/// ```
Future<T?> showModalNavigationDrawer<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? barrierColor,
  bool barrierDismissible = true,
  String? barrierLabel,
  bool useRootNavigator = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel:
        barrierLabel ??
        MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: barrierColor ?? Colors.black54,
    transitionDuration: const Duration(milliseconds: 350),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // Scrim fade animation
      final scrimAnimation = CurvedAnimation(
        parent: animation,
        curve: M3EMotion.standard,
      );

      // Drawer slide animation with gentle spring
      final slideAnimation = CurvedAnimation(
        parent: animation,
        curve: M3EMotion.gentleSpring.toCurve(),
      );

      return Stack(
        children: [
          // Scrim
          FadeTransition(
            opacity: scrimAnimation,
            child: GestureDetector(
              onTap: barrierDismissible
                  ? () => Navigator.of(context).pop()
                  : null,
              child: Container(color: Colors.transparent),
            ),
          ),
          // Drawer
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0), // Slide from left
              end: Offset.zero,
            ).animate(slideAnimation),
            child: Align(alignment: Alignment.centerLeft, child: child),
          ),
        ],
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return builder(context);
    },
    useRootNavigator: useRootNavigator,
  );
}

/// Helper extension to convert SpringDescription to Curve
extension on SpringDescription {
  Curve toCurve() {
    // For most cases, we'll use the emphasized curve as a close approximation
    // Real spring physics would require a custom Curve implementation
    return M3EMotion.emphasized;
  }
}

/// Navigation Drawer Divider
///
/// A divider for separating sections in the navigation drawer.
/// Follows M3E specifications: 1dp height with 8dp vertical margins.
///
/// Example usage:
///
/// ```dart
/// NavigationDrawerM3E(
///   destinations: [
///     // Main navigation items
///     NavigationDrawerDestinationM3E(...),
///     NavigationDrawerDestinationM3E(...),
///
///     // Divider
///     NavigationDrawerDividerM3E(),
///
///     // Secondary items
///     NavigationDrawerDestinationM3E(...),
///   ],
/// )
/// ```
class NavigationDrawerDividerM3E extends StatelessWidget {
  /// The color of the divider.
  ///
  /// Defaults to [ColorScheme.outlineVariant].
  final Color? color;

  /// The thickness of the divider.
  ///
  /// Defaults to 1.0 (M3E spec).
  final double thickness;

  /// The vertical margin around the divider.
  ///
  /// Defaults to 8.0 (M3E spec).
  final double margin;

  /// Creates a navigation drawer divider.
  const NavigationDrawerDividerM3E({
    super.key,
    this.color,
    this.thickness = 1.0,
    this.margin = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 28.0, // Match item padding
        vertical: margin,
      ),
      child: Divider(
        color: color ?? Theme.of(context).colorScheme.outlineVariant,
        thickness: thickness,
        height: 0,
      ),
    );
  }
}

/// Navigation Drawer Section Header
///
/// A text header for labeling sections in the navigation drawer.
///
/// Example usage:
///
/// ```dart
/// NavigationDrawerM3E(
///   destinations: [
///     NavigationDrawerSectionHeaderM3E(label: 'Main'),
///     NavigationDrawerDestinationM3E(...),
///     NavigationDrawerDestinationM3E(...),
///
///     NavigationDrawerDividerM3E(),
///
///     NavigationDrawerSectionHeaderM3E(label: 'Settings'),
///     NavigationDrawerDestinationM3E(...),
///   ],
/// )
/// ```
class NavigationDrawerSectionHeaderM3E extends StatelessWidget {
  /// The label text for the section header.
  final String label;

  /// The color of the label text.
  ///
  /// Defaults to [ColorScheme.onSurfaceVariant].
  final Color? color;

  /// Creates a navigation drawer section header.
  const NavigationDrawerSectionHeaderM3E({
    super.key,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        28.0, // Match item padding
        16.0, // Top margin
        28.0, // Match item padding
        8.0, // Bottom margin
      ),
      child: Text(
        label,
        style: textTheme.titleSmall?.copyWith(
          color: color ?? colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/motion.dart';
import '../theme/state_layers.dart';
import '../theme/spacing.dart';
import '../components/communication_m3e.dart';

/// Navigation Rail Destination
///
/// Represents a single destination in the navigation rail.
class NavigationRailDestinationM3E {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final int? badgeCount;
  final String? badgeLabel;

  const NavigationRailDestinationM3E({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.badgeCount,
    this.badgeLabel,
  });
}

/// Navigation Rail M3E
///
/// A navigation rail component for tablet/desktop layouts with collapsible behavior.
/// Features:
/// - Collapsible to icon-only mode
/// - Smooth expand/collapse animations
/// - Badge support
/// - Hover and selection states
/// - M3E expressive animations
class NavigationRailM3E extends StatefulWidget {
  /// Current selected index
  final int selectedIndex;

  /// Callback when destination is selected
  final ValueChanged<int> onDestinationSelected;

  /// List of destinations
  final List<NavigationRailDestinationM3E> destinations;

  /// Whether the rail is extended (showing labels)
  final bool extended;

  /// Callback when extended state changes
  final ValueChanged<bool>? onExtendedChanged;

  /// Leading widget (typically FAB or logo)
  final Widget? leading;

  /// Trailing widget (typically settings or profile)
  final Widget? trailing;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom selected color
  final Color? selectedColor;

  /// Custom unselected color
  final Color? unselectedColor;

  /// Whether to show labels when collapsed
  final bool showLabelsWhenCollapsed;

  const NavigationRailM3E({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.extended = true,
    this.onExtendedChanged,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.showLabelsWhenCollapsed = false,
  });

  @override
  State<NavigationRailM3E> createState() => _NavigationRailM3EState();
}

class _NavigationRailM3EState extends State<NavigationRailM3E>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late AnimationController _selectionController;
  late Animation<double> _expandAnimation;
  late Animation<double> _widthAnimation;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();

    _expandController = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium4),
      vsync: this,
    );

    _selectionController = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: M3EMotion.emphasizedDecelerate,
    );

    _widthAnimation = Tween<double>(
      begin: 80.0, // Collapsed width
      end: 256.0, // Expanded width
    ).animate(_expandAnimation);

    if (widget.extended) {
      _expandController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(NavigationRailM3E oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.extended != oldWidget.extended) {
      if (widget.extended) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    }
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _selectionController.reset();
      _selectionController.forward();
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    _selectionController.dispose();
    super.dispose();
  }

  void _handleDestinationTap(int index) {
    widget.onDestinationSelected(index);
  }

  void _toggleExtended() {
    final newExtended = !widget.extended;
    widget.onExtendedChanged?.call(newExtended);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = widget.backgroundColor ?? colorScheme.surface;
    final selectedColor = widget.selectedColor ?? colorScheme.primary;
    final unselectedColor = widget.unselectedColor ?? colorScheme.onSurfaceVariant;

    return AnimatedBuilder(
      animation: _widthAnimation,
      builder: (context, child) {
        return Container(
          width: _widthAnimation.value,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(
              right: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1.0,
              ),
            ),
          ),
          child: Column(
            children: [
              // Leading widget
              if (widget.leading != null)
                Padding(
                  padding: const EdgeInsets.all(M3ESpacing.sm),
                  child: widget.leading!,
                ),

              // Destinations
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: M3ESpacing.xs),
                  itemCount: widget.destinations.length,
                  itemBuilder: (context, index) {
                    final destination = widget.destinations[index];
                    final isSelected = index == widget.selectedIndex;
                    final isHovered = _hoveredIndex == index;

                    return _NavigationRailDestinationWidget(
                      destination: destination,
                      isSelected: isSelected,
                      isHovered: isHovered,
                      isExtended: widget.extended,
                      showLabelsWhenCollapsed: widget.showLabelsWhenCollapsed,
                      selectedColor: selectedColor,
                      unselectedColor: unselectedColor,
                      backgroundColor: backgroundColor,
                      selectionAnimation: _selectionController,
                      onTap: () => _handleDestinationTap(index),
                      onHover: (value) {
                        setState(() {
                          if (value) {
                            _hoveredIndex = index;
                          } else {
                            _hoveredIndex = null;
                          }
                        });
                      },
                    );
                  },
                ),
              ),

              // Trailing widget
              if (widget.trailing != null)
                Padding(
                  padding: const EdgeInsets.all(M3ESpacing.sm),
                  child: widget.trailing!,
                ),

              // Collapse/Expand button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _toggleExtended,
                  borderRadius: BorderRadius.circular(24.0),
                  child: Container(
                    width: 48.0,
                    height: 48.0,
                    alignment: Alignment.center,
                    child: AnimatedBuilder(
                      animation: _expandAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _expandAnimation.value * 3.14159, // 180 degrees
                          child: Icon(
                            Icons.chevron_left,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavigationRailDestinationWidget extends StatelessWidget {
  final NavigationRailDestinationM3E destination;
  final bool isSelected;
  final bool isHovered;
  final bool isExtended;
  final bool showLabelsWhenCollapsed;
  final Color selectedColor;
  final Color unselectedColor;
  final Color backgroundColor;
  final Animation<double> selectionAnimation;
  final VoidCallback onTap;
  final ValueChanged<bool> onHover;

  const _NavigationRailDestinationWidget({
    required this.destination,
    required this.isSelected,
    required this.isHovered,
    required this.isExtended,
    required this.showLabelsWhenCollapsed,
    required this.selectedColor,
    required this.unselectedColor,
    required this.backgroundColor,
    required this.selectionAnimation,
    required this.onTap,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    final currentColor = isSelected ? selectedColor : unselectedColor;

    Widget iconWidget = Icon(
      isSelected && destination.selectedIcon != null
          ? destination.selectedIcon!
          : destination.icon,
      size: 24.0,
      color: currentColor,
    );

    // Wrap with badge if needed
    if (destination.badgeCount != null || destination.badgeLabel != null) {
      iconWidget = BadgeM3E(
        count: destination.badgeCount,
        label: destination.badgeLabel,
        show: true,
        child: iconWidget,
      );
    }

    return AnimatedBuilder(
      animation: selectionAnimation,
      builder: (context, child) {
        final selectionProgress = isSelected ? selectionAnimation.value : 0.0;

        return MouseRegion(
          onEnter: (_) => onHover(true),
          onExit: (_) => onHover(false),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(28.0),
              overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.pressed)) {
                  return M3EStateLayer.getPressColor(currentColor);
                }
                if (states.contains(WidgetState.hovered)) {
                  return M3EStateLayer.getHoverColor(currentColor);
                }
                return null;
              }),
              child: Container(
                height: 56.0,
                padding: EdgeInsets.symmetric(
                  horizontal: isExtended ? M3ESpacing.md : M3ESpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? selectedColor.withValues(alpha: (0.12 * selectionProgress).clamp(0.0, 1.0))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(28.0),
                ),
                child: Row(
                  children: [
                    iconWidget,
                    if (isExtended || showLabelsWhenCollapsed) ...[
                      const SizedBox(width: M3ESpacing.sm),
                      Expanded(
                        child: AnimatedOpacity(
                          opacity: isExtended ? 1.0 : 0.0,
                          duration: M3EMotion.getDuration(M3EMotion.medium3),
                          child: Text(
                            destination.label,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: currentColor,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


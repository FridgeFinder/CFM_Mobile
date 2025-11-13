import 'package:flutter/material.dart';
import '../theme/motion.dart';
import '../theme/shape_morph.dart';
import '../theme/elevation.dart';

/// Enhanced Navigation Bar with pill morph, icon bounce, and smooth sliding indicator
///
/// Features:
/// - Fixed button positions (no layout shift)
/// - Sliding pill indicator with smooth morph animation
/// - Icon bounce on selection with spring physics
/// - Expressive animations following M3E guidelines
class NavigationBarEnhancedM3E extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  final Color? backgroundColor;
  final double? elevation;
  final double? height;
  final Color? indicatorColor;

  const NavigationBarEnhancedM3E({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.backgroundColor,
    this.elevation,
    this.height,
    this.indicatorColor,
  });

  @override
  State<NavigationBarEnhancedM3E> createState() =>
      _NavigationBarEnhancedM3EState();
}

class _NavigationBarEnhancedM3EState extends State<NavigationBarEnhancedM3E>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _iconBounceController;
  late AnimationController _morphController;
  late Animation<double> _slideAnimation;
  late Animation<double> _iconBounceAnimation;
  late Animation<BorderRadius> _pillMorphAnimation;
  int _previousIndex = 0;
  final Map<int, GlobalKey> _destinationKeys = {};

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.selectedIndex;

    // Initialize keys for each destination
    for (int i = 0; i < widget.destinations.length; i++) {
      _destinationKeys[i] = GlobalKey();
    }

    // Slide animation controller - longer duration for smooth movement
    _slideController = AnimationController(
      duration: M3EMotion.getDuration(
        M3EMotion.long2,
      ), // 500ms for smooth slide
      vsync: this,
    );

    // Icon bounce animation controller - longer duration for more noticeable bounce
    _iconBounceController = AnimationController(
      duration: M3EMotion.getDuration(
        M3EMotion.long2,
      ), // 300ms for more expressive bounce
      vsync: this,
    );

    // Morph animation controller - for pill shape transition
    _morphController = AnimationController(
      duration: M3EMotion.getDuration(
        M3EMotion.medium4,
      ), // 400ms for smoother morph
      vsync: this,
    );

    // Slide animation with spring physics
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: M3EMotion.expressiveDefaultOvershoot,
    );

    // Icon bounce animation with smooth elastic bounce
    _iconBounceAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconBounceController,
        curve: Curves.elasticOut,
      ),
    );

    // Pill morph animation - rounded to pill with spring
    _pillMorphAnimation = ShapeMorph.createMorph(
      controller: _morphController,
      startType: ShapeType.rounded,
      endType: ShapeType.pill,
      customRadius: 20.0,
    );

    // Start animations
    _slideController.forward();
    _morphController.forward();
  }

  @override
  void didUpdateWidget(NavigationBarEnhancedM3E oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _previousIndex = oldWidget.selectedIndex;
      // Trigger icon bounce for new selection
      _iconBounceController.reset();
      _iconBounceController.forward();
      // Restart slide animation
      _slideController.reset();
      _slideController.forward();
      // Restart morph animation
      _morphController.reset();
      _morphController.forward();
    }
  }

  void _handleDestinationTap(int index) {
    // Trigger animations immediately on tap
    if (index != widget.selectedIndex) {
      _iconBounceController.reset();
      _iconBounceController.forward();
      _slideController.reset();
      _slideController.forward();
      _morphController.reset();
      _morphController.forward();
    }
    widget.onDestinationSelected(index);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _iconBounceController.dispose();
    _morphController.dispose();
    super.dispose();
  }

  double _getDestinationXPosition(int index, double totalWidth) {
    // Calculate center X position of each destination
    final destinationWidth = totalWidth / widget.destinations.length;
    return (index * destinationWidth) + (destinationWidth / 2);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveHeight = widget.height ?? 100.0;
    final effectiveElevation = widget.elevation ?? M3EElevation.level1;
    final effectiveBackgroundColor =
        widget.backgroundColor ?? colorScheme.surface;
    final effectiveIndicatorColor =
        widget.indicatorColor ?? colorScheme.secondaryContainer;

    final surfaceWithTint = M3EElevation.applySurfaceTint(
      surface: effectiveBackgroundColor,
      surfaceTint: colorScheme.primary,
      elevation: effectiveElevation,
    );

    return Container(
      height: effectiveHeight,
      decoration: BoxDecoration(
        color: surfaceWithTint,
        boxShadow: M3EElevation.getShadow(effectiveElevation),
      ),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final indicatorCenterX = _getDestinationXPosition(
              widget.selectedIndex,
              totalWidth,
            );
            final previousIndicatorCenterX = _getDestinationXPosition(
              _previousIndex,
              totalWidth,
            );

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Sliding pill indicator - positioned absolutely behind icons
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _slideAnimation,
                    _pillMorphAnimation,
                  ]),
                  builder: (context, child) {
                    // Interpolate X position smoothly with spring physics
                    final currentX = Tween<double>(
                      begin: previousIndicatorCenterX,
                      end: indicatorCenterX,
                    ).evaluate(_slideAnimation);

                    return Positioned(
                      left: currentX - 28, // Center the 56dp wide pill
                      top: 8,
                      child: Container(
                        width: 56,
                        height: 32,
                        decoration: BoxDecoration(
                          color: effectiveIndicatorColor,
                          borderRadius: _pillMorphAnimation.value,
                        ),
                      ),
                    );
                  },
                ),
                // Navigation destinations - fixed positions (rendered on top)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: widget.destinations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final destination = entry.value;
                    final isSelected = index == widget.selectedIndex;

                    return Expanded(
                      flex: 1,
                      child: _NavigationDestination(
                        key: _destinationKeys[index],
                        destination: destination,
                        isSelected: isSelected,
                        iconBounceAnimation: isSelected
                            ? _iconBounceAnimation
                            : null,
                        onTap: () => _handleDestinationTap(index),
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Navigation destination with fixed layout - icon always in same position
class _NavigationDestination extends StatelessWidget {
  final NavigationDestination destination;
  final bool isSelected;
  final Animation<double>? iconBounceAnimation;
  final VoidCallback onTap;

  const _NavigationDestination({
    super.key,
    required this.destination,
    required this.isSelected,
    this.iconBounceAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 4, left: 4, right: 4),
        constraints: const BoxConstraints(minHeight: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container - fixed size to prevent layout shift
            SizedBox(
              width: 56,
              height: 32,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Icon with bounce animation
                  if (iconBounceAnimation != null && isSelected)
                    AnimatedBuilder(
                      animation: iconBounceAnimation!,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: iconBounceAnimation!.value,
                          child: IconTheme(
                            data: IconThemeData(
                              size: 24,
                              color: colorScheme.onSecondaryContainer,
                            ),
                            child: destination.selectedIcon ?? destination.icon,
                          ),
                        );
                      },
                    )
                  else
                    IconTheme(
                      data: IconThemeData(
                        size: 24,
                        color: isSelected
                            ? colorScheme.onSecondaryContainer
                            : colorScheme.onSurfaceVariant,
                      ),
                      child: isSelected
                          ? (destination.selectedIcon ?? destination.icon)
                          : destination.icon,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Label - always shown with flexible constraints
            Flexible(
              child: Text(
                destination.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge with pulse animation
class BadgePulseM3E extends StatefulWidget {
  final Widget child;
  final int? count;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showWhenZero;

  const BadgePulseM3E({
    super.key,
    required this.child,
    this.count,
    this.backgroundColor,
    this.textColor,
    this.showWhenZero = false,
  });

  @override
  State<BadgePulseM3E> createState() => _BadgePulseM3EState();
}

class _BadgePulseM3EState extends State<BadgePulseM3E>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int? _previousCount;

  @override
  void initState() {
    super.initState();
    _previousCount = widget.count;

    _pulseController = AnimationController(
      duration: M3EMotion.getDuration(
        M3EMotion.medium4,
      ), // 400ms for more noticeable pulse
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: M3EMotion.expressiveDefaultOvershoot,
      ),
    );

    if (widget.count != null && widget.count! > 0) {
      _pulseController.forward();
    }
  }

  @override
  void didUpdateWidget(BadgePulseM3E oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count &&
        widget.count != null &&
        widget.count! > 0) {
      if (_previousCount != widget.count) {
        _pulseController.reset();
        _pulseController.forward();
        _previousCount = widget.count;
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final showBadge =
        widget.count != null && (widget.count! > 0 || widget.showWhenZero);

    if (!showBadge) {
      return widget.child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        Positioned(
          top: -4,
          right: -4,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      widget.count! > 99 ? '99+' : '${widget.count}',
                      style: TextStyle(
                        color: widget.textColor ?? colorScheme.onError,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

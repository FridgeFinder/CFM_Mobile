import 'package:flutter/material.dart';
import '../theme/motion.dart';
import '../theme/spacing.dart';
import '../theme/shapes.dart';

/// M3E Tab Bar Component
///
/// Material 3 Expressive tabs with indicator morphing and spring animations.
///
/// Features:
/// - Primary and secondary variants
/// - Sliding indicator with morph animation
/// - Spring-based tab switching
/// - Fixed and scrollable layouts
/// - Icon and label support
class TabsM3E extends StatefulWidget {
  /// List of tab items
  final List<TabItemM3E> tabs;

  /// Currently selected tab index
  final int selectedIndex;

  /// Callback when tab is selected
  final ValueChanged<int>? onTabSelected;

  /// Tab bar variant (primary or secondary)
  final TabVariant variant;

  /// Whether tabs are scrollable (for many tabs)
  final bool isScrollable;

  /// Custom indicator color
  final Color? indicatorColor;

  /// Custom label color
  final Color? labelColor;

  /// Custom unselected label color
  final Color? unselectedLabelColor;

  const TabsM3E({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    this.onTabSelected,
    this.variant = TabVariant.primary,
    this.isScrollable = false,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
  }) : assert(selectedIndex >= 0 && selectedIndex < tabs.length);

  @override
  State<TabsM3E> createState() => _TabsM3EState();
}

class _TabsM3EState extends State<TabsM3E>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnimation;
  late List<GlobalKey> _tabKeys;

  @override
  void initState() {
    super.initState();
    _tabKeys = List.generate(
      widget.tabs.length,
      (index) => GlobalKey(),
    );

    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.selectedIndex,
    );

    _indicatorController = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium4),
      vsync: this,
    );

    _indicatorAnimation = CurvedAnimation(
      parent: _indicatorController,
      curve: M3EMotion.expressiveDefaultOvershoot,
    );

    _tabController.addListener(_onTabChanged);
    _indicatorController.forward();
  }

  @override
  void didUpdateWidget(TabsM3E oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _tabController.animateTo(widget.selectedIndex);
      _indicatorController.reset();
      _indicatorController.forward();
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _indicatorController.reset();
      _indicatorController.forward();
    }
    widget.onTabSelected?.call(_tabController.index);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _indicatorController.dispose();
    super.dispose();
  }

  double _getTabWidth(int index) {
    final context = _tabKeys[index].currentContext;
    if (context == null) return 0.0;
    final box = context.findRenderObject() as RenderBox?;
    return box?.size.width ?? 0.0;
  }

  double _getTabXPosition(int index) {
    double x = 0.0;
    for (int i = 0; i < index; i++) {
      x += _getTabWidth(i);
    }
    return x;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final indicatorColor = widget.indicatorColor ??
        (widget.variant == TabVariant.primary
            ? colorScheme.primary
            : colorScheme.secondary);
    final labelColor = widget.labelColor ??
        (widget.variant == TabVariant.primary
            ? colorScheme.onSurface
            : colorScheme.onSurfaceVariant);
    final unselectedLabelColor = widget.unselectedLabelColor ??
        colorScheme.onSurfaceVariant;

    return Container(
      height: widget.variant == TabVariant.primary ? 48.0 : 40.0,
      decoration: BoxDecoration(
        color: widget.variant == TabVariant.primary
            ? Colors.transparent
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(M3EShapes.medium),
      ),
      child: Stack(
        children: [
          // Sliding indicator
          AnimatedBuilder(
            animation: Listenable.merge([_tabController, _indicatorAnimation]),
            builder: (context, child) {
              final selectedIndex = _tabController.index;
              final previousIndex = _tabController.previousIndex;
              final animationValue = _tabController.animation?.value ?? 0.0;

              // Interpolate position
              final currentX = _getTabXPosition(selectedIndex);
              final previousX = _getTabXPosition(previousIndex);
              final currentWidth = _getTabWidth(selectedIndex);
              final previousWidth = _getTabWidth(previousIndex);

              final x = (currentX * animationValue + previousX * (1 - animationValue));
              final width = (currentWidth * animationValue + previousWidth * (1 - animationValue));

              return Positioned(
                left: x,
                top: widget.variant == TabVariant.primary ? 40.0 : 36.0,
                child: Container(
                  width: width,
                  height: widget.variant == TabVariant.primary ? 3.0 : 2.0,
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              );
            },
          ),
          // Tabs
          TabBar(
            controller: _tabController,
            isScrollable: widget.isScrollable,
            indicator: const BoxDecoration(),
            dividerColor: Colors.transparent,
            labelColor: labelColor,
            unselectedLabelColor: unselectedLabelColor,
            labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            tabs: widget.tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              return Tab(
                key: _tabKeys[index],
                icon: tab.icon,
                text: tab.label,
                iconMargin: const EdgeInsets.only(bottom: M3ESpacing.xxs),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Tab item data
class TabItemM3E {
  final String label;
  final Widget? icon;

  const TabItemM3E({
    required this.label,
    this.icon,
  });
}

/// Tab bar variant
enum TabVariant {
  primary,
  secondary,
}


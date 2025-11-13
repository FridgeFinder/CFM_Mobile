import 'package:flutter/material.dart';
import '../theme/motion.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../theme/elevation.dart';
import 'top_app_bar_m3e.dart';

/// Collapsing App Bar M3E
///
/// An app bar that collapses and morphs its title as the user scrolls.
///
/// Features:
/// - Title morphs from large to small as user scrolls
/// - Elevation increases on scroll
/// - Smooth spring-based animations
/// - Height transitions from large/medium to small
class CollapsingAppBarM3E extends StatefulWidget implements PreferredSizeWidget {
  /// The title widget
  final Widget title;

  /// Leading widget (typically back button)
  final Widget? leading;

  /// Action widgets
  final List<Widget>? actions;

  /// Initial app bar size (collapses to small)
  final TopAppBarSizeM3E initialSize;

  /// Scroll controller to listen to
  final ScrollController scrollController;

  /// Threshold offset for collapse animation
  final double collapseThreshold;

  /// Background color
  final Color? backgroundColor;

  /// Foreground color
  final Color? foregroundColor;

  const CollapsingAppBarM3E({
    super.key,
    required this.title,
    required this.scrollController,
    this.leading,
    this.actions,
    this.initialSize = TopAppBarSizeM3E.large,
    this.collapseThreshold = 100.0,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Size get preferredSize {
    return Size.fromHeight(getHeightForSize(TopAppBarSizeM3E.small));
  }

  static double getHeightForSize(TopAppBarSizeM3E size) {
    switch (size) {
      case TopAppBarSizeM3E.small:
        return 64.0;
      case TopAppBarSizeM3E.medium:
        return 112.0;
      case TopAppBarSizeM3E.large:
        return 152.0;
    }
  }

  @override
  State<CollapsingAppBarM3E> createState() => _CollapsingAppBarM3EState();
}

class _CollapsingAppBarM3EState extends State<CollapsingAppBarM3E>
    with TickerProviderStateMixin {
  late AnimationController _collapseController;
  late AnimationController _elevationController;
  late Animation<double> _collapseAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _titleScaleAnimation;

  @override
  void initState() {
    super.initState();

    _collapseController = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium4),
      vsync: this,
    );

    _elevationController = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium4),
      vsync: this,
    );

    _collapseAnimation = CurvedAnimation(
      parent: _collapseController,
      curve: M3EMotion.emphasizedDecelerate,
    );

    _elevationAnimation = Tween<double>(
      begin: M3EElevation.appBarDefault,
      end: M3EElevation.appBarScrolled,
    ).animate(CurvedAnimation(
      parent: _elevationController,
      curve: M3EMotion.emphasizedDecelerate,
    ));

    _titleScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(_collapseAnimation);

    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _collapseController.dispose();
    _elevationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = widget.scrollController.offset;
    final progress = (offset / widget.collapseThreshold).clamp(0.0, 1.0);

    _collapseController.value = progress;
    if (offset > widget.collapseThreshold) {
      _elevationController.forward();
    } else {
      _elevationController.reverse();
    }
  }

  double _getCurrentHeight() {
    final initialHeight = CollapsingAppBarM3E.getHeightForSize(widget.initialSize);
    final smallHeight = CollapsingAppBarM3E.getHeightForSize(TopAppBarSizeM3E.small);
    return initialHeight - (initialHeight - smallHeight) * _collapseAnimation.value;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: Listenable.merge([_collapseAnimation, _elevationAnimation]),
      builder: (context, child) {
        final currentHeight = _getCurrentHeight();
        final currentElevation = _elevationAnimation.value;

        return Container(
          height: currentHeight,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? colorScheme.surface,
            boxShadow: M3EElevation.getShadow(currentElevation),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: M3ESpacing.md),
              child: Row(
                children: [
                  // Leading
                  if (widget.leading != null) widget.leading!,
                  // Title with scale animation
                  Expanded(
                    child: Center(
                      child: Transform.scale(
                        scale: _titleScaleAnimation.value,
                        child: DefaultTextStyle(
                          style: widget.initialSize == TopAppBarSizeM3E.large
                              ? M3ETypography.headlineMedium
                              : M3ETypography.headlineSmall,
                          child: widget.title,
                        ),
                      ),
                    ),
                  ),
                  // Actions
                  if (widget.actions != null) ...widget.actions!,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Search App Bar M3E
///
/// An app bar variant with integrated search functionality.
class SearchAppBarM3E extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final List<Widget>? actions;
  final String? hintText;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final bool autoFocus;

  const SearchAppBarM3E({
    super.key,
    this.leading,
    this.actions,
    this.hintText,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.autoFocus = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64.0);

  @override
  Widget build(BuildContext context) {
    return TopAppBarM3E(
      leading: leading,
      actions: actions,
      title: TextField(
        autofocus: autoFocus,
        onChanged: onSearchChanged,
        onSubmitted: onSearchSubmitted,
        decoration: InputDecoration(
          hintText: hintText ?? 'Search',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

/// Bottom App Bar M3E
///
/// A bottom app bar variant with FAB cutout support.
class BottomAppBarM3E extends StatelessWidget {
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double? elevation;

  const BottomAppBarM3E({
    super.key,
    this.actions,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveElevation = elevation ?? M3EElevation.level1;

    return Container(
      height: 64.0,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        boxShadow: M3EElevation.getShadow(effectiveElevation),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: actions ?? [],
        ),
      ),
    );
  }
}


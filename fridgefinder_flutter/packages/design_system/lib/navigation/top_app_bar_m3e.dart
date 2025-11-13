import 'package:flutter/material.dart';
import '../theme/elevation.dart';
import '../theme/motion.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// Material 3 Expressive Top App Bar Sizes
///
/// Defines the three size variants for the top app bar:
/// - Small: 64dp height (default) - increased from MD2's 56dp
/// - Medium: 112dp height - provides more vertical space for context
/// - Large: 152dp height - for maximum visual impact and prominence
enum TopAppBarSizeM3E {
  /// Small app bar with 64dp height
  /// Use for: Standard app bars, dense layouts, most screens
  small,

  /// Medium app bar with 112dp height
  /// Use for: Screens that need moderate prominence, can collapse on scroll
  medium,

  /// Large app bar with 152dp height
  /// Use for: Landing pages, top-level destinations, maximum prominence
  large,
}

/// Material 3 Expressive Top App Bar
///
/// A comprehensive implementation of the Material 3 top app bar with M3E styling.
///
/// ## Material 3 Specifications
///
/// ### Size Variants
/// - **Small**: 64dp height (increased from MD2's 56dp) - DEFAULT
/// - **Medium**: 112dp height - provides more vertical space
/// - **Large**: 152dp height - maximum visual impact
///
/// ### Visual Design
/// - No drop shadow in M3 (uses surface tint overlay instead)
/// - Background: surface color with optional surface tint
/// - Title typography:
///   - Small: titleLarge (22sp)
///   - Medium: headlineSmall (24sp)
///   - Large: headlineMedium (28sp)
/// - Leading icon: 48x48dp touch target, 24dp icon, 16dp from start
/// - Actions: 48x48dp each, 4dp spacing between, 16dp from end
///
/// ### Elevation
/// - Default: level 0 (no elevation)
/// - Scrolled: level 2 (subtle surface tint)
/// - Transition: Gentle spring animation when scrolling past threshold
///
/// ### Animations
/// - Scroll elevation change: 300ms with gentle spring curve
/// - Collapse (medium/large): Title size and position transition as user scrolls
///
/// ## Usage Examples
///
/// ### Basic Small App Bar (Default)
/// ```dart
/// TopAppBarM3E(
///   title: const Text('Screen Title'),
///   leading: IconButton(
///     icon: const Icon(Icons.menu),
///     onPressed: () {},
///   ),
///   actions: [
///     IconButton(
///       icon: const Icon(Icons.search),
///       onPressed: () {},
///     ),
///     IconButton(
///       icon: const Icon(Icons.more_vert),
///       onPressed: () {},
///     ),
///   ],
/// )
/// ```
///
/// ### Medium App Bar with Center Title
/// ```dart
/// TopAppBarM3E(
///   title: const Text('Profile'),
///   size: TopAppBarSizeM3E.medium,
///   centerTitle: true,
///   leading: IconButton(
///     icon: const Icon(Icons.arrow_back),
///     onPressed: () => Navigator.pop(context),
///   ),
/// )
/// ```
///
/// ### Large App Bar with Custom Colors
/// ```dart
/// TopAppBarM3E(
///   title: const Text('Welcome'),
///   size: TopAppBarSizeM3E.large,
///   backgroundColor: Theme.of(context).colorScheme.primaryContainer,
///   foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
///   actions: [
///     IconButton(
///       icon: const Icon(Icons.settings),
///       onPressed: () {},
///     ),
///   ],
/// )
/// ```
///
/// ### App Bar with Elevated State
/// ```dart
/// TopAppBarM3E(
///   title: const Text('Scrolled Content'),
///   elevation: M3EElevation.appBarScrolled, // 3.0
///   surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
/// )
/// ```
///
/// ### App Bar with Custom Title Style
/// ```dart
/// TopAppBarM3E(
///   title: Text(
///     'Custom Styled',
///     style: M3ETypography.headlineSmall.copyWith(
///       fontWeight: FontWeight.w600,
///     ),
///   ),
///   size: TopAppBarSizeM3E.medium,
/// )
/// ```
///
/// ### Using in Scaffold
/// ```dart
/// Scaffold(
///   appBar: TopAppBarM3E(
///     title: const Text('My App'),
///     leading: IconButton(
///       icon: const Icon(Icons.menu),
///       onPressed: () {
///         Scaffold.of(context).openDrawer();
///       },
///     ),
///   ),
///   body: ListView.builder(
///     // Your scrollable content
///   ),
/// )
/// ```
///
/// ### With Scroll Controller for Dynamic Elevation
/// ```dart
/// class MyScreen extends StatefulWidget {
///   @override
///   State<MyScreen> createState() => _MyScreenState();
/// }
///
/// class _MyScreenState extends State<MyScreen> {
///   final _scrollController = ScrollController();
///   bool _isScrolled = false;
///
///   @override
///   void initState() {
///     super.initState();
///     _scrollController.addListener(_onScroll);
///   }
///
///   void _onScroll() {
///     final isScrolled = _scrollController.offset > 0;
///     if (isScrolled != _isScrolled) {
///       setState(() => _isScrolled = isScrolled);
///     }
///   }
///
///   @override
///   void dispose() {
///     _scrollController.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: TopAppBarM3E(
///         title: const Text('Dynamic Elevation'),
///         elevation: _isScrolled ? M3EElevation.appBarScrolled : M3EElevation.appBarDefault,
///         surfaceTintColor: _isScrolled ? Theme.of(context).colorScheme.surfaceTint : null,
///       ),
///       body: ListView.builder(
///         controller: _scrollController,
///         itemCount: 50,
///         itemBuilder: (context, index) => ListTile(
///           title: Text('Item $index'),
///         ),
///       ),
///     );
///   }
/// }
/// ```
///
/// ### App Bar Without Back Button (Automatic Leading)
/// ```dart
/// // If there's a previous route, back button appears automatically
/// TopAppBarM3E(
///   title: const Text('Detail Screen'),
///   automaticallyImplyLeading: true, // default
/// )
/// ```
///
/// ### App Bar with No Leading Widget
/// ```dart
/// TopAppBarM3E(
///   title: const Text('Home'),
///   automaticallyImplyLeading: false,
///   actions: [
///     IconButton(
///       icon: const Icon(Icons.notifications),
///       onPressed: () {},
///     ),
///   ],
/// )
/// ```
///
/// ## Accessibility
///
/// The component provides built-in accessibility features:
/// - Proper semantic labels for screen readers
/// - Touch targets meet minimum 48x48dp requirement
/// - High contrast support through color scheme
/// - Focus indicators for keyboard navigation
///
/// ## Best Practices
///
/// 1. **Title Length**: Keep titles concise (1-2 words). For longer titles, consider:
///    - Using a medium or large app bar for more space
///    - Breaking into title and subtitle
///    - Using overflow ellipsis
///
/// 2. **Actions**: Limit to 2-3 actions for optimal usability
///    - Most important action on the right
///    - Consider using a menu for additional actions
///
/// 3. **Elevation**: Use elevation sparingly
///    - Default (0) for most cases
///    - Level 2 only when content scrolls behind app bar
///    - Avoid constant elevation unless needed for visual hierarchy
///
/// 4. **Size Selection**:
///    - Small: Standard screens, list views, detail pages
///    - Medium: Screens needing moderate prominence, profile pages
///    - Large: Landing pages, top-level destinations only
///
/// 5. **Center Title**: In Material 3, center-aligned titles are default
///    - Use centerTitle: true for balanced layouts
///    - Use centerTitle: false for left-aligned (platform-specific preference)
///
/// ## Migration from Material 2
///
/// Key differences from MD2's AppBar:
/// - Height increased from 56dp to 64dp (small variant)
/// - No drop shadow by default (use surface tint instead)
/// - Title typography is larger and more prominent
/// - Spacing and padding adjusted to M3 specifications
/// - New medium and large size variants available
class TopAppBarM3E extends StatelessWidget implements PreferredSizeWidget {
  /// The primary content of the app bar, typically a [Text] widget
  final Widget? title;

  /// A widget to display before the [title]
  ///
  /// Typically an [IconButton] or [BackButton].
  /// If null and [automaticallyImplyLeading] is true, an appropriate button
  /// will be created automatically (e.g., back button if there's a previous route).
  final Widget? leading;

  /// A list of widgets to display in a row after the [title]
  ///
  /// Typically [IconButton] widgets representing common actions.
  /// Limited to 2-3 actions for optimal usability.
  final List<Widget>? actions;

  /// Whether the title should be centered
  ///
  /// Defaults to true, following Material 3 guidelines.
  /// Set to false for platform-specific behavior (e.g., left-aligned on iOS).
  final bool centerTitle;

  /// The size variant of the app bar
  ///
  /// - [TopAppBarSizeM3E.small]: 64dp height (default)
  /// - [TopAppBarSizeM3E.medium]: 112dp height
  /// - [TopAppBarSizeM3E.large]: 152dp height
  final TopAppBarSizeM3E size;

  /// The background color of the app bar
  ///
  /// If null, defaults to [ColorScheme.surface].
  /// In M3, app bars use the surface color with optional surface tint overlay.
  final Color? backgroundColor;

  /// The color of text and icons in the app bar
  ///
  /// If null, defaults to [ColorScheme.onSurface].
  final Color? foregroundColor;

  /// The elevation of the app bar
  ///
  /// Material 3 uses tonal elevation overlays instead of shadows.
  /// - Default: [M3EElevation.appBarDefault] (0.0)
  /// - Scrolled: [M3EElevation.appBarScrolled] (3.0)
  ///
  /// Higher elevation adds a subtle tint of the surface tint color.
  final double? elevation;

  /// The color of the surface tint overlay
  ///
  /// In M3, elevation is indicated by a tonal overlay of this color.
  /// If null, uses [ColorScheme.surfaceTint].
  final Color? surfaceTintColor;

  /// The color of the shadow below the app bar
  ///
  /// Material 3 typically uses surface tint instead of shadows.
  /// This is provided for cases where shadows are explicitly needed.
  final Color? shadowColor;

  /// Controls whether we should try to imply the leading widget if null
  ///
  /// If true and [leading] is null, automatically creates:
  /// - Back button if Navigator can pop
  /// - Menu button if there's a Drawer
  ///
  /// Defaults to true.
  final bool automaticallyImplyLeading;

  /// Optional custom title text style
  ///
  /// If null, uses the appropriate M3E typography style:
  /// - Small: [M3ETypography.titleLarge] (22sp)
  /// - Medium: [M3ETypography.headlineSmall] (24sp)
  /// - Large: [M3ETypography.headlineMedium] (28sp)
  final TextStyle? titleTextStyle;

  /// Optional custom style for action icon buttons
  final IconThemeData? actionsIconTheme;

  /// Optional custom style for the leading icon button
  final IconThemeData? iconTheme;

  /// Optional widget to display at the bottom of the app bar
  ///
  /// Typically a [TabBar]. The height of the bottom widget is added to
  /// the [preferredSize].
  final PreferredSizeWidget? bottom;

  /// Whether this app bar is being displayed at the top of the screen
  ///
  /// If true, the app bar's padding is increased by the status bar height.
  /// Defaults to true.
  final bool primary;

  /// Defines the app bar's shape
  ///
  /// Material 3 typically uses no shape (rectangular), but this can be
  /// customized for specific designs.
  final ShapeBorder? shape;

  /// The color of the status bar icons (light or dark)
  ///
  /// Material 3 automatically determines this based on background color.
  final Brightness? systemOverlayStyle;

  /// Custom padding for the toolbar content
  ///
  /// If null, uses M3 default spacing:
  /// - Horizontal: 4dp
  /// - Leading icon: 16dp from start
  /// - Actions: 16dp from end
  final EdgeInsetsGeometry? toolbarPadding;

  /// The height of the toolbar component
  ///
  /// If null, uses the appropriate height based on [size]:
  /// - Small: 64dp
  /// - Medium: 112dp
  /// - Large: 152dp
  final double? toolbarHeight;

  /// Controls whether the toolbar should scroll under the app bar
  ///
  /// When false, the app bar remains fixed and content scrolls behind it.
  /// When true, the app bar scrolls with the content.
  final bool? forceMaterialTransparency;

  /// Defines the visual properties of the toolbar overflow menu
  final Color? toolbarTextStyle;

  /// The z-coordinate at which to place this app bar when scrolling
  final double? scrolledUnderElevation;

  const TopAppBarM3E({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.size = TopAppBarSizeM3E.small,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.surfaceTintColor,
    this.shadowColor,
    this.automaticallyImplyLeading = true,
    this.titleTextStyle,
    this.actionsIconTheme,
    this.iconTheme,
    this.bottom,
    this.primary = true,
    this.shape,
    this.systemOverlayStyle,
    this.toolbarPadding,
    this.toolbarHeight,
    this.forceMaterialTransparency,
    this.toolbarTextStyle,
    this.scrolledUnderElevation,
  });

  @override
  Size get preferredSize {
    final height = _getHeightForSize(size);
    final bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(height + bottomHeight);
  }

  /// Returns the appropriate height for the given size variant
  static double _getHeightForSize(TopAppBarSizeM3E size) {
    switch (size) {
      case TopAppBarSizeM3E.small:
        return 64.0; // M3 standard (increased from MD2's 56dp)
      case TopAppBarSizeM3E.medium:
        return 112.0; // M3 medium variant
      case TopAppBarSizeM3E.large:
        return 152.0; // M3 large variant
    }
  }

  /// Returns the appropriate title text style for the given size variant
  TextStyle _getTitleTextStyleForSize(BuildContext context, TopAppBarSizeM3E size) {
    // If custom style provided, use it
    if (titleTextStyle != null) {
      return titleTextStyle!;
    }

    // Apply foreground color to the appropriate typography style
    final color = foregroundColor ?? Theme.of(context).colorScheme.onSurface;

    switch (size) {
      case TopAppBarSizeM3E.small:
        return M3ETypography.titleLarge.copyWith(color: color);
      case TopAppBarSizeM3E.medium:
        return M3ETypography.headlineSmall.copyWith(color: color);
      case TopAppBarSizeM3E.large:
        return M3ETypography.headlineMedium.copyWith(color: color);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine colors
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.surface;
    final effectiveForegroundColor = foregroundColor ?? colorScheme.onSurface;
    final effectiveSurfaceTintColor = surfaceTintColor ?? colorScheme.surfaceTint;

    // Determine elevation
    final effectiveElevation = elevation ?? M3EElevation.appBarDefault;

    // Create icon themes
    final effectiveIconTheme = iconTheme ??
        IconThemeData(
          color: effectiveForegroundColor,
          size: 24.0,
        );

    final effectiveActionsIconTheme = actionsIconTheme ??
        IconThemeData(
          color: effectiveForegroundColor,
          size: 24.0,
        );

    // Get title text style
    final effectiveTitleTextStyle = _getTitleTextStyleForSize(context, size);

    // Determine toolbar height
    final effectiveToolbarHeight = toolbarHeight ?? _getHeightForSize(size);

    return AppBar(
      // Content
      title: title,
      leading: leading,
      actions: actions,

      // Layout
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      toolbarHeight: effectiveToolbarHeight,
      bottom: bottom,

      // Styling
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      elevation: effectiveElevation,
      surfaceTintColor: effectiveSurfaceTintColor,
      shadowColor: shadowColor,
      scrolledUnderElevation: scrolledUnderElevation,

      // Typography & Icons
      titleTextStyle: effectiveTitleTextStyle,
      iconTheme: effectiveIconTheme,
      actionsIconTheme: effectiveActionsIconTheme,

      // Layout properties
      primary: primary,
      shape: shape,
      toolbarTextStyle: toolbarTextStyle == null ? null : TextStyle(color: toolbarTextStyle),
      forceMaterialTransparency: forceMaterialTransparency ?? false,

      // Padding - M3 uses minimal horizontal padding (4dp for container)
      // Individual elements have their own spacing
      titleSpacing: centerTitle ? NavigationToolbar.kMiddleSpacing : M3ESpacing.md,
    );
  }
}

/// Animated Top App Bar with Scroll-Based Elevation
///
/// A specialized variant that automatically handles elevation changes
/// based on scroll position. Uses M3E spring animations for smooth,
/// natural transitions.
///
/// ## Usage Example
///
/// ```dart
/// class MyScreen extends StatefulWidget {
///   @override
///   State<MyScreen> createState() => _MyScreenState();
/// }
///
/// class _MyScreenState extends State<MyScreen> {
///   final _scrollController = ScrollController();
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AnimatedTopAppBarM3E(
///         scrollController: _scrollController,
///         title: const Text('Animated AppBar'),
///         actions: [
///           IconButton(
///             icon: const Icon(Icons.search),
///             onPressed: () {},
///           ),
///         ],
///       ),
///       body: ListView.builder(
///         controller: _scrollController,
///         itemCount: 50,
///         itemBuilder: (context, index) => ListTile(
///           title: Text('Item $index'),
///         ),
///       ),
///     );
///   }
/// }
/// ```
class AnimatedTopAppBarM3E extends StatefulWidget implements PreferredSizeWidget {
  /// The scroll controller to listen to for elevation changes
  final ScrollController scrollController;

  /// The threshold offset at which elevation changes
  ///
  /// When the scroll offset exceeds this value, the app bar gains elevation.
  /// Defaults to 0.0 (any scroll triggers elevation).
  final double scrollThreshold;

  /// All other properties from [TopAppBarM3E]
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final TopAppBarSizeM3E size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? surfaceTintColor;
  final Color? shadowColor;
  final bool automaticallyImplyLeading;
  final TextStyle? titleTextStyle;
  final IconThemeData? actionsIconTheme;
  final IconThemeData? iconTheme;
  final PreferredSizeWidget? bottom;
  final bool primary;
  final ShapeBorder? shape;

  const AnimatedTopAppBarM3E({
    super.key,
    required this.scrollController,
    this.scrollThreshold = 0.0,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.size = TopAppBarSizeM3E.small,
    this.backgroundColor,
    this.foregroundColor,
    this.surfaceTintColor,
    this.shadowColor,
    this.automaticallyImplyLeading = true,
    this.titleTextStyle,
    this.actionsIconTheme,
    this.iconTheme,
    this.bottom,
    this.primary = true,
    this.shape,
  });

  @override
  Size get preferredSize {
    final height = TopAppBarM3E._getHeightForSize(size);
    final bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(height + bottomHeight);
  }

  @override
  State<AnimatedTopAppBarM3E> createState() => _AnimatedTopAppBarM3EState();
}

class _AnimatedTopAppBarM3EState extends State<AnimatedTopAppBarM3E>
    with SingleTickerProviderStateMixin {
  late AnimationController _elevationController;
  late Animation<double> _elevationAnimation;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller with M3E motion duration
    _elevationController = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium4), // 400ms for smoother transition
      vsync: this,
    );

    // Create elevation animation with M3E expressive curve
    _elevationAnimation = Tween<double>(
      begin: M3EElevation.appBarDefault,
      end: M3EElevation.appBarScrolled,
    ).animate(CurvedAnimation(
      parent: _elevationController,
      curve: M3EMotion.emphasizedDecelerate,
    ));

    // Listen to scroll changes
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _elevationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isScrolled = widget.scrollController.offset > widget.scrollThreshold;

    if (isScrolled != _isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
        if (_isScrolled) {
          _elevationController.forward();
        } else {
          _elevationController.reverse();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _elevationAnimation,
      builder: (context, child) {
        return TopAppBarM3E(
          title: widget.title,
          leading: widget.leading,
          actions: widget.actions,
          centerTitle: widget.centerTitle,
          size: widget.size,
          backgroundColor: widget.backgroundColor,
          foregroundColor: widget.foregroundColor,
          elevation: _elevationAnimation.value,
          surfaceTintColor: _isScrolled ? widget.surfaceTintColor : null,
          shadowColor: widget.shadowColor,
          automaticallyImplyLeading: widget.automaticallyImplyLeading,
          titleTextStyle: widget.titleTextStyle,
          actionsIconTheme: widget.actionsIconTheme,
          iconTheme: widget.iconTheme,
          bottom: widget.bottom,
          primary: widget.primary,
          shape: widget.shape,
        );
      },
    );
  }
}

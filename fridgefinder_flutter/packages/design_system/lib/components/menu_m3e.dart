import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/elevation.dart';
import '../theme/state_layers.dart';
import '../theme/motion.dart';
import '../theme/shapes.dart';

/// Material 3 Expressive Menu Component
///
/// A dropdown menu that follows M3E specifications with:
/// - Min width: 112dp, Max width: 280dp
/// - Item height: 48dp
/// - Elevation: Level 2
/// - Corner radius: 4dp (extra small)
/// - Cascade animations with staggered entrance
/// - Keyboard navigation support
class MenuM3E extends StatefulWidget {
  /// The items to display in the menu
  final List<MenuItemM3E> items;

  /// Whether the menu is currently open
  final bool isOpen;

  /// Callback when the menu requests to close
  final VoidCallback? onClose;

  /// Optional elevation override (defaults to Level 2)
  final double? elevation;

  /// Optional width constraints
  final BoxConstraints? constraints;

  /// Whether to animate items with stagger effect
  final bool enableStagger;

  /// Whether the menu should animate from the anchor point
  final bool enableCascade;

  const MenuM3E({
    super.key,
    required this.items,
    required this.isOpen,
    this.onClose,
    this.elevation,
    this.constraints,
    this.enableStagger = true,
    this.enableCascade = true,
  });

  @override
  State<MenuM3E> createState() => _MenuM3EState();
}

class _MenuM3EState extends State<MenuM3E>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  int _focusedIndex = -1;

  static const Duration _cascadeDuration = Duration(milliseconds: 400);
  static const Duration _itemStaggerDelay = Duration(milliseconds: 40);
  static const int _maxStaggerItems = 8;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: M3EMotion.getDuration(M3EMotion.medium4), // 400ms for smoother cascade
    );

    // Cascade animation: scale from anchor point
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: M3EMotion.emphasizedDecelerate,
    ));

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    if (widget.isOpen) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(MenuM3E oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
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

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _focusedIndex = (_focusedIndex + 1) % widget.items.length;
      });
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _focusedIndex = _focusedIndex <= 0
            ? widget.items.length - 1
            : _focusedIndex - 1;
      });
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_focusedIndex >= 0 && _focusedIndex < widget.items.length) {
        final item = widget.items[_focusedIndex];
        if (item.onTap != null && !item.disabled) {
          item.onTap!();
        }
      }
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onClose?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Focus(
      onKeyEvent: (node, event) {
        _handleKeyEvent(event);
        return KeyEventResult.handled;
      },
      child: AnimatedBuilder(
        animation: _controller,
        child: Material(
          elevation: widget.elevation ?? M3EElevation.menu,
          shadowColor: colorScheme.shadow,
          surfaceTintColor: colorScheme.surfaceTint,
          color: colorScheme.surface,
          shape: M3EShapes.menu,
          child: ConstrainedBox(
            constraints: widget.constraints ??
                const BoxConstraints(
                  minWidth: 112.0,
                  maxWidth: 280.0,
                ),
            child: IntrinsicWidth(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];

                  // Stagger animation for items
                  if (widget.enableStagger && index < _maxStaggerItems) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: M3EMotion.getDuration(
                        Duration(
                          milliseconds: _cascadeDuration.inMilliseconds +
                              (index * _itemStaggerDelay.inMilliseconds),
                        ),
                      ),
                      curve: M3EMotion.emphasizedDecelerate,
                      child: item.copyWith(
                        isFocused: index == _focusedIndex,
                      ),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 8 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                    );
                  }

                  return item.copyWith(
                    isFocused: index == _focusedIndex,
                  );
                },
              ),
            ),
          ),
        ),
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: Alignment.topLeft,
              child: child,
            ),
          );
        },
      ),
    );
  }
}

/// Material 3 Expressive Menu Item
///
/// Individual menu item with:
/// - Height: 48dp
/// - Padding: 8dp horizontal
/// - Typography: bodyLarge
/// - Leading icon support (24dp)
/// - Trailing widget support
/// - State layers with proper colors
class MenuItemM3E extends StatefulWidget {
  /// The text label for the menu item
  final String? label;

  /// Custom child widget (overrides label)
  final Widget? child;

  /// Leading icon (24dp)
  final IconData? leadingIcon;

  /// Trailing widget (shortcut, checkmark, chevron)
  final Widget? trailing;

  /// Callback when item is tapped
  final VoidCallback? onTap;

  /// Whether the item is disabled
  final bool disabled;

  /// Whether the item is selected/checked
  final bool selected;

  /// Whether the item is focused (keyboard navigation)
  final bool isFocused;

  /// Custom height (defaults to 48dp)
  final double? height;

  /// Custom background color
  final Color? backgroundColor;

  const MenuItemM3E({
    super.key,
    this.label,
    this.child,
    this.leadingIcon,
    this.trailing,
    this.onTap,
    this.disabled = false,
    this.selected = false,
    this.isFocused = false,
    this.height,
    this.backgroundColor,
  }) : assert(label != null || child != null,
            'Either label or child must be provided');

  MenuItemM3E copyWith({
    String? label,
    Widget? child,
    IconData? leadingIcon,
    Widget? trailing,
    VoidCallback? onTap,
    bool? disabled,
    bool? selected,
    bool? isFocused,
    double? height,
    Color? backgroundColor,
  }) {
    return MenuItemM3E(
      key: key,
      label: label ?? this.label,
      leadingIcon: leadingIcon ?? this.leadingIcon,
      trailing: trailing ?? this.trailing,
      onTap: onTap ?? this.onTap,
      disabled: disabled ?? this.disabled,
      selected: selected ?? this.selected,
      isFocused: isFocused ?? this.isFocused,
      height: height ?? this.height,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      child: child ?? this.child,
    );
  }

  @override
  State<MenuItemM3E> createState() => _MenuItemM3EState();
}

class _MenuItemM3EState extends State<MenuItemM3E> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine colors based on state
    final stateLayerColor = widget.selected
        ? colorScheme.primary
        : colorScheme.onSurface;

    final contentColor = widget.disabled
        ? M3EStateLayer.getDisabledContentColor(colorScheme.onSurface)
        : widget.selected
            ? colorScheme.primary
            : colorScheme.onSurface;

    final backgroundColor = widget.backgroundColor ??
        M3EStateLayer.getCombinedStateLayer(
          surface: colorScheme.surface,
          stateLayerColor: stateLayerColor,
          isHovered: _isHovered && !widget.disabled,
          isFocused: widget.isFocused && !widget.disabled,
          isPressed: _isPressed && !widget.disabled,
        );

    return MouseRegion(
      onEnter: widget.disabled ? null : (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: widget.disabled ? null : (_) => setState(() => _isPressed = true),
        onTapUp: widget.disabled ? null : (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.disabled ? null : widget.onTap,
        child: AnimatedContainer(
          duration: M3EMotion.getDuration(M3EMotion.medium3), // Smoother hover transition
          curve: M3EMotion.emphasizedDecelerate,
          height: widget.height ?? 48.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          color: backgroundColor,
          child: Row(
            children: [
              // Leading icon
              if (widget.leadingIcon != null) ...[
                Icon(
                  widget.leadingIcon,
                  size: 24.0,
                  color: contentColor,
                ),
                const SizedBox(width: 12.0),
              ],

              // Label or custom child
              Expanded(
                child: widget.child ??
                    Text(
                      widget.label!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: contentColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              ),

              // Trailing widget
              if (widget.trailing != null) ...[
                const SizedBox(width: 12.0),
                DefaultTextStyle(
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: contentColor,
                  ),
                  child: IconTheme(
                    data: IconThemeData(
                      color: contentColor,
                      size: 18.0,
                    ),
                    child: widget.trailing!,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Material 3 Expressive Divider
///
/// A divider component with:
/// - Thickness: 1dp
/// - Color: outlineVariant (low emphasis)
/// - Optional insets (16dp, 72dp for list avatars)
/// - Optional fade animation (150ms)
class DividerM3E extends StatelessWidget {
  /// Whether this is a vertical divider
  final bool vertical;

  /// Start inset (for horizontal) or top inset (for vertical)
  final double? startInset;

  /// End inset (for horizontal) or bottom inset (for vertical)
  final double? endInset;

  /// Custom thickness (defaults to 1dp)
  final double? thickness;

  /// Custom color (defaults to outlineVariant)
  final Color? color;

  /// Whether to animate the divider fade in/out
  final bool animated;

  /// Custom height for horizontal divider (when vertical is false)
  final double? height;

  /// Custom width for vertical divider (when vertical is true)
  final double? width;

  const DividerM3E({
    super.key,
    this.vertical = false,
    this.startInset,
    this.endInset,
    this.thickness,
    this.color,
    this.animated = false,
    this.height,
    this.width,
  });

  /// Create a full-width horizontal divider
  const DividerM3E.horizontal({
    super.key,
    this.startInset,
    this.endInset,
    this.thickness,
    this.color,
    this.animated = false,
    this.height,
  }) : vertical = false,
       width = null;

  /// Create a full-height vertical divider
  const DividerM3E.vertical({
    super.key,
    this.startInset,
    this.endInset,
    this.thickness,
    this.color,
    this.animated = false,
    this.width,
  }) : vertical = true,
       height = null;

  /// Create a horizontal divider with standard list inset (16dp)
  const DividerM3E.inset({
    super.key,
    this.thickness,
    this.color,
    this.animated = false,
    this.height,
  }) : vertical = false,
       startInset = 16.0,
       endInset = null,
       width = null;

  /// Create a horizontal divider with avatar list inset (72dp)
  const DividerM3E.avatarInset({
    super.key,
    this.thickness,
    this.color,
    this.animated = false,
    this.height,
  }) : vertical = false,
       startInset = 72.0,
       endInset = null,
       width = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = color ?? theme.colorScheme.outlineVariant;
    final dividerThickness = thickness ?? 1.0;

    Widget divider;

    if (vertical) {
      divider = Container(
        width: width ?? dividerThickness,
        margin: EdgeInsets.only(
          top: startInset ?? 0.0,
          bottom: endInset ?? 0.0,
        ),
        color: dividerColor,
      );
    } else {
      divider = Container(
        height: height ?? dividerThickness,
        margin: EdgeInsets.only(
          left: startInset ?? 0.0,
          right: endInset ?? 0.0,
        ),
        color: dividerColor,
      );
    }

    if (animated) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 150),
        curve: Curves.linear,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: child,
          );
        },
        child: divider,
      );
    }

    return divider;
  }
}

/// Show a menu at a specific position
///
/// Returns the selected value when an item is tapped, or null if dismissed.
///
/// Example:
/// ```dart
/// final result = await showMenuM3E<String>(
///   context: context,
///   position: RelativeRect.fromLTRB(100, 100, 0, 0),
///   items: [
///     MenuItemM3E(label: 'Edit', leadingIcon: Icons.edit),
///     MenuItemM3E(label: 'Delete', leadingIcon: Icons.delete),
///   ],
/// );
/// ```
Future<T?> showMenuM3E<T>({
  required BuildContext context,
  required RelativeRect position,
  required List<PopupMenuEntry<T>> items,
  T? initialValue,
  double? elevation,
  Color? surfaceTintColor,
  Color? shadowColor,
  BoxConstraints? constraints,
  bool useRootNavigator = false,
  RouteSettings? routeSettings,
}) {
  return showMenu<T>(
    context: context,
    position: position,
    items: items,
    initialValue: initialValue,
    elevation: elevation ?? M3EElevation.menu,
    surfaceTintColor: surfaceTintColor,
    shadowColor: shadowColor,
    constraints: constraints ??
        const BoxConstraints(
          minWidth: 112.0,
          maxWidth: 280.0,
        ),
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    shape: M3EShapes.menu,
  );
}

/// Show a menu relative to a widget (anchor)
///
/// Automatically positions the menu below or above the anchor widget.
///
/// Example:
/// ```dart
/// final button = GlobalKey();
///
/// // In build:
/// IconButton(
///   key: button,
///   icon: Icon(Icons.more_vert),
///   onPressed: () async {
///     final result = await showMenuM3EFromAnchor<String>(
///       context: context,
///       anchor: button,
///       items: [
///         PopupMenuItem(value: 'edit', child: Text('Edit')),
///         PopupMenuItem(value: 'delete', child: Text('Delete')),
///       ],
///     );
///   },
/// );
/// ```
Future<T?> showMenuM3EFromAnchor<T>({
  required BuildContext context,
  required GlobalKey anchor,
  required List<PopupMenuEntry<T>> items,
  T? initialValue,
  double? elevation,
  Color? surfaceTintColor,
  Color? shadowColor,
  BoxConstraints? constraints,
  bool useRootNavigator = false,
  RouteSettings? routeSettings,
}) {
  final RenderBox? overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox?;
  final RenderBox? renderBox =
      anchor.currentContext?.findRenderObject() as RenderBox?;

  if (overlay == null || renderBox == null) {
    throw Exception('Cannot show menu: overlay or anchor not found');
  }

  final Offset position = renderBox.localToGlobal(
    renderBox.size.bottomLeft(Offset.zero),
    ancestor: overlay,
  );

  final RelativeRect menuPosition = RelativeRect.fromLTRB(
    position.dx,
    position.dy,
    overlay.size.width - position.dx - renderBox.size.width,
    overlay.size.height - position.dy,
  );

  return showMenuM3E<T>(
    context: context,
    position: menuPosition,
    items: items,
    initialValue: initialValue,
    elevation: elevation,
    surfaceTintColor: surfaceTintColor,
    shadowColor: shadowColor,
    constraints: constraints,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
  );
}

/// Example usage demonstrating all menu components
class MenuM3EExample extends StatefulWidget {
  const MenuM3EExample({super.key});

  @override
  State<MenuM3EExample> createState() => _MenuM3EExampleState();
}

class _MenuM3EExampleState extends State<MenuM3EExample> {
  final GlobalKey _menuButtonKey = GlobalKey();
  String? _selectedAction;
  bool _showCustomMenu = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu M3E Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Standard PopupMenuButton with M3E styling
            Text(
              'Standard Menu',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            PopupMenuButton<String>(
              elevation: M3EElevation.menu,
              shape: M3EShapes.menu,
              constraints: const BoxConstraints(
                minWidth: 112.0,
                maxWidth: 280.0,
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 24),
                      SizedBox(width: 12),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 24),
                      SizedBox(width: 12),
                      Text('Share'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 24),
                      SizedBox(width: 12),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                setState(() => _selectedAction = value);
              },
              child: OutlinedButton.icon(
                icon: const Icon(Icons.menu),
                label: const Text('Show Menu'),
                onPressed: null, // PopupMenuButton handles this
              ),
            ),
            if (_selectedAction != null) ...[
              const SizedBox(height: 8),
              Text('Selected: $_selectedAction'),
            ],

            const SizedBox(height: 32),
            const DividerM3E(),
            const SizedBox(height: 32),

            // Custom MenuM3E widget
            Text(
              'Custom Menu with Animations',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                setState(() => _showCustomMenu = !_showCustomMenu);
              },
              child: Text(_showCustomMenu ? 'Hide Menu' : 'Show Menu'),
            ),
            const SizedBox(height: 16),
            if (_showCustomMenu)
              MenuM3E(
                isOpen: _showCustomMenu,
                onClose: () => setState(() => _showCustomMenu = false),
                items: [
                  MenuItemM3E(
                    label: 'Profile',
                    leadingIcon: Icons.person,
                    onTap: () {
                      setState(() => _showCustomMenu = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile tapped')),
                      );
                    },
                  ),
                  MenuItemM3E(
                    label: 'Settings',
                    leadingIcon: Icons.settings,
                    onTap: () {
                      setState(() => _showCustomMenu = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings tapped')),
                      );
                    },
                  ),
                  const MenuItemM3E(
                    label: 'Help',
                    leadingIcon: Icons.help,
                    trailing: Text('⌘H'),
                  ),
                  const MenuItemM3E(
                    label: 'Disabled',
                    leadingIcon: Icons.block,
                    disabled: true,
                  ),
                  MenuItemM3E(
                    label: 'Selected',
                    leadingIcon: Icons.check,
                    selected: true,
                    trailing: const Icon(Icons.check, size: 18),
                    onTap: () {},
                  ),
                ],
              ),

            const SizedBox(height: 32),
            const DividerM3E(),
            const SizedBox(height: 32),

            // Menu from anchor example
            Text(
              'Menu from Anchor',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            IconButton.outlined(
              key: _menuButtonKey,
              icon: const Icon(Icons.more_vert),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final result = await showMenuM3EFromAnchor<String>(
                  context: context,
                  anchor: _menuButtonKey,
                  items: [
                    const PopupMenuItem(
                      value: 'copy',
                      child: Row(
                        children: [
                          Icon(Icons.copy, size: 24),
                          SizedBox(width: 12),
                          Text('Copy'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'paste',
                      child: Row(
                        children: [
                          Icon(Icons.paste, size: 24),
                          SizedBox(width: 12),
                          Text('Paste'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'cut',
                      child: Row(
                        children: [
                          Icon(Icons.cut, size: 24),
                          SizedBox(width: 12),
                          Text('Cut'),
                        ],
                      ),
                    ),
                  ],
                );

                if (result != null && mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Selected: $result')),
                  );
                }
              },
            ),

            const SizedBox(height: 32),
            const DividerM3E(),
            const SizedBox(height: 32),

            // Divider examples
            Text(
              'Divider Examples',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            const Text('Full width:'),
            const SizedBox(height: 8),
            const DividerM3E(),
            const SizedBox(height: 16),

            const Text('With inset:'),
            const SizedBox(height: 8),
            const DividerM3E.inset(),
            const SizedBox(height: 16),

            const Text('Avatar list inset:'),
            const SizedBox(height: 8),
            const DividerM3E.avatarInset(),
            const SizedBox(height: 16),

            const Text('Animated:'),
            const SizedBox(height: 8),
            const DividerM3E(animated: true),
            const SizedBox(height: 16),

            const Text('Vertical dividers:'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  color: Colors.blue.withValues(alpha: 0.3),
                ),
                const SizedBox(
                  height: 48,
                  child: DividerM3E.vertical(),
                ),
                Container(
                  height: 48,
                  width: 48,
                  color: Colors.green.withValues(alpha: 0.3),
                ),
                const SizedBox(
                  height: 48,
                  child: DividerM3E.vertical(),
                ),
                Container(
                  height: 48,
                  width: 48,
                  color: Colors.orange.withValues(alpha: 0.3),
                ),
              ],
            ),

            const SizedBox(height: 32),
            const DividerM3E(),
            const SizedBox(height: 32),

            // Menu items showcase
            Text(
              'Menu Item Variations',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(M3EShapes.extraSmall),
              ),
              child: Column(
                children: [
                  MenuItemM3E(
                    label: 'Basic item',
                    onTap: () {},
                  ),
                  const DividerM3E(),
                  MenuItemM3E(
                    label: 'With icon',
                    leadingIcon: Icons.star,
                    onTap: () {},
                  ),
                  const DividerM3E(),
                  MenuItemM3E(
                    label: 'With trailing',
                    leadingIcon: Icons.settings,
                    trailing: const Text('⌘S'),
                    onTap: () {},
                  ),
                  const DividerM3E(),
                  MenuItemM3E(
                    label: 'Selected item',
                    leadingIcon: Icons.check_circle,
                    selected: true,
                    trailing: const Icon(Icons.check, size: 18),
                    onTap: () {},
                  ),
                  const DividerM3E(),
                  const MenuItemM3E(
                    label: 'Disabled item',
                    leadingIcon: Icons.block,
                    disabled: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

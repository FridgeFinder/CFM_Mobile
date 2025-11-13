import 'package:flutter/material.dart';
import '../theme/motion.dart';
import '../theme/state_layers.dart';
import 'communication_m3e.dart';

/// Toggle Icon Button M3E
///
/// An icon button that can be toggled between selected and unselected states.
/// Features:
/// - Smooth state transition animations
/// - Badge support
/// - Hover and press feedback
/// - Custom selected/unselected icons
class ToggleIconButtonM3E extends StatefulWidget {
  /// Icon to display when unselected
  final IconData icon;

  /// Icon to display when selected (optional, uses icon if not provided)
  final IconData? selectedIcon;

  /// Whether the button is currently selected
  final bool isSelected;

  /// Callback when button is tapped
  final ValueChanged<bool>? onPressed;

  /// Badge to display (count or label)
  final int? badgeCount;
  final String? badgeLabel;

  /// Whether to show badge
  final bool showBadge;

  /// Tooltip text
  final String? tooltip;

  /// Custom colors
  final Color? selectedColor;
  final Color? unselectedColor;

  /// Size of the icon
  final double? iconSize;

  /// Whether the button is enabled
  final bool enabled;

  const ToggleIconButtonM3E({
    super.key,
    required this.icon,
    this.selectedIcon,
    required this.isSelected,
    this.onPressed,
    this.badgeCount,
    this.badgeLabel,
    this.showBadge = false,
    this.tooltip,
    this.selectedColor,
    this.unselectedColor,
    this.iconSize,
    this.enabled = true,
  });

  @override
  State<ToggleIconButtonM3E> createState() => _ToggleIconButtonM3EState();
}

class _ToggleIconButtonM3EState extends State<ToggleIconButtonM3E>
    with TickerProviderStateMixin {
  late AnimationController _toggleController;
  late AnimationController _scaleController;
  late Animation<double> _toggleAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _toggleController = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3),
      vsync: this,
    );

    _toggleAnimation = CurvedAnimation(
      parent: _toggleController,
      curve: M3EMotion.emphasizedDecelerate,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.9)
            .chain(CurveTween(curve: M3EMotion.emphasizedAccelerate)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.0)
            .chain(CurveTween(curve: M3EMotion.expressiveDefaultOvershoot)),
        weight: 50.0,
      ),
    ]).animate(_scaleController);

    if (widget.isSelected) {
      _toggleController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ToggleIconButtonM3E oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _toggleController.forward();
      } else {
        _toggleController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _toggleController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled) return;

    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    widget.onPressed?.call(!widget.isSelected);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveIconSize = widget.iconSize ?? 24.0;

    final selectedColor = widget.selectedColor ?? colorScheme.primary;
    final unselectedColor = widget.unselectedColor ?? colorScheme.onSurfaceVariant;

    Widget button = AnimatedBuilder(
      animation: Listenable.merge([_toggleAnimation, _scaleAnimation]),
      builder: (context, child) {
        final currentColor = Color.lerp(
          unselectedColor,
          selectedColor,
          _toggleAnimation.value,
        )!;

        final currentIcon = Icon(
          widget.isSelected && widget.selectedIcon != null
              ? widget.selectedIcon!
              : widget.icon,
          size: effectiveIconSize * _scaleAnimation.value,
          color: currentColor,
        );

        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24.0),
          child: InkWell(
            onTap: widget.enabled ? _handleTap : null,
            onTapDown: widget.enabled ? (_) {} : null,
            onTapUp: widget.enabled ? (_) {} : null,
            onTapCancel: widget.enabled ? () {} : null,
            onHover: widget.enabled ? (value) {} : null,
            borderRadius: BorderRadius.circular(24.0),
            overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.pressed)) {
                return M3EStateLayer.getPressColor(currentColor);
              }
              if (states.contains(WidgetState.hovered)) {
                return M3EStateLayer.getHoverColor(currentColor);
              }
              if (states.contains(WidgetState.focused)) {
                return M3EStateLayer.getFocusColor(currentColor);
              }
              return null;
            }),
            child: Container(
              width: 48.0,
              height: 48.0,
              alignment: Alignment.center,
              child: currentIcon,
            ),
          ),
        );
      },
    );

    // Wrap with badge if needed
    if (widget.showBadge && (widget.badgeCount != null || widget.badgeLabel != null)) {
      button = BadgeM3E(
        count: widget.badgeCount,
        label: widget.badgeLabel,
        show: widget.showBadge,
        child: button,
      );
    }

    // Wrap with tooltip if provided
    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Dropdown Icon Button M3E
///
/// An icon button that shows a dropdown menu when pressed.
/// Features:
/// - Menu cascade animation
/// - Badge support
/// - Custom menu items
class DropdownIconButtonM3E extends StatefulWidget {
  /// Icon to display
  final IconData icon;

  /// Menu items to display
  final List<DropdownMenuItemM3E> items;

  /// Badge to display
  final int? badgeCount;
  final String? badgeLabel;
  final bool showBadge;

  /// Tooltip text
  final String? tooltip;

  /// Custom icon size
  final double? iconSize;

  /// Whether the button is enabled
  final bool enabled;

  const DropdownIconButtonM3E({
    super.key,
    required this.icon,
    required this.items,
    this.badgeCount,
    this.badgeLabel,
    this.showBadge = false,
    this.tooltip,
    this.iconSize,
    this.enabled = true,
  });

  @override
  State<DropdownIconButtonM3E> createState() => _DropdownIconButtonM3EState();
}

class _DropdownIconButtonM3EState extends State<DropdownIconButtonM3E> {
  void _showMenu(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height,
        MediaQuery.of(context).size.width - offset.dx - renderBox.size.width,
        MediaQuery.of(context).size.height - offset.dy - renderBox.size.height,
      ),
      items: widget.items.map((item) {
        return PopupMenuItem(
          value: item.value,
          child: ListTile(
            leading: item.icon != null ? Icon(item.icon) : null,
            title: Text(item.label),
            onTap: () {
              Navigator.pop(context);
              item.onTap?.call();
            },
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget button = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24.0),
      child: InkWell(
        onTap: widget.enabled ? () => _showMenu(context) : null,
        borderRadius: BorderRadius.circular(24.0),
        child: Container(
          width: 48.0,
          height: 48.0,
          alignment: Alignment.center,
          child: Icon(
            widget.icon,
            size: widget.iconSize ?? 24.0,
          ),
        ),
      ),
    );

    // Wrap with badge if needed
    if (widget.showBadge && (widget.badgeCount != null || widget.badgeLabel != null)) {
      button = BadgeM3E(
        count: widget.badgeCount,
        label: widget.badgeLabel,
        show: widget.showBadge,
        child: button,
      );
    }

    // Wrap with tooltip if provided
    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Dropdown menu item for DropdownIconButtonM3E
class DropdownMenuItemM3E {
  final String label;
  final IconData? icon;
  final dynamic value;
  final VoidCallback? onTap;

  const DropdownMenuItemM3E({
    required this.label,
    this.icon,
    required this.value,
    this.onTap,
  });
}


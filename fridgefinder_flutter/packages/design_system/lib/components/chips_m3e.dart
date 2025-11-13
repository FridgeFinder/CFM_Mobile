import 'package:flutter/material.dart';
import '../theme/motion.dart';

/// M3E Filter Chip with selection bounce and hover lift
///
/// Features:
/// - Selection bounce animation (scale 1.0 → 1.05 → 1.0)
/// - Hover lift (elevation +1dp)
/// - Press feedback (scale 0.95)
class FilterChipM3E extends StatefulWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;

  const FilterChipM3E({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
    this.icon,
  });

  @override
  State<FilterChipM3E> createState() => _FilterChipM3EState();
}

class _FilterChipM3EState extends State<FilterChipM3E>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3), // 350ms for more expressive bounce
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05, // Bounce scale
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: M3EMotion.expressiveDefaultOvershoot,
    ));

    if (widget.selected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(FilterChipM3E oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      if (widget.selected) {
        _controller.reset();
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
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onSelected?.call(!widget.selected);
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            final scale = _isPressed ? 0.95 : (widget.selected ? _scaleAnimation.value : 1.0);
            return Transform.scale(
              scale: scale,
              child: Material(
                elevation: _isHovered ? 1.0 : 0.0,
                borderRadius: BorderRadius.circular(8),
                color: Colors.transparent,
                child: FilterChip(
                  label: Text(widget.label),
                  selected: widget.selected,
                  onSelected: widget.onSelected,
                  avatar: widget.icon != null ? Icon(widget.icon, size: 18) : null,
                  showCheckmark: widget.icon == null,
                  selectedColor: colorScheme.secondaryContainer,
                  checkmarkColor: colorScheme.onSecondaryContainer,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// M3E Input Chip with delete animation and hover lift
///
/// Features:
/// - Delete icon fade-out animation
/// - Hover lift (elevation +1dp)
/// - Press feedback
class InputChipM3E extends StatefulWidget {
  final String label;
  final VoidCallback? onDeleted;
  final VoidCallback? onPressed;
  final IconData? avatar;

  const InputChipM3E({
    super.key,
    required this.label,
    this.onDeleted,
    this.onPressed,
    this.avatar,
  });

  @override
  State<InputChipM3E> createState() => _InputChipM3EState();
}

class _InputChipM3EState extends State<InputChipM3E>
    with TickerProviderStateMixin {
  late AnimationController _deleteController;
  late Animation<double> _deleteAnimation;
  bool _isHovered = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _deleteController = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3), // 350ms for smoother fade
      vsync: this,
    );

    _deleteAnimation = CurvedAnimation(
      parent: _deleteController,
      curve: M3EMotion.emphasizedDecelerate,
    );
  }

  @override
  void dispose() {
    _deleteController.dispose();
    super.dispose();
  }

  void _handleDelete() {
    setState(() => _isDeleting = true);
    _deleteController.forward().then((_) {
      widget.onDeleted?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _deleteAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isDeleting ? _deleteAnimation.value : 1.0,
            child: Opacity(
              opacity: _isDeleting ? 1.0 - _deleteAnimation.value : 1.0,
              child: Material(
                elevation: _isHovered ? 1.0 : 0.0,
                borderRadius: BorderRadius.circular(8),
                color: Colors.transparent,
                child: InputChip(
                  label: Text(widget.label),
                  onDeleted: widget.onDeleted != null ? _handleDelete : null,
                  onPressed: widget.onPressed,
                  avatar: widget.avatar != null ? Icon(widget.avatar, size: 18) : null,
                  deleteIconColor: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// M3E Assist Chip with hover lift and press feedback
class AssistChipM3E extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const AssistChipM3E({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  State<AssistChipM3E> createState() => _AssistChipM3EState();
}

class _AssistChipM3EState extends State<AssistChipM3E>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3), // 350ms for more expressive bounce
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95, // Press scale
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: M3EMotion.emphasizedDecelerate,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _controller.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _controller.reverse();
          widget.onPressed?.call();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isPressed ? _scaleAnimation.value : 1.0,
              child: Material(
                elevation: _isHovered ? 1.0 : 0.0,
                borderRadius: BorderRadius.circular(8),
                color: Colors.transparent,
                child: ActionChip(
                  label: Text(widget.label),
                  onPressed: widget.onPressed,
                  avatar: widget.icon != null ? Icon(widget.icon, size: 18) : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

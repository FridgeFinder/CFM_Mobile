import 'package:flutter/material.dart';
import '../theme/spacing.dart';
import '../theme/shapes.dart';
import '../theme/motion.dart';

/// M3E Bottom Sheet
///
/// Utilities for showing bottom sheets with proper M3E styling.
class BottomSheetM3E {
  /// Show a modal bottom sheet with enhanced M3E styling
  static Future<T?> showModal<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? colorScheme.surfaceContainerLow,
      shape: M3EShapes.bottomSheet,
      elevation: 3, // Enhanced elevation for better depth perception
      clipBehavior: Clip.antiAlias,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: M3EMotionPatterns.bottomSheetFallback,
      ),
      builder: (context) => Container(
        decoration: BoxDecoration(
          // Subtle top border for visual separation
          border: Border(
            top: BorderSide(
              color: colorScheme.primary.withValues(alpha: 0.1),
              width: 2,
            ),
          ),
        ),
        child: child,
      ),
    );
  }

  /// Show a modal bottom sheet with a drag handle and spring physics
  static Future<T?> showModalWithHandle<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    double initialChildSize = 0.5, // 50% of screen height
    List<double>? snapPoints, // e.g., [0.25, 0.5, 1.0] for peek, half, full
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      shape: M3EShapes.bottomSheet,
      builder: (context) => _SpringBottomSheet(
        initialChildSize: initialChildSize,
        snapPoints: snapPoints ?? [0.25, 0.5, 1.0],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DragHandleM3E(),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

/// M3E Drag Handle with morph animation
///
/// A visual indicator for draggable bottom sheets that morphs during drag.
class DragHandleM3E extends StatefulWidget {
  final bool isDragging;
  
  const DragHandleM3E({super.key, this.isDragging = false});

  @override
  State<DragHandleM3E> createState() => _DragHandleM3EState();
}

class _DragHandleM3EState extends State<DragHandleM3E>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3), // 350ms for smoother morph
      vsync: this,
    );
    
    _widthAnimation = Tween<double>(
      begin: 32.0,
      end: 48.0, // Wider when dragging
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: M3EMotion.emphasizedDecelerate,
    ));
    
    _heightAnimation = Tween<double>(
      begin: 4.0,
      end: 5.0, // Taller when dragging
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: M3EMotion.emphasizedDecelerate,
    ));
    
    if (widget.isDragging) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(DragHandleM3E oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDragging != oldWidget.isDragging) {
      if (widget.isDragging) {
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

    return AnimatedBuilder(
      animation: Listenable.merge([_widthAnimation, _heightAnimation]),
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.only(
            top: M3ESpacing.md, // More breathing room
            bottom: M3ESpacing.md,
          ),
          width: _widthAnimation.value,
          height: _heightAnimation.value,
          decoration: BoxDecoration(
            // More vibrant color when dragging
            color: widget.isDragging
                ? colorScheme.primary.withValues(alpha: 0.6)
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(M3ESpacing.xxs / 2),
            // Subtle glow when dragging
            boxShadow: widget.isDragging
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        );
      },
    );
  }
}

/// Spring-based bottom sheet with snap points
class _SpringBottomSheet extends StatefulWidget {
  final Widget child;
  final double initialChildSize;
  final List<double> snapPoints;

  const _SpringBottomSheet({
    required this.child,
    required this.initialChildSize,
    required this.snapPoints,
  });

  @override
  State<_SpringBottomSheet> createState() => _SpringBottomSheetState();
}

class _SpringBottomSheetState extends State<_SpringBottomSheet> {
  late DraggableScrollableController _controller;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = DraggableScrollableController();
    _controller.addListener(_onDragUpdate);
  }

  void _onDragUpdate() {
    // Track if controller is attached and position is changing
    final isAttached = _controller.isAttached;
    if (isAttached && !_isDragging) {
      setState(() => _isDragging = true);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onDragUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        if (notification.dragDetails != null) {
          if (!_isDragging) {
            setState(() => _isDragging = true);
          }
        } else {
          if (_isDragging) {
            setState(() => _isDragging = false);
          }
        }
        return false;
      },
      child: DraggableScrollableSheet(
        controller: _controller,
        initialChildSize: widget.initialChildSize,
        minChildSize: widget.snapPoints.first,
        maxChildSize: widget.snapPoints.last,
        snap: true,
        snapSizes: widget.snapPoints,
        builder: (context, scrollController) {
          return Column(
            children: [
              DragHandleM3E(isDragging: _isDragging),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  child: widget.child,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// M3E Bottom Sheet Content Wrapper
///
/// Provides consistent padding and enhanced styling for bottom sheet content.
class BottomSheetContentM3E extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool showDivider;

  const BottomSheetContentM3E({
    super.key,
    required this.child,
    this.padding,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Optional subtle divider for visual separation
        if (showDivider) ...[
          Container(
            height: 1,
            margin: M3ESpacing.symmetric(
              horizontal: M3ESpacing.xl,
              vertical: M3ESpacing.xs,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  colorScheme.outlineVariant.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          M3ESpacing.verticalSM,
        ],
        // Content with enhanced padding
        Padding(
          padding: padding ??
              M3ESpacing.symmetric(
                horizontal: M3ESpacing.xl, // More generous horizontal padding
                vertical: M3ESpacing.lg,
              ),
          child: child,
        ),
      ],
    );
  }
}

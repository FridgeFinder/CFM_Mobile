import 'package:flutter/material.dart';
import '../theme/motion.dart';
import '../theme/shape_morph.dart';

/// Enhanced Segmented Button with indicator morphing and spring tracking
///
/// Features:
/// - Animated indicator that morphs and slides between segments
/// - Spring-based tracking animation
/// - Smooth shape transitions
/// - Multi-select support with multiple indicators
class SegmentedButtonEnhancedM3E<T> extends StatefulWidget {
  final List<ButtonSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>>? onSelectionChanged;
  final bool multiSelectionEnabled;
  final bool showSelectedIcon;
  final bool emptySelectionAllowed;
  final ButtonStyle? style;

  const SegmentedButtonEnhancedM3E({
    super.key,
    required this.segments,
    required this.selected,
    this.onSelectionChanged,
    this.multiSelectionEnabled = false,
    this.showSelectedIcon = true,
    this.emptySelectionAllowed = true,
    this.style,
  }) : assert(segments.length >= 2, 'SegmentedButton requires at least 2 segments');

  @override
  State<SegmentedButtonEnhancedM3E<T>> createState() => _SegmentedButtonEnhancedM3EState<T>();
}

class _SegmentedButtonEnhancedM3EState<T> extends State<SegmentedButtonEnhancedM3E<T>>
    with TickerProviderStateMixin {
  late List<AnimationController> _indicatorControllers;
  late List<Animation<double>> _indicatorAnimations;
  late List<Animation<BorderRadius>> _morphAnimations;
  Set<T> _previousSelected = {};

  @override
  void initState() {
    super.initState();
    _previousSelected = Set<T>.from(widget.selected);
    
    // Create animation controllers for each segment
    _indicatorControllers = List.generate(
      widget.segments.length,
      (index) => AnimationController(
        duration: M3EMotion.getDuration(M3EMotion.medium4), // 400ms for smoother indicator slide
        vsync: this,
      ),
    );

    _indicatorAnimations = _indicatorControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: M3EMotion.expressiveDefaultOvershoot,
      ));
    }).toList();

    _morphAnimations = _indicatorControllers.map((controller) {
      return ShapeMorph.createMorph(
        controller: controller,
        startType: ShapeType.rounded,
        endType: ShapeType.pill,
        customRadius: 20.0,
      );
    }).toList();

    // Initialize animations for selected segments
    _updateAnimations();
  }

  @override
  void didUpdateWidget(SegmentedButtonEnhancedM3E<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      _previousSelected = Set<T>.from(oldWidget.selected);
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    for (int i = 0; i < widget.segments.length; i++) {
      final segment = widget.segments[i];
      final isSelected = widget.selected.contains(segment.value);
      final wasSelected = _previousSelected.contains(segment.value);

      if (isSelected && !wasSelected) {
        // Segment just became selected - animate in
        _indicatorControllers[i].forward();
      } else if (!isSelected && wasSelected) {
        // Segment just became unselected - animate out
        _indicatorControllers[i].reverse();
      } else if (isSelected) {
        // Segment remains selected - ensure it's animated
        if (_indicatorControllers[i].value == 0.0) {
          _indicatorControllers[i].forward();
        }
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _indicatorControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // Background segments
        Row(
          mainAxisSize: MainAxisSize.min,
          children: widget.segments.asMap().entries.map((entry) {
            final index = entry.key;
            final segment = entry.value;
            final isSelected = widget.selected.contains(segment.value);

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  final newSelection = Set<T>.from(widget.selected);
                  if (widget.multiSelectionEnabled) {
                    if (newSelection.contains(segment.value)) {
                      if (widget.emptySelectionAllowed || newSelection.length > 1) {
                        newSelection.remove(segment.value);
                      }
                    } else {
                      newSelection.add(segment.value);
                    }
                  } else {
                    if (newSelection.contains(segment.value)) {
                      if (widget.emptySelectionAllowed) {
                        newSelection.clear();
                      }
                    } else {
                      newSelection.clear();
                      newSelection.add(segment.value);
                    }
                  }
                  widget.onSelectionChanged?.call(newSelection);
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colorScheme.outline,
                      width: 1.0,
                    ),
                    borderRadius: _getSegmentBorderRadius(index),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.showSelectedIcon && isSelected)
                          Icon(
                            Icons.check,
                            size: 18,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        if (widget.showSelectedIcon && isSelected) const SizedBox(width: 4),
                        if (segment.icon != null) ...[
                          IconTheme(
                            data: IconThemeData(
                              size: 18,
                              color: isSelected
                                  ? colorScheme.onSecondaryContainer
                                  : colorScheme.onSurface,
                            ),
                            child: segment.icon!,
                          ),
                          if (segment.label != null) const SizedBox(width: 4),
                        ],
                        if (segment.label != null)
                          DefaultTextStyle(
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: isSelected
                                  ? colorScheme.onSecondaryContainer
                                  : colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ) ?? const TextStyle(),
                            child: segment.label!,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // Animated indicators
        ...widget.segments.asMap().entries.map((entry) {
          final index = entry.key;
          final segment = entry.value;
          final isSelected = widget.selected.contains(segment.value);

          if (!isSelected) return const SizedBox.shrink();

          return AnimatedBuilder(
            animation: Listenable.merge([
              _indicatorAnimations[index],
              _morphAnimations[index],
            ]),
            builder: (context, child) {
              return Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final segmentWidth = constraints.maxWidth / widget.segments.length;
                    final left = segmentWidth * index;

                    return Positioned(
                      left: left,
                      width: segmentWidth,
                      height: 40,
                      child: IgnorePointer(
                        child: Container(
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer.withValues(
                              alpha: _indicatorAnimations[index].value,
                            ),
                            borderRadius: _morphAnimations[index].value,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }),
      ],
    );
  }

  BorderRadius _getSegmentBorderRadius(int index) {
    final isFirst = index == 0;
    final isLast = index == widget.segments.length - 1;

    if (isFirst && isLast) {
      // Single segment
      return BorderRadius.circular(20);
    } else if (isFirst) {
      // First segment
      return const BorderRadius.only(
        topLeft: Radius.circular(20),
        bottomLeft: Radius.circular(20),
      );
    } else if (isLast) {
      // Last segment
      return const BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      );
    } else {
      // Middle segment
      return BorderRadius.zero;
    }
  }
}


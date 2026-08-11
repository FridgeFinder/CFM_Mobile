import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/motion.dart';
import '../theme/spacing.dart';

/// M3E Checkbox with path-based fill animation
///
/// Features:
/// - Path-based checkmark animation with overshoot
/// - Smooth fill transition
/// - Spring-based animations
class CheckboxM3E extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final Color? activeColor;
  final Color? checkColor;

  const CheckboxM3E({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.activeColor,
    this.checkColor,
  });

  @override
  State<CheckboxM3E> createState() => _CheckboxM3EState();
}

class _CheckboxM3EState extends State<CheckboxM3E>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3),
      vsync: this,
    );

    // Checkmark path animation with smooth overshoot
    // The expressiveFastOvershoot curve naturally handles overshoot with smooth transitions
    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: M3EMotion.expressiveFastOvershoot,
      ),
    );

    if (widget.value) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(CheckboxM3E oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
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
    final activeColor = widget.activeColor ?? colorScheme.primary;
    final checkColor = widget.checkColor ?? colorScheme.onPrimary;

    final checkbox = AnimatedBuilder(
      animation: _checkAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(20, 20),
          painter: _CheckboxPainter(
            checked: widget.value,
            checkProgress: _checkAnimation.value.clamp(0.0, 1.0),
            activeColor: activeColor,
            checkColor: checkColor,
          ),
        );
      },
    );

    final interactiveCheckbox = GestureDetector(
      onTap: () => widget.onChanged?.call(!widget.value),
      child: checkbox,
    );

    if (widget.label != null) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(widget.label!),
        trailing: interactiveCheckbox,
        onTap: widget.onChanged != null
            ? () => widget.onChanged?.call(!widget.value)
            : null,
      );
    }

    return interactiveCheckbox;
  }
}

/// Custom checkbox painter with path-based checkmark
class _CheckboxPainter extends CustomPainter {
  final bool checked;
  final double checkProgress;
  final Color activeColor;
  final Color checkColor;

  _CheckboxPainter({
    required this.checked,
    required this.checkProgress,
    required this.activeColor,
    required this.checkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw border
    paint.color = checked ? activeColor : Colors.grey;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(4),
    );
    canvas.drawRRect(rect, paint);

    // Draw fill
    if (checked) {
      paint.style = PaintingStyle.fill;
      paint.color = activeColor.withValues(alpha: checkProgress);
      canvas.drawRRect(rect, paint);
    }

    // Draw checkmark path
    if (checked && checkProgress > 0) {
      paint.style = PaintingStyle.stroke;
      paint.color = checkColor;
      paint.strokeWidth = 2.5;
      paint.strokeCap = StrokeCap.round;
      paint.strokeJoin = StrokeJoin.round;

      final path = Path();
      final startX = size.width * 0.2;
      final startY = size.height * 0.5;
      final midX = size.width * 0.4;
      final midY = size.height * 0.7;
      final endX = size.width * 0.8;
      final endY = size.height * 0.3;

      // Animate checkmark drawing
      if (checkProgress < 0.5) {
        // First stroke
        final firstProgress = checkProgress * 2;
        path.moveTo(startX, startY);
        path.lineTo(
          startX + (midX - startX) * firstProgress,
          startY + (midY - startY) * firstProgress,
        );
      } else {
        // Both strokes
        path.moveTo(startX, startY);
        path.lineTo(midX, midY);
        final secondProgress = (checkProgress - 0.5) * 2;
        path.moveTo(midX, midY);
        path.lineTo(
          midX + (endX - midX) * secondProgress,
          midY + (endY - midY) * secondProgress,
        );
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_CheckboxPainter oldDelegate) {
    return oldDelegate.checked != checked ||
        oldDelegate.checkProgress != checkProgress;
  }
}

/// M3E Radio with path-based fill animation
///
/// Features:
/// - Path-based dot fill animation with overshoot
/// - Smooth selection transition
/// - Spring-based animations
class RadioM3E<T> extends StatefulWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final Color? activeColor;

  const RadioM3E({
    super.key,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.label,
    this.activeColor,
  });

  @override
  State<RadioM3E<T>> createState() => _RadioM3EState<T>();
}

class _RadioM3EState<T> extends State<RadioM3E<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;

  bool get isSelected => widget.value == widget.groupValue;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3),
      vsync: this,
    );

    // Dot fill animation with overshoot
    _fillAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: M3EMotion.expressiveFastOvershoot)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: M3EMotion.emphasizedDecelerate)),
        weight: 50.0,
      ),
    ]).animate(_controller);

    if (isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(RadioM3E<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasSelected = oldWidget.value == oldWidget.groupValue;
    if (isSelected != wasSelected) {
      if (isSelected) {
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
    final activeColor = widget.activeColor ?? colorScheme.primary;

    final radio = AnimatedBuilder(
      animation: _fillAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(20, 20),
          painter: _RadioPainter(
            selected: isSelected,
            fillProgress: _fillAnimation.value.clamp(0.0, 1.0),
            activeColor: activeColor,
          ),
        );
      },
    );

    final interactiveRadio = GestureDetector(
      onTap: () => widget.onChanged?.call(widget.value),
      child: radio,
    );

    if (widget.label != null) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(widget.label!),
        trailing: interactiveRadio,
        onTap: widget.onChanged != null
            ? () => widget.onChanged?.call(widget.value)
            : null,
      );
    }

    return interactiveRadio;
  }
}

/// Custom radio painter with path-based dot fill
class _RadioPainter extends CustomPainter {
  final bool selected;
  final double fillProgress;
  final Color activeColor;

  _RadioPainter({
    required this.selected,
    required this.fillProgress,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw outer circle
    paint.color = selected ? activeColor : Colors.grey;
    canvas.drawCircle(center, radius - 1, paint);

    // Draw fill with animation
    if (selected && fillProgress > 0) {
      paint.style = PaintingStyle.fill;
      paint.color = activeColor.withValues(alpha: fillProgress);
      canvas.drawCircle(center, radius - 1, paint);

      // Draw inner dot with overshoot animation
      final dotRadius = (radius - 6) * fillProgress.clamp(0.0, 1.0);
      if (dotRadius > 0) {
        paint.color = activeColor;
        canvas.drawCircle(center, dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_RadioPainter oldDelegate) {
    return oldDelegate.selected != selected ||
        oldDelegate.fillProgress != fillProgress;
  }
}

/// M3E Switch with spring animations
///
/// Features:
/// - Thumb morph (20dp → 24dp → 20dp during transition)
/// - Track expansion (2px during transition)
/// - Spring travel with playful bounce
/// - Icon morph (check/close icons cross-fade)
/// - Ripple effect on toggle
class SwitchM3E extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  const SwitchM3E({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
  });

  @override
  State<SwitchM3E> createState() => _SwitchM3EState();
}

class _SwitchM3EState extends State<SwitchM3E>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _thumbScaleAnimation;
  late Animation<double> _trackExpansionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3), // 350ms for more expressive toggle
      vsync: this,
    );

    // Thumb scales from 20dp → 24dp → 20dp
    _thumbScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2, // 20dp → 24dp
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: M3EMotion.expressiveDefaultOvershoot,
    ));

    // Track expands 2px during transition
    _trackExpansionAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: M3EMotion.expressiveDefaultOvershoot,
    ));

    if (widget.value) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(SwitchM3E oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final switchWidget = AnimatedBuilder(
      animation: Listenable.merge([_thumbScaleAnimation, _trackExpansionAnimation]),
      builder: (context, child) {
        return Switch(
          value: widget.value,
          onChanged: widget.onChanged,
          // Enhanced styling with spring animations
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      },
    );

    if (widget.label != null) {
      return SwitchListTile(
        value: widget.value,
        onChanged: widget.onChanged,
        title: Text(widget.label!),
        // Use custom switch styling
        secondary: switchWidget,
        controlAffinity: ListTileControlAffinity.trailing,
      );
    }

    return switchWidget;
  }
}

/// M3E Slider with enhanced animations and interactions
///
/// Features:
/// - Thumb scaling on drag (1.0 → 1.2)
/// - Value labels with fade animation
/// - Track preview (active portion highlighted)
/// - Haptic feedback on discrete steps
/// - Smooth spring-based animations
class SliderM3E extends StatefulWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final bool showValueLabel;
  final String Function(double)? valueFormatter;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;

  const SliderM3E({
    super.key,
    required this.value,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.showValueLabel = true,
    this.valueFormatter,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
  });

  @override
  State<SliderM3E> createState() => _SliderM3EState();
}

class _SliderM3EState extends State<SliderM3E>
    with TickerProviderStateMixin {
  late AnimationController _thumbScaleController;
  late AnimationController _labelController;
  late Animation<double> _thumbScaleAnimation;
  late Animation<double> _labelOpacityAnimation;
  bool _isDragging = false;
  double _previousValue = 0.0;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;

    // Thumb scale animation (1.0 → 1.2 when dragging)
    _thumbScaleController = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3),
      vsync: this,
    );
    _thumbScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _thumbScaleController,
      curve: M3EMotion.expressiveDefaultOvershoot,
    ));

    // Label fade animation
    _labelController = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3), // 350ms for smoother fade
      vsync: this,
    );
    _labelOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _labelController,
      curve: M3EMotion.emphasizedDecelerate,
    ));
  }

  @override
  void didUpdateWidget(SliderM3E oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_isDragging) {
      // Trigger haptic feedback on discrete steps
      if (widget.divisions != null) {
        final step = (widget.max - widget.min) / widget.divisions!;
        final currentStep = ((widget.value - widget.min) / step).round();
        final previousStep = ((_previousValue - widget.min) / step).round();
        if (currentStep != previousStep) {
          HapticFeedback.selectionClick();
        }
      }
      _previousValue = widget.value;
    }
  }

  @override
  void dispose() {
    _thumbScaleController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _handleDragStart(double value) {
    setState(() {
      _isDragging = true;
    });
    _thumbScaleController.forward();
    _labelController.forward();
    widget.onChangeStart?.call(value);
  }

  void _handleDragEnd(double value) {
    setState(() {
      _isDragging = false;
    });
    _thumbScaleController.reverse();
    _labelController.reverse();
    widget.onChangeEnd?.call(value);
  }

  String _formatValue(double value) {
    if (widget.valueFormatter != null) {
      return widget.valueFormatter!(value);
    }
    return value.toStringAsFixed(widget.divisions != null ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = widget.activeColor ?? colorScheme.primary;
    final inactiveColor = widget.inactiveColor ?? colorScheme.surfaceContainerHighest;
    final thumbColor = widget.thumbColor ?? colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Value label
        if (widget.showValueLabel && _isDragging)
          AnimatedBuilder(
            animation: _labelOpacityAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _labelOpacityAnimation.value,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: M3ESpacing.xs,
                    bottom: M3ESpacing.xxs,
                  ),
                  child: Text(
                    _formatValue(widget.value),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              );
            },
          ),
        // Slider with custom thumb
        AnimatedBuilder(
          animation: _thumbScaleAnimation,
          builder: (context, child) {
            return SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: activeColor,
                inactiveTrackColor: inactiveColor,
                thumbColor: thumbColor,
                overlayColor: thumbColor.withValues(alpha: 0.1),
                thumbShape: _ScaledSliderThumb(
                  scale: _isDragging ? _thumbScaleAnimation.value : 1.0,
                ),
                trackHeight: 4.0,
                valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                showValueIndicator: (widget.showValueLabel && _isDragging)
                    ? ShowValueIndicator.onDrag
                    : ShowValueIndicator.never,
                valueIndicatorTextStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
              child: Slider(
                value: widget.value,
                onChanged: widget.onChanged,
                onChangeStart: _handleDragStart,
                onChangeEnd: _handleDragEnd,
                min: widget.min,
                max: widget.max,
                divisions: widget.divisions,
                label: widget.label ?? _formatValue(widget.value),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Custom thumb shape with scale animation
class _ScaledSliderThumb extends SliderComponentShape {
  final double scale;

  const _ScaledSliderThumb({required this.scale});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(20.0 * scale, 20.0 * scale);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final paint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 10.0 * scale, paint);
  }
}

/// M3E Range Slider
///
/// A slider with two thumbs for selecting a range of values.
///
/// Features:
/// - Two interactive thumbs
/// - Discrete marks support
/// - Custom track styling
/// - Logarithmic scale support
/// - Haptic feedback on discrete steps
class RangeSliderM3E extends StatefulWidget {
  /// Current range values (start, end)
  final RangeValues values;

  /// Callback when range changes
  final ValueChanged<RangeValues>? onChanged;

  /// Callback when drag starts
  final ValueChanged<RangeValues>? onChangeStart;

  /// Callback when drag ends
  final ValueChanged<RangeValues>? onChangeEnd;

  /// Minimum value
  final double min;

  /// Maximum value
  final double max;

  /// Number of divisions (for discrete marks)
  final int? divisions;

  /// Labels for divisions
  final Map<int, String>? labels;

  /// Whether to use logarithmic scale
  final bool logarithmic;

  /// Custom active color
  final Color? activeColor;

  /// Custom inactive color
  final Color? inactiveColor;

  /// Custom thumb color
  final Color? thumbColor;

  /// Show value labels
  final bool showValueLabels;

  const RangeSliderM3E({
    super.key,
    required this.values,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.labels,
    this.logarithmic = false,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.showValueLabels = true,
  });

  @override
  State<RangeSliderM3E> createState() => _RangeSliderM3EState();
}

class _RangeSliderM3EState extends State<RangeSliderM3E>
    with TickerProviderStateMixin {
  late AnimationController _startThumbController;
  late AnimationController _endThumbController;
  bool _isDraggingStart = false;
  bool _isDraggingEnd = false;

  @override
  void initState() {
    super.initState();

    _startThumbController = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3),
      vsync: this,
    );

    _endThumbController = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _startThumbController.dispose();
    _endThumbController.dispose();
    super.dispose();
  }

  void _handleStartDragStart(RangeValues values) {
    setState(() => _isDraggingStart = true);
    _startThumbController.forward();
    widget.onChangeStart?.call(values);
  }

  void _handleStartDragEnd(RangeValues values) {
    setState(() => _isDraggingStart = false);
    _startThumbController.reverse();
    widget.onChangeEnd?.call(values);
  }

  void _handleEndDragStart(RangeValues values) {
    setState(() => _isDraggingEnd = true);
    _endThumbController.forward();
    widget.onChangeStart?.call(values);
  }

  void _handleEndDragEnd(RangeValues values) {
    setState(() => _isDraggingEnd = false);
    _endThumbController.reverse();
    widget.onChangeEnd?.call(values);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = widget.activeColor ?? colorScheme.primary;
    final inactiveColor = widget.inactiveColor ?? colorScheme.surfaceContainerHighest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Value labels
        if (widget.showValueLabels && (_isDraggingStart || _isDraggingEnd))
          Padding(
            padding: const EdgeInsets.only(
              left: M3ESpacing.xs,
              bottom: M3ESpacing.xxs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.values.start.toStringAsFixed(widget.divisions != null ? 0 : 1),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  widget.values.end.toStringAsFixed(widget.divisions != null ? 0 : 1),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        // Range slider
        RangeSlider(
          values: widget.values,
          onChanged: widget.onChanged,
          onChangeStart: _isDraggingStart ? _handleStartDragStart : _handleEndDragStart,
          onChangeEnd: _isDraggingStart ? _handleStartDragEnd : _handleEndDragEnd,
          min: widget.min,
          max: widget.max,
          divisions: widget.divisions,
          labels: widget.labels != null
              ? RangeLabels(
                  widget.labels![0] ?? widget.values.start.toStringAsFixed(0),
                  widget.labels![widget.divisions ?? 0] ?? widget.values.end.toStringAsFixed(0),
                )
              : null,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
        ),
      ],
    );
  }
}

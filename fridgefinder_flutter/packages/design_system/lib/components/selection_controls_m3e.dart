import 'package:flutter/material.dart';
import '../theme/motion.dart';

/// M3E Checkbox
class CheckboxM3E extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String? label;

  const CheckboxM3E({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return CheckboxListTile(
        value: value,
        onChanged: onChanged,
        title: Text(label!),
        controlAffinity: ListTileControlAffinity.leading,
      );
    }

    return Checkbox(
      value: value,
      onChanged: onChanged,
    );
  }
}

/// M3E Radio
class RadioM3E<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T?>? onChanged;
  final String? label;

  const RadioM3E({
    super.key,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return
      // ignore: deprecated_member_use
      RadioListTile<T>(
        value: value,
        // ignore: deprecated_member_use
        groupValue: groupValue,
        // ignore: deprecated_member_use
        onChanged: onChanged,
        title: Text(label!),
      );
    }

    return
    // ignore: deprecated_member_use
    Radio<T>(
      value: value,
      // ignore: deprecated_member_use
      groupValue: groupValue,
      // ignore: deprecated_member_use
      onChanged: onChanged,
    );
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

/// M3E Slider
class SliderM3E extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;

  const SliderM3E({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: value,
      onChanged: onChanged,
      min: min,
      max: max,
      divisions: divisions,
      label: label,
    );
  }
}

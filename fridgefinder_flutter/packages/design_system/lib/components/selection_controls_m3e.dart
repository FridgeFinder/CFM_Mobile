import 'package:flutter/material.dart';

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
      return RadioListTile<T>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        title: Text(label!),
      );
    }

    return Radio<T>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }
}

/// M3E Switch
class SwitchM3E extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (label != null) {
      return SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(label!),
      );
    }

    return Switch(
      value: value,
      onChanged: onChanged,
    );
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

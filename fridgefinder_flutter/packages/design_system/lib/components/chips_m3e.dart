import 'package:flutter/material.dart';

/// M3E Filter Chip
class FilterChipM3E extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      avatar: icon != null ? Icon(icon, size: 18) : null,
      showCheckmark: icon == null,
    );
  }
}

/// M3E Input Chip
class InputChipM3E extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label),
      onDeleted: onDeleted,
      onPressed: onPressed,
      avatar: avatar != null ? Icon(avatar, size: 18) : null,
    );
  }
}

/// M3E Assist Chip
class AssistChipM3E extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onPressed,
      avatar: icon != null ? Icon(icon, size: 18) : null,
    );
  }
}

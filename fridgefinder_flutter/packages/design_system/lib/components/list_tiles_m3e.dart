import 'package:flutter/material.dart';

/// M3E List Tile
///
/// Flutter's ListTile already follows M3 design.
/// This is a convenience wrapper for consistency.
class ListTileM3E extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final bool selected;
  final bool dense;

  const ListTileM3E({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.selected = false,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      onLongPress: onLongPress,
      enabled: enabled,
      selected: selected,
      dense: dense,
    );
  }
}

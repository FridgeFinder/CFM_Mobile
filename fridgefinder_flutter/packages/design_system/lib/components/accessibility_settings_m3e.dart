import 'package:flutter/material.dart';
import '../theme/motion_settings.dart';
import '../theme/spacing.dart';
import 'selection_controls_m3e.dart';

/// M3E Accessibility Settings Widget
///
/// Provides a settings panel for accessibility preferences including:
/// - Reduce motion toggle
/// - Motion setting listener
/// - WCAG 2.3.3 compliance documentation
///
/// Usage in a settings screen:
/// ```dart
/// AccessibilitySettingsM3E(
///   onChanged: () {
///     setState(() {});
///   },
/// )
/// ```
class AccessibilitySettingsM3E extends StatefulWidget {
  /// Optional callback when settings change
  final VoidCallback? onChanged;

  /// Whether to show section title and description
  final bool showHeader;

  /// Custom title for the section
  final String? title;

  /// Custom description text
  final String? description;

  const AccessibilitySettingsM3E({
    super.key,
    this.onChanged,
    this.showHeader = true,
    this.title,
    this.description,
  });

  @override
  State<AccessibilitySettingsM3E> createState() =>
      _AccessibilitySettingsM3EState();
}

class _AccessibilitySettingsM3EState extends State<AccessibilitySettingsM3E> {
  late VoidCallback _motionListener;

  @override
  void initState() {
    super.initState();
    // Listen to motion setting changes
    _motionListener = () {
      setState(() {});
    };
    MotionSettings.addListener(_motionListener);
  }

  @override
  void dispose() {
    MotionSettings.removeListener(_motionListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showHeader) ...[
          Text(
            widget.title ?? 'Accessibility',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          M3ESpacing.verticalSM,
          Text(
            widget.description ??
                'Adjustments to improve usability for people with disabilities',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          M3ESpacing.verticalMD,
        ],
        // Reduce Motion Setting
        _MotionSettingTile(
          onChanged: () {
            setState(() {});
            widget.onChanged?.call();
          },
        ),
      ],
    );
  }
}

/// Individual motion setting tile
class _MotionSettingTile extends StatefulWidget {
  final VoidCallback? onChanged;

  const _MotionSettingTile({this.onChanged});

  @override
  State<_MotionSettingTile> createState() => _MotionSettingTileState();
}

class _MotionSettingTileState extends State<_MotionSettingTile> {
  late VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _listener = () {
      setState(() {});
      widget.onChanged?.call();
    };
    MotionSettings.addListener(_listener);
  }

  @override
  void dispose() {
    MotionSettings.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isEnabled = MotionSettings.reduceMotion;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: M3ESpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reduce motion',
                        style: textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      M3ESpacing.verticalXS,
                      Text(
                        isEnabled ? 'Enabled' : 'Disabled',
                        style: textTheme.bodySmall?.copyWith(
                          color: isEnabled
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          fontWeight:
                              isEnabled ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                SwitchM3E(
                  value: isEnabled,
                  onChanged: (value) {
                    MotionSettings.reduceMotion = value;
                  },
                ),
              ],
            ),
            M3ESpacing.verticalMD,
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getWcagDescription(isEnabled),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWcagDescription(bool isEnabled) {
    if (isEnabled) {
      return 'Motion animations are disabled or significantly reduced. Page transitions, '
          'loading animations, and interactive effects are optimized for accessibility. '
          '(WCAG 2.3.3 compliant)';
    } else {
      return 'Motion animations provide expressive feedback. If you experience dizziness, '
          'vertigo, or motion sensitivity, enable Reduce motion in your device settings '
          'or toggle it here.';
    }
  }
}

/// Minimal motion toggle for inline settings
class MotionSettingToggleM3E extends StatefulWidget {
  /// Callback when setting changes
  final void Function(bool)? onChanged;

  /// Whether to show label
  final bool showLabel;

  const MotionSettingToggleM3E({
    super.key,
    this.onChanged,
    this.showLabel = true,
  });

  @override
  State<MotionSettingToggleM3E> createState() => _MotionSettingToggleM3EState();
}

class _MotionSettingToggleM3EState extends State<MotionSettingToggleM3E> {
  late VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _listener = () {
      setState(() {});
    };
    MotionSettings.addListener(_listener);
  }

  @override
  void dispose() {
    MotionSettings.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = MotionSettings.reduceMotion;

    if (widget.showLabel) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Reduce motion'),
          M3ESpacing.horizontalSM,
          SwitchM3E(
            value: isEnabled,
            onChanged: (value) {
              MotionSettings.reduceMotion = value;
              widget.onChanged?.call(value);
            },
          ),
        ],
      );
    }

    return SwitchM3E(
      value: isEnabled,
      onChanged: (value) {
        MotionSettings.reduceMotion = value;
        widget.onChanged?.call(value);
      },
    );
  }
}

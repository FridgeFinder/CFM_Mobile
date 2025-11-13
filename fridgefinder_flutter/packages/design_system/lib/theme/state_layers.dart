import 'package:flutter/material.dart';
import 'colors.dart';

/// Material 3 Expressive Universal State Layer System
///
/// Provides automatic state layers for all interactive elements:
/// - Hover: 8% opacity
/// - Focus: 12% opacity with outline
/// - Press: 12% opacity
/// - Drag: 16% opacity
///
/// State layers stack additively (hover + press = 20%)
class M3EStateLayer {
  M3EStateLayer._();

  /// Hover state layer opacity
  static const double hoverOpacity = 0.08;

  /// Focus state layer opacity
  static const double focusOpacity = 0.12;

  /// Press state layer opacity
  static const double pressOpacity = 0.12;

  /// Drag state layer opacity
  static const double dragOpacity = 0.16;

  /// Disabled container opacity
  static const double disabledContainerOpacity = 0.12;

  /// Disabled content opacity
  static const double disabledContentOpacity = 0.38;

  /// Get state layer color with proper opacity
  static Color getStateLayerColor({
    required Color baseColor,
    required String state,
  }) {
    return M3EColors.getStateLayerColor(
      baseColor: baseColor,
      state: state,
    );
  }

  /// Apply state layer overlay to a surface color
  static Color applyStateLayer({
    required Color surface,
    required Color onSurface,
    required String state,
  }) {
    return M3EColors.applyStateLayer(
      surface: surface,
      onSurface: onSurface,
      state: state,
    );
  }

  /// Get hover color
  static Color getHoverColor(Color baseColor) {
    return getStateLayerColor(baseColor: baseColor, state: 'hover');
  }

  /// Get focus color
  static Color getFocusColor(Color baseColor) {
    return getStateLayerColor(baseColor: baseColor, state: 'focus');
  }

  /// Get press color
  static Color getPressColor(Color baseColor) {
    return getStateLayerColor(baseColor: baseColor, state: 'press');
  }

  /// Get drag color
  static Color getDragColor(Color baseColor) {
    return getStateLayerColor(baseColor: baseColor, state: 'drag');
  }

  /// Get disabled content color
  static Color getDisabledContentColor(Color baseColor) {
    return baseColor.withValues(alpha: disabledContentOpacity);
  }

  /// Get disabled container color
  static Color getDisabledContainerColor(Color baseColor) {
    return baseColor.withValues(alpha: disabledContainerOpacity);
  }

  /// Get combined state layer color (for multiple simultaneous states)
  /// Example: hover + focus
  static Color getCombinedStateLayer({
    required Color surface,
    required Color stateLayerColor,
    bool isHovered = false,
    bool isFocused = false,
    bool isPressed = false,
    bool isDragged = false,
  }) {
    double totalOpacity = 0.0;

    if (isDragged) {
      totalOpacity = dragOpacity;
    } else if (isPressed) {
      totalOpacity = pressOpacity;
    } else {
      if (isHovered) totalOpacity += hoverOpacity;
      if (isFocused) totalOpacity += focusOpacity;
    }

    if (totalOpacity == 0.0) return surface;

    final overlayColor = stateLayerColor.withValues(alpha: totalOpacity.clamp(0.0, 1.0));
    return Color.alphaBlend(overlayColor, surface);
  }
}

/// Widget wrapper that automatically applies state layers
///
/// Wraps any interactive widget with automatic state layer handling.
class StateLayerWidget extends StatelessWidget {
  /// Child widget to wrap
  final Widget child;

  /// Base color for state layers
  final Color baseColor;

  /// Whether to show hover state
  final bool showHover;

  /// Whether to show focus state
  final bool showFocus;

  /// Whether to show press state
  final bool showPress;

  /// Custom state layer builder
  final Widget Function(BuildContext context, String state, Widget child)? builder;

  const StateLayerWidget({
    super.key,
    required this.child,
    required this.baseColor,
    this.showHover = true,
    this.showFocus = true,
    this.showPress = true,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: null, // Handled by child
        hoverColor: showHover ? M3EStateLayer.getHoverColor(baseColor) : null,
        focusColor: showFocus ? M3EStateLayer.getFocusColor(baseColor) : null,
        splashColor: showPress ? M3EStateLayer.getPressColor(baseColor) : null,
        highlightColor: showPress ? M3EStateLayer.getPressColor(baseColor) : null,
        child: builder != null
            ? builder!(context, 'default', child)
            : child,
      ),
    );
  }
}

/// State layer overlay widget
///
/// Applies a state layer overlay on top of a widget.
class StateLayerOverlay extends StatelessWidget {
  /// Child widget
  final Widget child;

  /// State layer color
  final Color stateLayerColor;

  /// State layer opacity
  final double opacity;

  const StateLayerOverlay({
    super.key,
    required this.child,
    required this.stateLayerColor,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Container(
            color: stateLayerColor.withValues(alpha: opacity),
          ),
        ),
      ],
    );
  }
}


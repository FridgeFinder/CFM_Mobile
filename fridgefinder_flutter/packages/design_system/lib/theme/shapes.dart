import 'package:flutter/material.dart';

/// Material 3 Shape System
///
/// Defines the rounded corner system used throughout M3 components.
/// M3 uses a scale from none (0) to extra large (28dp) with specific
/// assignments for each component type.
class M3EShapes {
  M3EShapes._();

  // ============================================================================
  // CORNER RADIUS SCALE
  // ============================================================================

  /// No rounding (0dp) - Used for: Dividers, some text fields in filled state
  static const double none = 0.0;

  /// Extra small (4dp) - Used for: Checkboxes, radio buttons, small chips
  static const double extraSmall = 4.0;

  /// Extra small top (4dp top, 0dp bottom)
  static const double extraSmallTop = 4.0;

  /// Small (8dp) - Used for: Buttons, badges, filled text fields
  static const double small = 8.0;

  /// Medium (12dp) - Used for: Cards, outlined text fields, search bars, chips
  static const double medium = 12.0;

  /// Large (16dp) - Used for: FABs, extended FABs, navigation drawer items
  static const double large = 16.0;

  /// Extra large (28dp) - Used for: Dialogs, bottom sheets, modals
  static const double extraLarge = 28.0;

  /// Full (9999dp) - Used for: Pill-shaped elements like filter chips
  static const double full = 9999.0;

  // ============================================================================
  // COMPONENT-SPECIFIC SHAPES
  // ============================================================================

  /// Buttons (all variants: Filled, Outlined, Text, Elevated, Tonal)
  static const ShapeBorder button = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(full)),
  );

  /// Cards (Elevated, Filled, Outlined)
  static const ShapeBorder card = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(medium)),
  );

  /// Chips (Assist, Filter, Input, Suggestion)
  static const ShapeBorder chip = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(small)),
  );

  /// Dialogs (Standard, Full-screen)
  static const ShapeBorder dialog = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(extraLarge)),
  );

  /// FAB (Small, Medium, Large)
  static const ShapeBorder fab = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(large)),
  );

  /// Extended FAB
  static const ShapeBorder fabExtended = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(large)),
  );

  /// Text fields - Filled variant
  static const ShapeBorder textFieldFilled = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(extraSmallTop),
      bottom: Radius.zero,
    ),
  );

  /// Text fields - Outlined variant
  static const ShapeBorder textFieldOutlined = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(extraSmall)),
  );

  /// Bottom sheet
  static const ShapeBorder bottomSheet = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(extraLarge),
      bottom: Radius.zero,
    ),
  );

  /// Side sheet
  static const ShapeBorder sideSheet = RoundedRectangleBorder(
    borderRadius: BorderRadius.horizontal(
      left: Radius.circular(extraLarge),
      right: Radius.zero,
    ),
  );

  /// Navigation drawer
  static const ShapeBorder navigationDrawer = RoundedRectangleBorder(
    borderRadius: BorderRadius.horizontal(
      right: Radius.circular(large),
      left: Radius.zero,
    ),
  );

  /// Navigation drawer item (when selected)
  static const ShapeBorder navigationDrawerItem = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(full)),
  );

  /// Navigation bar (bottom)
  static const ShapeBorder navigationBar = RoundedRectangleBorder(
    borderRadius: BorderRadius.zero,
  );

  /// Navigation rail
  static const ShapeBorder navigationRail = RoundedRectangleBorder(
    borderRadius: BorderRadius.zero,
  );

  /// Search bar
  static const ShapeBorder searchBar = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(full)),
  );

  /// Search view
  static const ShapeBorder searchView = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(extraLarge)),
  );

  /// Snackbar
  static const ShapeBorder snackbar = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(extraSmall)),
  );

  /// Tooltip
  static const ShapeBorder tooltip = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(extraSmall)),
  );

  /// Badge
  static const ShapeBorder badge = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(full)),
  );

  /// Menu
  static const ShapeBorder menu = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(extraSmall)),
  );

  /// Banner
  static const ShapeBorder banner = RoundedRectangleBorder(
    borderRadius: BorderRadius.zero,
  );

  // ============================================================================
  // HELPER FUNCTIONS
  // ============================================================================

  /// Create a rounded rectangle shape with specified radius
  static ShapeBorder rounded(double radius) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
    );
  }

  /// Create a rounded rectangle with different radii for each corner
  static ShapeBorder roundedCustom({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(topLeft),
        topRight: Radius.circular(topRight),
        bottomLeft: Radius.circular(bottomLeft),
        bottomRight: Radius.circular(bottomRight),
      ),
    );
  }

  /// Create a pill shape (fully rounded)
  static const ShapeBorder pill = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(full)),
  );

  /// Create top-rounded shape (for bottom sheets, drawers)
  static ShapeBorder topRounded(double radius) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(radius),
        bottom: Radius.zero,
      ),
    );
  }

  /// Create bottom-rounded shape
  static ShapeBorder bottomRounded(double radius) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.zero,
        bottom: Radius.circular(radius),
      ),
    );
  }

  /// Create start-rounded shape (for RTL-aware components)
  static ShapeBorder startRounded(double radius) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadiusDirectional.horizontal(
        start: Radius.circular(radius),
        end: Radius.zero,
      ),
    );
  }

  /// Create end-rounded shape (for RTL-aware components)
  static ShapeBorder endRounded(double radius) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadiusDirectional.horizontal(
        start: Radius.zero,
        end: Radius.circular(radius),
      ),
    );
  }
}

/// Shape morphing utilities for animated shape transitions
class M3EShapeMorph {
  M3EShapeMorph._();

  /// Interpolate between two border radii
  static BorderRadius lerpBorderRadius(
    BorderRadius begin,
    BorderRadius end,
    double t,
  ) {
    return BorderRadius.lerp(begin, end, t)!;
  }

  /// Interpolate between two shapes
  static ShapeBorder lerpShape(
    ShapeBorder begin,
    ShapeBorder end,
    double t,
  ) {
    return ShapeBorder.lerp(begin, end, t)!;
  }

  /// Create an animated shape that morphs between two shapes
  static Animation<ShapeBorder?> createShapeMorphAnimation({
    required AnimationController controller,
    required ShapeBorder begin,
    required ShapeBorder end,
    Curve curve = Curves.easeInOut,
  }) {
    return ShapeBorderTween(
      begin: begin,
      end: end,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Material 3 Spacing System
///
/// M3E uses a generous 4dp base spacing unit with a scale that emphasizes
/// breathing room and clear visual hierarchy.
///
/// The spacing scale is based on multiples of 4dp:
/// 0, 4, 8, 12, 16, 20, 24, 28, 32, 40, 48, 64, 80, 96, 120
class M3ESpacing {
  M3ESpacing._();

  // ============================================================================
  // BASE SPACING SCALE
  // ============================================================================

  static const double none = 0.0;
  static const double xxs = 4.0; // Extra extra small
  static const double xs = 8.0; // Extra small
  static const double sm = 12.0; // Small
  static const double md = 16.0; // Medium
  static const double lg = 20.0; // Large
  static const double xl = 24.0; // Extra large
  static const double xxl = 28.0; // Extra extra large
  static const double xxxl = 32.0; // Extra extra extra large
  static const double huge1 = 40.0;
  static const double huge2 = 48.0;
  static const double huge3 = 64.0;
  static const double huge4 = 80.0;
  static const double huge5 = 96.0;
  static const double huge6 = 120.0;

  // ============================================================================
  // COMPONENT-SPECIFIC SPACING
  // ============================================================================

  // Buttons
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: xl, // 24dp
    vertical: sm, // 12dp
  );

  static const EdgeInsets buttonIconPadding = EdgeInsets.symmetric(
    horizontal: md, // 16dp
    vertical: sm, // 12dp
  );

  static const double buttonIconGap = xs; // 8dp between icon and label

  // Cards
  static const EdgeInsets cardPadding = EdgeInsets.all(md); // 16dp
  static const EdgeInsets cardContentPadding = EdgeInsets.all(md); // 16dp
  static const double cardGap = md; // 16dp between cards

  // List items
  static const EdgeInsets listTilePadding = EdgeInsets.symmetric(
    horizontal: md, // 16dp
    vertical: xs, // 8dp
  );

  static const EdgeInsets listTileContentPadding = EdgeInsets.symmetric(
    horizontal: md, // 16dp
  );

  static const double listTileLeadingGap = md; // 16dp
  static const double listTileTrailingGap = md; // 16dp
  static const double listTileVerticalGap = xxs; // 4dp between title and subtitle

  // Dialogs
  static const EdgeInsets dialogPadding = EdgeInsets.all(xl); // 24dp
  static const EdgeInsets dialogTitlePadding = EdgeInsets.fromLTRB(xl, xl, xl, md); // 24, 24, 24, 16
  static const EdgeInsets dialogContentPadding = EdgeInsets.fromLTRB(xl, none, xl, xl); // 24, 0, 24, 24
  static const EdgeInsets dialogActionsPadding = EdgeInsets.fromLTRB(xl, md, xl, xl); // 24, 16, 24, 24
  static const double dialogActionsGap = xs; // 8dp between action buttons

  // Bottom sheets
  static const EdgeInsets bottomSheetPadding = EdgeInsets.all(md); // 16dp
  static const EdgeInsets bottomSheetContentPadding = EdgeInsets.symmetric(
    horizontal: md, // 16dp
    vertical: xs, // 8dp
  );
  static const double bottomSheetDragHandleMargin = sm; // 12dp

  // Text fields
  static const EdgeInsets textFieldPadding = EdgeInsets.symmetric(
    horizontal: md, // 16dp
    vertical: md, // 16dp
  );

  static const EdgeInsets textFieldContentPadding = EdgeInsets.symmetric(
    horizontal: md, // 16dp
    vertical: sm, // 12dp
  );

  static const double textFieldIconGap = sm; // 12dp
  static const double textFieldLabelGap = xxs; // 4dp
  static const double textFieldHelperGap = xxs; // 4dp

  // Chips
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: sm, // 12dp
    vertical: xxs, // 4dp
  );

  static const double chipIconGap = xs; // 8dp
  static const double chipGap = xs; // 8dp between chips

  // Snackbars
  static const EdgeInsets snackbarPadding = EdgeInsets.symmetric(
    horizontal: md, // 16dp
    vertical: sm, // 12dp
  );

  static const EdgeInsets snackbarMargin = EdgeInsets.all(xs); // 8dp
  static const double snackbarActionGap = xs; // 8dp

  // App bars
  static const double appBarHeight = 64.0; // M3 standard app bar height
  static const EdgeInsets appBarPadding = EdgeInsets.symmetric(
    horizontal: xxs, // 4dp
  );

  static const EdgeInsets appBarTitlePadding = EdgeInsets.symmetric(
    horizontal: md, // 16dp
  );

  // Navigation
  static const EdgeInsets navigationBarPadding = EdgeInsets.symmetric(
    horizontal: xs, // 8dp
    vertical: sm, // 12dp
  );

  static const double navigationBarHeight = 80.0;
  static const double navigationBarItemGap = xxs; // 4dp

  static const EdgeInsets navigationDrawerPadding = EdgeInsets.symmetric(
    horizontal: sm, // 12dp
    vertical: sm, // 12dp
  );

  static const EdgeInsets navigationDrawerItemPadding = EdgeInsets.symmetric(
    horizontal: md, // 16dp
    vertical: sm, // 12dp
  );

  static const double navigationDrawerItemGap = xxs; // 4dp between items

  static const EdgeInsets navigationRailPadding = EdgeInsets.symmetric(
    vertical: xxs, // 4dp
  );

  static const double navigationRailWidth = 80.0;

  // Menus
  static const EdgeInsets menuPadding = EdgeInsets.symmetric(
    vertical: xs, // 8dp
  );

  static const EdgeInsets menuItemPadding = EdgeInsets.symmetric(
    horizontal: sm, // 12dp
    vertical: sm, // 12dp
  );

  static const double menuItemGap = none; // No gap between menu items
  static const double menuIconGap = sm; // 12dp

  // Tooltips
  static const EdgeInsets tooltipPadding = EdgeInsets.symmetric(
    horizontal: sm, // 12dp
    vertical: xxs, // 4dp
  );

  static const EdgeInsets tooltipMargin = EdgeInsets.all(xxs); // 4dp

  // FAB
  static const EdgeInsets fabPadding = EdgeInsets.all(md); // 16dp
  static const EdgeInsets fabExtendedPadding = EdgeInsets.symmetric(
    horizontal: lg, // 20dp
    vertical: md, // 16dp
  );
  static const double fabIconGap = xs; // 8dp

  // Badges
  static const EdgeInsets badgePadding = EdgeInsets.symmetric(
    horizontal: xxs, // 4dp
    vertical: xxs, // 4dp
  );

  static const double badgeOffset = xxs; // 4dp

  // Search
  static const EdgeInsets searchBarPadding = EdgeInsets.symmetric(
    horizontal: md, // 16dp
    vertical: xs, // 8dp
  );

  static const EdgeInsets searchBarContentPadding = EdgeInsets.symmetric(
    horizontal: md, // 16dp
  );

  // Tabs
  static const EdgeInsets tabPadding = EdgeInsets.symmetric(
    horizontal: md, // 16dp
    vertical: sm, // 12dp
  );

  static const double tabIconGap = xs; // 8dp
  static const double tabGap = none; // No gap between tabs

  // ============================================================================
  // LAYOUT HELPERS
  // ============================================================================

  /// Vertical spacing widget
  static Widget vertical(double height) => SizedBox(height: height);

  /// Horizontal spacing widget
  static Widget horizontal(double width) => SizedBox(width: width);

  /// Gap widget - modern approach using Gap from flutter
  static Widget gap(double size) => SizedBox.square(dimension: size);

  // Common vertical spacers
  static Widget get verticalXXS => SizedBox(height: xxs);
  static Widget get verticalXS => SizedBox(height: xs);
  static Widget get verticalSM => SizedBox(height: sm);
  static Widget get verticalMD => SizedBox(height: md);
  static Widget get verticalLG => SizedBox(height: lg);
  static Widget get verticalXL => SizedBox(height: xl);
  static Widget get verticalXXL => SizedBox(height: xxl);

  // Common horizontal spacers
  static Widget get horizontalXXS => SizedBox(width: xxs);
  static Widget get horizontalXS => SizedBox(width: xs);
  static Widget get horizontalSM => SizedBox(width: sm);
  static Widget get horizontalMD => SizedBox(width: md);
  static Widget get horizontalLG => SizedBox(width: lg);
  static Widget get horizontalXL => SizedBox(width: xl);
  static Widget get horizontalXXL => SizedBox(width: xxl);

  /// Create padding from a single value
  static EdgeInsets all(double value) => EdgeInsets.all(value);

  /// Create symmetric padding
  static EdgeInsets symmetric({double? horizontal, double? vertical}) {
    return EdgeInsets.symmetric(
      horizontal: horizontal ?? 0,
      vertical: vertical ?? 0,
    );
  }

  /// Create padding with specific values for each side
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }

  /// Create padding with LTRB values
  static EdgeInsets fromLTRB(
    double left,
    double top,
    double right,
    double bottom,
  ) {
    return EdgeInsets.fromLTRB(left, top, right, bottom);
  }
}

/// Responsive spacing that adapts to screen size
class M3EResponsiveSpacing {
  M3EResponsiveSpacing._();

  /// Get responsive spacing based on screen width
  static double getResponsive(BuildContext context, {
    required double compact,
    required double medium,
    required double expanded,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (width < 600) {
      return compact;
    } else if (width < 840) {
      return medium;
    } else {
      return expanded;
    }
  }

  /// Get responsive horizontal padding
  static EdgeInsets getHorizontalPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: getResponsive(
        context,
        compact: M3ESpacing.md, // 16dp
        medium: M3ESpacing.xl, // 24dp
        expanded: M3ESpacing.xxxl, // 32dp
      ),
    );
  }

  /// Get responsive content padding
  static EdgeInsets getContentPadding(BuildContext context) {
    return EdgeInsets.all(
      getResponsive(
        context,
        compact: M3ESpacing.md, // 16dp
        medium: M3ESpacing.xl, // 24dp
        expanded: M3ESpacing.xxxl, // 32dp
      ),
    );
  }
}

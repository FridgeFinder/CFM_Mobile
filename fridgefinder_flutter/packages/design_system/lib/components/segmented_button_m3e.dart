import 'package:flutter/material.dart';
import '../theme/motion.dart';

/// Material 3 Expressive Segmented Button
///
/// A segmented button is a set of 2-5 clickable buttons (segments) grouped together
/// in a horizontal row. Each segment is a discrete button that can be selected/deselected.
///
/// ## Features
/// - Single-select mode (default): Mutually exclusive selection like radio buttons
/// - Multi-select mode: Multiple segments can be selected simultaneously
/// - M3E styling: Proper colors, shapes, and animations
/// - Accessibility: 48dp touch targets, semantic labels
/// - Responsive animations: Smooth 200ms selection transitions
///
/// ## Visual Specifications
/// - Height: 40dp with 48dp touch target
/// - Border radius: 20dp (fully rounded pill shape)
/// - First segment: Top-left + bottom-left rounded
/// - Middle segments: Square corners (no rounding)
/// - Last segment: Top-right + bottom-right rounded
/// - Selected: Filled with secondaryContainer, text in onSecondaryContainer
/// - Unselected: Transparent background, text in onSurface
/// - Border: outline color around entire group
/// - Label padding: 12-24px horizontal (scales with content)
///
/// ## Animation Specifications
/// - Selection indicator slide: 200ms with M3EMotion.responsiveSpring
/// - Background color transition: 150ms with emphasized curve
/// - Text color transition: 150ms with emphasized curve
/// - Elevation change (if applicable): 150ms
///
/// ## Usage Examples
///
/// ### Single-select mode (default - like radio buttons):
/// ```dart
/// enum Calendar { day, week, month }
///
/// Calendar selectedView = Calendar.day;
///
/// SegmentedButtonM3E<Calendar>(
///   segments: const [
///     ButtonSegment(
///       value: Calendar.day,
///       label: Text('Day'),
///       icon: Icon(Icons.calendar_view_day),
///     ),
///     ButtonSegment(
///       value: Calendar.week,
///       label: Text('Week'),
///       icon: Icon(Icons.calendar_view_week),
///     ),
///     ButtonSegment(
///       value: Calendar.month,
///       label: Text('Month'),
///       icon: Icon(Icons.calendar_view_month),
///     ),
///   ],
///   selected: {selectedView},
///   onSelectionChanged: (Set<Calendar> newSelection) {
///     setState(() {
///       selectedView = newSelection.first;
///     });
///   },
/// )
/// ```
///
/// ### Multi-select mode (like checkboxes):
/// ```dart
/// enum Sizes { extraSmall, small, medium, large, extraLarge }
///
/// Set<Sizes> selectedSizes = {Sizes.large};
///
/// SegmentedButtonM3E<Sizes>(
///   segments: const [
///     ButtonSegment(value: Sizes.extraSmall, label: Text('XS')),
///     ButtonSegment(value: Sizes.small, label: Text('S')),
///     ButtonSegment(value: Sizes.medium, label: Text('M')),
///     ButtonSegment(value: Sizes.large, label: Text('L')),
///     ButtonSegment(value: Sizes.extraLarge, label: Text('XL')),
///   ],
///   selected: selectedSizes,
///   onSelectionChanged: (Set<Sizes> newSelection) {
///     setState(() {
///       selectedSizes = newSelection;
///     });
///   },
///   multiSelectionEnabled: true,
///   showSelectedIcon: false, // Icons take up space in tight layouts
/// )
/// ```
///
/// ### Icon-only segments (compact):
/// ```dart
/// enum ViewMode { grid, list }
///
/// ViewMode viewMode = ViewMode.grid;
///
/// SegmentedButtonM3E<ViewMode>(
///   segments: const [
///     ButtonSegment(
///       value: ViewMode.grid,
///       icon: Icon(Icons.grid_view),
///       tooltip: 'Grid view',
///     ),
///     ButtonSegment(
///       value: ViewMode.list,
///       icon: Icon(Icons.view_list),
///       tooltip: 'List view',
///     ),
///   ],
///   selected: {viewMode},
///   onSelectionChanged: (Set<ViewMode> newSelection) {
///     setState(() {
///       viewMode = newSelection.first;
///     });
///   },
///   showSelectedIcon: false,
/// )
/// ```
///
/// ### With custom styling:
/// ```dart
/// SegmentedButtonM3E<String>(
///   segments: const [
///     ButtonSegment(value: 'all', label: Text('All')),
///     ButtonSegment(value: 'active', label: Text('Active')),
///     ButtonSegment(value: 'completed', label: Text('Completed')),
///   ],
///   selected: {'all'},
///   onSelectionChanged: (newSelection) {
///     // Handle selection
///   },
///   showSelectedIcon: true,
///   emptySelectionAllowed: false, // Ensure at least one is selected
/// )
/// ```
///
/// ## Design Guidelines
///
/// ### When to use:
/// - Selecting between 2-5 related options
/// - Options are of equal importance
/// - User needs to see all options at once
/// - Compact horizontal layout is desired
///
/// ### When NOT to use:
/// - More than 5 options (use Dropdown or Chips instead)
/// - Options need explanation (use Radio with descriptions)
/// - Vertical layout preferred (use Radio/Checkbox list)
/// - Action buttons (use Button row instead)
///
/// ### Best practices:
/// - Keep labels short (1-2 words, max 3)
/// - Use consistent icon style across segments
/// - Ensure at least one segment is always selected in single-select mode
/// - Use multi-select for independent options (like filters)
/// - Use single-select for mutually exclusive options (like view modes)
///
/// ## Accessibility
/// - Proper semantic labels for screen readers
/// - 48dp minimum touch target size (automatically applied)
/// - High contrast text colors for readability
/// - Focus indicators for keyboard navigation
/// - Tooltips supported via ButtonSegment.tooltip
class SegmentedButtonM3E<T> extends StatelessWidget {
  /// The list of button segments to display.
  ///
  /// Must contain at least 2 segments. Each segment should have:
  /// - [ButtonSegment.value]: Unique identifier for this segment
  /// - [ButtonSegment.label]: Text to display (optional if icon provided)
  /// - [ButtonSegment.icon]: Icon to display (optional if label provided)
  /// - [ButtonSegment.enabled]: Whether segment is interactive (default: true)
  /// - [ButtonSegment.tooltip]: Tooltip for accessibility (optional)
  ///
  /// At least one of [label] or [icon] must be provided for each segment.
  final List<ButtonSegment<T>> segments;

  /// The set of currently selected segment values.
  ///
  /// In single-select mode (default): Should contain 0 or 1 element
  /// In multi-select mode: Can contain 0 to N elements
  ///
  /// The selected set must only contain values that exist in [segments].
  final Set<T> selected;

  /// Callback when selection changes.
  ///
  /// Receives a [Set<T>] containing the new selection:
  /// - Single-select mode: Set will have 0 or 1 element
  /// - Multi-select mode: Set can have 0 to N elements
  ///
  /// If null, the segmented button is read-only (display only).
  final ValueChanged<Set<T>>? onSelectionChanged;

  /// Whether multiple segments can be selected simultaneously.
  ///
  /// - false (default): Single-select mode - acts like radio buttons
  ///   - Selecting a new segment deselects the previous one
  ///   - User can deselect by tapping selected segment (unless [emptySelectionAllowed] is false)
  /// - true: Multi-select mode - acts like checkboxes
  ///   - Multiple segments can be selected at once
  ///   - Tapping toggles individual segments
  final bool multiSelectionEnabled;

  /// Whether to show a checkmark icon on selected segments.
  ///
  /// - true (default): Shows checkmark icon when segment is selected
  /// - false: No icon shown, only background color changes
  ///
  /// Consider setting to false when:
  /// - Using icon-only segments (icons provide visual indication)
  /// - Horizontal space is limited
  /// - Design calls for minimal visual clutter
  final bool showSelectedIcon;

  /// Whether the selection can be empty.
  ///
  /// - true (default): User can deselect all segments
  /// - false: At least one segment must always be selected
  ///
  /// In single-select mode with [emptySelectionAllowed] = false:
  /// - Tapping selected segment does nothing (stays selected)
  /// - Useful for view modes where a choice is required
  final bool emptySelectionAllowed;

  /// Custom style overrides for the segmented button.
  ///
  /// If null, uses theme defaults with M3E specifications:
  /// - Selected: secondaryContainer background, onSecondaryContainer text
  /// - Unselected: transparent background, onSurface text
  /// - Border: outline color
  /// - Shape: Fully rounded ends (20dp radius)
  final ButtonStyle? style;

  /// Creates a Material 3 Expressive segmented button.
  ///
  /// The [segments] must contain at least 2 button segments.
  /// The [selected] set should contain values from [segments].
  const SegmentedButtonM3E({
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Build the M3E styled segmented button
    return SegmentedButton<T>(
      segments: segments,
      selected: selected,
      onSelectionChanged: onSelectionChanged,
      multiSelectionEnabled: multiSelectionEnabled,
      emptySelectionAllowed: emptySelectionAllowed,
      showSelectedIcon: showSelectedIcon,
      style: style ?? _buildM3EStyle(context, colorScheme),
    );
  }

  /// Builds the M3E button style with proper specifications
  ButtonStyle _buildM3EStyle(BuildContext context, ColorScheme colorScheme) {
    return ButtonStyle(
      // Background color: secondaryContainer when selected, transparent otherwise
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.secondaryContainer;
          }
          return Colors.transparent;
        },
      ),

      // Foreground color: onSecondaryContainer when selected, onSurface otherwise
      foregroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(alpha: 0.38);
          }
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onSecondaryContainer;
          }
          return colorScheme.onSurface;
        },
      ),

      // Icon color: matches foreground color
      iconColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(alpha: 0.38);
          }
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onSecondaryContainer;
          }
          return colorScheme.onSurface;
        },
      ),

      // Border side: outline color around entire group
      side: WidgetStateProperty.resolveWith<BorderSide>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(
              color: colorScheme.onSurface.withValues(alpha: 0.12),
              width: 1.0,
            );
          }
          return BorderSide(
            color: colorScheme.outline,
            width: 1.0,
          );
        },
      ),

      // Shape: First segment has left rounded, last has right rounded, middle is square
      // Flutter's SegmentedButton handles this automatically with 20dp radius
      shape: WidgetStateProperty.all<OutlinedBorder>(
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
      ),

      // Padding: 12-24px horizontal for comfortable tap targets
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
      ),

      // Minimum size: 40dp height as per M3 spec
      minimumSize: WidgetStateProperty.all<Size>(
        const Size.fromHeight(40.0),
      ),

      // Maximum size: Constrain height, allow width to grow
      maximumSize: WidgetStateProperty.all<Size>(
        const Size.fromHeight(40.0),
      ),

      // Tap target size: Padded for 48dp minimum touch target
      tapTargetSize: MaterialTapTargetSize.padded,

      // Visual density: Compact for tight layouts
      visualDensity: VisualDensity.compact,

      // Elevation: Flat design, no shadow
      elevation: WidgetStateProperty.all<double>(0.0),

      // Animation duration: Smooth, expressive transitions
      animationDuration: M3EMotion.medium3, // 350ms for more noticeable transitions

      // Overlay color: State layers for press/hover/focus
      overlayColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return colorScheme.onSecondaryContainer.withValues(alpha: 0.12);
          }
          if (states.contains(WidgetState.hovered)) {
            return colorScheme.onSecondaryContainer.withValues(alpha: 0.08);
          }
          if (states.contains(WidgetState.focused)) {
            return colorScheme.onSecondaryContainer.withValues(alpha: 0.12);
          }
          return Colors.transparent;
        },
      ),

      // Mouse cursor: Pointer on enabled, forbidden on disabled
      mouseCursor: WidgetStateProperty.resolveWith<MouseCursor>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return SystemMouseCursors.forbidden;
          }
          return SystemMouseCursors.click;
        },
      ),

      // Text style: Body medium from theme
      textStyle: WidgetStateProperty.all<TextStyle>(
        Theme.of(context).textTheme.labelLarge ?? const TextStyle(),
      ),

      // Icon size: Standard 18dp for segmented buttons
      iconSize: WidgetStateProperty.all<double>(18.0),

      // Alignment: Center content in each segment
      alignment: Alignment.center,
    );
  }
}

/// Extension methods for common segmented button use cases
extension SegmentedButtonM3EHelpers<T> on List<T> {
  /// Creates ButtonSegment list from enum values with custom label builder
  ///
  /// Example:
  /// ```dart
  /// enum Size { small, medium, large }
  ///
  /// final segments = Size.values.toSegments(
  ///   labelBuilder: (size) => Text(size.name.toUpperCase()),
  /// );
  /// ```
  List<ButtonSegment<T>> toSegments({
    required Widget Function(T value) labelBuilder,
    Widget Function(T value)? iconBuilder,
    bool Function(T value)? enabledBuilder,
    String Function(T value)? tooltipBuilder,
  }) {
    return map((value) {
      return ButtonSegment<T>(
        value: value,
        label: labelBuilder(value),
        icon: iconBuilder?.call(value),
        enabled: enabledBuilder?.call(value) ?? true,
        tooltip: tooltipBuilder?.call(value),
      );
    }).toList();
  }
}

/// Helper function to create simple text-only segments from strings
///
/// Example:
/// ```dart
/// final segments = createTextSegments(['Option A', 'Option B', 'Option C']);
/// ```
List<ButtonSegment<String>> createTextSegments(List<String> labels) {
  return labels.map((label) {
    return ButtonSegment<String>(
      value: label,
      label: Text(label),
    );
  }).toList();
}

/// Helper function to create icon-label segments
///
/// Example:
/// ```dart
/// final segments = createIconLabelSegments([
///   (Icons.home, 'Home', 'home'),
///   (Icons.search, 'Search', 'search'),
///   (Icons.person, 'Profile', 'profile'),
/// ]);
/// ```
List<ButtonSegment<String>> createIconLabelSegments(
  List<(IconData icon, String label, String value)> items,
) {
  return items.map((item) {
    final (icon, label, value) = item;
    return ButtonSegment<String>(
      value: value,
      icon: Icon(icon),
      label: Text(label),
    );
  }).toList();
}

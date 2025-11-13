# NavigationDrawerM3E

A Material 3 Expressive navigation drawer component that follows the latest M3 design specifications with enhanced animations and proper styling.

## Features

- **M3E Compliant**: Follows Material 3 Expressive specifications
- **Increased Width**: 360dp (increased from MD2's 304dp)
- **Smooth Animations**: Uses spring-based motion for natural, expressive animations
- **Flexible Layout**: Support for headers, footers, sections, and dividers
- **Badge Support**: Built-in badge indicators for notifications
- **Modal Variant**: Full support for modal drawers with scrim
- **Accessibility**: Proper semantic labels and interaction patterns

## Specifications

### Dimensions
- **Width**: 360dp
- **Item Height**: 56dp per destination
- **Active Indicator**: Pill-shaped, full width minus 24dp margins
- **Item Spacing**: 12dp vertical between items
- **Section Divider**: 1dp with 8dp vertical margins

### Colors
- **Background**: `surfaceContainerLow`
- **Selected Indicator**: `secondaryContainer` with pill shape
- **Icon Size**: 24dp
- **Label Typography**: `labelLarge`

### Animations
- **Slide In**: 350ms with `M3EMotion.gentleSpring` from left
- **Indicator Slide**: 300ms with `M3EMotion.responsiveSpring`
- **Scrim Fade**: 300ms for modal variant
- **Press Feedback**: Scale animation with spring physics

## Basic Usage

```dart
NavigationDrawerM3E(
  selectedIndex: _selectedIndex,
  onDestinationSelected: (index) {
    setState(() => _selectedIndex = index);
  },
  destinations: const [
    NavigationDrawerDestinationM3E(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: Text('Home'),
    ),
    NavigationDrawerDestinationM3E(
      icon: Icon(Icons.explore_outlined),
      selectedIcon: Icon(Icons.explore),
      label: Text('Explore'),
    ),
    NavigationDrawerDestinationM3E(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: Text('Settings'),
    ),
  ],
)
```

## With Header and Footer

```dart
NavigationDrawerM3E(
  selectedIndex: _selectedIndex,
  onDestinationSelected: (index) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context); // Close drawer after selection
  },
  destinations: _destinations,
  header: DrawerHeader(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: 32,
          child: Icon(Icons.person),
        ),
        SizedBox(height: 12),
        Text('John Doe', style: TextStyle(fontSize: 20)),
        Text('john.doe@example.com'),
      ],
    ),
  ),
  footer: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Divider(),
      ListTile(
        leading: Icon(Icons.settings),
        title: Text('Settings'),
        onTap: () {
          // Navigate to settings
        },
      ),
    ],
  ),
)
```

## Modal Drawer

```dart
// Show modal drawer with scrim and animations
showModalNavigationDrawer(
  context: context,
  builder: (context) => NavigationDrawerM3E(
    selectedIndex: _selectedIndex,
    onDestinationSelected: (index) {
      setState(() => _selectedIndex = index);
      Navigator.pop(context);
    },
    destinations: _destinations,
  ),
);
```

## With Badges

```dart
NavigationDrawerDestinationM3E(
  icon: Icon(Icons.notifications_outlined),
  selectedIcon: Icon(Icons.notifications),
  label: Text('Notifications'),
  badge: Badge(
    label: Text('3'),
  ),
)

// Or dot badge
NavigationDrawerDestinationM3E(
  icon: Icon(Icons.message_outlined),
  selectedIcon: Icon(Icons.message),
  label: Text('Messages'),
  badge: Badge(
    smallSize: 8,
  ),
)
```

## With Sections and Dividers

You can create custom sections using standard widgets combined with the drawer:

```dart
Drawer(
  width: 360,
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      // Header
      DrawerHeader(...),

      // Section header
      NavigationDrawerSectionHeaderM3E(label: 'MAIN'),

      // Destinations (manually built or using NavigationDrawerM3E)
      _buildDrawerItem(0, 'Home'),
      _buildDrawerItem(1, 'Search'),

      // Divider
      NavigationDrawerDividerM3E(),

      // Another section
      NavigationDrawerSectionHeaderM3E(label: 'SETTINGS'),
      _buildDrawerItem(2, 'Settings'),
      _buildDrawerItem(3, 'Help'),
    ],
  ),
)
```

## Disabled Items

```dart
NavigationDrawerDestinationM3E(
  icon: Icon(Icons.delete_outlined),
  selectedIcon: Icon(Icons.delete),
  label: Text('Trash'),
  enabled: false, // Grays out and disables interaction
)
```

## Component Structure

### NavigationDrawerM3E

The main component that wraps Flutter's `Drawer` and `NavigationDrawer` widgets with M3E styling.

**Parameters:**
- `selectedIndex` (int, required): The index of the currently selected destination
- `onDestinationSelected` (ValueChanged<int>, required): Callback when a destination is selected
- `destinations` (List<NavigationDrawerDestinationM3E>, required): List of destinations to display
- `header` (Widget?, optional): Optional header widget at the top
- `footer` (Widget?, optional): Optional footer widget at the bottom
- `backgroundColor` (Color?, optional): Background color, defaults to `surfaceContainerLow`
- `elevation` (double?, optional): Elevation of the drawer

### NavigationDrawerDestinationM3E

Represents a single navigation destination in the drawer.

**Parameters:**
- `icon` (Widget, required): Icon to display when not selected
- `selectedIcon` (Widget?, optional): Icon to display when selected
- `label` (Widget, required): Label text for the destination
- `badge` (Widget?, optional): Optional badge widget
- `enabled` (bool, optional): Whether the destination is enabled, defaults to true

### NavigationDrawerDividerM3E

A divider for separating sections.

**Parameters:**
- `color` (Color?, optional): Color of the divider, defaults to `outlineVariant`
- `thickness` (double, optional): Thickness of the divider, defaults to 1.0
- `margin` (double, optional): Vertical margin around the divider, defaults to 8.0

### NavigationDrawerSectionHeaderM3E

A text header for labeling sections.

**Parameters:**
- `label` (String, required): The label text
- `color` (Color?, optional): Color of the label, defaults to `onSurfaceVariant`

## Modal Navigation Drawer Function

### showModalNavigationDrawer<T>

Shows a modal drawer with proper animations and scrim.

**Parameters:**
- `context` (BuildContext, required): The build context
- `builder` (WidgetBuilder, required): Builder function that returns the drawer widget
- `barrierColor` (Color?, optional): Color of the scrim barrier
- `barrierDismissible` (bool, optional): Whether tapping the scrim closes the drawer, defaults to true
- `barrierLabel` (String?, optional): Semantic label for the barrier
- `useRootNavigator` (bool, optional): Whether to use the root navigator, defaults to true

**Returns:** `Future<T?>` that resolves when the drawer is closed

## Animation Details

The NavigationDrawerM3E uses sophisticated animations for a polished user experience:

1. **Drawer Slide Animation** (350ms)
   - Uses `M3EMotion.gentleSpring` for natural, smooth entry
   - Slides in from the left with proper spring physics
   - Creates a sense of weight and physical presence

2. **Indicator Animation** (300ms)
   - Uses `M3EMotion.responsiveSpring` for snappy response
   - Smoothly transitions between selected states
   - Maintains visual continuity during navigation

3. **Press Feedback**
   - Scale animation (1.0 → 0.95) on press
   - Provides immediate tactile feedback
   - Reverses smoothly on release

4. **Icon Transition**
   - AnimatedSwitcher with scale transition
   - Seamlessly swaps between outlined and filled icons
   - Adds polish to the selection experience

5. **Scrim Fade** (300ms, Modal Only)
   - Smooth fade in/out of the backdrop
   - Coordinates with drawer slide for unified effect
   - Uses standard easing for backdrop transitions

## Best Practices

### Do's

✅ Use outlined icons for unselected state and filled icons for selected state
✅ Keep destination labels concise (1-2 words)
✅ Use badges sparingly for important notifications
✅ Include a header when user context is important
✅ Close the drawer after navigation selection
✅ Use section headers to group related items
✅ Maintain consistent icon style across destinations

### Don'ts

❌ Don't use more than 7-10 destinations in a single drawer
❌ Don't mix different icon styles
❌ Don't use overly long labels that truncate
❌ Don't overuse badges (they lose impact)
❌ Don't forget to provide selected icon variants
❌ Don't nest multiple levels of navigation
❌ Don't use custom colors that break the M3E theme

## Accessibility

The NavigationDrawerM3E is built with accessibility in mind:

- **Semantic Labels**: All destinations have proper semantic labels from their text
- **Touch Targets**: 56dp height ensures minimum touch target size
- **Color Contrast**: Uses theme colors with sufficient contrast ratios
- **Focus Indicators**: Standard Material focus indicators work automatically
- **Screen Readers**: Compatible with TalkBack and VoiceOver
- **Keyboard Navigation**: Supports keyboard navigation when used on desktop

## Responsive Behavior

The drawer adapts to different screen sizes:

- **Compact** (<600dp): Modal drawer recommended, shown on demand
- **Medium** (600-840dp): Can use either modal or standard persistent drawer
- **Expanded** (>840dp): Standard persistent drawer or navigation rail recommended

## Integration with Scaffold

### Standard Drawer

```dart
Scaffold(
  appBar: AppBar(
    leading: Builder(
      builder: (context) => IconButton(
        icon: Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
    ),
  ),
  drawer: NavigationDrawerM3E(...),
  body: YourContent(),
)
```

### End Drawer (Right Side)

```dart
Scaffold(
  appBar: AppBar(
    actions: [
      Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openEndDrawer(),
        ),
      ),
    ],
  ),
  endDrawer: NavigationDrawerM3E(...),
  body: YourContent(),
)
```

## Examples

See `navigation_drawer_m3e_example.dart` for comprehensive examples including:

- Standard drawer with header and footer
- Modal drawer variant
- Complex drawer with sections and dividers
- Badge indicators
- Disabled destinations
- Custom styling options

## Related Components

- **NavigationBarM3E**: For bottom navigation
- **NavigationRailM3E**: For side navigation on larger screens
- **TabsM3E**: For tab-based navigation

## References

- [Material 3 Navigation Drawer Guidelines](https://m3.material.io/components/navigation-drawer)
- [M3E Motion System](../theme/motion.dart)
- [M3E Spacing System](../theme/spacing.dart)

# FAB M3E Components

Comprehensive Material 3 Expressive Floating Action Button components with advanced animations and state management.

## Table of Contents

- [Overview](#overview)
- [Components](#components)
- [Visual Specifications](#visual-specifications)
- [Animations](#animations)
- [Usage Examples](#usage-examples)
- [API Reference](#api-reference)

## Overview

This module provides complete M3E FAB implementation with:

- **FABM3E**: Main FAB widget with size variants (Small, Regular, Large, Extended)
- **IconButtonM3E**: Icon buttons with variants (Standard, Filled, Tonal, Outlined)
- **FABMenuM3E**: Expandable FAB menu with staggered animations
- **ExtendedFABM3E**: FAB with expand/collapse animation

All components feature:
- Expressive spring-based animations
- Proper state layers (hover, focus, press)
- Accessibility support with tooltips
- RTL support
- Material 3 elevation and shadows
- Tonal variants

## Components

### 1. FABM3E - Main FAB Widget

The primary FAB component with three size variants.

#### Size Variants

| Variant | Size | Icon Size | Corner Radius | Elevation |
|---------|------|-----------|---------------|-----------|
| Small | 40x40dp | 24dp | 8dp | Level 3 |
| Regular | 56x56dp | 24dp | 16dp | Level 3 |
| Large | 96x96dp | 36dp | 28dp | Level 3 |
| Extended | 56dp height | 24dp | 16dp | Level 3 |

#### Basic Usage

```dart
// Regular FAB
FABM3E(
  icon: Icons.add,
  onPressed: () {
    // Handle press
  },
)

// Small FAB
FABM3E(
  icon: Icons.edit,
  size: FABSize.small,
  onPressed: () {},
)

// Large FAB
FABM3E(
  icon: Icons.add,
  size: FABSize.large,
  onPressed: () {},
)

// Extended FAB
FABM3E(
  icon: Icons.add,
  label: 'Create',
  onPressed: () {},
)

// Tonal FAB
FABM3E(
  icon: Icons.edit,
  tonal: true,
  onPressed: () {},
)
```

### 2. IconButtonM3E - Icon Button Variants

Icon buttons with four style variants and toggle support.

#### Variants

| Variant | Background | Use Case |
|---------|-----------|----------|
| Standard | None | Default actions in app bars, toolbars |
| Filled | Primary | High-emphasis actions |
| Tonal | Secondary Container | Medium-emphasis actions |
| Outlined | Outline border | Actions needing clear boundaries |

#### Basic Usage

```dart
// Standard
IconButtonM3E(
  icon: Icons.favorite,
  onPressed: () {},
)

// Filled
IconButtonM3E(
  icon: Icons.favorite,
  variant: IconButtonVariant.filled,
  onPressed: () {},
)

// Tonal
IconButtonM3E(
  icon: Icons.favorite,
  variant: IconButtonVariant.tonal,
  onPressed: () {},
)

// Outlined
IconButtonM3E(
  icon: Icons.favorite_border,
  variant: IconButtonVariant.outlined,
  onPressed: () {},
)

// Toggle button
IconButtonM3E(
  icon: Icons.favorite_border,
  selectedIcon: Icons.favorite,
  selected: isFavorite,
  onSelectedChanged: (selected) {
    setState(() => isFavorite = selected);
  },
  variant: IconButtonVariant.filled,
)
```

### 3. FABMenuM3E - Expandable FAB Menu

A FAB that expands to reveal multiple action buttons with staggered animations.

#### Features

- Backdrop scrim with fade animation
- Child FABs with 50ms stagger delay
- Labels with slide + fade animations
- Four expansion directions (up, down, left, right)
- Automatic menu closure on item selection

#### Usage

```dart
FABMenuM3E(
  icon: Icons.add,
  openIcon: Icons.close,
  tooltip: 'Create new',
  showLabels: true,
  direction: FABMenuDirection.up,
  items: [
    FABMenuItem(
      icon: Icons.photo,
      label: 'Photo',
      onPressed: () {
        // Handle photo
      },
    ),
    FABMenuItem(
      icon: Icons.video_library,
      label: 'Video',
      onPressed: () {
        // Handle video
      },
    ),
    FABMenuItem(
      icon: Icons.article,
      label: 'Document',
      onPressed: () {
        // Handle document
      },
    ),
  ],
)
```

### 4. ExtendedFABM3E - Animated Extended FAB

A FAB that can smoothly animate between icon-only and extended (icon + label) states.

#### Usage

```dart
ExtendedFABM3E(
  icon: Icons.edit,
  label: 'Edit',
  expanded: isExpanded, // Control via state
  onPressed: () {},
)

// Typical usage with ScrollController
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final isScrolling = _scrollController.position.isScrollingNotifier.value;
      if (isScrolling != !_isExpanded) {
        setState(() {
          _isExpanded = !isScrolling;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        controller: _scrollController,
        children: [...],
      ),
      floatingActionButton: ExtendedFABM3E(
        icon: Icons.add,
        label: 'Create',
        expanded: _isExpanded,
        onPressed: () {},
      ),
    );
  }
}
```

## Visual Specifications

### Colors

| Variant | Background | Foreground | Container |
|---------|-----------|----------|-----------|
| Primary FAB | primary | onPrimary | - |
| Tonal FAB | secondaryContainer | onSecondaryContainer | - |
| Standard Icon | - | onSurfaceVariant | - |
| Filled Icon | primary | onPrimary | primary |
| Tonal Icon | secondaryContainer | onSecondaryContainer | secondaryContainer |
| Outlined Icon | - | onSurfaceVariant | outline border |

### State Layers

| State | Opacity |
|-------|---------|
| Hover | 8% |
| Focus | 12% |
| Press | 12% |
| Drag | 16% |

### Elevation Levels

| Component | Default | Hover | Pressed |
|-----------|---------|-------|---------|
| FAB | Level 3 (6dp) | Level 4 (8dp) | Level 3 (6dp) |
| Icon Button | Level 0 | Level 1 | Level 0 |

### Shadow System

M3E uses a 3-shadow system for depth:

1. **Umbra**: Dark, sharp shadow directly below
2. **Penumbra**: Medium, soft shadow slightly offset
3. **Ambient**: Light, very soft shadow with large spread

## Animations

### FAB Entrance Animation

- **Duration**: 300ms
- **Curve**: Expressive spring
- **Effect**: Scale from 0 to 1.0

```dart
FABM3E(
  icon: Icons.add,
  visible: _isVisible,
  onPressed: () {},
)
```

### FAB Exit Animation

- **Duration**: 250ms
- **Curve**: Emphasized accelerate
- **Effect**: Scale from 1.0 to 0

### Press Animation

- **Duration**: 150ms
- **Curve**: Responsive spring
- **Effect**: Scale to 0.95

### Hover Elevation

- **Duration**: 250ms
- **Curve**: Standard easing
- **Effect**: Level 3 → Level 4

### Extended FAB Expand/Collapse

- **Duration**: 350ms
- **Curve**: Gentle spring
- **Effect**: Width animation with label clip

### FAB Menu Staggered Animation

- **Base Duration**: 350ms
- **Stagger Delay**: 50ms per item
- **Curve**: Emphasized decelerate
- **Effects**:
  - Scale: 0 → 1.0
  - Opacity: 0 → 1.0
  - Position: Animated based on direction
  - Labels: Slide + fade

## Usage Examples

### Example 1: Basic FAB in Scaffold

```dart
Scaffold(
  appBar: AppBar(title: Text('My App')),
  body: ListView(...),
  floatingActionButton: FABM3E(
    icon: Icons.add,
    tooltip: 'Add item',
    onPressed: () {
      // Add item
    },
  ),
)
```

### Example 2: Multiple Icon Buttons in App Bar

```dart
AppBar(
  title: Text('My App'),
  actions: [
    IconButtonM3E(
      icon: Icons.search,
      onPressed: () {},
      tooltip: 'Search',
    ),
    IconButtonM3E(
      icon: Icons.favorite_border,
      selectedIcon: Icons.favorite,
      selected: isFavorite,
      onSelectedChanged: (value) {
        setState(() => isFavorite = value);
      },
      tooltip: 'Favorite',
    ),
    IconButtonM3E(
      icon: Icons.more_vert,
      variant: IconButtonVariant.outlined,
      onPressed: () {},
      tooltip: 'More options',
    ),
  ],
)
```

### Example 3: FAB Menu with Custom Colors

```dart
FABMenuM3E(
  icon: Icons.add,
  backgroundColor: Colors.green,
  foregroundColor: Colors.white,
  items: [
    FABMenuItem(
      icon: Icons.image,
      label: 'Image',
      backgroundColor: Colors.blue,
      onPressed: () {},
    ),
    FABMenuItem(
      icon: Icons.camera,
      label: 'Camera',
      backgroundColor: Colors.purple,
      onPressed: () {},
    ),
  ],
)
```

### Example 4: Bottom Sheet with Icon Button Group

```dart
class MyBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Share', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  IconButtonM3E(
                    icon: Icons.link,
                    variant: IconButtonVariant.filled,
                    onPressed: () {},
                  ),
                  SizedBox(height: 8),
                  Text('Copy link'),
                ],
              ),
              Column(
                children: [
                  IconButtonM3E(
                    icon: Icons.mail,
                    variant: IconButtonVariant.filled,
                    onPressed: () {},
                  ),
                  SizedBox(height: 8),
                  Text('Email'),
                ],
              ),
              Column(
                children: [
                  IconButtonM3E(
                    icon: Icons.share,
                    variant: IconButtonVariant.filled,
                    onPressed: () {},
                  ),
                  SizedBox(height: 8),
                  Text('Share'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### Example 5: Scroll-Aware Extended FAB

```dart
class ScrollAwareScreen extends StatefulWidget {
  @override
  State<ScrollAwareScreen> createState() => _ScrollAwareScreenState();
}

class _ScrollAwareScreenState extends State<ScrollAwareScreen> {
  final ScrollController _controller = ScrollController();
  bool _showLabel = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final show = _controller.offset < 100;
      if (show != _showLabel) {
        setState(() => _showLabel = show);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        controller: _controller,
        itemCount: 50,
        itemBuilder: (context, index) => ListTile(
          title: Text('Item $index'),
        ),
      ),
      floatingActionButton: ExtendedFABM3E(
        icon: Icons.add,
        label: 'Create',
        expanded: _showLabel,
        onPressed: () {},
      ),
    );
  }
}
```

## API Reference

### FABM3E

```dart
FABM3E({
  required VoidCallback? onPressed,
  required IconData icon,
  String? label,
  FABSize size = FABSize.regular,
  Color? backgroundColor,
  Color? foregroundColor,
  double? elevation,
  double? hoverElevation,
  String? tooltip,
  Object? heroTag,
  bool visible = true,
  ShapeBorder? shape,
  bool tonal = false,
})
```

### IconButtonM3E

```dart
IconButtonM3E({
  required IconData icon,
  VoidCallback? onPressed,
  IconButtonVariant variant = IconButtonVariant.standard,
  double? iconSize,
  Color? color,
  Color? backgroundColor,
  String? tooltip,
  bool selected = false,
  IconData? selectedIcon,
  ValueChanged<bool>? onSelectedChanged,
})
```

### FABMenuM3E

```dart
FABMenuM3E({
  required IconData icon,
  IconData? openIcon,
  required List<FABMenuItem> items,
  Color? backgroundColor,
  Color? foregroundColor,
  String? tooltip,
  Object? heroTag,
  bool showLabels = true,
  FABMenuDirection direction = FABMenuDirection.up,
})
```

### ExtendedFABM3E

```dart
ExtendedFABM3E({
  required VoidCallback? onPressed,
  required IconData icon,
  required String label,
  bool expanded = true,
  Color? backgroundColor,
  Color? foregroundColor,
  double? elevation,
  double? hoverElevation,
  String? tooltip,
  Object? heroTag,
  bool visible = true,
  bool tonal = false,
})
```

### FABMenuItem

```dart
FABMenuItem({
  required IconData icon,
  String? label,
  required VoidCallback onPressed,
  Color? backgroundColor,
  Color? foregroundColor,
})
```

## Enums

### FABSize

- `small` - 40x40dp
- `regular` - 56x56dp (default)
- `large` - 96x96dp

### IconButtonVariant

- `standard` - No background
- `filled` - Primary background
- `tonal` - Secondary container background
- `outlined` - Border outline

### FABMenuDirection

- `up` - Expand upward (default)
- `down` - Expand downward
- `left` - Expand to the left
- `right` - Expand to the right

## Best Practices

1. **Use appropriate FAB sizes**:
   - Small: Secondary actions, compact UIs
   - Regular: Primary actions (most common)
   - Large: Main action on tablet/desktop

2. **Choose the right icon button variant**:
   - Standard: Default choice for app bars
   - Filled: Primary or most important action
   - Tonal: Related actions in a group
   - Outlined: When boundary clarity is needed

3. **FAB Menu considerations**:
   - Limit to 3-6 menu items
   - Use clear, distinguishable icons
   - Provide labels when icons might be ambiguous
   - Choose appropriate direction based on screen position

4. **Accessibility**:
   - Always provide tooltips for icon-only buttons
   - Use semantic labels for screen readers
   - Ensure sufficient touch target size (minimum 48x48dp)

5. **Animation performance**:
   - Use `visible` property for entrance/exit animations
   - Avoid nesting multiple animated FABs
   - Consider disabling animations for accessibility preferences

## See Also

- [Material 3 Design Guidelines](https://m3.material.io/)
- [M3E Motion System](../theme/motion.dart)
- [M3E Elevation System](../theme/elevation.dart)
- [Example Implementation](fab_m3e_example.dart)

# SearchBarM3E - Material 3 Expressive Search Bar

A fully animated, highly customizable search bar component that follows Material 3 Expressive design specifications with smooth animations and expressive state transitions.

## Features

- **Expressive Animations**: Smooth expand/collapse animations with M3E motion curves
- **Icon Slide Animation**: Leading icon slides 30dp left during expansion
- **Clear Button**: Automatically appears when text is present with fade animation
- **Voice Search Support**: Optional voice search button
- **State Management**: Handles inactive, active, and interactive states
- **Elevation Changes**: Dynamic elevation on hover
- **Focus Management**: Intelligent focus and expansion behavior
- **Fully Customizable**: Support for custom icons, trailing widgets, and styling
- **Accessibility**: Full keyboard navigation and screen reader support

## Specifications

### Dimensions
- **Height**: 56dp (standard), 48dp (compact)
- **Corner Radius**: 28dp (extra-large, fully rounded pill shape)
- **Icon Size**: 24dp (standard), 20dp (compact)
- **Shadow**: Elevation level 2 (3dp)

### Colors
- **Background**: `surfaceContainerHigh` from ColorScheme
- **Icons**: `onSurfaceVariant` from ColorScheme
- **Text**: `onSurface` from ColorScheme

### Animations

| Animation | Duration | Curve |
|-----------|----------|-------|
| Expand | 300ms | emphasizedDecelerate |
| Collapse | 250ms | emphasizedAccelerate |
| Icon Slide | 300ms | emphasizedDecelerate |
| Clear Button Fade | 150ms | easeIn/easeOut |

### States
- **Inactive (Collapsed)**: Resting state, shows hint text
- **Active (Expanded)**: User interaction, text input enabled
- **Hover**: Elevated shadow on mouse over
- **Focus**: Expanded with keyboard focus
- **Text Present**: Shows clear button

## Usage

### Basic Search Bar

```dart
import 'package:design_system/design_system.dart';

SearchBarM3E(
  hintText: 'Search for fridges...',
  onChanged: (value) {
    print('Search: $value');
  },
  onSubmitted: (value) {
    performSearch(value);
  },
)
```

### With Controller

```dart
final _searchController = TextEditingController();

SearchBarM3E(
  controller: _searchController,
  hintText: 'Search...',
  onSubmitted: (value) {
    // Handle search
  },
)
```

### Auto-focus on Mount

```dart
SearchBarM3E(
  hintText: 'Search...',
  autoFocus: true,
  onSubmitted: (value) {
    // Handle search
  },
)
```

### With Voice Search

```dart
SearchBarM3E(
  hintText: 'Try voice search...',
  showVoiceSearch: true,
  onVoiceSearch: () {
    // Activate voice search
  },
  onSubmitted: (value) {
    // Handle search
  },
)
```

### Custom Leading Icon

```dart
SearchBarM3E(
  hintText: 'Search locations...',
  leadingIcon: Icons.location_on,
  onSubmitted: (value) {
    // Handle location search
  },
)
```

### Custom Trailing Widget

```dart
SearchBarM3E(
  hintText: 'Search with filter...',
  trailing: IconButton(
    icon: Icon(Icons.filter_list),
    onPressed: () {
      // Show filter dialog
    },
  ),
  onSubmitted: (value) {
    // Handle filtered search
  },
)
```

### Expanded by Default

```dart
SearchBarM3E(
  hintText: 'Already expanded...',
  expandedByDefault: true,
  onSubmitted: (value) {
    // Handle search
  },
)
```

### Custom Elevation

```dart
SearchBarM3E(
  hintText: 'Search...',
  elevation: M3EElevation.level3, // 6dp
  onSubmitted: (value) {
    // Handle search
  },
)
```

## Variants

### CompactSearchBarM3E

A smaller variant for constrained spaces with 48dp height instead of 56dp.

```dart
CompactSearchBarM3E(
  hintText: 'Compact search...',
  onSubmitted: (value) {
    // Handle search
  },
)
```

### SearchBarWithSuggestionsM3E

Displays search suggestions in a dropdown as the user types.

```dart
SearchBarWithSuggestionsM3E(
  hintText: 'Search community fridges...',
  suggestions: [
    'Community Fridge A',
    'Community Fridge B',
    'Food Pantry Central',
  ],
  onSuggestionSelected: (suggestion) {
    // Handle suggestion selection
  },
  onSubmitted: (value) {
    // Handle search submission
  },
)
```

### Custom Suggestion Builder

Customize how suggestions are displayed:

```dart
SearchBarWithSuggestionsM3E(
  hintText: 'Search...',
  suggestions: ['Apple', 'Banana', 'Cherry'],
  suggestionBuilder: (context, suggestion) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(suggestion[0]),
      ),
      title: Text(suggestion),
      trailing: Icon(Icons.arrow_forward),
      dense: true,
    );
  },
  onSuggestionSelected: (suggestion) {
    // Handle selection
  },
)
```

## Properties

### SearchBarM3E

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `controller` | `TextEditingController?` | `null` | Controller for the search text field |
| `onChanged` | `ValueChanged<String>?` | `null` | Callback when search text changes |
| `onSubmitted` | `ValueChanged<String>?` | `null` | Callback when search is submitted |
| `hintText` | `String?` | `null` | Hint text displayed when empty |
| `leadingIcon` | `IconData?` | `Icons.search` | Leading icon (24dp) |
| `trailing` | `Widget?` | `null` | Custom trailing widget |
| `showVoiceSearch` | `bool` | `false` | Show voice search button |
| `onVoiceSearch` | `VoidCallback?` | `null` | Callback when voice search pressed |
| `autoFocus` | `bool` | `false` | Auto-focus on mount |
| `enabled` | `bool` | `true` | Whether search is enabled |
| `elevation` | `double?` | `level2` | Shadow elevation (3dp) |
| `onTap` | `VoidCallback?` | `null` | Callback when tapped (collapsed) |
| `expandedByDefault` | `bool` | `false` | Start in expanded state |

### CompactSearchBarM3E

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `controller` | `TextEditingController?` | `null` | Controller for the search text field |
| `onChanged` | `ValueChanged<String>?` | `null` | Callback when search text changes |
| `onSubmitted` | `ValueChanged<String>?` | `null` | Callback when search is submitted |
| `hintText` | `String?` | `null` | Hint text displayed when empty |
| `leadingIcon` | `IconData?` | `Icons.search` | Leading icon (20dp) |
| `trailing` | `Widget?` | `null` | Custom trailing widget |
| `showVoiceSearch` | `bool` | `false` | Show voice search button |
| `onVoiceSearch` | `VoidCallback?` | `null` | Callback when voice search pressed |
| `autoFocus` | `bool` | `false` | Auto-focus on mount |
| `enabled` | `bool` | `true` | Whether search is enabled |

### SearchBarWithSuggestionsM3E

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `controller` | `TextEditingController?` | `null` | Controller for the search text field |
| `onChanged` | `ValueChanged<String>?` | `null` | Callback when search text changes |
| `onSubmitted` | `ValueChanged<String>?` | `null` | Callback when search is submitted |
| `hintText` | `String?` | `null` | Hint text displayed when empty |
| `suggestions` | `List<String>` | `[]` | List of search suggestions |
| `onSuggestionSelected` | `ValueChanged<String>?` | `null` | Callback when suggestion selected |
| `suggestionBuilder` | `Widget Function(BuildContext, String)?` | `null` | Custom suggestion widget builder |
| `autoFocus` | `bool` | `false` | Auto-focus on mount |

## Behavior

### Expansion/Collapse Logic

The search bar automatically manages its expanded/collapsed state:

1. **Expands when**:
   - User taps the search bar
   - Focus is requested
   - `autoFocus` is `true`
   - `expandedByDefault` is `true`

2. **Collapses when**:
   - Focus is lost AND
   - No text is present

3. **Stays expanded when**:
   - Text is present
   - Focus is active

### Clear Button

The clear button:
- Fades in when text is present
- Clears all text when pressed
- Maintains focus after clearing
- Uses 150ms fade animation

### Icon Animation

The leading icon:
- Slides 30dp to the left during expansion
- Uses emphasizedDecelerate curve (300ms)
- Slides back during collapse with emphasizedAccelerate curve (250ms)

### Elevation States

| State | Elevation |
|-------|-----------|
| Default | Level 2 (3dp) |
| Hover (collapsed) | Level 4 (8dp) |
| Active (expanded) | Level 2 (3dp) |

## Accessibility

### Screen Reader Support

- All interactive elements have semantic labels
- Clear button has "Clear" tooltip
- Voice search button has "Voice search" tooltip
- Focus management follows accessibility guidelines

### Keyboard Navigation

- **Tab**: Focus search bar
- **Enter**: Submit search
- **Escape**: Clear and collapse (when empty)
- **Clear button**: Tab accessible

### High Contrast Mode

The component automatically adapts to high contrast mode using system colors from the ColorScheme.

## Performance

### Optimizations

- Uses `SingleTickerProviderStateMixin` for efficient animations
- Debounced text change callbacks
- Efficient state management with minimal rebuilds
- Lazy initialization of controllers

### Memory Management

- Properly disposes controllers and focus nodes
- Removes listeners on dispose
- Handles internal vs external controllers

## Examples

See `search_bar_m3e_example.dart` for comprehensive examples including:

1. Basic search bar
2. Auto-focus search bar
3. Search bar with voice search
4. Custom leading icon
5. Custom trailing widget
6. Expanded by default
7. Compact search bar
8. Search bar with suggestions
9. Custom suggestion builder
10. Disabled search bar

Run the examples:

```dart
import 'package:design_system/navigation/search_bar_m3e_example.dart';

// View all examples
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SearchBarM3EExamples(),
  ),
);

// View real-world search page example
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SearchPageExample(),
  ),
);
```

## Design Tokens Used

### M3EMotion
- `medium2` (300ms) - Expand animation duration
- `medium1` (250ms) - Collapse animation duration
- `emphasizedDecelerate` - Expand animation curve
- `emphasizedAccelerate` - Collapse animation curve

### M3ESpacing
- `md` (16dp) - Horizontal padding
- `sm` (12dp) - Icon spacing
- `xs` (8dp) - Content spacing

### M3ETypography
- `bodyLarge` (16px) - Search text style
- `bodyMedium` (14px) - Compact variant text style

### M3EElevation
- `level1` (1dp) - Compact variant elevation
- `level2` (3dp) - Default elevation
- `searchBarHovered` (8dp) - Hover state elevation

### ColorScheme
- `surfaceContainerHigh` - Background color
- `onSurface` - Text color
- `onSurfaceVariant` - Icon and hint text color

## Related Components

- **TextField**: Base Flutter text input component
- **NavigationBar**: Bottom navigation bar component
- **NavigationDrawer**: Side navigation drawer component
- **AutocompleteM3E**: (Future) Advanced autocomplete component

## Migration from Standard SearchBar

If you're migrating from Flutter's standard `SearchBar` widget:

```dart
// Before (Standard Flutter SearchBar)
SearchBar(
  hintText: 'Search...',
  onChanged: (value) {},
)

// After (M3E SearchBar)
SearchBarM3E(
  hintText: 'Search...',
  onChanged: (value) {},
)
```

The M3E version adds:
- Expressive expand/collapse animations
- Icon slide animation
- Hover state elevation changes
- Better state management
- Voice search support
- Custom trailing widgets
- Suggestions support (variant)

## Testing

### Unit Tests

Test the search bar functionality:

```dart
testWidgets('SearchBarM3E expands on tap', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SearchBarM3E(
          hintText: 'Search...',
        ),
      ),
    ),
  );

  // Tap the search bar
  await tester.tap(find.byType(SearchBarM3E));
  await tester.pumpAndSettle();

  // Verify it's expanded
  expect(find.byType(TextField), findsOneWidget);
});
```

### Integration Tests

Test search functionality in real scenarios:

```dart
testWidgets('Search flow works correctly', (tester) async {
  String? searchResult;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SearchBarM3E(
          hintText: 'Search...',
          onSubmitted: (value) {
            searchResult = value;
          },
        ),
      ),
    ),
  );

  // Tap to expand
  await tester.tap(find.byType(SearchBarM3E));
  await tester.pumpAndSettle();

  // Enter text
  await tester.enterText(find.byType(TextField), 'test query');
  await tester.pumpAndSettle();

  // Submit
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();

  // Verify
  expect(searchResult, equals('test query'));
});
```

## Troubleshooting

### Search bar doesn't expand
- Ensure `enabled` is `true`
- Check that the widget is properly focused
- Verify `expandedByDefault` or `autoFocus` if needed

### Clear button doesn't appear
- Verify that text is present in the controller
- Check that the animation has completed
- Ensure sufficient width for the button

### Voice search not working
- Set `showVoiceSearch: true`
- Provide `onVoiceSearch` callback
- Check that permissions are granted for microphone

### Custom trailing widget not visible
- Ensure search bar is expanded
- Check that widget has appropriate size
- Verify no conflicting constraints

## Best Practices

1. **Use controllers for complex logic**: If you need to programmatically control the search text, always provide a controller
2. **Handle empty searches**: Always check for empty strings in `onSubmitted`
3. **Debounce onChange**: For API calls, debounce the `onChanged` callback to avoid excessive requests
4. **Clear on navigation**: Clear search text when navigating away to avoid stale state
5. **Provide meaningful hints**: Use descriptive hint text that explains what can be searched
6. **Test accessibility**: Always test with screen readers and keyboard navigation
7. **Handle loading states**: Show loading indicators during search operations

## License

Part of the FridgeFinder Design System.
Material 3 Expressive Design implementation.

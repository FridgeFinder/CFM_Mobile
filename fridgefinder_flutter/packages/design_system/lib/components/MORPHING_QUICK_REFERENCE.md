# M3E Morphing Loading - Quick Reference Card

## Import
```dart
import 'package:design_system/design_system.dart';
```

## 5 Variants - One Liner Each

### 1. Shape Morph (Geometric)
```dart
MorphingLoadingIndicatorM3E.shapeMorph()
```
Circle → Square → Rounded Square → Circle

### 2. Blob Morph (Organic)
```dart
MorphingLoadingIndicatorM3E.blobMorph()
```
Living, breathing organic blob

### 3. Connected Dots (Network)
```dart
MorphingLoadingIndicatorM3E.connectedDots()
```
4 dots with connecting lines

### 4. Breathing (Calm)
```dart
MorphingLoadingIndicatorM3E.breathing()
```
Pulsing rounded square

### 5. Liquid Flow (Dynamic)
```dart
MorphingLoadingIndicatorM3E.liquidFlow()
```
Flowing liquid blobs

---

## Common Use Cases

### Fullscreen Loading
```dart
Scaffold(
  body: MorphingLoadingIndicatorM3E.fullscreenBlobMorph(
    message: 'Loading...',
  ),
)
```

### Inline Loading
```dart
MorphingLoadingIndicatorM3E.inlineShapeMorph()
```

### Button Loading
```dart
FilledButton(
  child: _isLoading
    ? MorphingLoadingIndicatorM3E.shapeMorph(size: 24)
    : Text('Submit'),
)
```

### Custom Color
```dart
MorphingLoadingIndicatorM3E.blobMorph(
  color: Colors.purple,
  message: 'Processing...',
)
```

---

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `size` | double | 64 | Size in dp |
| `color` | Color? | primary | Custom color |
| `message` | String? | null | Text below |
| `fullscreen` | bool | false | Center on screen |

---

## Sizes

- **64dp** - Fullscreen loading
- **48dp** - Inline (default)
- **32dp** - Compact spaces
- **24dp** - Buttons

---

## When to Use Each Variant

| Variant | Best For |
|---------|----------|
| Shape Morph | General purpose, reliable |
| Blob Morph | Data processing, uploads |
| Connected Dots | Network, syncing |
| Breathing | Background updates |
| Liquid Flow | Content generation |

---

## Properties

- **Duration:** 2000ms per cycle
- **FPS:** 60fps smooth
- **Curve:** emphasizedDecelerate
- **Memory:** 1-2KB per indicator
- **Performance:** Minimal impact

---

## Examples Location

See comprehensive examples:
`lib/components/loading_m3e_morphing_example.dart`

Full documentation:
`lib/components/LOADING_M3E_MORPHING_README.md`

---

## Migration from CircularProgressIndicator

**Before:**
```dart
CircularProgressIndicator()
```

**After:**
```dart
MorphingLoadingIndicatorM3E.shapeMorph()
```

**Before:**
```dart
Column(
  children: [
    CircularProgressIndicator(),
    SizedBox(height: 16),
    Text('Loading...'),
  ],
)
```

**After:**
```dart
MorphingLoadingIndicatorM3E.blobMorph(
  message: 'Loading...',
)
```

---

## Quick Decision Tree

```
Need loading indicator?
├─ Page load → fullscreenBlobMorph()
├─ Data processing → blobMorph()
├─ Network/sync → connectedDots()
├─ Background → breathing()
├─ Creative/generation → liquidFlow()
└─ General purpose → shapeMorph()
```

---

## Copy-Paste Ready Examples

### Fullscreen
```dart
const MorphingLoadingIndicatorM3E.fullscreenShapeMorph(
  message: 'Loading your content...',
)
```

### Inline with Row
```dart
Row(
  children: [
    MorphingLoadingIndicatorM3E.inlineShapeMorph(),
    SizedBox(width: 16),
    Text('Loading...'),
  ],
)
```

### Dialog
```dart
showDialog(
  context: context,
  builder: (context) => Dialog(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: MorphingLoadingIndicatorM3E.blobMorph(
        message: 'Processing...',
      ),
    ),
  ),
)
```

### Future Builder
```dart
FutureBuilder(
  future: loadData(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return MorphingLoadingIndicatorM3E.breathing();
    }
    return YourContent(data: snapshot.data);
  },
)
```

### ListTile
```dart
ListTile(
  title: Text('Item'),
  trailing: isLoading
    ? MorphingLoadingIndicatorM3E.inlineShapeMorph()
    : Icon(Icons.check),
)
```

---

## Troubleshooting

**Issue:** Indicator not showing
**Fix:** Ensure parent has size constraints

**Issue:** Animation choppy
**Fix:** Check for other expensive operations on UI thread

**Issue:** Wrong color
**Fix:** Pass custom color or check theme primary color

**Issue:** Too large/small
**Fix:** Adjust `size` parameter

---

## Performance Tips

1. Don't create multiple fullscreen indicators simultaneously
2. Reuse inline indicators when possible
3. Use appropriate size for context
4. Consider using breathing() for low-priority loads

---

## Accessibility

- Screen reader: Announces "Loading" + message
- Reduced motion: Respects OS preferences
- Color contrast: Uses theme colors
- Messages: Provide context for users

---

## File Location

**Implementation:**
`packages/design_system/lib/components/loading_m3e_morphing.dart`

**Export:**
Already exported via `package:design_system/design_system.dart`

**Examples:**
`packages/design_system/lib/components/loading_m3e_morphing_example.dart`

---

## That's It!

Simple one-line usage, sophisticated animations, M3E philosophy.

Choose your variant and start using:
```dart
MorphingLoadingIndicatorM3E.blobMorph()
```

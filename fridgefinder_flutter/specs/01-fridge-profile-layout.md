# Spec 01: Fridge Profile Layout Overhaul

## Summary
Restructure the fridge profile sheet to match the web version layout, improve button placement, add missing sections, and refine visual hierarchy.

## Feedback Sources
- Fridge Profiles section (pages 17-21)
- November 10, 2025 notes (page 7)
- December 8, 2025 notes (pages 3-4)
- February 6, 2025 notes (page 2)

---

## Architectural Prerequisites

Before implementing any of the changes below, address the following structural issues in `fridge_profile_sheet.dart`:

### Decompose `fridge_profile_sheet.dart` before implementing
The file is 1257 lines with a ~765-line `build` method. Every provider change rebuilds the entire widget tree. Extract into separate `ConsumerWidget` classes that each only watch the providers they need:
- `FridgeProfileHeader`
- `FridgeProfilePhoto`
- `FridgeProfileButtonRow`
- `FridgeLatestStatusUpdate`
- `FridgeDetailsSection`
- `FridgeMaintainerSection`
- `FridgeActionButtons`

### Fix perpetual animation controller
`_glowController` at lines 59-62 uses `..repeat(reverse: true)` running continuously even when the fridge is not followed. Start the animation only when follow state is confirmed; stop when not followed. Move to a separate `FridgeHeroIcon` widget.

### Remove fragile route detection pattern
Lines 88-106 add `addPostFrameCallback` inside `build()` to detect route changes. Every rebuild adds a new callback. Use a `RouteObserver` or `GoRouterState` listener in `initState`/`dispose` instead.

### Replace raw Flutter buttons with M3E equivalents
Lines 342-376 (`FilledButton`), 415-456 (`OutlinedButton`), 461-496 (`FilledButton`), 1224-1228 (`TextButton`) should use `FilledButtonM3E`, `OutlinedButtonM3E`, `TextButtonM3E`.

### Replace hardcoded pixel sizes with M3ESpacing
Lines 353-356 (`EdgeInsets.symmetric(horizontal: 16, vertical: 10)`), 634/671/680 (`SizedBox(height: 12/8)`) should use `M3ESpacing` constants.

---

## Change 1: Header - Replace Status with Neighborhood

### Current State
- **File:** `lib/src/features/profile/presentation/fridge_profile_sheet.dart` (lines 148-327)
- Header displays: Fridge Name, Address, Status Condition (e.g. "Good"), Distance
- Status condition shown with colored icon (green check for good, coral for dirty, etc.)

### Target State
- Header displays: Fridge Name, Address, **Neighborhood Name** (e.g. "Bedford-Stuyvesant"), Distance
- Remove status condition from header (it's redundant since it appears in Latest Status Update section below)
- Matches web version layout

### Notes
- Neighborhood data may need to come from the API/database. Check if `fridge.location` already has a neighborhood field, or if it needs to be derived from the address.
- The `fridge_domain.dart` `FridgeLocation` model (lines 75-107) has: address, city, state, zip, lat, lng. No explicit neighborhood field exists currently.

---

## Change 2: Fridge Photo - Move Up, Remove Label, Resize

### Current State
- **File:** `fridge_profile_sheet.dart` (lines 506-553)
- Photo displayed AFTER header, but with section label "Fridge Photo" and icon
- Uses `_buildSection()` helper which adds icon + title + indentation
- Size: full width x 250px, 12px border radius, `BoxFit.cover`

### Target State
- Photo remains after header (already correct position)
- **Remove** the "Fridge Photo" section label/icon/indentation - display photo directly
- Resize to **4:3 aspect ratio** (portrait orientation) instead of fixed 250px height
- Photo should feel like the fridge's "profile photo" - clean, edge-to-edge within the card
- Creates visual distinction from the report photo shown further down

### Implementation Notes
- Replace fixed `height: 250` with `AspectRatio(aspectRatio: 3/4)` for portrait 4:3
- Remove wrapping `_buildSection()` call, render `ClipRRect` directly
- Keep error handling fallback (gray placeholder with "Photo unavailable")
- IMPORTANT: Wrap `AspectRatio(aspectRatio: 3/4)` in `ConstrainedBox(constraints: BoxConstraints(maxHeight: 400))` to prevent the photo from exceeding viewport on small devices. On iPhone SE (320dp wide), a 3:4 ratio = 427dp tall which exceeds the sheet's visible area (~341dp). Use `M3ELayout.getAdaptiveValue()` for responsive max heights.
- Add a `loadingBuilder` to `Image.network` showing a shimmer placeholder to prevent layout shift during image load.

---

## Change 3: Main Buttons - Rename, Consolidate, Reorder

### Current State
- **File:** `fridge_profile_sheet.dart` (lines 328-502, 802-838)
- Button layout when followed (top): `[Edit Alerts]` `[Unfollow]` (side by side)
- Button layout when not followed (top): `[Follow]` (full width, gold)
- Bottom buttons (in order): `[Report Status Update]`, `[Get Directions]`, `[Share]`

### Target State

**Terminology Change:**
- "Follow" -> "Follow"
- "Unfollow" -> "Unfollow"
- Reasoning: "Follow" implies paid membership, "Follow" is more intuitive

**Button Row (below photo):**
1. **Button 1:** `[Follow]` / `[Unfollow]` - Consolidate follow action with alert editing
   - When not following: tapping opens the notification preferences dialog, then follows
   - When following: shows "Unfollow" with option to "Edit Alerts" accessible via the same button or a secondary action
2. **Button 2:** `[Directions]` - Moved UP from bottom of profile
   - Reasoning: Getting directions is a priority action for users looking for food

**Below Latest Status Update:**
- `[Report Status Update]` button stays
- `[Share]` button stays at bottom

**Remove:**
- The standalone "Get Directions" button at the bottom (since it's now in the button row)

### Implementation Notes
- Rename all instances of "Follow"/"Unfollow" to "Follow"/"Unfollow" across codebase
- Update `M3EColors.follow` references to conceptually be "follow" color (keep gold #FFD700)
- Search for "follow", "Follow", "unfollow", "Unfollow" strings in UI text
- Update `edit_notification_preferences_dialog.dart` dialog title from "Follow to Fridge" to "Follow Fridge"
- Update filter pill label from "Following" to "Following"
- Test button row at minimum 320dp width. With 48dp horizontal padding + 12dp gap, each button gets ~130dp. Consider `FittedBox(fit: BoxFit.scaleDown)` for button labels or `M3ELayout.isCompact()` check to switch to vertical stack on narrow screens.
- Fix unfollow dialog at lines 1216-1254: Replace raw `AlertDialog` with `DialogM3E.showConfirmation(isDestructive: true)`. Replace `TextStyle(color: Colors.red)` at line 1249 with `colorScheme.error`.

---

## Change 4: Add Missing Details Section

### Current State
- **File:** `fridge_profile_sheet.dart` (lines 772-799)
- Only a "Maintainer" section exists with: name, organization, phone, email, instagram, website
- **Missing:** Fridge Notes (INFO), Instagram handle with link, fridge website link
- These fields exist on the web version but are omitted from mobile

### Target State
- Add a **"Details"** section (or labeled "Info") between the Latest Status Update and Report Status Update button
- Section contains:
  1. **Fridge Notes** (labeled "Info") - Access instructions, donation guidelines, etc.
  2. **Instagram handle** - Tappable link to Instagram profile
  3. **Fridge link** - Tappable URL (e.g. linktree)
- Use word "Info" for the section/notes label per team decision
- Match web version's layout with icons: (i) for details, Instagram icon, globe icon

### Implementation Notes
- Check if `FridgeDomain` model already has `notes`, `instagram`, `website` fields from the API
- If not, these fields need to be added to the domain model and data layer
- The `FridgeMaintainerDomain` already has `instagram` and `website` - determine if these are the same or separate
- Use maintainer-level `instagram` and `website` from `FridgeMaintainerDomain` (already in model) alongside fridge-level `notes` (already at `FridgeDomain.notes`, line 203). No new data model fields needed.
- Add `maxLines: 2` and `TextOverflow.ellipsis` to maintainer data fields. Make email, phone, instagram, website tappable via `url_launcher`.

---

## Change 5: Refine "Latest Report" -> "Latest Status Update"

### Current State
- **File:** `fridge_profile_sheet.dart` (lines 555-726)
- Section title: "Latest Report" with `Icons.report`
- Display order: Condition, Food Level, Notes, Timestamp
- Timestamp format: Relative ("2 days ago", "X hours ago") via `_formatDate()`
- Timestamp text: "Last updated: [relative time]"
- Condition values display raw: "good", "dirty" (lowercase)

### Target State

**Title:** "Latest Status Update" (matches action verb "Report Status Update")

**Display Order (changed):**
1. Timestamp (moved to top)
2. Condition
3. Food Level
4. Notes

**Timestamp Format:**
- Change from relative to precise: "Reported on: 2/4/26 9:00 AM EST"
- Include date, time, and timezone
- Reasoning: Exact timestamps are useful for organizers tracking fridge activity

**Condition Label Changes:**
- "dirty" -> "Needs Cleaning" (less harsh, more constructive)
- "good" -> "Good" (capitalize consistently)
- "out of order" -> "Needs Repairs" (already done in status_update_form.dart)
- "not at location" -> "Not at Location" (capitalize consistently)

**Capitalization Convention:**
- All condition and food level values should use Title Case consistently
- "good" -> "Good", "dirty" -> "Needs Cleaning", etc.

### Implementation Notes
- Update `_formatDate()` method (lines 1039-1052) to return precise format
- Use `DateFormat('M/d/yy h:mm a')` from intl package + timezone suffix
- Update `FridgeCondition` display text in `fridge_domain.dart` `statusText` getter (lines 244-261)
- Reorder the widgets in the Latest Report section builder
- Update section icon from `Icons.report` to something more fitting (e.g. `Icons.update`)
- CRITICAL: `fridge_profile_sheet.dart` line 598 displays `condition.value` (raw enum: `"dirty"`) instead of `fridge.statusText`. Must change to use `statusText` or the label changes will have no visible effect.
- Wrap bottom sheet content in `Center(child: ConstrainedBox(constraints: M3ELayout.getContentConstraints(context)))` for tablet/desktop readability.

---

## Regression & Integration Notes

### API-First Migration Note
- Legacy Firebase Database path guidance is obsolete.
- Follow/alert state is now sourced from notification APIs only.
- Keep naming and behavior aligned with API terminology: follow, unfollow, and edit alerts.

### Full list of UI text files requiring Follow->Follow rename:
1. `fridge_profile_sheet.dart` - lines 369, 445, 487, 1061, 1115, 1120, 1180, 1219, 1221, 1236, 1248
2. `edit_notification_preferences_dialog.dart` - lines 164, 370, 485
3. `filter_pills_row.dart` - line 101
4. `filter_status_indicator.dart` - line 26
5. `bottom_nav_bar.dart` - line 43 (tooltip)
6. `my_fridges_screen.dart` - lines 77, 137, 142, 189, 194
7. `profile_screen.dart` - lines 66, 684, 738, 1192
8. `test_notification_utils.dart` - lines 31, 96, 199, 220, 224
9. `test_notification_screen.dart` - lines 221, 406, 444, 450, 578

### Color constant rename:
- `M3EColors.follow` in `packages/design_system/lib/theme/colors.dart` line 228 -> consider renaming to `M3EColors.follow` or adding alias

### Condition label consistency:
- `filter_condition.dart` line 31 already returns `'Needs Cleaning'` for dirty filter label
- `fridge_domain.dart` line 252 still returns `'Dirty'` for statusText - MISMATCH that must be fixed
- Profile sheet line 595 displays `condition.value` (raw enum: "dirty") instead of `fridge.statusText` - must use statusText
- CONFIRMED BUG: Line 598 of `fridge_profile_sheet.dart` uses `condition.value` (raw enum string) for display. This must be changed to `fridge.statusText` for ANY condition label changes to take effect.

### fridge_domain.dart statusColor architectural note:
- The `statusColor` getter at line 235 returns `Colors.black` for "Not at Location" - invisible in dark mode
- This getter is on a domain model and CANNOT access `BuildContext`
- Solution: Move color determination to a UI-layer utility that accepts isDarkMode, OR use a color that works in both modes (e.g. `Colors.grey`)

### Sign-out dialog context bug (relates to Spec 05):
The sign-out dialog at lines 1116-1173 uses `Navigator.of(context).pop()` where `context` is the profile screen's context, not the dialog's context. This pops the wrong route, causing a black screen. Fix: Use `Builder` to capture dialog context, or restructure dialog to use builder pattern.

### Widget decomposition rebuild impact:
The `ref.watch(userLocationProvider)` at line 83 causes the entire 1257-line sheet to rebuild on every GPS update. After decomposition, only the distance display widget should watch `userLocationProvider`. Use `ref.listen()` for `drawerStateProvider` and `bottomSheetCloseTriggerProvider` (side-effect-only providers).

---

## Required Tests

- **P0:** Verify `FridgeDomain.statusText` returns "Needs Cleaning" for dirty condition (not "Dirty")
- **P1:** Verify "Follow" text appears in all 30+ UI locations (widget tests per file)
- **P1:** Verify all condition labels match between form, profile display, and filter pills
- **P1:** Verify button row renders without overflow at 320dp width

---

## Files to Modify
1. `lib/src/features/profile/presentation/fridge_profile_sheet.dart` - Main layout changes + all Follow->Follow text
2. `lib/src/features/map/domain/models/fridge_domain.dart` - Condition display text (statusText getter line 252: "Dirty"->"Needs Cleaning")
3. `lib/src/features/auth/presentation/widgets/edit_notification_preferences_dialog.dart` - Follow->Follow rename (lines 164, 370, 485)
4. `lib/src/features/map/presentation/widgets/filter_pills_row.dart` - "Following"->"Following" (line 101)
5. `lib/src/features/map/presentation/widgets/filter_status_indicator.dart` - "followed"->"followed" (line 26)
6. `lib/src/common_widgets/bottom_nav_bar.dart` - tooltip text (line 43)
7. `lib/src/features/auth/presentation/screens/my_fridges_screen.dart` - all Follow text (5 instances)
8. `lib/src/features/profile/presentation/profile_screen.dart` - Follow text (4 instances)
9. `packages/design_system/lib/theme/colors.dart` - Color constant name (line 228)
10. `lib/src/core/providers/followed_fridges_provider.dart` - Variable/method naming (internal consistency)
11. `lib/src/features/map/presentation/controllers/map_filter_controller.dart` - `subscribedOnly`->`followingOnly`

## Design System Compliance
- All buttons use `FilledButtonM3E`, `OutlinedButtonM3E`, `TextButtonM3E`
- Spacing uses `M3ESpacing` constants
- Typography uses `M3ETypography` styles
- Colors use `M3EColors` or `Theme.of(context).colorScheme`
- No hardcoded colors, sizes, or fonts

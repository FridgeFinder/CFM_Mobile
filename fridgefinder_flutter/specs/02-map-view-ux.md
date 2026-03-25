# Spec 02: Map View UX Improvements

## Summary
Improve map interaction (rotation, clustering, zoom), add ghost fridge filter, and fix filter UX issues.

## Feedback Sources
- December 8, 2025 notes (pages 2-3)
- November 10, 2025 notes (pages 7-8)
- Follow/Subscription issues (pages 23-25)

---

## Change 1: Ghost Fridge Filter

### Current State
- **File:** `lib/src/features/map/data/fridge_repository.dart` (lines 43-47)
- Ghost fridges are **completely filtered out** at the API response level
- `FridgeCondition.ghost` exists in the enum but is never displayed
- No UI option to show/hide discontinued fridges
- **File:** `lib/src/features/map/presentation/controllers/filter_condition.dart` - no ghost filter option

### Target State
- Add a "Ghost Fridge" / "Discontinued" filter option - **default toggled OFF**
- When toggled ON, ghost fridges appear on the map with their distinct icon (semi-transparent, wavy outline)
- Ghost fridges should be visually distinct from active fridges
- Reasoning: Some users want to see discontinued fridges to know the data exists; most don't want them cluttering the map

### Implementation Notes
- Remove the `.where()` filter in `fridge_repository.dart` that strips ghost fridges
- Add `ghost` to `FilterCondition` enum in `filter_condition.dart`
- Ghost filter should be **excluded from default selected conditions** (toggled off by default)
- The ghost icon already exists in `fridge_icon_utils.dart` (lines 171-186) - light blue wavy outline
- Need to handle ghost fridges in list view as well
- Ghost fridges should NOT be subscribable/followable
- **ARCHITECTURAL RECOMMENDATION:** Do NOT move the ghost filter from the data layer to the UI layer. Loading all ghost fridges into `fridgeListProvider` means they propagate through the entire provider dependency tree (`mapFilteredFridgesProvider`, `filteredFridgesProvider`, `fridgesSortedByDistanceProvider`) even when filtered out. Instead, add a parameter to the repository: `getFridges({bool includeGhosts = false})`. The filter pill toggles this parameter, triggering a provider refresh. This avoids the memory overhead of holding ghost fridge objects in cache permanently.
- If the team decides to keep the UI-layer filter approach despite the memory concern, memoize the `subscribedFridgeIds` set outside the marker builder closure in `map_screen.dart` (lines 651-658) — it is currently recreated on every filter state change.

---

## Change 2: Filter UX Improvements

### Current State
- **File:** `lib/src/features/map/presentation/widgets/filter_pills_row.dart` (111 lines)
- **File:** `lib/src/features/map/presentation/widgets/filter_status_indicator.dart` (81 lines)
- "Showing only subscribed fridges" text at bottom-left is small (12px), white with text shadows
- Filter state persists across app restarts via Hive storage
- Active filter indication is subtle - easy to forget a filter is selected
- No reset mechanism on app launch

### Target State
- **Improve filter active indication:**
  - Make it more obvious when filters are active (not just subtle pill color changes)
  - Consider a banner or more prominent indicator
  - Ensure ADA/accessibility compliance for filter status text
- **Filter persistence behavior:**
  - Keep filter persistence (team decided this is desired), but ensure the active filter indicator is prominent enough that users notice
- **"Subscribed"/"Following" filter text:**
  - Rename from "Subscribed" to "Following" (per terminology change in Spec 01)
  - Ensure text is readable in both light and dark modes

### Implementation Notes
- Update `filter_status_indicator.dart` - increase text size, improve contrast
- Consider adding a "Clear Filters" button when filters are active
- The `isDarkMode` parameter is passed to `_buildSubscribedPill()` but NOT used (line 92-109) - fix this
- Update "Subscribed" label to "Following" in `filter_pills_row.dart` line 101
- Add `Semantics(liveRegion: true, label: 'Active filter: ...')` to `filter_status_indicator.dart`. Screen readers currently cannot announce filter changes. The existing text uses `Colors.white` with shadows for map overlay readability, which is acceptable.

---

## Change 3: Prevent Following "Not at Location" Fridges

### Current State
- **File:** `fridge_profile_sheet.dart` (lines 1054-1100)
- Users CAN subscribe to fridges with "Not at Location" status
- No validation prevents this
- Subscribe dialog appears regardless of fridge condition

### Target State
- **Disable** the Follow button for fridges with "Not at Location" condition
- Show a message explaining why (e.g., "This fridge is not currently at this location")
- If a fridge becomes "Not at Location" while followed, don't auto-unfollow, but prevent new follows

### Implementation Notes
- Add condition check before showing subscribe dialog in `fridge_profile_sheet.dart`
- Check `fridge.latestFridgeReport?.condition != FridgeCondition.notAtLocation`
- Show disabled button state or informational message
- Guard MUST be in both UI AND provider. Add a condition check in `subscriptions_provider.dart` `subscribeToFridge()` method (lines 88-156). Currently no condition check exists — any programmatic call (deep links, notification taps, tests) can bypass a UI-only guard.
- Add `Semantics(button: true, label: 'Follow this fridge - disabled, fridge not at location')` when the button is disabled for accessibility.

---

## Change 4: "Not at Location" Dark Mode Text Fix

### Current State
- **File:** `lib/src/core/utils/fridge_icon_utils.dart` (line 217)
- **File:** `lib/src/features/map/domain/models/fridge_domain.dart` (line 235)
- "Not at Location" status returns `Colors.black` hardcoded
- In dark mode, black text on dark background is **invisible**

### Target State
- Use theme-aware color for "Not at Location" status
- Should be visible in both light and dark modes
- Consider using `colorScheme.onSurface` or a specific muted color

### Implementation Notes
- Update `getStatusColor()` in `fridge_icon_utils.dart` line 217
- Update `statusColor` in `fridge_domain.dart` line 235
- Use `Theme.of(context).colorScheme.onSurface` or a color that works in both modes
- May need to pass `BuildContext` or `isDarkMode` flag to these utility methods

---

## Regression & Integration Notes

### Ghost filter implementation order - CRITICAL:
- `filter_condition.dart` currently has cases: `good`, `dirty`, `needsRepairs`, `notAtLocation` (line 6-9)
- Adding a `ghost` case affects the `when()` pattern matching across ALL files that switch on FilterCondition
- **Must add the new enum case AND update all switch/when statements in the same commit**
- Files that switch on FilterCondition: `filter_pills_row.dart`, `filter_status_indicator.dart`, `map_filter_controller.dart`

### Ghost filter vs repository filter coordination:
- `fridge_repository.dart` currently filters out ghost fridges at the data layer (line ~85: `where((f) => f.isActive)`)
- The new ghost filter is at the UI layer (FilterCondition enum)
- **Order matters:** Remove repository filter AFTER adding UI filter, or ghost fridges will appear with no way to hide them
- Safe approach: Add UI ghost filter first (default OFF), verify it works, THEN remove repository-level filter

### Dark mode color - architectural constraint:
- `fridge_domain.dart` `statusColor` getter (line 235) returns `Colors.black` for notAtLocation
- This is a **domain model** - it cannot access `BuildContext` or `Theme.of(context)`
- `fridge_icon_utils.dart` `getStatusColor()` (line 217) has the same issue
- **Solution:** Use a theme-neutral color like `Colors.grey` in the domain model, OR move color logic to a UI-layer utility that accepts `isDarkMode` parameter
- The `isDarkMode` approach is cleaner but requires updating all call sites

### Prevent follow on "Not at Location" - subscription provider impact:
- The follow prevention must happen in the UI (disable button) AND in `subscriptions_provider.dart` (guard the subscribe method)
- If only UI is guarded, programmatic subscriptions could still happen
- Add a check in the subscription method: if fridge condition is notAtLocation, throw or return early

### Test data fidelity:
- `MockFridgeRepository.getFridges()` in `test/test_helpers.dart` line 17 returns `FridgeFixtures.allFridges` which INCLUDES the ghost fridge. Production filters ghosts out. Tests see 5 fridges while production sees 4. Fix: filter ghosts in mock to match production behavior, or add `includeGhosts` parameter.

### Color-only indicators need non-color alternatives:
- The status icon at `fridge_profile_sheet.dart` lines 254-292 uses icon + colored text for condition. The icon has no `semanticLabel`. Add `semanticLabel` to all `Icon` widgets that convey status meaning.

---

## Required Tests

- **P0:** Ghost filter defaults to OFF on fresh install
- **P0:** Toggling ghost filter ON shows ghost fridges, OFF hides them
- **P1:** Follow button is disabled when fridge condition is `notAtLocation`
- **P1:** `subscribeToFridge()` throws or returns early for `notAtLocation` fridges
- **P1:** `FilterCondition.ghost.matches()` returns true for ghost fridges, false for others
- **P2:** "Not at Location" status text is visible in dark mode

---

## Files to Modify
1. `lib/src/features/map/data/fridge_repository.dart` - Remove ghost fridge filter (AFTER UI filter is added)
2. `lib/src/features/map/presentation/controllers/filter_condition.dart` - Add ghost filter case
3. `lib/src/features/map/presentation/widgets/filter_pills_row.dart` - Ghost pill, rename to "Following"
4. `lib/src/features/map/presentation/widgets/filter_status_indicator.dart` - Improve visibility
5. `lib/src/core/utils/fridge_icon_utils.dart` - Fix dark mode color
6. `lib/src/features/map/domain/models/fridge_domain.dart` - Fix dark mode color (use theme-neutral color)
7. `lib/src/features/profile/presentation/fridge_profile_sheet.dart` - Prevent follow on "Not at Location"
8. `lib/src/core/providers/subscriptions_provider.dart` - Guard subscribe method for notAtLocation

## Design System Compliance
- Filter pills use `FilterChipM3E` component
- Colors must be theme-aware (no hardcoded `Colors.black`)
- Text sizes and contrast must meet WCAG AA standards
- Use `M3EColors` for all status colors where possible

# Spec 03: Search Improvements

## Summary
Fix search behavior across map and list views - improve name search, disable confusing location geocoding, and synchronize search state.

## Feedback Sources
- February 6, 2025 notes (page 2) - "Refine search"
- December 8, 2025 notes (page 5) - "Search box should have same search"
- November 10, 2025 notes (page 8) - "Can't toggle off text box"

---

## Change 1: Improve Name Search to Include Fridge Names

### Current State
- **File:** `lib/src/features/map/presentation/controllers/fridge_list_controller.dart` (lines 195-211)
- **File:** `lib/src/features/list/presentation/list_screen.dart` (lines 223-238)
- Fuzzy search matches on: fridge name, city, state
- Does NOT search by address or zip code
- If a fridge named "Fenix" is searched, it matches the fridge name correctly
- BUT `onSubmitted` also triggers geocoding which can navigate the map to "Fenix, NC"

### Target State
- Search should match on: fridge **name**, city, state, **address**, and **zip code**
- Fridge name matches should be prioritized in results
- Add zip code to searchable fields

### Implementation Notes
- Update fuzzy search filter in `fridge_list_controller.dart` `mapFilteredFridgesProvider`
- Add `fridge.location.address` and `fridge.location.zip` to the search fields
- Keep fuzzy matching behavior for typo tolerance

---

## Change 2: Disable Location Geocoding on Search Submit

### Current State
- **File:** `lib/src/features/map/presentation/screens/map_screen.dart` (lines 337-384)
- **File:** `lib/src/features/list/presentation/list_screen.dart` (lines 67-116)
- `onSubmitted` callback triggers `_searchLocation()` which geocodes the query
- Geocoding converts text to lat/lng coordinates and pans/filters the map
- Problem: Searching "Fenix" (fridge name) geocodes to Fenix, North Carolina
- This confuses users who wanted to find a fridge by name

### Target State
- **Disable geocoding-based location search** until a better UX is designed
- `onSubmitted` should just dismiss the keyboard (same as `onChanged` filtering)
- The real-time fuzzy filter on name/city/state/zip is sufficient for now
- Future: Consider a dedicated "Search by location" mode with explicit UI toggle

### Implementation Notes
- Remove or comment out `_searchLocation()` call from `onSubmitted` in both map and list screens
- Keep the fuzzy filter on `onChanged` which already works well
- Remove the "Near: [location]" pill UI from list_screen.dart (lines 266-315) since geocoding is disabled
- Remove `_selectedLocation` state variable and related filtering logic in list_screen.dart

---

## Change 3: Synchronize Search Between Map and List Views

### Current State
- **File:** `lib/src/features/map/presentation/controllers/map_filter_controller.dart`
- Both views already share the same `mapFilterProvider` state
- Search query IS synchronized between views via Riverpod
- However: Map search bar is hidden by default (collapsible), List search bar is always visible
- When list view has an active search, switching to map view doesn't show the search bar

### Target State
- When switching from List to Map view with an active search query:
  - The map search bar should auto-expand to show the active search
  - The search query should be pre-populated (already happens via shared state)
- Search state remains in sync (already working)

### Implementation Notes
- In `map_screen.dart`, check `filterState.searchQuery.isNotEmpty` on build
- If search query exists, auto-expand the search bar (`_isSearchVisible = true`)
- This may already partially work since the filter state is shared - verify behavior
- The `_isSearchVisible` flag (line 43) is local state and doesn't sync with the shared filter
- Search query should NOT be persisted to Hive across app restarts. The current `_saveToStorage()` at `map_filter_controller.dart` line 160 writes every debounced keystroke to disk. Exclude `searchQuery` from `_saveToStorage()` — sync only within the active session via the shared provider, not across restarts.

---

## Files to Modify
1. `lib/src/features/map/presentation/controllers/fridge_list_controller.dart` - Add address/zip to search
2. `lib/src/features/map/presentation/screens/map_screen.dart` - Disable geocoding, auto-show search bar
3. `lib/src/features/list/presentation/list_screen.dart` - Disable geocoding, remove location pill
4. `lib/src/core/utils/fuzzy_search.dart` - Verify fuzzy matching works for zip codes

## Design System Compliance
- Search bar uses `SearchBarM3E` component - no changes needed to the component itself
- Ensure consistent hint text across both views: "Search by name or location..."
- Consider updating hint text to "Search by name, address, or zip..." for clarity

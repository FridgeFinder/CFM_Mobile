# Feedback Specs Overview

## Source Document
`Internal Feedback - Mobile App.pdf` - Team feedback from Nov 2025, Dec 2025, Jan 2026, Feb 2025

## Spec Files

| # | Spec | Priority | Complexity | Status | Review Status |
|---|------|----------|------------|--------|---------------|
| 01 | [Fridge Profile Layout](./01-fridge-profile-layout.md) | High | High | Ready for planning | Reviewed - has prerequisites |
| 02 | [Map View UX](./02-map-view-ux.md) | High | Medium | Ready for planning | Reviewed - architecture change recommended |
| 03 | [Search Improvements](./03-search-improvements.md) | Medium | Low | Ready for planning | Reviewed |
| 04 | [Status Update Form](./04-status-update-form.md) | High | Medium | Ready for planning | Reviewed - navigation approach clarified |
| 05 | [Auth & Sign Out Fixes](./05-auth-and-sign-out-fixes.md) | Critical | Medium | Ready for planning | Reviewed - root causes confirmed |
| 06 | [Notification Multi-Device](./06-notification-multi-device.md) | Medium | High | Ready for planning | Reviewed - architecture change recommended |
| 07 | [User Profile Refinements](./07-user-profile-refinements.md) | Low | Low | Needs discussion | Reviewed |

## Critical Architectural Findings

The following critical issues were identified during expert Flutter engineering review and must be addressed:

1. **Sign-out blank/black screen** (Spec 05): `Navigator.of(context).pop()` uses wrong context + 3 redundant `ref.invalidate()` calls on auto-updating stream providers
2. **FCM token migration breaks all existing users** (Spec 06): Freezed `fromJson` will crash on existing records. Recommend Map instead of List for atomic per-device operations
3. **Zip code optional creates redirect loop** (Spec 07): Both `router.dart` and `auth_provider.dart` must be updated atomically
4. **Dialog-to-page conversion breaks bottom sheet** (Spec 04): Must use `Navigator.of(context, rootNavigator: true).push()`, NOT GoRouter
5. **Profile completion cancel + PopScope deadlock** (Spec 05): `canPop: false` + redirect guard can trap users

## Architectural Prerequisites

Before implementing individual specs, these architectural changes should be done first:

1. **Decompose `fridge_profile_sheet.dart`** (1257 lines) into 6-7 smaller `ConsumerWidget`s — every GPS update currently rebuilds the entire sheet
2. **Fix condition display bug**: `fridge_profile_sheet.dart:598` uses `condition.value` (raw enum) instead of `statusText` — affects Specs 01 and 04
3. **Add Firebase mocking to test infrastructure** — subscription/FCM/auth tests are currently structural smoke tests that accept any error
4. **Fix `MockFridgeRepository`** to filter ghost fridges (matching production behavior)

## Recommended Implementation Order

Based on dependency analysis and risk profile:

1. **Architectural prerequisites** (above) — foundation for all other specs
2. **Spec 05 + Spec 07 together** — Fix redirect loop and profile completion. These are blocking bugs that trap users
3. **Spec 04** — Status update form. Use `Navigator.push` with `rootNavigator: true`. Test thoroughly that bottom sheet survives navigation
4. **Spec 01** — Fridge profile layout (after decomposition). Largest change, benefits from all prerequisites
5. **Spec 02 + Spec 03** — Map/search UX. Lower navigation risk
6. **Spec 06** — FCM tokens. No navigation impact but requires backend coordination. Ship backend changes first or simultaneously

## Completed Items (Already Done)
The following items from the feedback todos are already checked off / implemented:
- Map tile/styling options researched (MapTiler implemented)
- Rotation sensitivity decreased (threshold set to 40.0)
- Clustering radius adjusted (maxClusterRadius: 20)
- Further zoom out allowed (minZoom: 3.0)
- Verification field hidden
- Food level shows labels not percentages (Full, Many Items, Few Items, Empty)
- Report Status update UI bugs fixed
- Fridge and report photo kept separate
- Fridge condition text matched (Needs Repairs instead of Out of Order)
- Clicking outside search box dismisses it (GestureDetector + unfocus)
- Blue app color matched (#5B9FFF primary, #88B3FF/#6FA7FF header gradient)
- Profile flow made mandatory (canPop: false, auth guard redirect)

## Follow-Up Items (Need Team Discussion)
These items from the feedback require team discussion before implementation:
- [ ] Pre-filling report data (currently food level IS pre-filled)
- [ ] Ghost fridge display in UI (spec 02 proposes filter approach)
- [ ] List view search box exit behavior on mobile keyboards
- [ ] Zip code field requirements
- [ ] User profile types / "volunteer" vs "organizer" terminology
- [ ] Points system redesign

## Cross-Cutting Concerns
- **Terminology:** "Subscribe" -> "Follow" across entire codebase (Spec 01)
- **Condition Labels:** "Dirty" -> "Needs Cleaning" everywhere (Specs 01, 04)
- **Dark Mode:** Fix hardcoded `Colors.black` for "Not at Location" (Spec 02)
- **Design System:** All changes must use M3E components, spacing, typography, colors. 6+ raw Flutter buttons, 6+ hardcoded colors, 15+ hardcoded pixel sizes need M3E replacements across modified files
- **No Regressions:** Each spec should include testing notes to verify existing features still work
- **Testing:** No Firebase mocking exists. P0 tests needed for: Firebase path preservation, FCM migration backward compat, sign-out navigation, status form on full page, ghost filter default
- **Performance:** Ghost filter should stay at data layer (not UI). Profile sheet needs provider watch optimization. Search query should not persist to Hive
- **Accessibility:** Filter status indicator needs `Semantics(liveRegion: true)`. Status icons need `semanticLabel`. Color-only indicators need non-color alternatives

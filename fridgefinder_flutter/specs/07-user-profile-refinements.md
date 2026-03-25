# Spec 07: User Profile Refinements

## Summary
Refine user type terminology, make zip code optional, and address points system concerns.

## Feedback Sources
- User Profiles section (pages 9-15)
- Achievements section (pages 28-29)

---

## Change 1: Reconsider "Volunteer" Terminology

### Current State
- **File:** `lib/src/features/auth/domain/models/user_profile.dart` (line 65)
- **File:** `lib/src/features/auth/presentation/screens/profile_completion_screen.dart` (lines 330-337)
- **File:** `lib/src/features/profile/presentation/profile_screen.dart` (lines 125-138)
- User type is a boolean: `isVolunteer: bool`
- Profile completion shows checkbox: "I am a volunteer"
- Profile screen shows "Volunteer" badge with volunteer icon
- No "Organizer" role exists in the current system

### Target State
- **Discussion needed:** The team has concerns about the "volunteer" label:
  - What makes someone a volunteer? Confusing in mutual aid context
  - "Organizer" is a more specific and meaningful role
  - From a philosophical perspective, not differentiating "volunteer" from "community member" aligns better with mutual aid values
- **For now:** Keep the current implementation but note this as a future redesign
- **Immediate change:** If keeping the label, consider changing display text from "Volunteer" to something more inclusive, or remove the label entirely from the profile display
- This is a **discussion item** that needs team alignment before implementing

### Notes
- Jean Paul's feedback: Can derive volunteer-like data from user behavior (status updates made, fridges cleaned) rather than self-identification
- The new profile mockups (page 14-15) show "Organizer" role with activity stats
- Full user type redesign is out of scope for this round - flagging for follow-up

---

## Change 2: Make Zip Code Optional

### Current State
- **File:** `profile_completion_screen.dart` (lines 339-360)
- Zip code field only appears when `_isVolunteer` is true
- When shown, it is **required** (marked with *)
- Validation: minimum 5 characters (line 45)
- Purpose: "We collect zip codes for non-profit funding..."

### Target State
- Make zip code **optional** for all users (including volunteers)
- Remove the asterisk (*) from the label
- Remove the validation that blocks form submission without zip code
- Keep the help text explaining why we ask for it
- Reasoning: Privacy concern raised by Jean Paul

### Implementation Notes
- In `profile_completion_screen.dart`, remove the zip code validation in `_submitProfile()` (lines 40-48)
- Change label from `'Zip Code *'` to `'Zip Code'`
- Allow null/empty zip code to pass validation
- Update `auth_provider.dart` profile completion check (lines 111-115) to not require zip code for volunteers
- The zip code field can remain conditionally shown for volunteers but not block submission
- Profile completion screen has TWO code paths that check zip: (1) `_createProfile()` method at lines 40-48 (new users), and (2) `_updateZipCode()` method at lines 104-113 (existing volunteers missing zip). Both must be updated.
- After removing the router redirect for missing zip, the `needsZipCode` branch at lines 420-500 becomes unreachable dead code. Simplify or remove it to avoid confusion.
- EXISTING BUG: `_generateUsername()` at lines 220-225 runs inside `profileAsync.when(data:)` callback. If `userProfileProvider` re-emits during async generation, another generation is scheduled. FIX: Use a `_hasStartedGeneration` flag set synchronously rather than checking `_username.isEmpty`.

---

## Change 3: Points System - Scope Discussion

### Current State
- **File:** `lib/src/core/providers/points_provider.dart` (lines 8-100)
- Only volunteers earn points (line 84: `if (!isVolunteer) return;`)
- Points calculation: 10 base + 20 cleaning bonus + 30 stocking bonus
- Points stored as single integer on user profile
- No breakdown of how points were earned
- No stats (fridges updated, cleaned, filled)
- Points display only visible to volunteers

### Target State
- **Discussion needed:** Team wants to think through the points system more carefully
- Jean Paul's concerns:
  - Only volunteers gaining points feels exclusionary
  - Current implementation doesn't track HOW points were earned
  - No stats breakdown (# fridges reported, cleaned, filled)
  - Doesn't leave room for future iterations
- **For now:** Keep current implementation as-is, but:
  - Consider allowing ALL users to earn points (remove volunteer check)
  - Consider tracking point sources (status reports, cleaning, stocking) separately

### Notes
- There is reportedly a new document for points in the Backend folder
- Full points system redesign is out of scope for this round
- The mockups on page 14-15 show a richer profile with stats: Updated (28), Cleaned (12), Filled (45), Following (34)
- This implies future work on tracking activity history per user
- EXISTING BUG: `points_provider.dart` lines 61-68 has a read-then-write race condition. `pointsRef.get()` then `pointsRef.set(currentPoints + points)` — concurrent submissions lose points. FIX (when touching this code): Replace with `pointsRef.set(ServerValue.increment(points))` which is atomic.

---

## Immediate vs Deferred Changes

**Implement Now:**
- Change 2: Make zip code optional (small, clear change)

**Needs Discussion First:**
- Change 1: Volunteer terminology (needs team alignment)
- Change 3: Points system (needs design thinking)

---

## Regression & Integration Notes

### Zip code optional - Router redirect must also change:
- `profile_completion_screen.dart` lines 40-48: Remove zip code validation block
- **ALSO:** `router.dart` lines 98-102 checks `profile.isVolunteer && (profile.zipCode == null || profile.zipCode!.isEmpty)` and redirects to `/complete-profile`
- If zip is made optional but router check stays, volunteers who skip zip will be stuck in redirect loop
- **Must update both files together**

### Profile completion check coordination with Spec 05:
- Spec 05 adds a cancel button to profile completion screen
- Spec 07 makes zip optional on same screen
- Both changes are compatible and should be implemented together
- After both: volunteers can skip zip AND can cancel (sign out) from the completion screen

### `isProfileComplete` provider duplication:
`isProfileCompleteProvider` at `auth_provider.dart` lines 95-129 duplicates the SAME completeness logic that exists inline in `router.dart` lines 86-109. If zip code requirements change, BOTH locations must be updated. Consider having the router use `isProfileCompleteProvider` instead of duplicating the logic.

---

## Required Tests

- **P0:** Volunteer with empty zip code is NOT redirected to profile completion (no loop)
- **P1:** Both `router.dart` and `auth_provider.dart` agree on profile completeness for volunteer with empty zip
- **P2:** Points awarded atomically (no read-then-write)

---

## Files to Modify (for Change 2)
1. `lib/src/features/auth/presentation/screens/profile_completion_screen.dart` - Remove zip validation, change label
2. `lib/src/routing/router.dart` - Remove zip code redirect check (lines 98-102)
3. `lib/src/core/providers/auth_provider.dart` - Update profile completion check if it also validates zip

## Design System Compliance
- No UI component changes needed
- Text label changes only

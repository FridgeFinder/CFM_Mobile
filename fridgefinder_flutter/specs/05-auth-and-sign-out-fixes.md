# Spec 05: Auth Flow & Sign Out Bug Fixes

## Summary
Fix sign-out UX bugs, add cancel button to profile completion, and handle Google sign-in cancellation gracefully.

## Feedback Sources
- December 8, 2025 notes (page 5) - User Auth section

---

## Change 1: Add Cancel/Close to Profile Completion Screen

### Current State
- **File:** `lib/src/features/auth/presentation/screens/profile_completion_screen.dart` (lines 191-197)
- `PopScope(canPop: false)` prevents back navigation entirely
- `automaticallyImplyLeading: false` removes the back button from AppBar
- Users are **stuck** on this screen unless they complete the form
- No cancel or close button available

### Target State
- Add a close/cancel button (X icon) in the AppBar or as a text button
- Tapping cancel should:
  1. Show a confirmation dialog: "Are you sure? You need to complete your profile to use the app."
  2. If confirmed, sign the user out and return to the login screen
- This prevents users from being trapped in an incomplete state
- The profile flow should still be **mandatory** (redirected back if incomplete), but users can exit by signing out

### Implementation Notes
- Add `leading: IconButton(icon: Icon(Icons.close), onPressed: _showCancelDialog)` to AppBar
- Or change `automaticallyImplyLeading` to true and handle `PopScope` with confirmation
- On cancel confirmation: call `authRepository.signOut()`, invalidate auth providers, navigate to login
- Keep the mandatory profile completion redirect in `router.dart` auth guard
- DEADLOCK RISK: `PopScope(canPop: false)` at line 191 + router redirect guard at `router.dart` line 68 (`if (currentPath == '/complete-profile') return null;`) = if sign-out succeeds but navigation fails, user is stuck on the completion screen with no way out. FIX: In the cancel handler, use a `finally` block to ensure `context.go('/')` always executes. Consider temporarily setting `canPop: true` once sign-out is initiated.
- Profile completion has TWO code paths: `profile == null` (lines 218-417, full form) and `needsZipCode` (lines 420-500, zip-only form). The cancel button must work for both branches. After Spec 07 makes zip optional and removes the router redirect, the `needsZipCode` branch becomes dead code — simplify or remove it.

---

## Change 2: Fix Sign Out Modal - Cancel Turns Screen Black

### Current State
- **File:** `lib/src/features/profile/presentation/profile_screen.dart` (lines 1116-1174)
- Bug report: Clicking "Cancel" on sign-out modal turns the app black
- Current cancel handler: `Navigator.of(context).pop()` (line 1134)
- Uses `DialogM3E.showCustom()` for the dialog

### Target State
- Cancel button should dismiss the dialog and return to the profile screen cleanly
- No black screen or visual artifacts

### Investigation Notes
- The black screen could be caused by:
  1. Navigator context mismatch - dialog context vs scaffold context
  2. Theme/background color not being applied after dialog dismissal
  3. A rebuild issue where the profile screen's state is invalidated
- Need to verify if `DialogM3E.showCustom()` properly returns void or if it has a return value issue
- Test: Does the dialog use `showDialog` with `barrierDismissible: true`? Tapping outside might also cause this
- Check if `Navigator.of(context).pop()` is using the correct context (dialog's context, not the profile screen's)

### Implementation Notes
- Ensure dialog uses its own `BuildContext` from the builder callback for `Navigator.pop()`
- Consider using `Navigator.of(dialogContext).pop()` explicitly
- Verify that the profile screen doesn't rebuild or lose its scaffold background on dialog dismiss
- ROOT CAUSE CONFIRMED: `Navigator.of(context).pop()` at line 1134 uses the profile screen's `context` (captured in closure), NOT the dialog's context. `DialogM3E.showCustom()` uses `showGeneralDialog` which creates a new route. The outer context's `Navigator.pop()` pops the profile screen route, not the dialog, producing the black screen.
- FIX: Restructure the dialog child to capture the dialog's own context using `Builder(builder: (dialogContext) => ...)`. All `Navigator.of(context).pop()` calls inside the dialog must use `dialogContext`, not the outer `context`.
- Compare with delete dialog at line 1202 which correctly uses `Navigator.of(context, rootNavigator: true).pop()` — this pattern inconsistency confirms the bug.

---

## Change 3: Fix Sign Out - Page Turns Blank After Sign Out

### Current State
- **File:** `profile_screen.dart` (lines 1139-1167)
- Bug report: Clicking "Sign Out" on modal turns page blank
- Sign out flow:
  1. Closes dialog (line 1140)
  2. Calls `repository.signOut()` (line 1143)
  3. Invalidates `authUserProvider`, `userProfileProvider`, `isAuthenticatedProvider`
  4. Shows success snackbar

### Target State
- After sign out, user should be redirected to the login/welcome screen cleanly
- No blank page state

### Investigation Notes
- The blank page is likely caused by:
  1. Auth state invalidation triggers router redirect, but the current screen hasn't been popped
  2. The profile screen tries to render while auth state is null, causing an error
  3. The GoRouter auth guard should redirect to login, but there may be a timing issue
- The router's `redirect` logic in `router.dart` should handle this, but the profile screen may be rebuilding before the redirect fires

### Implementation Notes
- After `signOut()`, explicitly navigate to the login route before invalidating providers
- Or: Use `GoRouter.of(context).go('/login')` after sign out instead of relying on redirect
- Ensure the profile screen handles `null` auth state gracefully during the transition
- Add a check at the top of profile screen build: if not authenticated, show loading or empty state
- ROOT CAUSE CONFIRMED: Three redundant `ref.invalidate()` calls at lines 1146-1148 are harmful. `authUserProvider` is a STREAM provider (line 17 of `auth_provider.dart`) that auto-updates via Firebase `authStateChanges()`. Manually invalidating it creates a double-rebuild. `isAuthenticatedProvider` watches `authUserProvider` and auto-rebuilds. `userProfileProvider` watches `currentAuthUserProvider` and auto-clears.
- FIX: Remove ALL three `ref.invalidate()` calls. Just call `repository.signOut()` and let the stream provider + `_RouterNotifier` handle everything automatically. The `_RouterNotifier` at `router.dart:34` already listens to `authUserProvider` and triggers redirect.
- Between `signOut()` completing and GoRouter redirect executing, `ProfileScreen.build()` still watches `userProfileProvider` (line 37). When it returns null, the screen renders blank for 1-2 frames. Add a null-auth guard at the top of the Consumer builder: if `isAuthenticated` transitions false, show a loading indicator instead of trying to render profile data.

---

## Change 4: Fix Sign Out Modal Padding

### Current State
- **File:** `profile_screen.dart` (lines 1116-1173)
- Bug report: Modal needs more padding
- Current dialog uses `DialogM3E.showCustom()` with a Column child
- Internal spacing uses `M3ESpacing.verticalMD` and `M3ESpacing.verticalXL`
- No explicit padding on the outer Column

### Target State
- Dialog content should have proper padding on all sides
- Should match Material 3 dialog padding standards (typically 24dp)

### Implementation Notes
- `DialogM3E.showCustom()` should already apply padding - verify its implementation
- If not, wrap the Column child in `Padding(padding: EdgeInsets.all(M3ESpacing.xl))`
- Check `packages/design_system/lib/components/dialogs_m3e.dart` for default padding behavior
- CONFIRMED: Sign-out dialog at lines 1116-1173 passes raw `Column` to `DialogM3E.showCustom()` with no padding wrapper. Compare with delete dialog at lines 1181-1189 which wraps in `Padding(padding: M3ESpacing.all(M3ESpacing.xl))`. Add identical padding.

---

## Change 5: Handle Google Sign-In Cancellation Gracefully

### Current State
- **File:** `lib/src/features/auth/presentation/widgets/sign_in_widget.dart` (lines 280-288)
- When user taps "Sign in with Google" then cancels, it throws an exception
- Exception is caught and shown as a SnackBar: "Google Sign-In error: [full error message]"
- The error message is long and technical - confusing for users
- This is a valid use case (user changed their mind) and should NOT show an error

### Target State
- When user cancels Google Sign-In, **no error message** should be displayed
- Silently return to the sign-in screen
- Only show errors for actual failures (network error, server error, etc.)

### Implementation Notes
- In the catch block, check if the error is a cancellation:
  - `PlatformException` with code `sign_in_canceled`
  - Or `GoogleSignIn` returns null account
- If cancellation, just reset loading state without showing snackbar
- Only show error snackbar for genuine errors
- Example pattern:
  ```dart
  catch (e) {
    if (e is PlatformException && e.code == 'sign_in_canceled') {
      // User cancelled - do nothing
    } else {
      // Show error
    }
  }
  ```
- Google Sign-In cancellation varies by platform: iOS returns `null` (no exception), Android may throw `PlatformException` with code `sign_in_canceled`. Current code at line 199 calls `repository.signInWithGoogle()` — if the repository doesn't handle null, a null reference error occurs instead of a recognizable cancel. FIX: Handle null return from `GoogleSignIn().signIn()` in the repository method. Return a sentinel or throw a specific `SignInCancelledException`. In `sign_in_widget.dart`, check for both null return and the specific exception type.

---

## Change 6: Error Message Z-Index / Layering

### Current State
- Bug report: Error messages appear behind other UI elements ("one layer back")
- Uses standard Flutter SnackBar which should appear on top

### Target State
- Error messages should always appear on top of all other content
- Ensure SnackBars are not obscured by bottom sheets, dialogs, or other overlays

### Investigation Notes
- This may be related to using `ScaffoldMessenger.of(context)` from within a dialog or bottom sheet
- The SnackBar may be showing in the wrong Scaffold's messenger
- Check if `showSnackBar` is called from the correct context

### Implementation Notes
- Use `ScaffoldMessenger.of(context)` from the root scaffold context, not from within dialogs
- Or use a global snackbar approach (e.g., a global key for ScaffoldMessenger)
- Ensure the auth widget's context has access to the main scaffold's messenger

---

## Regression & Integration Notes

### Sign-out blank page - provider invalidation timing:
- Current sign-out in `profile_screen.dart` calls `ref.invalidate()` on multiple providers THEN navigates
- If provider invalidation triggers a rebuild before navigation completes, the screen may render with null/empty state -> blank page
- **Fix:** Navigate FIRST (or simultaneously), then let the auth redirect guard handle the state cleanup
- The GoRouter redirect in `router.dart` already checks auth state - leverage this instead of manual navigation

### Profile completion cancel - auth state safety:
- `profile_completion_screen.dart` has `PopScope(canPop: false)` to prevent back navigation
- Adding a cancel button that signs out must properly clear auth state
- **Risk:** If sign-out fails mid-way (network error), user is stuck on a screen they can't leave with corrupted auth state
- **Mitigation:** The cancel/sign-out action should always allow navigation away, even if the sign-out API call fails. Use `finally` block to ensure navigation happens.

### Profile completion - coordination with Spec 07:
- Spec 07 makes zip code optional on the same `profile_completion_screen.dart`
- Spec 05 adds a cancel button to the same screen
- Both changes are compatible: cancel button is in the AppBar, zip validation is in the form body
- **Implement together** to avoid merge conflicts on the same file

### Google sign-in cancel detection:
- `sign_in_widget.dart` calls Google Sign-In which can throw `PlatformException` with code `sign_in_canceled`
- Also possible: `GoogleSignIn().signIn()` returns `null` when user cancels (no exception)
- **Must handle both cases:** null return AND PlatformException
- Current code may show generic error snackbar for cancel - should silently ignore instead

### Error z-index / SnackBar context:
- If SnackBar is shown from a dialog context, it may appear behind the dialog
- Using `ScaffoldMessenger.of(context)` from the dialog's context gets the dialog's scaffold, not the root
- **Fix:** Use a root-level `ScaffoldMessenger` key, or dismiss the dialog before showing the SnackBar

### SnackBar z-index solution:
- For all SnackBar calls from within the bottom sheet or dialogs, use a root-level `ScaffoldMessenger` key OR dismiss the overlay first then show the SnackBar from the parent context. The `status_update_form.dart` conversion to a full page (Spec 04) fixes the form's SnackBar z-index, but the pattern should be audited in `fridge_profile_sheet.dart` lines 1060 and 1235-1237 as well.

### Sign-in widget context mismatch:
- When `SignInWidget` is used inside `fridge_profile_sheet.dart` sign-in dialog (line 1103), the `onSignInSuccess` callback chains to `_showSubscribeDialog` using a potentially disposed dialog context. The sign-in -> subscribe flow should check `context.mounted` before opening follow-up dialogs.

---

## Required Tests
- P0: Sign out from profile screen produces no blank/black screen — redirects to login
- P0: Profile screen handles null auth state gracefully (loading indicator, not crash)
- P1: Cancel button appears on profile completion screen
- P1: Cancel -> confirm -> sign out navigates to login even if sign-out API call fails
- P1: Google sign-in cancel produces no error snackbar
- P2: Sign-out dialog has proper padding (matches delete dialog)

## Files to Modify
1. `lib/src/features/auth/presentation/screens/profile_completion_screen.dart` - Add cancel button, coordinate with Spec 07 zip changes
2. `lib/src/features/profile/presentation/profile_screen.dart` - Fix sign-out dialog bugs, padding, provider invalidation order
3. `lib/src/features/auth/presentation/widgets/sign_in_widget.dart` - Handle Google cancel (null + PlatformException)
4. `packages/design_system/lib/components/dialogs_m3e.dart` - Verify dialog padding
5. `lib/src/routing/router.dart` - Verify auth redirect behavior after sign-out

## Design System Compliance
- Dialogs use `DialogM3E` component with M3E padding (24dp)
- Buttons use `FilledButtonM3E`, `TextButtonM3E`
- Error handling uses standard SnackBar patterns
- Navigation uses GoRouter redirect guards

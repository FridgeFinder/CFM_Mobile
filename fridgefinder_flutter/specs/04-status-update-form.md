# Spec 04: Status Update Form Improvements

## Summary
Convert the status update form from a modal dialog to a full page, refine condition options, and fix pre-filling behavior.

## Feedback Sources
- November 10, 2025 notes (page 7) - "Should be its own page"
- December 8, 2025 notes (page 4) - "Form should be wider"
- February 6, 2025 notes (page 2) - Condition terminology discussion

---

## Change 1: Convert Form from Modal to Full Page

### Current State
- **File:** `lib/src/features/profile/presentation/fridge_profile_sheet.dart` (lines 880-910)
- **File:** `lib/src/features/profile/presentation/widgets/status_update_form.dart` (lines 1-399)
- Form opens as a `Dialog` widget via `showDialog()`
- Dialog size: 90% width x 80% height of screen
- On smaller devices, the stepper and form content can feel cramped
- 3-step horizontal stepper: Condition -> Food Level -> Details

### Target State
- Form should be its own **full-screen page** (not a dialog/modal overlay)
- Navigate to it via `Navigator.push()` or GoRouter
- Full screen gives more room for the stepper, radio buttons, slider, and notes field
- Back button / close button in app bar to return to fridge profile
- Stepper should have room to breathe on all device sizes

### Implementation Notes
- Create a new screen widget (e.g. `StatusUpdateScreen`) that wraps `StatusUpdateForm`
- Replace `showDialog()` call with navigation to the new screen
- CRITICAL: Use `Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(...))` to push onto the root navigator, NOT GoRouter. Reasons: (1) The fridge profile sheet at lines 88-106 has route-change detection that calls `Navigator.of(context).pop()` when the GoRouter route changes — pushing a GoRouter route will auto-dismiss the sheet. (2) Adding a GoRouter route inside ShellRoute would render the form with the bottom nav bar visible. (3) Adding outside ShellRoute would dismiss the sheet on route change. Using imperative `Navigator.push` with `rootNavigator: true` avoids all three issues.
- Do NOT add this as a GoRouter route in `router.dart`. The status update page is a transient form launched from a bottom sheet, not a navigable destination.
- Pass fridge data via route parameters or provider
- Ensure the form still submits correctly and returns to the profile on success
- The new `StatusUpdateScreen` MUST be wrapped in `PopScope` with unsaved changes detection: `canPop: false` when `_selectedCondition != null || _selectedImage != null || _notesController.text.isNotEmpty`. Show a discard confirmation dialog when back is pressed with unsaved data.

---

## Change 2: Don't Pre-fill Form with Previous Report Data

### Current State
- **File:** `status_update_form.dart` (lines 32-37)
- Condition: NOT pre-filled (set to `null`) - already correct
- Food Level: **Pre-filled** with previous report's `foodPercentage` or defaults to 0.5
- Notes: NOT pre-filled - already correct
- Photo: NOT pre-filled - already correct

### Target State
- **No fields should be pre-filled** with previous report data
- Each status update should start fresh
- Food Level should default to **empty/no selection** state, not the previous value
- Reasoning: Pre-filling can lead to lazy updates where users just submit without actually checking

### Implementation Notes
- Change food level initialization from `widget.fridge.latestFridgeReport?.foodPercentage ?? 0.5` to a neutral default
- Consider making food level selection required (user must explicitly choose)
- The slider currently defaults to 0.5 ("Many Items") - could default to 0.0 or require explicit selection
- Alternative: Show the slider but with no initial selection state, requiring user to interact before proceeding
- Use a boolean flag `_hasTouchedSlider = false` to track explicit user interaction, rather than defaulting to 0.0. Defaulting to 0.0 ('Empty') is still pre-filling with a bias. Gate the 'Next' button on `_hasTouchedSlider == true`. This properly distinguishes 'user selected Empty' from 'user has not chosen yet'.

---

## Change 3: Make Fridge Condition Required

### Current State
- **File:** `status_update_form.dart` (lines 230-252)
- Label: "Fridge Condition **(Optional)**"
- If not filled out, previous condition remains unchanged
- Users can skip this step entirely

### Target State
- Make Fridge Condition **required** instead of optional
- Label: "Fridge Condition" (remove "(Optional)")
- User must select a condition before proceeding to Food Level step
- Disable "Next" button until a condition is selected

### Implementation Notes
- Update label text on line 235
- Add validation in the stepper's continue/next callback
- Show validation message if user tries to proceed without selecting
- The `_selectedCondition` starts as `null` - use this to gate the Next button

---

## Change 4: Standardize Condition Labels Across Web and Mobile

### Current State
- **File:** `status_update_form.dart` (lines 384-398)
- Mobile labels: "Good - Operational", "Dirty - Needs Cleaning", "Needs Repairs", "Not at Location"
- Web labels: "Fridge needs servicing", "Fridge needs cleaning", "Fridge is temporarily unavailable", "Fridge is permanently unavailable"
- "Out of Order" was renamed to "Needs Repairs" (already done, confirmed in code)
- No "Permanently Unavailable" option on mobile

### Target State
- Standardized labels for mobile:
  1. "Good" (simplified from "Good - Operational")
  2. "Needs Cleaning" (changed from "Dirty - Needs Cleaning")
  3. "Needs Repairs" (already correct, was "Out of Order")
  4. "Not at Location" (keep as-is)
- "Permanently Unavailable" / ghost fridge marking: **reserved for organizer/host user types only** (future feature, not implementing now)
- Match these labels in both the form AND the profile display

### Implementation Notes
- Update `_conditionLabel()` method in `status_update_form.dart`
- Update `statusText` getter in `fridge_domain.dart` to match
- Ensure `FridgeCondition.dirty` displays as "Needs Cleaning" everywhere (not "Dirty")
- The condition enum values stay the same (`dirty`, `good`, etc.) - only display text changes

---

## Change 5: Additional Notes - Keyboard Dismissal

### Current State
- **File:** `status_update_form.dart` (lines 343-351)
- TextFieldM3E for notes with maxLines: 3
- No explicit keyboard dismissal button
- Users may struggle to exit the text field on some devices

### Target State
- Ensure keyboard can be dismissed by tapping outside the text field
- The form page (from Change 1) should wrap content in a GestureDetector with unfocus behavior
- Consider adding a "Done" button above the keyboard (toolbar)

### Implementation Notes
- The full-screen page conversion (Change 1) naturally solves this since the page scaffold will have a GestureDetector
- Wrap the form body with `GestureDetector(onTap: () => FocusScope.of(context).unfocus())`
- Replace hardcoded colors in the form with M3E constants: line 63 `Color(0xFFFFB300)` -> `M3EColors.warning`, line 133 `Color(0xFF5FD65F)` -> `M3EColors.tertiary`, line 154 `Color(0xFFFF7043)` -> `M3EColors.alert`. Use `showSnackbarM3E()` utility instead of raw `ScaffoldMessenger.of(context).showSnackBar()`.

---

## Regression & Integration Notes

### Dialog-to-page navigation - CRITICAL callback chain:
- Current submit flow: `_submit()` in `status_update_form.dart` (line 75) -> invalidates `fridgeListProvider` and `singleFridgeProvider` (lines 108-109) -> calls `Navigator.pop(context)` (line 142) to close dialog -> fridge profile sheet refreshes
- When converting to full page: `Navigator.pop(context)` will pop the PAGE instead of a dialog - this is correct behavior
- BUT: Provider invalidations trigger on the form's context. Verify the fridge profile sheet (which launched the page) properly refreshes when popping back
- The `singleFridgeProvider` invalidation is key - it forces the profile sheet to re-fetch fresh fridge data
- **Test:** Submit a status update from the new page -> verify profile sheet shows updated data when returning

### Food level "no selection" state:
- The slider (`SliderM3E`) may not support a "no selection" visual state
- Option A: Default to 0.0 (Empty) but require explicit interaction before Next
- Option B: Keep slider visible but gate the Next button until user moves it
- Option C: Default to middle (0.5) but this is pre-filling which the spec says to avoid
- **Recommendation:** Default to 0.0 and require the user to explicitly set it, with validation on Next

### SnackBar context after page pop:
- In `status_update_form.dart` lines 130-137, the success SnackBar is shown using `ScaffoldMessenger.of(context)`. When the page is then popped at line 143, the SnackBar vanishes because its scaffold is disposed. Fix: Show the success SnackBar AFTER popping, on the parent route's context. Pass a callback or use a global `ScaffoldMessenger` key.

### Stepper landscape mode:
- The `StepperM3E` horizontal layout in landscape orientation may have insufficient vertical space for radio buttons. Consider wrapping in `OrientationBuilder` and switching to `StepperType.vertical` in landscape, or ensure content area has minimum height constraint.

### Condition label consistency with Spec 01:
- Spec 01 and Spec 04 both change labels in the same `_conditionLabel()` method (lines 384-398)
- Final labels should be: "Good", "Needs Cleaning", "Needs Repairs", "Not at Location"
- Must also update `fridge_domain.dart` `statusText` getter to match: line 252 "Dirty" -> "Needs Cleaning"

---

## Required Tests
- P0: `StatusUpdateForm` in a full `Scaffold` (not Dialog) renders all steps and submits correctly
- P0: After submit from page, `fridgeListProvider` and `singleFridgeProvider` are invalidated and profile sheet refreshes
- P1: Food level starts with no selection state (not pre-filled from previous report)
- P1: Next button disabled when condition not selected
- P1: Back button with unsaved changes shows discard confirmation

## Files to Modify
1. `lib/src/features/profile/presentation/widgets/status_update_form.dart` - Form changes (labels, pre-fill, required condition)
2. `lib/src/features/profile/presentation/fridge_profile_sheet.dart` - Replace showDialog with Navigator.push
3. `lib/src/features/map/domain/models/fridge_domain.dart` - Condition display text (statusText line 252)
4. New file: `lib/src/features/profile/presentation/screens/status_update_screen.dart` - Full page wrapper
5. `lib/src/routing/router.dart` - ~~Add route for status update page (if using GoRouter)~~ Do NOT add a GoRouter route; use imperative Navigator.push with rootNavigator

## Design System Compliance
- Full page should use standard `Scaffold` with `AppBar` using M3E theme
- Stepper should use M3E spacing and typography
- Radio buttons, slider, text field all already use M3E components
- Buttons use `FilledButtonM3E` and `TextButtonM3E`

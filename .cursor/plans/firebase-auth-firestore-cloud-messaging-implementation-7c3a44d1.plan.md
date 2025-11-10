<!-- 7c3a44d1-8aa9-4e65-a009-c421ee4bc38f a91616b0-da02-4a87-b379-19aa4f8af415 -->
# Firebase Implementation Guide for FridgeFinder Flutter App

## Project Context

FridgeFinder is a Flutter mobile app that helps users find and track community fridges. The app uses Firebase for authentication, data storage, push notifications, and location-based features. This document outlines all Firebase features to be implemented, current progress, remaining work, and debugging instructions.

## Core Firebase Features to Implement

### 1. Firebase Authentication

**Requirements:**

- Phone number authentication with SMS verification code
- Google Sign-In (Gmail) authentication
- Users remain signed in persistently across app sessions
- Anonymous access allowed for browsing (no auth required for map/list/status reports)
- Sign-in/logout/user info widget in sidebar footer and profile page top
- Account deletion with confirmation dialog (permanently deletes account and related data, keeps status reports anonymized)
- Compliance with Apple and Android developer guidelines for account handling

**Onboarding Flow:**

- Multi-step sign-up form (fade-in animations)
- Step 1: Volunteer status checkbox
- Step 2: If volunteer → zip code input (with privacy notice about non-profit funding)
- Step 2: Username generation (food-related for non-volunteers, volunteering-related for volunteers)
- Username regeneration via "roll dice" button
- Onboarding form should ONLY show on first sign-up, NOT on subsequent sign-ins

**User Profile Model:**

- userId (Firebase Auth UID)
- email (nullable)
- phoneNumber (nullable)
- username (unique, generated)
- isVolunteer (boolean)
- zipCode (nullable, only for volunteers)
- points (integer, starts at 0)
- createdAt (DateTime)
- lastLoginAt (DateTime, nullable)
- settings (UserSettings object)

**UserSettings Model:**

- notificationsEnabled (boolean)
- geofencingEnabled (boolean)
- notificationFrequency (enum: immediate, daily, weekly)

### 2. Firebase Realtime Database

**Database Structure:**

```
/users/{userId}/
 - profile data (UserProfile)
 - subscribedFridges/{fridgeId}/
  - notificationPreferences (NotificationPreferences)
  - subscribedAt (timestamp)
 - points (integer)
 - fcmToken (string)
 - settings (UserSettings)
/statusReports/{reportId}/
 - fridgeId (string)
 - fridgeName (string)
 - condition (string)
 - foodPercentage (double)
 - reportDate (timestamp)
 - notes (string, nullable)
 - photoUrl (string, nullable)
```

**Features:**

- "My Fridges" page (formerly "Favorites") showing subscribed fridges
- When not signed in: display message explaining benefits + sign-in button
- When signed in: display list of subscribed fridges
- Subscribe button in fridge details panel header (purple FilledButton with "Subscribe" text)
- Subscribe button visible even when not signed in (triggers sign-in flow)
- Show subscribed state with checkmark and glowing border animation
- Subscription dialog with notification preference checkboxes:
                                                                - Updated with food (auto-selected for non-volunteers)
                                                                - Running low on food (auto-selected for volunteers)
                                                                - Empty (auto-selected for volunteers)
                                                                - Needs cleaning (auto-selected for volunteers)
                                                                - Needs servicing (auto-selected for volunteers)
                                                                - Routine validation >2 days (auto-selected for volunteers)
- Unsubscribe confirmation dialog
- Edit notification preferences for subscribed fridges
- Points system for volunteers:
                                                                - 10 points for status reports
                                                                - +20 points for cleaning a dirty fridge
                                                                - +30 points for stocking food
                                                                - Eventually supports neighborhood leaderboard

### 3. Firebase Cloud Messaging (FCM)

**Requirements:**

- Request push notification permission on first fridge subscription
- Allow users to toggle push notifications on/off in profile page
- Send notifications based on per-fridge subscription preferences
- Handle foreground notifications (show local notification)
- Handle background notifications (system handles)
- Notification navigation: tapping notification opens fridge details sheet
- Notification payload includes fridgeId for navigation

**Notification Types:**

- Updated with food
- Running low on food
- Empty
- Needs cleaning
- Needs servicing
- Routine validation (>2 days since update)

### 4. Geofencing

**Requirements:**

- Request geofencing permission on first fridge subscription
- Ask about geofencing with explanation: "Get notifications when near fridges needing attention (within 2-block radius, if location is always on in the background)"
- Allow users to deny geofencing
- Toggle geofencing on/off in profile page (like location access toggle)
- Monitor location in background (requires "always" permission)
- Detect when user is within 2-block radius (~400 meters) of fridge needing attention
- Send push notification when geofence triggered
- Only trigger for fridges user is subscribed to with relevant preferences

### 5. Firebase Cloud Functions

**Requirements:**

- Trigger on Realtime Database status report creation
- Check user subscription preferences
- Send FCM notifications based on preferences
- Handle invalid FCM tokens (remove from database)
- Scheduled function for routine validation checks (daily at 9 AM)
- Batch notifications for users with daily/weekly frequency preferences

**File:** `functions/index.js`

### 6. Local Notifications

**Requirements:**

- Use `flutter_local_notifications` package
- Display foreground FCM notifications as local notifications
- Handle notification taps for navigation
- Android notification channel: "fridgefinder_notifications"
- iOS notification permissions

**File:** `lib/src/core/services/local_notification_service.dart`

## Current Implementation Status

### ✅ Completed

1. **Firebase Setup:**

                                                                                                - Firebase initialized in `main.dart`
                                                                                                - Firebase options configured for Android and iOS
                                                                                                - Google Sign-In configured (AndroidManifest.xml, Info.plist)

2. **Authentication Infrastructure:**

                                                                                                - `AuthRepository` with phone and Google Sign-In methods
                                                                                                - `auth_provider.dart` with Riverpod providers (authUser, currentAuthUser, userProfile, isAuthenticated)
                                                                                                - `SignInWidget` with phone and Gmail options
                                                                                                - `SignUpForm` with multi-step onboarding
                                                                                                - `UsernameGenerator` for themed username generation
                                                                                                - Phone number formatting and validation utilities

3. **Realtime Database Infrastructure:**

                                                                                                - `DatabaseProvider` for centralized database reference
                                                                                                - `SubscriptionPreferences` and `UserProfile` Freezed models
                                                                                                - `subscriptions_provider.dart` with Riverpod providers
                                                                                                - `points_provider.dart` for volunteer points tracking
                                                                                                - `SubscriptionManager` for subscribe/unsubscribe operations
                                                                                                - `MyFridgesScreen` UI (basic structure)

4. **FCM Infrastructure:**

                                                                                                - `FCMService` class with token management
                                                                                                - Background message handler in `main.dart`
                                                                                                - Foreground message handling setup
                                                                                                - `LocalNotificationService` for displaying notifications

5. **Geofencing Infrastructure:**

                                                                                                - `GeofencingService` class structure
                                                                                                - Location monitoring setup

6. **Cloud Functions:**

                                                                                                - `functions/index.js` with status report trigger
                                                                                                - Notification sending logic
                                                                                                - Routine validation scheduled function

7. **UI Components:**

                                                                                                - Subscribe button in `FridgeProfileSheet` header
                                                                                                - `SubscriptionDialog` widget
                                                                                                - Sign-in widgets in sidebar and profile page
                                                                                                - Router configured with `/my-fridges` route

8. **Navigation:**

                                                                                                - GoRouter with error handling for Firebase Auth deep links
                                                                                                - Bottom navigation includes "My Fridges"
                                                                                                - Drawer menu includes "My Fridges"

### 🚧 Partially Implemented / Needs Fixes

1. **Authentication Flow:**

                                                                                                - Phone auth works but throws Navigator exception causing black screen
                                                                                                - Google Sign-In works but throws Navigator exception causing black screen
                                                                                                - Sign-up form incorrectly shows for existing users on re-sign-in
                                                                                                - Profile check logic needs refinement

2. **UI Display:**

                                                                                                - User info (username) not displaying in sidebar when authenticated
                                                                                                - Sign-out button exists but may not be visible/working correctly
                                                                                                - Delete account button exists but may not be functional
                                                                                                - User info not displaying in profile page when authenticated

3. **Subscription Dialog:**

                                                                                                - Dialog shows but throws error when subscribing
                                                                                                - Wrong initial checkbox selections (not respecting volunteer status defaults)

4. **Provider State:**

                                                                                                - Auth state not updating UI reactively
                                                                                                - Provider invalidation may not be working correctly

### ❌ Not Implemented

1. **Points System:**

                                                                                                - Points not awarded when submitting status reports
                                                                                                - Points not awarded for cleaning dirty fridges
                                                                                                - Points not awarded for stocking food
                                                                                                - Points display in profile page (UI exists but data may not update)

2. **Geofencing:**

                                                                                                - Background location monitoring not active
                                                                                                - Geofence detection not implemented
                                                                                                - Geofence-triggered notifications not implemented

3. **Notification Navigation:**

                                                                                                - Notification tap navigation not fully working
                                                                                                - Fridge details sheet not opening from notification

4. **FCM Token Management:**

                                                                                                - Token not saved to Realtime Database on sign-in
                                                                                                - Token not updated when user signs in on new device

5. **First Subscription Flow:**

                                                                                                - Push notification permission request on first subscription
                                                                                                - Geofencing permission request on first subscription

## Current Errors and Debugging Attempts

### Error 1: Navigator Exception (Black Screen)

**Error:**

```
'package:flutter/src/widgets/navigator.dart': Failed assertion: line 4061 pos 12: '!_debugLocked': is not true.
```

**Occurrence:**

- After phone auth verification code entry
- After Google Sign-In completion
- Leads to black screen

**Root Cause:**

- Multiple `Navigator.pop()` calls or navigation operations happening simultaneously
- Dialog closing while another navigation operation is in progress
- Provider invalidation triggering rebuilds during navigation

**Attempted Fixes:**

1. Added delays between navigation operations
2. Added `mounted` checks before navigation
3. Changed dialog closing order (close sign-up, then sign-in)
4. Added provider invalidation delays
5. Changed from `Navigator.pop()` to explicit dialog closing

**Files Involved:**

- `lib/src/features/auth/presentation/widgets/sign_in_widget.dart` (lines 84-163, 165-232)
- `lib/src/features/auth/presentation/widgets/sign_up_form.dart` (lines 140-177)

**Next Steps:**

- Use `WidgetsBinding.instance.addPostFrameCallback` for navigation
- Ensure only one navigation operation at a time
- Use `Navigator.of(context, rootNavigator: true)` for dialogs
- Consider using a state machine for auth flow

### Error 2: Sign-Up Form Shows for Existing Users

**Error:**

- Sign-up form appears when re-signing in with existing account
- Profile check happens but form still shows

**Root Cause:**

- Profile check happens before auth state fully updates
- `getUserProfile` may return null even for existing users
- Race condition between auth state update and profile fetch

**Attempted Fixes:**

1. Added delays before profile check
2. Added provider invalidation before profile check
3. Checked profile directly from repository instead of provider

**Files Involved:**

- `lib/src/features/auth/presentation/widgets/sign_in_widget.dart` (lines 113-114, 183-184)

**Next Steps:**

- Wait for auth state stream to emit user before checking profile
- Use `ref.listen` to react to auth state changes
- Add retry logic for profile fetch

### Error 3: Subscribe Dialog Error

**Error:**

- Error thrown when clicking "Subscribe" button in dialog
- Error details not visible in user report

**Root Cause:**

- Async operation in `_showSubscribeDialog` may be failing
- Provider read may be returning error state
- Subscription manager may be throwing exception

**Attempted Fixes:**

1. Changed from `whenData` to `await` pattern
2. Added error handling with try-catch
3. Added context.mounted checks

**Files Involved:**

- `lib/src/features/profile/presentation/fridge_profile_sheet.dart` (lines 737-762)
- `lib/src/features/auth/presentation/widgets/subscription_dialog.dart` (lines 134-152)

**Next Steps:**

- Add detailed error logging
- Check subscription manager implementation
- Verify user is authenticated before subscribing

### Error 4: Wrong Checkbox Defaults in Subscription Dialog

**Error:**

- Checkboxes not showing correct defaults based on volunteer status
- Non-volunteers should have "Updated with food" selected
- Volunteers should have all others selected

**Root Cause:**

- `isVolunteer` flag may not be passed correctly
- Default preferences logic may be incorrect
- User profile may not be loaded when dialog opens

**Files Involved:**

- `lib/src/features/auth/presentation/widgets/subscription_dialog.dart` (lines 26-42)

**Next Steps:**

- Verify `isVolunteer` is correctly read from user profile
- Add logging to verify default preferences
- Ensure user profile is loaded before showing dialog

### Error 5: User Info Not Displaying

**Error:**

- Username not showing in sidebar when authenticated
- User info not showing in profile page when authenticated
- Sign-out button not visible

**Root Cause:**

- `isAuthenticatedProvider` may be returning false even when authenticated
- `userProfileProvider` may be returning null or error
- UI may not be rebuilding when auth state changes
- Provider invalidation may not be triggering rebuilds

**Attempted Fixes:**

1. Added provider invalidation after sign-in
2. Added auth state listener in `app.dart`
3. Fixed error handling in `isAuthenticatedProvider`

**Files Involved:**

- `lib/src/common_widgets/main_shell.dart` (lines 306-396)
- `lib/src/features/profile/presentation/profile_screen.dart` (lines 30-212)
- `lib/src/core/providers/auth_provider.dart` (lines 70-87)

**Next Steps:**

- Verify auth state stream is emitting correctly
- Check if providers are being watched correctly
- Add debug logging to track provider state
- Ensure UI widgets are using `Consumer` or `ConsumerWidget`

### Error 6: Delete Account Button Not Working

**Error:**

- Delete account button exists but functionality not verified
- May not be calling repository method correctly
- May not be showing confirmation dialog

**Files Involved:**

- `lib/src/features/profile/presentation/profile_screen.dart` (lines 187-204)
- Need to check `_showDeleteAccountDialog` implementation

**Next Steps:**

- Verify `_showDeleteAccountDialog` method exists and is implemented
- Check if confirmation dialog is shown
- Verify `deleteAccount` repository method is called
- Test account deletion flow

## File Structure Reference

### Authentication Files

- `lib/src/features/auth/data/repositories/auth_repository.dart` - Auth operations
- `lib/src/features/auth/domain/models/user_profile.dart` - User profile model
- `lib/src/features/auth/presentation/widgets/sign_in_widget.dart` - Sign-in UI
- `lib/src/features/auth/presentation/widgets/sign_up_form.dart` - Onboarding form
- `lib/src/core/providers/auth_provider.dart` - Auth state providers

### Subscription Files

- `lib/src/core/providers/subscriptions_provider.dart` - Subscription providers
- `lib/src/features/auth/domain/models/subscription_preferences.dart` - Subscription model
- `lib/src/features/auth/presentation/widgets/subscription_dialog.dart` - Subscribe dialog
- `lib/src/features/auth/presentation/screens/my_fridges_screen.dart` - My Fridges page

### Notification Files

- `lib/src/core/services/fcm_service.dart` - FCM service
- `lib/src/core/services/local_notification_service.dart` - Local notifications
- `lib/src/core/services/geofencing_service.dart` - Geofencing service
- `lib/src/core/providers/notification_providers.dart` - Notification providers
- `functions/index.js` - Cloud Functions

### UI Files

- `lib/src/common_widgets/main_shell.dart` - Sidebar with auth widget
- `lib/src/features/profile/presentation/profile_screen.dart` - Profile page
- `lib/src/features/profile/presentation/fridge_profile_sheet.dart` - Fridge details with subscribe button

## Key Implementation Details

### Provider Pattern

- All providers use `@riverpod` annotation for code generation
- Stream providers return `AsyncValue` automatically
- Use `ref.watch` for reactive updates, `ref.read` for one-time reads
- Invalidate providers with `ref.invalidate()` to force refresh

### Navigation Pattern

- Use GoRouter for navigation
- Dialogs use `showDialog` with `Navigator.of(context).pop()`
- Bottom sheets use `showModalBottomSheet`
- Handle deep links in router `redirect` and `errorBuilder`

### Error Handling

- Use try-catch blocks around async operations
- Check `mounted` before navigation operations
- Use `context.mounted` before showing dialogs/snackbars
- Log errors with `logger.e()` from `app_logger.dart`

### Database Operations

- Use `DatabaseProvider.databaseRef` for database access
- Write operations: `ref.set()`, `ref.update()`, `ref.push()`
- Read operations: `ref.get()`, `ref.onValue` for streams
- Handle null/empty snapshots gracefully

## Testing Checklist

- [ ] Phone auth: sign in, verify code, check profile creation
- [ ] Google Sign-In: sign in, check profile creation
- [ ] Re-sign-in: existing users should NOT see sign-up form
- [ ] Subscribe: dialog shows, checkboxes correct, subscription saves
- [ ] Unsubscribe: confirmation dialog, subscription removed
- [ ] User info: displays in sidebar and profile page
- [ ] Sign out: button works, user signed out, UI updates
- [ ] Delete account: confirmation dialog, account deleted, UI updates
- [ ] Points: awarded correctly, displayed correctly
- [ ] Notifications: received, navigation works
- [ ] Geofencing: permission requested, monitoring active, notifications sent

## Next Steps for Implementation

1. Fix Navigator exception by ensuring single navigation operation
2. Fix profile check to prevent sign-up form for existing users
3. Fix subscribe dialog error with proper error handling
4. Fix checkbox defaults in subscription dialog
5. Fix user info display by ensuring providers update correctly
6. Implement points awarding in status report submission
7. Implement geofencing background monitoring
8. Implement notification navigation
9. Implement FCM token saving to database
10. Implement first subscription permission requests

### To-dos

- [ ] Fix Navigator exception causing black screen after auth flows
- [ ] Prevent sign-up form from showing for existing users on re-sign-in
- [ ] Fix error when clicking Subscribe button in subscription dialog
- [ ] Fix wrong initial checkbox selections in subscription dialog based on volunteer status
- [ ] Fix user info (username) not displaying in sidebar and profile page when authenticated
- [ ] Ensure sign-out button is visible and functional in sidebar and profile page
- [ ] Implement and test delete account functionality with confirmation dialog
- [ ] Implement points system: award points for status reports, cleaning, and stocking
- [ ] Implement background location monitoring and geofence detection
- [ ] Implement navigation to fridge details when notification is tapped
- [ ] Save FCM token to Realtime Database on sign-in and update when needed
- [ ] Request push notification and geofencing permissions on first fridge subscription
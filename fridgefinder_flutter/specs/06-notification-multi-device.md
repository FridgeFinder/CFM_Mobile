# Spec 06: Notification & Multi-Device FCM Token Support

## Summary
Support multiple FCM tokens per user for multi-device notification delivery.

## Feedback Sources
- January 2026 notes (pages 5-6) - Notifications discussion

---

## Change 1: Store FCM Tokens as a List

### Current State
- **File:** `lib/src/core/services/fcm_service.dart` (lines 305-348)
- **File:** `lib/src/features/auth/domain/models/user_profile.dart` (line 68)
- Single `fcmToken: String?` field on UserProfile
- New token overwrites old token: `copyWith(fcmToken: token)` (line 321)
- Database path: `users/{userId}/fcmToken` - single string value
- Only the last device to authenticate receives notifications
- Logging out removes the single token, but badge count may persist on device

### Target State
- Store FCM tokens as a **list/set** on the user record
- Database path: `users/{userId}/fcmTokens` - list of token strings
- Each device adds its token to the list on login
- Each device removes its token from the list on logout
- All devices in the list receive push notifications
- Prevent duplicate tokens in the list

### Implementation Notes

**Data Model Change:**
- In `user_profile.dart`: Change `String? fcmToken` to `List<String> fcmTokens` with `@Default([])`
- Or keep backward compatibility: support reading old `fcmToken` field and migrating to `fcmTokens`

**Token Add Flow (login/refresh):**
- On login or token refresh, add current device's token to the list
- Use Firebase Realtime Database transaction or set operation
- Deduplicate: check if token already exists before adding
- Database operation: `users/{userId}/fcmTokens` -> add token to list

**Token Remove Flow (logout):**
- On logout, remove ONLY the current device's token from the list
- Don't clear the entire list (other devices should keep their tokens)
- Database operation: Find and remove specific token from the list

**Token Refresh Handling:**
- When a token refreshes (new token replaces old on same device):
  - Remove old token from list
  - Add new token to list
  - Need to cache the previous token locally to know which one to remove

**Backend Impact:**
- The notification sending backend needs to iterate over `fcmTokens` list instead of reading single `fcmToken`
- Each token gets its own FCM message
- Handle stale tokens (FCM returns error for invalid tokens - remove them from list)

**ARCHITECTURAL RECOMMENDATION:** Use a Map, not a List, for token storage. Store as `fcmTokens: { "device_hash": "token_string" }` in Firebase RTDB. Benefits: (1) Per-device writes are atomic without transactions — each device writes to its own child key. (2) Firebase RTDB handles concurrent writes to different child keys correctly. (3) No read-modify-write race condition. (4) Easy to remove a specific device's token by key. The device hash can be derived from a combination of platform + device ID or generated on first launch and cached in SharedPreferences.

**CRITICAL:** `updateUserProfile()` at `auth_repository.dart` line 251 uses `userRef.update(profile.toJson())` which is a shallow merge. This writes ALL profile fields, creating a race condition when two devices call it simultaneously. For token operations, use targeted field updates: `userRef.child('fcmTokens').child(deviceHash).set(token)` instead of writing the entire profile.

**Migration:**
- On first app launch after update, check for old `fcmToken` field
- If exists, migrate to `fcmTokens: [oldToken]`
- Clean up old `fcmToken` field
- The old `fcmToken` field will NOT be automatically removed by `update()` (it only merges, never deletes). Explicitly delete it during migration: `userRef.child('fcmToken').remove()`.

---

## Change 2: Clean Up Badge Count on Logout

### Current State
- When logged out, user doesn't receive notifications (good)
- But app icon badge count may still show notifications from before logout
- Badge count persists on the device even after token removal

### Target State
- On logout, clear the app badge count
- Remove device FCM token from user's token list
- Badge should show 0 after logout

### Implementation Notes
- Call `FlutterAppBadger.removeBadge()` or equivalent on logout
- Or use Firebase Messaging to reset badge: `FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(badge: false)` temporarily
- This is a device-local operation, separate from the token list management

---

## Architectural Issues

### FCMService never disposed by its provider
`notification_providers.dart` creates `FCMService` but never calls `dispose()`. No `ref.onDispose(() => service.dispose())` exists. The `WidgetsBindingObserver` remains registered and stream subscriptions (`_tokenSubscription`, `_messageSubscription`, `_settingsSubscription`) leak. FIX: Add `ref.onDispose()` callback in the provider to call `service.dispose()`.

### `onTokenRefresh` stale closure risk
The `onTokenRefresh` listener at line 104 is guarded by `_tokenSubscription ??=`. If a user signs out (which does NOT cancel `_tokenSubscription`) and signs back in, `initialize()` runs again but `_tokenSubscription` is non-null. The old subscription holds stale closure references and may save a new device's token under the previous user's record. FIX: Cancel `_tokenSubscription` in `deleteToken()` and set it to null.

### `notification_providers.dart` calls `initialize()` on every auth change
`ref.listen(authUserProvider, ...)` at line 15 calls `service.initialize()` every time auth state emits (including token refreshes). Operations like `_verifyTokenSaved()` make unnecessary database reads on each emission. FIX: Add an `_isInitialized` flag to skip redundant initialization.

---

## Scope Note
This spec covers the FCM token storage architecture change. The actual notification sending logic is likely on the backend (Cloud Functions or server) and may need separate changes to iterate over the token list. This spec focuses on the mobile client changes only.

---

## Regression & Integration Notes

### Data model migration - CRITICAL:
- Existing users have `fcmToken: "token_string"` (single string) in Firebase
- Changing to `fcmTokens: ["token1", "token2"]` will break `fromJson` deserialization for existing users
- **Migration strategy options:**
  - Option A: Support BOTH fields. Read old `fcmToken` on login, migrate to `fcmTokens`, delete old field
  - Option B: Add custom `fromJson` logic that handles both String and List types
  - Option C: Run a one-time Cloud Function to migrate all existing records
- **Recommended:** Option A (client-side migration on login) - simplest, no backend deployment needed

### Token refresh - Old token tracking:
- `fcm_service.dart` line 104: `onTokenRefresh` listener saves new token but doesn't remove old
- Must cache the current token locally (e.g. in memory or Hive) to know which to remove on refresh
- Flow: Store current token -> on refresh, remove old from list, add new to list, update local cache

### Backend coordination required:
- `functions/index.js` reads `userData.subscribedFridges` and sends notifications
- The notification-sending Cloud Functions need to iterate over `fcmTokens` list instead of single `fcmToken`
- If mobile ships before backend update: multi-device tokens saved but only one gets notified (backend reads first/last)
- **Recommendation:** Ship backend changes first or simultaneously
- CONFIRMED: 6 Cloud Functions in `functions/index.js` reference `subscribedFridges` and `fcmToken`. Specifically: line 41 (`userData.fcmToken` check), line 62 (`token: userData.fcmToken` for FCM message), line 104 (removes invalid token). ALL must be updated to iterate `fcmTokens` Map. If mobile ships first, only one device gets notified (Cloud Functions read single `fcmToken`).

### Sign-out token removal:
- Current `deleteToken()` in `fcm_service.dart` (lines 469-476) calls `_messaging.deleteToken()` (Firebase SDK)
- This invalidates the token with Firebase servers but does NOT remove it from the user's database record
- Must also call database remove: find current device's token in `fcmTokens` list and remove it
- If token not removed from DB on logout, backend will try to send to invalid token -> FCM error (harmless but wasteful)

### Sign-out token cleanup sequence:
The sign-out flow must: (1) Read current device's token BEFORE sign-out, (2) Remove it from `fcmTokens` Map in database, (3) THEN call `_messaging.deleteToken()`, (4) THEN call `signOut()`. Steps 1-2 must happen before `signOut()` since after sign-out the user's database path may be inaccessible (depending on Firebase security rules).

---

## Required Tests

- **P0:** `UserProfile.fromJson({'fcmToken': 'old_token', ...})` still deserializes (backward compat)
- **P0:** `UserProfile.fromJson({'fcmTokens': {'device1': 'token1'}, ...})` deserializes new format
- **P0:** Migration converts old `fcmToken` string to `fcmTokens` Map entry
- **P1:** Sign-out removes ONLY current device's token, not others
- **P1:** Token refresh replaces old token with new token in Map
- **P2:** `FCMService.dispose()` is called when provider is disposed

---

## Files to Modify
1. `lib/src/features/auth/domain/models/user_profile.dart` - Data model change (add `fcmTokens`, keep `fcmToken` for migration)
2. `lib/src/core/services/fcm_service.dart` - Token management (add/remove from list, track old token)
3. `lib/src/features/auth/data/auth_repository.dart` - Sign out token cleanup
4. `functions/index.js` - Backend notification sending (iterate token list) - coordinate with backend team

## Design System Compliance
- No UI changes in this spec
- Data model and service layer only

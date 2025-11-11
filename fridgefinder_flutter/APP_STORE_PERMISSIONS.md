# App Store Permissions Documentation

This document explains the permissions required by FridgeFinder for iOS App Review and Google Play Store submission.

## Location Permissions

### iOS: NSLocationAlwaysAndWhenInUseUsageDescription

**Permission Requested:** "Always Allow" Background Location Access

**User-Facing Description:**
> FridgeFinder needs background location access to send you notifications when you're near a community fridge that needs volunteers or has fresh food available.

**Why This Permission Is Needed:**
- **Volunteer-only feature**: This permission is ONLY requested for users who sign up as volunteers
- **Geofencing for community impact**: Volunteers opt-in to receive notifications when they are near a community fridge that needs restocking or maintenance
- **Timely alerts**: Background location enables the app to notify volunteers when they're within a 4-block radius (~400 meters) of ANY fridge needing help, even when the app is not actively being used
- **Volunteer engagement**: This feature helps connect available volunteers with nearby fridges in real-time, improving community response times
- **Not for food finders**: Regular users who just want to find food DO NOT see or need this permission
- **Smart notifications**: Uses Firebase Cloud Messaging for reliable delivery even when app is closed

**How It's Used:**
1. Permission is requested **only** for volunteer users when they subscribe to their first fridge and opt into geofencing
2. Non-volunteer users (food finders) never see geofencing prompts or options
3. User sees a clear dialog explaining the feature before permission is requested
4. Volunteers can enable/disable geofencing at any time in their profile settings
5. Location data is used only for geofence triggers and is never stored, tracked, or shared
6. **Proximity detection for ALL fridges** in the system (not just subscribed), helping volunteers discover nearby needs
7. Notifications include distance in feet and point rewards for specific actions (cleaning: 20-50 points, stocking: 30-60 points, routine updates: 10 points)
8. **Once-per-day notification limit:** Each fridge can trigger maximum one notification per day per notification type (prevents spam)
9. Notification history tracked both client-side and in Firebase backend for reliable enforcement

**User Control:**
- Optional feature - users can decline geofencing and still use all other app features
- Toggle can be turned off at any time in Profile > Settings
- Clear explanation provided before requesting permission
- No location tracking - only geofence boundary crossings trigger notifications

**Background Modes Enabled:**
- `location` - Required for geofencing to work when app is not in foreground
- `remote-notification` - Required for Firebase Cloud Messaging push notifications
- `fetch` - For background data updates

### Android: ACCESS_BACKGROUND_LOCATION

**Permission Requested:** Background Location Access (Android 10+)

**User-Facing Description (in-app):**
> FridgeFinder needs background location access to send you notifications when you're near a community fridge that needs volunteers or has fresh food available.

**Why This Permission Is Needed:**
Same rationale as iOS - enables geofencing notifications for volunteer coordination.

**How It's Used:**
- Requested after foreground location permissions (ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION) are granted
- Only requested when user opts into geofencing feature
- Used exclusively for geofence monitoring
- No location tracking or data storage

**Compliance:**
- Android 11+ requires prominent disclosure before requesting background location (✅ provided via dialog)
- Android 12+ background location limits respected (geofencing works within system limits)
- Can be revoked at any time through system settings or app settings

## When-In-Use Location Permissions

### iOS: NSLocationWhenInUseUsageDescription

**User-Facing Description:**
> FridgeFinder needs your location to show nearby community fridges on the map and calculate distances. Your location is never stored or shared.

**Why This Permission Is Needed:**
- Display fridges on interactive map
- Calculate distances to help users find nearest fridges
- Center map on user's current location
- Sort fridge list by proximity

**How It's Used:**
- Only active when app is open and map/list is visible
- Location is processed locally on device
- Never transmitted to servers or stored in database
- Used only for display and distance calculations

## Notification Permissions

### iOS: User Notification Permission
### Android: POST_NOTIFICATIONS (Android 13+)

**Why This Permission Is Needed:**
- Send alerts when subscribed fridges need restocking or maintenance
- Notify when fridges near user are updated (if geofencing enabled)
- Community announcements about fridge status changes

**User Control:**
- Requested on first subscription
- Can be disabled in system settings
- Frequency controlled by user preferences in app

## Camera & Photo Library Permissions

### iOS: NSCameraUsageDescription, NSPhotoLibraryUsageDescription
### Android: CAMERA, READ_MEDIA_IMAGES

**Why These Permissions Are Needed:**
- Volunteers can upload photos of fridge conditions
- Helps community see fridge status (empty, full, needs cleaning, etc.)
- Visual documentation for maintenance reports

**User Control:**
- Only requested when user attempts to upload a photo
- Optional - users can contribute without photos
- Photos are user-submitted, not automatic

## Data Privacy Summary

FridgeFinder is committed to user privacy:
- ✅ Location data never stored on servers
- ✅ No user tracking or analytics on location
- ✅ All location permissions are optional (except when-in-use for core map feature)
- ✅ Clear explanations before requesting permissions
- ✅ User controls in settings to manage all permissions
- ✅ Geofencing is opt-in only
- ✅ No third-party location data sharing

## App Store Reviewer Testing

### Testing Volunteer Geofencing Feature:

**Setup:**
1. Sign up and create a profile **AS A VOLUNTEER** (important: check the volunteer checkbox during signup)
2. Subscribe to your first fridge
3. When prompted, agree to enable geofencing (non-volunteers will NOT see this prompt)
4. Approve "Always Allow" location permission when system dialog appears
5. Check Profile > Settings to see geofencing toggle is enabled (only visible for volunteers)

**Testing Notifications:**
1. Simulate location near ANY fridge (within 400 meters / 4 blocks)
2. Notification will appear if fridge:
   - Is dirty (needs cleaning) - shows "Earn 20-50 points"
   - Is empty (needs stocking) - shows "Earn 30-60 points"
   - Hasn't been updated in >2 days - shows "Earn 10 points"
3. Notification includes distance in feet and specific action needed
4. Example: "This fridge 328 feet away needs cleaning! Earn 20-50 points by heading there and taking care of it"
5. Notifications work even when app is closed (Firebase Cloud Messaging)
6. **Once-per-day limit:** If you receive a notification for a fridge, you won't get another notification for that same fridge/type combination until the next day
7. Different notification types for same fridge still work (e.g., "cleaning" in morning, "stocking" in evening if status changes)

**Testing Non-Volunteer Experience:**
1. Sign up as a regular user (do NOT check volunteer box)
2. Subscribe to fridges
3. Verify that geofencing is NEVER mentioned or prompted
4. Verify Profile > Settings does NOT show geofencing toggle
5. Regular users only need "While Using" location for map features

**Backend Integration:**
- Geofencing notifications sent via Firebase Cloud Function (`sendGeofencingNotification`)
- Production Firebase project used for all authentication and messaging
- Fridge data API uses dev environment by default (can be switched in settings)
- Daily notification limits enforced both client-side and server-side
- Notification history stored in Firebase at `users/{userId}/geofencing/lastNotifications`
- Automatic cleanup of notification records older than 7 days

**Privacy Note:**
- Notification history only tracks **dates** of notifications sent, not location data
- No user location is ever stored in the database
- Location is only used in real-time for proximity detection

Note: Geofencing can be disabled at any time from Profile > Settings (volunteers only) without affecting other app functionality.

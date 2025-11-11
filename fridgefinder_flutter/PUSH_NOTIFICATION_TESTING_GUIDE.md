# Push Notification Testing Guide

This guide explains how to test push notifications in the FridgeFinder app, including FCM notifications, Cloud Functions triggers, and geofencing notifications.

## Overview

The app supports three types of notifications:

1. **FCM Notifications** - Sent via Firebase Cloud Messaging when fridge status changes
2. **Cloud Functions Notifications** - Triggered automatically when status reports are created
3. **Geofencing Notifications** - Local notifications when you're near a fridge

## Prerequisites

1. **Firebase Project Setup**
   - Cloud Functions deployed (already done ✅)
   - FCM enabled in Firebase Console
   - Realtime Database configured

2. **App Setup**
   - User must be signed in
   - User must subscribe to at least one fridge
   - Notification permissions granted (requested on first subscription)

3. **Testing Tools**
   - Firebase Console access
   - Node.js installed (for test scripts)
   - Service account key file

## Testing Methods

### Method 1: Using the In-App Test Screen (Easiest)

1. **Open the app** and sign in
2. **Subscribe to a fridge** from the map or list view
3. **Navigate to Profile** screen
4. **Scroll to Debug Tools** section (only visible in debug mode)
5. **Tap "Test Notifications"**
6. **Select a subscribed fridge** from the dropdown
7. **Use the test buttons:**
   - **Create Test Status Report** - Creates a status report in Realtime Database, triggering Cloud Functions
   - **Test Local Notification** - Sends a local notification directly
   - **Test Geofencing Notification** - Tests geofencing (requires being within 400m of fridge)

### Method 2: Using Firebase Console

1. **Get your FCM token:**
   - Open the app
   - Go to Profile > Test Notifications
   - Copy your FCM token (shown at the top)

2. **Send test message:**
   - Go to Firebase Console > Cloud Messaging
   - Click "Send test message"
   - Paste your FCM token
   - Add notification title and body
   - Add custom data:
     ```json
     {
       "type": "fridge_update",
       "fridgeId": "your-fridge-id",
       "reason": "test"
     }
     ```
   - Click "Test"

### Method 3: Using Test Scripts

#### Setup

1. **Install dependencies:**
   ```bash
   cd functions
   npm install firebase-admin
   ```

2. **Set service account key:**
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="./secrets/fridgefinder-app-1-17dbe2831a13.json"
   ```

#### Test FCM Notification Directly

```bash
node functions/test_fcm_notification.js <fcm-token> <fridge-id> [title] [body]
```

Example:
```bash
node functions/test_fcm_notification.js "your-token-here" "fridge-123" "Test Title" "Test Body"
```

#### Test Status Report (Triggers Cloud Function)

```bash
node functions/test_status_report.js <fridge-id> [condition] [food-percentage] [fridge-name]
```

Example:
```bash
node functions/test_status_report.js "fridge-123" "good" 0.0 "Test Fridge"
```

This creates a status report in Realtime Database, which automatically triggers the `onFridgeStatusUpdate` Cloud Function.

## Testing Scenarios

### Scenario 1: Subscription-Based Notifications

**Goal:** Test notifications when a subscribed fridge's status changes

**Steps:**
1. Sign in to the app
2. Subscribe to a fridge
3. Create a test status report for that fridge (using test screen or script)
4. Verify notification is received
5. Tap notification and verify it opens the fridge details

**Expected Result:**
- Notification appears with fridge name and status reason
- Tapping notification navigates to fridge details sheet
- Notification respects user preferences (empty, running low, etc.)

### Scenario 2: Geofencing Notifications

**Goal:** Test local notifications when near a fridge

**Steps:**
1. Sign in to the app
2. Enable geofencing in Profile > Notification Settings
3. Grant location permissions (Always Allow for background)
4. Subscribe to a nearby fridge
5. Walk within 400 meters of the fridge
6. Verify local notification appears

**Expected Result:**
- Local notification appears when entering geofence
- Notification shows fridge name and "needs attention" message
- Tapping notification navigates to fridge details
- Cooldown prevents spam (30 minutes between notifications for same fridge)

### Scenario 3: FCM Token Management

**Goal:** Verify FCM token is saved and refreshed correctly

**Steps:**
1. Sign in to the app
2. Subscribe to a fridge (this requests permissions and saves token)
3. Check Realtime Database: `/users/{userId}/fcmToken`
4. Verify token exists
5. Force app restart
6. Verify token is refreshed if needed

**Expected Result:**
- Token saved to database on first subscription
- Token persists across app restarts
- Token refresh handled automatically

### Scenario 4: Notification Preferences

**Goal:** Test that notifications respect user preferences

**Steps:**
1. Sign in and subscribe to a fridge
2. Open subscription dialog
3. Configure notification preferences (empty, running low, etc.)
4. Create status reports matching different conditions
5. Verify only matching preferences trigger notifications

**Expected Result:**
- Notifications only sent for enabled preferences
- Empty fridge triggers if "empty" preference enabled
- Running low triggers if "running low" preference enabled
- Etc.

### Scenario 5: Background Notifications

**Goal:** Test notifications when app is in background or killed

**Steps:**
1. Sign in and subscribe to a fridge
2. Put app in background (home button)
3. Create a test status report
4. Verify notification appears
5. Kill the app completely
6. Create another test status report
7. Verify notification appears

**Expected Result:**
- Notifications work in background
- Notifications work when app is killed
- Tapping notification opens app and navigates to fridge

## Troubleshooting

### Notifications Not Appearing

1. **Check FCM token:**
   - Go to Profile > Test Notifications
   - Verify token exists
   - If missing, subscribe to a fridge

2. **Check permissions:**
   - iOS: Settings > FridgeFinder > Notifications
   - Android: App Settings > Notifications

3. **Check Cloud Functions logs:**
   ```bash
   firebase functions:log
   ```

4. **Check Realtime Database:**
   - Verify status report was created: `/statusReports/{reportId}`
   - Verify user subscription: `/users/{userId}/subscribedFridges/{fridgeId}`
   - Verify FCM token: `/users/{userId}/fcmToken`

### Geofencing Not Working

1. **Check location permissions:**
   - Profile > Notification Settings > Geofencing toggle
   - Ensure "Always Allow" is granted

2. **Check geofencing enabled:**
   - Profile > Notification Settings
   - Verify geofencing toggle is ON

3. **Check distance:**
   - Must be within 400 meters of fridge
   - Use Test Geofencing Notification button to check distance

### Cloud Functions Not Triggering

1. **Check deployment:**
   ```bash
   firebase functions:list
   ```

2. **Check logs:**
   ```bash
   firebase functions:log --only onFridgeStatusUpdate
   ```

3. **Verify database path:**
   - Status reports must be created at `/statusReports/{reportId}`
   - Check Realtime Database rules allow writes

## Database Structure

### FCM Token Storage
```
/users/{userId}/fcmToken: "fcm-token-string"
```

### Subscriptions
```
/users/{userId}/subscribedFridges/{fridgeId}: {
  notificationPreferences: {
    empty: true,
    runningLow: true,
    updatedWithFood: false,
    needsCleaning: true,
    needsServicing: true,
    routineValidation: false
  },
  subscribedAt: "2024-01-01T00:00:00Z"
}
```

### Status Reports (Triggers Cloud Function)
```
/statusReports/{reportId}: {
  fridgeId: "fridge-123",
  fridgeName: "Community Fridge",
  condition: "good",
  foodPercentage: 0.0,
  reportDate: "2024-01-01T00:00:00Z",
  createdAt: "2024-01-01T00:00:00Z",
  notes: "Optional notes",
  photoUrl: "Optional photo URL"
}
```

## Cloud Functions

### onFridgeStatusUpdate
- **Trigger:** Realtime Database write to `/statusReports/{reportId}`
- **Action:** Sends notifications to subscribed users based on preferences
- **Logs:** `firebase functions:log --only onFridgeStatusUpdate`

### onUserSubscribe
- **Trigger:** Realtime Database write to `/users/{userId}/subscribedFridges/{fridgeId}`
- **Action:** Logs subscription (can be extended for welcome notifications)
- **Logs:** `firebase functions:log --only onUserSubscribe`

### checkRoutineValidation
- **Trigger:** Scheduled daily at 9 AM EST
- **Action:** Checks for fridges needing routine validation (>2 days since update)
- **Logs:** `firebase functions:log --only checkRoutineValidation`

## Additional Resources

- Firebase Console: https://console.firebase.google.com/project/fridgefinder-app
- Cloud Functions Logs: `firebase functions:log`
- Realtime Database: Firebase Console > Realtime Database
- FCM Documentation: https://firebase.google.com/docs/cloud-messaging


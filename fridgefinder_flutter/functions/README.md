# Firebase Cloud Functions Setup Guide

## Prerequisites

1. Install Node.js (v18 or higher)
2. Install Firebase CLI: `npm install -g firebase-tools`
3. Login to Firebase: `firebase login`

## Setup Steps

1. **Initialize Firebase Functions** (if not already done):
   ```bash
   cd functions
   npm install
   ```

2. **Deploy Functions**:
   ```bash
   firebase deploy --only functions
   ```

3. **Set up Realtime Database Rules**:
   - Go to Firebase Console → Realtime Database → Rules
   - Apply the security rules from `FIREBASE_SETUP_CHECKLIST.md`

## Functions Overview

### 1. `onFridgeStatusUpdate`
- **Trigger**: When a new status report is created in `statusReports/{reportId}`
- **Purpose**: Sends notifications to subscribed users based on their preferences
- **Checks**: Food level, condition, routine validation

### 2. `onUserSubscribe`
- **Trigger**: When a user subscribes to a fridge
- **Purpose**: Handles subscription setup (can be extended for welcome messages)

### 3. `checkRoutineValidation`
- **Trigger**: Daily at 9 AM (scheduled)
- **Purpose**: Checks for fridges needing routine validation (>2 days since update)

## Integration with Your API

The functions currently reference `statusReports` in Realtime Database. You'll need to:

1. **Option A**: Write status reports to Realtime Database when they're created via your API
2. **Option B**: Modify functions to call your API to get fridge status
3. **Option C**: Use Firestore instead of Realtime Database (modify functions accordingly)

## Testing

1. **Local Testing**:
   ```bash
   cd functions
   npm run serve
   ```

2. **Test with Firebase Emulator**:
   ```bash
   firebase emulators:start
   ```

## Notification Payload Structure

```json
{
  "title": "Fridge Name needs attention",
  "body": "Check the fridge status and help if you can!",
  "data": {
    "type": "fridge_update",
    "fridgeId": "fridge123",
    "reason": "needs cleaning"
  }
}
```

## Next Steps

1. Integrate with your fridge API to get real-time status
2. Add notification batching for daily/weekly frequencies
3. Implement geofencing triggers (when user enters geofence area)
4. Add notification analytics/tracking


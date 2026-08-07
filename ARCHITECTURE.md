# FridgeFinder Mobile App Architecture

## Overview

FridgeFinder uses a hybrid architecture combining Firebase services for mobile-specific features (geofencing) with AWS services for scalable business logic and data storage.

---

## Architecture Components

### 1. Authentication - Firebase Auth

**Service:** Firebase Authentication

**Purpose:** Handle user sign-in and identity management

**Implementation:**
- Phone authentication (primary method)
- Google Sign-In (secondary method)
- JWT token generation for API authentication
- Session management with automatic token refresh

**Why Firebase?**
- Native mobile SDK integration
- Handles phone verification SMS automatically
- Built-in security features (rate limiting, fraud detection)
- Zero maintenance required
- Excellent offline support

**Data Flow:**
```
Mobile App → Firebase Auth SDK → Firebase Auth Service
           ↓
    Get ID Token (JWT)
           ↓
    AWS API Gateway (validates Firebase JWT)
           ↓
    AWS Lambda (extracts userId from token)
```

**User Model Fields (from Firebase Auth):**
- `userId` (Firebase UID)
- `email`
- `phoneNumber`
- `createdAt`
- `lastLoginAt`

---

### 2. User Data - AWS DynamoDB

**Service:** AWS DynamoDB

**Purpose:** Store all business data (users, fridges, subscriptions, status reports)

**Tables:**

#### Users Table
```
Primary Key: userId (String)
Attributes:
- userId (String) - Firebase UID
- email (String)
- phoneNumber (String)
- username (String)
- isVolunteer (Boolean)
- zipCode (String)
- points (Number)
- fcmToken (String) - for push notifications
- createdAt (Timestamp)
- lastLoginAt (Timestamp)
```

#### Subscriptions Table
* LINK THE DOUCMENT WE WORKED ON


**Why DynamoDB?**
- Serverless with auto-scaling
- Single-digit millisecond latency
- Pay-per-request pricing (cost-effective at any scale)
- Global Secondary Indexes for efficient querying
- Strong consistency guarantees
- Atomic updates (no manual index management)

**Query Patterns:**
1. **Get user profile:** Query Users table by `userId` - O(1), 10-50ms
2. **Get user's subscriptions:** Query Subscriptions table by `userId` - O(m), 50-200ms
3. **Get fridge subscribers:** Query FridgeSubscribersIndex GSI by `fridgeId` - O(m), 50-200ms
4. **Get fridge reports:** Query FridgeReportsIndex GSI by `fridgeId` - O(m), 50-200ms

---

### 3. API Layer - AWS Lambda + API Gateway

**Services:** AWS Lambda, AWS API Gateway

**Purpose:** Handle all business logic and data operations

**Architecture:**
```
Mobile App → API Gateway (REST API)
           ↓
      JWT Validation (Firebase Auth)
           ↓
      AWS Lambda Functions
           ↓
      DynamoDB / Firebase Admin SDK
```

**Lambda Functions:**

#### User Management
- `createUser` - Create new user profile in DynamoDB
- `getUser` - Retrieve user profile
- `updateUser` - Update user profile
- `deleteUser` - Delete user account

#### Subscription Management
- `subscribeFridge` - Add fridge subscription
- `unsubscribeFridge` - Remove fridge subscription
- `getUserSubscriptions` - Get all fridges user is subscribed to
- `updateNotificationPreferences` - Update notification settings for a subscription


#### Notification Service
- `sendSubscriptionNotifications` - When a status report is created:
  1. Query DynamoDB FridgeSubscribersIndex GSI by `fridgeId`
  2. Filter users based on their notification preferences
  3. Send FCM push notifications via Firebase Admin SDK
  4. Check against daily notification limits in Firebase RTDB

**Why AWS Lambda?**
- Already using AWS Lambda + API Gateway (existing infrastructure)
- Scales automatically with demand
- Pay only for execution time
- Easy integration with DynamoDB
- Can use Firebase Admin SDK for FCM notifications
- Unified backend (web + mobile)

---

### 4. Geofencing - Firebase Realtime Database

**Service:** Firebase Realtime Database

**Purpose:** Store geofencing settings and daily notification limits with real-time sync

**Data Structure:**
```json
{
  "users": {
    "{userId}": {
      "settings": {
        "geofencingEnabled": true,
        "notificationsEnabled": true,
        "notificationFrequency": "immediate"
      },
      "geofencing": {
        "lastNotifications": {
          "{fridgeId}": {
            "updatedWithFood": "2025-12-01",
            "runningLow": "2025-12-01",
            "empty": null,
            "needsCleaning": "2025-11-30",
            "needsServicing": null,
            "routineValidation": "2025-11-29"
          }
        }
      }
    }
  }
}
```

**Fields:**
- `settings.geofencingEnabled` (Boolean) - Master toggle for location monitoring
- `settings.notificationsEnabled` (Boolean) - Master toggle for all notifications
- `settings.notificationFrequency` (String) - Future batching feature (not yet implemented)
- `geofencing.lastNotifications.{fridgeId}.{reportType}` (ISO Date String) - Last notification date for daily limit enforcement

**Geofencing Implementation:**

The geofencing service runs entirely on the mobile device using the Geolocator Flutter package.

**How It Works:**
```
1. User enables geofencing in app
   ↓
2. Mobile app starts GPS monitoring
   ↓
3. OS triggers location updates when user moves 50+ meters
   ↓
4. App calculates distance to all nearby fridges (cached locally)
   ↓
5. When user enters 400m radius of a fridge:
   a. Check Firebase RTDB for geofencingEnabled toggle
   b. Check daily notification limit (once per fridge per type per day)
   c. If allowed, send FCM notification via AWS Lambda
   d. Update lastNotifications date in Firebase RTDB
```

**Geofencing Parameters:**
- **Radius:** 400 meters (circular geofence around each fridge)
- **Distance Filter:** 50 meters (only trigger on 50+ meter movement)
- **Daily Limit:** Max 1 notification per fridge per notification type per day
- **Battery Impact:** 2-6% per day (mostly from GPS, minimal from app logic)

**Why Firebase RTDB for Geofencing?**
- Real-time sync (toggle geofencing on/off instantly)
- Offline support (app works without internet)
- Low latency reads (10-50ms)
- Simple key-value structure
- No need for complex queries
- Client-side SDK handles caching automatically
- Minimal data storage (only settings + dates)

---

### 5. Push Notifications - Firebase Cloud Messaging (FCM)

**Service:** Firebase Cloud Messaging

**Purpose:** Send push notifications to mobile devices

**Implementation:**

**Token Management:**
```
1. App generates FCM token on first launch
   ↓
2. Store token in DynamoDB Users table (fcmToken field)
   ↓
3. Token refresh handled automatically by FCM SDK
   ↓
4. Update DynamoDB when token changes
```

**Notification Flow:**
```
Event Trigger (Status Report Created / Geofence Entered)
           ↓
      AWS Lambda Function
           ↓
   Query DynamoDB for subscribers + fcmTokens
           ↓
   Firebase Admin SDK (in Lambda)
           ↓
   FCM Service
           ↓
   Mobile Device (via OS push notification service)
```

**Notification Types:**
1. **Status Report Notifications** (subscription-based):
   - Sent when a new status report is created
   - Only to users subscribed to that fridge
   - Filtered by notification preferences
   
2. **Geofence Notifications** (location-based):
   - Sent when user enters 400m radius of a fridge
   - Only if geofencingEnabled = true
   - Limited to once per day per fridge

**Why FCM?**
- Minimal battery impact (0.2-0.5% per day)
- Persistent connection shared across all apps
- OS-level optimization (doze mode, batching)
- Works on both iOS (APNs) and Android (FCM)
- Free up to unlimited messages
- Reliable delivery with retry logic

---

## Data Flow Examples

### Example 1: User Signs Up

```
1. User enters phone number in app
   ↓ Firebase Auth SDK
2. Firebase Auth sends verification SMS
   ↓
3. User enters code, Firebase Auth creates account
   ↓ Get Firebase UID + JWT token
4. App calls AWS API Gateway POST /users
   ↓ Validates JWT, extracts userId
5. AWS Lambda creates user record in DynamoDB
   ↓
6. Lambda creates geofencing settings in Firebase RTDB
   ↓
7. Response sent back to mobile app
```

### Example 2: User Subscribes to Fridge

```
1. User taps "Subscribe" button in app
   ↓ POST /subscriptions with JWT token
2. API Gateway validates Firebase JWT
   ↓
3. Lambda creates subscription in DynamoDB
   - userId (from JWT)
   - fridgeId (from request)
   - notificationPreferences (default all true)
   ↓
4. DynamoDB automatically updates FridgeSubscribersIndex GSI
   ↓
5. Response confirms subscription
```

### Example 3: Volunteer Creates Status Report

```
1. Volunteer submits status report
   ↓ POST /status-reports with JWT token
2. Lambda creates report in DynamoDB StatusReports table
   ↓
3. Lambda queries FridgeSubscribersIndex GSI by fridgeId
   ↓ Returns list of subscribed users (50-200ms)
4. Lambda filters users by notification preferences
   ↓ e.g., only users with "updatedWithFood": true
5. Lambda checks Firebase RTDB for daily notification limits
   ↓ Filter out users who already got this notification today
6. Lambda sends FCM notifications via Firebase Admin SDK
   ↓
7. Lambda updates Firebase RTDB lastNotifications dates
   ↓
8. Mobile devices receive push notifications
```

### Example 4: Geofencing Notification

```
1. User moves 50+ meters (OS triggers location update)
   ↓
2. App calculates distance to cached fridges
   ↓
3. User within 400m of Fridge X
   ↓
4. App reads Firebase RTDB geofencingEnabled setting
   ↓ If true, continue
5. App reads Firebase RTDB lastNotifications for Fridge X
   ↓ Check if notified today
6. If not notified today, call AWS Lambda POST /geofence-notification
   ↓
7. Lambda sends FCM notification
   ↓
8. App updates Firebase RTDB lastNotifications.{fridgeId} = today
   ↓
9. User receives "You're near a fridge!" notification
```

---

---




---

## Key Architectural Decisions

### Why Hybrid (Firebase + AWS)?

**Firebase Strengths:**
- ✅ Authentication (handles phone verification SMS)
- ✅ Real-time sync (perfect for geofencing toggles)
- ✅ Push notifications (minimal battery impact)
- ✅ Mobile SDK integration (offline support)

**AWS Strengths:**
- ✅ Scalable data storage (DynamoDB auto-scales)
- ✅ Complex queries (GSI for reverse lookups)
- ✅ Unified backend (already using Lambda + API Gateway)
- ✅ Cost-effective at scale (pay-per-request)
- ✅ Strong consistency (atomic updates)

**Result:**
Use Firebase for mobile-specific features that require real-time sync and minimal battery impact. Use AWS for business logic and data that needs complex querying and scalability.

---

## Conclusion

This architecture provides:
- ✅ Scalable data storage with DynamoDB
- ✅ Efficient geofencing with Firebase RTDB real-time sync
- ✅ Reliable authentication with Firebase Auth
- ✅ Low-battery push notifications with FCM
- ✅ Unified API layer with AWS Lambda
- ✅ Fast queries with DynamoDB GSI (O(1) lookups)
- ✅ Cost-effective scaling (pay-per-request)

The hybrid approach leverages the best of both platforms while avoiding their weaknesses.

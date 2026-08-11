# FridgeFinder Mobile App Architecture

## Overview

FridgeFinder is API-first.

- Mobile data flows (users, fridges, follows, alert preferences, reports) are owned by backend APIs.
- Firebase is used for mobile platform capabilities: authentication and push delivery (FCM).
- The mobile app does not use Firebase Realtime Database or Cloud Functions for runtime app data paths.

---

## Architecture Components

### 1. Authentication - Firebase Auth

**Service:** Firebase Authentication

**Purpose:** Handle user sign-in and identity management

**Implementation:**
- Phone authentication (primary method)
- Google Sign-In (secondary method)
- Firebase ID token (JWT) used to authorize backend API calls
- Session management with automatic token refresh

**Data Flow:**
```
Mobile App -> Firebase Auth SDK -> Firebase Auth Service
           -> Firebase ID Token (JWT)
           -> API Gateway / Backend API auth middleware
           -> Authorized backend request context (userId)
```

**Auth Identity Fields (from Firebase Auth):**
- `userId` (Firebase UID)
- `email`
- `phoneNumber`
- `createdAt`
- `lastLoginAt`

---

### 2. Backend API + Data Layer

**Services:** AWS API Gateway + AWS Lambda + AWS DynamoDB

**Purpose:** Source of truth for all business data and workflows

#### Users Table

Current app profile shape (as consumed by mobile):

```
Primary Key: userId (String)

Attributes:
- userId (String)
- email (String, nullable)
- phoneNumber (String, nullable)
- username (String)
- userType (String: organizer | host | neighbor | volunteer)
- zipcode (String, nullable)
- points (Number)
- settings (Map)
  - emailNotificationEnabled (Boolean)
  - geofencingEnabled (Boolean)
- createdAt (Timestamp)
- lastUpdated (Timestamp, nullable)
- lastLoginAt (Timestamp, nullable)
```

Notes:
- `fcmToken` is not treated as a single user-table source of truth anymore.
- Device tokens are managed by backend notification/device-token flows.

#### Follows + Alert Preferences

Follows are modeled through fridge-notification resources.

Mobile uses endpoints such as:
- `GET /v1/users/{userId}/fridge-notifications`
- `GET /v1/users/{userId}/fridge-notifications/{fridgeId}`
- `POST /v1/users/{userId}/fridge-notifications/{fridgeId}` (follow)
- `PATCH /v1/users/{userId}/fridge-notifications/{fridgeId}` (edit alert preferences)
- `DELETE /v1/users/{userId}/fridge-notifications/{fridgeId}` (unfollow)

---

### 3. Notification and Follow Domain

**Purpose:** Notify users based on fridge changes and follow preferences

**Backend responsibilities:**
- Resolve follower set for a fridge
- Apply per-fridge alert preference filters
- Enforce notification policy/rate limits
- Dispatch push notifications through FCM

**Mobile responsibilities:**
- Manage follow/unfollow actions
- Manage per-fridge alert preferences
- Register refresh/delete local device FCM token via backend-owned workflows
- Display and route notification taps

---

### 4. Geofencing - On Device + API Policy

**Mobile runtime:**
- Geofencing/proximity checks run on-device with Geolocator
- App evaluates nearby fridges based on user location updates

**Backend role:**
- Owns policy checks (for example daily limits and user settings)
- Owns notification dispatch and persistence of notification history metadata

**Current direction:**
- Geofencing remains volunteer-scoped in UX
- Follow and alert routing remains API-backed

---

### 5. Push Notifications - Firebase Cloud Messaging (FCM)

**Service:** Firebase Cloud Messaging

**Purpose:** Deliver push notifications to user devices

**Token Lifecycle:**
1. App obtains an FCM token from Firebase Messaging SDK
2. App sends token updates through backend-owned token registration workflows
3. Backend associates tokens to user/device records
4. Backend sends notifications through Firebase Admin SDK

**Notification Types:**
1. **Fridge update alerts** (follow-based)
2. **Geofence/proximity alerts** (location-based policy)

---

## Data Flow Examples

### Example 1: User Signs Up

```
1. User signs in with phone or Google
2. Firebase Auth issues ID token
3. App calls backend Users API (/users)
4. Backend creates/updates user profile record
5. App continues with API-backed profile + follow state
```

### Example 2: User Follows a Fridge

```
1. User taps Follow in app
2. App calls POST /v1/users/{userId}/fridge-notifications/{fridgeId}
3. Backend stores follow + alert preference defaults
4. Future fridge events use these preferences for notification targeting
```

### Example 3: User Edits Alert Preferences

```
1. User opens edit alerts for a followed fridge
2. App calls PATCH /v1/users/{userId}/fridge-notifications/{fridgeId}
3. Backend persists updated contact-type preferences
4. Next notification fan-out reflects the new settings
```

### Example 4: Volunteer Geofencing Alert

```
1. Device receives location update
2. App detects nearby fridge candidates
3. App/backend policy flow determines whether alert is allowed
4. Backend sends FCM push if allowed
5. App receives and displays notification
```

---

## Key Architectural Decisions

### Why API-First with Firebase for Mobile Platform Features?

**API-first backend strengths:**
- Unified source of truth for business state
- Consistent behavior across mobile/web/backend systems
- Centralized policy and alert routing
- Easier contract governance and observability

**Firebase strengths retained:**
- Reliable auth UX on mobile (phone + social sign-in)
- Cross-platform push transport (FCM)
- Mature mobile SDK support

**Result:**
Business data and follow/alert state are API-owned. Firebase is used for auth identity and push transport, not runtime business-data storage.

---

## Conclusion

This architecture provides:
- API-owned business logic and data contracts
- Firebase-authenticated user identity
- Reliable push delivery through FCM
- On-device geofencing with backend policy control
- Clear separation between mobile platform services and business-data ownership

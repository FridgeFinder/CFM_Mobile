/**
 * Firebase Cloud Functions for FridgeFinder Push Notifications
 *
 * This file contains all Cloud Functions needed to send push notifications
 * to users based on their subscription preferences and fridge status changes.
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.database();

/**
 * Server-side caching for improved performance
 */
const statsCache = new Map();
const STATS_CACHE_TTL = 2 * 60 * 1000; // 2 minutes

/**
 * Invalidate stats cache (called when data changes)
 */
async function invalidateStatsCache() {
  statsCache.clear();
  // Update cache version in Firebase for client awareness
  await db.ref('cacheVersions/stats').set(Date.now());
  console.log('Stats cache invalidated');
}

/**
 * Send notification to a user's FCM token
 */
async function sendNotificationToUser(userId, notification) {
  try {
    // Get user profile to retrieve FCM token
    const userRef = db.ref(`users/${userId}`);
    const userSnapshot = await userRef.once('value');
    const userData = userSnapshot.val();

    if (!userData || !userData.fcmToken) {
      console.log(`No FCM token found for user ${userId}`);
      return;
    }

    // Check if notifications are enabled
    if (userData.settings && userData.settings.notificationsEnabled === false) {
      console.log(`Notifications disabled for user ${userId}`);
      return;
    }

    // Send notification
    // Convert all data values to strings (FCM requirement for iOS)
    const dataPayload = {};
    if (notification.data && Object.keys(notification.data).length > 0) {
      for (const [key, value] of Object.entries(notification.data)) {
        dataPayload[key] = String(value || '');
      }
    }

    const message = {
      token: userData.fcmToken,
      notification: {
        title: notification.title,
        body: notification.body,
      },
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          channelId: 'fridgefinder_notifications',
        },
      },
      apns: {
        headers: {
          'apns-priority': '10',
        },
        payload: {
          aps: {
            alert: {
              title: notification.title,
              body: notification.body,
            },
            sound: 'default',
            badge: 1,
          },
        },
      },
    };

    // Only add data field if it has content
    if (Object.keys(dataPayload).length > 0) {
      message.data = dataPayload;
    }

    const response = await admin.messaging().send(message);
    console.log(`Successfully sent notification to ${userId}:`, response);
    return response;
  } catch (error) {
    console.error(`Error sending notification to ${userId}:`, error);
    // If token is invalid, remove it
    if (error.code === 'messaging/invalid-registration-token' ||
        error.code === 'messaging/registration-token-not-registered') {
      await db.ref(`users/${userId}/fcmToken`).remove();
    }
    throw error;
  }
}

/**
 * Notification Rules Configuration
 * Maps fridge conditions and food levels to notification types with custom messages
 * Rules are evaluated in priority order (lower number = higher priority)
 */
const NOTIFICATION_RULES = [
  // Priority 1: Critical conditions (highest priority)
  {
    id: 'out_of_order',
    preferenceKey: 'needsServicing',
    condition: (report, prefs) => report.condition === 'out of order' && prefs.needsServicing,
    title: (fridgeName) => `${fridgeName} needs servicing`,
    body: (fridgeName) => 'This fridge is out of order and needs immediate attention!',
    priority: 1,
    urgent: true, // Always send immediately regardless of frequency setting
  },

  // Priority 2: Maintenance needs
  {
    id: 'dirty',
    preferenceKey: 'needsCleaning',
    condition: (report, prefs) => report.condition === 'dirty' && prefs.needsCleaning,
    title: (fridgeName) => `${fridgeName} needs cleaning`,
    body: (fridgeName) => 'This fridge needs some TLC - help keep it clean for the community!',
    priority: 2,
  },

  // Priority 3: Empty fridge
  {
    id: 'empty',
    preferenceKey: 'empty',
    condition: (report, prefs) => report.foodPercentage === 0 && prefs.empty,
    title: (fridgeName) => `${fridgeName} is now empty`,
    body: (fridgeName) => 'This fridge is completely empty. Can you help stock it?',
    priority: 3,
  },

  // Priority 4: Running low on food
  {
    id: 'running_low',
    preferenceKey: 'runningLow',
    condition: (report, prefs) => {
      // Running low means 33% or less (but not empty, which is handled above)
      return report.foodPercentage !== undefined &&
             report.foodPercentage > 0 &&
             report.foodPercentage <= 0.33 &&
             prefs.runningLow;
    },
    title: (fridgeName) => `${fridgeName} is running low on food`,
    body: (fridgeName) => 'Food supplies are getting low - consider stocking if you can!',
    priority: 4,
  },

  // Priority 5: Positive updates - restocked
  {
    id: 'updated_with_food',
    preferenceKey: 'updatedWithFood',
    condition: (report, prefs) => report.foodPercentage >= 0.66 && prefs.updatedWithFood,
    title: (fridgeName) => `${fridgeName} has been restocked`,
    body: (fridgeName) => 'Fresh food is available - check it out!',
    priority: 5,
  },

  // Priority 6: Routine validation (lowest priority)
  {
    id: 'routine_validation',
    preferenceKey: 'routineValidation',
    condition: (report, prefs) => {
      if (!prefs.routineValidation || !report.reportDate) return false;
      const reportDate = new Date(report.reportDate);
      const daysSinceUpdate = (Date.now() - reportDate.getTime()) / (1000 * 60 * 60 * 24);
      return daysSinceUpdate > 2;
    },
    title: (fridgeName) => `${fridgeName} needs a status update`,
    body: (fridgeName, report) => {
      const reportDate = new Date(report.reportDate);
      const days = Math.floor((Date.now() - reportDate.getTime()) / (1000 * 60 * 60 * 24));
      return `It's been ${days} days since the last update. Quick photo?`;
    },
    priority: 6,
  },
];

/**
 * Evaluate notification rules for a status report
 * Returns the highest priority matching notification, or null if none match
 *
 * @param {Object} reportData - The status report data
 * @param {Object} userPreferences - User's notification preferences
 * @returns {Object|null} Notification object with title, body, and metadata, or null
 */
function evaluateNotifications(reportData, userPreferences) {
  // Find all rules that match the current report and user preferences
  const matchingRules = NOTIFICATION_RULES
    .filter((rule) => rule.condition(reportData, userPreferences))
    .sort((a, b) => a.priority - b.priority); // Sort by priority (lower = higher priority)

  if (matchingRules.length === 0) {
    return null;
  }

  // Return the highest priority match (first in sorted array)
  const rule = matchingRules[0];
  const fridgeName = reportData.fridgeName || 'A community fridge';

  return {
    id: rule.id,
    title: rule.title(fridgeName, reportData),
    body: rule.body(fridgeName, reportData),
    urgent: rule.urgent || false,
    data: {
      type: 'fridge_update',
      fridgeId: reportData.fridgeId,
      notificationId: rule.id,
    },
  };
}

/**
 * Triggered when a fridge status report is created/updated
 * Sends notifications to subscribed users based on their preferences
 */
exports.onFridgeStatusUpdate = functions.database
  .ref('statusReports/{reportId}')
  .onCreate(async (snapshot, context) => {
    const reportData = snapshot.val();
    const fridgeId = reportData.fridgeId;

    if (!fridgeId) {
      console.log('No fridgeId in report');
      return null;
    }

    // Get all users subscribed to this fridge
    const usersRef = db.ref('users');
    const usersSnapshot = await usersRef.once('value');
    const users = usersSnapshot.val();

    if (!users) {
      return null;
    }

    const notifications = [];

    for (const [userId, userData] of Object.entries(users)) {
      if (!userData.subscribedFridges || !userData.subscribedFridges[fridgeId]) {
        continue;
      }

      const subscription = userData.subscribedFridges[fridgeId];
      const prefs = subscription.notificationPreferences || {};

      // Evaluate notification rules using the mapping configuration
      const notification = evaluateNotifications(reportData, prefs);

      if (notification) {
        notifications.push(
          sendNotificationToUser(userId, notification),
        );
      }
    }

    // Send all notifications in parallel
    await Promise.allSettled(notifications);

    // Write to activity feed
    try {
      const timestamp = Date.now();
      const reportId = context.params.reportId;

      await db.ref(`activityFeed/${timestamp}_report_${reportId}`).set({
        type: 'report',
        timestamp: timestamp,
        reportId: reportId,
        fridgeId: reportData.fridgeId,
        fridgeName: reportData.fridgeName || fridgeId,
        condition: reportData.condition,
        foodPercentage: reportData.foodPercentage || 0,
        photoUrl: reportData.photoUrl || null,
        reportDate: reportData.reportDate || new Date().toISOString(),
      });

      console.log(`Activity feed: Status report created - ${reportId}`);

      // Invalidate stats cache since data changed
      await invalidateStatsCache();
    } catch (error) {
      console.error('Error writing report to activity feed:', error);
      // Don't throw - we don't want to block report creation
    }

    return null;
  });

/**
 * Triggered when a user subscribes to a fridge
 * Requests notification permission and sets up initial preferences
 */
exports.onUserSubscribe = functions.database
  .ref('users/{userId}/subscribedFridges/{fridgeId}')
  .onCreate(async (snapshot, context) => {
    const {userId, fridgeId} = context.params;

    console.log(`User ${userId} subscribed to fridge ${fridgeId}`);

    // You can add logic here to:
    // 1. Send welcome notification
    // 2. Request notification permissions (handled client-side)
    // 3. Set up geofencing if enabled

    return null;
  });

/**
 * Scheduled function to check for fridges needing routine validation
 * Runs daily at 9 AM
 */
exports.checkRoutineValidation = functions.pubsub
  .schedule('0 9 * * *') // 9 AM daily
  .timeZone('America/New_York')
  .onRun(async (context) => {
    const usersRef = db.ref('users');
    const usersSnapshot = await usersRef.once('value');
    const users = usersSnapshot.val();

    if (!users) {
      return null;
    }

    const notifications = [];
    const now = Date.now();
    const twoDaysAgo = now - (2 * 24 * 60 * 60 * 1000);

    for (const [userId, userData] of Object.entries(users)) {
      if (!userData.subscribedFridges) {
        continue;
      }

      for (const [fridgeId, subscription] of Object.entries(userData.subscribedFridges)) {
        const prefs = subscription.notificationPreferences || {};

        if (!prefs.routineValidation) {
          continue;
        }

        // Check last report date (you'll need to fetch this from your API)
        // For now, this is a placeholder - you'll need to integrate with your fridge API
        const lastReportDate = subscription.lastReportDate;

        if (lastReportDate &&
          new Date(lastReportDate).getTime() < twoDaysAgo) {
          const reportTime = new Date(lastReportDate).getTime();
          const daysSinceUpdate =
            Math.floor((now - reportTime) / (1000 * 60 * 60 * 24));

          notifications.push(
            sendNotificationToUser(userId, {
              title: 'Routine Validation Needed',
              body: `Subscribed fridge needs update (${daysSinceUpdate}d)`,
              data: {
                type: 'routine_validation',
                fridgeId: fridgeId,
                daysSinceUpdate: daysSinceUpdate.toString(),
              },
            }),
          );
        }
      }
    }

    await Promise.allSettled(notifications);
    return null;
  });

/**
 * HTTP Callable Function: Send geofencing notification
 * Called by the app when a user enters a geofence near a fridge that needs attention
 *
 * Expected request data:
 * {
 *   fridgeId: string,
 *   fridgeName: string,
 *   notificationType: 'cleaning' | 'stocking' | 'routine',
 *   notificationMessage: string,
 *   distanceFeet: number
 * }
 */
exports.sendGeofencingNotification = functions.https.onCall(async (data, context) => {
  // Verify the user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to send geofencing notifications',
    );
  }

  const userId = context.auth.uid;
  const {fridgeId, fridgeName, notificationType, notificationMessage, distanceFeet} = data;

  // Validate required fields
  if (!fridgeId || !fridgeName || !notificationType || !notificationMessage) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required fields: fridgeId, fridgeName, notificationType, notificationMessage',
    );
  }

  try {
    // Get user profile to check settings
    const userRef = db.ref(`users/${userId}`);
    const userSnapshot = await userRef.once('value');
    const userData = userSnapshot.val();

    if (!userData) {
      throw new functions.https.HttpsError('not-found', 'User profile not found');
    }

    // Check if user has geofencing enabled
    if (!userData.settings || !userData.settings.geofencingEnabled) {
      console.log(`Geofencing disabled for user ${userId}`);
      return {success: false, reason: 'geofencing_disabled'};
    }

    // Check if user has notifications enabled
    if (userData.settings.notificationsEnabled === false) {
      console.log(`Notifications disabled for user ${userId}`);
      return {success: false, reason: 'notifications_disabled'};
    }

    // Check if we've already sent this notification today (once-per-day limit)
    const notificationKey = `${fridgeId}_${notificationType}`;
    const lastNotifications = userData.geofencing?.lastNotifications || {};
    const lastNotificationDate = lastNotifications[notificationKey];

    if (lastNotificationDate) {
      const lastDate = new Date(lastNotificationDate);
      const now = new Date();

      // Check if same day (year, month, day)
      const isSameDay =
        lastDate.getFullYear() === now.getFullYear() &&
        lastDate.getMonth() === now.getMonth() &&
        lastDate.getDate() === now.getDate();

      if (isSameDay) {
        console.log(
          `Already notified user ${userId} about fridge ${fridgeId} (${notificationType}) today`,
        );
        return {success: false, reason: 'already_notified_today'};
      }
    }

    // Send the notification via FCM
    await sendNotificationToUser(userId, {
      title: `${fridgeName} needs help!`,
      body: notificationMessage,
      data: {
        type: 'geofence',
        fridgeId: fridgeId,
        needType: notificationType,
        distanceFeet: distanceFeet ? distanceFeet.toString() : '0',
      },
    });

    // Record notification date in database
    await userRef.child(`geofencing/lastNotifications/${notificationKey}`).set(
      new Date().toISOString(),
    );

    console.log(
      `Geofencing notification sent to ${userId} for fridge ${fridgeId} (${notificationType}, ${distanceFeet}ft away)`,
    );

    return {
      success: true,
      message: 'Geofencing notification sent successfully',
    };
  } catch (error) {
    console.error('Error sending geofencing notification:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// Helper function to batch notifications based on user preferences
// For users with daily/weekly frequency, batches notifications
// Currently unused - reserved for future batching implementation
// async function batchNotificationsForUser(userId, notification) {
//   const userRef = db.ref(`users/${userId}`);
//   const userSnapshot = await userRef.once('value');
//   const userData = userSnapshot.val();
//
//   const frequency = userData?.settings?.notificationFrequency || 'immediate';
//
//   if (frequency === 'immediate') {
//     return sendNotificationToUser(userId, notification);
//   }
//
//   // For daily/weekly, you'd add to a queue and process in batches
//   console.log(`Batching for user ${userId} with ${frequency}`);
//   return null;
// }

/**
 * ============================================================================
 * DASHBOARD STATISTICS FUNCTIONS
 * For web dashboard analytics and reporting
 * ============================================================================
 */

/**
 * HTTP Callable Function: Verify dashboard password
 * Simple password verification for dashboard access
 *
 * Expected request data:
 * {
 *   passwordHash: string (SHA-256 hash of password)
 * }
 */
exports.verifyDashboardPassword = functions.https.onCall(async (data, context) => {
  const {passwordHash} = data;

  if (!passwordHash) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required field: passwordHash',
    );
  }

  // Get dashboard password from environment config
  // Set this with: firebase functions:config:set dashboard.password="your_password_here"
  const config = functions.config();
  const correctPassword = config.dashboard?.password || 'changeme123';

  // In production, store the hash of the password in config, not plaintext
  // For now, we compare the provided hash with a hash of the stored password
  const crypto = require('crypto');
  const correctHash = crypto
    .createHash('sha256')
    .update(correctPassword)
    .digest('hex');

  if (passwordHash === correctHash) {
    // Generate session token
    const sessionToken = crypto.randomBytes(32).toString('hex');
    const expiresAt = Date.now() + (60 * 60 * 1000); // 1 hour

    // Store session in database
    await db.ref(`dashboardSessions/${sessionToken}`).set({
      createdAt: Date.now(),
      expiresAt: expiresAt,
    });

    return {
      success: true,
      sessionToken: sessionToken,
      expiresAt: expiresAt,
    };
  } else {
    // Add small delay to prevent brute force
    await new Promise((resolve) => setTimeout(resolve, 1000));
    throw new functions.https.HttpsError(
      'permission-denied',
      'Invalid password',
    );
  }
});

/**
 * HTTP Callable Function: Get aggregated statistics
 * Returns pre-aggregated statistics for the dashboard
 *
 * Expected request data:
 * {
 *   sessionToken: string,
 *   timeFilter: '24h' | '7d' | 'all' (optional, defaults to 'all')
 * }
 */
exports.getAggregatedStats = functions.https.onCall(async (data, context) => {
  const {sessionToken, timeFilter = 'all', forceRefresh = false} = data;

  // Verify session token
  if (!sessionToken) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Session token required',
    );
  }

  const sessionRef = db.ref(`dashboardSessions/${sessionToken}`);
  const sessionSnapshot = await sessionRef.once('value');
  const sessionData = sessionSnapshot.val();

  if (!sessionData || sessionData.expiresAt < Date.now()) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Invalid or expired session',
    );
  }

  // Check server-side cache (unless force refresh)
  const cacheKey = `stats_${timeFilter}`;
  if (!forceRefresh && statsCache.has(cacheKey)) {
    const cached = statsCache.get(cacheKey);
    if (Date.now() - cached.timestamp < STATS_CACHE_TTL) {
      console.log(`Returning cached stats for ${timeFilter}`);
      return {
        ...cached.data,
        cached: true,
        cacheAge: Date.now() - cached.timestamp,
      };
    }
  }

  // Calculate time threshold based on filter
  let timeThreshold = 0;
  if (timeFilter === '24h') {
    timeThreshold = Date.now() - (24 * 60 * 60 * 1000);
  } else if (timeFilter === '7d') {
    timeThreshold = Date.now() - (7 * 24 * 60 * 60 * 1000);
  }

  // Get all users
  const usersSnapshot = await db.ref('users').once('value');
  const users = usersSnapshot.val() || {};

  // Get all status reports
  const reportsSnapshot = await db.ref('statusReports').once('value');
  const reports = reportsSnapshot.val() || {};

  // Aggregate user statistics
  const userStats = {
    total: 0,
    regular: 0,
    volunteer: 0,
    zipCodes: {},
    geofencingEnabled: 0,
  };

  for (const userData of Object.values(users)) {
    // Apply time filter if needed
    if (timeFilter !== 'all' && userData.createdAt) {
      const createdDate = new Date(userData.createdAt).getTime();
      if (createdDate < timeThreshold) continue;
    }

    userStats.total++;

    if (userData.isVolunteer) {
      userStats.volunteer++;
      if (userData.zipCode) {
        userStats.zipCodes[userData.zipCode] =
          (userStats.zipCodes[userData.zipCode] || 0) + 1;
      }
    } else {
      userStats.regular++;
    }

    if (userData.settings?.geofencingEnabled) {
      userStats.geofencingEnabled++;
    }
  }

  // Aggregate subscription statistics
  const subscriptionStats = {
    total: 0,
    byFridge: {},
  };

  for (const userData of Object.values(users)) {
    if (userData.subscribedFridges) {
      for (const [fridgeId, subscription] of Object.entries(
        userData.subscribedFridges,
      )) {
        // Apply time filter if needed
        if (timeFilter !== 'all' && subscription.subscribedAt) {
          const subDate = new Date(subscription.subscribedAt).getTime();
          if (subDate < timeThreshold) continue;
        }

        subscriptionStats.total++;
        subscriptionStats.byFridge[fridgeId] =
          (subscriptionStats.byFridge[fridgeId] || 0) + 1;
      }
    }
  }

  // Aggregate status report statistics
  const reportStats = {
    total: 0,
    byCondition: {
      'good': 0,
      'dirty': 0,
      'out of order': 0,
      'not at location': 0,
    },
    byFoodLevel: {
      empty: 0,
      low: 0,
      medium: 0,
      full: 0,
    },
    byFridge: {},
  };

  for (const reportData of Object.values(reports)) {
    // Apply time filter if needed
    if (timeFilter !== 'all' && reportData.reportDate) {
      const reportDate = new Date(reportData.reportDate).getTime();
      if (reportDate < timeThreshold) continue;
    }

    reportStats.total++;

    // Count by condition
    if (reportData.condition) {
      reportStats.byCondition[reportData.condition] =
        (reportStats.byCondition[reportData.condition] || 0) + 1;
    }

    // Count by food level
    if (reportData.foodPercentage !== undefined) {
      if (reportData.foodPercentage === 0) {
        reportStats.byFoodLevel.empty++;
      } else if (reportData.foodPercentage <= 0.33) {
        reportStats.byFoodLevel.low++;
      } else if (reportData.foodPercentage <= 0.66) {
        reportStats.byFoodLevel.medium++;
      } else {
        reportStats.byFoodLevel.full++;
      }
    }

    // Count by fridge
    if (reportData.fridgeId) {
      reportStats.byFridge[reportData.fridgeId] =
        (reportStats.byFridge[reportData.fridgeId] || 0) + 1;
    }
  }

  // Build result object
  const result = {
    userStats: userStats,
    subscriptionStats: subscriptionStats,
    reportStats: reportStats,
    timestamp: Date.now(),
  };

  // Cache result in memory for subsequent requests
  statsCache.set(cacheKey, {
    data: result,
    timestamp: Date.now(),
  });

  console.log(`Stats computed and cached for ${timeFilter}`);

  return result;
});

/**
 * HTTP Callable Function: Geocode volunteer zip codes
 * Uses OpenStreetMap Nominatim API to geocode zip codes
 *
 * Expected request data:
 * {
 *   sessionToken: string,
 *   zipCodes: string[] (array of zip codes to geocode)
 * }
 */
exports.geocodeVolunteerZipCodes = functions.https.onCall(
  async (data, context) => {
    const {sessionToken, zipCodes} = data;

    // Verify session token
    if (!sessionToken) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Session token required',
      );
    }

    const sessionRef = db.ref(`dashboardSessions/${sessionToken}`);
    const sessionSnapshot = await sessionRef.once('value');
    const sessionData = sessionSnapshot.val();

    if (!sessionData || sessionData.expiresAt < Date.now()) {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Invalid or expired session',
      );
    }

    if (!zipCodes || !Array.isArray(zipCodes)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'zipCodes must be an array',
      );
    }

    const axios = require('axios');
    const results = {};

    // Check if zip codes are already cached
    const cachedRef = db.ref('statistics/geocodedZips');
    const cachedSnapshot = await cachedRef.once('value');
    const cached = cachedSnapshot.val() || {};

    for (const zipCode of zipCodes) {
      // Check cache first
      if (cached[zipCode]) {
        results[zipCode] = cached[zipCode];
        continue;
      }

      try {
        // Rate limit: 1 request per second (Nominatim policy)
        await new Promise((resolve) => setTimeout(resolve, 1000));

        const response = await axios.get(
          'https://nominatim.openstreetmap.org/search',
          {
            params: {
              postalcode: zipCode,
              country: 'US',
              format: 'json',
              limit: 1,
            },
            headers: {
              'User-Agent': 'FridgeFinder-Dashboard/1.0',
            },
          },
        );

        if (response.data && response.data.length > 0) {
          const location = response.data[0];
          const geocoded = {
            zipCode: zipCode,
            city: location.display_name.split(',')[0],
            state: location.display_name.split(',')[1]?.trim() || '',
            lat: parseFloat(location.lat),
            lng: parseFloat(location.lon),
            lastUpdated: Date.now(),
          };

          results[zipCode] = geocoded;

          // Cache the result
          await cachedRef.child(zipCode).set(geocoded);
        } else {
          results[zipCode] = {
            zipCode: zipCode,
            error: 'Not found',
          };
        }
      } catch (error) {
        console.error(`Error geocoding ${zipCode}:`, error.message);
        results[zipCode] = {
          zipCode: zipCode,
          error: error.message,
        };
      }
    }

    return {
      success: true,
      results: results,
    };
  },
);

/**
 * HTTP Callable Function: Get app download statistics
 * Fetches download stats from App Store Connect and Google Play Console APIs
 *
 * Expected request data:
 * {
 *   sessionToken: string
 * }
 */
exports.getAppDownloads = functions.https.onCall(async (data, context) => {
  const {sessionToken} = data;

  // Verify session token
  if (!sessionToken) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Session token required',
    );
  }

  const sessionRef = db.ref(`dashboardSessions/${sessionToken}`);
  const sessionSnapshot = await sessionRef.once('value');
  const sessionData = sessionSnapshot.val();

  if (!sessionData || sessionData.expiresAt < Date.now()) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Invalid or expired session',
    );
  }

  const config = functions.config();
  const axios = require('axios');
  const jwt = require('jsonwebtoken');

  const results = {
    ios: 0,
    android: 0,
    lastUpdated: Date.now(),
    iosError: null,
    androidError: null,
  };

  const bundleId = 'com.fridgefinder.fridgefinderFlutterApp';
  const packageName = 'com.fridgefinder.fridgefinderapp';

  // Fetch iOS downloads from App Store Connect API
  try {
    const appStoreConfig = config.appstore;
    if (appStoreConfig && appStoreConfig.key_id && appStoreConfig.issuer_id &&
        appStoreConfig.private_key) {
      // Generate JWT token for App Store Connect API
      const token = jwt.sign(
        {
          iss: appStoreConfig.issuer_id,
          exp: Math.floor(Date.now() / 1000) + (20 * 60), // 20 minutes
          aud: 'appstoreconnect-v1',
        },
        appStoreConfig.private_key.replace(/\\n/g, '\n'),
        {
          algorithm: 'ES256',
          header: {
            kid: appStoreConfig.key_id,
            typ: 'JWT',
          },
        },
      );

      // Step 1: Find the app by bundle ID
      const appsResponse = await axios.get(
        'https://api.appstoreconnect.apple.com/v1/apps',
        {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json',
          },
          params: {
            'filter[bundleId]': bundleId,
            'limit': 1,
          },
        },
      );

      if (appsResponse.data.data && appsResponse.data.data.length > 0) {
        const appId = appsResponse.data.data[0].id;
        console.log(`Found iOS app: ${appId}`);

        // Step 2: Get app analytics (units sold/downloads)
        // Note: App Store Connect API doesn't provide direct download counts
        // The Analytics Reports API requires asynchronous report generation
        // For now, we'll use App Analytics web scraping or manual entry

        // Alternative: Use Sales Reports API (requires separate setup)
        // For this implementation, we'll log success and recommend manual entry
        console.log('App Store Connect API authenticated successfully');
        console.log('To get download numbers, use App Store Connect web portal');
        console.log('or implement Sales Reports API integration');

        results.iosError = 'API authenticated. Manual entry required for download counts.';
      } else {
        console.log(`App with bundle ID ${bundleId} not found`);
        results.iosError = 'App not found in App Store Connect';
      }
    } else {
      console.log('App Store Connect API not configured');
      results.iosError = 'API not configured';
    }
  } catch (error) {
    console.error('Error fetching iOS downloads:', error.message);
    if (error.response) {
      console.error('Response status:', error.response.status);
      console.error('Response data:', JSON.stringify(error.response.data));
    }
    results.iosError = error.message;
  }

  // Fetch Android downloads from Google Play Console API
  try {
    const playStoreConfig = config.playstore;
    if (playStoreConfig && playStoreConfig.service_account) {
      // Parse service account credentials (if it's a string) or use as-is (if already an object)
      const credentials = typeof playStoreConfig.service_account === 'string' ?
        JSON.parse(playStoreConfig.service_account) :
        playStoreConfig.service_account;

      // Generate JWT for Google APIs
      const googleToken = jwt.sign(
        {
          iss: credentials.client_email,
          scope: 'https://www.googleapis.com/auth/androidpublisher',
          aud: 'https://oauth2.googleapis.com/token',
          exp: Math.floor(Date.now() / 1000) + (60 * 60), // 1 hour
          iat: Math.floor(Date.now() / 1000),
        },
        credentials.private_key,
        {algorithm: 'RS256'},
      );

      // Exchange JWT for access token
      const tokenResponse = await axios.post(
        'https://oauth2.googleapis.com/token',
        {
          grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
          assertion: googleToken,
        },
      );

      const accessToken = tokenResponse.data.access_token;

      // Get app details to verify access
      const appResponse = await axios.get(
        `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${packageName}`,
        {
          headers: {
            'Authorization': `Bearer ${accessToken}`,
          },
        },
      );

      console.log('Google Play Console API authenticated successfully');
      console.log(`Found Android app: ${appResponse.data.packageName}`);

      // Note: Google Play Developer API doesn't provide total download counts
      // It provides:
      // - Reviews and ratings
      // - In-app purchases
      // - Subscriptions
      // For download stats, use Google Play Console web interface
      // or Play Console Reports API (requires Google Cloud Storage setup)

      results.androidError = 'API authenticated. Download stats require Play Console Reports setup.';
    } else {
      console.log('Google Play Console API not configured');
      results.androidError = 'API not configured';
    }
  } catch (error) {
    console.error('Error fetching Android downloads:', error.message);
    if (error.response) {
      console.error('Response status:', error.response.status);
      console.error('Response data:', JSON.stringify(error.response.data));
    }
    results.androidError = error.message;
  }

  // Check if we have manually entered download stats
  const downloadsRef = db.ref('statistics/downloads');
  const latestSnapshot = await downloadsRef
    .orderByKey()
    .limitToLast(1)
    .once('value');

  if (latestSnapshot.exists()) {
    const latest = Object.values(latestSnapshot.val())[0];
    results.ios = latest.ios || 0;
    results.android = latest.android || 0;
    results.lastUpdated = latest.timestamp || Date.now();
  }

  return results;
});

/**
 * Scheduled Function: Update app download statistics daily
 * Runs daily at 6 AM EST to fetch latest download numbers
 */
exports.updateAppDownloads = functions.pubsub
  .schedule('0 6 * * *')
  .timeZone('America/New_York')
  .onRun(async (context) => {
    console.log('Running scheduled download stats update');

    // For now, this logs a reminder to manually update stats
    // In the future, this could integrate with Sales Reports API
    console.log('Reminder: Update download statistics manually in Firebase Console');
    console.log('Path: Realtime Database > statistics > downloads');

    return null;
  });

/**
 * HTTP Callable Function: Manually update download statistics
 * Allows authorized users to manually enter download numbers
 *
 * Expected request data:
 * {
 *   sessionToken: string,
 *   ios: number,
 *   android: number
 * }
 */
exports.updateDownloadStats = functions.https.onCall(async (data, context) => {
  const {sessionToken, ios, android} = data;

  // Verify session token
  if (!sessionToken) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Session token required',
    );
  }

  const sessionRef = db.ref(`dashboardSessions/${sessionToken}`);
  const sessionSnapshot = await sessionRef.once('value');
  const sessionData = sessionSnapshot.val();

  if (!sessionData || sessionData.expiresAt < Date.now()) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Invalid or expired session',
    );
  }

  // Validate input
  if (typeof ios !== 'number' || typeof android !== 'number') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'ios and android must be numbers',
    );
  }

  if (ios < 0 || android < 0) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Download numbers must be positive',
    );
  }

  // Store in database
  const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD
  const downloadData = {
    ios: ios,
    android: android,
    total: ios + android,
    timestamp: Date.now(),
    updatedAt: new Date().toISOString(),
  };

  // Write to daily stats
  await db.ref(`statistics/downloads/${today}`).set(downloadData);

  // Also write to "latest" for real-time dashboard updates
  await db.ref('statistics/downloadLatest').set(downloadData);

  console.log(`Download stats updated: iOS=${ios}, Android=${android}, Total=${ios + android}`);

  return {
    success: true,
    data: downloadData,
    date: today,
  };
});

/**
 * ============================================================================
 * ACCOUNT DELETION FUNCTIONS
 * For Google Play compliance and user privacy
 * ============================================================================
 */

/**
 * Generate a 6-digit verification code
 */
function generateVerificationCode() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

/**
 * HTTP Callable Function: Send account deletion verification code
 * Sends a verification code to the user's email or phone
 *
 * Expected request data:
 * {
 *   authMethod: 'email' | 'phone',
 *   identifier: string (email or phone number)
 * }
 */
exports.sendAccountDeletionCode = functions.https.onCall(async (data, context) => {
  const {authMethod, identifier} = data;

  // Validate input
  if (!authMethod || !identifier) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required fields: authMethod and identifier',
    );
  }

  if (authMethod !== 'email' && authMethod !== 'phone') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'authMethod must be either "email" or "phone"',
    );
  }

  try {
    // Generate verification code
    const code = generateVerificationCode();
    const expiresAt = Date.now() + (15 * 60 * 1000); // 15 minutes from now

    // Store verification code in database
    const verificationRef = db.ref('accountDeletionCodes').push();
    await verificationRef.set({
      authMethod,
      identifier: identifier.toLowerCase().trim(),
      code,
      expiresAt,
      createdAt: Date.now(),
      used: false,
    });

    // Send verification code based on auth method
    if (authMethod === 'email') {
      // For email users, we'll use Firebase Auth's email sending
      // Note: This requires the email to be a registered Firebase Auth user
      try {
        // Verify user exists (throws error if not found)
        await admin.auth().getUserByEmail(identifier);

        // In production, you'd use a proper email service like SendGrid
        // For now, we'll log the code (NOT SECURE - replace with real email sending)
        console.log(`Verification code for ${identifier}: ${code}`);

        // TODO: Replace with actual email sending service
        // Example with SendGrid:
        // const sgMail = require('@sendgrid/mail');
        // sgMail.setApiKey(process.env.SENDGRID_API_KEY);
        // const msg = {
        //   to: identifier,
        //   from: 'noreply@communityfridgefinder.com',
        //   subject: 'FridgeFinder Account Deletion Verification',
        //   text: `Your verification code is: ${code}`,
        //   html: `<strong>Your verification code is: ${code}</strong><br>
        //          This code will expire in 15 minutes.`,
        // };
        // await sgMail.send(msg);

        return {
          success: true,
          message: 'Verification code sent to your email',
        };
      } catch (error) {
        if (error.code === 'auth/user-not-found') {
          // Don't reveal if user exists or not for security
          return {
            success: true,
            message: 'If an account exists with this email, a verification code has been sent',
          };
        }
        throw error;
      }
    } else {
      // For phone users
      // Note: Sending SMS requires a third-party service like Twilio
      console.log(`Verification code for ${identifier}: ${code}`);

      // TODO: Replace with actual SMS sending service
      // Example with Twilio:
      // const twilio = require('twilio');
      // const client = twilio(
      //   process.env.TWILIO_ACCOUNT_SID,
      //   process.env.TWILIO_AUTH_TOKEN,
      // );
      // await client.messages.create({
      //   body: `Your FridgeFinder account deletion code is: ${code}. Valid for 15 minutes.`,
      //   from: process.env.TWILIO_PHONE_NUMBER,
      //   to: identifier,
      // });

      return {
        success: true,
        message: 'Verification code sent to your phone',
      };
    }
  } catch (error) {
    console.error('Error sending verification code:', error);
    throw new functions.https.HttpsError('internal', 'Failed to send verification code');
  }
});

/**
 * HTTP Callable Function: Delete user account
 * Verifies the code and deletes the user account and all associated data
 *
 * Expected request data:
 * {
 *   authMethod: 'email' | 'phone',
 *   identifier: string (email or phone number),
 *   verificationCode: string (6-digit code)
 * }
 */
exports.deleteUserAccount = functions.https.onCall(async (data, context) => {
  const {authMethod, identifier, verificationCode} = data;

  // Validate input
  if (!authMethod || !identifier || !verificationCode) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required fields: authMethod, identifier, and verificationCode',
    );
  }

  try {
    // Find and verify the verification code
    const codesRef = db.ref('accountDeletionCodes');
    const snapshot = await codesRef
      .orderByChild('identifier')
      .equalTo(identifier.toLowerCase().trim())
      .once('value');

    if (!snapshot.exists()) {
      throw new functions.https.HttpsError(
        'not-found',
        'No verification code found for this account',
      );
    }

    let validCodeKey = null;
    let isValid = false;

    snapshot.forEach((childSnapshot) => {
      const codeData = childSnapshot.val();
      if (
        codeData.code === verificationCode &&
        codeData.authMethod === authMethod &&
        !codeData.used &&
        codeData.expiresAt > Date.now()
      ) {
        validCodeKey = childSnapshot.key;
        isValid = true;
      }
    });

    if (!isValid) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Invalid or expired verification code',
      );
    }

    // Mark code as used
    await codesRef.child(validCodeKey).update({used: true, usedAt: Date.now()});

    // Find user by email or phone
    let user;
    try {
      if (authMethod === 'email') {
        user = await admin.auth().getUserByEmail(identifier);
      } else {
        user = await admin.auth().getUserByPhoneNumber(identifier);
      }
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        // User doesn't exist in Firebase Auth, but may still have data in database
        console.log(`No Firebase Auth user found for ${identifier}`);
      } else {
        throw error;
      }
    }

    const userId = user ? user.uid : null;

    // Delete user data from Realtime Database
    if (userId) {
      const userRef = db.ref(`users/${userId}`);

      // Log deletion for compliance (store minimal info for audit trail)
      await db.ref('deletedAccounts').push({
        userId,
        identifier: authMethod === 'email' ? identifier : 'phone_user',
        deletedAt: Date.now(),
        deletionMethod: 'web_form',
      });

      // Delete user data
      await userRef.remove();
      console.log(`Deleted database entry for user ${userId}`);
    }

    // Delete from Firebase Authentication
    if (user) {
      await admin.auth().deleteUser(user.uid);
      console.log(`Deleted Firebase Auth user ${user.uid}`);
    }

    // Clean up verification codes for this identifier
    snapshot.forEach((childSnapshot) => {
      childSnapshot.ref.remove();
    });

    return {
      success: true,
      message: 'Account successfully deleted',
    };
  } catch (error) {
    console.error('Error deleting account:', error);

    // Don't expose internal errors to client
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    throw new functions.https.HttpsError(
      'internal',
      'Failed to delete account. Please contact support.',
    );
  }
});

/**
 * Activity Feed Triggers
 * These functions automatically write to the activityFeed node
 * whenever relevant events occur
 */

/**
 * Database Trigger: On User Account Creation
 * Writes to activityFeed when a new user account is created
 */
exports.onUserAccountCreation = functions.database
  .ref('/users/{userId}')
  .onCreate(async (snapshot, context) => {
    try {
      const userData = snapshot.val();
      const timestamp = Date.now();
      const userId = context.params.userId;

      // Write to activity feed
      await db.ref(`activityFeed/${timestamp}_account_${userId}`).set({
        type: 'account',
        timestamp: timestamp,
        userId: userId,
        isVolunteer: userData.isVolunteer || false,
        zipCode: userData.zipCode || null,
        createdAt: userData.createdAt || new Date().toISOString(),
      });

      console.log(`Activity feed: User account created - ${userId}`);

      // Invalidate stats cache since data changed
      await invalidateStatsCache();
    } catch (error) {
      console.error('Error writing account creation to activity feed:', error);
      // Don't throw - we don't want to block user creation
    }
  });

/**
 * Database Trigger: On Fridge Subscription
 * Writes to activityFeed when a user subscribes to a fridge
 */
exports.onFridgeSubscription = functions.database
  .ref('/users/{userId}/subscribedFridges/{fridgeId}')
  .onCreate(async (snapshot, context) => {
    try {
      const subscription = snapshot.val();
      const timestamp = Date.now();
      const userId = context.params.userId;
      const fridgeId = context.params.fridgeId;

      // Write to activity feed
      await db.ref(`activityFeed/${timestamp}_subscription_${userId}_${fridgeId}`).set({
        type: 'subscription',
        timestamp: timestamp,
        userId: userId,
        fridgeId: fridgeId,
        subscribedAt: subscription.subscribedAt || new Date().toISOString(),
      });

      console.log(`Activity feed: Subscription created - ${userId} to ${fridgeId}`);

      // Invalidate stats cache since data changed
      await invalidateStatsCache();
    } catch (error) {
      console.error('Error writing subscription to activity feed:', error);
      // Don't throw - we don't want to block subscription
    }
  });

/**
 * HTTP Callable Function: Get Activity Feed
 * Returns chronological feed of user accounts, subscriptions, and status reports
 *
 * Expected request data:
 * {
 *   sessionToken: string,
 *   timeFilter: '24h' | '7d' | 'all',
 *   limit: number (default 20),
 *   lastTimestamp: number (cursor for pagination),
 *   direction: 'desc' | 'asc' (default 'desc')
 * }
 */
exports.getActivityFeed = functions.https.onCall(async (data) => {
  const {
    sessionToken,
    timeFilter = 'all',
    limit = 20,
    lastTimestamp = null,
    direction = 'desc',
  } = data;

  // Verify session token
  if (!sessionToken) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Session token required',
    );
  }

  const sessionRef = db.ref(`dashboardSessions/${sessionToken}`);
  const sessionSnapshot = await sessionRef.once('value');
  const sessionData = sessionSnapshot.val();

  if (!sessionData || sessionData.expiresAt < Date.now()) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Invalid or expired session',
    );
  }

  try {
    // Calculate time threshold
    const now = Date.now();
    let startTimestamp = 0;
    if (timeFilter === '24h') {
      startTimestamp = now - (24 * 60 * 60 * 1000);
    } else if (timeFilter === '7d') {
      startTimestamp = now - (7 * 24 * 60 * 60 * 1000);
    }

    // Build query with cursor-based pagination
    let query = db.ref('activityFeed').orderByKey();

    if (direction === 'desc') {
      // For newest first (default)
      if (lastTimestamp) {
        // Continue from last cursor - endBefore excludes the cursor itself
        query = query.endBefore(`${lastTimestamp}`);
      }
      query = query.limitToLast(limit);
    } else {
      // For oldest first (less common)
      if (lastTimestamp) {
        query = query.startAfter(`${lastTimestamp}`);
      }
      query = query.limitToFirst(limit);
    }

    const snapshot = await query.once('value');
    const activities = [];

    snapshot.forEach((child) => {
      const activity = child.val();
      // Apply time filter
      if (activity.timestamp >= startTimestamp) {
        activities.push({
          id: child.key,
          ...activity,
        });
      }
    });

    // Sort (keys are already sorted, but reverse if desc)
    if (direction === 'desc') {
      activities.reverse();
    }

    // Get cursor for next page
    const nextCursor = activities.length > 0 ?
      activities[activities.length - 1].timestamp :
      null;

    return {
      activities: activities,
      nextCursor: nextCursor,
      hasMore: activities.length === limit,
      count: activities.length,
      timeFilter: timeFilter,
    };
  } catch (error) {
    console.error('Error fetching activity feed:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to fetch activity feed',
    );
  }
});


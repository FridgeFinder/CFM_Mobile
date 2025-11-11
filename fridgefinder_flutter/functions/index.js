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
    const message = {
      token: userData.fcmToken,
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: notification.data || {},
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          channelId: 'fridgefinder_notifications',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    };

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

      // Check if user wants notifications for this type of update
      let shouldNotify = false;
      let notificationReason = '';

      // Check food level changes
      if (reportData.foodPercentage !== undefined) {
        if (reportData.foodPercentage === 0 && prefs.empty) {
          shouldNotify = true;
          notificationReason = 'is now empty';
        } else if (reportData.foodPercentage < 0.25 && prefs.runningLow) {
          shouldNotify = true;
          notificationReason = 'is running low on food';
        } else if (reportData.foodPercentage > 0.5 && prefs.updatedWithFood) {
          shouldNotify = true;
          notificationReason = 'has been updated with food';
        }
      }

      // Check condition changes
      if (reportData.condition) {
        if (reportData.condition === 'dirty' && prefs.needsCleaning) {
          shouldNotify = true;
          notificationReason = 'needs cleaning';
        } else if (reportData.condition === 'out of order' && prefs.needsServicing) {
          shouldNotify = true;
          notificationReason = 'needs servicing';
        }
      }

      // Check routine validation (more than 2 days since last update)
      if (prefs.routineValidation && reportData.reportDate) {
        const reportDate = new Date(reportData.reportDate);
        const daysSinceUpdate = (Date.now() - reportDate.getTime()) / (1000 * 60 * 60 * 24);
        if (daysSinceUpdate > 2) {
          shouldNotify = true;
          notificationReason = `needs routine validation (${Math.floor(daysSinceUpdate)} days since update)`;
        }
      }

      if (shouldNotify) {
        // Get fridge name from report data or use default
        const fridgeName = reportData.fridgeName || 'A community fridge';

        notifications.push(
          sendNotificationToUser(userId, {
            title: `${fridgeName} ${notificationReason}`,
            body: 'Check the fridge status and help if you can!',
            data: {
              type: 'fridge_update',
              fridgeId: fridgeId,
              reason: notificationReason,
            },
          }),
        );
      }
    }

    // Send all notifications in parallel
    await Promise.allSettled(notifications);
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


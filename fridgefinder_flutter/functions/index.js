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


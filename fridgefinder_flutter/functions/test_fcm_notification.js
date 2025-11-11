/**
 * Test script for sending FCM notifications directly
 *
 * Usage:
 *   node test_fcm_notification.js <fcm-token> <fridge-id> [title] [body]
 *
 * Example:
 *   node test_fcm_notification.js "your-fcm-token-here" "fridge-123" "Test Title" "Test Body"
 *
 * Prerequisites:
 *   1. Install dependencies: npm install firebase-admin
 *   2. Set GOOGLE_APPLICATION_CREDENTIALS environment variable to your service account key
 *      export GOOGLE_APPLICATION_CREDENTIALS="./secrets/fridgefinder-app-1-17dbe2831a13.json"
 */

const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
// Make sure GOOGLE_APPLICATION_CREDENTIALS is set to your service account key path
if (!admin.apps.length) {
  try {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
    });
    console.log('Firebase Admin SDK initialized');
  } catch (error) {
    console.error('Error initializing Firebase Admin SDK:', error);
    console.error('Make sure GOOGLE_APPLICATION_CREDENTIALS is set correctly');
    process.exit(1);
  }
}

async function sendTestNotification(fcmToken, fridgeId, title, body) {
  try {
    const message = {
      token: fcmToken,
      notification: {
        title: title || 'Test Notification',
        body: body || 'This is a test notification',
      },
      data: {
        type: 'fridge_update',
        fridgeId: fridgeId,
        reason: 'test',
      },
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
    console.log('✅ Successfully sent notification:', response);
    return response;
  } catch (error) {
    console.error('❌ Error sending notification:', error);

    // Handle specific error cases
    if (error.code === 'messaging/invalid-registration-token' ||
        error.code === 'messaging/registration-token-not-registered') {
      console.error('Invalid or expired FCM token. Please get a new token from the app.');
    }

    throw error;
  }
}

// Main execution
const args = process.argv.slice(2);

if (args.length < 2) {
  console.log('Usage: node test_fcm_notification.js <fcm-token> <fridge-id> [title] [body]');
  console.log('');
  console.log('Example:');
  console.log('  node test_fcm_notification.js "your-token" "fridge-123" "Test Title" "Test Body"');
  process.exit(1);
}

const [fcmToken, fridgeId, title, body] = args;

console.log('Sending test FCM notification...');
console.log(`FCM Token: ${fcmToken.substring(0, 20)}...`);
console.log(`Fridge ID: ${fridgeId}`);
console.log(`Title: ${title || 'Test Notification'}`);
console.log(`Body: ${body || 'This is a test notification'}`);
console.log('');

sendTestNotification(fcmToken, fridgeId, title, body)
  .then(() => {
    console.log('');
    console.log('✅ Test notification sent successfully!');
    console.log('Check your device for the notification.');
    process.exit(0);
  })
  .catch((error) => {
    console.error('');
    console.error('❌ Failed to send test notification');
    process.exit(1);
  });


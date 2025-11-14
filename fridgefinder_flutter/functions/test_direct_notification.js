/**
 * Test script to send a notification directly to FCM token
 * This bypasses the Cloud Function to test if FCM messaging works
 */

const admin = require('firebase-admin');

// Initialize with application default credentials
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    databaseURL: 'https://fridgefinder-app-default-rtdb.firebaseio.com',
  });
}

async function sendTestNotification(fcmToken, title, body) {
  try {
    // Convert all data values to strings (FCM requirement for iOS)
    const dataPayload = {
      type: 'fridge_update',
      fridgeId: 'J93c8l',
      reason: 'test notification',
    };

    const message = {
      token: fcmToken,
      notification: {
        title: title,
        body: body,
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
              title: title,
              body: body,
            },
            sound: 'default',
            badge: 1,
          },
        },
      },
    };

    // Add data if it has content
    if (Object.keys(dataPayload).length > 0) {
      message.data = dataPayload;
    }

    console.log('Sending test notification...');
    console.log('Token:', fcmToken.substring(0, 30) + '...');
    console.log('Title:', title);
    console.log('Body:', body);

    const response = await admin.messaging().send(message);
    console.log('✅ Notification sent successfully!');
    console.log('Response:', response);
    return response;
  } catch (error) {
    console.error('❌ Error sending notification:', error);
    throw error;
  }
}

// Get FCM token from command line
const fcmToken = process.argv[2];
const title = process.argv[3] || 'Test Fridge is now empty';
const body = process.argv[4] || 'Check the fridge status and help if you can!';

if (!fcmToken) {
  console.log('Usage: node test_direct_notification.js <fcm-token> [title] [body]');
  console.log('');
  console.log('Example:');
  console.log('  node test_direct_notification.js "eBNmC8..." "Test notification" "This is a test"');
  process.exit(1);
}

sendTestNotification(fcmToken, title, body)
  .then(() => {
    console.log('✅ Test completed successfully!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Test failed');
    process.exit(1);
  });

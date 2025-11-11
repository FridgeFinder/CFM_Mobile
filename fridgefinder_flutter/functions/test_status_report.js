/**
 * Test script for creating status reports in Realtime Database
 * This will trigger the Cloud Function onFridgeStatusUpdate
 *
 * Usage:
 *   node test_status_report.js <fridge-id> [condition] [food-percentage] [fridge-name]
 *
 * Example:
 *   node test_status_report.js "fridge-123" "good" 0.0 "Test Fridge"
 *
 * Prerequisites:
 *   1. Install dependencies: npm install firebase-admin
 *   2. Set GOOGLE_APPLICATION_CREDENTIALS environment variable to your service account key
 *      export GOOGLE_APPLICATION_CREDENTIALS="./secrets/fridgefinder-app-1-17dbe2831a13.json"
 */

const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
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

const db = admin.database();

async function createTestStatusReport(fridgeId, condition, foodPercentage, fridgeName) {
  try {
    const reportRef = db.ref('statusReports').push();

    const reportData = {
      fridgeId: fridgeId,
      fridgeName: fridgeName || 'Test Fridge',
      condition: condition || 'good',
      foodPercentage: foodPercentage !== undefined ? foodPercentage : 0.0,
      reportDate: new Date().toISOString(),
      createdAt: new Date().toISOString(),
      notes: 'Test status report created by test script',
    };

    await reportRef.set(reportData);
    const reportId = reportRef.key;

    console.log('✅ Test status report created successfully!');
    console.log(`Report ID: ${reportId}`);
    console.log(`Fridge ID: ${fridgeId}`);
    console.log(`Condition: ${condition || 'good'}`);
    console.log(`Food Percentage: ${foodPercentage !== undefined ? foodPercentage : 0.0}`);
    console.log('');
    console.log('This will trigger Cloud Function: onFridgeStatusUpdate');
    console.log('Users subscribed to this fridge will receive notifications');

    return reportId;
  } catch (error) {
    console.error('❌ Error creating status report:', error);
    throw error;
  }
}

// Main execution
const args = process.argv.slice(2);

if (args.length < 1) {
  console.log('Usage: node test_status_report.js <fridge-id> [condition] [food-percentage] [fridge-name]');
  console.log('');
  console.log('Example:');
  console.log('  node test_status_report.js "fridge-123" "good" 0.0 "Test Fridge"');
  console.log('');
  console.log('Conditions: good, dirty, out of order, not at location');
  console.log('Food Percentage: 0.0 (empty) to 1.0 (full)');
  process.exit(1);
}

const [fridgeId, condition, foodPercentageStr, fridgeName] = args;
const foodPercentage = foodPercentageStr ? parseFloat(foodPercentageStr) : undefined;

console.log('Creating test status report...');
console.log(`Fridge ID: ${fridgeId}`);
console.log(`Condition: ${condition || 'good'}`);
console.log(`Food Percentage: ${foodPercentage !== undefined ? foodPercentage : 0.0}`);
console.log(`Fridge Name: ${fridgeName || 'Test Fridge'}`);
console.log('');

createTestStatusReport(fridgeId, condition, foodPercentage, fridgeName)
  .then(() => {
    console.log('');
    console.log('✅ Test status report created successfully!');
    console.log('Check Cloud Functions logs to see if notifications were sent.');
    process.exit(0);
  })
  .catch((error) => {
    console.error('');
    console.error('❌ Failed to create test status report');
    process.exit(1);
  });


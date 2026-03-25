#!/bin/bash

# Setup Google Play Console API credentials for Firebase Functions
# This script configures the credentials needed for dashboard download statistics

echo "Setting up Google Play Console API credentials..."

cd fridgefinder_flutter

# Read the service account JSON and minify it (remove newlines/spaces)
SERVICE_ACCOUNT=$(cat secrets/fridgefinder-app-1-17dbe2831a13.json | tr -d '\n' | tr -d ' ')

# Set the Firebase Functions config
firebase functions:config:set \
  playstore.service_account="$SERVICE_ACCOUNT"

echo ""
echo "✅ Google Play Console API credentials configured!"
echo ""
echo "Important: This service account must be linked to Google Play Console:"
echo "1. Go to: https://play.google.com/console"
echo "2. Settings → API access"
echo "3. Find: fastlane@fridgefinder-app-1.iam.gserviceaccount.com"
echo "4. Grant access with 'View app information' permissions"
echo "5. Wait 24-48 hours for access to activate"
echo ""
echo "Next steps:"
echo "1. Deploy functions: firebase deploy --only functions"
echo "2. Verify in logs: firebase functions:log --only getAppDownloads"

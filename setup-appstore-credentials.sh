#!/bin/bash

# Setup App Store Connect API credentials for Firebase Functions
# This script configures the credentials needed for dashboard download statistics

echo "Setting up App Store Connect API credentials..."

cd fridgefinder_flutter

# Read the private key from file and escape newlines properly
# Use awk to replace actual newlines with the literal string \n
PRIVATE_KEY=$(cat secrets/AuthKey_273R6L4M2K.p8 | awk '{printf "%s\\n", $0}' | sed '$ s/\\n$//')

# Set the Firebase Functions config
firebase functions:config:set \
  appstore.key_id="273R6L4M2K" \
  appstore.issuer_id="69a6de8e-eb3c-47e3-e053-5b8c7c11a4d1" \
  appstore.private_key="$PRIVATE_KEY"

echo ""
echo "✅ App Store Connect API credentials configured!"
echo ""
echo "Next steps:"
echo "1. Deploy functions: firebase deploy --only functions"
echo "2. Verify in logs: firebase functions:log --only getAppDownloads"
echo ""
echo "Note: The dashboard will still show placeholder data until the full"
echo "App Store Connect API integration is implemented. For now, you can"
echo "manually update download stats in Firebase Console under:"
echo "Realtime Database > statistics > downloads"

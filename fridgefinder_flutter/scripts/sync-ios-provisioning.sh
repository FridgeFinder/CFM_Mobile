#!/bin/bash

# Script to automatically sync iOS provisioning profile UUID to ExportOptions.plist
# This ensures the ExportOptions.plist always uses the latest provisioning profile UUID

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MOBILEPROVISION_PATH="$PROJECT_ROOT/ios/fastlane/profiles/dev-tester.mobileprovision"
EXPORT_OPTIONS_PATH="$PROJECT_ROOT/ios/ExportOptions.plist"
BUNDLE_ID="com.fridgefinder.fridgefinderFlutterApp"

echo "🔍 Checking iOS provisioning profile UUID..."

# Check if mobileprovision file exists
if [ ! -f "$MOBILEPROVISION_PATH" ]; then
    echo "⚠️  Warning: Provisioning profile not found at $MOBILEPROVISION_PATH"
    echo "   Skipping UUID sync (will use existing ExportOptions.plist)"
    exit 0
fi

# Check if ExportOptions.plist exists
if [ ! -f "$EXPORT_OPTIONS_PATH" ]; then
    echo "❌ Error: ExportOptions.plist not found at $EXPORT_OPTIONS_PATH"
    exit 1
fi

# Extract UUID from mobileprovision file
MOBILEPROVISION_UUID=$(security cms -D -i "$MOBILEPROVISION_PATH" | plutil -convert xml1 -o - - | grep -A 1 "<key>UUID</key>" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')

if [ -z "$MOBILEPROVISION_UUID" ]; then
    echo "❌ Error: Could not extract UUID from provisioning profile"
    exit 1
fi

echo "   Provisioning profile UUID: $MOBILEPROVISION_UUID"

# Extract current UUID from ExportOptions.plist
# Convert to XML and extract the UUID for our bundle ID
CURRENT_UUID=$(plutil -convert xml1 -o - "$EXPORT_OPTIONS_PATH" | grep -A 1 "<key>$BUNDLE_ID</key>" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')

if [ -z "$CURRENT_UUID" ]; then
    echo "⚠️  Warning: Could not extract current UUID from ExportOptions.plist"
    echo "   The file may need manual inspection"
    exit 1
fi

echo "   ExportOptions.plist UUID:  $CURRENT_UUID"

# Compare UUIDs
if [ "$MOBILEPROVISION_UUID" = "$CURRENT_UUID" ]; then
    echo "✅ UUIDs match - no update needed"
    exit 0
fi

# UUIDs don't match - update ExportOptions.plist
echo ""
echo "🔄 UUID mismatch detected - updating ExportOptions.plist..."
echo "   Old UUID: $CURRENT_UUID"
echo "   New UUID: $MOBILEPROVISION_UUID"

# Use PlistBuddy to update the UUID (handles nested keys better than plutil)
/usr/libexec/PlistBuddy -c "Set :provisioningProfiles:$BUNDLE_ID $MOBILEPROVISION_UUID" "$EXPORT_OPTIONS_PATH"

# Verify the update
UPDATED_UUID=$(plutil -convert xml1 -o - "$EXPORT_OPTIONS_PATH" | grep -A 1 "<key>$BUNDLE_ID</key>" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')

if [ "$UPDATED_UUID" = "$MOBILEPROVISION_UUID" ]; then
    echo "✅ ExportOptions.plist updated successfully!"
    echo "   New UUID: $UPDATED_UUID"
else
    echo "❌ Error: Failed to update ExportOptions.plist"
    echo "   Expected: $MOBILEPROVISION_UUID"
    echo "   Got:      $UPDATED_UUID"
    exit 1
fi

echo ""
echo "✨ Provisioning profile sync complete!"

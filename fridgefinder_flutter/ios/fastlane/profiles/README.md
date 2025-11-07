# Provisioning Profile Setup for Fastlane

This directory is for storing provisioning profile files (`.mobileprovision`) used by Fastlane builds.

## How to Add a Provisioning Profile

### Option 1: Place file in this directory (Recommended)

1. Place your `.mobileprovision` file in this directory:
   ```
   ios/fastlane/profiles/dev-tester.mobileprovision
   ```

2. Fastlane will automatically detect and install it when running `bundle exec fastlane beta`

### Option 2: Use Environment Variable

Set the `PROVISIONING_PROFILE_PATH` environment variable before running fastlane:

```bash
export PROVISIONING_PROFILE_PATH="/path/to/your/profile.mobileprovision"
cd ios
bundle exec fastlane beta
```

### Option 3: Manual Installation

You can also manually install the provisioning profile to the system location:

```bash
# Copy to system provisioning profiles directory
cp your-profile.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/

# Or double-click the file to install via Xcode
open your-profile.mobileprovision
```

## File Naming Convention

- `dev-tester.mobileprovision` - For development/testing builds
- `adhoc.mobileprovision` - For ad-hoc distribution
- `appstore.mobileprovision` - For App Store distribution

## Notes

- Provisioning profiles are automatically installed to `~/Library/MobileDevice/Provisioning Profiles/`
- The profile must match your app's bundle identifier: `com.fridgefinder.fridgefinderFlutterApp`
- Ensure the profile includes all device UUIDs for your test group
- Profiles expire and need to be updated periodically


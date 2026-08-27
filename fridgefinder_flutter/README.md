# FridgeFinder Flutter

## Environment Setup

This app supports two runtime environments:

- `dev`
- `prod`

Runtime environment is selected with Dart define:

```bash
--dart-define=APP_ENV=dev
```

If `APP_ENV` is not provided, app bootstrap defaults to `prod`.

## Platform Firebase Configuration

Flutter shares app code, but Firebase native SDKs still require platform-specific
configuration files.

### iOS

- Dev Firebase plist: `ios/Runner/GoogleService-Info.dev.plist`
- Prod Firebase plist: `ios/Runner/GoogleService-Info.prod.plist`
- Dev URL scheme plist: `ios/Runner/Info.dev.plist`
- Prod URL scheme plist: `ios/Runner/Info.prod.plist`

Xcode build configuration selects the correct files automatically.

### Android

- Dev Firebase config: `android/app/src/debug/google-services.json`
- Prod Firebase config: `android/app/src/release/google-services.json`
- Prod profile config: `android/app/src/profile/google-services.json`

Google Services plugin picks the correct file by build type.

## Local Run Commands

Use helper scripts to avoid accidental environment mismatch:

### iOS

```bash
APP_ENV=dev ./scripts/run_ios_safe.sh "iPhone 17"
APP_ENV=prod ./scripts/run_ios_safe.sh "iPhone 17"
```

### Android

```bash
APP_ENV=dev ./scripts/run_android_safe.sh android
APP_ENV=prod ./scripts/run_android_safe.sh android
```

You can replace `android` with a specific Android device ID from `flutter devices`.

## Fastlane Environment Guardrails

Production release lanes enforce explicit environment and require `APP_ENV=prod`.

- iOS: `ios/fastlane/Fastfile`
- Android: `android/fastlane/Fastfile`
- Guard script: `scripts/require_prod_env.sh`

Set environment before release lanes:

```bash
export APP_ENV=prod
```

## Dev TestFlight

There is a dedicated iOS Fastlane lane for uploading a dev-environment build to
TestFlight:

```bash
cd ios
APP_ENV=dev bundle exec fastlane ios dev_testflight
```

This lane builds the iOS app with:

- `Release-dev` Xcode configuration
- `--dart-define=APP_ENV=dev`
- `GoogleService-Info.dev.plist`
- `Info.dev.plist`

Current limitation: the repo-side dev lane still uses the same iOS bundle ID as
production because the checked-in `GoogleService-Info.dev.plist` is registered
for `com.fridgefinder.fridgefinderFlutterApp`. To make the dev build a separate
installable TestFlight app, you still need to create a second iOS app in:

- Firebase for the dev project
- Apple Developer / App Store Connect

Then replace the dev plist and update the dev bundle ID in Xcode.

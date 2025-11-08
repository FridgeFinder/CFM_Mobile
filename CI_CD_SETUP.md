# CI/CD Setup Guide for FridgeFinder

This guide walks you through setting up Fastlane and GitHub Actions CI/CD for automated builds, testing, and deployment.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Fastlane Setup](#fastlane-setup)
3. [Firebase App Distribution Setup](#firebase-app-distribution-setup)
4. [App Store Connect Setup](#app-store-connect-setup)
5. [Google Play Console Setup](#google-play-console-setup)
6. [Android Keystore Setup](#android-keystore-setup)
7. [GitHub Secrets Configuration](#github-secrets-configuration)
8. [Release Process](#release-process)

## Prerequisites

- Flutter SDK 3.24.0 or higher
- Ruby 3.2+ (for Fastlane)
- macOS (for iOS builds)
- Android SDK and Java 17
- Xcode (for iOS builds)
- Git

## Fastlane Setup

### 1. Install Fastlane

```bash
cd fridgefinder_flutter
bundle install
```

### 2. Initialize Fastlane (Already Done)

Fastlane has been initialized for both iOS and Android:

- `ios/fastlane/` - iOS Fastlane configuration
- `android/fastlane/` - Android Fastlane configuration

### 3. Available Fastlane Lanes

#### iOS Lanes:

- `fastlane ios screenshots` - Generate screenshots for App Store
- `fastlane ios beta` - Build and upload to Firebase App Distribution
- `fastlane ios release` - Build and upload to App Store Connect

#### Android Lanes:

- `fastlane android screenshots` - Generate screenshots for Play Store
- `fastlane android beta` - Build and upload to Firebase App Distribution
- `fastlane android release` - Build and upload to Google Play Console

## Firebase App Distribution Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing project
3. Enable Firebase App Distribution

### 2. Register Your Apps

1. Go to Firebase Console → App Distribution
2. Register your iOS app (Bundle ID: `com.fridgefinder.fridgefinderFlutterApp`)
3. Register your Android app (Package: `com.fridgefinder.fridgefinder_flutter`)
4. Note the App IDs for each platform

### 3. Create Distribution Groups

Create groups for:

- `dev-testers` - For dev environment builds
- `staging-testers` - For staging environment builds

### 4. Get Firebase CLI Token

```bash
firebase login:ci
```

This will output a token. Save this for GitHub Secrets.

### 5. Configure Firebase App IDs

Note the App IDs from Firebase Console:

- iOS App ID: Found in Firebase Console → App Distribution → iOS app
- Android App ID: Found in Firebase Console → App Distribution → Android app

## App Store Connect Setup

### 1. Create App Store Connect API Key

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Navigate to Users and Access → Keys
3. Click "+" to create a new key
4. Name it "Fastlane CI/CD" (or similar)
5. Select "App Manager" role
6. Download the `.p8` key file (you can only download it once!)
7. Note the Key ID and Issuer ID

### 2. Configure App Store Connect

- **Key ID**: Found in App Store Connect → Keys
- **Issuer ID**: Found in App Store Connect → Keys (top of page)
- **API Key**: The `.p8` file you downloaded

## Google Play Console Setup

### 1. Create Service Account in Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing project
3. Enable Google Play Android Developer API:
   - Go to **APIs & Services** → **Library**
   - Search for "Google Play Android Developer API"
   - Click on it and click **Enable**
4. Go to **IAM & Admin** → **Service Accounts**
5. Click **+ Create Service Account**
6. Fill in the details:
   - **Service account name**: `fastlane-ci-cd` (or your preferred name)
   - **Service account ID**: Will auto-populate
   - **Description**: "Service account for CI/CD automation"
7. Click **Create and Continue**
8. Grant permissions (optional for this step):
   - Skip or grant "Service Account User" role
   - Click **Continue**
9. Click **Done**
10. Find your newly created service account and click on it
11. Go to the **Keys** tab
12. Click **Add Key** → **Create new key**
13. Select **JSON** format
14. Click **Create** - this will download a JSON key file
15. **IMPORTANT**: Save this JSON file securely (you'll need it for GitHub Secrets)

### 2. Link Service Account to Play Console

**IMPORTANT**: API access is at the **account level**, not the app level. You need to navigate to the account settings.

1. Go to [Google Play Console](https://play.google.com/console/)
2. **Navigate to Account Level** (not app level):
   - If you're currently viewing an app, click on **"All apps"** or the back arrow at the top left to go to the account dashboard
   - You should see the main account navigation menu
3. In the left sidebar, look for **Setup** section:
   - **Note**: If you don't see "Setup" in the left menu, try looking for:
     - **Settings** (gear icon) → **API access**
     - Or go directly to: `https://play.google.com/console/u/0/developers/[YOUR_ACCOUNT_ID]/api-access`
4. Click on **API access** (or navigate to it via Settings → API access)
5. Under the **Service accounts** section, you'll see your service accounts or a button to link one
6. Click **Grant Access** or **Link Service Account**:
   - If you already created a service account in Google Cloud Console, you should see it listed
   - If you don't see your service account, click **Create Service Account** which will redirect you to Google Cloud Console
7. In the popup or page:
   - Find your service account by email (looks like `fastlane-ci-cd@your-project.iam.gserviceaccount.com`)
   - Click on it or check the box next to it
8. Grant permissions:
   - Check **Release management** (or "Release apps to production, testing tracks, and manage releases")
   - Optionally grant other permissions as needed
9. Click **Invite** or **Grant Access**
10. Your service account should now appear in the API access page with a green checkmark

#### Alternative Navigation Methods:

If you still can't find API access:

1. **Direct URL method**:

   - When you're logged into Google Play Console, check the URL in your browser
   - It will look like: `https://play.google.com/console/u/0/developers/[YOUR_ACCOUNT_ID]/...`
   - The account ID is the number after `/developers/`
   - Go to: `https://play.google.com/console/u/0/developers/[YOUR_ACCOUNT_ID]/api-access`
   - Replace `[YOUR_ACCOUNT_ID]` with your actual account ID from the URL

2. **Via Settings menu**:

   - Look for a **Settings** (gear icon) in the top right or left sidebar
   - Navigate to Developer account settings
   - Look for API access or Service accounts

3. **Check permissions**:
   - Ensure your account has Admin or Account Owner permissions
   - Some users may not have access to API settings

### 3. Verify API Access

- Your service account should now be listed under "Service accounts" in the API access page
- Status should show "Active" or have a green checkmark
- The service account email is what you'll use (it's also in the downloaded JSON file)

## Android Keystore Setup

To sign your Android app for release, you need to create a keystore file. **This is critical - if you lose your keystore, you cannot update your app on Google Play Store!**

### 1. Generate a Keystore File

1. Open your terminal/command prompt
2. Navigate to a secure location (e.g., your home directory):
   ```bash
   cd ~
   ```
3. Generate the keystore using the `keytool` command (comes with Java):
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
4. You'll be prompted for the following information:
   - **Keystore password**: Choose a strong password (16+ characters recommended)
     - You'll need this for `ANDROID_KEYSTORE_PASSWORD` secret
   - **Re-enter password**: Confirm your keystore password
   - **First and last name**: Your name or organization name
   - **Organizational unit**: e.g., "Development"
   - **Organization**: Your company name, e.g., "FridgeFinder"
   - **City or locality**: Your city
   - **State or province**: Your state/province
   - **Country code**: Two-letter code (e.g., "US", "CA", "GB")
   - **Is this correct?**: Type "yes"
   - **Key password**: Press Enter to use the same password as keystore
     - Or enter a different password (you'll need this for `ANDROID_KEY_PASSWORD` secret)

### 2. Verify Your Keystore

Verify the keystore was created successfully:

```bash
keytool -list -v -keystore ~/upload-keystore.jks
```

You'll see information about your keystore including the alias (should be "upload").

### 3. Record Your Keystore Information

You'll need the following information for GitHub Secrets:

- **Keystore file location**: `~/upload-keystore.jks` (or wherever you saved it)
- **Keystore password**: The password you entered when creating the keystore
- **Key alias**: `upload` (or whatever alias you specified)
- **Key password**: Usually the same as keystore password (unless you set a different one)

### 4. Backup Your Keystore

**CRITICAL**: Backup your keystore file and passwords:

1. Copy the keystore file to a secure backup location:
   ```bash
   cp ~/upload-keystore.jks ~/backups/upload-keystore-backup.jks
   ```
2. Store your passwords securely:
   - Use a password manager
   - Store multiple backups in different secure locations
   - **Never commit the keystore file to git** (it's already in `.gitignore`)

### 5. Prepare Keystore for GitHub Secrets

To use the keystore in GitHub Actions, you need to convert it to Base64:

```bash
# Convert keystore to Base64
base64 -i ~/upload-keystore.jks
```

Copy the entire output (it will be a long string) - this is what you'll paste into the `ANDROID_KEYSTORE` GitHub secret.

**Note**: If you prefer to save the Base64 string to a file first:

```bash
base64 -i ~/upload-keystore.jks > keystore-base64.txt
cat keystore-base64.txt
```

## GitHub Secrets Configuration

Go to your GitHub repository → Settings → Secrets and variables → Actions → New repository secret

Add the following secrets:

### Required Secrets

| Secret Name                        | Description                         | How to Get                                            |
| ---------------------------------- | ----------------------------------- | ----------------------------------------------------- |
| `APP_STORE_CONNECT_API_KEY_ID`     | App Store Connect API Key ID        | From App Store Connect → Keys                         |
| `APP_STORE_CONNECT_ISSUER_ID`      | App Store Connect Issuer ID         | From App Store Connect → Keys                         |
| `APP_STORE_CONNECT_API_KEY`        | Base64 encoded `.p8` file           | `base64 -i AuthKey.p8`                                |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Base64 encoded service account JSON | See [Google Play Setup](#google-play-console-setup)   |
| `FIREBASE_CLI_TOKEN`               | Firebase CLI token                  | `firebase login:ci`                                   |
| `FIREBASE_APP_ID_IOS`              | Firebase iOS App ID                 | From Firebase Console                                 |
| `FIREBASE_APP_ID_ANDROID`          | Firebase Android App ID             | From Firebase Console                                 |
| `ANDROID_KEYSTORE`                 | Base64 encoded keystore file        | See [Android Keystore Setup](#android-keystore-setup) |
| `ANDROID_KEYSTORE_PASSWORD`        | Keystore password                   | Password you set when creating keystore               |
| `ANDROID_KEY_ALIAS`                | Key alias                           | Usually "upload" (from keystore creation)             |
| `ANDROID_KEY_PASSWORD`             | Key password                        | Usually same as keystore password                     |

### How to Base64 Encode Files

```bash
# App Store Connect API Key
base64 -i AuthKey.p8

# Google Play Service Account
# Use the JSON file you downloaded from Google Cloud Console
base64 -i service-account.json

# Android Keystore
# Use the keystore file you created (adjust path as needed)
base64 -i ~/upload-keystore.jks
```

### Step-by-Step Guide for Android Secrets

#### 1. ANDROID_KEYSTORE

1. Generate Base64 string from your keystore:
   ```bash
   base64 -i ~/upload-keystore.jks
   ```
2. Copy the entire output (it's a long string)
3. In GitHub: Settings → Secrets → New repository secret
4. Name: `ANDROID_KEYSTORE`
5. Value: Paste the entire Base64 string

#### 2. ANDROID_KEYSTORE_PASSWORD

1. Use the password you entered when creating the keystore
2. In GitHub: Create new secret
3. Name: `ANDROID_KEYSTORE_PASSWORD`
4. Value: Your keystore password (plain text, not Base64)

#### 3. ANDROID_KEY_ALIAS

1. This is the alias you used when creating the keystore
2. If you followed the guide, it's `upload`
3. In GitHub: Create new secret
4. Name: `ANDROID_KEY_ALIAS`
5. Value: `upload` (or your custom alias)

#### 4. ANDROID_KEY_PASSWORD

1. Usually the same as your keystore password
2. If you set a different key password when creating the keystore, use that instead
3. In GitHub: Create new secret
4. Name: `ANDROID_KEY_PASSWORD`
5. Value: Your key password (plain text, not Base64)

### Step-by-Step Guide for Google Play Service Account Secret

#### GOOGLE_PLAY_SERVICE_ACCOUNT_JSON

1. Use the JSON file you downloaded from Google Cloud Console
2. Convert to Base64:
   ```bash
   base64 -i /path/to/your-service-account.json
   ```
   Or if you saved it with a different name:
   ```bash
   base64 -i ~/Downloads/your-project-service-account-key.json
   ```
3. Copy the entire Base64 output
4. In GitHub: Create new secret
5. Name: `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
6. Value: Paste the entire Base64 string

**Note**: The JSON file contains sensitive information. After adding it to GitHub Secrets, you can delete the local file if desired (but keep backups in a secure location).

## Release Process

### Dev Environment

1. Create a git tag:

   ```bash
   git tag dev/v1.0.0+1
   git push origin dev/v1.0.0+1
   ```

2. GitHub Actions will automatically:
   - Run tests
   - Build Android and iOS
   - Upload to Firebase App Distribution (dev-testers group)

### Staging Environment

1. Create a git tag:

   ```bash
   git tag staging/v1.0.0+1
   git push origin staging/v1.0.0+1
   ```

2. GitHub Actions will automatically:
   - Run tests
   - Build Android and iOS
   - Upload to Firebase App Distribution (staging-testers group)

### Production Release

1. Update version in `pubspec.yaml`:

   ```yaml
   version: 1.0.0+1
   ```

2. Create a git tag:

   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

3. GitHub Actions will automatically:
   - Run full test suite
   - Generate screenshots
   - Build release binaries
   - Upload to App Store Connect
   - Upload to Google Play Console

### Manual Screenshot Generation

To manually generate screenshots:

```bash
# iOS
cd ios
bundle exec fastlane screenshots

# Android
cd android
bundle exec fastlane screenshots
```

## Local Testing

### Test Fastlane Lanes Locally

```bash
# iOS beta build
cd ios
bundle exec fastlane beta

# Android beta build
cd android
bundle exec fastlane beta
```

## Troubleshooting

### Fastlane Issues

- **Certificate errors**: Ensure certificates are properly configured in App Store Connect
- **Firebase upload fails**: Check Firebase CLI token is valid
- **Build fails**: Ensure Flutter dependencies are installed (`flutter pub get`)

### GitHub Actions Issues

- **Secrets not found**: Double-check secret names match exactly
- **Build fails**: Check Flutter version compatibility
- **Upload fails**: Verify API keys and tokens are correct

## Additional Resources

- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Firebase App Distribution](https://firebase.google.com/docs/app-distribution)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## Support

For issues or questions:

1. Check the troubleshooting section above
2. Review Fastlane documentation
3. Check GitHub Actions logs for detailed error messages

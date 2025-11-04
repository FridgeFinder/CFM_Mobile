plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties for release signing
// Create android/key.properties file with your keystore details
def keystorePropertiesFile = rootProject.file("key.properties")
def keystoreProperties = new Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.fridgefinder.fridgefinder_flutter"

    // Explicit SDK versions (CRITICAL for Play Store submission)
    compileSdk = 34  // Android 14 (required for 2025)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Updated to Java 17 (required for AGP 8.0+)
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"  // Match compileOptions
    }

    defaultConfig {
        applicationId = "com.fridgefinder.fridgefinder_flutter"

        // Explicit SDK versions for Play Store compliance
        minSdk = 24      // Android 7.0 (Flutter 3.35+ requirement)
        targetSdk = 34   // Android 14 (REQUIRED for Play Store 2024+)

        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Enable multidex for apps with >64k methods
        multiDexEnabled = true
    }

    // Signing configurations
    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            release {
                keyAlias = keystoreProperties['keyAlias']
                keyPassword = keystoreProperties['keyPassword']
                storeFile = file(keystoreProperties['storeFile'])
                storePassword = keystoreProperties['storePassword']
            }
        }
    }

    buildTypes {
        release {
            // Use release signing if keystore exists, otherwise use debug
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.release
            } else {
                signingConfig = signingConfigs.debug
            }

            // Enable code shrinking and obfuscation for smaller APK
            minifyEnabled = true
            shrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

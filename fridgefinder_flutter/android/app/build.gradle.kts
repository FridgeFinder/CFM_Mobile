import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties for release signing
// Create android/key.properties file with your keystore details
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
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
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile") ?: "")
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        getByName("release") {
            // Use release signing if keystore exists, otherwise use debug
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }

            // Enable code shrinking and obfuscation for smaller APK
            isMinifyEnabled = true
            isShrinkResources = true
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

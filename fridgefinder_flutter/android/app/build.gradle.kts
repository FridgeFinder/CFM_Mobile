import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

dependencies {
  // Import the Firebase BoM
  implementation(platform("com.google.firebase:firebase-bom:34.5.0"))

  // Firebase dependencies (versions inherited from BoM)
  implementation("com.google.firebase:firebase-analytics")

  // Play Core modular dependencies for split compatibility
  implementation("com.google.android.play:app-update:2.1.0")
  implementation("com.google.android.play:feature-delivery:2.1.0")

  // Flutter embedding dependency (required for MainActivity)
  debugImplementation("io.flutter:flutter_embedding_debug:1.0.0-035316565ad77281a75305515e4682e6c4c6f7ca")
  profileImplementation("io.flutter:flutter_embedding_profile:1.0.0-035316565ad77281a75305515e4682e6c4c6f7ca")
  releaseImplementation("io.flutter:flutter_embedding_release:1.0.0-035316565ad77281a75305515e4682e6c4c6f7ca")
}

// Load keystore properties for release signing
// Create android/key.properties file with your keystore details
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.fridgefinder.fridgefinderapp"

    // Explicit SDK versions (CRITICAL for Play Store submission)
    compileSdk = 36  // Android 15 (required for newer androidx libraries and plugins)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Updated to Java 21
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = "21"  // Match compileOptions
    }

    defaultConfig {
        applicationId = "com.fridgefinder.fridgefinderapp"

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

            // Disable minification for beta builds to avoid Play Core issues
            // TODO: Re-enable with proper ProGuard rules for production
            isMinifyEnabled = false
            isShrinkResources = false
            // proguardFiles(
            //     getDefaultProguardFile("proguard-android-optimize.txt"),
            //     "proguard-rules.pro"
            // )
        }
    }
}

flutter {
    source = "../.."
}

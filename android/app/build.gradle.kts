import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "in.mahato.cocircle"
    compileSdk = 36
    ndkVersion = "28.0.12433566"

    packaging {
        jniLibs {
            useLegacyPackaging = false
        }
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "in.mahato.cocircle"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("release")
            
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    flavorDimensions += "default"
    productFlavors {
        create("dev") {
            dimension = "default"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "CoCircle Dev")
            versionNameSuffix = "-dev"
        }
        create("prod") {
            dimension = "default"
            resValue("string", "app_name", "CoCircle")
        }
    }

    aaptOptions {
        noCompress("so")
    }
}

flutter {
    source = "../.."
}

configurations.all {
    resolutionStrategy {
        force("com.google.android.gms:play-services-auth:21.3.0")
        
        // Fix for 16 KB page size support in ML Kit and CameraX
        force("com.google.mlkit:barcode-scanning:17.3.0")
        force("com.google.android.gms:play-services-mlkit-barcode-scanning:18.3.1")
        force("androidx.camera:camera-core:1.4.1")
        force("androidx.camera:camera-camera2:1.4.1")
        force("androidx.camera:camera-lifecycle:1.4.1")
        force("androidx.camera:camera-view:1.4.1")
    }
}

dependencies {
    // Import the BoM to keep all Firebase versions in sync
    implementation(platform("com.google.firebase:firebase-bom:34.8.0"))

    // Firebase Auth (No version needed if using BoM)
    implementation("com.google.firebase:firebase-auth")

    // Required for Google Sign-In fallback and GMS identification
    implementation("com.google.android.gms:play-services-auth:21.3.0")

    // NEW: Required for Google Sign-In on API 36/Android 16
    implementation("androidx.credentials:credentials:1.3.0")
    implementation("androidx.credentials:credentials-play-services-auth:1.3.0")
    implementation("com.google.android.libraries.identity.googleid:googleid:1.1.1")
    
    // NEW: Required for Android 15 Edge-to-Edge support
    implementation("androidx.activity:activity-ktx:1.10.0")
}

apply(plugin = "com.google.gms.google-services")

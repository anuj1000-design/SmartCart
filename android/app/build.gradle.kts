plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

import org.jetbrains.kotlin.gradle.dsl.JvmTarget

android {
    namespace = "com.shrs.smartcart"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    ndkPath = "C:/Users/pawar/Desktop/Shrs/SmartCart/android/ndk/28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.shrs.smartcart"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true  // Enable code shrinking and obfuscation
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),  // Default Android rules
                "proguard-rules.pro"  // Custom rules for your app
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
        allWarningsAsErrors.set(false)
        freeCompilerArgs.add("-nowarn")
    }
}

tasks.withType<JavaCompile> {
    options.compilerArgs.add("-nowarn")
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.7.0"))
    implementation("com.google.firebase:firebase-analytics")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

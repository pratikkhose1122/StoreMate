import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Google Services plugin for Firebase
    id("com.google.gms.google-services")
}

android {
    namespace = "com.StoreMate.storemate"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.StoreMate.storemate"
        // Firebase Auth requires minSdk 23
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
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Required to fix camera_android_camerax compilation error
    implementation("androidx.concurrent:concurrent-futures:1.2.0")
}

tasks.register("copyApkToGDrive") {
    doLast {
        val properties = Properties()
        val localPropertiesFile = rootProject.file("local.properties")
        if (localPropertiesFile.exists()) {
            properties.load(localPropertiesFile.inputStream())
        }
        val gDriveDirStr = properties.getProperty("gdrive.apk.dir") ?: "G:\\My Drive\\APKs"
        val gDriveDir = file(gDriveDirStr)
        
        if (!gDriveDir.exists()) {
            try {
                gDriveDir.mkdirs()
            } catch (e: Exception) {
                println("Could not create GDrive directory: ${e.message}")
            }
        }
        
        val apkFile = file("../../build/app/outputs/flutter-apk/app-release.apk")
        if (apkFile.exists()) {
            copy {
                from(apkFile)
                into(gDriveDir)
            }
            println("Successfully copied APK to ${gDriveDir.absolutePath}")
        } else {
            println("APK not found at ${apkFile.absolutePath}")
        }
    }
}

tasks.whenTaskAdded {
    if (name == "assembleRelease") {
        finalizedBy("copyApkToGDrive")
    }
}

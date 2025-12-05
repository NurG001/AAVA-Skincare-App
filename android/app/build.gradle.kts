import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.aava.aava"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // FIXED: Kotlin syntax requires 'is' prefix and '=' assignment
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.aava.aava"
        // FIXED: minSdk assignment is fine, kept at 26 as requested
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    val properties = Properties()
    properties.load(project.rootProject.file("key.properties").inputStream())

    signingConfigs {
        create("release") {
            storeFile = file(properties.getProperty("storeFile"))
            storePassword = properties.getProperty("storePassword")
            keyAlias = properties.getProperty("keyAlias")
            keyPassword = properties.getProperty("keyPassword")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release") // Apply the signing config
            isMinifyEnabled = true // Ensure R8 shrinking is enabled
            // Keep your existing proguardFiles if needed:
            // proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

// FIXED: Dependencies block using Kotlin syntax
dependencies {
    // Kotlin uses double quotes "" and parentheses ()
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
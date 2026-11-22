import java.util.Properties
import java.io.FileInputStream
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "monster.nunu.wqeeer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.14206865"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Flag to enable support for the new language APIs
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
            applicationId = "monster.nunu.wqeeer"
            // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release  {
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }

    // AGP 9 disables resValues by default; flavors use resValue for app_name.
    buildFeatures {
        resValues = true
    }

    flavorDimensions += "default"
    productFlavors {
        create("dev") {
            dimension = "default"
            resValue(
                type = "string",
                name = "app_name",
                value = "V")
            applicationIdSuffix = ".dev"
        }
        create("staging") {
            dimension = "default"
            resValue(
                type = "string",
                name = "app_name",
                value = "X")
            applicationIdSuffix = ".staging"
        }
        create("production") {
            dimension = "default"
            resValue(
                type = "string",
                name = "app_name",
                value = "努努")
            applicationIdSuffix = ""
        }
        create("apk") {
            dimension = "default"
            resValue(
                type = "string",
                name = "app_name",
                value = "努努VPN")
            applicationIdSuffix = ".apk"
        }
    }

    lint {
        disable += "NullSafeMutableLiveData"
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_11)
    }
}

flutter {
    source = "../.."
}

repositories {
    flatDir {
        dirs("../../../nunu-plugin/tm_android/android/libs")
    }
}

dependencies {
    implementation(files("../../../nunu-plugin/tm_android/android/libs/x.aar"))
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // google_mobile_ads pulls an old WorkManager; AGP 9 R8 needs a newer one
    // (or the Room keep rule in proguard-rules.pro) to start in release.
    implementation("androidx.work:work-runtime:2.11.2")
    // implementation("com.google.android.play:integrity:1.4.0")
    // implementation(name: "x", ext: "aar")
}
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

//Load the keystore properties from the key.properties file if it exists. This is used for signing the release build of the app.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val admobAppId = providers.gradleProperty("ADMOB_APP_ID").orNull
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.app.MatchIn"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

//Sing the app
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.app.MatchIn"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        // Google Play requires API 36 for app updates submitted after
        // August 31, 2026. Keep this aligned with Flutter's compile SDK.
        targetSdk = 36
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        debug {
            manifestPlaceholders["admobAppId"] =
                "ca-app-pub-3940256099942544~3347511713"
        }
        release {
            // Never produce a release artifact signed with the debug key: it
            // cannot be uploaded as a valid Play update for the published app.
            signingConfig = signingConfigs.getByName("release")
            // Supply with -PADMOB_APP_ID=<production app id> for Play builds.
            // The sample ID is intentionally restricted to debug builds.
            manifestPlaceholders["admobAppId"] = admobAppId ?: ""
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

// A missing upload key must fail the Play bundle task instead of silently
// producing an artifact signed with the debug key.
if (!keystorePropertiesFile.exists() || admobAppId.isNullOrBlank()) {
    tasks.configureEach {
        if (name == "bundleRelease") {
            doFirst {
                if (admobAppId.isNullOrBlank()) {
                    throw GradleException(
                        "Missing ADMOB_APP_ID. Set the production AdMob application ID before building the release AAB."
                    )
                }
                if (!keystorePropertiesFile.exists()) {
                    throw GradleException(
                        "Missing android/key.properties. Configure the Play upload keystore before building the release AAB."
                    )
                }
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

import java.io.FileInputStream
import java.util.Properties

// Credenciais do keystore de upload. Ficam FORA do repositório
// (`android/.gitignore` cobre key.properties, *.jks e *.keystore).
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "br.com.gabrielkozuki.contaemdia"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Permanente: é a chave que o Android usa para saber se um APK é
        // atualização ou app novo. Trocar depois de publicar obriga o usuário a
        // desinstalar (perdendo o banco local) para instalar a versão nova.
        applicationId = "br.com.gabrielkozuki.contaemdia"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Só existe quando há key.properties. Sem essa guarda, um clone do
        // repositório sem o arquivo falha ao ABRIR o projeto no Gradle, não
        // apenas ao buildar em release.
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            // Cai no debug enquanto não houver keystore, para `flutter run
            // --release` continuar funcionando. O que vai ao Play NUNCA pode
            // sair por esse caminho — confira com:
            //   apksigner verify --print-certs <apk>
            signingConfig = signingConfigs.findByName("release")
                ?: signingConfigs.getByName("debug")
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

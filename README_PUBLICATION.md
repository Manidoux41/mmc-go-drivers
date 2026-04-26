# Guide de Publication - MMC Go

Ce guide détaille les étapes nécessaires pour compiler et publier l'application **MMC Go** sur Google Play Store (Android) et l'App Store (iOS).

## 1. Pré-requis Communs
- Avoir un compte développeur [Google Play Console](https://play.google.com/console) (25$ à vie).
- Avoir un compte développeur [Apple Developer Program](https://developer.apple.com/) (99$/an).
- Avoir généré les icônes finales via la commande :
  ```bash
  flutter pub run flutter_launcher_icons
  ```

---

## 2. Publication Android (Google Play Store)

### Étape A : Générer la clé de signature (Keystore)
Si vous n'en avez pas, générez une clé pour signer l'application :
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
*Note: Conservez ce fichier précieusement. S'il est perdu, vous ne pourrez plus mettre à jour l'application.*

### Étape B : Configurer Gradle
Créez un fichier `android/key.properties` et ajoutez-y :
```properties
storePassword=<votre-mot-de-passe>
keyPassword=<votre-mot-de-passe-clé>
keyAlias=upload
storeFile=/Users/<votre-nom>/upload-keystore.jks
```

### Étape C : Compiler le App Bundle (AAB)
```bash
flutter clean
flutter build appbundle --release
```
Le fichier généré se trouve ici : `build/app/outputs/bundle/release/app-release.aab`.

### Étape D : Mise en ligne
1. Allez sur votre console Google Play.
2. Créez une nouvelle "Release".
3. Téléchargez le fichier `.aab`.

---

## 3. Publication iOS (App Store)

### Étape A : Configuration Xcode
1. Ouvrez le projet dans Xcode : `open ios/Runner.xcworkspace`.
2. Allez dans l'onglet **Signing & Capabilities**.
3. Sélectionnez votre **Team** Apple Developer.
4. Vérifiez que le **Bundle Identifier** est unique (ex: `com.mmc.godrivers`).

### Étape B : Archivage
1. Sélectionnez **Any iOS Device (arm64)** comme cible de build.
2. Dans le menu du haut, faites : **Product > Archive**.
3. Une fois terminé, la fenêtre "Organizer" s'ouvre.

### Étape C : Upload
1. Cliquez sur **Distribute App**.
2. Choisissez **App Store Connect** puis **Upload**.
3. Suivez les instructions jusqu'à la fin.

---

## 4. Gestion de la Base de Données (Post-Publication)

L'application a été conçue pour être flexible. Vous n'avez pas besoin de recompiler l'application pour changer de serveur.

1. Installez l'application sur un téléphone.
2. Sur l'écran de connexion, cliquez sur l'icône **"Configuration DB"** (engrenage).
3. Saisissez l'URL de votre base de données ou de votre API.
4. Validez. L'application communiquera désormais avec cette adresse.

---

## 5. Maintenance
- Pour changer la version : modifiez `version: 1.0.0+1` dans `pubspec.yaml`.
- Le `+1` (build number) doit augmenter à chaque nouvelle soumission sur les stores.

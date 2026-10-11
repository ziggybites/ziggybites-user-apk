# ZiggyBites — Customer App

Flutter app for ZiggyBites customers. It wraps [ziggybites.com](https://ziggybites.com/) in a native WebView and adds native features the website can't do on its own: push notifications, camera and gallery uploads, location, downloads, Google Sign-In, sharing and UPI payment app links.

| | |
|---|---|
| App name | ZiggyBites |
| Android package / iOS bundle ID | `com.ziggybites.user` |
| Website loaded | `https://ziggybites.com/` |
| API base | `https://ziggybites.com/api` |
| Version | see `version:` in `pubspec.yaml` |

## Features

- Splash screen and one-time onboarding slides
- Full-screen WebView of the ZiggyBites website (`flutter_inappwebview`)
- Push notifications via Firebase Cloud Messaging; the FCM token is registered with the backend at `/api/v1/fcm-tokens/mobile/save`
- Camera and gallery file uploads from web forms
- Location access for the website (nearby restaurants, delivery tracking)
- File downloads and opening downloaded files
- Native Google Sign-In
- Opens UPI apps (GPay, PhonePe, Paytm, BHIM…), phone, email, SMS, WhatsApp and maps links in their native apps
- Offline screen, pull to refresh, back-button handling and exit confirmation
- Light and dark theme

## Project structure

```
lib/
├── main.dart                    # App entry, Firebase init
├── config/
│   ├── app_config.dart          # App name, URLs, colours, notification channel, onboarding
│   └── theme_config.dart
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   └── webview_screen.dart      # WebView, JS handlers, URL routing, uploads, downloads
├── services/api_service.dart    # Backend API calls
├── utils/                       # Notifications, FCM background handler, permissions,
│                                # connectivity, downloads, prefs, status bar
└── widgets/                     # Exit dialog, offline screen
```

Most settings, such as URLs, app name, colours and onboarding slides, live in `lib/config/app_config.dart`.

## Getting started

Requirements: Flutter (stable channel, see `.fvmrc`), Xcode for iOS builds, Android Studio or the Android SDK for Android builds.

```bash
flutter pub get
flutter run
```

Firebase is already configured for project `ziggybites-79bfc`:
- Android: `android/app/src/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

## Release builds and signing

Signing keys are **not** stored in this repo. The release build reads them from a folder next to the repo:

```
ZiggyBites/
├── ziggybites-user-apk/     # this repo
└── signing-keys/
    └── user/
        ├── key.properties   # storePassword, keyPassword, keyAlias, storeFile
        └── ziggybites_user.jks
```

To keep the keys elsewhere, set `ZIGGYBITES_SIGNING_DIR` to the folder that holds `key.properties` and the keystore.

```bash
flutter build appbundle --release   # Play Store
flutter build apk --release
flutter build ipa --release         # iOS
```

## Security notes

- Never commit `key.properties`, `*.jks` or `*.keystore`; they are listed in `.gitignore`.
- Automatic VS Code tasks are turned off in `.vscode/settings.json`. Don't add tasks that run on folder open.
- The app only allows HTTPS traffic: cleartext is disabled on Android, and iOS uses the default App Transport Security.

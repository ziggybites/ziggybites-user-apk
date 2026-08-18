# 🌐 WebView Master App

A feature-rich Flutter WebView application that wraps any website into a beautiful native mobile app with advanced features.

## ✨ Features

- ✅ **Splash Screen** - Animated logo on app launch
- ✅ **Onboarding** - Beautiful intro slides (shown only once)
- ✅ **Full WebView** - Complete website in native app
- ✅ **File Upload** - Camera & Gallery support (works perfectly!)
- ✅ **Geolocation** - Location access for websites
- ✅ **Offline Detection** - Beautiful offline screen
- ✅ **Pull to Refresh** - Swipe down to reload
- ✅ **Back Navigation** - Smart back button handling
- ✅ **Exit Confirmation** - Animated exit dialog
- ✅ **Dark/Light Theme** - Automatic theme switching
- ✅ **All Permissions** - Camera, Location, Microphone, Photos, Notifications
- ✅ **Easy Configuration** - Change everything from one file!

## 📦 Tech Stack

```yaml
Framework: Flutter
Language: Dart
WebView: flutter_inappwebview ^6.0.0
Permissions: permission_handler ^11.0.1
Storage: shared_preferences ^2.3.2
Network: connectivity_plus ^6.0.3
```

## 🚀 Quick Start

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Configure Your App

Edit `lib/config/app_config.dart`:

```dart
// App Identity
static const String appName = 'Your App Name';
static const String logoPath = 'assets/images/logo.png';

// Colors
static const Color primaryColor = Color(0xFF6366F1);

// Website URL
static const String webUrl = 'https://yourwebsite.com';

// Onboarding
static final List<OnboardingPage> onboardingPages = [
  OnboardingPage(
    title: 'Welcome',
    description: 'Your description',
    imagePath: 'assets/onboarding/onboarding_1.png',
  ),
  // Add more pages...
];
```

### 3. Add Your Assets

Replace these files with your own:
- `assets/images/logo.png` - Your app logo
- `assets/onboarding/onboarding_1.png` - Onboarding slide 1
- `assets/onboarding/onboarding_2.png` - Onboarding slide 2
- `assets/onboarding/onboarding_3.png` - Onboarding slide 3

### 4. Run the App

```bash
flutter run
```

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (iOS 11+)

## 📂 Project Structure

```
lib/
├── config/              # App configuration & themes
│   ├── app_config.dart           # ⭐ Edit this for customization
│   └── theme_config.dart         # Light/Dark themes
├── screens/             # All app screens
│   ├── splash_screen.dart        # Initial splash screen
│   ├── onboarding_screen.dart    # Onboarding slides
│   └── webview_screen.dart       # Main WebView
├── widgets/             # Reusable UI components
│   ├── exit_dialog.dart          # Exit confirmation
│   └── offline_screen.dart       # Offline UI
└── utils/               # Helper utilities
    ├── permission_handler_util.dart
    ├── prefs_util.dart
    ├── connectivity_util.dart
    └── status_bar_util.dart
```

## 🎨 Customization

Everything can be customized from **`lib/config/app_config.dart`**:

### Change App Name
```dart
static const String appName = 'My Awesome App';
```

### Change Website URL
```dart
static const String webUrl = 'https://mywebsite.com';
```

### Change Primary Color
```dart
static const Color primaryColor = Color(0xFFFF5722); // Your color
```

### Change Splash Duration
```dart
static const int splashDurationSeconds = 3; // Seconds
```

### Change Status Bar Colors
```dart
static const Color statusBarColorLight = Color(0xFFFFFFFF);
static const Color statusBarColorDark = Color(0xFF000000);
```

### Change Exit Dialog Colors
```dart
static const Color exitDialogButtonColor = Color(0xFF6366F1);
static const double exitDialogBorderRadius = 20.0;
```

## 🔧 Key Features Explained

### File Upload (Camera & Gallery) 📷🖼️

When your website has a file input:
```html
<input type="file" accept="image/*">
```

The app automatically shows:
- 📷 Camera option
- 🖼️ Gallery option
- 📁 File browser

**No extra configuration needed! It just works!**

### Geolocation 📍

When your website requests location:
```javascript
navigator.geolocation.getCurrentPosition(success, error);
```

The app automatically:
1. Checks system permission
2. Requests if needed
3. Grants to website
4. Provides accurate location

**No "Location access denied" errors!**

### Offline Detection 🌐

The app automatically:
- Detects when internet is lost
- Shows beautiful offline screen
- Auto-reloads when back online
- Shows snackbar notifications

### Pull to Refresh 🔄

Users can pull down on the WebView to refresh the page!

### Back Navigation ⬅️

Smart back button handling:
1. If WebView has history → Navigate back in WebView
2. If at WebView start → Show exit confirmation dialog
3. User confirms → Exit app

### Console Logging 📝

All website `console.log` messages appear in Flutter logs for easy debugging:
```
🌐 Console: User logged in
🌐 Console: API call successful
```

## 🔐 Permissions

### Automatic Permission Requests

The app requests these permissions during splash:
- 📷 Camera
- 🎤 Microphone
- 📍 Location
- 🖼️ Photos
- 🔔 Notifications

### Android Permissions

All required permissions are already configured in `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<!-- ... and more -->
```

### iOS Permissions

All permission descriptions are configured in `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos</string>
<!-- ... and more -->
```

## 🧪 Testing

### Test File Upload

1. Run the app
2. Navigate to a form with file upload
3. Click the file input
4. Select Camera or Gallery
5. Upload image ✅

### Test Geolocation

1. Navigate to a page that uses location
2. Location should work automatically ✅

### Test Offline Mode

1. Turn off internet
2. App shows offline screen ✅
3. Turn on internet
4. App shows "Back online" and reloads ✅

### View Logs

```bash
# Android
adb logcat | grep -i "webview\|file\|location\|camera"

# iOS
Open Xcode → Run → View console
```

## 📚 Documentation

### Complete Documentation

See **`COMPLETE_PROJECT_DOCUMENTATION.md`** for:
- Detailed architecture explanation
- Every component explained
- Code walkthrough
- Step-by-step creation guide
- Advanced customization

### Migration Summary

See **`PACKAGE_MIGRATION_SUMMARY.md`** for:
- What changed from webview_flutter to flutter_inappwebview
- Benefits and improvements
- Feature comparison

### Permissions Guide

See **`PERMISSIONS_GUIDE.md`** for:
- Complete permission setup
- Android & iOS configuration
- Troubleshooting

## 🎯 App Flow

```
App Starts
    ↓
Splash Screen (3 seconds)
    ↓
Request Permissions
    ↓
Check if Onboarding Complete
    ↓
If No → Onboarding Screens
    ↓
    User Swipes Through
    ↓
    Clicks "Get Started"
    ↓
WebView Screen (Main Screen)
    ↓
Website Loads
    ↓
User Interacts:
- File upload → Camera/Gallery opens ✅
- Location request → Auto-granted ✅
- Back button → Navigate or exit ✅
- Pull down → Refresh ✅
- No internet → Offline screen ✅
```

## 🚨 Troubleshooting

### File Upload Not Working

**Solution**: Reinstall the app to reset permissions
```bash
adb uninstall com.webviewmasterapp
flutter run
```

### Geolocation Not Working

**Solution**: Check if location permission is granted
```bash
Settings → Apps → Your App → Permissions → Location → Allow
```

### WebView Not Loading

**Solution**: Check internet connection and URL in `app_config.dart`

### Build Errors

**Solution**: Clean and rebuild
```bash
flutter clean
flutter pub get
flutter run
```

## 🎨 Themes

### Light Theme
- White background
- Dark text
- Primary color accents

### Dark Theme
- Dark gray background (#121212)
- White text
- Primary color accents

**Themes switch automatically based on system settings!**

## 🔧 Development

### Clean Build

```bash
flutter clean
flutter pub get
flutter run
```

### Release Build (Android)

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Release Build (iOS)

```bash
flutter build ios --release
```

## 📊 Performance

- ✅ Hardware acceleration enabled
- ✅ Cache enabled for faster loading
- ✅ Optimized WebView settings
- ✅ Smooth animations (60 FPS)
- ✅ Low memory footprint

## 🎉 Why This App is Better

### vs Basic WebView Apps:

| Feature | Basic WebView | This App |
|---------|--------------|----------|
| File Upload | ❌ | ✅ Works perfectly |
| Camera | ❌ | ✅ Auto-opens |
| Gallery | ❌ | ✅ Auto-opens |
| Geolocation | ❌ Often broken | ✅ Works perfectly |
| Offline Detection | ❌ | ✅ Beautiful UI |
| Splash Screen | ❌ | ✅ Animated |
| Onboarding | ❌ | ✅ Customizable |
| Themes | ❌ | ✅ Dark/Light |
| Pull to Refresh | ❌ | ✅ Yes |
| Exit Dialog | ❌ | ✅ Animated |
| Easy Config | ❌ | ✅ One file |

## 💡 Pro Tips

1. **Test on real devices** - Camera/gallery work better than emulators
2. **Check permissions** - Ensure all permissions are granted in Settings
3. **Use console logs** - Website logs appear in Flutter logs for debugging
4. **Customize AppConfig** - Change everything from one file
5. **Update regularly** - Keep dependencies updated for bug fixes

## 🤝 Contributing

Want to improve this app? Feel free to:
1. Fork the repository
2. Make your changes
3. Submit a pull request

## 📝 License

This project is free to use and modify for your own projects.

## 📞 Support

For questions or issues:
- Check `COMPLETE_PROJECT_DOCUMENTATION.md` for detailed explanations
- Check `PERMISSIONS_GUIDE.md` for permission issues
- Check logs with `adb logcat` for debugging

## 🎊 Credits

Built with:
- Flutter & Dart
- flutter_inappwebview
- permission_handler
- shared_preferences
- connectivity_plus

---

## ⚡ Quick Commands

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Clean build
flutter clean

# Build APK
flutter build apk --release

# View logs
adb logcat | grep "🌐\|📁\|📍\|✅"
```

---

**Made with ❤️ using Flutter**

**Star ⭐ this repo if you find it helpful!**

#   j h u m r o o  
 
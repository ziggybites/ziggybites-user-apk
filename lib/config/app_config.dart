import 'package:flutter/material.dart';

/// Main Configuration Class
///
/// This is the central configuration file for the WebView Master App.
/// To customize the app for your website:
///
/// 1. CHANGE WEB URL: Update `webUrl` below (line 50)
/// 2. CHANGE APP NAME: Update `appName` below (line 6)
/// 3. CHANGE COLORS: Update `primaryColor` and theme colors (lines 9-11)
/// 4. CHANGE NOTIFICATION SETTINGS: Update notification icon and color (lines 64-69)
///
/// All settings are documented inline for easy customization.
class AppConfig {
  // ==================== APP IDENTITY ====================
  static const String appName = 'ZiggyBites';
  static const String appLogoPath = 'assets/images/logo.png';

  // ==================== COLORS & THEME ====================
  static const Color primaryColor = Color(0xFFB3B3B3); // Indigo
  static const Color secondaryColor = Color(0xFFB3B3B3); // Purple
  static const Color accentColor = Color(0xFFB3B3B3); // Pink

  // ==================== DIALOG COLORS ====================
  // Exit Dialog - Light Theme
  static const Color exitDialogBackgroundLight = Color(0xFFFFFFFF); // White
  static const Color exitDialogTitleColorLight = Color(0xFF000000); // Black
  static const Color exitDialogTextColorLight = Color(0xFF666666); // Gray
  static const Color exitDialogCancelColorLight = Color(0xFF666666); // Gray

  // Exit Dialog - Dark Theme
  static const Color exitDialogBackgroundDark = Color(0xFF1E1E1E); // Dark Gray
  static const Color exitDialogTitleColorDark = Color(0xFFFFFFFF); // White
  static const Color exitDialogTextColorDark = Color(0xFFB3B3B3); // Light Gray
  static const Color exitDialogCancelColorDark =
      Color(0xFFB3B3B3); // Light Gray

  // Exit Dialog - Common
  static const Color exitDialogButtonColor = primaryColor; // Exit button color
  static const double exitDialogBorderRadius = 20.0; // Dialog corner radius

  // ==================== STATUS BAR COLORS ====================
  // Light Theme Status Bar
  static const Color statusBarColorLight = Color(0x00000000); // Transparent
  static const Brightness statusBarIconBrightnessLight =
      Brightness.dark; // Dark icons
  static const Color navigationBarColorLight = Color(0xFFFFFFFF); // White
  static const Brightness navigationBarIconBrightnessLight = Brightness.dark;

  // Dark Theme Status Bar
  static const Color statusBarColorDark = Color(0x00000000); // Transparent
  static const Brightness statusBarIconBrightnessDark =
      Brightness.light; // Light icons
  static const Color navigationBarColorDark = Color(0xFF121212); // Dark Gray
  static const Brightness navigationBarIconBrightnessDark = Brightness.light;

  // ==================== WEB URL CONFIGURATION ====================
  // ⚠️ CHANGE THIS URL TO YOUR WEB APPLICATION ⚠️
  static const String webUrl = 'https://ziggybites.com/';

  static const String notificationIcon =
      '@mipmap/ic_launcher'; // Default app launcher icon

  // Notification color (used for Android notification LED and accent color)
  static const Color notificationColor =
      primaryColor; // Uses primary color by default

  // Notification channel ID (Android)
  static const String notificationChannelId = 'webview_notifications';

  // Notification channel name (Android)
  static const String notificationChannelName = 'WebView Notifications';

  // Notification channel description (Android)
  static const String notificationChannelDescription =
      'Notifications from the website and push notifications';

  // ==================== API CONFIGURATION ====================
  // Base URL for API endpoints (update this with your actual API base URL)
  static const String apiBaseUrl = 'https://ziggybites.com/api';
  static const String fcmTokenUrl =
      'https://ziggybites.com/api/v1/fcm-tokens/mobile/save';
//https://api.Mobasket.com/api/notification/user/token
  // ==================== SPLASH SCREEN ====================
  static const int splashDurationSeconds = 2;

  // ==================== ONBOARDING ====================
  static const List<OnboardingPage> onboardingPages = [
    OnboardingPage(
      title: 'Welcome to Mobasket',
      description: 'Experience seamless delivery with the Mobasket app.',
      imagePath: 'assets/onboarding/onboarding1.png',
    ),
    OnboardingPage(
      title: 'Feature Rich',
      description:
          'Enjoy camera, location, microphone access and many more powerful features.',
      imagePath: 'assets/onboarding/onboarding2.png',
    ),
    OnboardingPage(
      title: 'Fast & Secure',
      description:
          'Lightning-fast performance with top-notch security for your delivery needs.',
      imagePath: 'assets/onboarding/onboarding3.png',
    ),
  ];

  // ==================== PERMISSIONS ====================
  static const List<String> requiredPermissions = [
    'Camera',
    'Location',
    'Microphone',
    'Photos',
    'Notifications',
  ];

  // ==================== UI SETTINGS ====================
  static const double borderRadius = 16.0;
  static const double buttonHeight = 56.0;
  static const EdgeInsets defaultPadding = EdgeInsets.all(20.0);
}

/// Model for onboarding page data
class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

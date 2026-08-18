import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_master_app/config/app_config.dart';

/// Utility class for managing status bar styling
/// All status bar colors can be configured in AppConfig
class StatusBarUtil {
  /// Update status bar based on theme (Light/Dark)
  static void updateStatusBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: isDark
            ? AppConfig.statusBarColorDark
            : AppConfig.statusBarColorLight,
        statusBarIconBrightness: isDark
            ? AppConfig.statusBarIconBrightnessDark
            : AppConfig.statusBarIconBrightnessLight,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDark
            ? AppConfig.navigationBarColorDark
            : AppConfig.navigationBarColorLight,
        systemNavigationBarIconBrightness: isDark
            ? AppConfig.navigationBarIconBrightnessDark
            : AppConfig.navigationBarIconBrightnessLight,
      ),
    );
  }

  /// Set status bar for splash screen (always light icons on gradient)
  static void setSplashStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  /// Set status bar for light theme
  static void setLightStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
     const SystemUiOverlayStyle(
        statusBarColor: AppConfig.statusBarColorLight,
        statusBarIconBrightness: AppConfig.statusBarIconBrightnessLight,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppConfig.navigationBarColorLight,
        systemNavigationBarIconBrightness:
            AppConfig.navigationBarIconBrightnessLight,
      ),
    );
  }

  /// Set status bar for dark theme
  static void setDarkStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppConfig.statusBarColorDark,
        statusBarIconBrightness: AppConfig.statusBarIconBrightnessDark,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppConfig.navigationBarColorDark,
        systemNavigationBarIconBrightness:
            AppConfig.navigationBarIconBrightnessDark,
      ),
    );
  }
}

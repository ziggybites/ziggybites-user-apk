import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:webview_master_app/config/app_config.dart';
import 'package:webview_master_app/utils/prefs_util.dart';
import 'package:webview_master_app/utils/status_bar_util.dart';
import 'package:webview_master_app/utils/permission_handler_util.dart';
import 'package:webview_master_app/utils/notification_service.dart';

import 'package:webview_master_app/screens/webview_screen.dart';

/// Splash Screen - Shows logo and app name for configured duration
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late AnimationController _backgroundController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateAfterDelay();
  }

  void _setupAnimations() {
    // Entrance Animation (Fade + Scale)
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    // Pulse Animation (Heartbeat) - Repeats
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Background Animation (Floating)
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    // Start Animations
    _entranceController.forward().then((_) {
      _pulseController.repeat(reverse: true);
    });
  }

  Future<void> _navigateAfterDelay() async {
    // Total duration slightly longer than animation to enjoy the view
    await Future.delayed(
      const Duration(seconds: AppConfig.splashDurationSeconds + 1),
    );

    if (!mounted) return;

    // Request permissions early for better UX
    await _requestInitialPermissions();

    // Navigate directly to WebViewScreen
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const WebViewScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  /// Request initial permissions during splash
  Future<void> _requestInitialPermissions() async {
    if (!mounted) return;
    try {
      await PermissionHandlerUtil.requestAllPermissions();
    } catch (e) {
      debugPrint('Initial permission request: $e');
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI to immersive/transparent with light content
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Light icons for dark bg
        statusBarBrightness: Brightness.dark, // for iOS
        systemNavigationBarColor: Color(0xFFB3B3B3), // Dark nav bar
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          // 1. Deep Navy Gradient Background
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
          ),

          // 2. Animated Floating Soft Glows
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Stack(
                children: [
                  // Pink Abstract Shape (Top Left)
                  Positioned(
                    top: -100 + (_backgroundController.value * 20),
                    left: -50 + (_backgroundController.value * 10),
                    child: Opacity(
                      opacity: 0.15,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color(0xFFB3B3B3), // Accent Pink
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Cyan/Teal Abstract Shape (Bottom Right)
                  Positioned(
                    bottom: -80 - (_backgroundController.value * 20),
                    right: -40 - (_backgroundController.value * 10),
                    child: Opacity(
                      opacity: 0.1,
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color(0xFFB3B3B3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // 3. Central Content (Logo + Text)
          Center(
            child: AnimatedBuilder(
              animation:
                  Listenable.merge([_entranceController, _pulseController]),
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    // Combined scale from entrance and pulse
                    scale: _scaleAnimation.value * _pulseAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Card/Container for Logo
                        // Container(
                        //   width: 180,
                        //   height: 180,
                        //   padding: const EdgeInsets.all(28),
                        //   decoration: BoxDecoration(
                        //     shape: BoxShape.circle,
                        //     color: const Color.fromARGB(255, 235, 235, 235),
                        //     boxShadow: [
                        //       BoxShadow(
                        //         color: Colors.black.withOpacity(0.2),
                        //         blurRadius: 30,
                        //         offset: const Offset(0, 10),
                        //       ),
                        //       BoxShadow(
                        //         color: const Color.fromARGB(254, 254, 254, 254)
                        //             .withOpacity(0.3),
                        //         blurRadius: 50,
                        //         spreadRadius: -10,
                        //         offset: const Offset(0, 0),
                        //       ),
                        //     ],
                        //   ),
                        //   // Display Logo
                        //   child: Image.asset(
                        //     AppConfig.appLogoPath,
                        //     fit: BoxFit.contain,
                        //   ),
                        // ),
                        Image.asset(
                          AppConfig.appLogoPath,
                          width: 140,
                          height: 140,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 30),
                        // Typography
                        const Text(
                          AppConfig.appName,
                          style: TextStyle(
                            fontFamily:
                                'Inter', // Fallback to default if not available
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4.0, // Increased spacing
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:webview_master_app/services/api_service.dart';
import 'package:webview_master_app/config/app_config.dart';
import 'dart:io' show Platform;

/// Notification Service - Handles system tray notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  FirebaseMessaging? _firebaseMessaging;

  bool _isInitialized = false;

  // Track shown notifications to prevent duplicates
  final Set<String> _shownNotificationIds = <String>{};
  final Map<String, DateTime> _notificationTimestamps = <String, DateTime>{};

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings(AppConfig.notificationIcon);

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    await _createNotificationChannel();

    // Initialize Firebase Messaging
    await _initializeFirebaseMessaging();

    _isInitialized = true;
    debugPrint('✅ Notification service initialized');
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> _initializeFirebaseMessaging() async {
    try {
      _firebaseMessaging = FirebaseMessaging.instance;

      // Request notification permission for iOS (Android permissions handled via PermissionHandler)
      if (Platform.isIOS) {
        // Allow iOS system to present alerts, badges, and sounds in foreground
        await _firebaseMessaging!.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        NotificationSettings settings =
            await _firebaseMessaging!.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          debugPrint('✅ Firebase notification permission granted (iOS)');
        } else if (settings.authorizationStatus ==
            AuthorizationStatus.provisional) {
          debugPrint(
              '⚠️ Firebase notification permission granted provisionally (iOS)');
        } else {
          debugPrint('❌ Firebase notification permission denied (iOS)');
        }

        try {
          String? apnsToken = await _firebaseMessaging!.getAPNSToken();
          debugPrint('📱 APNs Token: $apnsToken');
        } catch (e) {
          debugPrint('⚠️ Error getting APNs token: $e');
        }
      }

      // Get FCM token
      String? token = await _firebaseMessaging!.getToken();
      if (token != null) {
        debugPrint('📱 FCM Token: $token');
      } else {
        debugPrint('⚠️ FCM Token is null');
      }

      // Listen for token refresh
      _firebaseMessaging!.onTokenRefresh.listen((newToken) {
        debugPrint('🔄 FCM Token refreshed: $newToken');
      });

      // Configure foreground message handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('📨 Foreground FCM message received: ${message.messageId}');
        _handleForegroundMessage(message);
      });

      // Handle notification tap when app is opened from terminated state
      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        if (message != null) {
          debugPrint('📨 App opened from notification: ${message.messageId}');
        }
      });

      debugPrint('✅ Firebase Messaging initialized');
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing Firebase Messaging: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      // Continue even if Firebase fails - local notifications will still work
    }
  }

  /// Handle foreground FCM messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📨 Foreground message received: ${message.messageId}');
    debugPrint('📨 Message data: ${message.data}');

    RemoteNotification? notification = message.notification;
    Map<String, dynamic>? data = message.data;

    // Create unique ID for this notification
    String notificationId = message.messageId ?? '';

    // Clean old notification IDs (older than 5 minutes)
    _cleanOldNotificationIds();

    if (notification != null) {
      debugPrint('📨 Notification title: ${notification.title}');
      debugPrint('📨 Notification body: ${notification.body}');

      if (Platform.isIOS) {
        debugPrint(
            '📱 iOS automatically presents FCM notification payload via setForegroundNotificationPresentationOptions. Skipping duplicate local notification display.');
        return;
      }

      // Create a unique ID - use messageId if available, otherwise create from content
      final String uniqueId = notificationId.isNotEmpty
          ? notificationId
          : '${notification.title}_${notification.body}_${message.sentTime?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch}';

      // Check if this notification was already shown (prevent duplicates)
      if (_shownNotificationIds.contains(uniqueId)) {
        debugPrint('⚠️ Duplicate notification detected, skipping: $uniqueId');
        return;
      }

      // Mark as shown
      _shownNotificationIds.add(uniqueId);
      _notificationTimestamps[uniqueId] = DateTime.now();

      // Ensure notification service is initialized
      if (!_isInitialized) {
        await initialize();
      }

      // Request permission if not granted
      if (!await Permission.notification.isGranted) {
        debugPrint('⚠️ Notification permission not granted, requesting...');
        final granted = await requestPermission();
        if (!granted) {
          debugPrint(
              '❌ Notification permission denied, cannot show notification');
          return;
        }
      }

      // Show notification
      await showNotification(
        title: notification.title ?? 'Notification',
        body: notification.body ?? '',
        payload: data.toString(),
        imageUrl: notification.android?.imageUrl ??
            notification.apple?.imageUrl?.toString(),
        notificationId: uniqueId,
      );
    } else if (data.isNotEmpty) {
      // Handle data-only messages
      debugPrint('📨 Data-only message received');
      final title = data['title']?.toString() ?? 'Notification';
      final body =
          data['body']?.toString() ?? data['message']?.toString() ?? '';

      // Create unique ID for data-only messages
      final String uniqueId = notificationId.isNotEmpty
          ? notificationId
          : '${title}_${body}_${message.sentTime?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch}';

      // Check for duplicates
      if (_shownNotificationIds.contains(uniqueId)) {
        debugPrint(
            '⚠️ Duplicate data-only notification detected, skipping: $uniqueId');
        return;
      }

      // Mark as shown
      _shownNotificationIds.add(uniqueId);
      _notificationTimestamps[uniqueId] = DateTime.now();

      if (!_isInitialized) {
        await initialize();
      }

      if (!await Permission.notification.isGranted) {
        await requestPermission();
      }

      await showNotification(
        title: title,
        body: body,
        payload: data.toString(),
        notificationId: uniqueId,
      );
    }
  }

  /// Clean old notification IDs to prevent memory buildup
  void _cleanOldNotificationIds() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    _notificationTimestamps.forEach((id, timestamp) {
      if (now.difference(timestamp).inMinutes > 5) {
        keysToRemove.add(id);
      }
    });

    for (final id in keysToRemove) {
      _shownNotificationIds.remove(id);
      _notificationTimestamps.remove(id);
    }
  }

  /// Get FCM token
  Future<String?> getFCMToken() async {
    if (_firebaseMessaging == null) {
      await _initializeFirebaseMessaging();
    }
    return await _firebaseMessaging?.getToken();
  }

  Future<bool> saveFCMTokenToBackend({
    required String phone,
    String? platform,
  }) async {
    try {
      // Get FCM token
      final token = await getFCMToken();

      if (token == null || token.isEmpty) {
        debugPrint('❌ Cannot save FCM token: Token is null or empty');
        return false;
      }

      // Save to backend via API service
      final success = await ApiService().saveFCMToken(
        token: token,
        phone: phone,
        platform: platform,
      );

      if (success) {
        debugPrint('✅ FCM token saved to backend successfully');
      } else {
        debugPrint('❌ Failed to save FCM token to backend');
      }

      return success;
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving FCM token to backend: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      return false;
    }
  }

  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    try {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        AppConfig.notificationChannelId,
        AppConfig.notificationChannelName,
        description: AppConfig.notificationChannelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
        enableLights: true,
        ledColor: AppConfig.notificationColor,
      );

      final androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(channel);
        debugPrint(
            '✅ Notification channel created: ${AppConfig.notificationChannelId}');
        debugPrint('   Channel importance: ${channel.importance}');
        debugPrint('   Channel color: ${AppConfig.notificationColor}');
      } else {
        debugPrint('⚠️ Android notification plugin not available');
      }
    } catch (e) {
      debugPrint('❌ Error creating notification channel: $e');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📱 Notification tapped: ${response.payload}');
  }

  /// Check if application has notification permission cross-platform
  Future<bool> hasNotificationPermission() async {
    if (Platform.isIOS) {
      if (_firebaseMessaging == null) {
        _firebaseMessaging = FirebaseMessaging.instance;
      }
      final settings = await _firebaseMessaging!.getNotificationSettings();
      final isAuthorized = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (isAuthorized) return true;
    }
    final status = await Permission.notification.status;
    return status.isGranted || status.isProvisional;
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    try {
      // Check current permission status
      final currentStatus = await Permission.notification.status;
      debugPrint('🔔 Current notification permission status: $currentStatus');

      if (currentStatus.isGranted) {
        debugPrint('✅ Notification permission already granted');
        return true;
      }

      // For Android 13+, request permission
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        debugPrint('🔔 Permission request result: $status');

        if (status.isGranted) {
          debugPrint('✅ Notification permission granted');
          return true;
        } else if (status.isPermanentlyDenied) {
          debugPrint('❌ Notification permission permanently denied');
          debugPrint('⚠️ User needs to enable notifications in app settings');
        } else {
          debugPrint('❌ Notification permission denied');
        }
        return status.isGranted;
      }

      // For iOS, permissions are handled by Firebase
      return currentStatus.isGranted;
    } catch (e) {
      debugPrint('❌ Error requesting notification permission: $e');
      return false;
    }
  }

  /// Show notification in system tray
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
    String? notificationId,
  }) async {
    debugPrint('🔔 showNotification called - Title: "$title", Body: "$body"');

    if (!_isInitialized) {
      debugPrint('⚠️ Service not initialized, initializing now...');
      await initialize();
    }

    // Check permission
    final hasPermission = await Permission.notification.isGranted;
    debugPrint('🔔 Permission status: $hasPermission');

    if (!hasPermission) {
      debugPrint('❌ Notification permission not granted');
      debugPrint('⚠️ Requesting notification permission...');
      final granted = await requestPermission();
      if (!granted) {
        debugPrint('❌ Cannot show notification - permission denied');
        debugPrint('⚠️ Please enable notifications in Android Settings');
        return;
      }
    }

    // Generate notification ID - use provided ID or create one based on content
    // This ensures duplicate notifications with same content use same ID and replace each other
    final int localNotificationId;
    if (notificationId != null && notificationId.isNotEmpty) {
      // Use hash of the notification ID for consistent integer ID
      localNotificationId = notificationId.hashCode.abs() % 2147483647;
    } else {
      // Fallback: create ID based on title and body to prevent duplicates of same content
      final contentId = '${title}_$body';
      localNotificationId = contentId.hashCode.abs() % 2147483647;
    }

    // Android notification details
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      AppConfig.notificationChannelId, // Must match channel ID
      AppConfig.notificationChannelName, // Must match channel name
      channelDescription: AppConfig.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: AppConfig.notificationIcon,
      showWhen: true,
      styleInformation: const BigTextStyleInformation(''),
      color: AppConfig.notificationColor,
    );

    // iOS notification details
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Combined notification details
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Show the notification
    try {
      await _notificationsPlugin.show(
        localNotificationId,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
      debugPrint(
          '✅ Notification displayed successfully - ID: $localNotificationId');
    } catch (e, stackTrace) {
      debugPrint('❌ Error showing notification: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }
}

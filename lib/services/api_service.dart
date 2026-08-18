import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:webview_master_app/config/app_config.dart';
import 'package:webview_master_app/utils/prefs_util.dart';
import 'dart:io' show Platform;

/// API Service - Handles all API calls to the backend
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Get the full API URL for an endpoint
  String _getApiUrl(String endpoint) {
    // Remove leading slash if present to avoid double slashes
    final cleanEndpoint =
        endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return '${AppConfig.apiBaseUrl}$cleanEndpoint';
  }

  /// Save FCM token to backend
  ///
  /// [token] - The FCM token to save
  /// [phone] - Phone number (10-digit without +91)
  /// [platform] - Platform identifier (defaults to "android" for Android)
  ///
  /// Returns true if successful, false otherwise
  Future<bool> saveFCMToken({
    required String token,
    required String phone,
    String? platform,
  }) async {
    try {
      // Determine platform if not provided
      final platformValue = platform ?? (Platform.isAndroid ? 'android' : 'ios');

      // Validate phone number (should be 10 digits)
      if (phone.length != 10 || !RegExp(r'^\d{10}$').hasMatch(phone)) {
        debugPrint(
            '❌ Invalid phone number format. Expected 10 digits, got: $phone');
        return false;
      }
      final url = AppConfig.fcmTokenUrl;
      
      final requestBody = {
        'token': token,
        'platform': platformValue,
      };

      // Validate token
      if (token.isEmpty) {
        debugPrint('❌ FCM token is empty');
        return false;
      }

      // Get access token
      String? accessToken = PrefsUtil.getAccessToken();
      if (accessToken == null) {
        debugPrint('⚠️ Access token not found. Cannot save FCM token.');
        return false;
      }

      debugPrint('📤 Saving FCM token to: $url');
      debugPrint('📤 Request Body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('❌ Request timeout while saving FCM token');
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ FCM token saved successfully');
        return true;
      } else {
        debugPrint(
            '❌ Failed to save FCM token. Status: ${response.statusCode}');
        debugPrint('❌ Error: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving FCM token: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      return false;
    }
  }
}

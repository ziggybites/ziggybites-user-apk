import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Utility class for checking network connectivity
class ConnectivityUtil {
  static final Connectivity _connectivity = Connectivity();

  /// Check if device is connected to internet
  static Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();

      // Check if connected to mobile or wifi
      if (result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.ethernet)) {
        return true;
      }

      return false;
    } catch (e) {
      // If there's an error checking connectivity, assume not connected
      return false;
    }
  }

  /// Listen to connectivity changes
  static Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }

  /// Check if result indicates connection
  static bool isConnectivityResultConnected(List<ConnectivityResult> results) {
    return results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }
}

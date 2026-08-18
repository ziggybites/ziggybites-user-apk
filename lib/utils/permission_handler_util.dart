import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Utility class for handling app permissions
class PermissionHandlerUtil {
  /// Request all necessary permissions at once
  static Future<bool> requestAllPermissions() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.microphone,
        Permission.location,
        Permission.photos,
        Permission.notification,
        Permission.storage,
      ].request();

      // Check if all permissions are granted
      bool allGranted = statuses.values.every((status) => status.isGranted);

      // Log permission statuses for debugging
      statuses.forEach((permission, status) {
        debugPrint('Permission ${permission.toString()}: ${status.toString()}');
      });

      return allGranted;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

  /// Request individual permission
  static Future<bool> requestPermission(Permission permission) async {
    final status = await permission.request();
    return status.isGranted;
  }

  /// Check if a specific permission is granted
  static Future<bool> isPermissionGranted(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  /// Check camera permission
  static Future<bool> checkCameraPermission() async {
    return await isPermissionGranted(Permission.camera);
  }

  /// Check microphone permission
  static Future<bool> checkMicrophonePermission() async {
    return await isPermissionGranted(Permission.microphone);
  }

  /// Check location permission
  static Future<bool> checkLocationPermission() async {
    return await isPermissionGranted(Permission.location);
  }

  /// Check photos permission
  static Future<bool> checkPhotosPermission() async {
    return await isPermissionGranted(Permission.photos);
  }

  /// Check notification permission
  static Future<bool> checkNotificationPermission() async {
    return await isPermissionGranted(Permission.notification);
  }

  /// Check storage permission
  static Future<bool> checkStoragePermission() async {
    final status = await Permission.storage.status;
    if (status.isGranted) {
      return true;
    }

    // Also check for manageExternalStorage (Android 11+)
    if (await Permission.manageExternalStorage.status.isGranted) {
      return true;
    }

    return false;
  }

  /// Request storage permission
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      return true;
    }

    // Try requesting manageExternalStorage if storage failed?
    // NOTE: This usually opens a full screen intent, use with caution.
    // For now we just return the storage request result.
    return false;
  }

  /// Show permission rationale dialog
  static void showPermissionRationale(
      BuildContext context, String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionName Permission Required'),
        content: Text(
          'This app needs $permissionName permission to function properly. '
          'Please grant the permission in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Request permissions with dialog on denial
  static Future<void> requestPermissionsWithDialog(BuildContext context) async {
    final permissions = {
      Permission.camera: 'Camera',
      Permission.microphone: 'Microphone',
      Permission.location: 'Location',
      Permission.photos: 'Photos',
      Permission.notification: 'Notification',
      Permission.storage: 'Storage',
    };

    for (var entry in permissions.entries) {
      final status = await entry.key.status;

      if (status.isDenied) {
        final result = await entry.key.request();

        if (result.isPermanentlyDenied && context.mounted) {
          showPermissionRationale(context, entry.value);
        }
      }
    }
  }
}

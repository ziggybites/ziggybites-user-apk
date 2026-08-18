import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_master_app/utils/permission_handler_util.dart';
import 'package:open_file/open_file.dart';

/// Service for handling file downloads from WebView
class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Dio _dio = Dio();

  /// Supported file extensions
  static const List<String> supportedExtensions = [
    'pdf',
    'zip',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'txt',
    'jpg',
    'jpeg',
    'png',
    'gif',
    'mp4',
    'mp3',
    'csv',
    'html',
    'htm',
  ];

  /// Check if file extension is supported
  /// Returns true if extension is in supported list, or if URL doesn't have an extension (allow all)
  bool isSupportedFile(String url) {
    try {
      // Blob URLs are always supported
      if (url.startsWith('blob:')) {
        return true;
      }

      final uri = Uri.parse(url);
      final path = uri.path.toLowerCase();

      // If no extension, allow download
      if (!path.contains('.')) {
        return true;
      }

      final extension = path.split('.').last;

      // If extension is empty, allow download
      if (extension.isEmpty) {
        return true;
      }

      // Check if in supported list
      return supportedExtensions.contains(extension);
    } catch (e) {
      debugPrint('Error checking file support: $e');
      // On error, allow download anyway
      return true;
    }
  }

  /// Extract filename from URL or Content-Disposition header
  String extractFilename(String url, String? contentDisposition) {
    String? filename;

    // Try to extract from Content-Disposition header
    if (contentDisposition != null && contentDisposition.isNotEmpty) {
      // Handle: Content-Disposition: attachment; filename="invoice.pdf"
      // Handle: Content-Disposition: attachment; filename*=UTF-8''invoice.pdf
      try {
        // Try to find filename= or filename*=
        final filenamePattern = RegExp(
          r'filename\*?=([^;]+)',
          caseSensitive: false,
        );
        final match = filenamePattern.firstMatch(contentDisposition);
        if (match != null && match.groupCount > 0) {
          filename = match.group(1);
          if (filename != null) {
            // Remove quotes and whitespace
            filename = filename.trim();
            if (filename.startsWith('"') && filename.endsWith('"')) {
              filename = filename.substring(1, filename.length - 1);
            } else if (filename.startsWith("'") && filename.endsWith("'")) {
              filename = filename.substring(1, filename.length - 1);
            }
            // Handle filename*=UTF-8''encoded-name format
            if (filename.contains("''")) {
              final parts = filename.split("''");
              if (parts.length > 1) {
                filename = parts.sublist(1).join("''");
              }
            }
            // Decode URL-encoded filename
            try {
              filename = Uri.decodeComponent(filename);
            } catch (e) {
              debugPrint('Error decoding filename: $e');
            }
          }
        }
      } catch (e) {
        debugPrint('Error parsing Content-Disposition: $e');
      }
    }

    // Fallback to URL path
    if (filename == null || filename.isEmpty) {
      try {
        final uri = Uri.parse(url);
        final path = uri.path;
        if (path.isNotEmpty) {
          filename = path.split('/').last;
          // Remove query parameters if any
          if (filename.contains('?')) {
            filename = filename.split('?').first;
          }
        }
      } catch (e) {
        debugPrint('Error extracting filename from URL: $e');
      }
    }

    // Final fallback
    if (filename == null || filename.isEmpty) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      filename = 'download_$timestamp';
    }

    // Sanitize filename (remove invalid characters)
    filename = filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

    return filename;
  }

  /// Get download directory
  /// Uses app-specific directories to comply with Google Play scoped storage requirements
  Future<Directory> getDownloadDirectory(
      {bool usePublicDownloads = false}) async {
    if (Platform.isAndroid) {
      // For receipts, try to use public Downloads folder if requested
      if (usePublicDownloads) {
        try {
          // Try to access public Downloads folder
          // Path: /storage/emulated/0/Download
          final publicDownloadsPaths = [
            '/storage/emulated/0/Download',
            '/sdcard/Download',
            '/storage/sdcard0/Download',
          ];

          for (final path in publicDownloadsPaths) {
            try {
              final directory = Directory(path);
              if (await directory.exists()) {
                debugPrint('✅ Using public Downloads directory: $path');
                return directory;
              }
            } catch (e) {
              debugPrint('⚠️ Could not access $path: $e');
            }
          }

          // Try to get from external storage and navigate to Downloads
          try {
            final externalDir = await getExternalStorageDirectory();
            if (externalDir != null) {
              final externalPath = externalDir.path;
              // Navigate from app-specific directory to public Downloads
              // External storage is usually at /storage/emulated/0/Android/data/package/files
              // We need to go to /storage/emulated/0/Download
              if (externalPath.contains('/Android/data/')) {
                final basePath = externalPath.split('/Android/data/').first;
                final downloadDir = Directory('$basePath/Download');
                if (await downloadDir.exists()) {
                  debugPrint(
                      '✅ Using public Downloads directory: ${downloadDir.path}');
                  return downloadDir;
                }
                // Try to create if it doesn't exist
                try {
                  await downloadDir.create(recursive: true);
                  debugPrint(
                      '✅ Created public Downloads directory: ${downloadDir.path}');
                  return downloadDir;
                } catch (e) {
                  debugPrint('⚠️ Could not create public Downloads: $e');
                }
              }
            }
          } catch (e) {
            debugPrint('⚠️ Error accessing public Downloads: $e');
          }
        } catch (e) {
          debugPrint('⚠️ Error getting public Downloads directory: $e');
        }
      }

      // Use app-specific external storage directory (doesn't require MANAGE_EXTERNAL_STORAGE)
      // This directory is accessible without special permissions and is scoped to the app
      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          // Create a Downloads subdirectory within app's external storage
          final downloadDir = Directory('${externalDir.path}/Downloads');
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
            debugPrint(
                '✅ Created app Downloads directory: ${downloadDir.path}');
          } else {
            debugPrint('✅ Using app Downloads directory: ${downloadDir.path}');
          }
          return downloadDir;
        }
      } catch (e) {
        debugPrint('⚠️ Error getting external storage directory: $e');
      }

      // Fallback to app documents directory
      debugPrint('⚠️ Falling back to app documents directory');
      final appDocDir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${appDocDir.path}/Downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir;
    } else if (Platform.isIOS) {
      // iOS uses app documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${appDocDir.path}/Downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir;
    }
    // Fallback
    final appDocDir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${appDocDir.path}/Downloads');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir;
  }

  /// Request storage permission
  /// For Android 10+ (API 29+), app-specific directories don't require permission
  /// Permission is only needed for public Downloads folder access
  Future<bool> requestStoragePermission(
      {bool requirePublicAccess = false}) async {
    try {
      // For Android 10+, app-specific directories are accessible without permission
      // Only check permission if we need public Downloads folder access
      if (Platform.isAndroid && !requirePublicAccess) {
        debugPrint(
            '✅ Android 10+: App-specific directory access doesn\'t require permission');
        return true; // Allow download to app-specific directory
      }

      final hasPermission =
          await PermissionHandlerUtil.checkStoragePermission();
      if (hasPermission) {
        return true;
      }

      debugPrint('📥 Requesting storage permission...');
      final granted = await PermissionHandlerUtil.requestStoragePermission();

      if (!granted) {
        debugPrint('❌ Storage permission denied');
      }

      return granted;
    } catch (e) {
      debugPrint('❌ Error requesting storage permission: $e');
      // For app-specific directories, allow download even if permission check fails
      if (Platform.isAndroid && !requirePublicAccess) {
        debugPrint(
            '⚠️ Permission check failed, but allowing download to app-specific directory');
        return true;
      }
      return false;
    }
  }

  /// Download file from URL (supports GET and POST)
  Future<DownloadResult> downloadFile({
    required String url,
    String? contentDisposition,
    required BuildContext context,
    Function(int received, int total)? onProgress,
    String? method,
    Map<String, String>? headers,
    dynamic body,
    bool usePublicDownloads =
        false, // For receipts, use public Downloads folder
  }) async {
    try {
      debugPrint('📥 Starting download: $url');

      // Check storage permission (only required for public Downloads folder)
      // For app-specific directories, permission is not required on Android 10+
      final hasPermission = await requestStoragePermission(
        requirePublicAccess: usePublicDownloads,
      );
      if (!hasPermission && usePublicDownloads) {
        // Only fail if we specifically need public Downloads access
        return DownloadResult(
          success: false,
          error:
              'Storage permission denied. File will be saved to app Downloads folder instead.',
          filePath: null,
        );
      }

      // If permission denied but we can use app-specific directory, continue
      if (!hasPermission && !usePublicDownloads) {
        debugPrint(
            '⚠️ Permission not granted, but using app-specific directory (no permission needed)');
      }

      // Get download directory (use public Downloads for receipts)
      final downloadDir =
          await getDownloadDirectory(usePublicDownloads: usePublicDownloads);

      // First, make a HEAD request to get headers (including Content-Disposition)
      String? finalContentDisposition = contentDisposition;
      String? finalFilename;

      try {
        final headResponse = await _dio.head(
          url,
          options: Options(
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36',
            },
            followRedirects: true,
            validateStatus: (status) => status! < 500,
          ),
        );

        // Extract Content-Disposition from response headers
        final headers = headResponse.headers;
        finalContentDisposition = headers.value('content-disposition') ??
            headers.value('Content-Disposition');

        debugPrint('📋 Content-Disposition: $finalContentDisposition');
      } catch (e) {
        debugPrint('⚠️ Could not fetch headers: $e');
        // Continue with download anyway
      }

      // Extract filename - prefer Content-Disposition, then use provided filename
      if (contentDisposition != null && contentDisposition.isNotEmpty) {
        finalFilename = extractFilename(url, contentDisposition);
      } else {
        // Try to extract from URL or use a default
        finalFilename = extractFilename(url, null);
      }
      debugPrint('📄 Filename: $finalFilename');

      final filePath = '${downloadDir.path}/$finalFilename';
      debugPrint('💾 Saving to: $filePath');

      // Prepare headers
      final requestHeaders = <String, dynamic>{
        'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36',
      };
      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      // Download file (support both GET and POST)
      final requestMethod = method?.toUpperCase() ?? 'GET';

      if (requestMethod == 'POST') {
        // For POST requests, we need to get the response first, then save it
        final response = await _dio.post(
          url,
          data: body,
          options: Options(
            headers: requestHeaders,
            followRedirects: true,
            validateStatus: (status) => status! < 500,
            responseType: ResponseType.bytes,
          ),
        );

        // Save response bytes to file
        final file = File(filePath);
        await file.writeAsBytes(response.data as List<int>);

        if (onProgress != null && response.data != null) {
          final data = response.data as List<int>;
          onProgress(data.length, data.length);
        }
      } else {
        // For GET requests, use download method
        await _dio.download(
          url,
          filePath,
          onReceiveProgress: (received, total) {
            if (onProgress != null && total > 0) {
              onProgress(received, total);
            }
          },
          options: Options(
            headers: requestHeaders,
            followRedirects: true,
            validateStatus: (status) => status! < 500,
          ),
        );
      }

      // Verify file was downloaded
      final file = File(filePath);
      if (await file.exists()) {
        final fileSize = await file.length();
        debugPrint('✅ Download successful: $filePath (\${fileSize} bytes)');

        // For Android, try to add file to MediaStore to make it visible in Downloads
        if (Platform.isAndroid && usePublicDownloads) {
          try {
            // Determine MIME type from filename or URL
            String fileMimeType = 'application/octet-stream';
            final lowerFilename = finalFilename.toLowerCase();
            if (lowerFilename.endsWith('.pdf')) {
              fileMimeType = 'application/pdf';
            } else if (lowerFilename.endsWith('.jpg') ||
                lowerFilename.endsWith('.jpeg')) {
              fileMimeType = 'image/jpeg';
            } else if (lowerFilename.endsWith('.png')) {
              fileMimeType = 'image/png';
            } else if (lowerFilename.endsWith('.doc') ||
                lowerFilename.endsWith('.docx')) {
              fileMimeType = 'application/msword';
            } else if (lowerFilename.endsWith('.xls') ||
                lowerFilename.endsWith('.xlsx')) {
              fileMimeType = 'application/vnd.ms-excel';
            } else if (lowerFilename.endsWith('.zip')) {
              fileMimeType = 'application/zip';
            }
            await addFileToMediaStore(filePath, finalFilename, fileMimeType);
          } catch (e) {
            debugPrint('⚠️ Could not add file to MediaStore: $e');
            // Continue anyway - file is saved, just might not be visible in Downloads
          }
        }

        return DownloadResult(
          success: true,
          error: null,
          filePath: filePath,
          filename: finalFilename,
          fileSize: fileSize,
        );
      } else {
        return DownloadResult(
          success: false,
          error: 'File was not saved correctly',
          filePath: null,
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ Download error: ${e.message}');
      String errorMessage = 'Download failed';

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMessage = 'Server error: ${e.response?.statusCode}';
      } else if (e.response != null) {
        errorMessage = 'Download failed: ${e.response?.statusCode}';
      } else {
        errorMessage = 'Download failed: ${e.message ?? "Unknown error"}';
      }

      return DownloadResult(
        success: false,
        error: errorMessage,
        filePath: null,
      );
    } catch (e) {
      debugPrint('❌ Unexpected download error: $e');
      return DownloadResult(
        success: false,
        error: 'Unexpected error: $e',
        filePath: null,
      );
    }
  }

  /// Open downloaded file
  Future<bool> openFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      return result.type == ResultType.done;
    } catch (e) {
      debugPrint('❌ Error opening file: $e');
      return false;
    }
  }

  /// Add file to MediaStore to make it visible in Downloads (Android 10+)
  Future<void> addFileToMediaStore(
      String filePath, String filename, String? mimeType) async {
    if (!Platform.isAndroid) return;

    try {
      const platform = MethodChannel('com.dadexpress.delivery/downloads');
      final result = await platform.invokeMethod('addToDownloads', {
        'filePath': filePath,
        'fileName': filename,
        'mimeType': mimeType ?? 'application/pdf',
      });
      debugPrint('✅ File added to MediaStore: $result');
    } on PlatformException catch (e) {
      debugPrint('❌ Error adding to MediaStore: ${e.message}');
      // If platform channel doesn't exist, try alternative method
      await _copyToPublicDownloads(filePath, filename);
    } catch (e) {
      debugPrint('❌ Error in MediaStore: $e');
      // Fallback to copying to public Downloads
      await _copyToPublicDownloads(filePath, filename);
    }
  }

  /// Fallback: Copy file to public Downloads folder
  Future<void> _copyToPublicDownloads(
      String sourcePath, String filename) async {
    try {
      // Try to copy to public Downloads
      final publicDownloadsPaths = [
        '/storage/emulated/0/Download',
        '/sdcard/Download',
      ];

      for (final path in publicDownloadsPaths) {
        try {
          final downloadDir = Directory(path);
          if (await downloadDir.exists()) {
            final destFile = File('$path/$filename');
            final sourceFile = File(sourcePath);
            if (await sourceFile.exists()) {
              await sourceFile.copy(destFile.path);
              debugPrint('✅ File copied to public Downloads: ${destFile.path}');
              return;
            }
          }
        } catch (e) {
          debugPrint('⚠️ Could not copy to $path: $e');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error copying to public Downloads: $e');
    }
  }

  /// Format file size for display
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}

/// Result of a download operation
class DownloadResult {
  final bool success;
  final String? error;
  final String? filePath;
  final String? filename;
  final int? fileSize;

  DownloadResult({
    required this.success,
    this.error,
    this.filePath,
    this.filename,
    this.fileSize,
  });
}






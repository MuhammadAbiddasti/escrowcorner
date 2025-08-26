import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class DynamicBrandingService {
  static const String _cacheDirName = 'dynamic_branding';
  
  // Singleton pattern
  static final DynamicBrandingService _instance = DynamicBrandingService._internal();
  factory DynamicBrandingService() => _instance;
  DynamicBrandingService._internal();

  /// Initialize the service
  Future<void> initialize() async {
    try {
      await _getCacheDirectory();
      print('Dynamic branding service initialized');
    } catch (e) {
      print('Error initializing dynamic branding service: $e');
    }
  }

  /// Get the cache directory for dynamic branding
  Future<Directory> _getCacheDirectory() async {
    if (Platform.isAndroid) {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDir.path}/$_cacheDirName');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
      return cacheDir;
    } else if (Platform.isIOS) {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDir.path}/$_cacheDirName');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
      return cacheDir;
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }

  /// Download and cache an image from URL
  Future<File?> downloadAndCacheImage(String imageUrl, String fileName) async {
    try {
      print('Downloading image: $imageUrl');
      
      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'User-Agent': 'EscrowCorner/1.0',
        },
      );

      if (response.statusCode == 200) {
        final cacheDir = await _getCacheDirectory();
        final file = File('${cacheDir.path}/$fileName');
        
        await file.writeAsBytes(response.bodyBytes);
        
        print('Image cached successfully: ${file.path}');
        print('File size: ${response.bodyBytes.length} bytes');
        
        return file;
      } else {
        print('Failed to download image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  /// Get cached image file
  Future<File?> getCachedImage(String fileName) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final file = File('${cacheDir.path}/$fileName');
      
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      print('Error getting cached image: $e');
      return null;
    }
  }

  /// Clear all cached images
  Future<void> clearCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create();
      }
      print('Cache cleared successfully');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  /// Get cache directory path
  Future<String> getCacheDirectoryPath() async {
    final cacheDir = await _getCacheDirectory();
    return cacheDir.path;
  }

  /// Check if image is cached
  Future<bool> isImageCached(String fileName) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final file = File('${cacheDir.path}/$fileName');
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get image file size
  Future<int?> getImageFileSize(String fileName) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final file = File('${cacheDir.path}/$fileName');
      
      if (await file.exists()) {
        final stat = await file.stat();
        return stat.size;
      }
      return null;
    } catch (e) {
      print('Error getting file size: $e');
      return null;
    }
  }

  /// Validate image file
  Future<bool> validateImageFile(File file) async {
    try {
      if (!await file.exists()) return false;
      
      final stat = await file.stat();
      if (stat.size == 0) return false;
      
      // Try to read the file as an image
      final bytes = await file.readAsBytes();
      if (bytes.length < 100) return false; // Minimum size for a valid image
      
      return true;
    } catch (e) {
      print('Error validating image file: $e');
      return false;
    }
  }

  /// Get image dimensions (basic validation)
  Future<Map<String, int>?> getImageDimensions(File file) async {
    try {
      final bytes = await file.readAsBytes();
      
      // Basic PNG header check
      if (bytes.length >= 8 && 
          bytes[0] == 0x89 && bytes[1] == 0x50 && 
          bytes[2] == 0x4E && bytes[3] == 0x47) {
        
        // Extract width and height from PNG header
        if (bytes.length >= 24) {
          final width = (bytes[16] << 24) | (bytes[17] << 16) | (bytes[18] << 8) | bytes[19];
          final height = (bytes[20] << 24) | (bytes[21] << 16) | (bytes[22] << 8) | bytes[23];
          
          return {'width': width, 'height': height};
        }
      }
      
      // Basic JPEG header check
      if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
        // For JPEG, we'd need more complex parsing to get dimensions
        // For now, return null to indicate we can't determine dimensions
        return null;
      }
      
      return null;
    } catch (e) {
      print('Error getting image dimensions: $e');
      return null;
    }
  }

  /// Save branding URLs to preferences
  Future<void> saveBrandingUrls(String logoUrl, String iconUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dynamic_logo_url', logoUrl);
      await prefs.setString('dynamic_icon_url', iconUrl);
      await prefs.setString('branding_last_updated', DateTime.now().toIso8601String());
    } catch (e) {
      print('Error saving branding URLs: $e');
    }
  }

  /// Get branding URLs from preferences
  Future<Map<String, String?>> getBrandingUrls() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'logo_url': prefs.getString('dynamic_logo_url'),
        'icon_url': prefs.getString('dynamic_icon_url'),
        'last_updated': prefs.getString('branding_last_updated'),
      };
    } catch (e) {
      print('Error getting branding URLs: $e');
      return {};
    }
  }

  /// Check if branding needs refresh
  Future<bool> needsRefresh({Duration maxAge = const Duration(hours: 24)}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdated = prefs.getString('branding_last_updated');
      
      if (lastUpdated == null) return true;
      
      final lastUpdateTime = DateTime.parse(lastUpdated);
      final now = DateTime.now();
      
      return now.difference(lastUpdateTime) > maxAge;
    } catch (e) {
      print('Error checking if refresh needed: $e');
      return true;
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final cacheDir = await _getCacheDirectory();
      final files = await cacheDir.list().toList();
      
      int totalSize = 0;
      int fileCount = 0;
      
      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          totalSize += stat.size;
          fileCount++;
        }
      }
      
      return {
        'file_count': fileCount,
        'total_size_bytes': totalSize,
        'total_size_mb': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'cache_directory': cacheDir.path,
      };
    } catch (e) {
      print('Error getting cache stats: $e');
      return {};
    }
  }

  /// Update the launcher icon with a new image
  Future<bool> updateLauncherIcon(File iconFile) async {
    try {
      print('Updating launcher icon with file: ${iconFile.path}');
      
      if (Platform.isAndroid) {
        return await _updateAndroidLauncherIcon(iconFile);
      } else if (Platform.isIOS) {
        return await _updateIOSLauncherIcon(iconFile);
      } else {
        print('Platform not supported for launcher icon updates');
        return false;
      }
    } catch (e) {
      print('Error updating launcher icon: $e');
      return false;
    }
  }

  /// Update Android launcher icon
  Future<bool> _updateAndroidLauncherIcon(File iconFile) async {
    try {
      // For Android, we need to use platform channels to call native code
      const platform = MethodChannel('com.escrowcorner.app/launcher_icon');
      
      final result = await platform.invokeMethod('updateLauncherIcon', {
        'iconPath': iconFile.path,
      });
      
      print('Android launcher icon update result: $result');
      return result == true;
    } catch (e) {
      print('Error updating Android launcher icon: $e');
      return false;
    }
  }

  /// Update iOS launcher icon
  Future<bool> _updateIOSLauncherIcon(File iconFile) async {
    try {
      // For iOS, we need to use platform channels to call native code
      const platform = MethodChannel('com.escrowcorner.app/launcher_icon');
      
      final result = await platform.invokeMethod('updateLauncherIcon', {
        'iconPath': iconFile.path,
      });
      
      print('iOS launcher icon update result: $result');
      return result == true;
    } catch (e) {
      print('Error updating iOS launcher icon: $e');
      return false;
    }
  }
}

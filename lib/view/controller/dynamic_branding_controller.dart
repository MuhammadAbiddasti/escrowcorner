import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/custom_api_url/constant_url.dart';
import '../../widgets/custom_token/constant_token.dart';
import '../../widgets/dynamic_branding/dynamic_branding_service.dart';

class DynamicBrandingController extends GetxController {
  // Observable variables for dynamic branding
  var appLogo = Rx<File?>(null);
  var appIcon = Rx<File?>(null);
  var isLoading = false.obs;
  var lastFetchTime = DateTime.now().subtract(Duration(hours: 24)).obs; // Default to 24 hours ago
  var currentAppIconUrl = ''.obs;
  var currentLogoUrl = ''.obs;
  
  // Cache duration (24 hours)
  static const Duration cacheDuration = Duration(hours: 24);
  
  // Dynamic branding service
  late DynamicBrandingService _brandingService;
  
  @override
  void onInit() {
    super.onInit();
    _brandingService = DynamicBrandingService();
    _initializeService();
  }
  
  Future<void> _initializeService() async {
    await _brandingService.initialize();
    // Clear cache first to force fresh download on app start
    await clearCache();
    // Always fetch fresh branding on app start to ensure we have the latest
    await fetchBrandingFromAPI();
    
    // After fetching, check if we have the icon and set it
    await _checkAndSetIconFromCache();
  }
  
  Future<void> _checkAndSetIconFromCache() async {
    try {
      print('🔍 Checking for cached icon...');
      final cachedIcon = await _brandingService.getCachedImage('dynamic_app_icon.png');
      if (cachedIcon != null && cachedIcon.existsSync()) {
        print('📁 Found cached icon: ${cachedIcon.path}');
        print('📁 Icon exists: ${cachedIcon.existsSync()}');
        print('📁 Icon size: ${await cachedIcon.length()} bytes');
        
        appIcon.value = cachedIcon;
        print('✅ Cached icon set to appIcon.value: ${appIcon.value?.path}');
        
        // Force refresh
        appIcon.refresh();
        print('🔄 Cached icon refreshed');
      } else {
        print('❌ No cached icon found');
      }
    } catch (e) {
      print('❌ Error checking cached icon: $e');
    }
  }

  // Check if cache should be refreshed
  bool shouldRefreshCache() {
    return DateTime.now().difference(lastFetchTime.value) > cacheDuration;
  }

  // Load cached branding from local storage
  Future<void> loadCachedBranding() async {
    try {
      // Load from branding service
      final brandingUrls = await _brandingService.getBrandingUrls();
      final logoUrl = brandingUrls['logo_url'];
      final iconUrl = brandingUrls['icon_url'];
      final lastUpdated = brandingUrls['last_updated'];
      
      if (lastUpdated != null) {
        lastFetchTime.value = DateTime.parse(lastUpdated);
      }
      
      if (logoUrl != null) {
        currentLogoUrl.value = logoUrl;
        final cachedLogo = await _brandingService.getCachedImage('dynamic_logo.png');
        if (cachedLogo != null) {
          appLogo.value = cachedLogo;
        }
      }
      
      if (iconUrl != null) {
        currentAppIconUrl.value = iconUrl;
        final cachedIcon = await _brandingService.getCachedImage('dynamic_app_icon.png');
        if (cachedIcon != null) {
          appIcon.value = cachedIcon;
        }
      }
      
      // Fallback to old cache method for backward compatibility
      final prefs = await SharedPreferences.getInstance();
      final logoPath = prefs.getString('cached_logo_path');
      final iconPath = prefs.getString('cached_icon_path');
      
      if (logoPath != null && File(logoPath).existsSync() && appLogo.value == null) {
        appLogo.value = File(logoPath);
      }
      
      if (iconPath != null && File(iconPath).existsSync() && appIcon.value == null) {
        appIcon.value = File(iconPath);
      }
      
    } catch (e) {
      print('Error loading cached branding: $e');
    }
  }

  // Save branding to cache
  Future<void> saveToCache(String logoPath, String iconPath, String logoUrl, String iconUrl) async {
    try {
      // Save to branding service
      await _brandingService.saveBrandingUrls(logoUrl, iconUrl);
      
      // Update observable URLs
      currentAppIconUrl.value = iconUrl;
      currentLogoUrl.value = logoUrl;
      lastFetchTime.value = DateTime.now();
      
      // Legacy cache for backward compatibility
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_logo_path', logoPath);
      await prefs.setString('cached_icon_path', iconPath);
      await prefs.setString('last_fetch_time', DateTime.now().toIso8601String());
      
    } catch (e) {
      print('Error saving to cache: $e');
    }
  }

  // Fetch branding from backend API
  Future<void> fetchBrandingFromAPI() async {
    if (isLoading.value) return;
    
    isLoading.value = true;
    
    try {
      print('🔍 Starting to fetch branding from API...');
      String? token = await getToken();
      print('🔑 Token available: ${token != null}');
      
      final apiUrl = '$baseUrl/api/get_setting';
      print('🌐 API URL: $apiUrl');
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'EscrowCorner/1.0',
        },
      );

      print('📡 API Response Status: ${response.statusCode}');
      print('📄 API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final settings = data['data'];
          
          String? logoUrl = settings['site_logo'];
          String? iconUrl = settings['app_icon'];
          
          print('✅ API Response - Logo: $logoUrl, Icon: $iconUrl');
          print('🔄 Current Logo URL: ${currentLogoUrl.value}');
          print('🔄 Current Icon URL: ${currentAppIconUrl.value}');
          
          // Check if URLs have changed or if this is the first load
          // Always download on first load or if URLs are different
          bool logoChanged = logoUrl != null && (logoUrl != currentLogoUrl.value || currentLogoUrl.value.isEmpty || appLogo.value == null);
          bool iconChanged = iconUrl != null && (iconUrl != currentAppIconUrl.value || currentAppIconUrl.value.isEmpty || appIcon.value == null);
          
          print('🔄 Logo changed: $logoChanged');
          print('🔄 Icon changed: $iconChanged');
          
          // Download and cache logo if changed or first load
          if (logoChanged && logoUrl.isNotEmpty) {
            print('📥 Downloading logo from: $logoUrl');
            final logoFile = await _brandingService.downloadAndCacheImage(logoUrl, 'dynamic_logo.png');
            if (logoFile != null) {
              appLogo.value = logoFile;
              print('✅ Logo updated successfully: ${logoFile.path}');
            } else {
              print('❌ Failed to download logo');
            }
          }
          
                     // Download and cache icon if changed or first load
           if (iconChanged && iconUrl.isNotEmpty) {
             print('📥 Downloading icon from: $iconUrl');
             final iconFile = await _brandingService.downloadAndCacheImage(iconUrl, 'dynamic_app_icon.png');
             if (iconFile != null) {
               print('📁 Icon file downloaded to: ${iconFile.path}');
               print('📁 Icon file exists: ${iconFile.existsSync()}');
               print('📁 Icon file size: ${await iconFile.length()} bytes');
               
               // Set the icon value
               appIcon.value = iconFile;
               print('✅ App icon value set: ${appIcon.value?.path}');
               
               // Force UI refresh
               appIcon.refresh();
               print('🔄 App icon refreshed');
               
               // Update launcher icon if app icon changed
               await updateLauncherIcon(iconFile);
             } else {
               print('❌ Failed to download icon');
             }
           }
          
                     // Save to cache with URLs
           if (logoUrl != null || iconUrl != null) {
             print('💾 Saving to cache - Logo: $logoUrl, Icon: $iconUrl');
             await saveToCache(
               logoUrl ?? currentLogoUrl.value,
               iconUrl ?? currentAppIconUrl.value,
               logoUrl ?? currentLogoUrl.value,
               iconUrl ?? currentAppIconUrl.value,
             );
           }
          
          print('🎉 Branding updated successfully');
          print('📊 Final Logo URL: ${currentLogoUrl.value}');
          print('📊 Final Icon URL: ${currentAppIconUrl.value}');
        } else {
          print('❌ API returned success: false');
        }
      } else {
        print('❌ Failed to fetch branding: ${response.statusCode}');
        print('📄 Response body: ${response.body}');
      }
    } catch (e) {
      print('💥 Error fetching branding: $e');
    } finally {
      isLoading.value = false;
      print('🏁 Finished fetching branding');
    }
  }

  // Download and cache an image (legacy method - kept for backward compatibility)
  Future<void> downloadAndCacheImage(String imageUrl, String fileName, Function(File) onSuccess) async {
    try {
      print('Downloading image from: $imageUrl');
      final response = await http.get(Uri.parse(imageUrl));
      
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        
        await file.writeAsBytes(response.bodyBytes);
        onSuccess(file);
        
        print('Image cached successfully: $fileName');
        print('File size: ${response.bodyBytes.length} bytes');
      } else {
        print('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading image $fileName: $e');
    }
  }

  // Update launcher icon (platform-specific implementation)
  Future<void> updateLauncherIcon(File iconFile) async {
    try {
      print('Updating launcher icon with file: ${iconFile.path}');
      
      // Call the service method to update the launcher icon
      final success = await _brandingService.updateLauncherIcon(iconFile);
      
      if (success) {
        print('Launcher icon updated successfully');
      } else {
        print('Failed to update launcher icon');
      }
    } catch (e) {
      print('Error updating launcher icon: $e');
    }
  }

  // Force refresh branding (for manual refresh)
  Future<void> forceRefresh() async {
    // Clear cache to force fresh download
    await clearCache();
    await fetchBrandingFromAPI();
  }

  // Get logo widget with fallback
  Widget getLogoWidget({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return Obx(() {
      if (appLogo.value != null) {
        return Image.file(
          appLogo.value!,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading logo: $error');
            return _getFallbackLogo(width, height, fit);
          },
        );
      } else {
        return _getFallbackLogo(width, height, fit);
      }
    });
  }

  // Get icon widget with fallback
  Widget getIconWidget({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    print('🔍 getIconWidget called - appIcon.value: ${appIcon.value}');
    print('🔍 getIconWidget called - appIcon.value?.path: ${appIcon.value?.path}');
    
    if (appIcon.value != null) {
      print('✅ Using dynamic icon: ${appIcon.value!.path}');
      return Image.file(
        appIcon.value!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error loading dynamic icon: $error');
          return _getFallbackIcon(width, height, fit);
        },
      );
    } else {
      print('⚠️ Using fallback icon: assets/icon/logo_app.png');
      return _getFallbackIcon(width, height, fit);
    }
  }

  // Fallback logo widget
  Widget _getFallbackLogo(double? width, double? height, BoxFit fit) {
    return Image.asset(
      'assets/icon/logo.png',
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Icon(Icons.image, color: Colors.grey[600]),
        );
      },
    );
  }

  // Fallback icon widget
  Widget _getFallbackIcon(double? width, double? height, BoxFit fit) {
    return Image.asset(
      'assets/icon/icon.png',
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        print('Fallback icon error: $error');
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Icon(Icons.apps, color: Colors.grey[600]),
        );
      },
    );
  }

  // Get current branding URLs
  String getCurrentLogoUrl() => currentLogoUrl.value;
  String getCurrentIconUrl() => currentAppIconUrl.value;

  // Check if branding is up to date
  bool isBrandingUpToDate() {
    return !shouldRefreshCache();
  }

  // Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    return await _brandingService.getCacheStats();
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      print('🧹 Clearing all branding cache...');
      
      // Clear branding service cache
      await _brandingService.clearCache();
      
      // Clear legacy cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_logo_path');
      await prefs.remove('cached_icon_path');
      await prefs.remove('cached_logo_url');
      await prefs.remove('cached_icon_url');
      await prefs.remove('last_fetch_time');
      
      // Clear observable values
      appLogo.value = null;
      appIcon.value = null;
      currentLogoUrl.value = '';
      currentAppIconUrl.value = '';
      lastFetchTime.value = DateTime.now().subtract(Duration(hours: 25));
      
      print('✅ Cache cleared successfully');
      print('📱 App logo: ${appLogo.value}');
      print('📱 App icon: ${appIcon.value}');
      print('🌐 Logo URL: ${currentLogoUrl.value}');
      print('🌐 Icon URL: ${currentAppIconUrl.value}');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }
} 
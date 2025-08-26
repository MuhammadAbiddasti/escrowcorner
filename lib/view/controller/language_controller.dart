import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/custom_api_url/constant_url.dart';
import '../../widgets/custom_token/constant_token.dart'; // Added for getToken
import 'home_controller.dart' as home;
import 'services_controller.dart';
import 'about_us_controller.dart';

class LanguageController extends GetxController {
  // Observable variables for language management
  var languages = <Language>[].obs;
  var selectedLanguage = Rx<Language?>(null);
  var isLoading = false.obs;
  var hasError = false.obs;
  
  // Default language
  static const String defaultLocale = 'en';
  
  // Cache for language keys
  Map<String, Map<String, String>> _translationCache = {};
  
  @override
  void onInit() {
    super.onInit();
    print('LanguageController initialized');
    print('Default locale: $defaultLocale');
    
    loadSavedLanguage();
    fetchLanguages();
    
    // Also fetch language keys for the default language
    fetchLanguageKeys(defaultLocale);
    
    print('LanguageController onInit completed');
  }
  
  // Load saved language from local storage
  Future<void> loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString('selected_locale');
      
      if (savedLocale != null) {
        // User has previously selected a language, use that
        print('Loading previously saved language: $savedLocale');
      } else {
        // First time app launch, always start with English
        print('First time app launch, setting default language: English');
        await prefs.setString('selected_locale', defaultLocale);
      }
      
      // Set default language until we fetch from API
      selectedLanguage.value = Language(
        id: 1,
        name: 'English',
        locale: defaultLocale, // Always start with English
        createdAt: '',
        updatedAt: '',
      );
      
      // Try to load cached translations for the default language
      await _loadCachedTranslations(defaultLocale);
    } catch (e) {
      // Use translated error message
      final errorMessage = _translationCache[defaultLocale]?['error'] ?? 'error';
      print('$errorMessage loading saved language: $e');
      // Fallback to English
      selectedLanguage.value = Language(
        id: 1,
        name: 'English',
        locale: defaultLocale,
        createdAt: '',
        updatedAt: '',
      );
    }
  }
  
  // Load cached translations from SharedPreferences
  Future<void> _loadCachedTranslations(String locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedKeys = prefs.getString('language_keys_$locale');
      
      if (cachedKeys != null) {
        final translationMap = Map<String, String>.from(json.decode(cachedKeys));
        _translationCache[locale] = translationMap;
        print('Loaded ${translationMap.length} cached translations for $locale');
      } else {
        print('No cached translations found for $locale');
      }
    } catch (e) {
      // Use translated error message
      final errorMessage = _translationCache[locale]?['error'] ?? 'error';
      print('$errorMessage loading cached translations: $e');
    }
  }
  
  // Save selected language to local storage
  Future<void> saveLanguage(Language language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_locale', language.locale);
      selectedLanguage.value = language;
      
      // Apply language change to the app
      await _applyLanguage(language.locale);
      
      print('Language saved: ${language.name} (${language.locale})');
    } catch (e) {
      // Use translated error message
      final errorMessage = _translationCache[selectedLanguage.value?.locale ?? defaultLocale]?['error'] ?? 'error';
      print('$errorMessage saving language: $e');
    }
  }
  
  // Fetch languages from API
  Future<void> fetchLanguages() async {
    if (isLoading.value) return;
    
    isLoading.value = true;
    hasError.value = false;
    
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/getLanguages'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['languages'] != null) {
          List<dynamic> languagesData = data['languages'];
          languages.value = languagesData.map((lang) => Language.fromJson(lang)).toList();
          
          // Set selected language if not already set
          if (selectedLanguage.value == null) {
            final savedLocale = await _getSavedLocale();
            final defaultLang = languages.firstWhereOrNull(
              (lang) => lang.locale == savedLocale
            ) ?? languages.first;
            
            selectedLanguage.value = defaultLang;
            // Apply the language immediately
            await _applyLanguage(defaultLang.locale);
            print('Default language applied: ${defaultLang.name} (${defaultLang.locale})');
          } else {
            // Language is already set, just apply it to ensure consistency
            await _applyLanguage(selectedLanguage.value!.locale);
            print('Current language reapplied: ${selectedLanguage.value!.name} (${selectedLanguage.value!.locale})');
          }
          
          print('Languages fetched successfully: ${languages.length} languages');
        } else {
          hasError.value = true;
          print('Failed to parse languages data');
        }
      } else {
        hasError.value = true;
        print('Failed to fetch languages: ${response.statusCode}');
      }
    } catch (e) {
      hasError.value = true;
      // Use translated error message
      final errorMessage = _translationCache[defaultLocale]?['error'] ?? 'error';
      print('$errorMessage fetching languages: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Get saved locale from preferences
  Future<String> _getSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString('selected_locale');
      
      if (savedLocale != null && savedLocale.isNotEmpty) {
        return savedLocale;
      } else {
        // No saved locale, return default
        return defaultLocale;
      }
    } catch (e) {
      // Use translated error message
      final errorMessage = _translationCache[defaultLocale]?['error'] ?? 'error';
      print('$errorMessage getting saved locale: $e');
      return defaultLocale;
    }
  }
  
  // Apply language change to the app
  Future<void> _applyLanguage(String locale) async {
    try {
      // Change app locale using GetX
      Get.updateLocale(Locale(locale));
      
      // Note: RTL support can be implemented using MaterialApp's textDirection
      // or by wrapping specific widgets with Directionality
      
      // Refresh home content to show localized text
      try {
        final homeController = Get.find<home.HomeController>();
        homeController.refreshContent();
      } catch (e) {
        // Home controller might not be initialized yet, ignore
        print('Home controller not available for refresh: $e');
      }
      
      // Refresh services content to show localized text
      try {
        final servicesController = Get.find<ServicesController>();
        servicesController.refreshContent();
      } catch (e) {
        // Services controller might not be initialized yet, ignore
        print('Services controller not available for refresh: $e');
      }
      
      // Refresh about us content to show localized text
      try {
        final aboutUsController = Get.find<AboutUsController>();
        aboutUsController.refreshContent();
      } catch (e) {
        // About us controller might not be initialized yet, ignore
        print('About us controller not available for refresh: $e');
      }
      
      // Refresh all post-login content to show localized text
      await _refreshPostLoginContent();
      
      print('Language applied: $locale');
    } catch (e) {
      // Use translated error message
      final errorMessage = _translationCache[locale]?['error'] ?? 'error';
      print('$errorMessage applying language: $e');
    }
  }
  
  // Refresh all post-login content when language changes
  Future<void> _refreshPostLoginContent() async {
    try {
      print('Refreshing post-login content for language change...');
      
      // Get current locale for error messages
      final currentLocale = getCurrentLanguageLocale();
      
      // Refresh dashboard content
      try {
        final dashboardController = Get.find<home.HomeController>(tag: 'dashboard_home_controller');
        dashboardController.refreshContent();
        print('Dashboard content refreshed');
      } catch (e) {
        print('Dashboard controller not available for refresh: $e');
      }
      
      // Force UI update for all reactive widgets
      Get.forceAppUpdate();
      
      // Force refresh of sidebar menu by updating the app bar
      try {
        // This will trigger a rebuild of the CustomPopupMenu
        // The menu will automatically refresh when the language changes
        print('Sidebar menu refresh triggered');
      } catch (e) {
        // Use translated error message
        final errorMessage = _translationCache[currentLocale]?['error'] ?? 'error';
        print('$errorMessage updating sidebar menu: $e');
      }
      
      print('Post-login content refresh completed');
    } catch (e) {
      // Use translated error message
      final currentLocale = getCurrentLanguageLocale();
      final errorMessage = _translationCache[currentLocale]?['error'] ?? 'error';
      print('$errorMessage refreshing post-login content: $e');
    }
  }
  
  // Change language
  Future<void> changeLanguage(Language language) async {
    print('Changing language to: ${language.name} (${language.locale})');
    
    // Call the getLanguagesKeys API when switching languages
    await fetchLanguageKeys(language.locale);
    
    await saveLanguage(language);
  }

  // Fetch language keys for the selected language
  Future<void> fetchLanguageKeys(String locale) async {
    try {
      print('Fetching language keys for locale: $locale');
      
      // Determine which API to call based on login status
      String apiEndpoint;
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      
      // Get token
      String? token;
      try {
        token = await getToken();
      } catch (e) {
        print('Could not get token: $e');
        token = null;
      }
      
      if (token != null && token.isNotEmpty) {
        // User is logged in - call the after login API
        apiEndpoint = '$baseUrl/api/getLanguagesKeysAfterLogin';
        headers['Authorization'] = 'Bearer $token';
        print('User is logged in, calling: $apiEndpoint');
      } else {
        // User is not logged in - call the regular API
        apiEndpoint = '$baseUrl/api/getLanguagesKeys';
        print('User is not logged in, calling: $apiEndpoint');
      }
      
      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: headers,
        body: json.encode({
          'locale': locale,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          print('Language keys fetched successfully for $locale');
          
          // Parse the translations array and convert to a Map for easy access
          List<dynamic> translations = data['data'];
          Map<String, String> translationMap = {};
          
          for (var translation in translations) {
            if (translation['translation_key'] != null && translation['value'] != null) {
              final key = translation['translation_key'];
              final value = translation['value'];
              translationMap[key] = value;
              print('Stored translation: "$key" -> "$value"');
            }
          }
          
          print('Parsed ${translationMap.length} translations for $locale');
          
          // Store the translation map in shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('language_keys_$locale', json.encode(translationMap));
          
          // Also store in memory for faster access
          _translationCache[locale] = translationMap;
          
        } else {
          // Use translated error message
          final errorMessage = _translationCache[locale]?['error'] ?? 'error';
          print('Failed to fetch language keys: ${data['message'] ?? errorMessage}');
        }
      } else {
        // Use translated error message
        final errorMessage = _translationCache[locale]?['error'] ?? 'error';
        print('Failed to fetch language keys: ${response.statusCode} - $errorMessage');
      }
    } catch (e) {
      // Use translated error message
      final errorMessage = _translationCache[locale]?['error'] ?? 'error';
      print('$errorMessage fetching language keys: $e');
    }
  }

  // Reset to English (useful for testing or resetting preferences)
  Future<void> resetToEnglish() async {
    print('Resetting language to English');
    final englishLang = Language(
      id: 1,
      name: 'English',
      locale: defaultLocale,
      createdAt: '',
      updatedAt: '',
    );
    await saveLanguage(englishLang);
  }
  
  // Get current language name
  String getCurrentLanguageName() {
    return selectedLanguage.value?.name ?? 'English';
  }
  
  // Get current language locale
  String getCurrentLanguageLocale() {
    return selectedLanguage.value?.locale ?? defaultLocale;
  }
  
  // Check if current language is RTL
  bool isCurrentLanguageRTL() {
    final locale = getCurrentLanguageLocale();
    return locale == 'ar' || locale == 'he';
  }
  
  // Refresh languages from API
  Future<void> refreshLanguages() async {
    await fetchLanguages();
  }

  // Refresh language keys for the current language
  Future<void> refreshLanguageKeys() async {
    final locale = getCurrentLanguageLocale();
    await fetchLanguageKeys(locale);
  }

  // Get stored language keys for the current language
  Future<Map<String, dynamic>> getCurrentLanguageKeys() async {
    try {
      final locale = getCurrentLanguageLocale();
      return await getLanguageKeys(locale);
    } catch (e) {
      // Use translated error message
      final errorMessage = _translationCache[getCurrentLanguageLocale()]?['error'] ?? 'error';
      print('$errorMessage getting current language keys: $e');
      return {};
    }
  }

  // Get stored language keys for a specific locale
  Future<Map<String, dynamic>> getLanguageKeys(String locale) async {
    try {
      // First check cache
      if (_translationCache.containsKey(locale)) {
        return Map<String, dynamic>.from(_translationCache[locale]!);
      }
      
      // If not in cache, load from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final keysJson = prefs.getString('language_keys_$locale');
      
      if (keysJson != null) {
        final keys = json.decode(keysJson);
        final translationMap = Map<String, String>.from(keys);
        
        // Update cache
        _translationCache[locale] = translationMap;
        
        return Map<String, dynamic>.from(translationMap);
      }
      
      return {};
    } catch (e) {
      // Use translated error message
      final errorMessage = _translationCache[locale]?['error'] ?? 'error';
      print('$errorMessage getting language keys for $locale: $e');
      return {};
    }
  }

  // Get a specific language key value
  Future<String> getLanguageKey(String key, {String? locale}) async {
    try {
      final targetLocale = locale ?? getCurrentLanguageLocale();
      final keys = await getLanguageKeys(targetLocale);
      
      return keys[key]?.toString() ?? key; // Return the key itself if not found
    } catch (e) {
      // Use translated error message
      final targetLocale = locale ?? getCurrentLanguageLocale();
      final errorMessage = _translationCache[targetLocale]?['error'] ?? 'error';
      print('$errorMessage getting language key $key: $e');
      return key; // Return the key itself as fallback
    }
  }

  // Get a specific translation value (synchronous version using cache)
  String getTranslation(String key, {String? locale}) {
    try {
      final targetLocale = locale ?? getCurrentLanguageLocale();
      
      // Check cache first
      if (_translationCache.containsKey(targetLocale)) {
        final translatedValue = _translationCache[targetLocale]![key];
        if (translatedValue != null) {
          print('Translation found for "$key": "$translatedValue"');
          return translatedValue;
        } else {
          print('Translation not found for "$key", returning key as fallback');
          return key;
        }
      }
      
      // If no fallback, return the key as fallback
      print('No translations cached for locale "$targetLocale" and no fallback for "$key", returning key as fallback');
      return key;
    } catch (e) {
      // Use translated error message
      final targetLocale = locale ?? getCurrentLanguageLocale();
      final errorMessage = _translationCache[targetLocale]?['error'] ?? 'error';
      print('$errorMessage getting translation for $key: $e');
      return key;
    }
  }

  // Get all available translation keys for the current language
  List<String> getAvailableTranslationKeys() {
    try {
      final locale = getCurrentLanguageLocale();
      if (_translationCache.containsKey(locale)) {
        return _translationCache[locale]!.keys.toList();
      }
      return [];
    } catch (e) {
      // Use translated error message
      final errorMessage = _translationCache[getCurrentLanguageLocale()]?['error'] ?? 'error';
      print('$errorMessage getting available translation keys: $e');
      return [];
    }
  }

  // Debug method to print all cached translations
  void printAllCachedTranslations() {
    final locale = getCurrentLanguageLocale();
    print('=== Cached translations for $locale ===');
    if (_translationCache.containsKey(locale)) {
      _translationCache[locale]!.forEach((key, value) {
        print('  "$key" -> "$value"');
      });
    } else {
      print('  No translations cached for $locale');
    }
    print('=== End cached translations ===');
  }
}

// Language model
class Language {
  final int id;
  final String name;
  final String locale;
  final String createdAt;
  final String updatedAt;

  Language({
    required this.id,
    required this.name,
    required this.locale,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      locale: json['locale'] ?? 'en',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'locale': locale,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() {
    return 'Language(id: $id, name: $name, locale: $locale)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Language && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

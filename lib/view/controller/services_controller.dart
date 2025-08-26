import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../widgets/custom_api_url/constant_url.dart';
import 'language_controller.dart';

class Service {
  final int id;
  final String title;
  final String description;
  final String frTitle;
  final String frDescription;
  final String image;
  final String createdAt;
  final String updatedAt;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.frTitle,
    required this.frDescription,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    // Construct the full image URL
    String imageUrl = json['image'];
    if (!imageUrl.startsWith('http')) {
      imageUrl = '$baseUrl/$imageUrl'.replaceAll(RegExp(r'([^:]/)/+'), r'$1');
    }
    
    return Service(
      id: json['id'],
      title: json['title'] ?? '',
      description: (json['description'] ?? '').toString().replaceAll(RegExp(r'<[^>]*>'), ''), // Remove HTML tags
      frTitle: json['fr_title'] ?? '',
      frDescription: (json['fr_description'] ?? '').toString().replaceAll(RegExp(r'<[^>]*>'), ''), // Remove HTML tags
      image: imageUrl,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  // Get localized title based on current language
  String getLocalizedTitle() {
    try {
      final languageController = Get.find<LanguageController>();
      final currentLocale = languageController.getCurrentLanguageLocale();
      
      if (currentLocale == 'fr' && frTitle.isNotEmpty) {
        return frTitle;
      }
      return title;
    } catch (e) {
      print('Error getting localized title for service: $e');
      // Fallback to English if language controller not available
      return title;
    }
  }

  // Get localized description based on current language
  String getLocalizedDescription() {
    try {
      final languageController = Get.find<LanguageController>();
      final currentLocale = languageController.getCurrentLanguageLocale();
      
      if (currentLocale == 'fr' && frDescription.isNotEmpty) {
        return frDescription;
      }
      return description;
    } catch (e) {
      print('Error getting localized description for service: $e');
      // Fallback to English if language controller not available
      return description;
    }
  }
}

class ServicesController extends GetxController {
  var services = <Service>[].obs;
  var isLoading = true.obs;
  var hasError = false.obs;

  @override
  void onInit() {
    // Listen for language changes to refresh services
    try {
      final languageController = Get.find<LanguageController>();
      ever(languageController.selectedLanguage, (_) async {
        print('Language changed, refetching services from API');
        await fetchServices();
      });
    } catch (e) {
      print('Language controller not available for services: $e');
    }
    
    fetchServices();
    super.onInit();
  }

  // Refresh method to manually trigger services refresh
  Future<void> refreshServices() async {
    await fetchServices();
  }

  // Get current language for debugging
  String getCurrentLanguage() {
    try {
      final languageController = Get.find<LanguageController>();
      return languageController.getCurrentLanguageName();
    } catch (e) {
      return 'Unknown';
    }
  }

  // Refresh content without fetching from API (for language changes)
  void refreshContent() {
    // Trigger UI rebuild by updating the services list
    services.refresh();
    print('Services content refreshed for language change. Current language: ${getCurrentLanguage()}');
  }

  Future<void> fetchServices() async {
    try {
      isLoading(true);
      hasError(false);
      final languageController = Get.find<LanguageController>();
      final currentLocale = languageController.getCurrentLanguageLocale();
      print('Fetching services from: $baseUrl/api/get_services/$currentLocale');
      print('Current language: ${getCurrentLanguage()}');
      final response = await http.get(Uri.parse('$baseUrl/api/get_services/$currentLocale'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          List<dynamic>? servicesJson;
          // Support both shapes: { services: [...] } OR { data: { service: [...] } }
          if (jsonResponse['services'] is List) {
            servicesJson = jsonResponse['services'];
          } else if (jsonResponse['data'] is Map && jsonResponse['data']['service'] is List) {
            servicesJson = jsonResponse['data']['service'];
          } else if (jsonResponse['data'] is Map && jsonResponse['data']['services'] is List) {
            servicesJson = jsonResponse['data']['services'];
          }

          if (servicesJson != null) {
            services.value = servicesJson.map((json) => Service.fromJson(json)).toList();
            print('Services fetched successfully: ${services.length} services');
            print('Services will be displayed in: ${getCurrentLanguage()}');
          } else {
            hasError(true);
            print('Failed to parse services data: unexpected payload shape');
          }
        } else {
          hasError(true);
          print('API returned success=false');
        }
      } else {
        hasError(true);
        print('Error status code: ${response.statusCode}'); // Debug log
      }
    } catch (e) {
      hasError(true);
      print('Error fetching services: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }
} 
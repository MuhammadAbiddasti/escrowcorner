import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../widgets/custom_api_url/constant_url.dart';
import 'language_controller.dart';

class HomeContent {
  final String image;
  final String title;
  final String description;
  final String frTitle;
  final String frDescription;

  HomeContent({
    required this.image,
    required this.title,
    required this.description,
    required this.frTitle,
    required this.frDescription,
  });

  factory HomeContent.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['image'];
    if (!imageUrl.startsWith('http')) {
      imageUrl = '$baseUrl/$imageUrl'.replaceAll(RegExp(r'([^:]/)/+'), r'');
    }
    return HomeContent(
      image: imageUrl,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      frTitle: json['fr_title'] ?? '',
      frDescription: json['fr_description'] ?? '',
    );
  }

  // Get localized title based on current language
  String getLocalizedTitle() {
    final languageController = Get.find<LanguageController>();
    final currentLocale = languageController.getCurrentLanguageLocale();
    if (currentLocale == 'fr' && frTitle.isNotEmpty) {
      return frTitle;
    }
    return title;
  }

  // Get localized description based on current language
  String getLocalizedDescription() {
    final languageController = Get.find<LanguageController>();
    final currentLocale = languageController.getCurrentLanguageLocale();
    if (currentLocale == 'fr' && frDescription.isNotEmpty) {
      return frDescription;
    }
    return description;
  }
}

class HomeController extends GetxController {
  var homeContent = Rxn<HomeContent>();
  var isLoading = true.obs;
  var hasError = false.obs;

  @override
  void onInit() {
    fetchHomeContent();
    super.onInit();
    
    // Listen for language changes to refresh content
    try {
      final languageController = Get.find<LanguageController>();
      ever(languageController.selectedLanguage, (_) {
        refreshContent();
      });
    } catch (e) {
      // Language controller might not be initialized yet
      print('Language controller not available for listening: $e');
    }
    
    // Set fallback content after a delay if API fails
    Future.delayed(Duration(seconds: 5), () {
      if (homeContent.value == null && !isLoading.value) {
        print('Setting fallback content due to API failure');
        setFallbackContent();
      }
    });
  }

  // Set fallback content for testing
  void setFallbackContent() {
    homeContent.value = HomeContent(
      image: 'https://via.placeholder.com/400x300/0f9373/FFFFFF?text=Home+Image',
      title: 'EscrowCorner is a Payment Gateway and Financial Management Platform.',
      description: 'EscrowCorner is a Payment Gateway Solution That Help Companies and Businesses to Collect, Withdraw and Manage Their Payments.',
      frTitle: 'EscrowCorner est une passerelle de paiement et une plateforme de gestion financière.',
      frDescription: 'EscrowCorner est une solution de passerelle de paiement qui aide les entreprises à collecter, retirer et gérer leurs paiements.',
    );
    hasError(false);
    print('Fallback content set successfully');
  }

  // Test different API endpoints
  Future<void> testAPIEndpoints() async {
    print('Testing different API endpoints...');
    
    final endpoints = [
      '$baseUrl/api/get_home_content',
      '$baseUrl/api/get_setting',
      '$baseUrl/api/home',
    ];
    
    for (final endpoint in endpoints) {
      try {
        print('Testing endpoint: $endpoint');
        final response = await http.get(Uri.parse(endpoint));
        print('Status: ${response.statusCode}');
        print('Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
        print('---');
      } catch (e) {
        print('Error testing $endpoint: $e');
        print('---');
      }
    }
  }

  // Manual method to set fallback content for testing
  void setTestContent() {
    print('Setting test content manually');
    setFallbackContent();
  }

  Future<void> fetchHomeContent() async {
    try {
      isLoading(true);
      hasError(false);
      
      final apiUrl = '$baseUrl/api/get_home_content';
      print('Attempting to fetch from: $apiUrl');
      
      // Using the correct home content API endpoint
      final response = await http.get(Uri.parse(apiUrl));
      print('Home API status: ${response.statusCode}');
      print('Home API body: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('Home API parsed: $jsonResponse');
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          // Check if home_data exists in the response
          if (jsonResponse['data']['home_data'] != null) {
            homeContent.value = HomeContent.fromJson(jsonResponse['data']['home_data']);
            print('Home content loaded successfully');
            hasError(false);
          } else {
            print('No home_data found in response');
            print('Available keys in data: ${jsonResponse['data'].keys.toList()}');
            hasError(true);
          }
        } else {
          print('API response indicates failure or missing data');
          print('Success: ${jsonResponse['success']}');
          print('Data: ${jsonResponse['data']}');
          hasError(true);
        }
      } else {
        print('HTTP error: ${response.statusCode}');
        print('Response body: ${response.body}');
        hasError(true);
      }
    } catch (e) {
      print('Home API exception: $e');
      print('Exception type: ${e.runtimeType}');
      hasError(true);
    } finally {
      isLoading(false);
      print('Fetch completed. Loading: $isLoading, HasError: $hasError, Content: ${homeContent.value != null}');
    }
  }

  // Refresh content when language changes
  void refreshContent() {
    print('Refreshing home content due to language change');
    update(); // This will trigger UI rebuild
  }
} 
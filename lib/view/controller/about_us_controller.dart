import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../widgets/custom_api_url/constant_url.dart';
import 'language_controller.dart';

class AboutUsContent {
  final String title;
  final String description;
  final String image;
  final String frTitle;
  final String frDescription;

  AboutUsContent({
    required this.title, 
    required this.description, 
    required this.image,
    required this.frTitle,
    required this.frDescription,
  });

  factory AboutUsContent.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['image'] ?? '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = '$baseUrl/$imageUrl';
      // Remove accidental double slashes except after 'http(s):'
      imageUrl = imageUrl.replaceAll(RegExp(r'(?<!:)//'), '/');
    }
    return AboutUsContent(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: imageUrl,
      frTitle: json['fr_title'] ?? '',
      frDescription: json['fr_description'] ?? '',
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
      print('Error getting localized title for about us: $e');
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
      print('Error getting localized description for about us: $e');
      // Fallback to English if language controller not available
      return description;
    }
  }
}

class AboutUsController extends GetxController {
  var aboutUsContent = Rxn<AboutUsContent>();
  var isLoading = true.obs;
  var hasError = false.obs;

  @override
  void onInit() {
    // Listen for language changes to refresh about us content
    try {
      final languageController = Get.find<LanguageController>();
      ever(languageController.selectedLanguage, (_) async {
        print('Language changed, refetching about us content');
        await fetchAboutUsContent();
      });
    } catch (e) {
      print('Language controller not available for about us: $e');
    }
    
    fetchAboutUsContent();
    super.onInit();
  }

  Future<void> fetchAboutUsContent() async {
    try {
      isLoading(true);
      hasError(false);
      final languageController = Get.find<LanguageController>();
      final currentLocale = languageController.getCurrentLanguageLocale();
      final response = await http.get(Uri.parse('$baseUrl/api/get_about_us_content/$currentLocale'));
      print('Response received: ${response.body}');
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          Map<String, dynamic>? payload;
          // Support new shape: { aboutSection: {...} }
          if (jsonResponse['aboutSection'] is Map) {
            payload = Map<String, dynamic>.from(jsonResponse['aboutSection']);
          }
          // Support old shapes: { data: { about_us: {...} } } or { data: { aboutSection: {...} } }
          else if (jsonResponse['data'] is Map) {
            final data = jsonResponse['data'] as Map;
            if (data['about_us'] is Map) {
              payload = Map<String, dynamic>.from(data['about_us']);
            } else if (data['aboutSection'] is Map) {
              payload = Map<String, dynamic>.from(data['aboutSection']);
            }
          }

          if (payload != null) {
            aboutUsContent.value = AboutUsContent.fromJson(payload);
          } else {
            hasError(true);
            print('About Us: unexpected payload shape');
          }
        } else {
          hasError(true);
        }
      } else {
        hasError(true);
      }
    } catch (e) {
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  // Refresh content without fetching from API (for language changes)
  void refreshContent() {
    // Trigger UI rebuild by updating the about us content
    aboutUsContent.refresh();
    print('About us content refreshed for language change');
  }
} 
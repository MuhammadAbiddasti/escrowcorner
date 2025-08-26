import 'dart:convert';
import 'package:escrowcorner/widgets/custom_api_url/constant_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:escrowcorner/view/controller/language_controller.dart';

class LogoController extends GetxController {
  var logoUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLogoUrl();
    
    // Listen for language changes to refresh logo
    try {
      final languageController = Get.find<LanguageController>();
      ever(languageController.selectedLanguage, (_) {
        fetchLogoUrl(); // Refresh logo when language changes
      });
    } catch (e) {
      print('LanguageController not available yet: $e');
    }
  }

  Future<void> fetchLogoUrl() async {
    try {
      // Get the current locale from LanguageController
      final languageController = Get.find<LanguageController>();
      final currentLocale = languageController.getCurrentLanguageLocale();
      
      final response = await http.get(Uri.parse('$baseUrl/api/get_site_details/$currentLocale'));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        logoUrl.value = responseData['data']['site_logo'];
      } else {
        print('Failed to fetch logo URL');
      }
    } catch (e) {
      print('Error fetching logo URL: $e');
    }
  }
}

class LogoWidget extends StatelessWidget {
  final String logoUrl;
  LogoWidget(this.logoUrl);
  @override
  Widget build(BuildContext context) {
    return logoUrl.isEmpty
        ? CircularProgressIndicator()
        : Image.network(
              "$baseUrl/$logoUrl",
      height: Get.height*.07,
      width: Get.width*.36,
            );
  }
}


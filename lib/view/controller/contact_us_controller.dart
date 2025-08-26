import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/custom_api_url/constant_url.dart';
import 'language_controller.dart';

class ContactUsController extends GetxController {
  var address = ''.obs;
  var contact = ''.obs;
  var email = ''.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchContactUsContent();
  }

  Future<void> fetchContactUsContent() async {
    isLoading.value = true;
    try {
      final languageController = Get.find<LanguageController>();
      final currentLocale = languageController.getCurrentLanguageLocale();
      final url = Uri.parse('$baseUrl/api/get_contact_us_content/$currentLocale');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          address.value = jsonResponse['data']['address'] ?? '';
          contact.value = jsonResponse['data']['contact'] ?? '';
          email.value = jsonResponse['data']['email'] ?? '';
        }
      }
    } catch (e) {
      // Handle error, optionally set error message
    } finally {
      isLoading.value = false;
    }
  }
} 
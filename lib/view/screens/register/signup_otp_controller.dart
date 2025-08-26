import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../widgets/custom_api_url/constant_url.dart';
import '../login/screen_login.dart';
import '../../controller/language_controller.dart';

class SignupOtpController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> verifySignupOtp(BuildContext context, String otpCode, dynamic userId) async {
    if (otpCode.isEmpty) {
      final languageController = Get.find<LanguageController>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(languageController.getTranslation('please_enter_the_otp_code')), backgroundColor: Colors.red),
      );
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    final languageController = Get.find<LanguageController>();
    final currentLocale = languageController.getCurrentLanguageLocale();
    final url = '$baseUrl/api/verify_signup_otp/$currentLocale';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'otp_code': otpCode,
        'user_id': userId,
      }),
    );
    isLoading.value = false;
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.headers['content-type']?.contains('application/json') == true) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final languageController = Get.find<LanguageController>();
        final successMessage = data['message'] ?? languageController.getTranslation('email_verified');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage), backgroundColor: Colors.green),
        );
        await Future.delayed(Duration(seconds: 1));
        // Always redirect to dashboard after successful OTP verification
        Get.offAllNamed('/dashboard');
      } else {
        final languageController = Get.find<LanguageController>();
        final errorMessage = data['message'] ?? languageController.getTranslation('wrong_otp_code');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } else {
      // Non-JSON, show raw body or generic error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server error'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> resendSignupOtp(dynamic userId) async {
    // Implement resend OTP logic for signup
    // You may need to pass user info (email/user_id) as required by your backend
    final languageController = Get.find<LanguageController>();
    final currentLocale = languageController.getCurrentLanguageLocale();
    final url = '$baseUrl/api/resend_signup_otp/$currentLocale';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}),
    );
    print('Resend OTP status: ${response.statusCode}');
    print('Resend OTP response: ${response.body}');
    if (response.headers['content-type']?.contains('application/json') == true) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final title = 'success'.tr;
        final msg = data['message'] ?? 'otp_resent_successfully'.tr;
        Get.snackbar(title, msg, backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        final title = 'error'.tr;
        final msg = data['message'] ?? 'failed_to_resend_otp'.tr;
        Get.snackbar(title, msg, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
      Get.snackbar('error'.tr, 'server_error'.tr, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
} 
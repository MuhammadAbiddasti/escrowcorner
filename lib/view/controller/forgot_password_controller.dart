import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/custom_api_url/constant_url.dart';
import 'language_controller.dart';

class ForgotPasswordController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  final TextEditingController emailController = TextEditingController();

  Future<void> resetPassword(String email) async {
    // API URL with email as a query parameter and locale in path
    final languageController = Get.find<LanguageController>();
    final currentLocale = languageController.getCurrentLanguageLocale();
    final url = '$baseUrl/api/resetpassword/$currentLocale?email=${Uri.encodeComponent(email)}';

    // Headers (no token is included in this example)
    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      // Debugging: Check if the email is empty
      if (email.trim().isEmpty) {
        final languageController = Get.find<LanguageController>();
        Get.snackbar(
          languageController.getTranslation('error'),
          languageController.getTranslation('please_enter_a_valid_email_address'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Make the GET request
      final response = await http.get(Uri.parse(url), headers: headers);
      // Debugging: Check the response status code and body
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      if (response.statusCode == 200) {
        // Handle success response
        final data = jsonDecode(response.body);
        successMessage.value = data['message'] ?? 'Password reset link sent!';
        // Show success message in the snack bar
        final languageController = Get.find<LanguageController>();
        Get.snackbar(
          languageController.getTranslation('success'),
          successMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        emailController.clear();
        // Navigate to the new password reset screen if user_id or email is returned
        final userId = data['user_id'];
        if (userId != null) {
          Get.toNamed('/reset-password', arguments: {'userId': userId});
        } else {
          // fallback: pass email if user_id is not returned
          Get.toNamed('/reset-password', arguments: {'email': email});
        }
      } else {
        // Handle error response
        final data = jsonDecode(response.body);
        errorMessage.value = data['message'] ?? 'Failed to send reset link';
        // Show error message in the snack bar
        Get.snackbar(
          languageController.getTranslation('error'),
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Handle exception
      print("Error: $e");
      errorMessage.value = 'An error occurred';

      // Show error message in the snack bar
      Get.snackbar(
        languageController.getTranslation('error'),
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // Reset loading state
      isLoading.value = false;
    }
  }

  Future<void> submitResetPassword({
    required String otp,
    required String password,
    required String confirmPassword,
    dynamic userId,
    String? email,
  }) async {
    if (otp.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      final languageController = Get.find<LanguageController>();
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('please_fill_in_all_fields'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (password != confirmPassword) {
      final languageController = Get.find<LanguageController>();
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('password_mismatch'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    final languageController = Get.find<LanguageController>();
    final currentLocale = languageController.getCurrentLanguageLocale();
    final url = '$baseUrl/api/submit_reset_password/$currentLocale';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'otp': otp,
        'password': password,
        'confirm_password': confirmPassword,
        if (userId != null) 'user_id': userId,
        if (email != null) 'email': email,
      }),
    );
    print('Reset password status: ${response.statusCode}');
    print('Reset password response: ${response.body}');
    if (response.headers['content-type']?.contains('application/json') == true) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final languageController = Get.find<LanguageController>();
        Get.snackbar(languageController.getTranslation('success'), data['message'] ?? 'Password reset successful', backgroundColor: Colors.green, colorText: Colors.white);
        await Future.delayed(Duration(seconds: 1));
        Get.offAllNamed('/login');
      } else {
        Get.snackbar(
          languageController.getTranslation('error'),
          data['message'] ?? 'Failed to reset password',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('server_error'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

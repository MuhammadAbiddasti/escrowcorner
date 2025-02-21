import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/custom_api_url/constant_url.dart';

class ForgotPasswordController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  final TextEditingController emailController = TextEditingController();

  Future<void> resetPassword(String email) async {
    // API URL with email as a query parameter
    final url = '$baseUrl/api/resetpassword?email=${Uri.encodeComponent(email)}';

    // Headers (no token is included in this example)
    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      // Debugging: Check if the email is empty
      if (email.trim().isEmpty) {
        Get.snackbar("Message", "Email is Empty",snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,);
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
        Get.snackbar(
          "Success",
          successMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        emailController.clear();
      } else {
        // Handle error response
        final data = jsonDecode(response.body);
        errorMessage.value = data['message'] ?? 'Failed to send reset link';
        // Show error message in the snack bar
        Get.snackbar(
          "Error",
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
        "Error",
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
}

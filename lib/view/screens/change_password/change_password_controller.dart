import 'dart:convert';
import 'package:dacotech/view/screens/change_password/password_verification_screen.dart';
import 'package:dacotech/view/screens/change_password/screen_change_password.dart';
import 'package:dacotech/view/screens/settings/screen_settings_portion.dart';
import 'package:dacotech/widgets/custom_api_url/constant_url.dart';
import 'package:http/http.dart' as http;
import 'package:dacotech/widgets/custom_token/constant_token.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';

class ChangePasswordController extends GetxController {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController = TextEditingController();

  var isLoading = false.obs;

  Future<void> changePassword() async {
    String oldPassword = oldPasswordController.text;
    String newPassword = newPasswordController.text;
    String newPasswordConfirmation = confirmNewPasswordController.text;

    if (newPassword != newPasswordConfirmation) {
      Get.snackbar('Message', 'New password and confirmation do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,);
      return;
    }

    if (newPassword.isEmpty || newPasswordConfirmation.isEmpty || oldPassword.isEmpty) {
      Get.snackbar('Message', 'Please fill all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,);
      return;
    }

    isLoading.value = true;
    String? token = await getToken();
    if (token == null) {
      throw Exception('Token is null');
    }

    try {
      final url = Uri.parse('$baseUrl/api/changePassword');

      final body = jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      });

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == 'success') {
          Get.snackbar('Success', jsonResponse['message'] ?? 'Password changed successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,);
          //Get.off(ScreenSettingsPortion());
          oldPasswordController.clear();
          newPasswordController.clear();
          confirmNewPasswordController.clear();
        } else {
          Get.snackbar('Error', jsonResponse['message'] ?? 'Failed to change password',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,);
        }

      } else {
        // Extract message from error response body
        var errorResponse = jsonDecode(response.body);
        String errorMessage = errorResponse['message'] ?? 'An error occurred';

        Get.snackbar('Error', errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendOtpRequest({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
     String url = "$baseUrl/api/send_otp";
    String? token = await getToken(); // Ensure you have a method to get the Bearer token

    if (token == null) {
      Get.snackbar('Error', 'Token is null',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }
    try {

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        //body: json.encode(body), // Send the request body as JSON
      );

      print("response code ${response.statusCode}");
      print("response body ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];

        if (data['status'] == 1) {
          // Successfully sent OTP, navigate to OTP screen
          Get.snackbar("Success", data['message'] ?? "OTP sent successfully!",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white);
          // Navigate to OTP screen with necessary data
          Get.to(() => PasswordOtpVerificationScreen(
              oldPassword: oldPassword,
              newPassword: newPassword,
              confirmPassword: oldPassword),
              arguments: message); // Pass message as argument
        } else {
          Get.snackbar("Error", data['message'] ?? "Failed to send OTP",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        }
      } else {
        Get.snackbar("Error", "Unexpected error occurred",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to connect to the server",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      print("Exception: $e");
    }
  }

  Future<void> verifyOtpCode({
    required String otpCode,
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
     String url = "$baseUrl/api/verifyOtp";
    String? token = await getToken();
    if (token == null) {
      Get.snackbar(
        'Error',
        'Token is null',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Prepare request body
      final Map<String, dynamic> body = {
        "otp_code": otpCode,
      };

      // Use a custom client to handle redirects
      final client = http.Client();
      final request = http.Request('POST', Uri.parse(url))
        ..headers.addAll({
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        })
        ..body = json.encode(body);

      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      print("response code ${response.statusCode}");
      print("response body ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 1) {
          // Get.snackbar(
          //   "Success",
          //   data['message'] ?? "OTP verified successfully!",
          //   snackPosition: SnackPosition.BOTTOM,
          //   backgroundColor: Colors.green,
          //   colorText: Colors.white,
          // );
          await Future.delayed(const Duration(seconds: 2));
          await changePassword();
          Get.off(ScreenChangePassword());
        } else {
          Get.snackbar(
            "Error",
            data['message'] ?? "Failed to verify OTP",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else if (response.statusCode == 302) {
        // Handle redirect
        Get.snackbar(
          "Error",
          "Redirect detected. Please check the API endpoint.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          "Unexpected error occurred",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to connect to the server",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("Exception: $e");
    }
  }


}
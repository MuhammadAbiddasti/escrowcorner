import 'package:dacotech/view/screens/withdraw/screen_withdraw_otp.dart';
import 'package:dacotech/view/screens/withdraw/screen_withdrawal.dart';
import 'package:dacotech/widgets/custom_api_url/constant_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../widgets/custom_token/constant_token.dart';

class DepositWithdrawRequestController extends GetxController {
  var isLoading = false.obs;
  // Method to make a deposit request
  Future<void> makeDepositRequest({
    required String methodId,
    required String amount,
    required String phoneNumber,
    required String description,
  }) async {
    final String url = "$baseUrl/api/makeDepositRequest";
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
      // Prepare request body for form-data
      final body = {
        "method_id": "${methodId}",
        "amount": "${amount}",
        "phone_number": phoneNumber,  // Ensure this is a String type
        "description": "${description}",
      };

      print("all data: $body");

      // Send POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
        },
        body: body, // Directly passing as form-data
      );

      print("response code: ${response.statusCode}");
      print("response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == "success") {
          Get.snackbar(
            "Success",
            data['message'] ?? "Deposit request successful!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            "Error",
            data['message'] ?? "Something went wrong",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        final errorData = json.decode(response.body);
        Get.snackbar(
          "Error",
          errorData['message'] ?? "Unexpected error occurred",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print("Error: $errorData");
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


  Future<void> makeWithdrawRequest({
    required String methodId,
    required String amount,
    required String phoneNumber,
    required String description,
  }) async {
    final String url = "$baseUrl/api/makeWithdrawRequest";
    String? token = await getToken(); // Ensure you have a method to get the Bearer token
    if (token == null) {
      Get.snackbar('Error', 'Token is null');
      isLoading.value = false; // Stop loading
      return;
    }
    try {
      // Prepare request body
      final Map<String, dynamic> body = {
        "payment_method_id": methodId.toString(), // Convert methodId to String
        "amount": amount,
        "payee_number": phoneNumber,
        "description": description,
      };

      // Send POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token", // Replace with actual token
          "Content-Type": "application/json",
        },
        body: json.encode(body),
      );

      print("response code ${response.statusCode}");
      print("response body ${response.body}");

      // Decode response
      final data = json.decode(response.body);

      // Check response status
      if (response.statusCode == 200) {
        if (data['status'] == "success") {
          Get.snackbar(
            "Success",
            data['message'] ?? "Withdraw request successful!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            "Error",
            data['message'] ?? "Something went wrong",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        // Handle error responses
        Get.snackbar(
          "Error",
          data['message'] ?? "Unexpected error occurred",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print("Error: $data");
      }
    } catch (e) {
      // Exception handling
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


  Future<void> sendOtpRequest({
    required String paymentMethodId,
    required String amount,
    required String phoneNumber,
  }) async {
    const String url = "https://damaspay.com/api/send_otp";
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
          Get.to(() => WithdrawOtpVerificationScreen(
              paymentMethodId: paymentMethodId,
              amount: amount,
              phoneNumber: phoneNumber),
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
    required String paymentMethodId,
    required String amount,
    required String phoneNumber,
  }) async {
    const String url = "https://damaspay.com/api/verifyOtp";
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
          await makeWithdrawRequest(
            methodId: paymentMethodId,
            amount: amount,
            phoneNumber: phoneNumber,
            description: "Withdrawal request after OTP verification",
          );
          Get.off(() => ScreenWithdrawal());
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

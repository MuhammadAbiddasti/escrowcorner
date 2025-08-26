import 'package:escrowcorner/view/screens/withdraw/screen_withdraw_otp.dart';
import 'package:escrowcorner/view/screens/withdraw/screen_withdrawal.dart';
import 'package:escrowcorner/widgets/custom_api_url/constant_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../widgets/custom_token/constant_token.dart';
import '../../controller/language_controller.dart';

class DepositWithdrawRequestController extends GetxController {
  var isLoading = false.obs;
  final LanguageController languageController = Get.find<LanguageController>();
  
  // Temporary variable to store trx from makeWithdrawRequest
  String? tempTrx;
  // Method to make a deposit request
  Future<bool> makeDepositRequest({
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
      return false;
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
            languageController.getTranslation('success'),
            data['message'] ?? '', // Only show API message, no fallback
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          return true; // Return true on success
        } else {
          Get.snackbar(
            languageController.getTranslation('error'),
            data['message'] ?? '', // Only show API message, no fallback
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return false; // Return false on API error
        }
      } else {
        final errorData = json.decode(response.body);
        Get.snackbar(
          languageController.getTranslation('error'),
          errorData['message'] ?? '', // Only show API message, no fallback
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print("Error: $errorData");
        return false; // Return false on HTTP error
      }
    } catch (e) {
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('failed_to_connect_to_server'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("Exception: $e");
      return false; // Return false on exception
    }
  }


  Future<bool> makeWithdrawRequest({
    required String methodId,
    required String amount,
    required String phoneNumber,
    required String confirmNumber,
    required String description,
  }) async {
    final String url = "$baseUrl/api/makeWithdrawRequest";
    String? token = await getToken(); // Ensure you have a method to get the Bearer token
    if (token == null) {
      Get.snackbar('Error', 'Token is null');
      isLoading.value = false; // Stop loading
      return false;
    }
    try {
      // Prepare request body
      final Map<String, dynamic> body = {
        "payment_method_id": methodId.toString(), // Convert methodId to String
        "amount": amount,
        "payee_number": phoneNumber,
        "confirm_number": confirmNumber,
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
          // Check if OTP is enabled in the response
          int isEnabledOtp = int.tryParse(data['is_enabled_otp'].toString()) ?? 0;
          
                     if (isEnabledOtp == 1) {
             // Store trx in temporary variable for later use
             tempTrx = data['trx'];
             
             // OTP is enabled, navigate to OTP screen with dynamic heading
             String textHeading = data['text_heading'] ?? 'Enter the code sent to your email';
             Get.to(() => WithdrawOtpVerificationScreen(
               paymentMethodId: methodId,
               amount: amount,
               phoneNumber: phoneNumber,
               confirmNumber: confirmNumber,
             ), arguments: textHeading);
             return true;
                      } else {
             // OTP is not enabled, call submitWithdrawRequest API
             String? trx = data['trx'];
             if (trx != null && trx.isNotEmpty) {
               bool submitSuccess = await submitWithdrawRequest(trx);
               if (submitSuccess) {
                 print("Withdrawal successful without OTP, screen will be reset by UI");
                 // The UI will handle the screen reset
               }
               return submitSuccess;
             } else {
               // No trx received, show error
               Get.snackbar(
                 languageController.getTranslation('error'),
                 languageController.getTranslation('transaction_id_not_received'),
                 snackPosition: SnackPosition.BOTTOM,
                 backgroundColor: Colors.red,
                 colorText: Colors.white,
               );
               return false;
             }
           }
        } else {
          Get.snackbar(
            languageController.getTranslation('error'),
            data['message'] ?? '', // Only show API message, no fallback
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return false;
        }
      } else {
        // Handle error responses
        Get.snackbar(
          languageController.getTranslation('error'),
          data['message'] ?? '', // Only show API message, no fallback
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print("Error: $data");
        return false;
      }
    } catch (e) {
      // Exception handling
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('failed_to_connect_to_server'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("Exception: $e");
      return false;
    }
  }


  Future<bool> sendOtpRequest({
    required String paymentMethodId,
    required String amount,
    required String phoneNumber,
    required String confirmNumber,
  }) async {
    // Build URL with query parameters for GET request
    final Uri uri = Uri.parse("$baseUrl/api/send_otp").replace(
      queryParameters: {
        "payment_method_id": paymentMethodId,
        "amount": amount,
        "phone_number": phoneNumber,
        "confirm_number": confirmNumber,
      },
    );
    
    String? token = await getToken(); // Ensure you have a method to get the Bearer token

    if (token == null) {
      Get.snackbar('Error', 'Token is null',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    }
    try {
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("response code ${response.statusCode}");
      print("response body ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];

        if (data['status'] == 1) {
          // Successfully sent OTP, navigate to OTP screen
          Get.snackbar(languageController.getTranslation('success'), data['message'] ?? '', // Only show API message, no fallback
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white);

          // Navigate to OTP screen with necessary data
          Get.to(() => WithdrawOtpVerificationScreen(
              paymentMethodId: paymentMethodId,
              amount: amount,
              phoneNumber: phoneNumber,
              confirmNumber: confirmNumber),
              arguments: message); // Pass message as argument
          return true; // Return true on success
        } else {
          Get.snackbar(languageController.getTranslation('error'), data['message'] ?? '', // Only show API message, no fallback
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
          return false; // Return false on API error
        }
      } else {
        Get.snackbar(languageController.getTranslation('error'), languageController.getTranslation('unexpected_error_occurred'),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return false; // Return false on HTTP error
      }
    } catch (e) {
      Get.snackbar(languageController.getTranslation('error'), languageController.getTranslation('failed_to_connect_to_server'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      print("Exception: $e");
      return false; // Return false on exception
    }
  }

  Future<void> verifyOtpCode({
    required String otpCode,
    required String paymentMethodId,
    required String amount,
    required String phoneNumber,
    required String confirmNumber,
  }) async {
    final String url = "$baseUrl/api/verifyOtp";
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
        "payment_method_id": paymentMethodId,
        "amount": amount,
        "phone_number": phoneNumber,
        "confirm_number": confirmNumber,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode(body),
      );

      print("response code ${response.statusCode}");
      print("response body ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

                 if (data['status'] == 1) {
           // OTP verified successfully, now call submitWithdrawRequest API
           // Use the stored trx from makeWithdrawRequest response
           if (tempTrx != null && tempTrx!.isNotEmpty) {
             bool submitSuccess = await submitWithdrawRequest(tempTrx!);
             if (submitSuccess) {
               // Withdrawal submitted successfully, navigate back to withdrawal screen
               // Clear the temporary trx
               tempTrx = null;
               Get.off(() => ScreenWithdrawal());
             } else {
               // Error occurred during withdrawal submission
               // Stay on OTP screen to let user try again
             }
           } else {
             // No trx stored from makeWithdrawRequest
             Get.snackbar(
               languageController.getTranslation('error'),
               languageController.getTranslation('transaction_id_not_stored'),
               snackPosition: SnackPosition.BOTTOM,
               backgroundColor: Colors.red,
               colorText: Colors.white,
             );
           }
         } else {
          Get.snackbar(
            languageController.getTranslation('error'),
            data['message'] ?? '', // Only show API message, no fallback
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else if (response.statusCode == 302) {
        // Handle redirect
        final errorData = json.decode(response.body);
        Get.snackbar(
          languageController.getTranslation('error'),
          errorData['message'] ?? '', // Only show API message, no fallback
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        final errorData = json.decode(response.body);
        Get.snackbar(
          languageController.getTranslation('error'),
          errorData['message'] ?? '', // Only show API message, no fallback
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('failed_to_connect_to_server'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("Exception: $e");
    }
  }

  Future<bool> submitWithdrawRequest(String trx) async {
    final String url = "$baseUrl/api/submitWithdrawRequest";
    String? token = await getToken();

    if (token == null) {
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('token_is_null'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      // Prepare request body with trx parameter
      final Map<String, dynamic> body = {
        "trx": trx,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode(body),
      );

      print("submitWithdrawRequest response code: ${response.statusCode}");
      print("submitWithdrawRequest response body: ${response.body}");

             if (response.statusCode == 200) {
         final data = json.decode(response.body);
         
         if (data['status'] == "success" || data['success'] == true) {
           // Withdrawal submitted successfully, show success message
           Get.snackbar(
             languageController.getTranslation('success'),
             data['message'] ?? '', // Only show API message, no fallback
             snackPosition: SnackPosition.BOTTOM,
             backgroundColor: Colors.green,
             colorText: Colors.white,
           );
           
           print("Withdrawal successful with OTP, screen will be reset by UI");
           // The UI will handle the screen reset
           
           return true;
         } else {
           // Show error message
           Get.snackbar(
             languageController.getTranslation('error'),
             data['message'] ?? '', // Only show API message, no fallback
             snackPosition: SnackPosition.BOTTOM,
             backgroundColor: Colors.red,
             colorText: Colors.white,
           );
           return false;
         }
       } else {
         // Handle HTTP error responses
         final errorData = json.decode(response.body);
         Get.snackbar(
           languageController.getTranslation('error'),
           errorData['message'] ?? '', // Only show API message, no fallback
           snackPosition: SnackPosition.BOTTOM,
           backgroundColor: Colors.red,
           colorText: Colors.white,
         );
         print("Error: $errorData");
         return false;
       }
    } catch (e) {
      // Exception handling
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('failed_to_connect_to_server'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("Exception: $e");
      return false;
    }
  }

}

import 'dart:convert';
import 'dart:typed_data';
import 'package:dacotech/widgets/custom_token/constant_token.dart';
import 'package:dacotech/widgets/custom_api_url/constant_url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class TwoFactorController extends GetxController {
  // Reactive variables for email and google 2FA
  var email2fa = false.obs;
  var google2fa = false.obs;
  var isLoading = false.obs;
  RxString errorMessage = ''.obs;
  var qrCodeImage = Rx<Uint8List?>(null);
  var qrCodeValue = ''.obs;
  var showMessage = ''.obs;

  Future<void> sendOtp(String type) async {
    final String endpoint = "$baseUrl/api/send_otp_code/$type";
    String? bearerToken = await getToken();

    try {
      final headers = {
        "Authorization": "Bearer $bearerToken",
        "Content-Type": "application/json",
      };

      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final message = body['message'] ?? 'OTP sent successfully';
        print("OTP sent successfully: ${response.body}");

        // Show the message from the API in the Snackbar
        Get.snackbar(
          'Message',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        errorMessage.value = '';
      } else {
        final body = json.decode(response.body);
        print("Failed to send OTP: ${response.statusCode} - ${response.body}");
        errorMessage.value = body['message'] ?? "Failed to send OTP: ${response.statusCode}";
      }
    } catch (e) {
      print("Error occurred while sending OTP: $e");
      errorMessage.value = "Error occurred while sending OTP: $e";
    }
  }

  // Future<bool> verifyOtpCode(String code, String type) async {
  //   try {
  //     isLoading(true);
  //     String? bearerToken = await getToken();
  //
  //     // Update the type here before sending the request.
  //     String otpType = type == 'authenticator' ? 'google' : type;  // Change 'authenticator' to 'google'
  //
  //     final body = {"otp_code": code, "type": otpType};  // Ensure 'google' or 'email' is passed correctly
  //
  //     print("Sending OTP Type: $otpType and OTP Code: $code");
  //     print("Retrieved Token: $bearerToken");
  //     print("Request Body: $body");
  //
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/api/verifyOtpCode'),
  //       headers: {
  //         'Authorization': 'Bearer $bearerToken',
  //         'Content-Type': 'application/json',
  //       },
  //       body: json.encode(body),
  //     );
  //
  //     print("Response: ${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 'success') {
  //         Get.snackbar('Success', 'Verification successful',
  //           snackPosition: SnackPosition.BOTTOM,
  //           backgroundColor: Colors.green,
  //           colorText: Colors.white,);
  //         return true;
  //       } else {
  //         print("error: $data");
  //         Get.snackbar('Error', data['message'] ?? 'Invalid code',
  //           snackPosition: SnackPosition.BOTTOM,
  //           backgroundColor: Colors.red,
  //           colorText: Colors.white,);
  //         return false;
  //       }
  //     } else {
  //       print("Error: ${response.body}");
  //       //Get.snackbar('Error', 'Failed to verify the code');
  //       return false;
  //     }
  //   } catch (e) {
  //     print("Exception: $e");
  //     //Get.snackbar('Error', 'An error occurred while verifying the code');
  //     return false;
  //   } finally {
  //     isLoading(false);
  //   }
  // }

  Future<bool> verifyOtpCode(BuildContext context, String otp, String type) async {
    isLoading.value = true;  // Show loading indicator
    String? token = await getToken();
    print("Token used for OTP verification: $token");

    final url = Uri.parse("$baseUrl/api/verifyOtpCode");
    showLoadingSpinner(context);

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['otp_code'] = otp;  // Ensure OTP code is correctly set
      request.fields['type'] = type;

      print('Request Fields: ${request.fields}'); // Log fields for debugging

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      // Log status and response body
      print("Status Code for OTP Verification: ${response.statusCode}");
      print("Response Body for OTP Verification: $responseBody");

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);

        if (data['status'] == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('OTP verified successfully')),
          );
          return true;  // Return true if OTP is verified successfully
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Invalid OTP code'),
              backgroundColor: Colors.red,
            ),
          );
          return false;  // Return false if OTP verification failed
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid OTP code'),
            backgroundColor: Colors.red,
          ),
        );
        return false;  // Return false if the status code isn't 200
      }
    } catch (e) {
      print("Exception in OTP Verification: ${e.toString()}");
      Get.snackbar('Error', e.toString());
      return false;  // Return false in case of an exception
    } finally {
      isLoading.value = false;
      Navigator.pop(context);

    }
  }

  // Method to fetch the QR code
  Future<void> fetchQRCode() async {
    final String apiUrl = "$baseUrl/api/security";
    String? bearerToken = await getToken();
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $bearerToken",
        },
      );

      print("Response body:: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extract QR Code Base64 String and Secret
        final qrCodeBase64 = data['data']['qrCode'] ?? ''; // Extract Base64 string
        qrCodeValue.value = data['data']['google2fa_secret'] ?? ''; // Extract the secret code

        // Check if QR Code Base64 is valid
        if (qrCodeBase64.startsWith("data:image")) {
          final base64Str = qrCodeBase64.split(",").last; // Remove the prefix
          qrCodeImage.value = base64Decode(base64Str);    // Decode Base64 to Uint8List
        } else {
          qrCodeImage.value = null; // Set to null if invalid Base64
        }
      } else {
        errorMessage.value = "Failed to fetch QR code: ${response.body}";
      }
    } catch (e) {
      errorMessage.value = "An error occurred: $e";
    } finally {
      isLoading.value = false;
    }
  }

  void showLoadingSpinner(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Center(
            child: SpinKitFadingFour(
              duration: Duration(seconds: 3),
              size: 120,
              color: Colors.green,
            ),
          );
        }
    );
  }


}

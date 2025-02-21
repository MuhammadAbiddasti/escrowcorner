import 'package:dacotech/view/Kyc_screens/screen_kyc1.dart';
import 'package:dacotech/view/screens/dashboard/screen_dashboard.dart';
import 'package:dacotech/widgets/custom_api_url/constant_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../managers/manager_permission_controller.dart';
import '../user_profile/user_profile_controller.dart';
import 'screen_otp_verification.dart';

class LoginController extends GetxController {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var otpController = TextEditingController();
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  final ManagersPermissionController managerController = Get.put(ManagersPermissionController());
  final UserProfileController userProfileController =Get.put(UserProfileController());


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  // Future<void> login(BuildContext context) async {
  //   // Validation
  //   if (emailController.text.isEmpty || passwordController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Please fill in all fields')),
  //     );
  //     return;
  //   }
  //
  //   isLoading.value = true;
  //   errorMessage.value = '';
  //
  //   final url = '$baseUrl/api/login';
  //   final response = await http.post(
  //     Uri.parse(url),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({
  //       'email': emailController.text,
  //       'password': passwordController.text,
  //     }),
  //   );
  //
  //   isLoading.value = false;
  //
  //   print('Status Code: ${response.statusCode}');
  //   print('Response Body: ${response.body}');
  //
  //   if (response.statusCode == 200) {
  //     try {
  //       final data = jsonDecode(response.body);
  //       isLoading.value==true;
  //       final token = data['token'];
  //       final walletId = data['wallet_id'];
  //       print("Decoded Response Data: $data");
  //       print("Login successful, token: $token, wallet id: $walletId");
  //       // Store the token in SharedPreferences
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('token', token);
  //          ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Login Successful')));
  //       await Future.delayed(Duration(seconds: 1));
  //          //Get.to(() => OtpVerificationScreen());
  //            Get.offAll(() => ScreenDashboard());
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error: ${e.toString()}')),
  //       );
  //     }
  //   } else {
  //     final errorData = jsonDecode(response.body.toString());
  //     String errorMessage = errorData['message'].toString();
  //     try {
  //
  //       // Specific handling for incorrect password
  //       if (response.statusCode == 401) {
  //         errorMessage = errorData['message'].toString();
  //       }
  //
  //       //this.errorMessage.value = errorMessage;
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(errorMessage)),
  //       );
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Login Failed")),
  //       );
  //     };
  //     emailController.clear();
  //     passwordController.clear();
  //
  //   };
  //
  // }

  Future<void> login(BuildContext context) async {
    // Validation
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final url = '$baseUrl/api/login';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    isLoading.value = false;

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        print("Decoded Response Data: $data");

        if (data['success'] == true) {
          if (data.containsKey('token') && data['token'].isNotEmpty) {
            // Direct login and navigate to the dashboard
            final token = data['token'];
            print("User Token: $token");

            // Store the token in SharedPreferences or secure storage
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('auth_token', token);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Login successful!'), backgroundColor: Colors.green),
            );

            // Fetch user details and check KYC status
            await userProfileController.fetchUserDetails();
            await managerController.fetchManagerPermissions(prefs.getInt('user_id').toString());
            // Check KYC status after user details are fetched
            if (userProfileController.kyc.value == "3") {
              // If KYC status is 3, navigate to the Dashboard
              Get.offAll(() => ScreenDashboard());
            } else {
              // If KYC status is not 3, navigate to the KYC screen
              Get.offAll(() => ScreenKyc1()); // Replace with your actual KYC screen
            }

          } else {
            // Proceed with the OTP verification process
            final userId = data['user_id']; // Get the user ID from response
            final message = data['text_heading']; // OTP sent message

            print("User ID: $userId");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.green),
            );

            // Store the user_id in SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('user_id', userId);

            // Pass the OTP message to the OTP verification screen
            await Future.delayed(Duration(seconds: 1));
            Get.to(() => OtpVerificationScreen(), arguments: message);
          }
        } else {
          // Handle any other cases if 'success' is false
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed. Please try again.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } else {
      final errorData = jsonDecode(response.body);
      String errorMessage = errorData['message'] ?? 'Login Failed';

      // Specific handling for incorrect password or other error codes
      if (response.statusCode == 401) {
        errorMessage = errorData['message'] ?? 'Unauthorized access';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
      emailController.clear();
      passwordController.clear();
    }
  }

  Future<void> verifyOtpLogin(BuildContext context, String otpCode) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID is not found. Please login again.')),
      );
      return;
    }

    if (otpCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter the OTP code'),backgroundColor: Colors.red,),
      );
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    final url = '$baseUrl/api/verify_otp_login';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'otp_code': otpCode,
      }),
    );
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          // Save the token in SharedPreferences
          final token = data['token'];
          await prefs.setString('auth_token', token);  // Save the token
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login Successful'),backgroundColor: Colors.green,),
          );
          //managerController.fetchManagerPermissions(userProfileController.userId.value);
          // Navigate to the dashboard or home screen after successful OTP verification
          //userProfileController.fetchUserDetails();
          await userProfileController.fetchUserDetails();
          await managerController.fetchManagerPermissions(prefs.getInt('user_id').toString());

          // Check KYC status after user details are fetched
          if (userProfileController.kyc.value == "3") {
            // If KYC status is 3, navigate to the Dashboard
            Get.offAll(() => ScreenDashboard());
          } else {
            // If KYC status is not 3, navigate to the KYC screen
            Get.offAll(() => ScreenKyc1()); // Replace with your actual KYC screen
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid OTP code'),backgroundColor:Colors.red,),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'),backgroundColor: Colors.red,),
        );
      }
    } else {
      final errorData = jsonDecode(response.body);
      String errorMessage = errorData['message'] ?? 'OTP verification failed';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage),backgroundColor: Colors.red,),
      );
    }
    isLoading.value = false;
  }

  Future<void> resendOtp() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final String url = "$baseUrl/api/resend_otp/$userId";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      );
      print("response body: ${response.body}");
      print("response code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          Get.snackbar(
            "Success",
            data['message'] ?? "OTP resent successfully.",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar(
            "Error",
            data['message'] ?? "Failed to resend OTP.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          "Error",
          "Failed to resend OTP. Status Code: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Exception",
        "An error occurred: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      // Handle exceptions (e.g., network error, invalid JSON)
    }
  }
}

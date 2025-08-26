import 'package:escrowcorner/view/Kyc_screens/screen_kyc1.dart';
import 'package:escrowcorner/view/screens/dashboard/screen_dashboard.dart';
import 'package:escrowcorner/widgets/custom_api_url/constant_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../managers/manager_permission_controller.dart';
import '../user_profile/user_profile_controller.dart';
import 'screen_otp_verification.dart';
import '../../controller/language_controller.dart';

// Helper method to extract user_id from JWT token
int? extractUserIdFromToken(String token) {
  try {
    final parts = token.split('.');
    if (parts.length == 3) {
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(resp);
      return payloadMap['user_id'] ?? payloadMap['sub'];
    }
  } catch (e) {
    print("Error extracting user_id from token: $e");
  }
  return null;
}

class LoginController extends GetxController {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var otpController = TextEditingController();
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  final ManagersPermissionController managerController = Get.put(ManagersPermissionController());
  final UserProfileController userProfileController = Get.find<UserProfileController>();


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

  Future<bool> login(BuildContext context) async {
    // Validation
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      final languageController = Get.find<LanguageController>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            languageController.getTranslation('please_fill_in_all_fields'),
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final languageController = Get.find<LanguageController>();
    final currentLocale = languageController.getCurrentLanguageLocale();
    final url = '$baseUrl/api/login/$currentLocale';
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
            
            // Extract user_id from token or response if available
            if (data.containsKey('user_id') && data['user_id'] != null) {
              await prefs.setInt('user_id', data['user_id']);
            } else {
              // Try to extract user_id from token as fallback
              final userIdFromToken = extractUserIdFromToken(token);
              if (userIdFromToken != null) {
                await prefs.setInt('user_id', userIdFromToken);
              }
            }
            final successMessage = data['message'] ?? 'Login successful!';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(successMessage), backgroundColor: Colors.green),
            );

            // Fetch user details and check KYC status
            // Ensure UserProfileController is initialized
            if (!Get.isRegistered<UserProfileController>()) {
              Get.put(UserProfileController(), permanent: true);
            }
            
            try {
              await userProfileController.fetchUserDetails();
            } catch (e) {
              print("Error fetching user details: $e");
              // Continue with login even if user details fail
            }
            
            try {
              final userId = prefs.getInt('user_id');
              if (userId != null) {
                await managerController.fetchManagerPermissions(userId.toString());
              } else {
                print("No user_id found, skipping manager permissions fetch");
              }
            } catch (e) {
              print("Error fetching manager permissions: $e");
              // Continue with login even if manager permissions fail
            }
            
            // Always navigate to the Dashboard after login
            await Future.delayed(Duration(milliseconds: 500));
            
            // Ensure navigation happens even if there were errors
            try {
              // Use WidgetsBinding to ensure navigation happens after the current frame
              WidgetsBinding.instance.addPostFrameCallback((_) {
                try {
                  Get.offAll(() => ScreenDashboard());
                } catch (e) {
                  print("Navigation error: $e");
                  // Fallback navigation
                  Get.offAllNamed('/dashboard');
                }
              });
            } catch (e) {
              print("Error in navigation setup: $e");
              // Direct navigation as last resort
              Get.offAll(() => ScreenDashboard());
            }
            
            return true;
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
            return true;
          }
        } else {
          // Handle any other cases if 'success' is false
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed. Please try again.')),
          );
          return false;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
        return false;
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
      // Do not clear fields on error
      return false;
    }
    return false;
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
      final languageController = Get.find<LanguageController>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            languageController.getTranslation('please_enter_the_otp_code'),
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    final languageController = Get.find<LanguageController>();
    final currentLocale = languageController.getCurrentLanguageLocale();
    final url = '$baseUrl/api/verify_otp_login/$currentLocale';
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
          
          // Extract user_id from response if available
          if (data.containsKey('user_id') && data['user_id'] != null) {
            await prefs.setInt('user_id', data['user_id']);
          } else {
            // Try to extract user_id from token as fallback
            final userIdFromToken = extractUserIdFromToken(token);
            if (userIdFromToken != null) {
              await prefs.setInt('user_id', userIdFromToken);
            }
          }
          final successMessage = data['message'] ?? 'Login Successful';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(successMessage),backgroundColor: Colors.green,),
          );
          // Ensure UserProfileController is initialized
          if (!Get.isRegistered<UserProfileController>()) {
            Get.put(UserProfileController(), permanent: true);
          }
          
          try {
            await userProfileController.fetchUserDetails();
          } catch (e) {
            print("Error fetching user details: $e");
            // Continue with login even if user details fail
          }
          
          try {
            final userId = prefs.getInt('user_id');
            if (userId != null) {
              await managerController.fetchManagerPermissions(userId.toString());
            } else {
              print("No user_id found, skipping manager permissions fetch");
            }
          } catch (e) {
            print("Error fetching manager permissions: $e");
            // Continue with login even if manager permissions fail
          }
          
          // Always navigate to the Dashboard after OTP verification
          await Future.delayed(Duration(milliseconds: 500));
          
          // Ensure navigation happens even if there were errors
          try {
            // Use WidgetsBinding to ensure navigation happens after the current frame
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                Get.offAll(() => ScreenDashboard());
              } catch (e) {
                print("Navigation error: $e");
                // Fallback navigation
                Get.offAllNamed('/dashboard');
              }
            });
          } catch (e) {
            print("Error in navigation setup: $e");
            // Direct navigation as last resort
            Get.offAll(() => ScreenDashboard());
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
    final languageController = Get.find<LanguageController>();
    final currentLocale = languageController.getCurrentLanguageLocale();
    final String url = "$baseUrl/api/resend_otp/$userId/$currentLocale";

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
            languageController.getTranslation('success'),
            data['message'] ?? 'otp_resent_successfully'.tr,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar(
            languageController.getTranslation('error'),
            data['message'] ?? 'failed_to_resend_otp'.tr,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          languageController.getTranslation('error'),
          "Failed to resend OTP. Status Code: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        languageController.getTranslation('error'),
        "An error occurred: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      // Handle exceptions (e.g., network error, invalid JSON)
    }
  }
}

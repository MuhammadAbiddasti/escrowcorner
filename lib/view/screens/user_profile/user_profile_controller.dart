import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../widgets/custom_token/constant_token.dart';
import '../../../widgets/custom_api_url/constant_url.dart';
import '../../../view/screens/managers/manager_permission_controller.dart';
import '../../controller/language_controller.dart';

// Utility function to safely get UserProfileController
UserProfileController getUserProfileController() {
  if (!Get.isRegistered<UserProfileController>()) {
    Get.put(UserProfileController(), permanent: true);
  }
  return Get.find<UserProfileController>();
}

class UserProfileController extends GetxController {
  var firstName = ''.obs;
  var lastName = ''.obs;
  var userName = ''.obs;
  var userId = ''.obs;
  var email = ''.obs;
  var dob = ''.obs;
  var address1 = ''.obs;
  var address2 = ''.obs;
  var city = ''.obs;
  var zip = ''.obs;
  var country = ''.obs;
  var balance = ''.obs;
  var walletId = ''.obs;
  var kyc = ''.obs;
  var whatsapp = ''.obs;
  var isManager = ''.obs;
  RxInt currencyId = 1.obs; // Default to 1 (XAF)
  var orangeNumber = TextEditingController();
  var mtnNumber = TextEditingController();
  //var selectedImage = Rx<File?>(null);
  var avatar = Rxn<File>();
  var avatarUrl = ''.obs; // URL of the profile picture
  var verified = ''.obs;
  var id = ''.obs;
  var googleSecretCode = ''.obs;
  var enableGoogle2fa = false.obs;  // Google 2FA status
  var enableEmail2fa = false.obs;   // Email 2FA status
  var accountType = ''.obs;  // Account type field

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController address1Controller = TextEditingController();
  TextEditingController address2lController = TextEditingController();
  TextEditingController zipController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController whatsappController = TextEditingController();
  var isLoading = false.obs;
  late Future<Map<String, bool>> permissions;

  @override
  void onInit() {
    super.onInit();
    //fetchUserDetails(context);
    permissions = fetchPermissions();
  }

  Future<void> fetchUserDetails() async {
    final token = await getToken();
    if (token == null) {
      print('Token is null');
      final languageController = Get.find<LanguageController>();
      Get.snackbar(languageController.getTranslation('error'), 'UserProfile API: Token is null');
      return;
    }
    isLoading.value = true;
    //showLoadingSpinner(context);
    print('Verified Value before API Call: ${verified.value}');
    print('ID Value before API Call: ${id.value}');

    final url = '$baseUrl/api/getUserDetail';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Parsed Data: $data');
      final userDetails = data['message'];
      print('User Details: $userDetails');
      print('wallet_id: ${walletId.value}');

      // Update user details
      firstName.value = userDetails['first_name'] ?? '';
      lastName.value = userDetails['last_name'] ?? '';
      userName.value = userDetails['username'] ?? '';
      userId.value = userDetails['id']?.toString() ?? '';
      email.value = userDetails['email'] ?? '';
      dob.value = userDetails['dob'] ?? '';
      address1.value = userDetails['address_line_1'] ?? '';
      address2.value = userDetails['address_line_2'] ?? '';
      city.value = userDetails['city'] ?? '';
      zip.value = userDetails['zip_code'] ?? '';
      country.value = userDetails['country_name'] ?? '';
      whatsapp.value = userDetails['whatsapp'] ?? '';
      balance.value = userDetails['balance'] ?? '';
      walletId.value = userDetails['wallet_id']?.toString() ?? '';
      kyc.value = userDetails['is_kyc']?.toString() ?? '';
      isManager.value = userDetails['is_manager']?.toString() ?? '';
      currencyId.value = userDetails['currency_id'] ?? 1; // Default to 1 if null
      orangeNumber.text = userDetails['orange_number'] ?? '';
      mtnNumber.text = userDetails['mtn_number'] ?? '';
      avatarUrl.value = userDetails['avatar'] ?? '';
      verified.value = userDetails['verified']?.toString() ?? '';
      id.value = userDetails['id']?.toString() ?? '';
      // Fetch Google and Email 2FA status
      enableGoogle2fa.value = userDetails['enable_google2fa'] == 1;
      enableEmail2fa.value = userDetails['enable_email2fa'] == 1;
      googleSecretCode.value = userDetails['google2fa_secret']?.toString() ?? '';
      // Fetch Account Type
      accountType.value = userDetails['account_type'] ?? '';
      // Update Text Controllers
      firstNameController.text = firstName.value;
      lastNameController.text = lastName.value;
      userNameController.text = userName.value;
      emailController.text = email.value;
      dobController.text = dob.value;
      address1Controller.text = address1.value;
      address2lController.text = address2.value;
      cityController.text = city.value;
      countryController.text = country.value;
      whatsappController.text = whatsapp.value;
      zipController.text = zip.value;
      print('kyc_approved: ${kyc.value}');
      print('manager value: ${isManager.value}');
      // if (verified.value == '0') {
      //   print("Google Authenticator is enabled");
      // } else if (verified.value == '1') {
      //   print("Email Authentication is enabled");
      // } else {
         print("URL:${avatarUrl}");
      // }
      print('wallet_id: ${walletId.value}');
      // print('user_is: ${userId.value}');
      // Only fetch manager permissions if user is a manager
      if (isManager.value == '1') {
        final managerPermissionController = Get.find<ManagersPermissionController>();
        managerPermissionController.fetchManagerPermissions(userId.value);
      }
    } else {
      final languageController = Get.find<LanguageController>();
      Get.snackbar(languageController.getTranslation('error'), 'UserProfile API: Failed to load user details (Status: ${response.statusCode})');
      throw Exception('Failed to load user details');
    }
    isLoading.value=false;
  }

  Future<Map<String, bool>> fetchPermissions() async {
    try {
      String? token = await getToken();
      if (token == null) {
        throw Exception('Token is null');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/getPermissions'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'dashboard': data['dashboard'] == 1,
          'transferMoney': data['transferMoney'] == 1,
          'requestMoney': data['requestMoney'] == 1,
          'escrowSystem': data['escrowSystem'] == 1,
          // Add more permissions here as needed
        };
      } else {
        throw Exception('Failed to load permissions');
      }
    } catch (e) {
      print("Error fetching permissions: $e");
      return {};
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      avatar.value = File(image.path); // Update the observable with the new file
    }
  }

  Future<void> updateUserDetails() async {
    isLoading(true);

    final token = await getToken();
    if (token == null ) {
      final languageController = Get.find<LanguageController>();
      Get.snackbar(languageController.getTranslation('error'), 'Session expired. Please login again.');
      return;
    }

    final url = '$baseUrl/api/updateProfile';
    print('Request URL: $url');
    print('Authorization Token: Bearer $token');

    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers['Authorization'] = 'Bearer $token';

    if (firstName.value.isNotEmpty) {
      request.fields['first_name'] = firstName.value;
    }

    if (lastName.value.isNotEmpty) {
      request.fields['last_name'] = lastName.value;
    }

    if (avatar.value != null && avatar.value!.path.isNotEmpty) {
      print('Adding avatar file: ${avatar.value!.path}');
      request.files.add(await http.MultipartFile.fromPath('avatar', avatar.value!.path));
    } else if (avatarUrl.value.isNotEmpty) {
      // Pass the existing avatar URL from the API
      request.fields['avatar'] = avatarUrl.value;
      print("Passing avatar URL from API: ${avatarUrl.value}");
    } else {
      print("No avatar file or URL, skipping avatar upload.");
    }
    try {
      request.followRedirects = false; // Disable automatic redirects
      final response = await request.send();

      final responseBody = await response.stream.bytesToString();
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: $responseBody');

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        if (data['success'] == true) {
          final message = data['message'] ?? 'Profile updated successfully';
          final languageController = Get.find<LanguageController>();
          Get.snackbar(languageController.getTranslation('success'), message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,);
        } else {
          final languageController = Get.find<LanguageController>();
          Get.snackbar(languageController.getTranslation('error'), data['message'] ?? 'Failed to update user details');
        }
      } else if (response.statusCode == 302) {
        final redirectUrl = response.headers['location'];
        print('Unexpected redirection to: $redirectUrl');
        final languageController = Get.find<LanguageController>();
        Get.snackbar(languageController.getTranslation('error'), 'Redirected to: $redirectUrl',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,);
      } else {
        final languageController = Get.find<LanguageController>();
        String apiMessage;
        try {
          final data = jsonDecode(responseBody);
          apiMessage = data['message']?.toString() ?? 'Failed to update user details: ${response.reasonPhrase}';
        } catch (_) {
          apiMessage = 'Failed to update user details: ${response.reasonPhrase}';
        }
        Get.snackbar(languageController.getTranslation('error'), apiMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,);
        print('Error Response Body: $responseBody');
      }
    } catch (e) {
      final languageController = Get.find<LanguageController>();
      Get.snackbar(languageController.getTranslation('error'), 'An error occurred: $e');
      print('Exception: $e');
    } finally {
      isLoading(false);
    }
  }



  String getFormattedBalance() {
    final currencyAbbreviation = getCurrencyAbbreviation(currencyId.value);
    final doubleBalance = double.tryParse(balance.value) ?? 0.0; // Parse balance to double
    return '$currencyAbbreviation ${doubleBalance.toStringAsFixed(2)}';
  }


  /// Helper function to map currency_id to currency abbreviation
  String getCurrencyAbbreviation(int currencyId) {
    switch (currencyId) {
      case 1:
        return 'XAF';
      case 2:
        return 'USD';
      case 3:
        return 'BTC';
      default:
        return ''; // Empty string for unknown currencies
    }
  }


}

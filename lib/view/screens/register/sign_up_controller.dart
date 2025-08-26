import 'package:escrowcorner/view/screens/login/screen_login.dart';
import 'package:escrowcorner/widgets/custom_api_url/constant_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../dashboard/screen_dashboard.dart';
import '../../Home_Screens/screen_home.dart';
import 'package:escrowcorner/view/screens/register/screen_signup_otp_verification.dart';
import '../../controller/language_controller.dart';

class SignUpController extends GetxController {
  var isLoading = false.obs;
  var isChecked = false.obs;
  RxString countryCode = '+237'.obs;
  var siteDetails = {}.obs;
  var countryList = <Country>[].obs;
  var selectedCountry = ''.obs;
  
  // Language variables - synchronized with global language controller
  var selectedLanguage = 'English'.obs;
  var selectedLanguageId = 1.obs;
  var selectedLanguageLocale = 'en'.obs;

  final TextEditingController countrypic = TextEditingController();
  final TextEditingController countrycode = TextEditingController();
  final TextEditingController languagepic = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchCountries();
    // Do not auto-sync signup language with global header language; keep defaults until user selects
    languagepic.text = selectedLanguage.value;
  }

  @override
  void dispose() {
    nameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    emailController.dispose();
    countrypic.dispose();
    languagepic.dispose();
    super.dispose();
  }

  Future<void> fetchCountries() async {
    isLoading(true); // Start loading
    final url = '$baseUrl/api/get_country';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data'] is List) {
          List<dynamic> countries = data['data'];
          countryList.value = countries.map((country) => Country.fromJson(country)).toList();
          // Set Cameroon as default if present
          final cameroon = countryList.firstWhereOrNull((c) => c.name.toLowerCase().contains('cameroon'));
          if (cameroon != null) {
            selectedCountry.value = cameroon.name;
            countrypic.text = cameroon.name;
            countryCode.value = cameroon.dialCode;
            countrycode.text = cameroon.dialCode;
          }
        } else {
          print('Data key not found or not a list');
        }
      } else {
        print('Failed to fetch countries. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading(false); // Stop loading
    }
  }


   Future <void> signUp(BuildContext context) async {
    if (emailController.text.isEmpty ||
        nameController.text.isEmpty ||
        firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        phoneController.text.isEmpty ||
        isChecked == false ||
        countrycode.text.isEmpty ||
        selectedLanguage.value.isEmpty ||
        selectedLanguageLocale.value.isEmpty) {
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
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {

      final languageController = Get.find<LanguageController>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            languageController.getTranslation('password_mismatch'),
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
    isLoading(true);

    // Debug prints to track locale value
    print('Selected Language: ${selectedLanguage.value}');
    print('Selected Language ID: ${selectedLanguageId.value}');
    print('Selected Language Locale: ${selectedLanguageLocale.value}');

    // Always use the globally selected locale from the topbar header
    final languageController = Get.find<LanguageController>();
    final currentLocale = languageController.getCurrentLanguageLocale();
    final url = Uri.parse('$baseUrl/api/register/$currentLocale');
    final requestBody = {
      'email': emailController.text,
      'username': nameController.text,
      'first_name': firstNameController.text,
      'last_name': lastNameController.text,
      'password': passwordController.text,
      'repeat password': passwordController.text,
      'phone': phoneController.text,
      'CC': countryCode.value,
      'country_name': selectedCountry.value,
      'country_code': countrycode.text,
    };
    
    // Debug print the request body
    print('Request Body: $requestBody');
    
    final response = await http.post(url, body: requestBody);
    print('Status code:  [32m [1m [4m${response.statusCode} [0m');
    print('Response body: \n${response.body}');
    if (response.headers['content-type']?.contains('application/json') == true) {
      final responseData = jsonDecode(response.body);
      if (responseData['success']) {
        final languageController = Get.find<LanguageController>();
        final successMessage = responseData['message'] ?? languageController.getTranslation('user_registered');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(successMessage, style: TextStyle(color: Colors.white)),
          ),
        );
        // Navigate to OTP verification screen instead of login
        final otpMessage = responseData['otp_message'] ?? 'Enter the code sent to your email';
        final userId = responseData['user_id'];
        Get.offAll(() => SignupOtpVerificationScreen(), arguments: {'otpMessage': otpMessage, 'userId': userId});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      print('Unexpected response: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server error: Unexpected response'), backgroundColor: Colors.red),
      );
    }
    isLoading(false);
  }

  Future<bool> _checkAuthStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('authToken');
    return authToken != null;
  }
}

class Country {
  final String name;
  final String dialCode;

  Country({required this.name, required this.dialCode});

  // If you are getting country data from JSON, you can have a factory constructor as well:
  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'],
      dialCode: json['prefix'],  // Assuming 'prefix' holds the dial code in the API response
    );
  }
}




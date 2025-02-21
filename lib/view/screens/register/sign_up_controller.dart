import 'package:dacotech/view/screens/login/screen_login.dart';
import 'package:dacotech/widgets/custom_api_url/constant_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../dashboard/screen_dashboard.dart';
import '../../Home_Screens/screen_home.dart';

class SignUpController extends GetxController {
  var isLoading = false.obs;
  var isChecked = false.obs;
  RxString countryCode = '+237'.obs;
  var siteDetails = {}.obs;
  var countryList = <Country>[].obs;
  var selectedCountry = ''.obs;

  final TextEditingController countrypic = TextEditingController();
  final TextEditingController countrycode = TextEditingController();
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
        countrycode.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
    }
    isLoading(true);

    final url = Uri.parse('$baseUrl/api/register');
    final response = await http.post(url, body: {
      'email': emailController.text,
      'name': nameController.text,
      'first_name': firstNameController.text,
      'last_name': lastNameController.text,
      'password': passwordController.text,
      'repeat password': passwordController.text,
      'phone': phoneController.text,
      'CC': countryCode.value,
    });
    print("code:$countrycode");
    final responseData = jsonDecode(response.body);
    if (responseData['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User Registered Successfully')),
      );
      Get.offAll(ScreenLogin());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['message'])),
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


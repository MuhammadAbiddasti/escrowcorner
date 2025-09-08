import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import '../../../widgets/custom_token/constant_token.dart';
import '../../../widgets/custom_api_url/constant_url.dart';
import '../user_profile/user_profile_controller.dart';
import 'package:escrowcorner/view/controller/language_controller.dart';
import '../pdf_viewer_screen.dart';

class SettingController extends GetxController {
  var isLoading = false.obs;
  var charges = {}.obs;
  var depselectedRole = ''.obs; // Deposit charge payer
  var witselectedRole = ''.obs; // Withdrawal charge payer
  var allowApiWithdrawal = ''.obs;
  // var momoNumberController = TextEditingController();
  // var orangeNumberController = TextEditingController();
  var allowedIpsController = TextEditingController();
  var notifyDeposits = false.obs;
  var notifyWithdrawals = false.obs;
  var mtnLowBalanceController = TextEditingController();
  var orangeLowBalanceController = TextEditingController();
  
  // Site details variables
  var siteName = 'EscrowCorner'.obs;
  var siteTitle = ''.obs;
  var siteIcon = ''.obs;
  var siteLogo = ''.obs;
  var siteAddress = '123 Street, New York, USA'.obs;
  var siteContactNumber = '+01234567890'.obs;
  var siteAdminEmail = 'admin@admin.com'.obs;
  var siteOpeningHours = 'Monday - Friday 9:00 AM - 6:00 PM'.obs;
  var siteNewsletterTitle = 'Stay Updated'.obs;
  var siteNewsletter = 'Stay updated with our latest news and offers.'.obs;
  var termConditionPath = ''.obs;
  var privacyPolicyPath = ''.obs;
  var escrowDetailsPath = ''.obs;
  var socialLinks = <Map<String, dynamic>>[].obs;
  
  final UserProfileController userController = Get.put(UserProfileController());



  @override
  void onInit() {
    super.onInit();
    //fetchCharges(c);
    fetchSiteDetails(); // Fetch site details on initialization
    
    // Listen for language changes to refresh site details
    try {
      final languageController = Get.find<LanguageController>();
      ever(languageController.selectedLanguage, (_) {
        fetchSiteDetails(); // Refresh site details when language changes
      });
    } catch (e) {
      print('LanguageController not available yet: $e');
    }
  }
  
  // Fetch site details from API
  Future<void> fetchSiteDetails() async {
    try {
      // Get the current locale from LanguageController
      final languageController = Get.find<LanguageController>();
      final currentLocale = languageController.getCurrentLanguageLocale();
      
      final url = Uri.parse('$baseUrl/api/get_site_details/$currentLocale');
      print('=== FETCHING SITE DETAILS ===');
      print('URL: $url');
      print('Current locale: $currentLocale');
      
      final response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];
          siteName.value = data['site_name'] ?? 'EscrowCorner';
          siteTitle.value = data['title'] ?? '';
          siteIcon.value = data['site_icon'] ?? '';
          siteLogo.value = data['site_logo'] ?? '';
          siteAddress.value = data['address'] ?? '123 Street, New York, USA';
          siteContactNumber.value = data['contact_number'] ?? '+01234567890';
          siteAdminEmail.value = data['admin_email'] ?? 'admin@admin.com';
          siteOpeningHours.value = data['opening_hours'] ?? 'Monday - Friday 9:00 AM - 6:00 PM';
          siteNewsletterTitle.value = data['newsletter_title'] ?? 'Stay Updated';
          siteNewsletter.value = data['newsletter'] ?? 'Stay updated with our latest news and offers.';
          termConditionPath.value = data['term_condition_path'] ?? '';
          privacyPolicyPath.value = data['privacy_policy_path'] ?? '';
          escrowDetailsPath.value = data['escrow_details_path'] ?? '';
          
          print('=== TERMS AND CONDITIONS DEBUG ===');
          print('term_condition_path from API: "${data['term_condition_path']}"');
          print('termConditionPath.value after assignment: "${termConditionPath.value}"');
          print('privacy_policy_path from API: "${data['privacy_policy_path']}"');
          print('privacyPolicyPath.value after assignment: "${privacyPolicyPath.value}"');
          
                     // Parse social links - handle both possible field names
           if (data['social_links'] != null) {
             socialLinks.value = List<Map<String, dynamic>>.from(data['social_links']);
             print('Social links loaded from "social_links": ${socialLinks.length} links');
           } else if (data['social_lnks'] != null) {
             socialLinks.value = List<Map<String, dynamic>>.from(data['social_lnks']);
             print('Social links loaded from "social_lnks": ${socialLinks.length} links');
           } else {
             print('No social links found in API response. Available keys: ${data.keys.toList()}');
           }
           
           if (socialLinks.isNotEmpty) {
             print('=== SOCIAL LINKS DEBUG INFO ===');
             for (var link in socialLinks) {
               print('Social link: ${link['url']}');
               print('  - Icon filename: ${link['icon']}');
               print('  - Full icon URL: $baseUrl/assets/social/${link['icon']}');
               print('  - Alternative URLs:');
               print('    * $baseUrl/storage/social/${link['icon']}');
               print('    * $baseUrl/images/social/${link['icon']}');
               print('    * $baseUrl/uploads/social/${link['icon']}');
               print('    * $baseUrl/public/assets/social/${link['icon']}');
               print('---');
             }
           }
           
           print('Site details loaded: ${siteName.value}');
        } else {
          print('API response success is false or data is null');
          print('Response: $jsonResponse');
        }
      } else {
        print('Failed to load site details: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching site details: $e');
      // Keep default values on error
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

  // Method to open terms and conditions PDF in-app
  Future<void> openTermsAndConditions() async {
    print('=== TERMS AND CONDITIONS DEBUG ===');
    print('termConditionPath.value: "${termConditionPath.value}"');
    print('termConditionPath.isEmpty: ${termConditionPath.value.isEmpty}');
    
    // Always ensure we have the latest data
    if (termConditionPath.value.isEmpty) {
      print('Terms and conditions path is empty, fetching site details...');
      // Show loading indicator
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xff2E7D32)),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff666565),
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
      
      // Try to fetch site details first
      await fetchSiteDetails();
      
      // Close loading dialog
      Get.back();
      
      if (termConditionPath.value.isEmpty) {
        // Use a fallback URL if API doesn't provide one
        termConditionPath.value = 'https://escrowcorner.com/assets/uploads/terms_conditions/17557707298000.pdf';
        print('Using fallback URL: ${termConditionPath.value}');
      }
    }

    try {
      print('Attempting to open PDF in-app: ${termConditionPath.value}');
      final Uri url = Uri.parse(termConditionPath.value);
      
      // Navigate to PDF viewer screen
      final languageController = Get.find<LanguageController>();
      Get.to(() => PDFViewerScreen(pdfUrl: termConditionPath.value, title: languageController.getTranslation('terms_and_conditions')));
      
    } catch (e) {
      print('Error opening terms and conditions: $e');
      Get.snackbar(
        'Error',
        'Could not open terms and conditions: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Method to open privacy policy PDF in-app
  Future<void> openPrivacyPolicy() async {
    print('=== PRIVACY POLICY DEBUG ===');
    print('privacyPolicyPath.value: "${privacyPolicyPath.value}"');
    print('privacyPolicyPath.isEmpty: ${privacyPolicyPath.value.isEmpty}');
    
    // Always ensure we have the latest data
    if (privacyPolicyPath.value.isEmpty) {
      print('Privacy policy path is empty, fetching site details...');
      // Show loading indicator
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xff2E7D32)),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff666565),
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
      
      // Try to fetch site details first
      await fetchSiteDetails();
      
      // Close loading dialog
      Get.back();
      
      if (privacyPolicyPath.value.isEmpty) {
        // Use a fallback URL if API doesn't provide one
        privacyPolicyPath.value = 'https://escrowcorner.com/assets/uploads/privacy_policy/privacy_policy.pdf';
        print('Using fallback URL: ${privacyPolicyPath.value}');
      }
    }

    try {
      print('Attempting to open privacy policy PDF in-app: ${privacyPolicyPath.value}');
      final Uri url = Uri.parse(privacyPolicyPath.value);
      
      // Navigate to PDF viewer screen
      final languageController = Get.find<LanguageController>();
      Get.to(() => PDFViewerScreen(pdfUrl: privacyPolicyPath.value, title: languageController.getTranslation('privacy_policy')));
      
    } catch (e) {
      print('Error opening privacy policy: $e');
      Get.snackbar(
        'Error',
        'Could not open privacy policy: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Method to open escrow details PDF in-app
  Future<void> openEscrowDetails() async {
    print('=== ESCROW DETAILS DEBUG ===');
    print('escrowDetailsPath.value: "${escrowDetailsPath.value}"');
    print('escrowDetailsPath.isEmpty: ${escrowDetailsPath.value.isEmpty}');
    
    // Always ensure we have the latest data
    if (escrowDetailsPath.value.isEmpty) {
      print('Escrow details path is empty, fetching site details...');
      // Show loading indicator
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xff2E7D32)),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff666565),
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
      
      // Try to fetch site details first
      await fetchSiteDetails();
      
      // Close loading dialog
      Get.back();
      
      if (escrowDetailsPath.value.isEmpty) {
        // Use a fallback URL if API doesn't provide one
        escrowDetailsPath.value = 'https://escrowcorner.com/assets/uploads/escrow_details/escrow_guide.pdf';
        print('Using fallback URL: ${escrowDetailsPath.value}');
      }
    }

    try {
      print('Attempting to open escrow details PDF in-app: ${escrowDetailsPath.value}');
      final Uri url = Uri.parse(escrowDetailsPath.value);
      
      // Navigate to PDF viewer screen
      final languageController = Get.find<LanguageController>();
      Get.to(() => PDFViewerScreen(pdfUrl: escrowDetailsPath.value, title: languageController.getTranslation('what_is_escrow_and_how_does_it_work')));
      
    } catch (e) {
      print('Error opening escrow details: $e');
      Get.snackbar(
        'Error',
        'Could not open escrow details: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }


  Future<void> fetchCharges(BuildContext context) async {
    isLoading.value = true;

    String? token = await getToken(); // Implement your getToken method
    if (token == null) {
      isLoading.value = false;
      return;
    }

    final url = Uri.parse('$baseUrl/api/settingCharges');
    showLoadingSpinner(context);
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print('charges: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Handle user settings if present
        if (jsonResponse['userSetting'] != null) {
          notifyDeposits.value =
              jsonResponse['userSetting']['app_email_notify_deposits'] == 1;
          notifyWithdrawals.value =
              jsonResponse['userSetting']['app_email_notify_withdrawals'] == 1;

          depselectedRole.value = jsonResponse['userSetting']['who_pay_deposit_charge'] == 1
              ? 'Merchant'
              : 'Customer';
          witselectedRole.value = jsonResponse['userSetting']['who_pays_withdrawal_charge'] == 1
              ? 'Merchant'
              : 'Customer';

          allowApiWithdrawal.value =
          jsonResponse['userSetting']['allow_api_withdrawal'] == 1
              ? 'Yes'
              : (jsonResponse['userSetting']['allow_api_withdrawal'] == 0
              ? 'No'
              : 'No'); // Handle null as 'No'
        }

        charges.value = {
          'mtn_deposit_percentage_fee': int.tryParse(
              jsonResponse['mtn_deposit_percentage_fee'] ?? '0') ??
              0,
          'mtn_withdraw_percentage_fee': int.tryParse(
              jsonResponse['mtn_withdraw_percentage_fee'] ?? '0') ??
              0,
          'orange_deposit_percentage_fee': int.tryParse(
              jsonResponse['orange_deposit_percentage_fee'] ?? '0') ??
              0,
          'orange_withdraw_percentage_fee': int.tryParse(
              jsonResponse['orange_withdraw_percentage_fee'] ?? '0') ??
              0,
          'usdt_deposit_percentage_fee': int.tryParse(
              jsonResponse['usdt_deposit_percentage_fee'] ?? '0') ??
              0,
          'usdt_withdraw_percentage_fee': int.tryParse(
              jsonResponse['usdt_withdraw_percentage_fee'] ?? '0') ??
              0,
          'btc_deposit_percentage_fee': int.tryParse(
              jsonResponse['btc_deposit_percentage_fee'] ?? '0') ??
              0,
          'btc_withdraw_percentage_fee': int.tryParse(
              jsonResponse['btc_withdraw_percentage_fee'] ?? '0') ??
              0,
        };
      } else {
        throw Exception('Failed to load charges');
      }
    } catch (e) {
      print('Error: $e');
      charges.value = {};
    } finally {
      isLoading.value = false;
      Navigator.pop(context);
    }
  }


  Future<void> payDepositCharge(BuildContext context) async {
    isLoading.value = true;

    String? token = await getToken(); // Implement your getToken method
    if (token == null) {
      //Get.snackbar('Error', 'Token is null');
      isLoading.value = false;
      return;
    }
    showLoadingSpinner(context);

    final url = Uri.parse('$baseUrl/api/pay_deposit_charge');
    final String previousValue = depselectedRole.value; // Log previous value

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'who_pay_deposit_charge': depselectedRole.value}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        String message = jsonResponse['updated']['original']['message'].toString();

        // Force update the radio button value in case of any manual adjustments
        depselectedRole.refresh(); // Manually trigger the GetX observable update
        final languageController = Get.find<LanguageController>();
        Get.snackbar(languageController.getTranslation('success'), message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,);
      } else {
        throw Exception('Failed to update deposit charge');
      }
    } catch (e) {
      final languageController = Get.find<LanguageController>();
      Get.snackbar(languageController.getTranslation('error'), 'Failed to process the request',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,);
      print('Error updating deposit charge: $e');
    } finally {
      isLoading.value = false;
      Navigator.pop(context);

    }
  }

  Future<void> payWithdrawalCharge(BuildContext context) async {
    isLoading.value = true;

    String? token = await getToken(); // Implement your getToken method
    if (token == null) {
     // Get.snackbar('Error', 'Token is null');
      isLoading.value = false;
      return;
    }
    showLoadingSpinner(context);

    final url = Uri.parse('$baseUrl/api/pay_withdrawal_charge');
    final String previousValue = witselectedRole.value; // Log previous value

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'who_pays_withdrawal_charge': witselectedRole.value}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        String message = jsonResponse['updated']['original']['message'].toString();
        // Force update the radio button value in case of any manual adjustments
        witselectedRole.refresh(); // Manually trigger the GetX observable update
        final languageController = Get.find<LanguageController>();
        Get.snackbar(languageController.getTranslation('success'), message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,);
      } else {
        throw Exception('Failed to update withdrawal charge');
      }
    } catch (e) {
      final languageController = Get.find<LanguageController>();
      Get.snackbar(languageController.getTranslation('error'), 'Failed to process the request',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,);
      print('Error updating withdrawal charge: $e');
    } finally {
      isLoading.value = false;
      Navigator.pop(context);

    }
  }

  Future<void> payBothCharges(BuildContext context) async {
    isLoading.value = true;
    await payDepositCharge(context);
    await payWithdrawalCharge(context);
    isLoading.value = false;
  }

  Future<void> setApiWithdrawal() async {
    isLoading.value = true;

    String? token = await getToken();
    if (token == null) {
      //Get.snackbar('Error', 'Token is null');
      isLoading.value = false;
      return;
    }

    final url = Uri.parse('$baseUrl/api/withdrawal_api');

    // Convert the value based on 'Yes' or 'No'
    String apiWithdraw = allowApiWithdrawal.value == 'Yes' ? '1' :
    (allowApiWithdrawal.value == 'No' ? '0' : 'null');

    print('Request Payload: $apiWithdraw'); // Debug log

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'allow_api_withdrawal': apiWithdraw,
        }),
      );

      print("Response Body: ${response.body}"); // Debug log

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true) {
          // Update local state after successful save
          final languageController = Get.find<LanguageController>();
          Get.snackbar(languageController.getTranslation('success'), "Settings updated successfully!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,);

          // Update the current role values (ensure UI reflects changes)
          allowApiWithdrawal.value = apiWithdraw == '1' ? 'Yes' : (apiWithdraw == '0' ? 'No' : ''); // For null case
          print("Updated State -> allow_api: ${allowApiWithdrawal.value}");
        } else {
          throw Exception('Server update failed');
        }
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
      final languageController = Get.find<LanguageController>();
      Get.snackbar(languageController.getTranslation('error'), 'Failed to update settings',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveMtnNumber() async {
    isLoading.value = true;

    // Get the token for authorization
    String? token = await getToken();
    if (token == null) {
      //Get.snackbar('Error', 'Token is null');
      isLoading.value = false;
      return;
    }

    // Get the updated number from the controller
    String updatedNumber = userController.mtnNumber.text.trim();


    // Ensure the updated number is not empty
    if (updatedNumber.isEmpty || updatedNumber.length != 10) {
      final languageController = Get.find<LanguageController>();
      Get.snackbar(languageController.getTranslation('error'), 'Please enter a valid 10-digit MTN MoMo number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,);
      isLoading.value = false;
      return;
    }

    final url = Uri.parse('$baseUrl/api/mtn_momo_withdrawal_number');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'mtn_momo_number': updatedNumber, // Send the updated number to the server
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        String message = jsonResponse['message'] ?? 'MoMo number updated successfully';
        final languageController = Get.find<LanguageController>();
        Get.snackbar(languageController.getTranslation('success'), message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,);
      } else {
        final Map<String, dynamic> errorResponse = jsonDecode(response.body);
        String errorMessage = errorResponse['message'] ?? 'Failed to update MTN MoMo number';
        final languageController = Get.find<LanguageController>();
        Get.snackbar(languageController.getTranslation('error'), errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,);
      }
    } catch (e) {
      final languageController = Get.find<LanguageController>();
      Get.snackbar(languageController.getTranslation('error'), 'Failed to update: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveOrangeNumber() async {
    isLoading.value = true;

    String? token = await getToken(); // Implement your getToken method
    if (token == null) {
     // Get.snackbar('Error', 'Token is null');
      isLoading.value = false;
      return;
    }

    String updatedNumber = userController.orangeNumber.text.trim();


    // Ensure the updated number is not empty
    if (updatedNumber.isEmpty || updatedNumber.length != 10) {
      final languageController = Get.find<LanguageController>();
      Get.snackbar(languageController.getTranslation('error'), 'Please enter a valid 10-digit MTN MoMo number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      isLoading.value = false;
      return;
    }

    final url = Uri.parse('$baseUrl/api/orange_money_withdrawal_number');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'orange_money_number': updatedNumber
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        String message = jsonResponse['message'] ?? 'MoMo number updated successfully';
        final languageController = Get.find<LanguageController>();
        Get.snackbar(languageController.getTranslation('success'), message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,);
      } else {
        final Map<String, dynamic> errorResponse = jsonDecode(response.body);
        String errorMessage = errorResponse['message'] ?? 'Failed to update MTN MoMo number';
        final languageController = Get.find<LanguageController>();
        Get.snackbar(languageController.getTranslation('error'), errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,);
      }
    } catch (e) {
      final languageController = Get.find<LanguageController>();
      Get.snackbar(languageController.getTranslation('error'), 'Failed to process the request',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveAllowedIps() async {
    isLoading.value = true;

    String? token = await getToken(); // Implement your getToken method
    if (token == null) {
      //Get.snackbar('Error', 'Token is null');
      isLoading.value = false;
      return;
    }

    final url = Uri.parse('$baseUrl/api/api_allowed_ips');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'allowed_ips': allowedIpsController.text}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        String message = jsonResponse['updated']['original']['message'].toString();

        // Handle the response as needed
        final languageController = Get.find<LanguageController>();
        Get.snackbar(languageController.getTranslation('success'), "$message",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,);
      } else {
        throw Exception('Failed to save allowed IPs');
      }
    } catch (e) {
      final languageController = Get.find<LanguageController>();
      Get.snackbar(languageController.getTranslation('error'), 'Failed to process the request',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,);
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> saveDepositAlert() async {
  //   isLoading.value = true;
  //
  //   String? token = await getToken();
  //   if (token == null) {
  //     Get.snackbar('Error', 'Token is null');
  //     isLoading.value = false;
  //     return;
  //   }
  //
  //   final url = Uri.parse('$baseUrl/api/deposit_email_alerts');
  //
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({
  //         'app_email_notify_deposits': notifyDeposits.value ? '1' : '0',
  //       }),
  //     );
  //
  //     print("Response Body: ${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
  //
  //       // Assume successful update and toggle the local value
  //       if (jsonResponse['success'] == true) {
  //         notifyDeposits.value = !notifyDeposits.value;
  //         Get.snackbar("Success", "Deposit alert updated successfully!");
  //       } else {
  //         throw Exception('Update failed on server');
  //       }
  //     } else {
  //       throw Exception('Failed to save deposit alert');
  //     }
  //   } catch (e) {
  //     print("Error: $e");
  //     Get.snackbar('Error', 'Failed to update deposit alert');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
  //
  // Future<void> saveWithdrawalAlert() async {
  //   isLoading.value = true;
  //
  //   String? token = await getToken();
  //   if (token == null) {
  //     Get.snackbar('Error', 'Token is null');
  //     isLoading.value = false;
  //     return;
  //   }
  //
  //   final url = Uri.parse('$baseUrl/api/withdrawal_email_alerts');
  //
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({
  //         'app_email_notify_withdrawals': notifyWithdrawals.value ? '1' : '0', // Send the current checkbox value
  //       }),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
  //       String message = jsonResponse['updated']['original']['message'].toString();
  //
  //       // Show success message
  //       Get.snackbar("Success", message);
  //     } else {
  //       throw Exception('Failed to save withdrawal alert');
  //     }
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to update withdrawal alert');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> saveMtnLowBalance() async {
    isLoading.value = true;
    final languageController = Get.find<LanguageController>();
    Get.snackbar(languageController.getTranslation('success'), "Update Successfully");
    String? token = await getToken(); // Implement your getToken method
    if (token == null) {
      //Get.snackbar('Error', 'Token is null');
      isLoading.value = false;
      return;
    }

    final url = Uri.parse('$baseUrl/api/mtn_low_balance');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'mtn_low_amount': mtnLowBalanceController.text}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Handle the response as needed
        final languageController = Get.find<LanguageController>();
        Get.snackbar(languageController.getTranslation('success'), "$jsonResponse",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,);
      } else {
        throw Exception('Failed to save MTN low balance amount');
      }
    } catch (e) {
      final languageController = Get.find<LanguageController>();
      Get.snackbar(languageController.getTranslation('error'), 'Failed to process the request',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveOrangeLowBalance() async {
    isLoading.value = true;

    String? token = await getToken(); // Implement your getToken method
    if (token == null) {
      //Get.snackbar('Error', 'Token is null');
      isLoading.value = false;
      return;
    }

    final url = Uri.parse('$baseUrl/api/orange_low_balance');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'orange_low_amount': orangeLowBalanceController.text}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Handle the response as needed
        final languageController = Get.find<LanguageController>();
        Get.snackbar(languageController.getTranslation('success'), "$jsonResponse",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,);
      } else {
        throw Exception('Failed to save Orange low balance amount');
      }
    } catch (e) {
      final languageController = Get.find<LanguageController>();
      Get.snackbar(languageController.getTranslation('error'), 'Failed to process the request',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,);
    } finally {
      isLoading.value = false;
    }
  }

// Method of Email Alerts
  Future<void> saveEmailAlerts() async {
    isLoading.value = true;

    String? token = await getToken();
    if (token == null) {
      //Get.snackbar('Error', 'Token is null');
      isLoading.value = false;
      return;
    }

    final url = Uri.parse('$baseUrl/api/save_setting'); // Assume single API endpoint for both
    final depositValue = notifyDeposits.value ? '1' : '0';
    final withdrawalValue = notifyWithdrawals.value ? '1' : '0';

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'app_email_notify_deposits': depositValue,
          'app_email_notify_withdrawals': withdrawalValue,
        }),
      );

      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true) {
          final message = (jsonResponse['updated']?['original']?['message']?.toString())
              ?? jsonResponse['message']?.toString()
              ?? 'Email alerts updated successfully!';
          final languageController = Get.find<LanguageController>();
          Get.snackbar(languageController.getTranslation('success'), message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,);

          // Update local state to reflect changes
          notifyDeposits.value = depositValue == '1';
          notifyWithdrawals.value = withdrawalValue == '1';

          print(
              "Updated State -> Deposits: ${notifyDeposits.value}, Withdrawals: ${notifyWithdrawals.value}");
        } else {
          throw Exception('Server update failed');
        }
      } else {
        throw Exception('Failed to save email alerts');
      }
    } catch (e) {
      print("Error: $e");
      final languageController = Get.find<LanguageController>();
      Get.snackbar(languageController.getTranslation('error'), 'Failed to update email alerts',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,);
    } finally {
      isLoading.value = false;
    }
  }

// Method who pay deposit or withdraw charges
  Future<void> savePayCharges() async {
    isLoading.value = true;

    String? token = await getToken();
    if (token == null) {
      //Get.snackbar('Error', 'Token is null');
      isLoading.value = false;
      return;
    }

    final url = Uri.parse('$baseUrl/api/save_setting'); // Single endpoint
    final depositCharges = depselectedRole.value == 'Merchant' ? '1' : '2';
    final withdrawalCharges = witselectedRole.value == 'Merchant' ? '1' : '2';

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'who_pay_deposit_charge': depositCharges,
          'who_pays_withdrawal_charge': withdrawalCharges,
        }),
      );

      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true) {
          // Update local state after successful save
          final languageController = Get.find<LanguageController>();
          Get.snackbar(languageController.getTranslation('success'), "Settings updated successfully!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,);

          // Update the current role values (ensure UI reflects changes)
          depselectedRole.value =
          depositCharges == '1' ? 'Merchant' : 'Customer';
          witselectedRole.value =
          withdrawalCharges == '1' ? 'Merchant' : 'Customer';

          print(
              "Updated State -> deposit_charge: ${depselectedRole.value}, withdrawal_charge: ${witselectedRole.value}");
        } else {
          throw Exception('Server update failed');
        }
      } else {
        throw Exception('Failed to save settings');
      }
    } catch (e) {
      print("Error: $e");
      final languageController = Get.find<LanguageController>();
      Get.snackbar(languageController.getTranslation('error'), 'Failed to update settings',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,);
    } finally {
      isLoading.value = false;
    }
  }



}
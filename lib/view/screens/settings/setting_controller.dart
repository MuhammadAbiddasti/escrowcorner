import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../widgets/custom_token/constant_token.dart';
import '../../../widgets/custom_api_url/constant_url.dart';
import '../user_profile/user_profile_controller.dart';

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
  final UserProfileController userController = Get.put(UserProfileController());



  @override
  void onInit() {
    super.onInit();
    //fetchCharges(c);
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
        Get.snackbar("Success", "$message",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,);
      } else {
        throw Exception('Failed to update deposit charge');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to process the request',
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
        Get.snackbar("Success", "$message",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,);
      } else {
        throw Exception('Failed to update withdrawal charge');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to process the request',
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
          Get.snackbar("Success", "Settings updated successfully!",
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
      Get.snackbar('Error', 'Failed to update settings',
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
      Get.snackbar('Error', 'Please enter a valid 10-digit MTN MoMo number',
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
        Get.snackbar("Success", message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,);
      } else {
        final Map<String, dynamic> errorResponse = jsonDecode(response.body);
        String errorMessage = errorResponse['message'] ?? 'Failed to update MTN MoMo number';
        Get.snackbar('Error', errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update: $e',
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
      Get.snackbar('Error', 'Please enter a valid 10-digit MTN MoMo number',
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
        Get.snackbar("Success", message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,);
      } else {
        final Map<String, dynamic> errorResponse = jsonDecode(response.body);
        String errorMessage = errorResponse['message'] ?? 'Failed to update MTN MoMo number';
        Get.snackbar('Error', errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to process the request',
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
        Get.snackbar("Success", "$message",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,);
      } else {
        throw Exception('Failed to save allowed IPs');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to process the request',
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
    Get.snackbar("Success", "Update Successfully");
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
        Get.snackbar("Success", "$jsonResponse",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,);
      } else {
        throw Exception('Failed to save MTN low balance amount');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to process the request',
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
        Get.snackbar("Success", "$jsonResponse",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,);
      } else {
        throw Exception('Failed to save Orange low balance amount');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to process the request',
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
          // Show success message only once
          Get.snackbar("Success", "Email alerts updated successfully!",
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
      Get.snackbar('Error', 'Failed to update email alerts',
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
          Get.snackbar("Success", "Settings updated successfully!",
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
      Get.snackbar('Error', 'Failed to update settings',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,);
    } finally {
      isLoading.value = false;
    }
  }



}
import 'dart:developer';
import 'package:dacotech/view/screens/managers/manager_permission_controller.dart';
import 'package:dacotech/view/screens/payment_links/payment_link_controller.dart';
import 'package:dacotech/view/screens/settings/setting_controller.dart';
import 'package:dacotech/view/screens/tickets/ticket_controller.dart';
import 'package:dacotech/view/screens/Transactions/transaction_controller.dart';
import 'package:dacotech/view/screens/user_profile/user_profile_controller.dart';
import 'package:dacotech/view/screens/virtual_cards/virtualcard_controller.dart';
import 'package:dacotech/view/controller/wallet_controller.dart';
import 'package:dacotech/view/screens/withdraw/withdrawal_controller.dart';
import 'package:dacotech/widgets/custom_token/constant_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../main.dart';
import '../../widgets/custom_api_url/constant_url.dart';
import '../Home_Screens/screen_home.dart';
import '../screens/applications/merchant_controller.dart';
import '../screens/login/screen_login.dart';
import '../screens/managers/controller_managers.dart';
import '../screens/request_money/controller_requestmoney.dart';
import '../screens/send_money/controller_sendmoney.dart';
import '../screens/dashboard/dashboard_controller.dart';
import '../screens/login/login_controller.dart';
import '../screens/login/login_history_controller.dart';
import '../screens/deposit/mydeposit_controller.dart';

class LogoutController extends GetxController {
  var isLoading = false.obs;
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = await getToken();

    if (token == null) {
      Get.snackbar(
        'Error',
        'Token not found, please log in again',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    final url = '$baseUrl/api/logout';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          await prefs.clear();
          log("Token cleared: $token");
          showLoadingSpinner(context);
          // Use Future.delayed or WidgetsBinding to ensure navigation happens after the current frame
          Future.delayed(Duration(milliseconds: 100), () {
            Get.offAll(() => ScreenHome());
          });

          Get.snackbar(
            'Success',
            'Logged out successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            'Logout failed: ${responseData['message']}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to logout: ${response.statusCode}',
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
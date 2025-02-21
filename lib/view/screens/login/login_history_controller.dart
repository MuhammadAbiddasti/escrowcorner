import 'package:dacotech/widgets/custom_token/constant_token.dart';
import 'package:dacotech/widgets/custom_api_url/constant_url.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginHistoryController extends GetxController {
  var isLoading = false.obs;
  var loginHistory = [].obs; // This will store the list of login history

  Future<void> fetchLoginDetails(BuildContext context) async {
    final token = await getToken();
    if (token == null) {
      Get.snackbar("Error", "Token is Null, please login again");
      isLoading(false);
      return;
    }

    try {
      isLoading(true); // Start loading
      showLoadingSpinner(context);
      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/api/logindetail'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          loginHistory.value = (data['data'] as List).reversed.toList();
          print('Final Login History: ${loginHistory.length}');
        } else {
          print('Unexpected data format');
        }
      } else {
        print('Failed to fetch login details: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading(false);
      Navigator.pop(context);

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

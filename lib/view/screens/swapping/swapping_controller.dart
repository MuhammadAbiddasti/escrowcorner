import 'dart:convert';
import 'package:dacotech/widgets/custom_token/constant_token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../../../widgets/custom_api_url/constant_url.dart';

class SwappingController extends GetxController {
  var isLoading = false.obs;
  var exchangeResult = ''.obs;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController toCurrencyController  = TextEditingController();

  Future<Map<String, dynamic>> swapCurrency({
    required int fromCurrencyId,
    required int toCurrencyId,
  }) async {
    isLoading(true);
    String? token = await getToken();
    final amount = amountController.text;

    print("Starting currency swap...");
    print("From Currency ID: $fromCurrencyId");
    print("To Currency ID: $toCurrencyId");
    print("Amount: $amount");

    try {
      final url = Uri.parse("$baseUrl/api/swap_currency");
      print("Request URL: $url");

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      print("Headers: $headers");

      final body = jsonEncode({
        'from_currency_id': fromCurrencyId,
        'to_currency_id': toCurrencyId,
        'from_currency_amount': amount,
      });
      print("Request Body: $body");

      final response = await http.post(url, headers: headers, body: body);

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Parsed Response Data: $data");

        if (data['success'] == true) {
          print("Currency swap successful.");
          return data;
        } else {
          print("Currency swap failed with message: ${data['message']}");
          throw Exception(data['message'] ?? "Failed to swap currency");
        }
      } else {
        print("HTTP error occurred: ${response.statusCode}");
        print("Error Body: ${response.body}");
        throw Exception("Error: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Exception caught: $e");
      rethrow;
    } finally {
      print("Currency swap process complete.");
      isLoading(false);
    }
  }

  // Method to perform currency exchange
  Future<void> currencyExchange({
    required String fromCurrencyId,
    required String toCurrencyId,
    required String amount,
  }) async {
    isLoading.value = true;

    String? token = await getToken();
    if (token == null) {
      isLoading.value = false;
      exchangeResult.value = 'Authentication token not found';
      return;
    }

    String url =
        "$baseUrl/api/currency_exchange?from_currency_id=$fromCurrencyId&to_currency_id=$toCurrencyId&amount=$amount";

    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        exchangeResult.value =
        'Exchange Successful: ${responseData['converted_amount']}';
      } else if (response.statusCode == 404) {
        var responseData = jsonDecode(response.body);

        // Show SnackBar with error message
        Get.snackbar(
          "Error",
          responseData['message'] ?? 'Exchange rate not found for the selected currencies',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        // Set the exchange result as empty
        exchangeResult.value = '';
      } else {
        exchangeResult.value =
        'Error: ${response.statusCode} - ${jsonDecode(response.body)['message'] ?? 'Something went wrong'}';
      }
    } catch (e) {
      print("Exception: $e");
      exchangeResult.value = 'Exception: $e';
    } finally {
      isLoading.value = false;
    }
  }



  Future<void> fetchExchangeRate({
    required int fromCurrencyId,
    required int toCurrencyId,
    required double amount,
  }) async {
    await currencyExchange(
      fromCurrencyId: fromCurrencyId.toString(),
      toCurrencyId: toCurrencyId.toString(),
      amount: amount.toString(),
    );
    // Use `exchangeResult` directly for display or further processing.
    // For example:
    print("Exchange Result: ${exchangeResult.value}");
  }

}

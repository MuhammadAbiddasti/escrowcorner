import 'package:escrowcorner/view/screens/send_money/screen_get_all_sendmoney.dart';
import 'package:escrowcorner/widgets/custom_api_url/constant_url.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../widgets/custom_token/constant_token.dart';

class SendMoneyController extends GetxController {
  var isLoading = false.obs;
  // Assuming Currency is your model class
  var currencies = <Currency>[].obs; // List of Currency
  var selectedCurrency = Rx<Currency?>(null); // Single selected Currency or Method
  RxList<SendMoney> sendMoneyList = <SendMoney>[].obs;
  var currentPage = 1.obs;
  var perPage = 10.obs;
  var totalEntries = 0.obs;
  var totalPages = 0.obs;
  var unreadRequestMoneyCount = 0.obs;
  var unreadSupportTicketCount = 0.obs;

  var paymentMethods = <PaymentMethod>[].obs;
  var selectedPaymentMethod = Rxn<PaymentMethod>();


  final emailController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final methodController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchAllSendMoney();
    fetchSendmoneyCurrencies();
    fetchPaymentMethods();
  }
  // Method to Send Money
  Future<void> sendMoney(BuildContext context) async {

    if (selectedCurrency.value == null) {
      Get.snackbar('Message', 'Select a valid method',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      isLoading.value = false;
      return;
    }
    if (amountController.text.isEmpty) {
      Get.snackbar('Message', 'Enter amount',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      isLoading.value = false;
      return;
    }
    if (emailController.text.isEmpty) {
      Get.snackbar('Message', 'Enter a valid email',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      isLoading.value = false;
      return;
    }
    if (noteController.text.isEmpty) {
      Get.snackbar('Message', 'Note for recipient is required',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      isLoading.value = false;
      return;
    }

    final amount = amountController.text;
    final email = emailController.text;
    final note = noteController.text;
    final currencyId = selectedCurrency.value!.id;
    final paymentMethodId = selectedPaymentMethod.value?.id?.toString() ?? '';
    print('Selected Payment Method:  [32m [1m [4m${selectedPaymentMethod.value} [0m');
    print('Payment Method ID sent to API: $paymentMethodId');

    final body = json.encode({
      'currency': currencyId.toString(),
      'amount': amount,
      'email': email,
      'description': note,
      'method_id': paymentMethodId,
    });
    print('Request body: $body');

    String? token = await getToken();
    if (token == null) {
      Get.snackbar('Error', 'Token is null',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final url = Uri.parse('$baseUrl/api/sendMoney');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      isLoading.value = true;

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Check if success is true
        if (responseData['success'] == true) {
          Get.snackbar(
            'Success',
            responseData['message'] ?? 'Money sent successfully.',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          await fetchAllSendMoney(); // Optionally fetch data again
          Get.off(() => ScreenGetAllSendMoney()); // Navigate to the next screen
          clearFields(); // Clear fields after success
        } else {
          Get.snackbar(
            'Error',
            responseData['message'] ?? 'An error occurred.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else if (response.statusCode == 422) {
        final errorData = jsonDecode(response.body);
        print("error: ${response.body}");

        // Extract the first error message
        String errorMessage = errorData['errors'].values
            .map((errors) => errors.join(', '))
            .join('\n'); // Combine all error messages into a single string

        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      else {
        Get.snackbar(
          'Error',
          'Failed with status code: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An exception occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  // Method to fetch all Send Money
  Future<void> fetchAllSendMoney({int page = 1}) async {
    try {
      isLoading(true);

      String? token = await getToken();
      if (token == null) {
        throw Exception('Token is null');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/allSendMoney?page=$page'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true) {
          List<dynamic> data = jsonResponse['message']['data'] ?? [];
          List<SendMoney> fetchedSendMoney =
          data.map((item) => SendMoney.fromJson(item)).toList();

          sendMoneyList.value = fetchedSendMoney;

          currentPage.value = jsonResponse['message']['current_page'] ?? 1;
          perPage.value = jsonResponse['message']['per_page'] ?? 10;
          totalEntries.value = jsonResponse['message']['total'] ?? 0;

          // Calculate total pages
          totalPages.value = (totalEntries.value / perPage.value).ceil();

          // Update navigation button states
          hasPreviousPage.value = currentPage.value > 1;
          hasNextPage.value = currentPage.value < totalPages.value;

          print("Page ${currentPage.value} of ${totalPages.value}");
          print("Has Next: ${hasNextPage.value} | Has Previous: ${hasPreviousPage.value}");

        } else {
          throw Exception('Failed to fetch data: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading(false);
    }
  }

  var hasPreviousPage = false.obs;
  var hasNextPage = false.obs;

  int getTotalPages() {
    return (totalEntries.value / perPage.value).ceil();
  }

  // void previousPage() {
  //   if (hasPreviousPage) {
  //     fetchAllSendMoney(page: currentPage.value + 1);
  //   }
  // }
  //
  // void nextPage() {
  //   if (hasNextPage) {
  //     fetchAllSendMoney(page: currentPage.value + 1);
  //   }
  // }



  // Method to Send Money Currencies
  Future<void> fetchSendmoneyCurrencies() async {
    //isLoading.value = true;  // Start loading

    String? token = await getToken(); // Ensure you have a method to get the Bearer token
    if (token == null) {
      Get.snackbar('Error', 'Token is null');
      isLoading.value = false;  // Stop loading
      return;
    }

    final url = Uri.parse('$baseUrl/api/sendMoneyCurrencies');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        print("Currency :${response.body}");
        final List<Currency> fetchedCurrencies = data.map((item) => Currency.fromJson(item)).toList();
        currencies.assignAll(fetchedCurrencies);
        // Clear current selection if needed
        currencies.clear();
        currencies.addAll(fetchedCurrencies);
        // Log each currency name to ensure they are being fetched correctly
        for (var currency in fetchedCurrencies) {
          print("Currency: ${currency.name}");
        }
      } else {
        throw Exception('Failed to load Send Money Currencies');
      }
  }

  // Fetch payment methods from API
  Future<void> fetchPaymentMethods() async {
    String? token = await getToken();
    if (token == null) {
      Get.snackbar('Error', 'Token is null');
      return;
    }
    final url = Uri.parse('$baseUrl/api/getPaymentMethods');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data']['payment_method'] != null && data['data']['payment_method'] is List) {
          final List<PaymentMethod> fetchedMethods = (data['data']['payment_method'] as List)
              .map((e) => PaymentMethod.fromJson(e))
              .toList();
          paymentMethods.value = fetchedMethods;
          
          // Automatically select the first payment method if none is selected
          if (selectedPaymentMethod.value == null && fetchedMethods.isNotEmpty) {
            selectedPaymentMethod.value = fetchedMethods.first;
          }
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch payment methods');
      }
    } catch (e) {
      print('Error fetching payment methods: $e');
      Get.snackbar('Error', 'Failed to fetch payment methods');
    }
  }


  Future<void> fetchUnreadRequestMoneyCount() async {
    String url = "$baseUrl/api/countUnreadRequestMoney";
    String? token = await getToken(); // Ensure you have a method to get the Bearer token
    if (token == null) {
      print("Token is null, skipping unread request money count fetch");
      return;
    }
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
        },
      ).timeout(Duration(seconds: 10)); // Add timeout to prevent hanging

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data is Map<String, dynamic> && data.containsKey('total_count')) {
          unreadRequestMoneyCount.value = data['total_count']; // Update to handle `total_count`
        } else {
          print("Invalid response format for unread request money count: ${response.body}");
        }
      } else {
        print("Failed to fetch unread request money count: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error fetching unread request money count (silent): $e");
      // Don't show error snackbar for network issues - this is a background operation
      // Just log the error and continue
    }
  }

  Future<void> fetchUnreadSupportTicketCount() async {
    String url = "$baseUrl/api/countUnreadTickets";
    String? token = await getToken(); // Ensure you have a method to get the Bearer token
    if (token == null) {
      print("Token is null, skipping unread support ticket count fetch");
      return;
    }
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
        },
      ).timeout(Duration(seconds: 10)); // Add timeout to prevent hanging

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data is Map<String, dynamic> && data.containsKey('total_count')) {
          unreadSupportTicketCount.value = data['total_count']; // Update to handle `total_count`
        } else {
          print("Invalid response format for unread support ticket count: ${response.body}");
        }
      } else {
        print("Failed to fetch unread support ticket count: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error fetching unread support ticket count (silent): $e");
      // Don't show error snackbar for network issues - this is a background operation
      // Just log the error and continue
    }
  }

  void clearFields() {
    selectedCurrency.value = null;
    amountController.clear();
    emailController.clear();
    noteController.clear();
  }

  @override
  void onClose() {
    clearFields(); // Reset fields when controller is disposed
    super.onClose();
  }

}



// Model class for Send Money Currency
class Currency {
  final int id;
  final String name;
  final String createdAt;
  final String updatedAt;

  Currency({required this.id, required this.name,
    required this.createdAt,required this.updatedAt});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['id'],
      name: json['name'],
      createdAt:  json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

// Model class for SendMoney
class SendMoney {
  final String id;
  final String dateTime;
  final String description;
  final String status;
  final String currency;
  final String amount;
  final String transferBy ;
  final String transferTo ;

  SendMoney({
    required this.id,
    required this.dateTime,
    required this.description,
    required this.status,
    required this.currency,
    required this.amount,
    required this.transferBy,
    required this.transferTo,
  });

  factory SendMoney.fromJson(Map<String, dynamic> json) {
    return SendMoney(
      id: json['id'].toString(),
      description: json['description'] ?? '',
      transferBy: json['user']['email'] ?? '',
      transferTo: json['to']['email'] ?? '',
      status: json['status']['name']?? '', // Example field; adjust based on your JSON
      currency: json['currency'] != null ? json['currency']['name'].toString() : 'Unknown Currency',
      amount: json['gross'] ?? '',
      dateTime: json['created_at'] ?? '',
    );
  }
}

// Model class for Payment Method
class PaymentMethod {
  final int id;
  final String name;
  PaymentMethod({required this.id, required this.name});
  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      name: json['payment_method_name'],
    );
  }
}

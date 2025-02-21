import 'package:dacotech/view/screens/send_money/screen_get_all_sendmoney.dart';
import 'package:dacotech/view/screens/request_money/screen_get_request_money.dart';
import 'package:dacotech/widgets/custom_api_url/constant_url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../widgets/custom_token/constant_token.dart';

class RequestMoneyController extends GetxController {
  var isLoading = false.obs;
  var id = ''.obs;

  var isCurrencyLoading = false.obs;
  var selectedCurrency = <RCurrency>[].obs;
  var selectedMethod = Rxn<RCurrency>();
  RxList<RequestMoney> requestMoneyList = <RequestMoney>[].obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  final int pageSize = 10;
  var amount = ''.obs;
  var email = ''.obs;
  var note = ''.obs;

  @override
  void onInit() {
    fetchAllRequestMoney();
    super.onInit();
  }
  // Method to Request Money
  Future<void> requestMoney(BuildContext context,
      String amount,
      String email,
      String description) async {
    String? token = await getToken();
    if (token == null) {
      Get.snackbar('Error', 'Token is null');
      isLoading.value = false;
      return;
    }
    if (selectedMethod.value == null) {
      Get.snackbar('Message', 'Select a valid method',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      isLoading.value = false;
      return;
    }
    if (amount.isEmpty) {
      Get.snackbar('Message', 'Enter amount',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      isLoading.value = false;
      return;
    }
    if (email.isEmpty) {
      Get.snackbar('Message', 'Enter a valid email',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      isLoading.value = false;
      return;
    }
    if (description.isEmpty) {
      Get.snackbar('Message', 'Note for recipient is required',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
      isLoading.value = false;
      return;
    }

    isLoading.value = true;




    final url = Uri.parse('$baseUrl/api/requestMoney');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = json.encode({
      'currency': selectedMethod.value?.id.toString(),
      'amount': amount,
      'email': email,
      'description': description,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          Get.snackbar('Success', 'Request money was successful',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,);
          await fetchAllRequestMoney();
          Get.off(ScreenGetRequestMonay());
          clearFields();
        } else {
          final message = responseData['message'];
          Get.snackbar('Message', message,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,);
          print('Request money failed: $message');
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
      } else {
        Get.snackbar('Message', 'Request money failed',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,);
        print('Request money failed: ${response.statusCode}');
        print('Request money failed: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Message', '$e',backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      print("Message ${e}");
    } finally {
      isLoading.value = false;
    }
  }
  // Method to Fetch all Request Money
  Future<void> fetchAllRequestMoney() async {
    try {
      isLoading(true);
      String? token = await getToken();
      if (token == null) {
        throw Exception('Token is null');
      }
      var response = await http.get(
        Uri.parse('$baseUrl/api/allRequest'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('Response Body: $jsonResponse'); // Log the response body

        if (jsonResponse['success'] == true) {
          // Access the 'data' map, then fetch the list of request money items
          List<dynamic> dataList = jsonResponse['data']['data'];

          // You can now iterate over the 'data' list to fetch the 'id' for each request
          if (dataList.isNotEmpty) {
            // Fetch the first item id and convert it to a string
            var requestId = dataList[0]['id'].toString(); // Convert int to string
            id.value = requestId; // Set it to your id observable
            print("Fetched Request ID: ${id.value}");
          } else {
            print('No requests found in the data list.');
          }

          // Now, you can process the entire request list if needed
          List<RequestMoney> fetchedRequestMoney =
          dataList.map((item) => RequestMoney.fromJson(item)).toList();

          requestMoneyList.assignAll(fetchedRequestMoney);
        } else {
          throw Exception('Failed to load request money data');
        }
      } else {
        print("Failed to fetch data ${response.statusCode}");
      }
    } catch (e) {
      print("Error: ${e}");
    } finally {
      isLoading(false);
    }
  }


  // Method to fetch Money Currencies
  Future<void> fetchRequestMoneyCurrencies() async {
    isCurrencyLoading.value = true; // Start loading
    String? token = await getToken(); // Ensure you have a method to get the Bearer token
    if (token == null) {
      Get.snackbar('Error', 'Token is null');
      isCurrencyLoading.value = false; // Stop loading
      return;
    }

    final url = Uri.parse('$baseUrl/api/sendMoneyCurrencies');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print("Response code: ${response.statusCode}");
      print("Response body: ${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        print("Currency :${response.body}");

        // Assign fetched data to selectedCurrency without clearing it again
        final List<RCurrency> fetchedCurrencies =
        data.map((item) => RCurrency.fromJson(item)).toList();
        selectedCurrency.assignAll(fetchedCurrencies);
        // Log each currency for debugging
        for (var currency in fetchedCurrencies) {
          print("Currency: ${currency.name}");
        }
      } else {
        Get.snackbar('Error', 'Failed to load Request Money Currencies');
      }
    } catch (e) {
      print('Error: $e');
      Get.snackbar('Error', 'Failed to fetch currencies');
    } finally {
      isCurrencyLoading.value = false; // Stop loading
    }
  }

  Future<void> confirmRequestMoney(String requestId) async {
    final String url = "$baseUrl/api/confirmRequestMoney/$requestId";
    String? token = await getToken();

    if (token == null) {
      Get.snackbar(
        'Error',
        'Token is null',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      isCurrencyLoading.value = false;
      return;
    }

    print('URL: $url');
    print('Token: $token');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Transaction Complete';

        print('Request confirmed successfully: $responseBody');
        Get.snackbar(
          'Success',
          message,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        await fetchAllRequestMoney();
      } else {
        final responseBody = json.decode(response.body);
        final errorMessage = responseBody['message'] ?? 'Transaction Failed';

        print('Failed to confirm request: ${response.statusCode}');
        print('Error body: ${response.body}');
        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('An error occurred: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }


  void clearFields() {
    amount.value = '';
    email.value = '';
    note.value = '';
    selectedMethod.value = null;
  }
  @override
  void onClose() {
    clearFields(); // Reset fields when controller is disposed
    super.onClose();
  }

}

// Model class for Request Currency
class RCurrency {
  final int id;
  final String name;
  final String createdAt;
  final String updatedAt;

  RCurrency({required this.id, required this.name,
    required this.createdAt,required this.updatedAt});

  factory RCurrency.fromJson(Map<String, dynamic> json) {
    return RCurrency(
      id: json['id'],
      name: json['name'],
      createdAt:  json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

// Model class for Request Money
class RequestMoney {
  final String id;
  final String dateTime;
  final String requestedBy;
  final String requestedTo;
  final String description;
  final String status;
  final String currency;
  final String amount;
  final User user; // Assuming you need to access the user data

  RequestMoney({
    required this.id,
    required this.dateTime,
    required this.requestedBy,
    required this.requestedTo,
    required this.status,
    required this.description,
    required this.currency,
    required this.amount,
    required this.user,
  });

  factory RequestMoney.fromJson(Map<String, dynamic> json) {
    return RequestMoney(
      id: json['id'].toString(),
      description: json['description'] ?? '',
      requestedBy: json['user']?['email'] ?? '', // Access email from 'user' safely
      requestedTo: json['to']?['email'] ?? '',
      status: json['status']['name'].toString(), // Adjust based on your JSON
      currency: json['currency'] != null ? json['currency']['name'].toString() : 'Unknown Currency',
      amount: json['gross']?.toString() ?? '',
      dateTime: json['created_at'] ?? '',
      user: User.fromJson(json['user'] ?? {}), // Handling nested user object
    );
  }
}

class User {
  final String id;
  final String email;
  final String name;

  User({
    required this.id,
    required this.email,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      name: json['name'] ?? '',
    );
  }
}


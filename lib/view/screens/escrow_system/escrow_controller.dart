import 'dart:io';

import 'package:escrowcorner/view/screens/escrow_system/send_escrow/screen_escrow_list.dart';
import 'package:escrowcorner/view/screens/escrow_system/models/escrow_models.dart';
import 'package:escrowcorner/widgets/custom_token/constant_token.dart';
import 'package:escrowcorner/widgets/custom_api_url/constant_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../controller/language_controller.dart';

class UserEscrowsController extends GetxController {
  var isLoading = false.obs;
  var receivedCurrentPage = 1.obs;
  var receivedTotalPages = 1.obs;
  //var escrows = <Escrow>[].obs;
  var senderEscrows = <SenderEscrow>[].obs;
  var receiverEscrows = <ReceiverEscrow>[].obs;
  RxList<EscrowCategory> categories = <EscrowCategory>[].obs;
  Rx<EscrowCategory?> selectedCategory = Rx<EscrowCategory?>(null);
  RxList<EscrowCurrency> currencies = <EscrowCurrency>[].obs; // List to hold fetched currencies
  Rx<int?> selectedCurrencyId = Rx<int?>(null);
  RxList<EscrowPaymentMethod> paymentMethods = <EscrowPaymentMethod>[].obs; // List to hold fetched payment methods
  Rx<int?> selectedPaymentMethodId = Rx<int?>(null);
  bool get receivedHasPreviousPage => receivedCurrentPage.value > 1;
  bool get receivedHasNextPage => receivedCurrentPage.value < receivedTotalPages.value;

  // Helper function to safely parse JSON responses
  Map<String, dynamic>? safeJsonDecode(String responseBody, {String? context}) {
    try {
      return jsonDecode(responseBody);
    } catch (e) {
      print("Error parsing JSON response${context != null ? ' in $context' : ''}: $e");
      print("Response appears to be HTML or non-JSON format");
      print("Response body: $responseBody");
      return null;
    }
  }


  // Future<void> fetchSenderEscrows() async {
  //   isLoading.value = true;
  //   String? token = await getToken();
  //   final url = Uri.parse("$baseUrl/api/sendEscrow");
  //
  //   if (token == null) {
  //     Get.snackbar('Error', 'Token not found');
  //     isLoading.value = false;
  //     return;
  //   }
  //
  //   try {
  //     final response = await http.get(
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //       },
  //     );
  //
  //     // print("Response Status Code sender: ${response.statusCode}");
  //     // print("Response Body sender: ${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //
  //       // Confirm if the key is 'escrows' or 'myEscrows' in the response
  //       if (data['data'] != null) {
  //         print("Escrows data: ${data['escrows']}");
  //
  //         // Populate escrows with the data from 'escrows'
  //         senderEscrows.value = List<SenderEscrow>.from(
  //             data['data'].map((item) => SenderEscrow.fromJson(item))
  //         );
  //
  //         //Get.snackbar('Success', 'sender escrows loaded successfully');
  //       } else if (data['myEscrows'] != null) {
  //         print("Escrows data sender: ${data['myEscrows']}");
  //
  //         senderEscrows.value = List<SenderEscrow>.from(
  //             data['myEscrows'].map((item) => SenderEscrow.fromJson(item))
  //         );
  //
  //         //Get.snackbar('Success', 'sender escrows loaded successfully');
  //       } else {
  //         print("No escrows found in response");
  //         //Get.snackbar('Error', 'No escrows found');
  //       }
  //     } else {
  //       Get.snackbar('Error', 'Failed to load escrows: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     Get.snackbar('Error', 'An error occurred: ${e.toString()}');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // Future<void> fetchReceiverEscrows({int page = 1}) async {
  //   isLoading.value = true;
  //   String? token = await getToken();
  //   final url = Uri.parse("$baseUrl/api/received_escrow"); // No need for the page parameter
  //
  //   if (token == null) {
  //     Get.snackbar('Error', 'Token not found');
  //     isLoading.value = false;
  //     return;
  //   }
  //
  //   try {
  //     final response = await http.get(
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //
  //       // Log the full response for debugging
  //       print('API Response: $data');
  //
  //       // Ensure 'data' key exists and contains the expected nested structure
  //       if (data is Map && data.containsKey('data') && data['data'] is Map && data['data'].containsKey('data')) {
  //         final escrows = data['data']['data'];
  //
  //         // Log the data to check if it's a list or something else
  //         print('Escrows data: $escrows');
  //
  //         // Check if 'escrows' is a List
  //         if (escrows is List) {
  //           // Update the escrows list without pagination
  //           receiverEscrows.value = escrows.map((item) => ReceiverEscrow.fromJson(item)).toList();
  //         } else {
  //           // If it's not a list, show a more detailed message
  //           Get.snackbar('Error', 'Expected a list of escrows, but got ${escrows.runtimeType}');
  //         }
  //       } else {
  //         Get.snackbar('Error', 'Response does not contain the expected nested data key');
  //       }
  //     } else {
  //       Get.snackbar('Error', 'Failed to load escrows: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error occurred: $e');
  //     Get.snackbar('Error', 'An error occurred: ${e.toString()}');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // void nextPage() {
  //   if (receivedHasNextPage) {
  //     fetchReceiverEscrows( page: receivedCurrentPage.value + 1);
  //   }
  // }
  //
  // void previousPage() {
  //   if (receivedHasPreviousPage) {
  //     fetchReceiverEscrows( page: receivedCurrentPage.value - 1);
  //   }
  // }

  Future<void> escrowRefund(String eid) async {
    final String? token = await getToken(); // Ensure getToken() fetches your auth token
    final Uri url = Uri.parse("$baseUrl/api/escrowRefund?eid=$eid");
    final languageController = Get.find<LanguageController>();

    if (token == null) {
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('token_not_found'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // print("Response Status Code: ${response.statusCode}");
      // print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        Get.snackbar(
          languageController.getTranslation('success'),
          languageController.getTranslation('escrow_refund_processed_successfully'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Handle the response data as needed
      } else {
        final data = json.decode(response.body);
        String message = data['message'] ?? languageController.getTranslation('failed_to_process_escrow_release');
        Get.snackbar(
          languageController.getTranslation('message'),
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('an_error_occurred'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  Future<void> escrowCancel(String eid) async {
    final String? token = await getToken(); // Ensure getToken() fetches your auth token
    final Uri url = Uri.parse("$baseUrl/api/cancelRequest?eid=$eid");
    final languageController = Get.find<LanguageController>();

    if (token == null) {
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('token_not_found'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // print("Response Status Code: ${response.statusCode}");
      // print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        Get.snackbar(
          languageController.getTranslation('success'),
          languageController.getTranslation('escrow_cancel_processed_successfully'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Handle the response data as needed
      } else {
        final data = json.decode(response.body);
        String message = data['message'] ?? languageController.getTranslation('failed_to_process_escrow_cancel');
        Get.snackbar(
          languageController.getTranslation('message'),
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('an_error_occurred'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<Map<String, dynamic>?> storeEscrow({
    required String title,
    required double amount,
    required String email,
    required int escrowCategoryId,
    required String currency,
    required String description,
    required bool escrowTermConditions, // New parameter
    List<File>? attachments, // Optional multiple files parameter
    int? paymentMethodId, // Payment method ID parameter
    String? productName, // Product name parameter
  }) async {
    final languageController = Get.find<LanguageController>();
    
    try {
      String? token = await getToken();
      if (token == null) {
        print("Error: Token is null. Cannot proceed with the request.");
        return {
          'success': false,
          'message': languageController.getTranslation('token_not_found'),
          'data': null
        };
      }
      print("Retrieved Token: $token");

      final url = Uri.parse('$baseUrl/api/storeEscrow');

      // Create a multipart request
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll({
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        })
        ..fields['title'] = title
        ..fields['amount'] = amount.toString()
        ..fields['email'] = email
        ..fields['escrow_category_id'] = escrowCategoryId.toString()
        ..fields['currency'] = currency
        ..fields['description'] = description
        ..fields['escrow_term_conditions'] = escrowTermConditions.toString();
      
      // Add payment method ID if selected
      if (paymentMethodId != null) {
        request.fields['method_id'] = paymentMethodId.toString();
        print("Method ID added: $paymentMethodId");
      }
      
      // Add product name if provided
      if (productName != null && productName.isNotEmpty) {
        request.fields['product_name'] = productName;
        print("Product name added: $productName");
      }

      // Add files if available
      if (attachments != null && attachments.isNotEmpty) {
        for (int i = 0; i < attachments.length; i++) {
          request.files.add(await http.MultipartFile.fromPath('attachments[]', attachments[i].path));
          print("File attached: ${attachments[i].path}");
        }
        print("Total files attached: ${attachments.length}");
      }

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print("Response Status Code: ${response.statusCode}");
      print("Response Headers: ${response.headers}");
      print("Response Body (raw): ${response.body}");

      // Check if response is JSON before parsing
      final responseBody = safeJsonDecode(response.body, context: 'storeEscrow');
      if (responseBody == null) {
        // Handle different types of non-JSON responses
        String errorMessage;
        if (response.statusCode == 429) {
          errorMessage = languageController.getTranslation('too_many_requests') ?? 'Too many requests. Please wait a moment and try again.';
          print("Rate limit exceeded. Consider implementing retry logic with exponential backoff.");
        } else if (response.statusCode >= 500) {
          errorMessage = languageController.getTranslation('server_error') ?? 'Server error. Please try again later.';
        } else if (response.statusCode >= 400) {
          errorMessage = languageController.getTranslation('request_failed') ?? 'Request failed. Please check your connection and try again.';
        } else {
          errorMessage = languageController.getTranslation('server_returned_invalid_response') ?? 'Server returned an invalid response. Please try again.';
        }
        
        return {
          'success': false,
          'message': errorMessage,
          'data': null
        };
      }
      
      print("Response Body (parsed): $responseBody");

      if (response.statusCode == 200) {
        // Success - return the API response data
        print("Escrow stored successfully: ${responseBody['message']}");
        return {
          'success': true,
          'message': responseBody['message'] ?? languageController.getTranslation('escrow_stored_successfully'),
          'data': responseBody
        };
      } else {
        // Error - return error response data
        String errorMessage = responseBody['message'] ?? languageController.getTranslation('an_error_occurred');
        if (responseBody['message'] is String) {
          errorMessage = responseBody['message'];
        } else if (responseBody['message'] is Map && responseBody['message']['email'] != null) {
          errorMessage = responseBody['message']['email'][0];
        }
        print("Failed to store request escrow: $errorMessage");
        return {
          'success': false,
          'message': errorMessage,
          'data': responseBody
        };
      }
    } catch (e) {
      print("An error occurred: $e");
      return {
        'success': false,
        'message': languageController.getTranslation('an_unexpected_error_occurred_please_try_again'),
        'data': null
      };
    }
  }



  Future<void> fetchCategories() async {
    final String? token = await getToken();
    if (token == null) {
      print("Error: Token is null. Cannot proceed with the request.");
      return;
    }
    print("Retrieved Token: $token");
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/getEscrowCategories'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = safeJsonDecode(response.body, context: 'fetchEscrowCategories');
        if (data == null) {
          print("Failed to parse JSON response in fetchEscrowCategories");
          return;
        }

        if (data['escrow_categories'] != null) {
          final List<dynamic> categoryList = data['escrow_categories'];
          categories.value = categoryList.map((e) => EscrowCategory.fromJson(e)).toList();
          //print('Categories successfully fetched: ${categories.length} items.');
        } else {
          print('escrow_categories field is missing in the response.');
        }
      } else {
        print('Failed to fetch categories. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while fetching categories: $e');
    }
  }

  Future<void> fetchCurrencies() async {

    try {
      final token = await getToken(); // Fetch token properly
      if (token == null) {
        print('Token is null. Cannot fetch currencies.');
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/getCurrenciesList'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      // print('API Response Status Code: ${response.statusCode}');
      // print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = safeJsonDecode(response.body, context: 'fetchCurrencies');
        if (data == null) {
          print("Failed to parse JSON response in fetchCurrencies");
          return;
        }
        final List<dynamic> currencyList = data['currencies'] ?? [];
        currencies.value =
            currencyList.map((e) => EscrowCurrency.fromJson(e)).toList();
        print('Currencies fetched successfully: ${currencies.length} items.');
      } else {
        print('Failed to fetch currencies. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while fetching currencies: $e');
    }
  }

  Future<void> fetchPaymentMethods() async {
    try {
      isLoading.value = true;
      final token = await getToken();
      if (token == null) {
        print('Token is null. Cannot fetch payment methods.');
        isLoading.value = false;
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/getPaymentMethods'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Payment Methods API Response Status Code: ${response.statusCode}');
      print('Payment Methods API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic>? jsonResponse = safeJsonDecode(response.body, context: 'fetchPaymentMethods');
        if (jsonResponse == null) {
          print("Failed to parse JSON response in fetchPaymentMethods");
          return;
        }
        
        // Handle the correct response structure: data.payment_method
        List<dynamic> paymentMethodsList = [];
        if (jsonResponse['data'] != null && jsonResponse['data']['payment_method'] != null) {
          paymentMethodsList = jsonResponse['data']['payment_method'] as List;
        }
        
        print('Found payment methods in data: ${paymentMethodsList.length} items');
        
        if (paymentMethodsList.isNotEmpty) {
          final List<EscrowPaymentMethod> fetchedMethods =
              paymentMethodsList.map((item) => EscrowPaymentMethod.fromJson(item)).toList();
          paymentMethods.value = fetchedMethods;
          print('Payment methods fetched successfully: ${paymentMethods.length} items.');
          
          // Automatically select the first payment method if none is selected
          if (selectedPaymentMethodId.value == null && fetchedMethods.isNotEmpty) {
            selectedPaymentMethodId.value = fetchedMethods.first.id;
          }
          
          // Debug: Print each payment method
          for (var method in paymentMethods) {
            print('Payment Method: ID=${method.id}, Name=${method.paymentMethodName}, Created=${method.createdAt}');
          }
        } else {
          print('No payment methods found in response');
          paymentMethods.clear();
          selectedPaymentMethodId.value = null;
        }
      } else {
        print('Failed to fetch payment methods. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while fetching payment methods: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void clearField() {
    selectedCategory.value==null;
    selectedCurrencyId.value==null;
    selectedPaymentMethodId.value==null;
}

}


class EscrowCurrency {
  final int id;
  final String? name; // Nullable
  final String? symbol; // Nullable
  final String? code; // Nullable
  final int isCrypto;
  final String? thumb; // Nullable

  EscrowCurrency({
    required this.id,
    this.name, // Nullable
    this.symbol, // Nullable
    this.code, // Nullable
    required this.isCrypto,
    this.thumb, // Nullable
  });

  factory EscrowCurrency.fromJson(Map<String, dynamic> json) {
    return EscrowCurrency(
      id: json['id'],
      name: json['name'], // Can be null
      symbol: json['symbol'], // Can be null
      code: json['code'], // Can be null
      isCrypto: json['is_crypto'] ?? 0, // Default to 0 if null
      thumb: json['thumb'], // Can be null
    );
  }
}

class EscrowPaymentMethod {
  final int id;
  final String? name;
  final String? paymentMethodName;
  final String? createdAt;
  final String? updatedAt;

  EscrowPaymentMethod({
    required this.id,
    this.name,
    this.paymentMethodName,
    this.createdAt,
    this.updatedAt,
  });

  factory EscrowPaymentMethod.fromJson(Map<String, dynamic> json) {
    return EscrowPaymentMethod(
      id: json['id'],
      name: json['payment_method_name'] ?? json['name'] ?? '',
      paymentMethodName: json['payment_method_name'] ?? json['name'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is EscrowPaymentMethod &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}




//SenderEscrow model
class SenderEscrow {
  final int id;
  final int userId;
  final String? title;
  final int? escrowCategoryId;
  final String? attachment;
  final int to;
  final String gross;
  final String description;
  final int currencyId;
  final String currencySymbol;
  final String escrowTransactionStatus;
  final int agreement;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  SenderEscrow({
    required this.id,
    required this.userId,
    this.title,
    this.escrowCategoryId,
    this.attachment,
    required this.to,
    required this.gross,
    required this.description,
    required this.currencyId,
    required this.currencySymbol,
    required this.escrowTransactionStatus,
    required this.agreement,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory SenderEscrow.fromJson(Map<String, dynamic> json) {
    return SenderEscrow(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      escrowCategoryId: json['escrow_category_id'],
      attachment: json['attachment'],
      to: json['to'],
      gross: json['gross'],
      description: json['description'],
      currencyId: json['currency_id'],
      currencySymbol: json['currency_symbol'],
      escrowTransactionStatus: json['escrow_transaction_status'],
      agreement: json['agreement'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    );
  }
}



// ReceiverEscrow model
class ReceiverEscrow {
  final int id;
  final String? email;
  final String? title;
  final int status;
  final int? escrowCategoryId;
  final String? attachment;
  final String? to;
  final String gross;
  final String description;
  final int currencyId;
  final String currencySymbol;
  final String escrowTransactionStatus;
  final int agreement;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  ReceiverEscrow({
    required this.id,
    this.email,
    this.title,
    required this.status,
    this.escrowCategoryId,
    this.attachment,
    this.to,
    required this.gross,
    required this.description,
    required this.currencyId,
    required this.currencySymbol,
    required this.escrowTransactionStatus,
    required this.agreement,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  // This is the computed property for status label
  String get statusLabel {
    switch (status) {
      case 1:
        return 'Completed'; // Status 1 is completed
      case 2:
        return 'Pending'; // Status 2 is pending
      default:
        return 'Unknown'; // Default label if status is neither 1 nor 2
    }
  }

  factory ReceiverEscrow.fromJson(Map<String, dynamic> json) {
    return ReceiverEscrow(
      id: json['id'] as int,
      email: json['user']?['email'] as String?,
      title: json['title'] as String?,
      status: json['status'] as int,
      escrowCategoryId: json['escrow_category_id'] as int?,
      attachment: json['attachment'] as String?,
      to: json['to_user']?['email'] as String?,
      gross: json['gross']?.toString() ?? '0.0',
      description: json['description'] as String? ?? '',
      currencyId: json['currency_id'] as int,
      currencySymbol: json['currency_symbol']?.toString() ?? '',
      escrowTransactionStatus: json['status']?.toString() ?? 'Unknown',
      agreement: json['agreement'] as int,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    );
  }
}



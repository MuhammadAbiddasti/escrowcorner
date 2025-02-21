import 'dart:io';

import 'package:dacotech/view/screens/escrow_system/send_escrow/screen_escrow_list.dart';
import 'package:dacotech/widgets/custom_token/constant_token.dart';
import 'package:dacotech/widgets/custom_api_url/constant_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  bool get receivedHasPreviousPage => receivedCurrentPage.value > 1;
  bool get receivedHasNextPage => receivedCurrentPage.value < receivedTotalPages.value;


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

    if (token == null) {
      Get.snackbar('Error', 'Token not found');
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
        Get.snackbar('Success', 'Escrow refund processed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,);
        // Handle the response data as needed
      } else {
        final data = json.decode(response.body);
        String message = data['message'] ?? 'Failed to process escrow release';
        Get.snackbar('Message', message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,);
    }
  }
  Future<void> escrowCancel(String eid) async {
    final String? token = await getToken(); // Ensure getToken() fetches your auth token
    final Uri url = Uri.parse("$baseUrl/api/cancelRequest?eid=$eid");

    if (token == null) {
      Get.snackbar('Error', 'Token not found');
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
        Get.snackbar('Success', 'Escrow cancel processed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,);
        // Handle the response data as needed
      } else {
        final data = json.decode(response.body);
        String message = data['message'] ?? 'Failed to process escrow cancel';
        Get.snackbar('Message', message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,);
    }
  }

  Future<void> storeEscrow({
    required String title,
    required double amount,
    required String email,
    required int escrowCategoryId,
    required String currency,
    required String description,
    required bool escrowTermConditions, // New parameter
    File? attachment, // Optional file parameter
  }) async {
    try {
      String? token = await getToken();
      if (token == null) {
        print("Error: Token is null. Cannot proceed with the request.");
        return;
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

      // Add file if available
      if (attachment != null) {
        request.files.add(await http.MultipartFile.fromPath('attachment', attachment.path));
        print("File attached: ${attachment.path}");
      }

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseBody = jsonDecode(response.body);

      print("Response Body: $responseBody");

      if (response.statusCode == 200) {
        // Success
        Get.snackbar(
          "Success",
          "Escrow stored successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        await Future.delayed(Duration(seconds: 1));
        Get.off(() => ScreenEscrowList());
        clearField();
        print("Escrow stored successfully: ${responseBody['message']}");
      } else {
        // Error handling
        String errorMessage = responseBody['message'] ?? "An error occurred";
        if (responseBody['message'] is String) {
          errorMessage = responseBody['message'];
        } else if (responseBody['message'] is Map && responseBody['message']['email'] != null) {
          errorMessage = responseBody['message']['email'][0];
        }
        Get.snackbar(
          "Error",
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        print("Failed to store request escrow: $errorMessage");
      }
    } catch (e) {
      print("An error occurred: $e");
      Get.snackbar(
        "Error",
        "An unexpected error occurred. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
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
        final data = json.decode(response.body);

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
        final data = json.decode(response.body);
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

  void clearField() {
    selectedCategory.value==null;
    selectedCurrencyId.value==null;
}

}


class EscrowCategory {
  final int id;
  final String title;
  final String status;

  EscrowCategory({required this.id, required this.title, required this.status});

  factory EscrowCategory.fromJson(Map<String, dynamic> json) {
    return EscrowCategory(
      id: json['id'],
      title: json['title'],
      status: json['status'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is EscrowCategory &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
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



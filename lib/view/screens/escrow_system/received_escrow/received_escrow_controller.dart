import 'package:dacotech/view/screens/escrow_system/send_escrow/screen_escrow_list.dart';
import 'package:dacotech/widgets/custom_token/constant_token.dart';
import 'package:dacotech/widgets/custom_api_url/constant_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReceivedEscrowsController extends GetxController {
  var isLoading = false.obs;
  var receivedCurrentPage = 1.obs;
  var receivedTotalPages = 1.obs;
  var receiverEscrows = <ReceivedEscrow>[].obs;
  bool get receivedHasPreviousPage => receivedCurrentPage.value > 1;
  bool get receivedHasNextPage => receivedCurrentPage.value < receivedTotalPages.value;


  Future<void> fetchReceiverEscrows({int page = 1}) async {
    isLoading.value = true;
    String? token = await getToken();
    final url = Uri.parse("$baseUrl/api/received_escrow");

    if (token == null) {
      isLoading.value = false;
      return;
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Log the full response for debugging
        print('API Response: $data');

        // Ensure the 'data' field is present and is a list, or handle the empty object case
        if (data is Map && data.containsKey('data')) {
          final dynamic escrowsData = data['data'];

          if (escrowsData is List) {
            // Handle the case where 'data' is a list of escrows
            receiverEscrows.value = escrowsData
                .map((item) => ReceivedEscrow.fromJson(item as Map<String, dynamic>))
                .toList();
          } else if (escrowsData is Map && escrowsData.isEmpty) {
            // Handle the case where 'data' is an empty object
            receiverEscrows.value = [];
            Get.snackbar('Info', 'No received escrows available.',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,);
          } else {
            // Handle other unexpected structures
            //Get.snackbar('Error', 'Unexpected data format received.');
          }
        } else {
          // Handle the case where 'data' is missing or malformed
          //Get.snackbar('Error', 'Invalid data received.');
        }
      } else {
        // Handle non-200 status codes
        //Get.snackbar('Error', 'Failed to load escrows: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      Get.snackbar('Error', 'An error occurred: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }


  void nextPage() {
    if (receivedHasNextPage) {
      fetchReceiverEscrows( page: receivedCurrentPage.value + 1);
    }
  }

  void previousPage() {
    if (receivedHasPreviousPage) {
      fetchReceiverEscrows( page: receivedCurrentPage.value - 1);
    }
  }
}

// ReceiverEscrow model
class ReceivedEscrow {
  final int id;
  final String email;
  final String? title;
  final int status;
  final int? escrowCategoryId;
  final String? attachment;
  final String to;
  final String gross;
  final String description;
  final int currencyId;
  final String currencySymbol;
  final String escrowTransactionStatus;
  final int agreement;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  ReceivedEscrow({
    required this.id,
    required this.email,
    this.title,
    required this.status,
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

  // This is the computed property for status label
  String get statusLabel {
    switch (status) {
      case 0:
        return 'on hold'; // Status 1 is completed
      case 1:
        return 'Completed';
      case 2:
        return 'Rejected';// Status 2 is pending
      default:
        return 'Unknown'; // Default label if status is neither 1 nor 2
    }
  }

  factory ReceivedEscrow.fromJson(Map<String, dynamic> json) {
    return ReceivedEscrow(
      id: json['id'] as int,
      email: json['user']?['email'] ?? 'Unknown',
      title: json['title'] as String?,
      status: json['status'] as int,
      escrowCategoryId: json['escrow_category_id'] as int?,
      attachment: json['attachment'] as String?,
      to: json['to_user']?['email'] ?? 'Unknown',
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



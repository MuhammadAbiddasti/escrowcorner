import 'dart:convert';
import 'package:dacotech/widgets/custom_api_url/constant_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../widgets/custom_token/constant_token.dart';
class CancelledEscrowController extends GetxController {
  var isLoading = false.obs;
  var canceledEscrows = <CancelledEscrow>[].obs;

  // Other methods...

  Future<void> fetchCanceledEscrows() async {
    isLoading(true);
    String? token = await getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/cancel-request-escrow'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("Response body: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          canceledEscrows.value = (data['data'] as List)
              .map((escrow) => CancelledEscrow.fromJson(escrow))
              .toList();
        } else {
          // Get.snackbar(
          //   "Error",
          //   data['message'],
          //     snackPosition: SnackPosition.BOTTOM,
          //     backgroundColor: Colors.red,
          //     colorText: Colors.white,
          // );
        }
      } else {
        // Get.snackbar(
        //   "Error",
        //   "Failed to fetch canceled escrow requests.",
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.red,
        //   colorText: Colors.white,
        // );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }
}

class CancelledEscrow {
  final int id;
  final String userId;
  final String to;
  final String title;
  final String? attachment;
  final String gross;
  final String description;
  final String currencySymbol;
  final int status;
  final DateTime createdAt;

  CancelledEscrow({
    required this.id,
    required this.userId,
    required this.to,
    required this.title,
    this.attachment,
    required this.gross,
    required this.description,
    required this.currencySymbol,
    required this.status,
    required this.createdAt,
  });
  String get statusLabel {
    switch (status) {
      case 0:
        return 'Pending'; // Status 1 is completed
      case 1:
        return 'Completed'; // Status 2 is pending
      case 2:
        return 'Rejected';
      case 3:
        return 'On Hold';
      case 4:
        return 'Cancelled';
      default:
        return 'Unknown'; // Default label if status is neither 1 nor 2
    }
  }

  factory CancelledEscrow.fromJson(Map<String, dynamic> json) {
    return CancelledEscrow(
      id: json['id'] ?? 0,
      userId: json['user']?['email'],
      to: json['to_user']?['email'],
      title: json['title'] ?? '',
      attachment: json['attachment'],
      gross: json['gross'] ?? '0.000',
      description: json['description'] ?? '',
      currencySymbol: json['currency_symbol'] ?? '',
      status: json['status'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

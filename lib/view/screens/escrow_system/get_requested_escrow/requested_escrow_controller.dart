import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/custom_api_url/constant_url.dart';
import '../../../../widgets/custom_token/constant_token.dart';
import 'package:http/http.dart' as http;

import '../rejected_escrow/get_rejected_escrow.dart';

class RequestedEscrowController extends GetxController {
  final requestEscrows = <RequestedEscrow>[].obs;
  final isLoading = false.obs;

  Future<void> fetchRequestedEscrows() async {
    isLoading.value = true;
    String? token = await getToken();
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/requested_escrow"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          requestEscrows.assignAll(
              data.map((e) => RequestedEscrow.fromJson(e)).toList());
          print('API Response: $data');
        } else {
          //Get.snackbar("Error", responseData['message']);
        }
      } else {
        //Get.snackbar("Error", "Failed to fetch request escrow data.");
      }
    } catch (e) {
      //Get.snackbar("Error", "An error occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

class RequestedEscrow {
  final int id;
  final String? userId;
  final String? to;
  final String title;
  final String? attachment;
  final String gross;
  final String description;
  final String currencySymbol;
  final int status;
  final DateTime createdAt;

  RequestedEscrow({
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

  factory RequestedEscrow.fromJson(Map<String, dynamic> json) {
    return RequestedEscrow(
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



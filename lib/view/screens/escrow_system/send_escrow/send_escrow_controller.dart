import 'dart:convert';

import 'package:dacotech/view/screens/escrow_system/send_escrow/screen_escrow_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../widgets/custom_api_url/constant_url.dart';
import '../../../../widgets/custom_token/constant_token.dart';
import '../rejected_escrow/get_rejected_escrow.dart';
import '../rejected_escrow/rejected_escrow_controller.dart';

class SendEscrowsController extends GetxController {
  var isLoading = false.obs;
  var escrows = <Escrow>[].obs;
  final escrowDetail = <DetailsSendEscrow>[].obs;
  final RejectedEscrowController rejectController = Get.put(RejectedEscrowController());


  Future<void> fetchSendEscrows() async {
    isLoading.value = true;
    String? token = await getToken();
    final url = Uri.parse("$baseUrl/api/sendEscrow");

    if (token == null) {
      Get.snackbar('Error', 'Token not found');
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
        // Parse JSON data
        final data = json.decode(response.body);
        if (data['data'] != null) {
          escrows.value = List<Escrow>.from(
            data['data'].map((item) => Escrow.fromJson(item)),
          );
        } else {
          print("No escrows found in response");
        }
      } else if (response.statusCode == 429) {
        // Handle rate-limiting response
        print("Rate limit exceeded. Please try again later.");
        //Get.snackbar('Error', 'Too many requests. Please try again later.');
      } else {
        print("Failed to load escrows: ${response.statusCode}");
        //Get.snackbar('Error', 'Failed to load escrows: ${response.statusCode}');
      }
    } catch (e) {
      // Check if the response is HTML and not JSON
      if (e is FormatException) {
        print("Received an unexpected HTML response.");
        //Get.snackbar('Error', 'Unexpected response from the server.');
      } else {
        print("Failed to load escrows: $e");
        //Get.snackbar('Error', 'An error occurred: ${e.toString()}');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchEscrowDetail(int id) async {
    isLoading.value = true;
    String? token = await getToken();

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/sendEscrowDetails/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          final DetailsSendEscrow escrow = DetailsSendEscrow.fromJson(responseData['data']);
          escrowDetail.assignAll([escrow]); // Assign to observable list
        } else {
          escrowDetail.clear();
          print("No details available");
        }
      } else {
        print("Failed to fetch escrow details. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching escrow details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> escrowRelease(String eid) async {
    final String? token = await getToken(); // Ensure getToken() fetches your auth token
    final Uri url = Uri.parse("$baseUrl/api/escrowRelease");
    if (token == null) {
      Get.snackbar('Error', 'Token not found');
      return;
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'eid': eid}),
      );
      print("response body: ${response.body}");
      print("response code: ${response.statusCode}");
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Escrow release processed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,);
        Get.off(ScreenEscrowList());
        await fetchSendEscrows();
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

  Future<void> escrowReject(String eid) async {
    final String? token = await getToken(); // Ensure getToken() fetches your auth token
    final Uri url = Uri.parse("$baseUrl/api/reject?eid=$eid");
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
      print("response body: ${response.body}");
      print("response code: ${response.statusCode}");
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Escrow reject processed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,);
        Get.off(GetRejectedEscrow());
        await rejectController.fetchRejectedEscrows();
        // Handle the response data as needed
      } else {
        final data = json.decode(response.body);
        String message = data['message'] ?? 'Failed to process escrow reject';
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



}

class Escrow {
  final int id;
  final String? userId; // Changed to String? to store email
  final String? title;
  final int? escrowCategoryId;
  final String? attachment;
  final String? to; // Changed to String? to store email
  final int status;
  final String? gross; // Nullable
  final String? description; // Nullable
  final int currencyId;
  final String? currencySymbol; // Nullable
  final String? escrowTransactionStatus; // Nullable
  final int agreement;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  Escrow({
    required this.id,
    this.userId,
    this.title,
    this.escrowCategoryId,
    this.attachment,
    this.to,
    required this.status,
    this.gross,
    this.description,
    required this.currencyId,
    this.currencySymbol,
    this.escrowTransactionStatus,
    required this.agreement,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  String get statusLabel {
    switch (status) {
      case 0:
        return 'on hold';
      case 1:
        return 'Completed';
      case 3:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  factory Escrow.fromJson(Map<String, dynamic> json) {
    return Escrow(
      id: json['id'],
      userId: json['user']?['email'],  // Now returns String? (email)
      title: json['title'],
      escrowCategoryId: json['escrow_category_id'],
      attachment: json['attachment'],
      to: json['to_user']?['email'],  // Now returns String? (email)
      status: json['status'],
      gross: json['gross'],  // Nullable field
      description: json['description'],  // Nullable field
      currencyId: json['currency_id'],
      currencySymbol: json['currency_symbol'],  // Nullable field
      escrowTransactionStatus: json['escrow_transaction_status'],  // Nullable field
      agreement: json['agreement'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    );
  }
}



class DetailsSendEscrow {
  final int id;
  final String? title; // Nullable field
  final String? attachment; // Nullable field
  final double gross; // Changed to double for numeric consistency
  final String description;
  final String? currencySymbol; // Nullable field
  final int status;
  final int fee;
  final int escrows_hpd;
  final String? senderEmail; // Nullable field
  final String? receiverEmail; // Nullable field
  final DateTime? createdAt; // Made nullable

  DetailsSendEscrow({
    required this.id,
    this.title,
    this.attachment,
    required this.gross,
    this.description = '', // Default to an empty string
    this.currencySymbol,
    required this.status,
    required this.fee,
    required this.escrows_hpd,
    this.senderEmail,
    this.receiverEmail,
    this.createdAt,
  });

  String get statusLabel {
    switch (status) {
      case 0:
        return 'On Hold';
      case 1:
        return 'Completed';
      case 2:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  factory DetailsSendEscrow.fromJson(Map<String, dynamic> json) {
    return DetailsSendEscrow(
      id: json['escrow']?['id'] ?? 0,
      title: json['escrow']?['title'],
      attachment: json['attachment'],
      gross: double.tryParse(json['escrow']?['gross']?.toString() ?? '0.000') ?? 0.0,
      description: json['escrow']?['description'] ?? '', // Default value
      currencySymbol: json['escrow']?['currency_symbol'],
      status: json['escrow']?['status'] ?? 0,
      fee: json['escrow_fee'] ?? 0,
      escrows_hpd: _parseHoldingPeriod(json['escrows_hpd']),
      senderEmail: json['sender']?['email'],
      receiverEmail: json['receiver']?['email'],
      createdAt: json['escrow']?['created_at'] != null
          ? DateTime.tryParse(json['escrow']['created_at'])
          : null, // Safely parse nullable DateTime
    );
  }

  // Helper function to parse "escrows_hpd" and extract the numeric value
  static int _parseHoldingPeriod(dynamic holdingPeriod) {
    if (holdingPeriod != null) {
      final regex = RegExp(r'(\d+)'); // Match the number in the string
      final match = regex.firstMatch(holdingPeriod.toString());
      if (match != null) {
        return int.tryParse(match.group(0) ?? '0') ?? 0;
      }
    }
    return 0; // Default to 0 if no number is found
  }
}


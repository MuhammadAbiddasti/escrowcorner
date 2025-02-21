import 'dart:convert';
import 'dart:io';
import 'package:dacotech/view/screens/escrow_system/cancelled_escrow/get_cancelled_escrow.dart';
import 'package:dacotech/view/screens/escrow_system/request_escrow/request_escrow.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../../widgets/custom_api_url/constant_url.dart';
import '../../../../widgets/custom_token/constant_token.dart';
import '../get_requested_escrow/get_requested_escrow.dart';
import '../get_requested_escrow/requested_escrow_controller.dart';
import '../rejected_escrow/get_rejected_escrow.dart';

class RequestEscrowController extends GetxController {
  final requestEscrows = <RequestEscrow>[].obs;
  final isLoading = false.obs;
  final escrowDetail = <DetailsRequestEscrow>[].obs;
  final RequestedEscrowController controller = Get.put(RequestedEscrowController());
  //List<RequestEscrow> get escrows => requestEscrows;
  Future<void> fetchRequestEscrows() async {
    isLoading.value = true;
    String? token = await getToken();
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/request_escrow"),
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
              data.map((e) => RequestEscrow.fromJson(e)).toList());
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
  Future<void> fetchRequestEscrowDetail(int id) async {
    isLoading.value = true;
    String? token = await getToken();
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/requestedEscrowDetail/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final data = responseData['data'];
          // Pass the entire 'data' to the fromJson constructor
          escrowDetail.assignAll([DetailsRequestEscrow.fromJson(data)]);
          print('API Response: $data');
        } else {
          //Get.snackbar("Error", responseData['message']);
          print('response: $responseData');
        }
      } else {
        //Get.snackbar("Error", "Failed to fetch request detail escrow data.");
        print('response: ${response.body}');
      }
    } catch (e) {
      //Get.snackbar("Error", "An error occurred: $e");
      print('response: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveRequestEscrow(String eid) async {
    final String? token = await getToken(); // Ensure getToken() fetches your auth token
    final Uri url = Uri.parse("$baseUrl/api/approve_request?eid=$eid");
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
        Get.snackbar('Success', ' Approve request escrow processed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,);
        Get.off(GetRequestedEscrow());
        await controller.fetchRequestedEscrows();
        // Handle the response data as needed
      } else {
        final data = json.decode(response.body);
        String message = data['message'] ?? 'Failed to process escrow approve';
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

  Future<void> rejectRequestEscrow(String eid) async {
    final String? token = await getToken(); // Ensure getToken() fetches your auth token
    final Uri url = Uri.parse("$baseUrl/api/reject_request?eid=$eid");
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
        Get.snackbar('Success', 'Reject request escrow processed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,);
        Get.off(GetRejectedEscrow());
        //await rejectController.fetchRejectedEscrows();
        // Handle the response data as needed
      } else {
        final data = json.decode(response.body);
        String message = data['message'] ?? 'Failed to process escrow reject request';
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

  Future<void> cancelRequestEscrow(String eid) async {
    final String? token = await getToken(); // Ensure getToken() fetches your auth token
    final Uri url = Uri.parse("$baseUrl/api/cancel_request?eid=$eid");
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
        Get.snackbar('Success', 'Cancel request escrow processed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,);
        Get.off(GetCancelledEscrow());
        //await rejectController.fetchRejectedEscrows();
        // Handle the response data as needed
      } else {
        final data = json.decode(response.body);
        String message = data['message'] ?? 'Failed to process escrow cancel request';
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

  Future<void> releaseRequestEscrow(String eid) async {
    final String? token = await getToken(); // Ensure getToken() fetches your auth token
    final Uri url = Uri.parse("$baseUrl/api/release_request?eid=$eid");
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
        Get.snackbar('Success', 'Release request escrow processed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,);
        Get.off(GetRequestedEscrow());
        await controller.fetchRequestedEscrows();
        // Handle the response data as needed
      } else {
        final data = json.decode(response.body);
        String message = data['message'] ?? 'Failed to process release request';
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

  Future<void> storeRequestEscrow({
    required String title,
    required double amount,
    required String email,
    required int escrowCategoryId,
    required String currency,
    required String description,
    required bool escrowTermConditions, // New parameter
    File? attachment,
  }) async {
    try {
      String? token = await getToken();
      if (token == null) {
        print("Error: Token is null. Cannot proceed with the request.");
        return;
      }
      print("Retrieved Token: $token");
      final url = Uri.parse('$baseUrl/api/storeRequestEscrow');

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


      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseBody = jsonDecode(response.body);
      print("response body: ${response.body}");
      print("response code: ${response.statusCode}");

      if (response.statusCode == 200 ) {
        // Success
        Get.snackbar(
          "Success",
          "Request Escrow stored successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        await Future.delayed(Duration(seconds: 1));
        Get.off(() => GetRequestEscrow());

        print("Request Escrow stored successfully: ${responseBody['message']}");
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
}

class RequestEscrow {
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

  RequestEscrow({
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

  factory RequestEscrow.fromJson(Map<String, dynamic> json) {
    return RequestEscrow(
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


class DetailsRequestEscrow {
  final int id;
  final String? title; // Nullable field
  final String? attachment; // Nullable field
  final double gross; // Changed to double for numeric consistency
  final String description;
  final String? currencySymbol; // Nullable field
  final int status;
  final int escrows_hpd;
  final String? senderEmail; // Nullable field
  final String? receiverEmail; // Nullable field
  final DateTime? createdAt;

  DetailsRequestEscrow({
    required this.id,
    this.title,
    this.attachment,
    required this.gross,
    this.description = '', // Default to an empty string
    this.currencySymbol,
    required this.status,
    required this.escrows_hpd,
    this.senderEmail,
    this.receiverEmail,
    this.createdAt,
  });

  String get statusLabel {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Completed';
      case 2:
        return 'Rejected';
      case 3:
        return 'On Hold';
      case 4:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
  factory DetailsRequestEscrow.fromJson(Map<String, dynamic> json) {
    return DetailsRequestEscrow(
      id: json['escrow']?['id'] ?? 0,
      title: json['escrow']?['title'],
      attachment: json['attachment'],
      gross: double.tryParse(json['escrow']?['gross']?.toString() ?? '0.000') ?? 0.0,
      description: json['escrow']?['description'] ?? '', // Default value
      currencySymbol: json['escrow']?['currency_symbol'],
      status: json['escrow']?['status'] ?? 0,
      escrows_hpd: _parseHoldingPeriod(json['escrows_hpd']),
      senderEmail: json['sender']?['email'],
      receiverEmail: json['receiver']?['email'],
      createdAt: json['escrow']?['created_at'] != null
          ? DateTime.tryParse(json['escrow']['created_at'])
          : null, // Safely parse nullable DateTime
    );
  }
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



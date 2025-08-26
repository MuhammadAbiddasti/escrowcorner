import 'dart:convert';
import 'package:escrowcorner/widgets/custom_api_url/constant_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../widgets/custom_token/constant_token.dart';

// DetailsRequestEscrow model for detail view
class DetailsRequestEscrow {
  final int id;
  final String? title;
  final String? attachment;
  final String gross;
  final String description;
  final String? currencySymbol;
  final int status;
  final String? senderEmail;
  final String? receiverEmail;
  final DateTime? createdAt;
  final int? escrowCategoryId;
  final String? escrowCategoryName;
  final int? paymentMethodId;
  final String? paymentMethodName;
  final int agreement;
  final int escrows_hpd;
  final String? fee;
  final String? net;
  final String? holdingPeriod;

  DetailsRequestEscrow({
    required this.id,
    this.title,
    this.attachment,
    required this.gross,
    this.description = '',
    this.currencySymbol,
    required this.status,
    this.senderEmail,
    this.receiverEmail,
    this.createdAt,
    this.escrowCategoryId,
    this.escrowCategoryName,
    this.paymentMethodId,
    this.paymentMethodName,
    required this.agreement,
    required this.escrows_hpd,
    this.fee,
    this.net,
    this.holdingPeriod,
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
    print("DetailsRequestEscrow.fromJson called with: $json");
    print("JSON keys: ${json.keys.toList()}");
    
    try {
      // Extract escrow data from nested structure
      Map<String, dynamic>? escrowData;
      if (json.containsKey('escrow') && json['escrow'] is Map) {
        escrowData = Map<String, dynamic>.from(json['escrow']);
        print('Extracted escrow data: $escrowData');
      } else {
        print('No escrow data found in response');
      }
      
      // Handle different possible field names for sender and receiver
      String? senderEmail;
      if (json['sender'] is Map) {
        senderEmail = json['sender']['email'];
        print('Extracted sender email from sender map: $senderEmail');
      } else if (json['sender_email'] != null) {
        senderEmail = json['sender_email'];
        print('Extracted sender email from sender_email field: $senderEmail');
      } else if (json['user'] is Map) {
        senderEmail = json['user']['email'];
        print('Extracted sender email from user map: $senderEmail');
      }
      
      String? receiverEmail;
      if (json['receiver'] is Map) {
        receiverEmail = json['receiver']['email'];
        print('Extracted receiver email from receiver map: $receiverEmail');
      } else if (json['receiver_email'] != null) {
        receiverEmail = json['receiver_email'];
        print('Extracted receiver email from receiver_email field: $receiverEmail');
      } else if (json['to_user'] is Map) {
        receiverEmail = json['to_user']['email'];
        print('Extracted receiver email from to_user map: $receiverEmail');
      }
      
      // Handle different possible field names for payment method
      String? paymentMethodName;
      if (escrowData != null && escrowData['payment_method'] is Map) {
        paymentMethodName = escrowData['payment_method']['payment_method_name'] ?? 
                           escrowData['payment_method']['name'];
      } else if (json['payment_method'] is Map) {
        paymentMethodName = json['payment_method']['payment_method_name'] ?? 
                           json['payment_method']['name'];
      } else if (json['payment_method_name'] != null) {
        paymentMethodName = json['payment_method_name'];
      }
      
      // Handle different possible field names for escrow category
      String? escrowCategoryName;
      if (escrowData != null && escrowData['escrow_category'] is Map) {
        escrowCategoryName = escrowData['escrow_category']['name'];
      } else if (json['escrow_category'] is Map) {
        escrowCategoryName = json['escrow_category']['name'];
      } else if (json['escrow_category_name'] != null) {
        escrowCategoryName = json['escrow_category_name'];
      }
      
      // Extract holding period from the response
      String? holdingPeriodStr = json['holding_period'];
      int escrows_hpd = 0;
      if (holdingPeriodStr != null && holdingPeriodStr.contains('days')) {
        // Extract number from "30 days" format
        final regex = RegExp(r'(\d+)');
        final match = regex.firstMatch(holdingPeriodStr);
        if (match != null) {
          escrows_hpd = int.tryParse(match.group(1) ?? '0') ?? 0;
          print('Extracted holding period: $escrows_hpd from "$holdingPeriodStr"');
        }
      } else {
        print('Holding period not found or invalid format: $holdingPeriodStr');
      }
      
      final result = DetailsRequestEscrow(
        id: escrowData?['id'] ?? json['id'] ?? 0,
        title: escrowData?['title'] ?? json['title'] ?? 'No Title',
        attachment: escrowData?['attachment'] ?? json['attachment'],
        gross: escrowData?['gross']?.toString() ?? json['gross']?.toString() ?? '0.000',
        description: escrowData?['description'] ?? json['description'] ?? '',
        currencySymbol: escrowData?['currency_symbol'] ?? json['currency_symbol'] ?? '',
        status: escrowData?['status'] ?? json['status'] ?? 0,
        senderEmail: senderEmail,
        receiverEmail: receiverEmail,
        createdAt: escrowData?['created_at'] != null ? DateTime.tryParse(escrowData!['created_at']) :
                   json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
        escrowCategoryId: escrowData?['escrow_category_id'] ?? json['escrow_category_id'],
        escrowCategoryName: escrowCategoryName,
        paymentMethodId: escrowData?['payment_method_id'] ?? json['payment_method_id'],
        paymentMethodName: paymentMethodName,
        agreement: escrowData?['agreement'] ?? json['agreement'] ?? 0,
        escrows_hpd: escrows_hpd,
        fee: json['fee']?.toString(),
        net: json['net']?.toString(),
        holdingPeriod: holdingPeriodStr,
      );
      
      print("Created DetailsRequestEscrow: $result");
      return result;
    } catch (e) {
      print("ERROR in DetailsRequestEscrow.fromJson: $e");
      print("Stack trace: ${StackTrace.current}");
      
      // Return a default object with the available data
      return DetailsRequestEscrow(
        id: json['id'] ?? 0,
        title: json['title'] ?? 'Error Loading',
        attachment: json['attachment'],
        gross: json['gross']?.toString() ?? '0.000',
        description: json['description'] ?? '',
        currencySymbol: json['currency_symbol'] ?? '',
        status: json['status'] ?? 0,
        senderEmail: json['sender_email'] ?? json['user']?['email'] ?? 'N/A',
        receiverEmail: json['receiver_email'] ?? json['to_user']?['email'] ?? 'N/A',
        createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
        escrowCategoryId: json['escrow_category_id'],
        escrowCategoryName: json['escrow_category_name'],
        paymentMethodId: json['payment_method_id'],
        paymentMethodName: json['payment_method_name'],
        agreement: json['agreement'] ?? 0,
        escrows_hpd: 0,
        fee: json['fee']?.toString(),
        net: json['net']?.toString(),
        holdingPeriod: json['holding_period'],
      );
    }
  }
  
  @override
  String toString() {
    return 'DetailsRequestEscrow(id: $id, title: $title, gross: $gross, status: $status, escrows_hpd: $escrows_hpd, senderEmail: $senderEmail, receiverEmail: $receiverEmail, createdAt: $createdAt)';
  }
}

class CancelledEscrowController extends GetxController {
  var isLoading = false.obs;
  var canceledEscrows = <CancelledEscrow>[].obs;
  var isLoadingCancelledDetail = false.obs;
  var cancelledEscrowDetail = <DetailsRequestEscrow>[].obs;
  
  // Check if we have data
  bool get hasData => canceledEscrows.isNotEmpty;
  
  // Preserve data when navigating away
  void preserveData() {
    // Keep existing data when navigating to other screens
  }
  
  // Called when screen becomes visible
  void onScreenVisible() {
    // Screen is visible, can refresh data if needed
  }
  
  // Reset loading state if we have data available
  void resetLoadingIfDataAvailable() {
    if (hasData) {
      isLoading.value = false;
    }
  }
  
  // Clear data when needed
  void clearData() {
    canceledEscrows.clear();
    isLoading.value = false;
  }
  
  // Check if we should show loading
  bool get shouldShowLoading => isLoading.value && canceledEscrows.isEmpty;
  
  // Handle navigation from other escrow screens
  void handleNavigationFromOtherScreen() {
    print("=== handleNavigationFromOtherScreen called ===");
    print("Current canceledEscrows length: ${canceledEscrows.length}");
    print("Current isLoading: ${isLoading.value}");
    
    // If we have data, preserve it and reset loading
    if (hasData) {
      print("Data available, preserving and resetting loading state");
      preserveData();
      resetLoadingIfDataAvailable();
    } else {
      print("No data available, will fetch fresh data");
    }
  }

  // Other methods...

  Future<void> fetchCanceledEscrows() async {
    // If we already have data, don't fetch again
    if (canceledEscrows.isNotEmpty) {
      print("Data already available, skipping fetch");
      return;
    }
    
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

  Future<void> fetchCancelledEscrowDetail(int id) async {
    print("=== fetchCancelledEscrowDetail called with ID: $id ===");
    isLoadingCancelledDetail(true);
    
    String? token = await getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/requestedEscrowDetail/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("=== API Response received ===");
        print("Response status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        print("Parsed response data: $data");
        print("Response data keys: ${data.keys.toList()}");
        
        // Check for both 'success' boolean and 'status' string
        if (data['success'] == true || data['status'] == 'success') {
          print('=== Data to be parsed ===');
          print('API Response data: $data');
          print('Response data type: ${data.runtimeType}');
          print('Response data keys: ${data.keys.toList()}');
          
          // Try to parse the data - it might be at root level or in 'data' field
          try {
            print('=== About to parse DetailsRequestEscrow ===');
            print('Data being passed to parser: $data');
            
            // First try to parse the entire response data
            final cancelledEscrow = DetailsRequestEscrow.fromJson(data);
            cancelledEscrowDetail.assignAll([cancelledEscrow]);
            print("=== SUCCESS: Cancelled escrow detail fetched successfully ===");
            print("=== Data assigned successfully ===");
          } catch (parseError) {
            print('Error parsing entire response: $parseError');
            
            // If that fails, try to parse from 'data' field if it exists
            if (data['data'] != null) {
              try {
                print('=== Trying to parse from data field ===');
                final cancelledEscrow = DetailsRequestEscrow.fromJson(data['data']);
                cancelledEscrowDetail.assignAll([cancelledEscrow]);
                print("=== SUCCESS: Parsed from data field ===");
              } catch (dataParseError) {
                print('Error parsing from data field: $dataParseError');
                cancelledEscrowDetail.clear();
              }
            } else {
              print('No data field found in response');
              cancelledEscrowDetail.clear();
            }
          }
        } else {
          print('API returned success: false, message: ${data['message']}');
          cancelledEscrowDetail.clear();
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
        cancelledEscrowDetail.clear();
      }
    } catch (e) {
      print("Exception occurred: $e");
      cancelledEscrowDetail.clear();
    } finally {
      isLoadingCancelledDetail(false);
    }
  }
  
  // Debug method to check current state
  void checkCurrentState() {
    print("=== CancelledEscrowController State Check ===");
    print("isLoading: ${isLoading.value}");
    print("isLoadingCancelledDetail: ${isLoadingCancelledDetail.value}");
    print("canceledEscrows length: ${canceledEscrows.length}");
    print("cancelledEscrowDetail length: ${cancelledEscrowDetail.length}");
    if (cancelledEscrowDetail.isNotEmpty) {
      final detail = cancelledEscrowDetail.first;
      print("First detail item: $detail");
    }
    print("==========================================");
  }
}

class CancelledEscrow {
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

  CancelledEscrow({
    required this.id,
    this.userId,
    this.to,
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
      userId: json['user']?['email'] ?? 'N/A',
      to: json['to_user']?['email'] ?? 'N/A',
      title: json['title'] ?? 'Cancelled Escrow',
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

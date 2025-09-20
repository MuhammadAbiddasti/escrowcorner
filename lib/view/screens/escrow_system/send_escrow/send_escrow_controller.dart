import 'dart:convert';

import 'package:escrowcorner/view/screens/escrow_system/send_escrow/screen_escrow_list.dart';
import 'package:escrowcorner/view/screens/escrow_system/models/escrow_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../widgets/custom_api_url/constant_url.dart';
import '../../../../widgets/custom_token/constant_token.dart';
import '../rejected_escrow/get_rejected_escrow.dart';
import '../rejected_escrow/rejected_escrow_controller.dart';
import '../../../controller/language_controller.dart';

class SendEscrowsController extends GetxController {
  var isLoading = false.obs;
  var escrows = <Escrow>[].obs;
  final escrowDetail = <DetailsSendEscrow>[].obs;
  final RejectedEscrowController rejectController = Get.put(RejectedEscrowController());

  // Observable variables for escrow information
  var escrowInformation = <DetailsSendEscrow>[].obs;
  var isLoadingInformation = false.obs;
  
  // Method to check if data is already loaded
  bool get hasData => escrows.isNotEmpty;
  
  // Method to preserve data across navigation
  void preserveData() {
    // This method can be called to ensure data is not cleared during navigation
    print("Preserving send escrow data. Current count: ${escrows.length}");
  }
  
  // Method to handle navigation state changes
  void onScreenVisible() {
    print("Send escrow screen became visible. Current data count: ${escrows.length}");
    // If we have data, ensure loading state is false
    if (escrows.isNotEmpty) {
      isLoading.value = false;
    }
  }
  
  // Method to reset loading state if data is available
  void resetLoadingIfDataAvailable() {
    if (escrows.isNotEmpty) {
      isLoading.value = false;
      print("Reset loading state because data is available");
    }
  }
  
  // Method to clear data only when explicitly needed
  void clearData() {
    escrows.clear();
    escrowDetail.clear();
    escrowInformation.clear();
    print("Send escrow data cleared");
  }
  
  // Method to force refresh data (ignores existing data check)
  Future<void> forceRefreshData() async {
    print("Force refreshing send escrow data");
    await fetchSendEscrows(forceRefresh: true);
  }
  
  // Method to check if we should show loading state
  bool get shouldShowLoading => isLoading.value && escrows.isEmpty;
  
  // Method to handle navigation from other escrow screens
  void handleNavigationFromOtherScreen() {
    print("Handling navigation from other escrow screen");
    // If we have data, don't show loading
    if (escrows.isNotEmpty) {
      isLoading.value = false;
      print("Data already available, hiding loader");
    } else {
      print("No data available, will show loader");
    }
  }


  Future<void> fetchSendEscrows({bool forceRefresh = false}) async {
    // If data is already loaded and not forcing refresh, don't show loading state
    if (escrows.isNotEmpty && !forceRefresh) {
      print("Data already available, skipping fetch");
      return;
    }
    
    isLoading.value = true;
    String? token = await getToken();
    final url = Uri.parse("$baseUrl/api/sendEscrow");

    if (token == null) {
      final languageController = Get.find<LanguageController>();
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('token_not_found'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
    print("=== fetchEscrowDetail called with ID: $id ===");
    isLoading.value = true;
    String? token = await getToken();
    print("Token: ${token != null ? 'Token exists' : 'Token is null'}");

    try {
      final url = "$baseUrl/api/escrowagreement/$id";
      print("Calling API URL: $url");
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("Response status code: ${response.statusCode}");
      print("Response headers: ${response.headers}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print("Parsed response data: $responseData");
        print("Response status: ${responseData['status']}");
        
        if (responseData['status'] == 'success') {
          print("Status is success, parsing escrow details...");
          // Parse the response directly since escrow details are at root level
          final DetailsSendEscrow escrow = DetailsSendEscrow.fromJson(responseData);
          print("Parsed escrow object: $escrow");
          escrowDetail.assignAll([escrow]); // Assign to observable list
          print("Escrow details loaded successfully: ${escrowDetail.length} items");
          print("escrowDetail value: ${escrowDetail.value}");
        } else {
          escrowDetail.clear();
          print("No details available - status not success: ${responseData['status']}");
        }
      } else {
        print("Failed to fetch escrow details. Status code: ${response.statusCode}");
        print("Error response body: ${response.body}");
        escrowDetail.clear();
      }
    } catch (e) {
      print("Error fetching escrow details: $e");
      print("Error stack trace: ${StackTrace.current}");
      escrowDetail.clear();
    } finally {
      isLoading.value = false;
      print("=== fetchEscrowDetail completed ===");
    }
  }

  Future<Map<String, dynamic>?> escrowRelease(String eid) async {
    print("=== escrowRelease called with ID: $eid ===");
    final String? token = await getToken(); // Ensure getToken() fetches your auth token
    final Uri url = Uri.parse("$baseUrl/api/escrowRelease");
    
    if (token == null) {
      print("Token is null, returning error");
      return {'status': 'error', 'message': 'Token not found'};
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
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        print("Release API success: $data");
        // Return the API response for the UI to handle
        return data;
      } else {
        print("Release API error: ${response.statusCode} - ${data['message']}");
        // Return error response
        return {
          'status': 'error',
          'message': data['message'] ?? 'Failed to process escrow release'
        };
      }
    } catch (e) {
      print("Release API exception: $e");
      return {
        'status': 'error',
        'message': 'An error occurred: ${e.toString()}'
      };
    }
  }

  Future<void> escrowReject(String eid) async {
    final String? token = await getToken(); // Ensure getToken() fetches your auth token
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
      final response = await http.post(
        Uri.parse("$baseUrl/api/reject"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'eid': eid,
        }),
      );
      print("response body: ${response.body}");
      print("response code: ${response.statusCode}");
      if (response.statusCode == 200) {
        Get.snackbar(
          languageController.getTranslation('success'),
          languageController.getTranslation('escrow_reject_processed_successfully'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Refresh the detail screen instead of navigating away
        print("=== REFRESHING DETAIL SCREEN AFTER SUCCESS ===");
        await fetchEscrowDetail(int.parse(eid));
        print("=== DETAIL SCREEN REFRESHED AFTER SUCCESS ===");
        // Also refresh the rejected escrows list
        await rejectController.fetchRejectedEscrows();
      } else {
        final data = json.decode(response.body);
        String message = data['message'] ?? languageController.getTranslation('failed_to_process_escrow_reject');
        Get.snackbar(
          languageController.getTranslation('message'),
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        // Refresh the detail screen even on error
        print("=== REFRESHING DETAIL SCREEN AFTER ERROR ===");
        await fetchEscrowDetail(int.parse(eid));
        print("=== DETAIL SCREEN REFRESHED AFTER ERROR ===");
      }
    } catch (e) {
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('an_error_occurred'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // Refresh the detail screen even on exception
      print("=== REFRESHING DETAIL SCREEN AFTER EXCEPTION ===");
      await fetchEscrowDetail(int.parse(eid));
      print("=== DETAIL SCREEN REFRESHED AFTER EXCEPTION ===");
    }
  }

  // Fetch escrow information from API
  Future<void> fetchEscrowInformation(int id) async {
    try {
      isLoadingInformation.value = true;
      print('Fetching escrow information for ID: $id');
      
      final String? token = await getToken();
      if (token == null) {
        print('Error: No auth token available');
        isLoadingInformation.value = false;
        return;
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/view_information/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      print('Information API Response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true || responseData['status'] == 'success') {
          // Parse the information data - try different response structures
          try {
            final informationData = DetailsSendEscrow.fromJson(responseData);
            escrowInformation.value = [informationData];
            print('Escrow information loaded successfully');
          } catch (parseError) {
            print('Error parsing information data: $parseError');
            // Try to create a basic object if parsing fails
            escrowInformation.value = [];
          }
        } else {
          print('Failed to load escrow information: ${responseData['message'] ?? 'Unknown error'}');
          escrowInformation.value = [];
        }
      } else {
        print('Failed to fetch escrow information: ${response.statusCode}');
        escrowInformation.value = [];
      }
    } catch (e) {
      print('Error fetching escrow information: $e');
      escrowInformation.value = [];
    } finally {
      isLoadingInformation.value = false;
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
  final String gross; // Changed to String to preserve exact decimal format
  final String description;
  final String? currencySymbol; // Nullable field
  final int status;
  final String fee; // Changed to String to preserve exact decimal format
  final int escrows_hpd; // Required field but will have default value
  final String? senderEmail; // Nullable field
  final String? receiverEmail; // Nullable field
  final String? createdAt; // Changed to String to preserve "13 hours ago" format
  final String? paymentMethodName; // Added payment method name
  final String? productName; // Added product name
  final int? escrowCategoryId; // Added escrow category ID
  final int? paymentMethodId; // Added payment method ID
  final int? agreement; // Added agreement field
  final String net; // Changed to String to preserve exact decimal format
  final EscrowCategory? escrowCategory; // Added escrow category object

  DetailsSendEscrow({
    required this.id,
    this.title,
    this.attachment,
    required this.gross,
    this.description = '', // Default to an empty string
    this.currencySymbol,
    required this.status,
    required this.fee,
    this.escrows_hpd = 0, // Made optional with default value
    this.senderEmail,
    this.receiverEmail,
    this.createdAt,
    this.paymentMethodName, // Added to constructor
    this.productName, // Added to constructor
    this.escrowCategoryId, // Added to constructor
    this.paymentMethodId, // Added to constructor
    this.agreement, // Added to constructor
    required this.net, // Added to constructor
    this.escrowCategory, // Added to constructor
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
    print("Parsing DetailsSendEscrow from JSON: $json");
    
    final escrow = json['escrow'];
    final sender = json['sender'];
    final receiver = json['receiver'];
    final escrowCategory = escrow?['escrow_category']; // Parse escrow category from nested escrow object
    
    print("Escrow data: $escrow");
    print("Sender data: $sender");
    print("Receiver data: $receiver");
    print("Escrow Category data: $escrowCategory");
    
    return DetailsSendEscrow(
      id: escrow?['id'] ?? 0,
      title: escrow?['title'],
      attachment: escrow?['attachment'], // Fixed: parse from escrow.attachment
      gross: json['gross']?.toString() ?? '0.000', // Parse from root level
      description: escrow?['description'] ?? '', // Default value
      currencySymbol: escrow?['currency_symbol'],
      status: escrow?['status'] ?? 0,
      fee: json['fee']?.toString() ?? '0.000', // Parse from root level
      escrows_hpd: _parseHoldingPeriod(json['holding_period']), // Parse from root level 'holding_period'
      senderEmail: sender?['email'],
      receiverEmail: receiver?['email'],
      createdAt: json['created_at']?.toString(), // Parse from root level
      paymentMethodName: escrow?['payment_method']?['payment_method_name'], // Correctly parse from nested escrow.payment_method
      productName: escrow?['product_name'], // Parse product name
      escrowCategoryId: escrow?['escrow_category_id'], // Parse escrow category ID
      paymentMethodId: escrow?['payment_method_id'], // Parse payment method ID
      agreement: escrow?['agreement'], // Parse agreement field
      net: json['net']?.toString() ?? '0.000', // Parse net amount
      escrowCategory: escrowCategory != null ? EscrowCategory.fromJson(escrowCategory) : null, // Parse escrow category object
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

  @override
  String toString() {
    return 'DetailsSendEscrow{id: $id, title: $title, gross: $gross, description: $description, status: $status, fee: $fee, escrows_hpd: $escrows_hpd, senderEmail: $senderEmail, receiverEmail: $receiverEmail, paymentMethodName: $paymentMethodName, productName: $productName}';
  }
}


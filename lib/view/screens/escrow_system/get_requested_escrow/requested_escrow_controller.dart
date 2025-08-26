import 'dart:convert';
import 'package:escrowcorner/view/screens/escrow_system/models/escrow_models.dart';
import 'package:escrowcorner/view/screens/escrow_system/rejected_escrow/get_rejected_escrow.dart';
import 'package:escrowcorner/view/controller/language_controller.dart';
import 'package:escrowcorner/widgets/custom_api_url/constant_url.dart';
import 'package:escrowcorner/widgets/custom_token/constant_token.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


class RequestedEscrowController extends GetxController {
  final requestEscrows = <RequestedEscrow>[].obs;
  final isLoading = false.obs;
  final escrowAgreementDetail = <EscrowAgreementDetail>[].obs;
  final isLoadingAgreementDetail = false.obs;
  final isRejecting = false.obs;
  final isApproving = false.obs;
  final isReleasing = false.obs;
  final isReleaseSuccessful = false.obs;
  final isApproveSuccessful = false.obs;

  final languageController = Get.find<LanguageController>();

  // Method to clear all data when switching between escrow screens
  void clearData() {
    // Check if controller is still active before clearing data
    if (!Get.isRegistered<RequestedEscrowController>()) {
      print('RequestedEscrowController: Controller not registered, skipping clearData');
      return;
    }
    
    print('RequestedEscrowController: clearData called');
    requestEscrows.clear();
    escrowAgreementDetail.clear();
    isLoading.value = false;
    isLoadingAgreementDetail.value = false;
    isRejecting.value = false;
    isApproving.value = false;
    isReleasing.value = false;
    isReleaseSuccessful.value = false;
    isApproveSuccessful.value = false;
    print('RequestedEscrowController: Data cleared successfully');
  }

  // Method to refresh data when screen is accessed
  Future<void> refreshData() async {
    // Check if controller is still active
    if (!Get.isRegistered<RequestedEscrowController>()) {
      print('RequestedEscrowController: Controller not registered, skipping refreshData');
      return;
    }
    
    print('RequestedEscrowController: refreshData called');
    try {
      // Don't clear data immediately, fetch new data first
      print('RequestedEscrowController: Fetching requested escrows');
      await fetchRequestedEscrows();
      print('RequestedEscrowController: fetchRequestedEscrows completed');
    } catch (e) {
      print('RequestedEscrowController: Error in refreshData: $e');
    }
  }

  // Method to clear and refresh data (for manual use)
  Future<void> clearAndRefresh() async {
    // Check if controller is still active
    if (!Get.isRegistered<RequestedEscrowController>()) {
      print('RequestedEscrowController: Controller not registered, skipping clearAndRefresh');
      return;
    }
    
    print('RequestedEscrowController: clearAndRefresh called');
    try {
      clearData();
      await fetchRequestedEscrows();
    } catch (e) {
      print('RequestedEscrowController: Error in clearAndRefresh: $e');
    }
  }

  Future<void> fetchRequestedEscrows() async {
    // Check if controller is still active
    if (!Get.isRegistered<RequestedEscrowController>()) {
      print('RequestedEscrowController: Controller not registered, skipping fetch');
      return;
    }
    
    print('RequestedEscrowController: fetchRequestedEscrows called');
    isLoading.value = true;
    String? token = await getToken();
    print('RequestedEscrowController: Token obtained: ${token != null ? 'Yes' : 'No'}');
    
    if (token == null) {
      print('RequestedEscrowController: No token available');
      if (Get.isRegistered<RequestedEscrowController>()) {
        isLoading.value = false;
      }
      return;
    }
    
    final apiUrl = "$baseUrl/api/requested_escrow";
    print('RequestedEscrowController: Calling API: $apiUrl');
    
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      print("RequestedEscrowController: Response status: ${response.statusCode}");
      print("RequestedEscrowController: Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('RequestedEscrowController: Parsed response data: $responseData');
        
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          print('RequestedEscrowController: Data array length: ${data.length}');
          
          try {
            final parsedEscrows = data.map((e) {
              print('RequestedEscrowController: Parsing escrow item: $e');
              return RequestedEscrow.fromJson(e);
            }).toList();
            
            // Check if controller is still active before updating state
            if (Get.isRegistered<RequestedEscrowController>()) {
              requestEscrows.assignAll(parsedEscrows);
              print('RequestedEscrowController: Parsed escrows count: ${requestEscrows.length}');
            }
          } catch (parseError) {
            print('RequestedEscrowController: Error parsing escrow data: $parseError');
            print('RequestedEscrowController: Raw data that failed to parse: $data');
          }
        } else {
          print('RequestedEscrowController: API returned success: false');
          print('RequestedEscrowController: Message: ${responseData['message']}');
        }
      } else {
        print('RequestedEscrowController: HTTP Error: ${response.statusCode}');
        print('RequestedEscrowController: Response body: ${response.body}');
      }
    } catch (e) {
      print('RequestedEscrowController: Exception in fetchRequestedEscrows: $e');
    } finally {
      // Check if controller is still active before updating state
      if (Get.isRegistered<RequestedEscrowController>()) {
        isLoading.value = false;
        print('RequestedEscrowController: Loading completed, escrows count: ${requestEscrows.length}');
      }
    }
  }

  Future<void> fetchEscrowAgreementDetail(int escrowId) async {
    // Check if controller is still active
    if (!Get.isRegistered<RequestedEscrowController>()) {
      print('RequestedEscrowController: Controller not registered, skipping fetch');
      return;
    }
    
    isLoadingAgreementDetail.value = true;
    String? token = await getToken();
    
    if (token == null) {
      print('RequestedEscrowController: No token available');
      isLoadingAgreementDetail.value = false;
      return;
    }
    
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/requestedEscrowDetail/$escrowId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      print("Requested Escrow Detail Response: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Raw API Response: ${response.body}');
        print('Parsed Response Data: $responseData');
        print('=== FEE FIELDS IN API RESPONSE ===');
        print('fixed_fee: ${responseData['fixed_fee']}');
        print('percentage_fee: ${responseData['percentage_fee']}');
        print('fee: ${responseData['fee']}');
        print('==================================');
        
        if (responseData['status'] == 'success') {
          // Check if controller is still active before updating state
          if (Get.isRegistered<RequestedEscrowController>()) {
            escrowAgreementDetail.assignAll([EscrowAgreementDetail.fromJson(responseData)]);
            print('Requested Escrow Detail API Response: $responseData');
            print('Parsed EscrowAgreementDetail: ${escrowAgreementDetail.first}');
          }
        } else {
          print('API Error: ${responseData['message']}');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in fetchEscrowAgreementDetail: $e');
    } finally {
      // Check if controller is still active before updating state
      if (Get.isRegistered<RequestedEscrowController>()) {
        isLoadingAgreementDetail.value = false;
      }
    }
  }

  Future<void> rejectRequest(int escrowId) async {
    isRejecting.value = true;
    String? token = await getToken();
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/reject_request"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "eid": escrowId,
        }),
      );
      
      print("Reject Request Response: ${response.body}");
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print("Reject Request Response Data: $responseData");
        
        // Get the message from API response
        final String message = responseData['message'] ?? 'No message received';
        final bool isSuccess = responseData['success'] == true || responseData['status'] == 'success';
        
        Get.snackbar(
          isSuccess ? languageController.getTranslation('success') : languageController.getTranslation('response'),
          message,
          backgroundColor: isSuccess ? Colors.green : Colors.blue,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
        
        // If successful, refresh the escrow agreement details
        if (isSuccess) {
          await fetchEscrowAgreementDetail(escrowId);
        }
      } else {
        // Handle non-200 status codes
        final Map<String, dynamic> errorData = json.decode(response.body);
        final String errorMessage = errorData['message'] ?? 'HTTP Error: ${response.statusCode}';
        
        Get.snackbar(
          languageController.getTranslation('error'),
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
      }
    } catch (e) {
      print('Exception in rejectRequest: $e');
      Get.snackbar(
        languageController.getTranslation('error'),
        'An error occurred while rejecting the request: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      isRejecting.value = false;
    }
  }

  Future<bool> approveRequest(int escrowId) async {
    isApproving.value = true;
    String? token = await getToken();
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/approve_request"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "eid": escrowId,
        }),
      );
      
      print("Approve Request Response: ${response.body}");
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print("Approve Request Response Data: $responseData");
        
        // Get the message from API response
        final String message = responseData['message'] ?? 'No message received';
        final bool isSuccess = responseData['success'] == true || responseData['status'] == 'success';
        
        Get.snackbar(
          isSuccess ? languageController.getTranslation('success') : languageController.getTranslation('response'),
          message,
          backgroundColor: isSuccess ? Colors.green : Colors.blue,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
        
        // If successful, refresh the escrow agreement details
        if (isSuccess) {
          isApproveSuccessful.value = true;
          await fetchEscrowAgreementDetail(escrowId);
        }
      } else if (response.statusCode == 301 || response.statusCode == 302) {
        // Handle redirects
        Get.snackbar(
          languageController.getTranslation('redirect_error'),
          'API endpoint has moved. Please contact support.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
      } else {
        // Handle non-200 status codes
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          final String errorMessage = errorData['message'] ?? 'HTTP Error: ${response.statusCode}';
          
          Get.snackbar(
            languageController.getTranslation('error'),
            errorMessage,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 4),
          );
        } catch (parseError) {
          // If response is not JSON (like HTML), show generic error
          Get.snackbar(
            languageController.getTranslation('error'),
            'HTTP Error: ${response.statusCode} - Invalid response format',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 4),
          );
        }
      }
    } catch (e) {
      print('Exception in approveRequest: $e');
      Get.snackbar(
        languageController.getTranslation('error'),
        'An error occurred while approving the request: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      isApproving.value = false;
    }
    return isApproveSuccessful.value;
  }

  Future<void> releaseRequest(int escrowId) async {
    isReleasing.value = true;
    String? token = await getToken();
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/release_request"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "eid": escrowId,
        }),
      );
      
      print("Release Request Response: ${response.body}");
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print("Release Request Response Data: $responseData");
        
        // Get the message from API response
        final String message = responseData['message'] ?? 'No message received';
        final bool isSuccess = responseData['success'] == true || responseData['status'] == 'success';
        
        Get.snackbar(
          isSuccess ? languageController.getTranslation('success') : languageController.getTranslation('response'),
          message,
          backgroundColor: isSuccess ? Colors.green : Colors.blue,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
        
        // If successful, refresh the escrow agreement details and allow redirect
        if (isSuccess) {
          // Fetch the updated escrow details before redirect
          await fetchEscrowAgreementDetail(escrowId);
          // Set flag to indicate successful release
          isReleaseSuccessful.value = true;
        }
      } else if (response.statusCode == 301 || response.statusCode == 302) {
        // Handle redirects
        Get.snackbar(
          languageController.getTranslation('redirect_error'),
          'API endpoint has moved. Please contact support.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
      } else {
        // Handle non-200 status codes
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          final String errorMessage = errorData['message'] ?? 'HTTP Error: ${response.statusCode}';
          
          Get.snackbar(
            languageController.getTranslation('error'),
            errorMessage,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 4),
          );
        } catch (parseError) {
          // If response is not JSON (like HTML), show generic error
          Get.snackbar(
            languageController.getTranslation('error'),
            'HTTP Error: ${response.statusCode} - Invalid response format',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 4),
          );
        }
      }
    } catch (e) {
      print('Exception in releaseRequest: $e');
      Get.snackbar(
        languageController.getTranslation('error'),
        'An error occurred while releasing the request: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      isReleasing.value = false;
    }
  }

  Future<void> confirmReleaseRequest(int escrowId) async {
    isLoadingAgreementDetail.value = true;
    String? token = await getToken();
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/confirm_release_request"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "eid": escrowId,
        }),
      );
      
      print("Confirm Release Request Response: ${response.body}");
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print("Confirm Release Request Response Data: $responseData");
        
        // Store the response data for display on confirm_release_request screen
        escrowAgreementDetail.assignAll([EscrowAgreementDetail.fromJson(responseData)]);
        
        // No need to show alert message, just store the data
        print('Data loaded successfully from confirm_release_request API');
      } else if (response.statusCode == 301 || response.statusCode == 302) {
        // Handle redirects
        Get.snackbar(
          languageController.getTranslation('redirect_error'),
          'API endpoint has moved. Please contact support.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
      } else {
        // Handle non-200 status codes
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          final String errorMessage = errorData['message'] ?? 'HTTP Error: ${response.statusCode}';
          
          Get.snackbar(
            languageController.getTranslation('error'),
            errorMessage,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 4),
          );
        } catch (parseError) {
          // If response is not JSON (like HTML), show generic error
          Get.snackbar(
            languageController.getTranslation('error'),
            'HTTP Error: ${response.statusCode} - Invalid response format',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 4),
          );
        }
      }
    } catch (e) {
      print('Exception in confirmReleaseRequest: $e');
      Get.snackbar(
        languageController.getTranslation('error'),
        'An error occurred while confirming release request: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoadingAgreementDetail.value = false;
    }
  }

  Future<void> confirmEscrowRequest(int escrowId) async {
    isLoadingAgreementDetail.value = true;
    String? token = await getToken();
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/confirm_escrow_request"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "eid": escrowId,
        }),
      );
      
      print("Confirm Escrow Request Response: ${response.body}");
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print("Confirm Escrow Request Response Data: $responseData");
        
        // Store the response data for display on confirm_escrow_request screen
        escrowAgreementDetail.assignAll([EscrowAgreementDetail.fromJson(responseData)]);
        
        // No need to show alert message, just store the data
        print('Data loaded successfully from confirm_escrow_request API');
      } else if (response.statusCode == 301 || response.statusCode == 302) {
        // Handle redirects
        Get.snackbar(
          languageController.getTranslation('redirect_error'),
          'API endpoint has moved. Please contact support.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
      } else {
        // Handle non-200 status codes
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          final String errorMessage = errorData['message'] ?? 'HTTP Error: ${response.statusCode}';
          
          Get.snackbar(
            languageController.getTranslation('error'),
            errorMessage,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 4),
          );
        } catch (parseError) {
          // If response is not JSON (like HTML), show generic error
          Get.snackbar(
            languageController.getTranslation('error'),
            'HTTP Error: ${response.statusCode} - Invalid response format',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 4),
          );
        }
      }
    } catch (e) {
      print('Exception in confirmEscrowRequest: $e');
      Get.snackbar(
        languageController.getTranslation('error'),
        'An error occurred while confirming escrow request: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoadingAgreementDetail.value = false;
    }
  }
}

class EscrowAgreementDetail {
  final int id;
  final String title;
  final String gross;
  final String net;
  final String fee;
  final String description;
  final String? attachment;
  final int status;
  final int agreement;
  final String createdAt;
  final String updatedAt;
  final String? currencySymbol;
  final String? holdingPeriod;
  final String? senderEmail;
  final String? receiverEmail;
  final String? method;
  final String? categoryName;
  final String? categoryFrTitle;
  final String? fixedEscrowFee;
  final String? percentageEscrowFee;
  final String? totalAmount;

  EscrowAgreementDetail({
    required this.id,
    required this.title,
    required this.gross,
    required this.net,
    required this.fee,
    required this.description,
    this.attachment,
    required this.status,
    required this.agreement,
    required this.createdAt,
    required this.updatedAt,
    this.currencySymbol,
    this.holdingPeriod,
    this.senderEmail,
    this.receiverEmail,
    this.method,
    this.categoryName,
    this.categoryFrTitle,
    this.fixedEscrowFee,
    this.percentageEscrowFee,
    this.totalAmount,
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

  factory EscrowAgreementDetail.fromJson(Map<String, dynamic> json) {
    final categoryTitle = json['escrow']?['escrow_category']?['title'];
    final categoryFr = json['escrow']?['escrow_category']?['fr'];
    
    // Debug logging for fee fields
    print('=== PARSING FEE FIELDS ===');
    print('Raw JSON keys: ${json.keys.toList()}');
    print('fixed_fee: ${json['fixed_fee']} (type: ${json['fixed_fee'].runtimeType})');
    print('percentage_fee: ${json['percentage_fee']} (type: ${json['percentage_fee'].runtimeType})');
    print('fee: ${json['fee']} (type: ${json['fee'].runtimeType})');
    print('currency_symbol: ${json['escrow']?['currency_symbol']}');
    print('==========================');
    
    print('Parsing category - Title: $categoryTitle, FR: $categoryFr');
    print('Raw escrow_category data: ${json['escrow']?['escrow_category']}');
    
    final fixedFee = json['fixed_fee']?.toString();
    final percentageFee = json['percentage_fee']?.toString();
    
    print('Parsed fixed fee: $fixedFee');
    print('Parsed percentage fee: $percentageFee');
    
    return EscrowAgreementDetail(
      id: json['escrow']?['id'] ?? 0,
      title: json['escrow']?['title'] ?? '',
      gross: json['gross']?.toString() ?? '0.000',
      net: json['net']?.toString() ?? '0.000',
      fee: json['fee']?.toString() ?? '0.000',
      description: json['escrow']?['description'] ?? '',
      attachment: json['escrow']?['attachment'],
      status: json['escrow']?['status'] ?? 0,
      agreement: json['escrow']?['agreement'] ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['escrow']?['updated_at']?.toString() ?? '',
      currencySymbol: json['escrow']?['currency_symbol'],
      holdingPeriod: json['holding_period']?.toString(),
      senderEmail: json['sender']?['email'],
      receiverEmail: json['receiver']?['email'],
      method: json['escrow']?['payment_method']?['payment_method_name'],
      categoryName: categoryTitle,
      categoryFrTitle: categoryFr,
      fixedEscrowFee: fixedFee,
      percentageEscrowFee: percentageFee,
      totalAmount: json['total_amount']?.toString(),
    );
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



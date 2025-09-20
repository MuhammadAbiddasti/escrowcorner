import 'package:escrowcorner/view/screens/escrow_system/send_escrow/screen_escrow_list.dart';
import 'package:escrowcorner/widgets/custom_token/constant_token.dart';
import 'package:escrowcorner/widgets/custom_api_url/constant_url.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../controller/language_controller.dart';

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
            final languageController = Get.find<LanguageController>();
            Get.snackbar(
              languageController.getTranslation('info'),
              languageController.getTranslation('no_received_escrows_available'),
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
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
      final languageController = Get.find<LanguageController>();
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('an_error_occurred'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

  // Add escrow detail functionality
  var escrowDetail = <ReceivedEscrowDetail>[].obs;
  var isLoadingDetail = false.obs;
  var escrowAgreementDetail = <EscrowAgreementDetail>[].obs;
  var isLoadingAgreementDetail = false.obs;
  var isRejecting = false.obs;

  Future<void> fetchEscrowDetail(int escrowId) async {
    isLoadingDetail.value = true;
    String? token = await getToken();
    final url = Uri.parse("$baseUrl/api/received_escrow/$escrowId");

    if (token == null) {
      isLoadingDetail.value = false;
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
        print('Escrow Detail API Response: $data');

        if (data is Map && data.containsKey('data')) {
          final escrowData = data['data'];
          if (escrowData is Map) {
            // Cast the dynamic Map to Map<String, dynamic> for proper type safety
            final Map<String, dynamic> typedEscrowData = Map<String, dynamic>.from(escrowData);
            escrowDetail.value = [ReceivedEscrowDetail.fromJson(typedEscrowData)];
          }
        }
      } else {
        print('Failed to fetch escrow detail: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching escrow detail: $e');
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> fetchEscrowAgreementDetail(int escrowId) async {
    isLoadingAgreementDetail.value = true;
    String? token = await getToken();
    final url = Uri.parse("$baseUrl/api/escrowagreement/$escrowId");

    print('=== fetchEscrowAgreementDetail called ===');
    print('Escrow ID: $escrowId');
    print('URL: $url');
    print('Token exists: ${token != null}');

    if (token == null) {
      print('Token is null, cannot make API call');
      isLoadingAgreementDetail.value = false;
      return;
    }

    try {
      print('Making HTTP GET request to: $url');
      print('Headers: Authorization: Bearer ${token.substring(0, 10)}...');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      print('Response received - Status: ${response.statusCode}');
      print('Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Escrow Agreement Detail API Response: $data');
        print('Response body: ${response.body}');

        if (data is Map) {
          print('Response is a Map with keys: ${data.keys.toList()}');
          
          // Check if response has status field like send escrow controller
          if (data.containsKey('status') && data['status'] == 'success') {
            print('Status is success, parsing escrow agreement details...');
            try {
              final Map<String, dynamic> typedData = Map<String, dynamic>.from(data);
              escrowAgreementDetail.value = [EscrowAgreementDetail.fromJson(typedData)];
              print('Parsed escrow agreement detail: ${escrowAgreementDetail.value}');
            } catch (parseError) {
              print('Error parsing data with success status: $parseError');
              print('Parse error stack trace: ${StackTrace.current}');
            }
          } else if (data.containsKey('data')) {
            // Try the data wrapper approach
            final agreementData = data['data'];
            print('Agreement data from data wrapper: $agreementData');
            if (agreementData is Map) {
              final Map<String, dynamic> typedAgreementData = Map<String, dynamic>.from(agreementData);
              print('Typed agreement data: $typedAgreementData');
              escrowAgreementDetail.value = [EscrowAgreementDetail.fromJson(typedAgreementData)];
              print('Parsed escrow agreement detail from data wrapper: ${escrowAgreementDetail.value}');
            } else {
              print('Agreement data is not a Map, type: ${agreementData.runtimeType}');
            }
          } else {
            // Try to parse the data directly
            print('No status or data field found, trying to parse response directly');
            try {
              final Map<String, dynamic> typedData = Map<String, dynamic>.from(data);
              escrowAgreementDetail.value = [EscrowAgreementDetail.fromJson(typedData)];
              print('Parsed escrow agreement detail directly: ${escrowAgreementDetail.value}');
            } catch (parseError) {
              print('Error parsing data directly: $parseError');
              print('Direct parse error stack trace: ${StackTrace.current}');
            }
          }
        } else {
          print('Response is not a Map, type: ${data.runtimeType}');
        }
      } else {
        print('Failed to fetch escrow agreement detail: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching escrow agreement detail: $e');
      print('Error stack trace: ${StackTrace.current}');
      escrowAgreementDetail.clear();
    } finally {
      isLoadingAgreementDetail.value = false;
      print('=== fetchEscrowAgreementDetail completed ===');
    }
  }

  // Add reject escrow functionality
  Future<void> rejectEscrow(int escrowId) async {
    isRejecting.value = true;
    String? token = await getToken();

    print('=== rejectEscrow called ===');
    print('Escrow ID: $escrowId');
    print('URL: $baseUrl/api/reject');
    print('Token exists: ${token != null}');

    if (token == null) {
      print('Token is null, cannot make API call');
      Get.snackbar(
        'Error',
        'Authentication token not found',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      print('Making HTTP POST request to: $baseUrl/api/reject');
      print('Request body: {"eid": $escrowId}');
      print('Headers: Authorization: Bearer ${token.substring(0, 10)}...');

      final response = await http.post(
        Uri.parse("$baseUrl/api/reject"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'eid': escrowId,
        }),
      );

      print('Response received - Status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Reject API Response: $data');

        if (data is Map && data.containsKey('status')) {
          if (data['status'] == 'success') {
            print('Escrow rejected successfully');
            print('Backend success message: ${data['message'] ?? 'No message'}');
            Get.snackbar(
              'Success',
              data['message'] ?? 'Escrow rejected successfully',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: Duration(seconds: 5),
            );
            
            // Refresh the received escrow list after successful rejection
            await fetchReceiverEscrows();
            
            // Refresh the escrow agreement details
            await fetchEscrowAgreementDetail(escrowId);
            
            // Optionally navigate back or refresh the screen
            // Get.back();
          } else {
            print('Reject failed: ${data['message'] ?? 'Unknown error'}');
            Get.snackbar(
              'Error',
              data['message'] ?? 'Failed to reject escrow',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            // Refresh the received escrow list even on error
            await fetchReceiverEscrows();
            // Also refresh the detail screen even on error
            await fetchEscrowAgreementDetail(escrowId);
          }
        } else {
          print('Invalid response format');
          Get.snackbar(
            'Error',
            'Invalid response from server',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          // Refresh the received escrow list even on invalid response
          await fetchReceiverEscrows();
          // Also refresh the detail screen even on invalid response
          await fetchEscrowAgreementDetail(escrowId);
        }
      } else {
        print('Failed to reject escrow: ${response.statusCode}');
        print('Response body: ${response.body}');
        
        // Try to parse error message from response body
        String errorMessage = 'Failed to reject escrow. Please try again.';
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'];
            print('Backend error message: $errorMessage');
          }
        } catch (e) {
          print('Could not parse error response: $e');
        }
        
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
        // Refresh the received escrow list even on HTTP error
        await fetchReceiverEscrows();
        // Also refresh the detail screen even on HTTP error
        await fetchEscrowAgreementDetail(escrowId);
      }
    } catch (e) {
      print('Error rejecting escrow: $e');
      print('Error stack trace: ${StackTrace.current}');
      Get.snackbar(
        'Error',
        'Network error. Please check your connection.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // Refresh the received escrow list even on exception
      await fetchReceiverEscrows();
      // Also refresh the detail screen even on exception
      await fetchEscrowAgreementDetail(escrowId);
    } finally {
      isRejecting.value = false;
      print('=== rejectEscrow completed ===');
    }
  }
}

// ReceivedEscrowDetail model for detailed view
class ReceivedEscrowDetail {
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

  ReceivedEscrowDetail({
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
  });

  String get statusLabel {
    switch (status) {
      case 0:
        return 'on hold';
      case 1:
        return 'Completed';
      case 2:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  factory ReceivedEscrowDetail.fromJson(Map<String, dynamic> json) {
    return ReceivedEscrowDetail(
      id: json['id'] ?? 0,
      title: json['title'],
      attachment: json['attachment'],
      gross: json['gross']?.toString() ?? '0.000',
      description: json['description'] ?? '',
      currencySymbol: json['currency_symbol'],
      status: json['status'] ?? 0,
      senderEmail: json['sender']?['email'],
      receiverEmail: json['receiver']?['email'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      escrowCategoryId: json['escrow_category_id'],
      escrowCategoryName: json['escrow_category']?['name'],
      paymentMethodId: json['payment_method_id'],
      paymentMethodName: json['payment_method']?['payment_method_name'],
      agreement: json['agreement'] ?? 0,
    );
  }
}

// EscrowAgreementDetail model for agreement details
class EscrowAgreementDetail {
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
  final int? holdingPeriod;

  EscrowAgreementDetail({
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
    this.holdingPeriod,
  });

  String get statusLabel {
    switch (status) {
      case 0:
        return 'on hold';
      case 1:
        return 'Completed';
      case 2:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  factory EscrowAgreementDetail.fromJson(Map<String, dynamic> json) {
    print('Parsing EscrowAgreementDetail JSON: $json');
    
    // Extract escrow data from nested structure
    Map<String, dynamic>? escrowData;
    if (json.containsKey('escrow') && json['escrow'] is Map) {
      escrowData = Map<String, dynamic>.from(json['escrow']);
      print('Extracted escrow data: $escrowData');
    } else {
      print('No escrow data found in response');
    }
    
    // Log sender and receiver data
    print('Sender data: ${json['sender']}');
    print('Receiver data: ${json['receiver']}');
    print('Holding period: ${json['holding_period']}');
    
    // Handle different possible field names for sender and receiver
    String? senderEmail;
    if (json['sender'] is Map) {
      senderEmail = json['sender']['email'];
    } else if (json['sender_email'] != null) {
      senderEmail = json['sender_email'];
    }
    
    String? receiverEmail;
    if (json['receiver'] is Map) {
      receiverEmail = json['receiver']['email'];
    } else if (json['receiver_email'] != null) {
      receiverEmail = json['receiver_email'];
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
    int? holdingPeriod;
    if (holdingPeriodStr != null && holdingPeriodStr.contains('days')) {
      // Extract number from "30 days" format
      final regex = RegExp(r'(\d+)');
      final match = regex.firstMatch(holdingPeriodStr);
      if (match != null) {
        holdingPeriod = int.tryParse(match.group(1) ?? '0');
        print('Extracted holding period: $holdingPeriod from "$holdingPeriodStr"');
      }
    } else {
      print('Holding period not found or invalid format: $holdingPeriodStr');
    }
    
    return EscrowAgreementDetail(
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
      holdingPeriod: holdingPeriod ?? 0,
    );
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



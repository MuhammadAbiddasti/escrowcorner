import 'dart:convert';

import 'package:escrowcorner/widgets/custom_api_url/constant_url.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../../widgets/custom_token/constant_token.dart';
class RejectedEscrowController extends GetxController {
  var isLoading = false.obs;
  var rejectedEscrows = <RejectedEscrow>[].obs;
  var rejectedCurrentPage = 1.obs;
  var rejectedTotalPages = 1.obs;
  var isLoadingAgreementDetail = false.obs;
  var escrowAgreementDetail = <EscrowAgreementDetail>[].obs;
  bool get rejectedHasPreviousPage => rejectedCurrentPage.value > 1;
  bool get rejectedHasNextPage => rejectedCurrentPage.value < rejectedTotalPages.value;


  Future<void> fetchRejectedEscrows({int page = 1}) async {
    isLoading(true);
    String? token = await getToken();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/rejected_escrow?page=$page'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Log the full response for debugging
        print('API Response: $data');

        // Ensure 'data' key exists and contains the expected nested structure
        // Ensure 'data' key exists and is a list
        if (data is Map && data.containsKey('data') && data['data'] is List) {
          final List<dynamic> escrows = data['data'];

          // Safely map the dynamic list to ReceiverEscrow objects
          rejectedEscrows.value =
              escrows.map((item) =>
                  RejectedEscrow.fromJson(item as Map<String, dynamic>)).toList();
        } else {
          //Get.snackbar('Error', 'Response does not contain the expected nested data key');
        }
      } else {
       // Get.snackbar('Error', 'Failed to load escrows: ${response.statusCode}');
      }

    } catch (e) {
      print("Exception: $e");
      //Get.snackbar("Error", "An error occurred: $e", snackPosition: SnackPosition.BOTTOM,);
    } finally {
      isLoading(false);
    }
  }


  void nextPage() {
    if (rejectedHasNextPage) {
      fetchRejectedEscrows( page: rejectedCurrentPage.value + 1);
    }
  }

  void previousPage() {
    if (rejectedHasPreviousPage) {
      fetchRejectedEscrows( page: rejectedCurrentPage.value - 1);
    }
  }

  // Method to fetch a specific rejected escrow by ID
  Future<RejectedEscrow?> fetchRejectedEscrowById(int escrowId) async {
    // First check if we already have it in the list
    final existingEscrow = rejectedEscrows.firstWhereOrNull((escrow) => escrow.id == escrowId);
    if (existingEscrow != null) {
      return existingEscrow;
    }

    // If not found, fetch all and try again
    await fetchRejectedEscrows();
    return rejectedEscrows.firstWhereOrNull((escrow) => escrow.id == escrowId);
  }

  // Method to fetch escrow agreement details using the same API as received escrow
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

class RejectedEscrow {
  final int id;
  final String userId; // Changed to String to accommodate email
  final String to;     // Changed to String to accommodate email
  final String title;
  final String? attachment;
  final String gross;
  final String description;
  final String currencySymbol;
  final int status;
  final DateTime createdAt;

  RejectedEscrow({
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
        return 'on hold';
      case 1:
        return 'Completed';
      case 2:
        return 'Rejected';
      case 3:
        return 'unknown';
      case 4:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  factory RejectedEscrow.fromJson(Map<String, dynamic> json) {
    return RejectedEscrow(
      id: json['id'] ?? 0,
      userId: json['user']?['email'] ?? 'Unknown', // Assuming email is a string
      to: json['to_user']?['email'] ?? 'Unknown', // Assuming email is a string
      title: json['title'] ?? 'Untitled',
      attachment: json['attachment'],
      gross: json['gross'] ?? '0.000',
      description: json['description'] ?? 'No description provided',
      currencySymbol: json['currency_symbol'] ?? 'N/A',
      status: json['status'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}


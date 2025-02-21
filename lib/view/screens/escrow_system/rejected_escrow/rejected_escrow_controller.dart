import 'dart:convert';

import 'package:dacotech/widgets/custom_api_url/constant_url.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../../widgets/custom_token/constant_token.dart';
class RejectedEscrowController extends GetxController {
  var isLoading = false.obs;
  var rejectedEscrows = <RejectedEscrow>[].obs;
  var rejectedCurrentPage = 1.obs;
  var rejectedTotalPages = 1.obs;
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


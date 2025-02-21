import 'package:dacotech/widgets/custom_token/constant_token.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../widgets/custom_api_url/constant_url.dart';

class HomeController extends GetxController {
  var selectedOption = 'Today'.obs;
  var dashboardCurrentPage = 1.obs;
  var dashboardTotalPages = 1.obs;
  var pendingCurrentPage = 1.obs;
  var pendingTotalPages = 1.obs;
  var isLoading = true.obs;
  var isWalletCreated = false.obs;
  var errorMessage = ''.obs;
  var pendingTransactions = <PendingTransaction>[].obs;
  RxList<PendingMoneyRequest> pendingMoneyRequests = <PendingMoneyRequest>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPendingData("Today");
    fetchPendingMoneyRequests('Today');
  }
  bool get pendingHasPreviousPage => pendingCurrentPage.value > 1;
  bool get pendingHasNextPage => pendingCurrentPage.value < pendingTotalPages.value;

  //Transaction To Confirm
  Future<void> fetchPendingData(String type, {int page = 1}) async {
    String? token = await getToken();

    if (token == null) {
      //Get.snackbar('Error', 'Token is null');
      isLoading.value = false;
      return;
    }

    isLoading.value = true;

    try {

      final response = await http.get(
        Uri.parse('$baseUrl/api/home?type=$type&page=$page'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      // print('fetchPendingData called with type: $type, page: $page');
      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse JSON response
        try {
          var data = json.decode(response.body);

          if (data['transactions_to_confirm'] != null &&
              data['transactions_to_confirm']['data'] is List) {
            var transactionsData = data['transactions_to_confirm']['data'] as List;

            // Update current page and total pages
            pendingCurrentPage.value = data['transactions_to_confirm']['current_page'];
            pendingTotalPages.value = data['transactions_to_confirm']['last_page'];

            // Clear previous transactions and add new ones
            pendingTransactions.clear();
            pendingTransactions.addAll(transactionsData.map((t) {
              return PendingTransaction.fromJson(t);
            }).toList());
          } else {
            //Get.snackbar('Error', 'Unexpected response format');
          }
        } catch (e) {
          print('Error while parsing JSON: $e');
          //Get.snackbar('Error', 'Failed to parse response');
        }
      } else if (response.statusCode == 429) {
        print('Too many requests, please try again later.');
        Get.snackbar('Rate Limit Exceeded', 'You are making requests too frequently. Please try again later.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,);
      } else {
        print('Failed to fetch data, status code: ${response.statusCode}');
        //Get.snackbar('Error', 'Failed to fetch data (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Exception caught: $e');
      //Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void nextPage() {
    if (pendingHasNextPage) {
      fetchPendingData(selectedOption.value, page: pendingCurrentPage.value + 1);
    }
  }
  void previousPage() {
    if (pendingHasPreviousPage) {
      fetchPendingData(selectedOption.value, page: pendingCurrentPage.value - 1);
    }
  }
  Future<void> fetchFilteredData(String type) async {
    selectedOption.value = type;
    await fetchPendingData(type.toLowerCase());// Fetch data based on the selected filter
  }
  // Method to fetch Pending Money Requests
  Future<void> fetchPendingMoneyRequests(String type) async {
    String? token = await getToken();

    if (token == null) {
      //Get.snackbar('Error', 'Token is null');
      isLoading.value = false;
      return;
    }

    isLoading.value = true;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/home?type=$type'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      var data = json.decode(response.body);
      //print("Data of pending data: ${data}");
      if (response.statusCode == 200) {
        if (data['myRequests'] != null && data['myRequests'] is List) {
          var requestsData = data['myRequests'] as List;
          pendingMoneyRequests.clear();
          pendingMoneyRequests.addAll(requestsData.map((t) => PendingMoneyRequest.fromJson(t)).toList());
        } else {
          Get.snackbar('Error', 'Unexpected response format',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,);
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(),snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white
      );
      print("Error: ${e.toString()}",);
    } finally {
      isLoading.value = false;
    }
  }
}

class PendingTransaction {
  final String id;
  final int userId;
  final String transactionableId;
  final String transactionableType;
  final int entityId;
  final String entityName;
  final int transactionStateId;
  final String activityTitle;
  final String moneyFlow;
  final double gross;
  final double fee;
  final double net;
  final double balance;
  final String currencySymbol;
  final String createdAt;
  final String updatedAt;
  final String statusName;

  PendingTransaction({
    required this.id,
    required this.userId,
    required this.transactionableId,
    required this.transactionableType,
    required this.entityId,
    required this.entityName,
    required this.transactionStateId,
    required this.activityTitle,
    required this.moneyFlow,
    required this.gross,
    required this.fee,
    required this.net,
    required this.balance,
    required this.currencySymbol,
    required this.createdAt,
    required this.updatedAt,
    required this.statusName,
  });

  factory PendingTransaction.fromJson(Map<String, dynamic> json) {
    return PendingTransaction(
      id: json['id'].toString(),
      userId: int.tryParse(json['user_id'].toString()) ?? 0, // Safely parse to int
      transactionableId: json['transactionable_id'].toString(),
      transactionableType: json['transactionable_type'].toString(),
      entityId: int.tryParse(json['entity_id'].toString()) ?? 0, // Safely parse to int
      entityName: json['entity_name'].toString(),
      transactionStateId: int.tryParse(json['transaction_state_id'].toString()) ?? 0, // Safely parse to int
      activityTitle: json['activity_title'].toString(),
      moneyFlow: json['money_flow'].toString(),
      gross: json['gross'] is String ? double.parse(json['gross']) : json['gross'].toDouble(),  // Handle string or double
      fee: json['fee'] is String ? double.parse(json['fee']) : json['fee'].toDouble(),          // Handle string or double
      net: json['net'] is String ? double.parse(json['net']) : json['net'].toDouble(),          // Handle string or double
      balance: json['balance'] is String ? double.parse(json['balance']) : json['balance'].toDouble(),  // Handle string or double
      currencySymbol: json['currency_symbol'].toString(),
      createdAt: json['created_at'].toString(),
      updatedAt: json['updated_at'].toString(),
      statusName: json['status']['name'].toString(),
    );
  }
}


class PendingMoneyRequest {
  final int id;
  final String name;
  final String status;
  final double gross;
  final double fee;
  final double net;
  final String description;
  final String createdAt;
  final String currencySymbol;

  PendingMoneyRequest({
    required this.id,
    required this.name,
    required this.status,
    required this.gross,
    required this.fee,
    required this.net,
    required this.description,
    required this.createdAt,
    required this.currencySymbol,
  });

  factory PendingMoneyRequest.fromJson(Map<String, dynamic> json) {
    return PendingMoneyRequest(
      id: json['id'] ?? 0,
      status: json['transaction_state_id'] == "3" ? "Pending" : "Completed",
      name: json['user']  ['name'] ?? 'Unknown',
      gross: double.parse(json['gross']),
      fee: double.parse(json['fee']),
      net: double.parse(json['net']),
      description: json['description'] ?? '',
      createdAt: json['created_at'],
      currencySymbol: json['currency_symbol'] ?? '',
    );
  }
}





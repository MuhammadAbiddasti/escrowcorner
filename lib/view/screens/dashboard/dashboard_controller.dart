import 'package:escrowcorner/widgets/custom_token/constant_token.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../widgets/custom_api_url/constant_url.dart';
import 'package:escrowcorner/view/controller/language_controller.dart';

class HomeController extends GetxController {
  var selectedOption = 'Today'.obs;
  var dashboardCurrentPage = 1.obs;
  var dashboardTotalPages = 1.obs;
  var dashboardHasNextPage = false.obs;
  var dashboardHasPreviousPage = false.obs;
  var dashboardData = <dynamic>[].obs;
  var dashboardIsLoading = false.obs;
  var dashboardCurrentPagePending = 1.obs;
  var dashboardTotalPagesPending = 1.obs;
  var dashboardHasNextPagePending = false.obs;
  var dashboardHasPreviousPagePending = false.obs;
  var dashboardDataPending = <dynamic>[].obs;
  var dashboardIsLoadingPending = false.obs;
  var dashboardCurrentPageComplete = 1.obs;
  var dashboardTotalPagesComplete = 1.obs;
  var dashboardHasNextPageComplete = false.obs;
  var dashboardHasPreviousPageComplete = false.obs;
  var dashboardDataComplete = <dynamic>[].obs;
  var dashboardIsLoadingComplete = false.obs;
  var dashboardCurrentPageBalance = 1.obs;
  var dashboardTotalPagesBalance = 1.obs;
  var dashboardHasNextPageBalance = false.obs;
  var dashboardHasPreviousPageBalance = false.obs;
  var dashboardDataBalance = <dynamic>[].obs;
  
  // Original properties
  var pendingCurrentPage = 1.obs;
  var pendingTotalPages = 1.obs;
  var isLoading = true.obs;
  var isBalanceLoading = false.obs;
  var isWalletCreated = false.obs;
  var errorMessage = ''.obs;
  var pendingTransactions = <PendingTransaction>[].obs;
  var pendingMoneyRequests = <PendingMoneyRequest>[].obs;
  var balanceData = <BalanceData>[].obs;
  
  // Dashboard settings
  var dashboardImage = 'assets/images/dashboard.png'.obs;
  var welcomeMessage = 'Welcome back!'.obs;
  var showCreateWallet = true.obs;
  var isDashboardSettingsLoading = false.obs;
  
  // Language controller for dynamic translations
  final LanguageController languageController = Get.find<LanguageController>();

  @override
  void onInit() {
    super.onInit();
    fetchPendingData("Today");
    fetchPendingMoneyRequests('Today');
    fetchBalanceData("today");
    fetchDashboardSettings(); // Fetch dashboard settings
  }
  
  // Fetch dashboard settings from API
  Future<void> fetchDashboardSettings() async {
    String? token = await getToken();

    if (token == null) {
      print('Token is null. Cannot fetch dashboard settings.');
      return;
    }

    isDashboardSettingsLoading.value = true;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/settings'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Dashboard Settings API status: ${response.statusCode}');
      print('Dashboard Settings API body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          // Handle dashboard image URL - prepend base URL if it's a relative asset path
          String imageUrl = data['dashboard_image'] ?? 'assets/images/dashboard.png';
          if (imageUrl.startsWith('assets/')) {
            imageUrl = '$baseUrl/$imageUrl';
          }
          
          dashboardImage.value = imageUrl;
          welcomeMessage.value = languageController.getTranslation('welcome_back') ?? 'Welcome back!';
          showCreateWallet.value = data['show_create_wallet'] ?? true;
          
          print('Dashboard settings fetched successfully');
          print('Dashboard image URL: $imageUrl');
        } else {
          print('Failed to fetch dashboard settings: ${data['message']}');
        }
      } else {
        print('Failed to fetch dashboard settings, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught while fetching dashboard settings: $e');
    } finally {
      isDashboardSettingsLoading.value = false;
    }
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

      print('Dashboard API status:  [33m${response.statusCode} [0m');
      print('Dashboard API body:  [36m${response.body} [0m');

      if (response.statusCode == 200) {
        // Parse JSON response
        try {
          var data = json.decode(response.body);
          print('Dashboard API parsed: $data');

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
            Get.snackbar('Error', 'Dashboard API: Unexpected response format');
            //Get.snackbar('Error', 'Unexpected response format');
          }
        } catch (e) {
          print('Error while parsing JSON: $e');
          Get.snackbar('Error', 'Dashboard API: Failed to parse response');
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
        Get.snackbar('Error', 'Dashboard API: Failed to fetch data (Status: ${response.statusCode})');
        //Get.snackbar('Error', 'Failed to fetch data (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Exception caught: $e');
      Get.snackbar('Error', 'Dashboard API: $e');
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

      print('Dashboard MoneyReq API status:  [33m${response.statusCode} [0m');
      print('Dashboard MoneyReq API body:  [36m${response.body} [0m');

      var data = json.decode(response.body);
      print('Dashboard MoneyReq API parsed: $data');
      //print("Data of pending data: ${data}");
      if (response.statusCode == 200) {
        if (data['myRequests'] != null && data['myRequests'] is List) {
          var requestsData = data['myRequests'] as List;
          pendingMoneyRequests.clear();
          pendingMoneyRequests.addAll(requestsData.map((t) => PendingMoneyRequest.fromJson(t)).toList());
        } else {
          Get.snackbar('Error', 'Dashboard MoneyReq API: Unexpected response format',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,);
          Get.snackbar('Error', 'Unexpected response format',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,);
        }
      } else {
        Get.snackbar('Error', 'Dashboard MoneyReq API: Failed to fetch data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,);
        Get.snackbar('Error', 'Failed to fetch data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,);
      }
    } catch (e) {
      Get.snackbar('Error', 'Dashboard MoneyReq API: $e',snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white
      );
      Get.snackbar('Error', e.toString(),snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white
      );
      print("Error: ${e.toString()}",);
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch balance data for currency containers
  Future<void> fetchBalanceData(String type) async {
    String? token = await getToken();

    if (token == null) {
      print('Token is null. Cannot fetch balance data.');
      return;
    }

    // Set loading to true
    isBalanceLoading.value = true;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/getBalance?type=$type'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Balance API Response Status Code: ${response.statusCode}');
      print('Balance API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> balanceList = data['data'];
          
          balanceData.clear();
          balanceData.addAll(balanceList.map((item) => BalanceData.fromJson(item)).toList());
          
          print('Balance data fetched successfully: ${balanceData.length} items');
        } else {
          print('Failed to fetch balance data: ${data['message']}');
        }
      } else {
        print('Failed to fetch balance data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while fetching balance data: $e');
    } finally {
      // Set loading to false when done
      isBalanceLoading.value = false;
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

// Balance Data Model
class BalanceData {
  final int id;
  final String paymentMethodName;
  final String currency;
  final int currencyId;
  final String status;
  final String? detail;
  final String createdAt;
  final String updatedAt;
  final String totalDeposit;
  final String totalWithdraw;

  BalanceData({
    required this.id,
    required this.paymentMethodName,
    required this.currency,
    required this.currencyId,
    required this.status,
    this.detail,
    required this.createdAt,
    required this.updatedAt,
    required this.totalDeposit,
    required this.totalWithdraw,
  });

  factory BalanceData.fromJson(Map<String, dynamic> json) {
    return BalanceData(
      id: json['id'] ?? 0,
      paymentMethodName: json['payment_method_name'] ?? '',
      currency: json['currency'] ?? '',
      currencyId: json['currency_id'] ?? 0,
      status: json['status'] ?? '',
      detail: json['detail'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      totalDeposit: json['totalDeposit'] ?? '0.00',
      totalWithdraw: json['totalWithdraw'] ?? '0.00',
    );
  }
}

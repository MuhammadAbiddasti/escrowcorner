import 'package:dacotech/widgets/custom_token/constant_token.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../widgets/custom_api_url/constant_url.dart';

class CompleteTransactionController extends GetxController {
  var selectedOption = ''.obs;
  var dashboardCurrentPage = 1.obs;
  var dashboardTotalPages = 1.obs;
  var isLoading = true.obs;
  var dashboard = <Dashboard>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCompleteTransaction('today');
  }

  bool get dashboardHasPreviousPage => dashboardCurrentPage.value > 1;
  bool get dashboardHasNextPage => dashboardCurrentPage.value < dashboardTotalPages.value;

  //Method to Fetch Complete Transaction List on DashBoard
  Future<void> fetchCompleteTransaction(String type, {int page = 1}) async {
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

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['transactions'] != null && data['transactions']['data'] is List) {
          var transactionsData = data['transactions']['data'] as List;

          // Clear old data if fetching the first page
          if (page == 1) {
            dashboard.clear();
          }
          // Update current page and total pages
          dashboardCurrentPage.value = data['transactions']['current_page'];
          dashboardTotalPages.value = data['transactions']['last_page'];
          dashboard.addAll(transactionsData.map((t) {
            return Dashboard.fromJson(t);
          }).toList());
        } else {
          //Get.snackbar('Error', 'Unexpected response format');
        }
      } else {
        //Get.snackbar('Error', 'Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      //Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void filterTransactions(String type) {
    DateTime now = DateTime.now();
    List<Dashboard> filteredTransactions = [];

    if (type == 'Today') {
      filteredTransactions = dashboard.where((transaction) {
        DateTime transactionDate = DateTime.parse(transaction.createdAt);
        return transactionDate.year == now.year &&
            transactionDate.month == now.month &&
            transactionDate.day == now.day;
      }).toList();
    } else if (type == 'This Week') {
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      filteredTransactions = dashboard.where((transaction) {
        DateTime transactionDate = DateTime.parse(transaction.createdAt);
        return transactionDate.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
            transactionDate.isBefore(startOfWeek.add(Duration(days: 7)));
      }).toList();
    } else if (type == 'This Month') {
      filteredTransactions = dashboard.where((transaction) {
        DateTime transactionDate = DateTime.parse(transaction.createdAt);
        return transactionDate.year == now.year &&
            transactionDate.month == now.month;
      }).toList();
    } else if (type == 'This Year') {
      filteredTransactions = dashboard.where((transaction) {
        DateTime transactionDate = DateTime.parse(transaction.createdAt);
        return transactionDate.year == now.year;
      }).toList();
    }

    // Update the displayed transactions with the filtered ones
    dashboard.clear();
    dashboard.addAll(filteredTransactions);
  }

  void nextPage() {
    if (dashboardHasNextPage) {
      fetchCompleteTransaction(selectedOption.value, page: dashboardCurrentPage.value + 1);
    }
  }


  void previousPage() {
    if (dashboardHasPreviousPage) {
      fetchCompleteTransaction(selectedOption.value, page: dashboardCurrentPage.value - 1);
    }
  }

  Future<void> fetchFilteredData(String type) async {
    selectedOption.value = type;
    await fetchCompleteTransaction(type.toLowerCase());
  }
}

class Dashboard {
  final String id;
  final int userId;
  final String? phoneNumber;
  final String? requestId;
  final String? paymentMethodId;
  final String transactionableId;
  final String? transactionableType;
  final String entityId;
  final String entityName;
  final int transactionStateId;
  final String currency;
  final String activityTitle;
  final String moneyFlow;
  final double gross;
  final double fee;
  final double net;
  final double balance;
  final String currencySymbol;
  final String createdAt;
  final String updatedAt;

  Dashboard({
    required this.id,
    required this.userId,
    this.phoneNumber,
    this.requestId,
    this.paymentMethodId,
    required this.transactionableId,
    this.transactionableType,
    required this.entityId,
    required this.entityName,
    required this.transactionStateId,
    required this.currency,
    required this.activityTitle,
    required this.moneyFlow,
    required this.gross,
    required this.fee,
    required this.net,
    required this.balance,
    required this.currencySymbol,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      id: json['id'].toString(),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id']),
      phoneNumber: json['phone_number']?.toString(),  // Convert to String if not null
      requestId: json['request_id']?.toString(),  // Convert to String if not null
      paymentMethodId: json['payment_method_id']?.toString(),  // Convert to String if not null
      transactionableId: json['transactionable_id']?.toString() ?? '',
      transactionableType: json['transactionable_type']?.toString(),  // Convert to String if not null
      entityId: json['entity_id']?.toString() ?? '',
      entityName: json['entity_name'] ?? '',
      transactionStateId: json['transaction_state_id'] is int
          ? json['transaction_state_id']
          : int.parse(json['transaction_state_id']),
      currency: json['currency'] ?? '',
      activityTitle: json['activity_title'] ?? '',
      moneyFlow: json['money_flow'] ?? '',
      gross: json['gross'] is double
          ? json['gross']
          : double.tryParse(json['gross']?.toString() ?? '0') ?? 0.0,
      fee: json['fee'] is double
          ? json['fee']
          : double.tryParse(json['fee']?.toString() ?? '0') ?? 0.0,
      net: json['net'] is double
          ? json['net']
          : double.tryParse(json['net']?.toString() ?? '0') ?? 0.0,
      balance: json['balance'] is double
          ? json['balance']
          : double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
      currencySymbol: json['currency_symbol'] ?? '',
      createdAt: json['created_at']?.toString() ?? '',  // Convert to String if not null
      updatedAt: json['updated_at']?.toString() ?? '',  // Convert to String if not null
    );
  }

}






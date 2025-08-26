import 'package:escrowcorner/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:escrowcorner/widgets/custom_appbar/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../widgets/custom_token/constant_token.dart';
import '../../../widgets/custom_api_url/constant_url.dart';
import '../user_profile/user_profile_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScreenApiWithdrawals extends StatefulWidget {
  @override
  _ScreenApiWithdrawalsState createState() => _ScreenApiWithdrawalsState();
}

class _ScreenApiWithdrawalsState extends State<ScreenApiWithdrawals> {
  var selectedOption = 'All'.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var hasMoreData = true.obs;
  var transactions = <ApiWithdrawal>[].obs;
  var searchController = TextEditingController();
  final UserProfileController userProfileController = Get.find<UserProfileController>();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchApiWithdrawals("all");
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore.value && hasMoreData.value) {
        _loadMoreData();
      }
    }
  }

  void _loadMoreData() {
    if (currentPage.value < totalPages.value) {
      isLoadingMore.value = true;
      fetchApiWithdrawals(
        selectedOption.value.toLowerCase().replaceAll(' ', '_'),
        page: currentPage.value + 1,
      );
    } else {
      hasMoreData.value = false;
    }
  }

  Future<void> fetchApiWithdrawals(String type, {int page = 1}) async {
    String? token = await getToken();

    if (token == null) {
      Get.snackbar('Error', 'Token is null',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      isLoading.value = false;
      return;
    }

    isLoading.value = true;

    // Try both endpoint formats with 2 records per page
    List<String> endpoints = [
      '$baseUrl/api/apiwithdrawals?type=$type&page=$page&per_page=2',
      '$baseUrl/api/api-withdrawals?type=$type&page=$page&per_page=2',
    ];

    for (String endpoint in endpoints) {
      try {
        print('Trying API call to: $endpoint');
        print('Token: ${token.substring(0, 20)}...'); // Log first 20 chars of token
        
        final response = await http.get(
          Uri.parse(endpoint),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        print('API Withdrawals Response Status: ${response.statusCode}');
        print('API Withdrawals Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          
          if (data['success'] == true && data['data'] != null) {
            final List<dynamic> withdrawalsList = data['data'];
            
            // Update pagination info if available
            if (data['pagination'] != null) {
              currentPage.value = data['pagination']['current_page'] ?? 1;
              totalPages.value = data['pagination']['last_page'] ?? 1;
              hasMoreData.value = currentPage.value < totalPages.value;
            }
            
            if (page == 1) {
              transactions.clear();
              hasMoreData.value = true;
            }
            
            transactions.addAll(withdrawalsList.map((item) => ApiWithdrawal.fromJson(item)).toList());
            
            print('API Withdrawals fetched successfully: ${transactions.length} items');
            isLoading.value = false;
            isLoadingMore.value = false;
            return; // Success, exit the loop
          } else {
            print('Failed to fetch API withdrawals: ${data['message']}');
            // Continue to next endpoint if this one failed
          }
        } else {
          print('Failed to fetch API withdrawals. Status Code: ${response.statusCode}');
          print('Error Response: ${response.body}');
          
          // Continue to next endpoint if this one failed
        }
      } catch (e) {
        print('Error occurred while trying endpoint $endpoint: $e');
        // Continue to next endpoint if this one failed
      }
    }
    
    // If we reach here, all endpoints failed
    Get.snackbar('Error', 'Failed to fetch API withdrawals from all endpoints',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white);
    isLoading.value = false;
  }

  Future<void> fetchFilteredData(String type) async {
    selectedOption.value = type;
    currentPage.value = 1;
    hasMoreData.value = true;
    await fetchApiWithdrawals(type.toLowerCase().replaceAll(' ', '_'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: Color(0xff191f28),
        title: AppBarTitle(),
        leading: CustomPopupMenu(managerId: userProfileController.userId.value),
        actions: [
          PopupMenuButtonAction(),
          AppBarProfileButton(),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                    ),
                    child: PopupMenuButton<String>(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() => Text(
                                selectedOption.value,
                                style: TextStyle(fontSize: 16),
                              )),
                          Icon(Icons.expand_more),
                        ],
                      ),
                      onSelected: (String value) {
                        fetchFilteredData(value);
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'All',
                          child: Text('All'),
                        ),
                        PopupMenuItem<String>(
                          value: 'Today',
                          child: Text('Today'),
                        ),
                        PopupMenuItem<String>(
                          value: 'This Week',
                          child: Text('This Week'),
                        ),
                        PopupMenuItem<String>(
                          value: 'This Month',
                          child: Text('This Month'),
                        ),
                        PopupMenuItem<String>(
                          value: 'This Year',
                          child: Text('This Year'),
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 15),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      // Implement search functionality
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Transactions List
          Expanded(
            child: Obx(() {
              if (isLoading.value && transactions.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                );
              }
              
              if (transactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No API Withdrawals Found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No API withdrawals available for the selected period',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final withdrawal = transactions[index];
                        return _buildTransactionCard(withdrawal);
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
              bottomNavigationBar: CustomBottomContainerPostLogin(),
    );
  }

  Widget _buildTransactionCard(ApiWithdrawal withdrawal) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _showTransactionDetails(withdrawal);
          },
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(withdrawal.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(withdrawal.status).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        withdrawal.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(withdrawal.status),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey.shade400,
                      size: 16,
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Transaction Details Grid
                _buildDetailRow('DateTime', withdrawal.formattedDate, Icons.access_time),
                SizedBox(height: 12),
                _buildDetailRow('Transaction ID', withdrawal.id, Icons.receipt),
                SizedBox(height: 12),
                _buildDetailRow('Method', withdrawal.method, Icons.payment),
                SizedBox(height: 12),
                
                // Financial Details Section
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.shade100,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildFinancialRow('Gross', '${withdrawal.amount} ${withdrawal.currency}', Colors.red),
                      SizedBox(height: 8),
                      _buildFinancialRow('Fee', '${withdrawal.fee} ${withdrawal.currency}', Colors.red),
                      SizedBox(height: 8),
                      Divider(height: 1, color: Colors.red.shade200),
                      SizedBox(height: 8),
                      _buildFinancialRow('Net', '${withdrawal.net} ${withdrawal.currency}', Colors.red, isBold: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialRow(String label, String value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showTransactionDetails(ApiWithdrawal withdrawal) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaction Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildDetailItem('Transaction ID', withdrawal.id),
              _buildDetailItem('DateTime', withdrawal.formattedDate),
              _buildDetailItem('Method', withdrawal.method),
              _buildDetailItem('Status', withdrawal.status),
              _buildDetailItem('Gross', '${withdrawal.amount} ${withdrawal.currency}'),
              _buildDetailItem('Fee', '${withdrawal.fee} ${withdrawal.currency}'),
              _buildDetailItem('Net', '${withdrawal.net} ${withdrawal.currency}'),
              if (withdrawal.description.isNotEmpty)
                _buildDetailItem('Description', withdrawal.description),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class ApiWithdrawal {
  final String id;
  final String amount;
  final String currency;
  final String status;
  final String description;
  final String createdAt;
  final String formattedDate;
  final String method;
  final String fee;
  final String net;

  ApiWithdrawal({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.description,
    required this.createdAt,
    required this.formattedDate,
    required this.method,
    required this.fee,
    required this.net,
  });

  factory ApiWithdrawal.fromJson(Map<String, dynamic> json) {
    final createdAt = json['created_at'] ?? '';
    final date = createdAt.isNotEmpty ? DateTime.tryParse(createdAt) : null;
    final formattedDate = date != null 
        ? DateFormat('MMM dd, yyyy HH:mm').format(date)
        : 'N/A';

    // Parse status object
    final statusObj = json['status'] as Map<String, dynamic>?;
    final status = statusObj?['name']?.toString() ?? 'pending';

    // Parse method object
    final methodObj = json['method'] as Map<String, dynamic>?;
    final methodName = methodObj?['payment_method_name']?.toString() ?? 'API Withdrawal';

    // Use the actual values from API response
    final grossAmount = json['gross']?.toString() ?? '0.00';
    final feeAmount = json['fee']?.toString() ?? '0.00';
    final netAmount = json['net']?.toString() ?? '0.00';
    final currencySymbol = json['currency_symbol']?.toString() ?? '';

    return ApiWithdrawal(
      id: json['unique_transaction_id']?.toString() ?? json['id']?.toString() ?? '',
      amount: grossAmount,
      currency: currencySymbol,
      status: status,
      description: json['message']?.toString() ?? '',
      createdAt: createdAt,
      formattedDate: formattedDate,
      method: methodName,
      fee: feeAmount,
      net: netAmount,
    );
  }
} 
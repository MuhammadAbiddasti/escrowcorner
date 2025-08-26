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

class ScreenApiTransactions extends StatefulWidget {
  @override
  _ScreenApiTransactionsState createState() => _ScreenApiTransactionsState();
}

class _ScreenApiTransactionsState extends State<ScreenApiTransactions> {
  // Filter variables
  var selectedApplication = 'all'.obs;
  var selectedType = 'all'.obs;
  var selectedOperator = 'all'.obs;
  var selectedStatus = 'all'.obs;
  var selectedOrdering = 'desc'.obs;
  var phoneNumber = ''.obs;
  var fromDate = ''.obs;
  var toDate = ''.obs;
  
  // Pagination variables
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var hasMoreData = true.obs;
  var transactions = <ApiTransaction>[].obs;
  
  // Data for dropdowns
  var applications = <Application>[].obs;
  var operators = <Operator>[].obs;
  
  final UserProfileController userProfileController = Get.find<UserProfileController>();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
    fetchApplications();
    fetchOperators();
    fetchApiTransactions();
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
      fetchApiTransactions(page: currentPage.value + 1);
    } else {
      hasMoreData.value = false;
    }
  }

  Future<void> fetchApplications() async {
    String? token = await getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/getAllMerchants'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Get All Merchants Response Status: ${response.statusCode}');
      print('Get All Merchants Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          applications.value = (data['data'] as List)
              .map((item) => Application.fromJson(item))
              .toList();
          print('Applications fetched successfully: ${applications.length} items');
        } else {
          print('Failed to fetch applications: ${data['message']}');
        }
      } else {
        print('Failed to fetch applications. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching applications: $e');
    }
  }

  Future<void> fetchOperators() async {
    String? token = await getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/getPaymentMethods'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null && data['data']['payment_method'] != null) {
          operators.value = (data['data']['payment_method'] as List)
              .map((item) => Operator.fromJson(item))
              .toList();
        } else {
          print('No payment methods found in response');
          operators.clear();
        }
      }
    } catch (e) {
      print('Error fetching operators: $e');
    }
  }

  Future<void> fetchApiTransactions({int page = 1}) async {
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

    // Build query parameters
    Map<String, String> queryParams = {
      'page': page.toString(),
      'per_page': '10',
    };

    if (selectedApplication.value != 'all') {
      queryParams['application_id'] = selectedApplication.value;
    }
    if (selectedType.value != 'all') {
      queryParams['ui_type'] = selectedType.value;
    }
    if (selectedOperator.value != 'all') {
      queryParams['operators'] = selectedOperator.value;
    }
    if (selectedStatus.value != 'all') {
      queryParams['ui_status'] = selectedStatus.value;
    }
    if (selectedOrdering.value.isNotEmpty) {
      queryParams['ordering'] = selectedOrdering.value;
    }
    if (phoneNumber.value.isNotEmpty) {
      queryParams['phone_number'] = phoneNumber.value;
    }
    if (fromDate.value.isNotEmpty) {
      queryParams['from_date'] = fromDate.value;
    }
    if (toDate.value.isNotEmpty) {
      queryParams['to_date'] = toDate.value;
    }

    // Try both endpoint formats
    List<String> endpoints = [
      '$baseUrl/api/api-transactions?${Uri(queryParameters: queryParams).query}',
      '$baseUrl/api/apitransactions?${Uri(queryParameters: queryParams).query}',
    ];

    for (String endpoint in endpoints) {
      try {
        print('Trying API call to: $endpoint');
        
        final response = await http.get(
          Uri.parse(endpoint),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        print('API Transactions Response Status: ${response.statusCode}');
        print('API Transactions Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          
          if (data['success'] == true && data['data'] != null) {
            final List<dynamic> transactionsList = data['data'];
            
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
            
            transactions.addAll(transactionsList.map((item) => ApiTransaction.fromJson(item)).toList());
            
            print('API Transactions fetched successfully: ${transactions.length} items');
            isLoading.value = false;
            isLoadingMore.value = false;
            return; // Success, exit the loop
          } else {
            print('Failed to fetch API transactions: ${data['message']}');
          }
        } else {
          print('Failed to fetch API transactions. Status Code: ${response.statusCode}');
          print('Error Response: ${response.body}');
        }
      } catch (e) {
        print('Error occurred while trying endpoint $endpoint: $e');
      }
    }
    
    // If we reach here, all endpoints failed
    Get.snackbar('Error', 'Failed to fetch API transactions from all endpoints',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white);
    isLoading.value = false;
  }

  void applyFilters() {
    currentPage.value = 1;
    hasMoreData.value = true;
    fetchApiTransactions();
  }

  void resetFilters() {
    selectedApplication.value = 'all';
    selectedType.value = 'all';
    selectedOperator.value = 'all';
    selectedStatus.value = 'all';
    selectedOrdering.value = 'desc';
    phoneNumber.value = '';
    fromDate.value = '';
    toDate.value = '';
    applyFilters();
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Application Filter
                  _buildFilterDropdown(
                    'Application',
                    selectedApplication.value,
                    [
                      DropdownItem('all', 'All Applications'),
                      ...applications.map((app) => DropdownItem(app.id, app.name)).toList(),
                    ],
                    (value) {
                      selectedApplication.value = value;
                    },
                  ),
                  SizedBox(height: 8),
                  
                  // Transaction Type Filter
                  _buildFilterDropdown(
                    'Transaction Type',
                    selectedType.value,
                    [
                      DropdownItem('all', 'All Types'),
                      DropdownItem('withdraw', 'Withdrawals'),
                      DropdownItem('deposit', 'Deposits'),
                    ],
                    (value) {
                      selectedType.value = value;
                    },
                  ),
                  SizedBox(height: 8),
                  
                  // Operator Filter
                  _buildFilterDropdown(
                    'Payment Method',
                    selectedOperator.value,
                    [
                      DropdownItem('all', 'All Operators'),
                      ...operators.map((op) => DropdownItem(op.id, op.name)).toList(),
                    ],
                    (value) {
                      selectedOperator.value = value;
                    },
                  ),
                  SizedBox(height: 8),
                  
                  // Status Filter
                  _buildFilterDropdown(
                    'Status',
                    selectedStatus.value,
                    [
                      DropdownItem('all', 'All Status'),
                      DropdownItem('1', 'Completed'),
                      DropdownItem('3', 'Pending'),
                      DropdownItem('2', 'Cancelled'),
                    ],
                    (value) {
                      selectedStatus.value = value;
                    },
                  ),
                  SizedBox(height: 8),
                  
                  // Ordering Filter
                  _buildFilterDropdown(
                    'Sort Order',
                    selectedOrdering.value,
                    [
                      DropdownItem('asc', 'Time Ascending'),
                      DropdownItem('desc', 'Time Descending'),
                    ],
                    (value) {
                      selectedOrdering.value = value;
                    },
                  ),
                  SizedBox(height: 8),
                  
                  // Phone Number Filter
                  _buildTextField(
                    'Phone Number',
                    phoneNumber.value,
                    (value) {
                      phoneNumber.value = value;
                    },
                  ),
                  SizedBox(height: 8),
                  
                  // Date Range Filters
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          'From Date',
                          fromDate.value,
                          (value) {
                            fromDate.value = value;
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _buildDateField(
                          'To Date',
                          toDate.value,
                          (value) {
                            toDate.value = value;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: applyFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff191f28),
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Apply Filters',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: resetFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade600,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Reset All',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
                        Icons.swap_horiz,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No API Transactions Found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No API transactions available for the selected filters',
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
                        final transaction = transactions[index];
                        return _buildTransactionCard(transaction);
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

  Widget _buildFilterDropdown(String label, String value, List<DropdownItem> items, Function(String) onChanged) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          alignLabelWithHint: false,
        ),
        style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
        icon: Icon(Icons.arrow_drop_down, size: 20),
        isExpanded: true,
        items: items.map((item) => DropdownMenuItem(
          value: item.value,
          child: Text(
            item.label, 
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13),
            textAlign: TextAlign.left,
          ),
        )).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }

  Widget _buildTextField(String label, String value, Function(String) onChanged, {String? hintText}) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        initialValue: value,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDateField(String label, String value, Function(String) onChanged) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        initialValue: value,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          suffixIcon: Icon(Icons.calendar_today, size: 18),
        ),
        readOnly: true,
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );
          if (date != null) {
            onChanged(DateFormat('yyyy-MM-dd').format(date));
          }
        },
      ),
    );
  }

  Widget _buildTransactionCard(ApiTransaction transaction) {
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
            _showTransactionDetails(transaction);
          },
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Status and Type
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(transaction.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(transaction.status).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        transaction.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(transaction.status),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTransactionTypeColor(transaction.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        transaction.type.toUpperCase(),
                        style: TextStyle(
                          color: _getTransactionTypeColor(transaction.type),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Transaction Details
                _buildDetailRow('DateTime', transaction.formattedDate, Icons.access_time),
                SizedBox(height: 12),
                _buildDetailRow('Transaction ID', transaction.id, Icons.receipt),
                SizedBox(height: 12),
                _buildDetailRow('Amount', '${transaction.amount} ${transaction.currency}', Icons.attach_money),
                if (transaction.description.isNotEmpty) ...[
                  SizedBox(height: 12),
                  _buildDetailRow('Description', transaction.description, Icons.description),
                ],
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

  void _showTransactionDetails(ApiTransaction transaction) {
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
              _buildDetailItem('Transaction ID', transaction.id),
              _buildDetailItem('Type', transaction.type),
              _buildDetailItem('Status', transaction.status),
              _buildDetailItem('Amount', '${transaction.amount} ${transaction.currency}'),
              _buildDetailItem('DateTime', transaction.formattedDate),
              if (transaction.description.isNotEmpty)
                _buildDetailItem('Description', transaction.description),
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

  Color _getTransactionTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'deposit':
        return Colors.green;
      case 'withdrawal':
        return Colors.red;
      case 'transfer':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class ApiTransaction {
  final String id;
  final String amount;
  final String currency;
  final String status;
  final String type;
  final String description;
  final String createdAt;
  final String formattedDate;

  ApiTransaction({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.type,
    required this.description,
    required this.createdAt,
    required this.formattedDate,
  });

  factory ApiTransaction.fromJson(Map<String, dynamic> json) {
    final createdAt = json['created_at'] ?? '';
    final date = createdAt.isNotEmpty ? DateTime.tryParse(createdAt) : null;
    final formattedDate = date != null 
        ? DateFormat('MMM dd, yyyy HH:mm').format(date)
        : 'N/A';

    return ApiTransaction(
      id: json['unique_transaction_id']?.toString() ?? json['id']?.toString() ?? '',
      amount: json['gross']?.toString() ?? json['amount']?.toString() ?? '0.00',
      currency: json['currency_symbol']?.toString() ?? json['currency']?.toString() ?? '',
      status: json['status']?['name']?.toString() ?? json['status']?.toString() ?? 'pending',
      type: json['type']?.toString() ?? 'transaction',
      description: json['message']?.toString() ?? json['description']?.toString() ?? '',
      createdAt: createdAt,
      formattedDate: formattedDate,
    );
  }
}

class Application {
  final String id;
  final String name;

  Application({required this.id, required this.name});

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class Operator {
  final String id;
  final String name;

  Operator({required this.id, required this.name});

  factory Operator.fromJson(Map<String, dynamic> json) {
    return Operator(
      id: json['id']?.toString() ?? '',
      name: json['payment_method_name']?.toString() ?? '',
    );
  }
}

class DropdownItem {
  final String value;
  final String label;

  DropdownItem(this.value, this.label);
}
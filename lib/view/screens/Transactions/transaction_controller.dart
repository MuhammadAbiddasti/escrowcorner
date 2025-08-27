import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../widgets/custom_token/constant_token.dart';
import '../../../widgets/custom_api_url/constant_url.dart'; // Update the import path as necessary

class TransactionsController extends GetxController {
  var selectedType = 'all_types'.obs; // Use translation key instead of hardcoded string
  var selectedOperator = <OperatorMethod>[].obs; // Stores the list of operators
  var selectedMethod = Rx<OperatorMethod?>(null); // Stores the currently selected operator
  var selectedStatus = 'all_status'.obs; // Use translation key instead of hardcoded string
  var selectedTimeOrder = 'time_ascending'.obs; // Use translation key instead of hardcoded string
  var fromDate = ''.obs;
  var toDate = ''.obs;
  var phoneNumber = ''.obs;

  RxList<Transaction> transactions = <Transaction>[].obs;
  RxList<TransactionStatus> transactionStatuses = <TransactionStatus>[].obs; // Stores the list of transaction statuses
  var isLoading = true.obs;
  var isViewButtonLoading = false.obs;


  void updateSelectedType(String type) {
    selectedType.value = type;
  }


  void updateSelectedStatus(String status) {
    selectedStatus.value = status;
  }

  void updateSelectedTimeOrder(String order) {
    selectedTimeOrder.value = order;
  }

  void updatePhoneNumber(String number) {
    phoneNumber.value = number;
  }

  void updateFromDate(String date) {
    fromDate.value = date;
  }

  void updateToDate(String date) {
    toDate.value = date;
  }

  // Helper method to get the selected status ID
  String getSelectedStatusId() {
    if (selectedStatus.value == 'all_status') {
      return 'all';
    }
    
    // Find the status by name and return its ID
    for (var status in transactionStatuses) {
      if (status.name == selectedStatus.value) {
        return status.id.toString();
      }
    }
    
    // If not found, return the selected status value as fallback
    return selectedStatus.value;
  }


  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
    fetchOperatorMethods();
    fetchTransactionStatuses();
  }

    Future<void> fetchTransactions() async {
    try {
      // Set loading states
      isViewButtonLoading.value = true;
      isLoading.value = true;
      
      String apiUrl = '$baseUrl/api/transactions';

      // Retrieve the token
      String? token = await getToken();
      if (token == null) {
        throw Exception('Token is null');
      }

      // Prepare filters - always send all fields
      Map<String, dynamic> requestBody = {
        'ui_type': selectedType.value == 'all_types' ? 'all' : 
                   selectedType.value == 'withdrawals' ? 'withdraw' : 
                   selectedType.value == 'deposits' ? 'deposit' : selectedType.value,
        'ui_status': selectedStatus.value == 'all_status' ? 'all' : getSelectedStatusId(),
        'ordering': selectedTimeOrder.value == 'time_ascending' ? 'asc' : 'desc',
        'from_date': fromDate.value.isNotEmpty ? fromDate.value : '',
        'to_date': toDate.value.isNotEmpty ? toDate.value : '',
        'phone_number': phoneNumber.value.isNotEmpty ? phoneNumber.value : '',
      };
     
      // Add payment method if selected
      if (selectedMethod.value != null) {
        requestBody['payment_method_id'] = selectedMethod.value!.id.toString();
      }

      // Log request body for debugging
      print("=== FETCH TRANSACTIONS REQUEST ===");
      print("API URL: $apiUrl");
      print("Request Method: POST");
      print("Request Body: $requestBody");
      print("================================");

      // Make the API request using POST method
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );
      
      print("=== FETCH TRANSACTIONS RESPONSE ===");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("================================");

      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('transactions') &&
            jsonResponse['transactions']['data'] != null) {
          // Extract transactions data
          List<dynamic> transactionsList = jsonResponse['transactions']['data'];
          print('Found ${transactionsList.length} transactions');
          
          var fetchedTransactions = transactionsList
            .map((data) {
              print('Processing transaction data: $data');
              print('All keys in transaction data: ${data.keys.toList()}');
              var transaction = Transaction.fromJson(data);
              print('Created transaction with method: "${transaction.method}"');
              print('Transaction methodLabel: "${transaction.methodLabel}"');
              return transaction;
            })
            .toList();

          // Update observable transactions list
          transactions.assignAll(fetchedTransactions.reversed.toList());
          print('Successfully updated transactions list with ${fetchedTransactions.length} items');
        } else {
          throw Exception('Key "transactions.data" not found in response');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      // Show error message to user
      Get.snackbar(
        'Error',
        'Failed to fetch transactions: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // Always reset loading states
      isLoading.value = false;
      isViewButtonLoading.value = false;
      print('Loading states reset - isLoading: ${isLoading.value}, isViewButtonLoading: ${isViewButtonLoading.value}');
    }
  }


  Future<void> fetchOperatorMethods() async {
    String? token =
    await getToken(); // Ensure you have a method to get the Bearer token
    if (token == null) {
      Get.snackbar('Error', 'Token is null');
      isLoading.value = false;
      return;
    }

    final url = Uri.parse('$baseUrl/api/getPaymentMethods');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print("Payment :${response.body}");
      
      // Handle the correct response structure: data.payment_method
      List<dynamic> paymentMethodsList = [];
      if (jsonResponse['data'] != null && jsonResponse['data']['payment_method'] != null) {
        paymentMethodsList = jsonResponse['data']['payment_method'] as List;
      }
      
             if (paymentMethodsList.isNotEmpty) {
         final List<OperatorMethod> fetchedMethods =
         paymentMethodsList.map((item) => OperatorMethod.fromJson(item)).toList();
         selectedOperator.assignAll(fetchedMethods);
         
         // Automatically select the first payment method
         if (fetchedMethods.isNotEmpty) {
           selectedMethod.value = fetchedMethods.first;
         }
       } else {
        print('No payment methods found in response');
        selectedOperator.clear();
      }
    } else {
      throw Exception('Failed to load payment methods');
    }
  }

  Future<void> fetchTransactionStatuses() async {
    String? token = await getToken();
    if (token == null) {
      print('Token is null for fetchTransactionStatuses');
      return;
    }

    final url = Uri.parse('$baseUrl/api/getTransactionStatus');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print("Transaction Status Response: ${response.body}");
        
        if (jsonResponse['success'] == true && jsonResponse['status_data'] != null) {
          List<dynamic> statusList = jsonResponse['status_data'] as List;
          
          if (statusList.isNotEmpty) {
            final List<TransactionStatus> fetchedStatuses =
                statusList.map((item) => TransactionStatus.fromJson(item)).toList();
            transactionStatuses.assignAll(fetchedStatuses);
            print('Loaded ${fetchedStatuses.length} transaction statuses');
          } else {
            print('No transaction statuses found in response');
            transactionStatuses.clear();
          }
        } else {
          print('Invalid response structure for transaction statuses');
          transactionStatuses.clear();
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw Exception('Failed to load transaction statuses');
      }
    } catch (e) {
      print('Error fetching transaction statuses: $e');
      transactionStatuses.clear();
    }
  }

}



class Transaction {
  final String id;
  final String dateTime;
  final String transactionableId;
  final String method;
  final String currency;
  final String gross;
  final String fee;
  final String balance;
  final String net;
  final String description;
  final String phonenumber;
  final String status;
  final String title;

  Transaction({
    required this.id,
    required this.dateTime,
    required this.transactionableId,
    required this.method,
    required this.currency,
    required this.gross,
    required this.fee,
    required this.balance,
    required this.net,
    required this.description,
    required this.phonenumber,
    required this.status,
    required this.title,
  });

  String get methodLabel {
    if (method == 'null' || method.isEmpty) {
      return ''; // Return empty string if method is empty
    }
    return method;
  }
  String get descriptionLabel {
    if (description == 'null') {
      return ''; // Return empty string if method is empty
    }
    // Add other method conditions if needed
    return description;
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    // Debug logging to see what we're receiving
    print('Parsing transaction JSON: $json');
    print('payment_method field: ${json['payment_method']}');
    
    String methodValue = '';
    
    // First priority: Extract from payment_method object
    if (json['payment_method'] != null) {
      print('payment_method is not null, type: ${json['payment_method'].runtimeType}');
      print('payment_method toString: ${json['payment_method'].toString()}');
      
      // Try multiple approaches to extract the payment method name
      try {
        // Approach 1: Try to access as Map directly
        if (json['payment_method'] is Map) {
          var paymentMethod = json['payment_method'] as Map;
          print('payment_method is Map with keys: ${paymentMethod.keys.toList()}');
          
          if (paymentMethod.containsKey('payment_method_name')) {
            methodValue = paymentMethod['payment_method_name']?.toString() ?? '';
            print('Extracted payment_method_name from payment_method Map: "$methodValue"');
          } else if (paymentMethod.containsKey('name')) {
            methodValue = paymentMethod['name']?.toString() ?? '';
            print('Extracted name from payment_method Map: "$methodValue"');
          }
        }
        
        // Approach 2: Try to cast to Map<String, dynamic>
        if (methodValue.isEmpty) {
          try {
            var paymentMethod = json['payment_method'] as Map<String, dynamic>;
            print('Successfully cast to Map<String, dynamic> with keys: ${paymentMethod.keys.toList()}');
            
            if (paymentMethod.containsKey('payment_method_name')) {
              methodValue = paymentMethod['payment_method_name']?.toString() ?? '';
              print('Extracted payment_method_name after casting: "$methodValue"');
            } else if (paymentMethod.containsKey('name')) {
              methodValue = paymentMethod['name']?.toString() ?? '';
              print('Extracted name after casting: "$methodValue"');
            }
          } catch (e) {
            print('Failed to cast to Map<String, dynamic>: $e');
          }
        }
        
        // Approach 3: Try to cast to Map (generic)
        if (methodValue.isEmpty) {
          try {
            var paymentMethod = json['payment_method'] as Map;
            print('Successfully cast to generic Map with keys: ${paymentMethod.keys.toList()}');
            
            if (paymentMethod.containsKey('payment_method_name')) {
              methodValue = paymentMethod['payment_method_name']?.toString() ?? '';
              print('Extracted payment_method_name from generic Map: "$methodValue"');
            } else if (paymentMethod.containsKey('name')) {
              methodValue = paymentMethod['name']?.toString() ?? '';
              print('Extracted name from generic Map: "$methodValue"');
            }
          } catch (e) {
            print('Failed to cast to generic Map: $e');
          }
        }
        
        // Approach 4: If it's a string representation, try to parse it
        if (methodValue.isEmpty && json['payment_method'] is String) {
          String paymentMethodStr = json['payment_method'].toString();
          print('payment_method is String: "$paymentMethodStr"');
          
          // Check if it contains payment_method_name
          if (paymentMethodStr.contains('payment_method_name:')) {
            // Extract the value after payment_method_name:
            int startIndex = paymentMethodStr.indexOf('payment_method_name:') + 'payment_method_name:'.length;
            int endIndex = paymentMethodStr.indexOf(',', startIndex);
            if (endIndex == -1) {
              endIndex = paymentMethodStr.indexOf('}', startIndex);
            }
            if (endIndex != -1) {
              methodValue = paymentMethodStr.substring(startIndex, endIndex).trim();
              print('Extracted payment_method_name from string: "$methodValue"');
            }
          }
        }
        
      } catch (e) {
        print('Error processing payment_method: $e');
      }
    }
    
    // Second priority: Try other possible field names
    if (methodValue.isEmpty && json['method'] != null) {
      methodValue = json['method'].toString();
      print('Using method field: "$methodValue"');
    }
    
    if (methodValue.isEmpty && json['payment_method_name'] != null) {
      methodValue = json['payment_method_name'].toString();
      print('Using payment_method_name field: "$methodValue"');
    }
    
    // If still empty, set a default value
    if (methodValue.isEmpty) {
      methodValue = 'N/A';
      print('No payment method found, using default: "$methodValue"');
    }
    
    print('Final method value: "$methodValue"');
    
         return Transaction(
       id: json['id'].toString(), // Convert to string
       dateTime: json['created_at'] ?? '', // Use the 'created_at' field for dateTime
       transactionableId: json['transactionable_id'] ?? '',
       method: methodValue,
       currency: json['currency'] ?? '',
       title: json['activity_title']?.toString() ?? '',
       gross: json['gross']?.toString() ?? '', // Convert to string
       fee: json['fee']?.toString() ?? '', // Convert to string
       description: json['description']?.toString() ?? '', // Convert to string
              phonenumber: json['phone_number']?.toString() ?? '',
       balance: json['balance']?.toString() ?? '', // Convert to string
       net: json['net']?.toString() ?? '', // Convert to string
       status: json['status']?['name']?.toString() ?? '',
     );
  }
}

class OperatorMethod {
  final int id;
  final String name;
  final String createdAt;
  final String updatedAt;

  OperatorMethod(
      {required this.id,
        required this.name,
        required this.createdAt,
        required this.updatedAt});

  factory OperatorMethod.fromJson(Map<String, dynamic> json) {
    return OperatorMethod(
      id: json['id'],
      name: json['payment_method_name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class TransactionStatus {
  final int id;
  final String name;
  final String? jsonData;
  final String createdAt;
  final String updatedAt;

  TransactionStatus({
    required this.id,
    required this.name,
    this.jsonData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionStatus.fromJson(Map<String, dynamic> json) {
    return TransactionStatus(
      id: json['id'],
      name: json['name'],
      jsonData: json['json_data'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}


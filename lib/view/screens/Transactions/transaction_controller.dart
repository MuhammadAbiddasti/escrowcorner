import 'dart:convert';
import 'package:escrowcorner/view/screens/withdraw/withdrawal_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../widgets/custom_token/constant_token.dart';
import '../../../widgets/custom_api_url/constant_url.dart'; // Update the import path as necessary

class TransactionsController extends GetxController {
  var selectedType = 'All Types'.obs;
  var selectedOperator = <OperatorMethod>[].obs; // Stores the list of operators
  var selectedMethod = Rx<OperatorMethod?>(null); // Stores the currently selected operator
  var selectedStatus = 'All Status'.obs;
  var selectedTimeOrder = 'Time Ascending'.obs;
  var phoneNumber = ''.obs;

  RxList<Transaction> transactions = <Transaction>[].obs;
  var isLoading = true.obs;


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


  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
    fetchOperatorMethods();
  }

  Future<void> fetchTransactions() async {
    try {
      isLoading(true);
      String apiUrl = '$baseUrl/api/transactions';

      // Retrieve the token
      String? token = await getToken();
      if (token == null) {
        throw Exception('Token is null');
      }

      // Prepare filters
      Map<String, String> filters = {
        if (selectedType.value != 'All Types') 'ui_type': selectedType.value,
        if (selectedMethod.value != null) 'operators': selectedMethod.value!.name.toString(),
        if (selectedStatus.value != 'All Status') 'ui_status': selectedStatus.value,
        if (selectedTimeOrder.value != 'Time Ascending') 'ordering': selectedTimeOrder.value == 'Time Ascending' ? 'asc' : 'desc',
        if (phoneNumber.value.isNotEmpty) 'phone_number': phoneNumber.value,
      };

      // Log filters
      print("Filters being sent: $filters");

      // Append filters to the API URL
      final Uri url = Uri.parse(apiUrl).replace(queryParameters: filters);

      // Log the full URL
      print("API URL with filters: $url");

      // Make the API request
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("response body: ${response.body}");

      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Log the response body
        print('Response Body: ${response.body}');

        if (jsonResponse.containsKey('transactions') &&
            jsonResponse['transactions']['data'] != null) {
          // Extract transactions data
          List<dynamic> transactionsList = jsonResponse['transactions']['data'];
          var fetchedTransactions = transactionsList
              .map((data) => Transaction.fromJson(data))
              .toList();

          // Update observable transactions list
          transactions.assignAll(fetchedTransactions.reversed.toList());
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
    } finally {
      isLoading(false);
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
        
        // Automatically select the first payment method if none is selected
        if (selectedOperator.isEmpty == false && selectedOperator.isNotEmpty) {
          // Note: selectedOperator is a list, so we don't need to set a single selected value
          // The first item will be available for selection
        }
      } else {
        print('No payment methods found in response');
        selectedOperator.clear();
      }
    } else {
      throw Exception('Failed to load payment methods');
    }
  }

}



class Transaction {
  final String id;
  final String dateTime;
  final String transactionId;
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
    required this.transactionId,
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
    if (method == 'null') {
      return ''; // Return empty string if method is empty
    }
    // Add other method conditions if needed
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
    return Transaction(
      id: json['id'].toString(), // Convert to string
      dateTime: json['created_at'] ?? '', // Use the 'created_at' field for dateTime
      transactionId: json['entity_id'] ?? '',
      method: json['payment_method'].toString() ?? '', // Convert to string if it's an integer
      currency: json['currency'] ?? '',
      title: json['activity_title'] as String,
      gross: json['gross'].toString(), // Convert to string
      fee: json['fee'].toString(), // Convert to string
      description: json['description'].toString(), // Convert to string
      phonenumber: json['user']['phonenumber'].toString(), // Convert to string
      balance: json['balance'].toString(), // Convert to string
      net: json['net'].toString(), // Convert to string
      status: json['status']?['name'],
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

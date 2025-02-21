import 'dart:convert';
import 'package:dacotech/view/screens/withdraw/withdrawal_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../widgets/custom_token/constant_token.dart';
import '../../../widgets/custom_api_url/constant_url.dart'; // Update the import path as necessary

class MyDepositsController extends GetxController {
  RxList<MyDeposits> mydeposits = <MyDeposits>[].obs;
  var isLoading = true.obs;


  @override
  void onInit() {
    super.onInit();
    fetchMyDeposits();
  }

  Future<void> fetchMyDeposits() async {
    try {
      isLoading(true);
      String apiUrl = '$baseUrl/api/mydeposits'; // Replace with your actual API endpoint

      // Retrieve the token
      String? token = await getToken();
      if (token == null) {
        throw Exception('Token is null');
      }

      print('Retrieved Token: $token');

      // Include the token in the headers
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        print('Response Body: ${response.body}'); // Log the response body

        // Check if 'data' key exists
        if (jsonResponse.containsKey('data')) {
          // Assuming the key 'data' contains the array of transactions
          List<dynamic> transactionsList = jsonResponse['data'];

          // Map each transaction JSON to a Transaction object
          mydeposits.assignAll(transactionsList.map((data) => MyDeposits.fromJson(data)).toList());
        } else {
          throw Exception('Key "data" not found in response');
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

}

class MyDeposits {
  final String id;
  final String dateTime;
  final String transactionId;
  final String method;
  final String currency;
  final String gross;
  final String fee;
  final String net;
  final Status status;

  MyDeposits({
    required this.id,
    required this.dateTime,
    required this.transactionId,
    required this.method,
    required this.currency,
    required this.gross,
    required this.fee,
    required this.net,
    required this.status,
  });

  factory MyDeposits.fromJson(Map<String, dynamic> json) {
    return MyDeposits(
      id: json['id'].toString(), // Convert to string
      dateTime: json['created_at'] ?? '', // Use the 'created_at' field for dateTime
      transactionId: json['unique_transaction_id'] ?? '',
      method: json['method']?['payment_method_name']?.toString() ?? '', // Convert to string if it's an integer
      currency: json['currency_symbol'] ?? '',
      gross: json['gross'].toString(), // Convert to string
      fee: json['fee'].toString(), // Convert to string
      net: json['net'].toString(), // Convert to string
      status: Status.fromJson(json['status']), // Convert to string if it's an integer
    );
  }
}

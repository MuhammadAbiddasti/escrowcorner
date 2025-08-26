import 'dart:convert';
import 'package:escrowcorner/widgets/custom_api_url/constant_url.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../widgets/custom_token/constant_token.dart';

class WithdrawalsController extends GetxController {
  RxList<MyWithdrawal> mywithdrawals = <MyWithdrawal>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyWithdrawals();
  }

  Future<void> fetchMyWithdrawals() async {
    try {
      isLoading(true);
      String apiUrl = '$baseUrl/api/withdrawals'; // Replace with your actual API endpoint

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
          mywithdrawals.assignAll(transactionsList.map((data) => MyWithdrawal.fromJson(data)).toList());
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

class Status {
  final int id;
  final String name;

  Status({
    required this.id,
    required this.name,
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      id: json['id'],
      name: json['name']??'',
    );
  }
}


class MyWithdrawal {
  final String id;
  final String dateTime;
  final String transactionId;
  final String method;
  final String currency;
  final String gross;
  final String fee;
  final String net;
  final Status status;

  MyWithdrawal({
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

  factory MyWithdrawal.fromJson(Map<String, dynamic> json) {
    return MyWithdrawal(
      id: json['id'].toString(), // Handle id as string if it can be null
      dateTime: json['created_at'] ?? '',
      transactionId: json['unique_transaction_id'] ?? '',
      method: json['method']?['payment_method_name'].toString() ?? '',
      currency: json['currency_symbol'] ?? '',
      gross: json['gross'].toString(), // Handle amount as string if it can be null
      fee: json['fee'].toString(), // Handle fee as string if it can be null
      net: json['net'].toString(), // Handle net as string if it can be null
      status: Status.fromJson(json['status']),
    );
  }
}



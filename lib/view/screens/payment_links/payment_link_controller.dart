import 'dart:convert';
import 'package:escrowcorner/view/screens/payment_links/screen_paymentlinks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../widgets/custom_token/constant_token.dart';
import '../../../widgets/custom_api_url/constant_url.dart';

class PaymentLinkController extends GetxController {
  var isLoading = false.obs;
  var paymentLinks = [].obs;
  var paymentMethods = <PaymentMethod>[].obs;
  var selectedMethod = Rxn<PaymentMethod>();
  var paymentLinkId = '';
  var Id = '';
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchPaymentLinks();
    fetchPaymentMethods();
  }

  Future<void> fetchPaymentLinks() async {
    isLoading.value = true;
    String? token =
        await getToken(); // Ensure you have a method to get the Bearer token
    if (token == null) {
      Get.snackbar('Error', 'Token is null');
      isLoading.value = false;
      return;
    }

    final url = Uri.parse('$baseUrl/api/paymentlinks');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Payment Links Data: $data');

        if (data['success'] == true && data['data'] != null) {
          try {
            final rawLinks = data['data'] is List
                ? data['data'] as List<dynamic>
                : []; // Ensure it's a list or fallback to an empty list

            final parsedLinks = rawLinks
                .map((link) {
                  if (link is Map<String, dynamic>) {
                    try {
                      paymentLinkId = link['paymentlink_id'];
                       Id = link['id']!.toString();
                      print('Payment  ID: $Id');
                      print('Paymentlink  ID: $paymentLinkId');
                      return PaymentLink.fromJson(
                          link); // Parse each valid link
                    } catch (e) {
                      print('Error parsing link: $link, Error: $e');
                      return null; // Skip invalid links
                    }
                  } else {
                    print('Invalid link data: $link'); // Log unexpected data
                    return null;
                  }
                })
                .whereType<PaymentLink>()
                .toList(); // Filter out nulls

            paymentLinks.value = parsedLinks;

            print(
                'Payment links fetched successfully: ${paymentLinks.value.length}');
          } catch (e) {
            print('Error while parsing payment links: $e');
            Get.snackbar('Error', 'Failed to parse payment links');
          }
        } else {
          print('Failed to fetch payment links or no data available');
          Get.snackbar(
              'Error', 'Failed to fetch payment links or no data available');
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch payment links');
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPaymentMethods() async {
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
        final List<PaymentMethod> fetchedMethods =
            paymentMethodsList.map((item) => PaymentMethod.fromJson(item)).toList();
        paymentMethods.assignAll(fetchedMethods);
        
        // Automatically select the first payment method if none is selected
        if (selectedMethod.value == null && fetchedMethods.isNotEmpty) {
          selectedMethod.value = fetchedMethods.first;
        }
      } else {
        print('No payment methods found in response');
        paymentMethods.clear();
        selectedMethod.value = null;
      }
    } else {
      throw Exception('Failed to load payment methods');
    }
  }

  Future<void> createPaymentLink(BuildContext context) async {
    String name = nameController.text;
    Object paymentMethodId = selectedMethod.value?.id ?? ''; // Extracting the 'id' directly
    double amount = double.tryParse(amountController.text) ?? 0.0;
    String description = descriptionController.text;

    if(paymentMethodId == ''){
      Get.snackbar(
        'Message',
        'Select a valid Payment method',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if ( amount <= 0) {
      if (amount == 0.0) {
        Get.snackbar(
          'Message',
          'Amount cannot be zero.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return;
    }
    if(name.isEmpty){
      Get.snackbar(
        'Message',
        'Name is required',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if(description.isEmpty){
    Get.snackbar(
    'Message',
    'Description is required',
    backgroundColor: Colors.red,
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM,
    );
    return;
    }

    String? token = await getToken();
    if (token == null) {
      Get.snackbar('Error', 'Token is null');
      isLoading.value = false;
      return;
    }
    isLoading.value = true;

    final url = Uri.parse('$baseUrl/api/create_payment_link');
    final requestBody = {
      'name': name,
      'payment_method_id': paymentMethodId, // Using the extracted 'id' value here
      'amount': amount.toString(),
      'description': description,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print('Response Body: $responseBody'); // Debugging line
        if (responseBody['success']) {
          Get.snackbar('Success', 'Payment link created successfully!',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
          Get.off(ScreenPaymentLinks());
          clearFields();
          await fetchPaymentLinks();
        } else {
          Get.snackbar('Error',
              'Failed to create payment link: ${responseBody['message']}',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
        }
      } else if (response.statusCode == 302) {
        print('Redirect detected');
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          final redirectResponse = await http.get(Uri.parse(redirectUrl));
          print('Redirected Response: ${redirectResponse.body}');
        }
      } else if (response.statusCode == 429) {
        // Handle too many requests
        Get.snackbar(
          'Error',
          'Too many requests. Please try again later.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (response.statusCode == 422) {
        final errorData = jsonDecode(response.body);
        print("error: ${response.body}");

        // Extract the first error message
        String errorMessage = errorData['errors'].values
            .map((errors) => errors.join(', '))
            .join('\n'); // Combine all error messages into a single string

        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Request failed with status: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        print("Response body: ${response.body}");
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePaymentLink(String paymentLinkId, BuildContext context) async {
    String? token = await getToken(); // Fetch the Bearer token

    if (token == null) {
      //Get.snackbar('Error', 'Token is null');
      return;
    }

    final url = Uri.parse('$baseUrl/api/delete_payment_link/$paymentLinkId');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          Get.snackbar('Success', 'Payment link deleted successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,);
          await fetchPaymentLinks();
        } else {
          Get.snackbar('Error', 'Failed to delete payment link',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,);
        }
      } else {
        Get.snackbar('Error', 'Failed to delete payment link',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,);
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e',
      );
      Get.snackbar('Error', 'An error occurred while deleting the payment link',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,);
    }
  }
  void clearFields() {
    selectedMethod.value = null;
    amountController.clear();
    amountController.clear();
    descriptionController.clear();
  }

  @override
  void onClose() {
    clearFields(); // Reset fields when controller is disposed
    super.onClose();
  }
}

class PaymentMethod {
  final int id;
  final String name;
  final String createdAt;
  final String updatedAt;

  PaymentMethod(
      {required this.id,
      required this.name,
      required this.createdAt,
      required this.updatedAt});

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      name: json['payment_method_name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

// Payment Link Model Class
class PaymentLink {
  final int id;
  final String paymentlinkId;
  final int? paymentMethodId;
  final int? userId;
  final int? currencyId;
  final String? paymentlinkDetails;
  final double amount;
  final String name;
  final int? isCrypto;
  final int? paymentStatus;
  final int? linkStatus;
  final String createdAt;
  final String? updatedAt;
  final String link;
  final Currency? currency;
  final String receiver; // Dynamically determined

  PaymentLink({
    required this.id,
    required this.paymentlinkId,
    this.paymentMethodId,
    this.userId,
    this.currencyId,
    this.paymentlinkDetails,
    required this.amount,
    required this.name,
    this.isCrypto,
    this.paymentStatus,
    this.linkStatus,
    required this.createdAt,
    this.updatedAt,
    required this.link,
    this.currency,
    required this.receiver,
  });

  factory PaymentLink.fromJson(Map<String, dynamic> json) {
    // Determine the receiver based on currency_id
    String receiver = (json['payment_method_id'] == 1)
        ? 'MTN Mobile Money'
        : (json['payment_method_id'] == 2)
        ? 'Orange Money'
        : 'Unknown'; // Default to 'Unknown' if paymentMethodId is not 1 or 2

    return PaymentLink(
      id: int.parse(json['id'].toString()),
      paymentlinkId: json['paymentlink_id'] ?? '', // Default to empty string if null
      paymentMethodId: int.tryParse(json['payment_method_id']?.toString() ?? ''),
      userId: int.tryParse(json['user_id']?.toString() ?? ''),
      currencyId: int.tryParse(json['currency_id']?.toString() ?? ''),
      paymentlinkDetails: json['paymentlink_details'] ?? '', // Default to empty string
      amount: double.tryParse(json['amount']?.toString() ?? '0.0') ?? 0.0, // Default to 0.0
      name: json['name'] ?? '', // Default to empty string
      isCrypto: int.tryParse(json['is_crypto']?.toString() ?? ''),
      paymentStatus: int.tryParse(json['payment_status']?.toString() ?? ''),
      linkStatus: int.tryParse(json['link_status']?.toString() ?? ''),
      createdAt: json['created_at'] ?? '', // Default to empty string
      updatedAt: json['updated_at'], // Can be nullable
      link: json['paymentlink_id'] ?? '', // Default to empty string
      currency: json['currency'] != null ? Currency.fromJson(json['currency']) : null,
      receiver: receiver,
    );
  }
}

class Currency {
  final int id;
  final String name;
  final String symbol;

  Currency({
    required this.id,
    required this.name,
    required this.symbol,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
    );
  }
}

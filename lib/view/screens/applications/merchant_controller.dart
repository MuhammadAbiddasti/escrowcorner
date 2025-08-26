
import 'package:escrowcorner/view/screens/applications/screen_merchant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import '../../../widgets/custom_token/constant_token.dart';
import '../../../widgets/custom_api_url/constant_url.dart';

class MerchantController extends GetxController {
  RxList<Merchant> merchants = <Merchant>[].obs;
  RxList<MerchantTransaction> merchantTransactions = <MerchantTransaction>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var merchantData = {}.obs;
  var avatar = Rx<File?>(null);
  var avatarUrl = ''.obs;
  var currencies = <MCurrency>[].obs;
  var selectedCurrency = Rx<MCurrency?>(null); // Single selected Currency or Method
  var paymentMethods = <PaymentMethod>[].obs;
  var selectedPaymentMethod = Rx<PaymentMethod?>(null); // Selected payment method
  
  // Pagination variables
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasMoreData = true.obs;
  // Single selected Currency or Method
  // Form fields
  final merchantName = " ".obs;
  final merchantCurrency = " ".obs;


  final merchantSuccessLink =" ".obs;
  final merchantFailLink = " ".obs;
  final merchantDescription =" ".obs;
  //var merchantLogo = ''.obs; // Logo file path
  late TextEditingController webhookUrlController = TextEditingController();

  @override
  void onInit() {
    fetchMerchants();
    fetchSendmoneyCurrencies();
    fetchPaymentMethods();
    webhookUrlController = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    webhookUrlController.dispose();
    super.onClose();
  }

  void pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      avatar.value = File(pickedFile.path);
    } else {
      print("No Logo file");
      Get.snackbar('Error', 'No image selected.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,);
    }
  }

  Future<void> fetchSendmoneyCurrencies() async {
    isLoading.value = true;  // Start loading
    String? token = await getToken(); // Ensure you have a method to get the Bearer token
    if (token == null) {
      //Get.snackbar('Error', 'Token is null');
      isLoading.value = false;  // Stop loading
      return;
    }

    final url = Uri.parse('$baseUrl/api/sendMoneyCurrencies');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        print("Currency :${response.body}");
        final List<MCurrency> fetchedCurrencies = data.map((item) => MCurrency.fromJson(item)).toList();
        // Clear current selection if needed
        currencies.clear();
        currencies.addAll(fetchedCurrencies);
      } else {
        throw Exception('Failed to load Send Money Currencies');
      }
    } catch (e) {
      print('Error: $e');
      //Get.snackbar('Message', 'Failed to fetch currencies');
    } finally {
      isLoading.value = false;  // Stop loading
    }
  }

  Future<void> fetchPaymentMethods() async {
    String? token = await getToken();
    if (token == null) {
      print('Error: Token is null');
      return;
    }

    try {
      final url = Uri.parse('$baseUrl/api/getPaymentMethods');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print("Payment Methods: ${response.body}");
        
        // Handle the correct response structure: data.payment_method
        List<dynamic> paymentMethodsList = [];
        if (jsonResponse['data'] != null && jsonResponse['data']['payment_method'] != null) {
          paymentMethodsList = jsonResponse['data']['payment_method'] as List;
        }
        
        if (paymentMethodsList.isNotEmpty) {
          final List<PaymentMethod> fetchedMethods = paymentMethodsList.map((item) => PaymentMethod.fromJson(item)).toList();
          paymentMethods.clear();
          paymentMethods.addAll(fetchedMethods);
          
          // Automatically select the first payment method if none is selected
          if (selectedPaymentMethod.value == null && fetchedMethods.isNotEmpty) {
            selectedPaymentMethod.value = fetchedMethods.first;
          }
        } else {
          print('No payment methods found in response');
          paymentMethods.clear();
          selectedPaymentMethod.value = null;
        }
      } else {
        throw Exception('Failed to load payment methods');
      }
    } catch (e) {
      print('Error fetching payment methods: $e');
    }
  }

  Future<void> createMerchant(BuildContext context) async {
    print('createMerchant method called');
    
    // Validate required fields
    if (merchantName.value.isEmpty) {
              Get.snackbar('Error', 'Sub account name is required',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    

    
    if (merchantDescription.value.isEmpty) {
              Get.snackbar('Error', 'Sub account description is required',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    if (avatar.value == null) {
              Get.snackbar('Error', 'Sub account logo is required',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
  
    
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    isLoading(true);

    while (retryCount < maxRetries) {
      try {
        String? token = await getToken();
        if (token == null) {
          throw Exception('Token is null');
        }
        
        var request = http.MultipartRequest(
            'POST', Uri.parse('$baseUrl/api/add_application'))
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['merchant_name'] = merchantName.value

          ..fields['merchant_description'] = merchantDescription.value;
        request.files.add(await http.MultipartFile.fromPath('logo', avatar.value!.path));
        var response = await request.send();
        var responseData = await response.stream.bytesToString();
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          var jsonResponse = jsonDecode(responseData);
          if (jsonResponse['success'] == true) {
            Get.snackbar('Success', jsonResponse['message'],
                backgroundColor: Colors.green,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM);
            clearFormFields();
            Get.off(ScreenMerchant());
            await fetchMerchants();
            break; // Break the retry loop if successful
          } else {
            // Handle case where success is false but status code is 200/201
            String errorMessage = jsonResponse['message'] ?? 'Failed to create Sub Account';
            print('Success false, error message: $errorMessage');
            Get.snackbar('Error', errorMessage,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM);
            break; // Don't retry for this type of error
          }
        } else if (response.statusCode == 429) {
          retryCount++;
          if (retryCount >= maxRetries) {
            throw Exception('Rate limit exceeded. Please try again later.');
          }
          await Future.delayed(retryDelay);
        } else {
          // Handle other error status codes (like 400)
          try {
            var errorResponse = jsonDecode(responseData);
            String errorMessage = errorResponse['message'] ?? 'Failed to create Sub Account';
            print('Error message from backend: $errorMessage');
            Get.snackbar('Error', errorMessage,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM);
            break; // Don't retry for client errors (4xx)
          } catch (jsonError) {
            // If JSON parsing fails, use generic error message
            print('JSON parsing error: $jsonError');
            Get.snackbar('Error', 'Failed to create Sub Account. Status: ${response.statusCode}',
                backgroundColor: Colors.red,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM);
            break; // Don't retry for parsing errors
          }
        }
      } catch (e) {
        if (retryCount >= maxRetries) {
          Get.snackbar('Error', e.toString(),
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
          break;
        }
        await Future.delayed(retryDelay);
        retryCount++;
      } finally {
        isLoading(false);
      }
    }
  }

  Future<void> updateMerchant(String merchantId) async {
    isLoading(true);
    try {
      String? token = await getToken();
      if (token == null) {
        return;
      }
      print('Retrieved Token: $token');

      // Ensure required fields are not empty
      if (merchantName.value.isEmpty) {
        Get.snackbar('Message', 'name is required',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }


      if (merchantDescription.value.isEmpty) {
        Get.snackbar('Message', 'description is required',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // Create the request URL with the merchant ID
      final url = Uri.parse('$baseUrl/api/edit-merchant/$merchantId');

      // Build query parameters
      final queryParams = {
        'merchant_name': merchantName.value,

        'merchant_description': merchantDescription.value,
      };

      // Append avatar (optional, if needed by API)
      if (avatar.value != null) {
        queryParams['logo'] = avatar.value!.path; // Assuming the API accepts file paths as query params.
      }

      // Send GET request with headers
      final response = await http.get(
        url.replace(queryParameters: queryParams),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == "success") {
          Get.snackbar('Success', jsonResponse['message'],
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
          // Clear form fields
          clearFormFields();
          Get.off(ScreenMerchant());
          await fetchMerchants();
        } else {
          Get.snackbar('Error', jsonResponse['message'],
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
        }
      } else if (response.statusCode == 404) {
        Get.snackbar('Error', 'API not found (404). Please check the URL.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', 'Failed to update Sub Account. Status: ${response.statusCode}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  void clearFormFields() {
    merchantName.value = '';

    selectedCurrency.value = null;
    merchantSuccessLink.value = '';
    merchantFailLink.value = '';
    merchantDescription.value = '';
    avatar.value = null;
    avatarUrl.value = '';
    webhookUrlController.clear();
  }

// Method for Fetch Merchants History
  Future<void> fetchMerchants() async {
    try {
      isLoading(true);

      String? token = await getToken();
      if (token == null) {
        throw Exception('Token is null');
      }

      // Clear merchants list before fetching new data
      merchants.clear();
      merchants.refresh();

      var response = await http.get(
        Uri.parse('$baseUrl/api/getAllMerchants'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print('API Response: ${response.body}');
      print('Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print('Parsed JSON Response: $jsonResponse');
        print('Success field: ${jsonResponse['success']}');
        print('Data field: ${jsonResponse['data']}');
        
        // Check for different possible response structures
        bool isSuccess = jsonResponse['success'] == true || jsonResponse['status'] == 'success';
        List<dynamic> data = jsonResponse['data'] ?? jsonResponse['merchants'] ?? [];
        
        print('Is Success: $isSuccess');
        print('Data list length: ${data.length}');
        print('Data list: $data');
        
        if (isSuccess && data.isNotEmpty) {
          List<Merchant> fetchedMerchants = data.map((item) => Merchant.fromJson(item)).toList();
          print('Fetched merchants count: ${fetchedMerchants.length}');
          
          merchants.assignAll(fetchedMerchants);
          merchants.refresh(); // Ensure UI updates
          print('Updated Merchants List: ${merchants.map((e) => e.name).toList()}');
          print('Merchants with balances: ${merchants.map((e) => '${e.name}: Balance=${e.balance}, MTN=${e.mtnBalance}, Orange=${e.orangeBalance}').toList()}');
        } else if (isSuccess && data.isEmpty) {
          print('Success but no data found');
          merchants.clear();
          merchants.refresh();
        } else {
          print('Success is false, message: ${jsonResponse['message']}');
          throw Exception(jsonResponse['message'] ?? 'Failed to fetch merchants');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchMerchantIntegration(String merchantId) async {
    isLoading(true);
    try {
      String? token = await getToken();
      if (token == null) {
        print('Token is null');
        isLoading.value = false;
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/merchantIntegration?merchant_id=$merchantId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['success']) {
            merchantData.value = data['data'];

          } else {
            throw Exception('Failed to load merchant data: ${data['message']}');
          }
        } catch (e) {
          throw Exception('JSON decode error:  ${e.toString()}');
        }
      } else {
        throw Exception('Failed to load data with status code: ${response.statusCode}. Response: ${response.body}');
      }
    } catch (e) {
      print('Error details: ${e.toString()}');
      throw Exception('Error occurred: $e');
    } finally {
      isLoading(false);
    }
  }
  Future<String?> regeneratePublicKey(BuildContext context, String userId) async {
    // Construct the URL with the userId
    final url = Uri.parse('$baseUrl/api/regenrate-key/public/$userId');
    // Log the constructed URL

    String? token = await getToken();
    if (token == null) {
      print('Error: Token is null');
      //throw Exception('Token is null');
    }
    print('Token: $token');

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    try {
      // Making the POST request
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        // Parse and log the response data
        final responseData = json.decode(response.body);
        //print('Response Data: $responseData');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text("Public key regenerated successfully!",),
            duration: Duration(seconds: 2),
          ),
        );
        //Get.snackbar('Message', "key regenerated successfully.");
        // Extract and return the public key
        return responseData['public_key']; // Adjust if API response structure differs
      } else {
        print('Failed to regenerate key. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error occurred during API call: $e');
      return null;
    }
  }

  Future<String?> regenerateSecretKey(BuildContext context, String userId) async {
    // Construct the URL with the userId
    final url = Uri.parse('$baseUrl/api/regenrate-key/secret/$userId');
    // Log the constructed URL

    String? token = await getToken();
    if (token == null) {
      print('Error: Token is null');
      //throw Exception('Token is null');
    }

    // Log the token for debugging (optional, ensure sensitive data is not exposed in production)
    print('Token: $token');

    // Headers for the request
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    try {
      // Making the POST request
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        // Parse and log the response data
        final responseData = json.decode(response.body);
        print('Response Data: $responseData');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text("Secret key regenerated successfully!"),
            duration: Duration(seconds: 2),
          ),
        );
        return responseData['secret_key']; // Adjust if API response structure differs

      } else {
        print('Failed to regenerate key. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error occurred during API call: $e');
      return null;
    }
  }
  Future<void> updateWebhookUrl(BuildContext context, String merchantId, String newUrl) async {

    // Validate webhook URL
    if (newUrl.isEmpty) {
      Get.snackbar('Error', 'Webhook URL cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,);
      print('Error: Webhook URL is empty');
      return;
    }
    if (!Uri.parse(newUrl).isAbsolute) {
      Get.snackbar('Error', 'Invalid Webhook URL format',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,);
      print('Error: Invalid Webhook URL format');
      return;
    }
    String? token = await getToken();
    if (token == null) {
      print('Error: Token is null');
      // Get.snackbar('Error', 'Token is null');
      // throw Exception('Token is null');
    }
    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse('$baseUrl/api/update-webhook-url'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'merchant_id': merchantId,
          'webhook_url': newUrl,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Check for "status" field instead of "success"
        if (responseData['status'] == 'success') {
          Get.snackbar('Success', responseData['message'] ?? 'Webhook URL updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,);
          print('Webhook URL updated successfully');
        } else {
          Get.snackbar('Error', 'Failed to update webhook URL: ${responseData['message']}',
          snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,);
          print('Error: ${responseData['message']}');
        }
      } else {
        Get.snackbar('Error', 'Failed to update webhook URL: ${response.body}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,);
        print('Failed to update webhook URL. Status Code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Exception caught during webhook update: $e');
      Get.snackbar('Error', 'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,);
    } finally {
      isLoading.value = false;
      print('Finished updateWebhookUrl method execution');
    }
  }

  // Method for Transfer In (Deposit Request)
  Future<Map<String, dynamic>> submitDepositRequest(String merchantId, String paymentMethodId, String amount) async {
    try {
      String? token = await getToken();
      if (token == null) {
        throw Exception('Token is null');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/merchant/depositRequest/$merchantId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'method_id': paymentMethodId,
          'amount': amount,
        }),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check if the API response has success: true
        if (responseData['success'] == true) {
          return {
            'success': true,
            'data': responseData,
            'message': responseData['message'] ?? 'Transfer-In from dashboard wallet to application wallet done successfully!'
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to submit deposit request',
            'statusCode': response.statusCode
          };
        }
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to submit deposit request',
          'statusCode': response.statusCode
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
        'error': e.toString()
      };
    }
  }

  // Method to fetch merchant transactions
  Future<void> fetchMerchantTransactions(String merchantId, {String filter = 'today', bool loadMore = false}) async {
    print('=== STARTING MERCHANT TRANSACTION FETCH ===');
    print('Merchant ID: $merchantId');
    print('Filter: $filter');
    print('Load More: $loadMore');
    
    try {
      if (loadMore) {
        isLoadingMore(true);
      } else {
        isLoading(true);
        // Reset pagination for new filter
        currentPage.value = 1;
        hasMoreData.value = true;
      }
      
      String? token = await getToken();
      if (token == null) {
        throw Exception('Token is null');
      }
      
      print('Token obtained successfully');

      // Use the correct endpoint for merchant view detail
      final requestBody = {
        'merchant_id': merchantId,
        'filter': filter,
        'page': currentPage.value,
        'per_page': 2, // Request only 2 records per page
      };
      
      print('Request URL: $baseUrl/api/merchant/view_detail');
      print('Request Body: $requestBody');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/merchant/view_detail'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Merchant View Detail API Response: ${response.body}');
      print('Merchant View Detail API Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        print('Parsed Response Data: $responseData');
        print('Response Data Keys: ${responseData.keys.toList()}');
        
        // Check if success field exists and its value
        final bool isSuccess = responseData['success'] == true || responseData['status'] == 'success';
        print('Is Success: $isSuccess');
        
        if (isSuccess) {
          // Try to get transactions data from different possible structures
          List<dynamic> transactionList = [];
          
          // Try transactions.data structure first
          if (responseData['transactions'] != null && responseData['transactions']['data'] != null) {
            transactionList = responseData['transactions']['data'];
            print('Found transactions.data structure with ${transactionList.length} items');
          }
          // Try direct data structure
          else if (responseData['data'] != null && responseData['data'] is List) {
            transactionList = responseData['data'];
            print('Found direct data structure with ${transactionList.length} items');
          }
          // Try transactions as direct array
          else if (responseData['transactions'] != null && responseData['transactions'] is List) {
            transactionList = responseData['transactions'];
            print('Found transactions as array with ${transactionList.length} items');
          }
          
          print('Final transaction list length: ${transactionList.length}');
          
          if (transactionList.isNotEmpty) {
            final List<MerchantTransaction> transactions = [];
            
            for (int i = 0; i < transactionList.length; i++) {
              try {
                print('Processing transaction $i: ${transactionList[i]}');
                final transaction = MerchantTransaction.fromJson(transactionList[i]);
                transactions.add(transaction);
                print('Successfully added transaction $i: ${transaction.transactionId}');
              } catch (e) {
                print('Error processing transaction $i: $e');
                print('Problematic data: ${transactionList[i]}');
              }
            }
            
            print('Successfully parsed ${transactions.length} transactions');
            
            if (loadMore) {
              merchantTransactions.addAll(transactions);
            } else {
              merchantTransactions.assignAll(transactions);
            }
            
                         // Update pagination info
             if (responseData['transactions'] != null && responseData['transactions'] is Map) {
               currentPage.value = responseData['transactions']['current_page'] ?? 1;
               totalPages.value = responseData['transactions']['last_page'] ?? 1;
               hasMoreData.value = currentPage.value < totalPages.value;
               
               print('Pagination Info:');
               print('  Current Page: ${currentPage.value}');
               print('  Total Pages: ${totalPages.value}');
               print('  Has More Data: ${hasMoreData.value}');
               print('  Total Records: ${responseData['transactions']['total'] ?? 'unknown'}');
             }
            
            print('Final merchant transactions count: ${merchantTransactions.length}');
            print('Current page: ${currentPage.value}, Total pages: ${totalPages.value}');
          } else {
            print('No transactions found in response');
            if (!loadMore) {
              merchantTransactions.clear();
            }
          }
        } else {
          print('API returned success: false');
          print('Message: ${responseData['message']}');
          if (!loadMore) {
            merchantTransactions.clear();
          }
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Error response: ${response.body}');
        if (!loadMore) {
          merchantTransactions.clear();
        }
      }
    } catch (e) {
      print('Exception occurred: $e');
      if (!loadMore) {
        merchantTransactions.clear();
      }
    } finally {
      if (loadMore) {
        isLoadingMore(false);
      } else {
        isLoading(false);
      }
      print('=== MERCHANT TRANSACTION FETCH COMPLETED ===');
    }
  }

  // Method to load more transactions
  Future<void> loadMoreTransactions(String merchantId, String filter) async {
    print('=== LOADING MORE TRANSACTIONS ===');
    print('Current page: ${currentPage.value}');
    print('Has more data: ${hasMoreData.value}');
    print('Is loading more: ${isLoadingMore.value}');
    
    if (hasMoreData.value && !isLoadingMore.value) {
      print('Starting to load more transactions...');
      currentPage.value++;
      await fetchMerchantTransactions(merchantId, filter: filter, loadMore: true);
    } else {
      print('Cannot load more: hasMoreData=${hasMoreData.value}, isLoadingMore=${isLoadingMore.value}');
    }
  }

  // Method for Transfer Out (Withdraw Request)
  Future<Map<String, dynamic>> submitTransferOutRequest(String merchantId, String paymentMethodId, String amount) async {
    try {
      String? token = await getToken();
      if (token == null) {
        throw Exception('Token is null');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/merchant/withdrawRequest'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'application_id': merchantId,
          'method_id': paymentMethodId,
          'amount': amount,
        }),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check if the API response has success: true
        if (responseData['success'] == true) {
          return {
            'success': true,
            'data': responseData,
            'message': responseData['message'] ?? 'Transfer-Out from application wallet to dashboard wallet done successfully!'
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to submit withdraw request',
            'statusCode': response.statusCode
          };
        }
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to submit withdraw request',
          'statusCode': response.statusCode
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
        'error': e.toString()
      };
    }
  }
}

class Merchant{
  final String id;
  final String logo;
  final String webhookUrl;
  final String name;
  final String description;
  final String siteUrl;
  final String? balance;
  final String? mtnBalance;
  final String? orangeBalance;
 // final String merchant_id;

//<editor-fold desc="Data Methods">
   Merchant({
    required this.id,
    required this.logo,
    required this.webhookUrl,
    required this.name,
    required this.description,
    required this.siteUrl,
    this.balance,
    this.mtnBalance,
    this.orangeBalance,
  //required this.merchant_id
  });


  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['id']?.toString() ?? '',  // Handle possible null values
      logo: json['logo']?.toString() ?? '',  // Handle possible null values
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      webhookUrl: json['webhook_url']?.toString() ?? '',
      siteUrl: json['site_url']?.toString() ?? '',  // Handle possible null values
      balance: json['balance']?.toString() ?? '0.00',
      mtnBalance: json['mtn_balance']?.toString() ?? '0.00',
      orangeBalance: json['orange_balance']?.toString() ?? '0.00',
      //merchant_id: json['id'] ?? '',
    );
  }

//</editor-fold>
}

class MCurrency {
  final int id;
  final String name;
  final String createdAt;
  final String updatedAt;

  MCurrency({required this.id, required this.name,
    required this.createdAt,required this.updatedAt});

  factory MCurrency.fromJson(Map<String, dynamic> json) {
    return MCurrency(
      id: json['id'],
      name: json['name'],
      createdAt:  json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class PaymentMethod {
  final int id;
  final String name;
  final String createdAt;
  final String updatedAt;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      name: json['payment_method_name'] ?? json['name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentMethod && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class MerchantTransaction {
  final String transactionId;
  final String dateTime;
  final String method;
  final String description;
  final String status;
  final String activityTitle;
  final String gross;
  final String fee;
  final String net;
  final String balance;

  MerchantTransaction({
    required this.transactionId,
    required this.dateTime,
    required this.method,
    required this.description,
    required this.status,
    required this.activityTitle,
    required this.gross,
    required this.fee,
    required this.net,
    required this.balance,
  });

  factory MerchantTransaction.fromJson(Map<String, dynamic> json) {
    print('Creating MerchantTransaction from JSON: $json');
    
    try {
      // Extract nested objects safely - using Laravel Eloquent relationship names
      final paymentMethod = json['payment_method']; // Laravel relationship name
      final status = json['status']; // Laravel relationship name
      final currency = json['currency'];
      
      print('PaymentMethod object: $paymentMethod');
      print('Status object: $status');
      print('Currency object: $currency');
      
      // Get method name from nested PaymentMethod object
      String methodName = 'N/A';
      if (paymentMethod != null && paymentMethod is Map) {
        // Try different possible field names for payment method
        methodName = paymentMethod['payment_method_name']?.toString() ?? 
                    paymentMethod['name']?.toString() ?? 
                    paymentMethod['method_name']?.toString() ?? 'N/A';
        print('Extracted method name: $methodName');
      }
      
      // Get status name from nested status object
      String statusName = 'N/A';
      if (status != null && status is Map) {
        // Try different possible field names for status
        statusName = status['name']?.toString() ?? 
                    status['status_name']?.toString() ?? 
                    status['title']?.toString() ?? 'N/A';
        print('Extracted status name: $statusName');
      }
      
      // Get currency code from json['currency'] field
      String currencyCode = json['currency']?.toString() ?? '';
      print('Currency from json[\'currency\']: $currencyCode');
      
      // Format amounts with currency code
      String formatAmount(dynamic amount) {
        if (amount == null) return '0.00 $currencyCode';
        final amountStr = amount.toString();
        if (currencyCode.isNotEmpty) {
          return '$amountStr $currencyCode';
        } else {
          return amountStr;
        }
      }
      
      final formattedGross = formatAmount(json['gross'] ?? json['gross_amount']);
      final formattedFee = formatAmount(json['fee'] ?? json['fee_amount']);
      final formattedNet = formatAmount(json['net'] ?? json['net_amount'] ?? json['amount']);
      final formattedBalance = formatAmount(json['balance'] ?? json['balance_amount']);
      
      final transaction = MerchantTransaction(
        transactionId: json['transactionable_id']?.toString() ?? 
                      json['transaction_id']?.toString() ?? 
                      json['id']?.toString() ?? 'N/A',
        dateTime: json['date_time']?.toString() ?? 
                  json['created_at']?.toString() ?? 
                  json['datetime']?.toString() ?? 
                  json['date']?.toString() ?? 'N/A',
        method: methodName,
        description: json['description']?.toString() ?? 
                    json['desc']?.toString() ?? 'N/A',
        status: statusName,
        activityTitle: json['activity_title']?.toString() ?? 
                       json['title']?.toString() ?? 
                       json['activityTitle']?.toString() ?? 'Transaction',
        gross: formattedGross,
        fee: formattedFee,
        net: formattedNet,
        balance: formattedBalance,
      );
      
      print('Formatted amounts:');
      print('  Gross: $formattedGross');
      print('  Fee: $formattedFee');
      print('  Net: $formattedNet');
      print('  Balance: $formattedBalance');
      
      print('Successfully created transaction: ${transaction.transactionId} - ${transaction.activityTitle}');
      print('Method: $methodName, Status: $statusName, Currency: $currencyCode');
      return transaction;
    } catch (e) {
      print('Error creating transaction from JSON: $e');
      print('JSON data: $json');
      
      // Return a default transaction if parsing fails
      return MerchantTransaction(
        transactionId: 'Error',
        dateTime: 'N/A',
        method: 'N/A',
        description: 'Error parsing transaction data',
        status: 'Error',
        activityTitle: 'Transaction Error',
        gross: '0.00',
        fee: '0.00',
        net: '0.00',
        balance: '0.00',
      );
    }
  }
}

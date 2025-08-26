import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:escrowcorner/view/screens/escrow_system/cancelled_escrow/get_cancelled_escrow.dart';
import 'package:escrowcorner/view/screens/escrow_system/request_escrow/request_escrow.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../../widgets/custom_api_url/constant_url.dart';
import '../../../../widgets/custom_token/constant_token.dart';
import '../get_requested_escrow/get_requested_escrow.dart';
import '../get_requested_escrow/requested_escrow_controller.dart';
import '../rejected_escrow/get_rejected_escrow.dart';
import '../../../controller/language_controller.dart';

class RequestEscrowController extends GetxController {
  final requestEscrows = <RequestEscrow>[].obs;
  final isLoading = false.obs;
  final escrowDetail = <DetailsRequestEscrow>[].obs;
  final escrowInfoDetail = <DetailsRequestEscrow>[].obs; // Separate observable for information screen
  final isCancelling = false.obs; // Loading state for cancel operation
  final cancelLoadingStates = <int, bool>{}.obs; // Individual loading states for each escrow
  final RequestedEscrowController controller = Get.put(RequestedEscrowController());
  //List<RequestEscrow> get escrows => requestEscrows;
  Future<void> fetchRequestEscrows() async {
    // Prevent multiple simultaneous calls
    if (isLoading.value) return;
    
    isLoading.value = true;
    String? token = await getToken();
    
    try {
      print("Fetching request escrows...");
      final response = await http.get(
        Uri.parse("$baseUrl/api/request_escrow"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          print('Request escrows API call timed out after 30 seconds');
          throw TimeoutException('API call timed out', Duration(seconds: 30));
        },
      );
      
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'] ?? [];
          requestEscrows.assignAll(
              data.map((e) => RequestEscrow.fromJson(e)).toList());
          print('Successfully loaded ${requestEscrows.length} request escrows');
        } else {
          print('API returned success: false, message: ${responseData['message']}');
          // Clear existing data if API fails
          requestEscrows.clear();
        }
      } else {
        print('HTTP Error: ${response.statusCode}, body: ${response.body}');
        // Clear existing data on HTTP error
        requestEscrows.clear();
      }
    } catch (e) {
      print('Exception occurred while fetching request escrows: $e');
      // Clear existing data on exception
      requestEscrows.clear();
    } finally {
      isLoading.value = false;
      print('Request escrows loading completed. Total items: ${requestEscrows.length}');
    }
  }
  Future<void> fetchRequestEscrowDetail(int id) async {
    print("fetchRequestEscrowDetail called with ID: $id");
    print("Setting isLoading to true");
    isLoading.value = true;
    print("isLoading is now: ${isLoading.value}");
    
    String? token = await getToken();
    print("Token: ${token != null ? 'Found' : 'Not found'}");
    
    try {
      final url = Uri.parse("$baseUrl/api/requestedEscrowDetail/$id");
      print("Calling API: $url");
      print("Base URL: $baseUrl");
      print("Full URL: $url");
      print("About to make HTTP request...");
      
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          print('API call timed out after 30 seconds');
          throw TimeoutException('API call timed out', Duration(seconds: 30));
        },
      );
      print("=== API Response received ===");
      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print("Parsed response data: $responseData");
        
        // Check for both 'success' boolean and 'status' string
        if (responseData['success'] == true || responseData['status'] == 'success') {
          final data = responseData['data'] ?? responseData; // Use data if available, otherwise use the whole response
          print('API Response data: $data');
          print('Response data type: ${data.runtimeType}');
          print('Response data keys: ${data is Map ? data.keys.toList() : 'Not a Map'}');
          
          // Pass the entire 'data' to the fromJson constructor
          try {
            final detailsRequestEscrow = DetailsRequestEscrow.fromJson(data);
            print('Parsed DetailsRequestEscrow: $detailsRequestEscrow');
            
            escrowDetail.assignAll([detailsRequestEscrow]);
            print('Updated escrowDetail length: ${escrowDetail.length}');
          } catch (parseError) {
            print('Error parsing DetailsRequestEscrow: $parseError');
            print('Attempting to parse with raw response data...');
            
            // Try parsing with the raw response data
            try {
              final detailsRequestEscrow = DetailsRequestEscrow.fromJson(responseData);
              print('Parsed DetailsRequestEscrow with raw data: $detailsRequestEscrow');
              
              escrowDetail.assignAll([detailsRequestEscrow]);
              print('Updated escrowDetail length: ${escrowDetail.length}');
            } catch (rawParseError) {
              print('Error parsing with raw data: $rawParseError');
            }
          }
        } else {
          print('API returned success: false, message: ${responseData['message']}');
          print('Full response data: $responseData');
        }
      } else {
        print('HTTP Error: ${response.statusCode}, body: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    } finally {
      print('Finally block reached');
      print('Setting isLoading to false');
      isLoading.value = false;
      print('isLoading is now: ${isLoading.value}');
      print('Loading completed, escrowDetail length: ${escrowDetail.length}');
    }
  }

    // Method to fetch escrow details for information screen using GET with id in URL
  Future<void> fetchRequestEscrowDetailForInfo(int id) async {
    print("=== fetchRequestEscrowDetailForInfo called with ID: $id ===");
    print("Current escrowInfoDetail length before fetch: ${escrowInfoDetail.length}");
    print("Setting isLoading to true");
    isLoading.value = true;
    print("isLoading is now: ${isLoading.value}");
    
    String? token = await getToken();
    print("Token: ${token != null ? 'Found' : 'Not found'}");
    
    try {
      final url = Uri.parse("$baseUrl/api/requestedEscrowDetail/$id");
      print("=== Making API call ===");
      print("Calling API: $url with GET method");
      print("Base URL: $baseUrl");
      print("Full URL: $url");
      print("About to make HTTP GET request...");
     
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          print('API call timed out after 30 seconds');
          throw TimeoutException('API call timed out', Duration(seconds: 30));
        },
      );
      print("=== API Response received ===");
      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print("=== API Response Status: 200 ===");
        print("Parsed response data: $responseData");
        print("Response data keys: ${responseData.keys.toList()}");
        print("Response data type: ${responseData.runtimeType}");
        
        // Check for both 'success' boolean and 'status' string
        if (responseData['success'] == true || responseData['status'] == 'success') {
          // The API returns data directly at root level, not wrapped in 'data' field
          print('=== Data to be parsed ===');
          print('API Response data: $responseData');
          print('Response data type: ${responseData.runtimeType}');
          print('Response data keys: ${responseData.keys.toList()}');
          
          // Pass the entire response data to the fromJson constructor
          try {
            print('=== About to parse DetailsRequestEscrow ===');
            print('Data being passed to parser: $responseData');
            final detailsRequestEscrow = DetailsRequestEscrow.fromJson(responseData);
            print('=== SUCCESS: Parsed DetailsRequestEscrow for Info ===');
            print('Parsed object: $detailsRequestEscrow');
          
            escrowInfoDetail.assignAll([detailsRequestEscrow]);
            print('=== SUCCESS: Updated escrowInfoDetail length: ${escrowInfoDetail.length} ===');
            print('=== Data assigned successfully ===');
          } catch (parseError) {
            print('Error parsing DetailsRequestEscrow for Info: $parseError');
            print('Parse error details: $parseError');
            // Don't try fallback parsing since the API structure is clear
          }
        } else {
          print('API returned success: false, message: ${responseData['message']}');
          print('Full response data: $responseData');
        }
      } else {
        print('HTTP Error: ${response.statusCode}, body: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    } finally {
      print('=== Finally block reached ===');
      print('Setting isLoading to false');
      isLoading.value = false;
      print('isLoading is now: ${isLoading.value}');
      print('=== Loading completed, escrowInfoDetail length: ${escrowInfoDetail.length} ===');
      print('=== Final state check ===');
      if (escrowInfoDetail.isNotEmpty) {
        final data = escrowInfoDetail.first;
        print('=== Final data summary ===');
        print('  - ID: ${data.id}');
        print('  - Title: ${data.title}');
        print('  - Status: ${data.statusLabel}');
        print('  - Gross: ${data.gross}');
        print('  - Description: ${data.description}');
        print('  - Category: ${data.categoryName}');
        print('  - Payment Method: ${data.paymentMethodName}');
        print('  - Fee: ${data.fee}');
        print('  - Net: ${data.net}');
      } else {
        print('=== No data in escrowInfoDetail after API call ===');
      }
    }
  }

  Future<void> approveRequestEscrow(String eid) async {
    final String? token = await getToken(); // Ensure getToken() fetches your auth token
    final Uri url = Uri.parse("$baseUrl/api/approve_request?eid=$eid");
    final languageController = Get.find<LanguageController>();
    
    if (token == null) {
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('token_not_found'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("response body: ${response.body}");
      print("response code: ${response.statusCode}");
      if (response.statusCode == 200) {
        Get.snackbar(
          languageController.getTranslation('success'),
          languageController.getTranslation('approve_request_escrow_processed_successfully'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.off(GetRequestedEscrow());
        await controller.fetchRequestedEscrows();
        // Handle the response data as needed
      } else {
        final data = json.decode(response.body);
        String message = data['message'] ?? languageController.getTranslation('failed_to_process_escrow_approve');
        Get.snackbar(
          languageController.getTranslation('message'),
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('an_error_occurred'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> rejectRequestEscrow(String eid) async {
    final String? token = await getToken(); // Ensure getToken() fetches your auth token
    final Uri url = Uri.parse("$baseUrl/api/reject_request?eid=$eid");
    final languageController = Get.find<LanguageController>();
    
    if (token == null) {
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('token_not_found'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("response body: ${response.body}");
      print("response code: ${response.statusCode}");
      if (response.statusCode == 200) {
        Get.snackbar(
          languageController.getTranslation('success'),
          languageController.getTranslation('reject_request_escrow_processed_successfully'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.off(GetRejectedEscrow());
        //await rejectController.fetchRejectedEscrows();
        // Handle the response data as needed
      } else {
        final data = json.decode(response.body);
        String message = data['message'] ?? languageController.getTranslation('failed_to_process_escrow_reject_request');
        Get.snackbar(
          languageController.getTranslation('message'),
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('an_error_occurred'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> cancelRequestEscrow(String eid) async {
    final int escrowId = int.tryParse(eid) ?? 0;
    
    // Set loading state for this specific escrow
    setCancelLoading(escrowId, true);
    
    final String? token = await getToken(); // Ensure getToken() fetches your auth token
    final Uri url = Uri.parse("$baseUrl/api/cancel_request");
    final languageController = Get.find<LanguageController>();
    
    if (token == null) {
      setCancelLoading(escrowId, false); // Reset loading state for this escrow
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('token_not_found'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'eid': eid,
        }),
      );
      print("response body: ${response.body}");
      print("response code: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Show the actual message from API response
        String message = data['message'] ?? languageController.getTranslation('cancel_request_escrow_processed_successfully');
        Get.snackbar(
          languageController.getTranslation('success'),
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.off(GetCancelledEscrow());
        //await rejectController.fetchRejectedEscrows();
        // Handle the response data as needed
      } else {
        final data = json.decode(response.body);
        // Show the actual error message from API response
        String message = data['message'] ?? languageController.getTranslation('failed_to_process_escrow_cancel_request');
        Get.snackbar(
          languageController.getTranslation('error'),
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('an_error_occurred'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // Always reset loading state for this specific escrow
      setCancelLoading(escrowId, false);
    }
  }

  Future<void> releaseRequestEscrow(String eid) async {
    final String? token = await getToken(); // Ensure getToken() fetches your auth token
    final Uri url = Uri.parse("$baseUrl/api/release_request?eid=$eid");
    final languageController = Get.find<LanguageController>();
    
    if (token == null) {
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('token_not_found'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("response body: ${response.body}");
      print("response code: ${response.statusCode}");
      if (response.statusCode == 200) {
        Get.snackbar(
          languageController.getTranslation('success'),
          languageController.getTranslation('release_request_escrow_processed_successfully'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.off(GetRequestedEscrow());
        await controller.fetchRequestedEscrows();
        // Handle the response data as needed
      } else {
        final data = json.decode(response.body);
        String message = data['message'] ?? languageController.getTranslation('failed_to_process_release_request');
        Get.snackbar(
          languageController.getTranslation('message'),
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('an_error_occurred'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Test method to manually reset loading state
  void resetLoading() {
    print('Manually resetting loading state');
    isLoading.value = false;
    print('isLoading is now: ${isLoading.value}');
  }

  // Test method to manually reset cancel loading state
  void resetCancelLoading() {
    print('Manually resetting cancel loading state');
    isCancelling.value = false;
    print('isCancelling is now: ${isCancelling.value}');
  }

  // Method to set loading state for a specific escrow
  void setCancelLoading(int escrowId, bool loading) {
    cancelLoadingStates[escrowId] = loading;
  }

  // Method to get loading state for a specific escrow
  bool getCancelLoading(int escrowId) {
    return cancelLoadingStates[escrowId] ?? false;
  }

  // Method to reset loading state for a specific escrow
  void resetCancelLoadingForEscrow(int escrowId) {
    cancelLoadingStates.remove(escrowId);
  }

  // Method to reset all states when navigating to the screen
  void resetAllStates() {
    isLoading.value = false;
    isCancelling.value = false;
    cancelLoadingStates.clear();
    escrowDetail.clear();
    // Don't clear escrowInfoDetail here to preserve information screen data
    // escrowInfoDetail.clear(); // Commented out to preserve information screen data
    // Don't clear requestEscrows here as we want to keep the list
  }
  
  // Method to clear only information screen data when needed
  void clearInfoData() {
    print('Clearing escrowInfoDetail data');
    escrowInfoDetail.clear();
    print('escrowInfoDetail cleared, length: ${escrowInfoDetail.length}');
  }

  // Test method to add sample data
  void addTestData() {
    print('Adding test data');
    final testData = DetailsRequestEscrow(
      id: 1,
      title: 'Test Escrow',
      gross: 100.0,
      description: 'Test Description',
      status: 0,
      escrows_hpd: 30,
      senderEmail: 'sender@test.com',
      receiverEmail: 'receiver@test.com',
      createdAt: DateTime.now(),
    );
    escrowDetail.assignAll([testData]);
    print('Test data added, escrowDetail length: ${escrowDetail.length}');
  }
  
  // Test method to add sample data to escrowInfoDetail
  void addTestInfoData() {
    print('Adding test info data');
    final testData = DetailsRequestEscrow(
      id: 1,
      title: 'Test Info Escrow',
      gross: 200.0,
      description: 'Test Info Description',
      status: 0,
      escrows_hpd: 45,
      senderEmail: 'info@test.com',
      receiverEmail: 'info_receiver@test.com',
      createdAt: DateTime.now(),
      fee: 0.30,
      net: 200.0,
      categoryName: 'Test Category',
      paymentMethodName: 'Test Payment Method',
    );
    escrowInfoDetail.assignAll([testData]);
    print('Test info data added, escrowInfoDetail length: ${escrowInfoDetail.length}');
  }

  // Method to manually test API response parsing
  void testApiResponseParsing() {
    print('=== Testing API Response Parsing ===');
    
    // Simulate the API response structure you provided
    final testApiResponse = {
      "status": "success",
      "fee": "0.30",
      "gross": "15.00",
      "net": "15.00",
      "created_at": "14 hours ago",
      "holding_period": "30 Days",
      "escrow": {
        "id": 10,
        "user_id": 6,
        "application_id": null,
        "title": "sdf sfsdf sadfsdf",
        "escrow_category_id": 22,
        "product_name": "Test product",
        "attachment": "[\"assets\\/escrow\\/attachment\\/1756136516_1740395960.jpg\"]",
        "to": 15,
        "gross": "15.00000000",
        "fee": "0.30000000",
        "net": "15.00000000",
        "description": "fsadsad sadf sadfsadfsdf",
        "json_data": null,
        "currency_id": 1,
        "payment_method_id": 3,
        "currency_symbol": "XAF",
        "status": 4,
        "agreement": 0,
        "created_at": "2025-08-25T15:41:56.000000Z",
        "updated_at": "2025-08-25T17:35:52.000000Z",
        "deleted_at": null,
        "payment_method": {
          "id": 3,
          "payment_method_name": "MTN & Orange",
          "currency": "CFA Franc",
          "currency_id": 1,
          "status": "1",
          "detail": null,
          "created_at": "2025-07-29T12:05:58.000000Z",
          "updated_at": "2025-07-29T13:03:58.000000Z"
        },
        "escrow_category": {
          "id": 22,
          "title": "Apparel & Clothing",
          "fr": "Vêtements et vêtements",
          "status": "1",
          "created_at": "2025-03-28T19:54:11.000000Z",
          "updated_at": "2025-08-20T07:53:48.000000Z"
        }
      },
      "sender": {
        "id": 6,
        "name": null,
        "email": "abiddasti06@gmail.com"
      },
      "receiver": {
        "id": 15,
        "name": null,
        "email": "shopdasti@gmail.com"
      }
    };
    
    try {
      print('Testing with simulated API response...');
      final parsedData = DetailsRequestEscrow.fromJson(testApiResponse);
      print('SUCCESS: Parsed test data: $parsedData');
      
      // Add to escrowInfoDetail to test display
      escrowInfoDetail.assignAll([parsedData]);
      print('Test data added to escrowInfoDetail, length: ${escrowInfoDetail.length}');
      
    } catch (e) {
      print('ERROR: Failed to parse test data: $e');
    }
  }

  // Method to manually test the actual API call
  Future<void> testActualApiCall(int escrowId) async {
    print('=== Testing Actual API Call ===');
    print('Escrow ID: $escrowId');
    
    try {
      await fetchRequestEscrowDetailForInfo(escrowId);
      print('API call completed successfully');
      print('Final escrowInfoDetail length: ${escrowInfoDetail.length}');
      
      if (escrowInfoDetail.isNotEmpty) {
        final data = escrowInfoDetail.first;
        print('Data loaded successfully:');
        print('  - Title: ${data.title}');
        print('  - Status: ${data.statusLabel}');
        print('  - Gross: ${data.gross}');
      } else {
        print('No data loaded from API call');
      }
    } catch (e) {
      print('ERROR in API call: $e');
    }
  }

  // Method to check current state
  void checkCurrentState() {
    print('=== Current Controller State ===');
    print('isLoading: ${isLoading.value}');
    print('escrowInfoDetail length: ${escrowInfoDetail.length}');
    print('escrowDetail length: ${escrowDetail.length}');
    print('requestEscrows length: ${requestEscrows.length}');
    
    if (escrowInfoDetail.isNotEmpty) {
      final data = escrowInfoDetail.first;
      print('First escrowInfoDetail item:');
      print('  - ID: ${data.id}');
      print('  - Title: ${data.title}');
      print('  - Status: ${data.statusLabel}');
      print('  - Gross: ${data.gross}');
    }
    
    if (escrowDetail.isNotEmpty) {
      final data = escrowDetail.first;
      print('First escrowDetail item:');
      print('  - ID: ${data.id}');
      print('  - Title: ${data.title}');
      print('  - Status: ${data.statusLabel}');
      print('  - Gross: ${data.gross}');
    }
  }

  // Method to show all available fields from API response
  void showApiResponseFields() {
    if (escrowDetail.isNotEmpty) {
      final data = escrowDetail.first;
      print('Current escrow detail data:');
      print('  - ID: ${data.id}');
      print('  - Title: ${data.title}');
      print('  - Gross: ${data.gross}');
      print('  - Description: ${data.description}');
      print('  - Status: ${data.status}');
      print('  - Holding Period: ${data.escrows_hpd}');
      print('  - Sender Email: ${data.senderEmail}');
      print('  - Receiver Email: ${data.receiverEmail}');
      print('  - Created At: ${data.createdAt}');
      print('  - Currency Symbol: ${data.currencySymbol}');
      print('  - Attachment: ${data.attachment}');
    } else {
      print('No escrow detail data available');
    }
  }

  Future<Map<String, dynamic>?> storeRequestEscrow({
    required String title,
    required double amount,
    required String email,
    required int escrowCategoryId,
    required String currency,
    required String description,
    required bool escrowTermConditions, // New parameter
    List<File>? attachments, // Optional multiple files parameter
    String? productName, // Product name parameter
    int? paymentMethodId, // Payment method ID parameter
  }) async {
    final languageController = Get.find<LanguageController>();
    
    try {
      String? token = await getToken();
      if (token == null) {
        print("Error: Token is null. Cannot proceed with the request.");
        return {
          'success': false,
          'message': languageController.getTranslation('authentication_error'),
        };
      }
      print("Retrieved Token: $token");
      final url = Uri.parse('$baseUrl/api/storeRequestEscrow');

      // Create a multipart request
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll({
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        })
        ..fields['title'] = title
        ..fields['amount'] = amount.toString()
        ..fields['email'] = email
        ..fields['escrow_category_id'] = escrowCategoryId.toString()
        ..fields['currency'] = currency
        ..fields['description'] = description
        ..fields['escrow_term_conditions'] = escrowTermConditions.toString()
        ..fields['product_name'] = productName ?? ''
        ..fields['method_id'] = paymentMethodId?.toString() ?? '';
      
      print("Product name added: ${productName ?? 'empty'}");
      print("Method ID added: ${paymentMethodId?.toString() ?? 'empty'}");

      // Add files if available
      if (attachments != null && attachments.isNotEmpty) {
        for (int i = 0; i < attachments.length; i++) {
          request.files.add(await http.MultipartFile.fromPath('attachment[]', attachments[i].path));
          print("File attached: ${attachments[i].path}");
        }
        print("Total files attached: ${attachments.length}");
      } else {
        // Add empty array field if no files are selected
        request.fields['attachment'] = '[]';
        print("No files attached - sending empty attachment array");
      }


      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseBody = jsonDecode(response.body);
      print("response body: ${response.body}");
      print("response code: ${response.statusCode}");

      if (response.statusCode == 200 ) {
        // Success
        print("Request Escrow stored successfully: ${responseBody['message']}");
        return responseBody;
      } else {
        // Error handling
        String errorMessage = responseBody['message'] ?? languageController.getTranslation('an_error_occurred');
        if (responseBody['message'] is String) {
          errorMessage = responseBody['message'];
        } else if (responseBody['message'] is Map && responseBody['message']['email'] != null) {
          errorMessage = responseBody['message']['email'][0];
        }
        print("Failed to store request escrow: $errorMessage");
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print("An error occurred: $e");
      return {
        'success': false,
        'message': languageController.getTranslation('an_unexpected_error_occurred_please_try_again'),
      };
    }
  }
}

class RequestEscrow {
  final int id;
  final String? userId;
  final String? to;
  final String title;
  final String? attachment;
  final String gross;
  final String description;
  final String currencySymbol;
  final int status;
  final DateTime createdAt;

  RequestEscrow({
    required this.id,
    required this.userId,
    required this.to,
    required this.title,
    this.attachment,
    required this.gross,
    required this.description,
    required this.currencySymbol,
    required this.status,
    required this.createdAt,
  });
  String get statusLabel {
    switch (status) {
      case 0:
        return 'Pending'; // Status 1 is completed
      case 1:
        return 'Completed'; // Status 2 is pending
      case 2:
        return 'Rejected';
      case 3:
        return 'On Hold';
      case 4:
        return 'Cancelled';
      default:
        return 'Unknown'; // Default label if status is neither 1 nor 2
    }
  }

  factory RequestEscrow.fromJson(Map<String, dynamic> json) {
    return RequestEscrow(
      id: json['id'] ?? 0,
      userId: json['user']?['email'],
      to: json['to_user']?['email'],
      title: json['title'] ?? '',
      attachment: json['attachment'],
      gross: json['gross'] ?? '0.000',
      description: json['description'] ?? '',
      currencySymbol: json['currency_symbol'] ?? '',
      status: json['status'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}


class DetailsRequestEscrow {
  final int id;
  final String? title; // Nullable field
  final String? attachment; // Nullable field
  final double gross; // Changed to double for numeric consistency
  final String description;
  final String? currencySymbol; // Nullable field
  final int status;
  final int escrows_hpd;
  final String? senderEmail; // Nullable field
  final String? receiverEmail; // Nullable field
  final DateTime? createdAt;
  final double? fee; // Additional field from API
  final double? net; // Additional field from API
  final String? categoryName; // Additional field from API
  final String? paymentMethodName; // Additional field from API

  DetailsRequestEscrow({
    required this.id,
    this.title,
    this.attachment,
    required this.gross,
    this.description = '', // Default to an empty string
    this.currencySymbol,
    required this.status,
    required this.escrows_hpd,
    this.senderEmail,
    this.receiverEmail,
    this.createdAt,
    this.fee,
    this.net,
    this.categoryName,
    this.paymentMethodName,
  });

  String get statusLabel {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Completed';
      case 2:
        return 'Rejected';
      case 3:
        return 'On Hold';
      case 4:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
  factory DetailsRequestEscrow.fromJson(Map<String, dynamic> json) {
    print("DetailsRequestEscrow.fromJson called with: $json");
    
    // Based on the API response structure, data is nested under 'escrow', 'sender', 'receiver'
    final escrowData = json['escrow'] ?? {};
    final senderData = json['sender'] ?? {};
    final receiverData = json['receiver'] ?? {};
    
    print("escrowData: $escrowData");
    print("senderData: $senderData");
    print("receiverData: $receiverData");
    print("Root level fields:");
    print("  - holding_period: ${json['holding_period']}");
    print("  - gross: ${json['gross']}");
    print("  - fee: ${json['fee']}");
    print("  - net: ${json['net']}");
    print("All available fields in API response:");
    json.keys.forEach((key) {
      print("  - $key: ${json[key]}");
    });
    
    // Safely parse the data with better error handling
    try {
      final result = DetailsRequestEscrow(
        id: escrowData['id'] ?? 0,
        title: escrowData['title'] ?? 'No Title',
        attachment: escrowData['attachment'],
        // Use gross from escrow object, fallback to root level
        gross: double.tryParse(escrowData['gross']?.toString() ?? json['gross']?.toString() ?? '0.000') ?? 0.0,
        description: escrowData['description'] ?? 'No Description', // Better default value
        currencySymbol: escrowData['currency_symbol'] ?? 'N/A',
        status: escrowData['status'] ?? 0,
        // Parse holding_period from root level (e.g., "30 Days" -> 30)
        escrows_hpd: _parseHoldingPeriod(json['holding_period']),
        senderEmail: senderData['email'] ?? 'No Sender Email',
        receiverEmail: receiverData['email'] ?? 'No Receiver Email',
        createdAt: escrowData['created_at'] != null
            ? DateTime.tryParse(escrowData['created_at'])
            : null, // Safely parse nullable DateTime
        // Additional fields from API response
        fee: double.tryParse(json['fee']?.toString() ?? '0.00'),
        net: double.tryParse(json['net']?.toString() ?? '0.00'),
        categoryName: escrowData['escrow_category']?['title'] ?? 'No Category',
        paymentMethodName: escrowData['payment_method']?['payment_method_name'] ?? 'No Payment Method',
      );
      
      print("Created DetailsRequestEscrow: $result");
      print("Extracted values:");
      print("  - ID: ${result.id}");
      print("  - Title: ${result.title}");
      print("  - Gross: ${result.gross}");
      print("  - Holding Period: ${result.escrows_hpd}");
      print("  - Status: ${result.status}");
      print("  - Sender Email: ${result.senderEmail}");
      print("  - Receiver Email: ${result.receiverEmail}");
      print("  - Category: ${result.categoryName}");
      print("  - Payment Method: ${result.paymentMethodName}");
      print("  - Fee: ${result.fee}");
      print("  - Net: ${result.net}");
      return result;
    } catch (e) {
      print("ERROR in DetailsRequestEscrow.fromJson: $e");
      print("Stack trace: ${StackTrace.current}");
      
      // Return a default object if parsing fails
      return DetailsRequestEscrow(
        id: 0,
        title: 'Error Loading Title',
        gross: 0.0,
        description: 'Error loading description: $e',
        status: 0,
        escrows_hpd: 0,
        senderEmail: 'Error loading sender email',
        receiverEmail: 'Error loading receiver email',
        createdAt: null,
        fee: 0.0,
        net: 0.0,
        categoryName: 'Error loading category',
        paymentMethodName: 'Error loading payment method',
      );
    }
  }
  static int _parseHoldingPeriod(dynamic holdingPeriod) {
    print("Parsing holding period: $holdingPeriod (type: ${holdingPeriod.runtimeType})");
    
    if (holdingPeriod != null) {
      // If it's already a number, return it directly
      if (holdingPeriod is int) {
        print("Holding period is already an int: $holdingPeriod");
        return holdingPeriod;
      }
      
      // If it's a double, convert to int
      if (holdingPeriod is double) {
        print("Holding period is double, converting to int: ${holdingPeriod.toInt()}");
        return holdingPeriod.toInt();
      }
      
      // If it's a string, try to extract the number
      if (holdingPeriod is String) {
        // Handle formats like "30 Days", "45 Days", etc.
        final regex = RegExp(r'(\d+)'); // Match the number in the string
        final match = regex.firstMatch(holdingPeriod);
        if (match != null) {
          final result = int.tryParse(match.group(0) ?? '0') ?? 0;
          print("Extracted number from string '$holdingPeriod': $result");
          return result;
        }
        
        // Try to parse as int directly if it's just a number string
        final directParse = int.tryParse(holdingPeriod);
        if (directParse != null) {
          print("Direct parse successful: $directParse");
          return directParse;
        }
      }
      
      // Try to parse as int directly
      final directParse = int.tryParse(holdingPeriod.toString());
      if (directParse != null) {
        print("Direct parse successful: $directParse");
        return directParse;
      }
    }
    
    print("No valid holding period found, defaulting to 0");
    return 0; // Default to 0 if no number is found
  }
  
  @override
  String toString() {
    return 'DetailsRequestEscrow(id: $id, title: $title, gross: $gross, status: $status, escrows_hpd: $escrows_hpd, senderEmail: $senderEmail, receiverEmail: $receiverEmail, createdAt: $createdAt)';
  }
}



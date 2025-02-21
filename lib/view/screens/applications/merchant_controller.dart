
import 'package:dacotech/view/screens/applications/screen_merchant.dart';
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
  var isLoading = false.obs;
  var merchantData = {}.obs;
  var avatar = Rx<File?>(null);
  var avatarUrl = ''.obs;
  var currencies = <MCurrency>[].obs;
  var selectedCurrency = Rx<MCurrency?>(null); // Single selected Currency or Method
  // Single selected Currency or Method
  // Form fields
  final merchantName = " ".obs;
  final merchantCurrency = " ".obs;
  final webhookUrl = " ".obs;
  final merchantSiteUrl = " ".obs;
  final merchantSuccessLink =" ".obs;
  final merchantFailLink = " ".obs;
  final merchantDescription =" ".obs;
  //var merchantLogo = ''.obs; // Logo file path
  late  TextEditingController webhookUrlController= TextEditingController();

  @override
  void onInit() {
    fetchMerchants();
    fetchSendmoneyCurrencies();
    webhookUrlController = TextEditingController(text: webhookUrl.value);
    webhookUrlController.addListener(() {
      webhookUrl.value = webhookUrlController.text;
    });

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

  Future<void> createMerchant(BuildContext context) async {
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
          ..fields['site_url'] = merchantSiteUrl.value
          ..fields['webhook_url'] = webhookUrl.value
          ..fields['merchant_description'] = merchantDescription.value;

        // Add file
        request.files.add(await http.MultipartFile.fromPath('logo', avatar.value!.path));

        // Send request
        var response = await request.send();
        var responseData = await response.stream.bytesToString();
        if (response.statusCode == 200 || response.statusCode == 201) {
          var jsonResponse = jsonDecode(responseData);
          if (jsonResponse['status'] == "success") {
            Get.snackbar('Success', jsonResponse['message'],
                backgroundColor: Colors.green,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM);
            clearFormFields();
            Get.off(ScreenMerchant());
            await fetchMerchants();
            break; // Break the retry loop if successful
          } else {
            throw Exception(jsonResponse['message']);
          }
        } else if (response.statusCode == 429) {
          retryCount++;
          if (retryCount >= maxRetries) {
            throw Exception('Rate limit exceeded. Please try again later.');
          }
          await Future.delayed(retryDelay);
        } else {
          throw Exception('Failed to create Application. Status: ${response.statusCode}');
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
        if (retryCount >= maxRetries) isLoading(false);
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
      if (merchantSiteUrl.value.isEmpty) {
        Get.snackbar('Message', 'site url is required',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      if (webhookUrl.value.isEmpty) {
        Get.snackbar('Message', 'webhook url is required',
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
        'site_url': merchantSiteUrl.value,
        'webhook_url': webhookUrl.value,
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
        Get.snackbar('Error', 'Failed to update Application. Status: ${response.statusCode}',
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
    merchantSiteUrl.value = '';
    selectedCurrency.value = null;
    merchantSuccessLink.value = '';
    merchantFailLink.value = '';
    webhookUrl.value = '';
    merchantDescription.value = '';
    avatar.value = null;
    avatarUrl.value = '';
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

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          List<dynamic> data = jsonResponse['data'];
          List<Merchant> fetchedMerchants = data.map((item) => Merchant.fromJson(item)).toList();
          merchants.assignAll(fetchedMerchants);
          merchants.refresh(); // Ensure UI updates
          print('Updated Merchants List: ${merchants.map((e) => e.name).toList()}');
        } else {
          throw Exception(jsonResponse['message']);
        }
      } else {
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
            webhookUrlController.text = merchantData['webhook_url'] ?? '';
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
  Future<void> updateWebhookUrl(BuildContext context, String merchantId) async {
    String newUrl = webhookUrlController.text;

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
}

class Merchant{
  final String id;
  final String logo;
  final String webhookUrl;
  final String name;
  final String description;
  final String siteUrl;
 // final String merchant_id;

//<editor-fold desc="Data Methods">
   Merchant({
    required this.id,
    required this.logo,
    required this.webhookUrl,
    required this.name,
    required this.description,
    required this.siteUrl,
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





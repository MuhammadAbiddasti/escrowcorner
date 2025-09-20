import 'package:escrowcorner/view/screens/managers/screen_managers.dart';
import 'package:escrowcorner/view/screens/managers/screen_update_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../widgets/custom_token/constant_token.dart';
import '../../../widgets/custom_api_url/constant_url.dart';
import '../../controller/language_controller.dart';

class ManagersController extends GetxController {
  RxList<Manager> managersList = <Manager>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var selectedManagerId = ''.obs;
  var isEditing = false.obs;
  var managerId = ''.obs;
  
  // Applications related variables
  RxList<Application> applicationsList = <Application>[].obs;
  var isApplicationsLoading = false.obs;
  var applicationsErrorMessage = ''.obs;
  RxList<int> selectedApplicationIds = <int>[].obs;


  @override
  void onInit() {
    super.onInit();
    fetchManagers();
  }
  // Method to Fetch Managers
  Future<void> fetchManagers() async {
    try {
      isLoading(true);
      errorMessage('');
      String? token = await getToken();
      if (token == null) {
        throw Exception('Token is null');
      }
      print('Retrieved Token: $token');

      var response = await http.get(
        Uri.parse('$baseUrl/api/managers'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Decode the JSON response
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Extract the manager's details from the response
        final data = jsonResponse['data']; // 'data' contains a list of managers
        if (data != null && data.isNotEmpty) {
          final managerDetails = data[0]; // Assuming we're working with the first manager in the list

          // Assign the managerId
          managerId.value = managerDetails['id']?.toString() ?? '';
          print("Manager ID: $managerId");

          // Explicitly cast 'data' to List<Map<String, dynamic>> before mapping
          managersList.value = List<Map<String, dynamic>>.from(data)
              .map((managerJson) => Manager.fromJson(managerJson))
              .toList();
        } else {
          errorMessage('No manager data found in the response');
        }
      } else {
        errorMessage('Failed to fetch managers');
      }

    } catch (e) {
      errorMessage('An error occurred: $e');
      print("Error $e");
    } finally {
      isLoading(false);
    }
  }

  // Method to Create New Managers
  Future<void> createManager({required BuildContext context,
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String ConfPassword,
    required String phone,
  }) async {


    try {
      isLoading(true);
      errorMessage('');
      String? token = await getToken();
      if (token == null) {
        throw Exception('Token is null');
      }
      
      // Prepare the request body
      Map<String, dynamic> requestBody = {
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'password': password,
        'confirm_password': ConfPassword,
        'phone': phone,
      };
      
      // Add selected application IDs if any are selected
      if (selectedApplicationIds.isNotEmpty) {
        requestBody['application_ids'] = selectedApplicationIds.toList();
      }
      
      var response = await http.post(
        Uri.parse('$baseUrl/api/create_manager'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      print('Response body: ${response.body}');

      final languageController = Get.find<LanguageController>();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body);
        final String apiMessage = (jsonResponse['message']?.toString())
            ?? (jsonResponse['data']?.toString())
            ?? '';

        if (jsonResponse['success'] == true) {
          Get.snackbar(
            languageController.getTranslation('success'),
            apiMessage.isNotEmpty ? apiMessage : languageController.getTranslation('manager_created_successfully'),
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          Get.off(ScreenManagers());
          fetchManagers();
          // Clear selected applications after successful creation
          clearSelectedApplications();
        } else {
          Get.snackbar(
            languageController.getTranslation('error'),
            apiMessage.isNotEmpty ? apiMessage : 'Request failed',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        // Try to parse server-provided message for non-2xx responses
        String message;
        try {
          final decoded = jsonDecode(response.body);
          message = decoded['message']?.toString() ?? 'Failed to create manager: ${response.statusCode}';
        } catch (_) {
          message = 'Failed to create manager: ${response.statusCode}';
        }
        Get.snackbar(
          languageController.getTranslation('error'),
          message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      final languageController = Get.find<LanguageController>();
      Get.snackbar(
        languageController.getTranslation('error'),
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // Method to Fetch Managers Details
  Future<void> fetchManagerDetails(int id) async {
    try {
      print('=== FETCHING MANAGER DETAILS FOR ID: $id ===');
      isLoading(true);
      String? token = await getToken(); // Fetch the auth token
      if (token == null) {
        throw Exception('Token is null');
      }

      print('Token retrieved successfully');
      final url = '$baseUrl/api/edit_manager/$id';
      print('API URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('JSON Response: $jsonResponse');
        
        if (jsonResponse['success'] == true) {
          // Handle both List and Map responses
          Map<String, dynamic> managerDataMap;
          
          if (jsonResponse['data'] is List) {
            // If data is a list, take the first item
            List<dynamic> dataList = jsonResponse['data'];
            if (dataList.isNotEmpty) {
              managerDataMap = dataList[0] as Map<String, dynamic>;
              print('Data is a list, using first item: $managerDataMap');
            } else {
              throw Exception('Manager data list is empty');
            }
          } else if (jsonResponse['data'] is Map<String, dynamic>) {
            // If data is already a map, use it directly
            managerDataMap = jsonResponse['data'] as Map<String, dynamic>;
            print('Data is a map: $managerDataMap');
          } else {
            throw Exception('Unexpected data format: ${jsonResponse['data'].runtimeType}');
          }
          
          var managerData = Manager.fromJson(managerDataMap);
          
          // Handle assigned applications if present in response
          if (jsonResponse.containsKey('assign_application') && jsonResponse['assign_application'] != null) {
            var assignAppData = jsonResponse['assign_application'];
            print('Assign application data type: ${assignAppData.runtimeType}');
            print('Assign application data: $assignAppData');
            
            if (assignAppData is Map<String, dynamic>) {
              handleAssignedApplications(assignAppData);
            } else if (assignAppData is List && assignAppData.isNotEmpty) {
              // Convert list to map format if needed
              Map<String, dynamic> assignAppMap = {};
              for (int i = 0; i < assignAppData.length; i++) {
                assignAppMap[i.toString()] = assignAppData[i];
              }
              handleAssignedApplications(assignAppMap);
            } else {
              // Empty array or null - just clear selections
              print('Assign application is empty or null, clearing selections');
              selectedApplicationIds.clear();
            }
          } else {
            print('No assign_application data found, clearing selections');
            selectedApplicationIds.clear();
          }
          
          print('Manager Data parsed successfully: $managerData');
          print('Navigating to ScreenUpdateManger...');
          
          // Navigate to update screen
          Get.to(() => ScreenUpdateManger(manager: managerData));
          print('Navigation completed');
        } else {
          print('API returned success: false');
          final languageController = Get.find<LanguageController>();
          Get.snackbar(
            languageController.getTranslation('error'),
            jsonResponse['message'] ?? 'Failed to load manager details',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        print('API call failed with status: ${response.statusCode}');
        final languageController = Get.find<LanguageController>();
        Get.snackbar(
          languageController.getTranslation('error'),
          'Failed to fetch manager details. Status: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Exception in fetchManagerDetails: $e');
      final languageController = Get.find<LanguageController>();
      Get.snackbar(
        languageController.getTranslation('error'),
        'Error: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
      print('=== FETCH MANAGER DETAILS COMPLETED ===');
    }
  }
  // Method to handle assigned applications from API response
  void handleAssignedApplications(Map<String, dynamic> assignApplicationData) {
    try {
      print('Handling assigned applications: $assignApplicationData');
      selectedApplicationIds.clear();
      
      if (assignApplicationData.isNotEmpty) {
        // Extract application IDs from the assign_application data
        assignApplicationData.forEach((key, value) {
          if (value is Map<String, dynamic> && value.containsKey('application_id')) {
            int applicationId = int.tryParse(value['application_id'].toString()) ?? 0;
            if (applicationId > 0) {
              selectedApplicationIds.add(applicationId);
              print('Added application ID: $applicationId');
            }
          }
        });
        print('Total selected application IDs: ${selectedApplicationIds.length}');
      } else {
        print('Assign application data is empty, cleared selections');
      }
    } catch (e) {
      print('Error in handleAssignedApplications: $e');
      // Clear selections on error to prevent issues
      selectedApplicationIds.clear();
    }
  }

  // Method to Edit Managers
  Future<void> editManager({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String confPassword,
  }) async {
    // Password fields are optional; if provided, they must match
    if ((password.isNotEmpty || confPassword.isNotEmpty) && password != confPassword) {
      final languageController = Get.find<LanguageController>();
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('new_password_not_matched_with_confirm_password'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    try {
      isLoading(true);
      String? token = await getToken();
      if (token == null) {
        throw Exception('Token is null');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/update_manager/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(() {
          final payload = <String, dynamic>{
            'email': email,
            'first_name': firstName,
            'last_name': lastName,
            'phone': phone,
          };
          if (password.isNotEmpty) {
            payload['password'] = password;
          }
          
          // Add selected application IDs if any are selected
          if (selectedApplicationIds.isNotEmpty) {
            payload['application_ids'] = selectedApplicationIds.toList();
          }
          
          return payload;
        }()),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final languageController = Get.find<LanguageController>();
        if (jsonResponse['success'] == true) {
          // Handle assigned applications if present in response
          if (jsonResponse.containsKey('assign_application') && jsonResponse['assign_application'] != null) {
            handleAssignedApplications(jsonResponse['assign_application']);
          }
          
          final apiMessage = (jsonResponse['message']?.toString())
              ?? (jsonResponse['data']?.toString())
              ?? '';
          Get.off(ScreenManagers());  // Return to the previous screen
          Get.snackbar(
            languageController.getTranslation('success'),
            apiMessage.isNotEmpty ? apiMessage : languageController.getTranslation('manager_updated_successfully'),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          fetchManagers();
          // Clear selected applications after successful update
          clearSelectedApplications();
        } else {
          final apiMessage = (jsonResponse['message']?.toString()) ?? 'Failed to update manager details';
          Get.snackbar(
            languageController.getTranslation('error'),
            apiMessage,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          errorMessage(apiMessage);
          print("Failed to edit manager: ${apiMessage}");
        }
      } else if (response.statusCode == 302) {
        print("Redirect detected: ${response.headers['location']}");
        errorMessage('Failed to edit manager: Redirect detected');
      } else {
        final languageController = Get.find<LanguageController>();
        String apiMessage;
        try {
          final data = jsonDecode(response.body);
          apiMessage = data['message']?.toString() ?? 'Failed to edit manager';
        } catch (_) {
          apiMessage = 'Failed to edit manager';
        }
        Get.snackbar(
          languageController.getTranslation('error'),
          apiMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        errorMessage(apiMessage);
        print("Failed to edit manager: ${response.statusCode}");
      }
    } catch (e) {
      errorMessage(e.toString());
      print("Failed to edit manager: ${e.toString()}");
    } finally {
      isLoading(false);
    }
  }


  // Method to Delete Managers
  Future<void> deleteManager(BuildContext context, int managerId) async {
      try {
        isLoading(true);
        errorMessage('');
        String? token = await getToken();
        if (token == null) {
          throw Exception('Token is null');
        }
        print('Retrieved Token: $token');
        var response = await http.get(
          Uri.parse('$baseUrl/api/delete_manager/$managerId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final languageController = Get.find<LanguageController>();
          try {
            final decoded = jsonDecode(response.body);
            final String apiMessage = (decoded['message']?.toString())
                ?? (decoded['data']?.toString())
                ?? '';
            managersList.removeWhere((manager) => manager.id == managerId);
            Get.snackbar(
              languageController.getTranslation('success'),
              apiMessage.isNotEmpty ? apiMessage : languageController.getTranslation('deleted_successfully'),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          } catch (e) {
            managersList.removeWhere((manager) => manager.id == managerId);
            Get.snackbar(
              languageController.getTranslation('success'),
              languageController.getTranslation('deleted_successfully'),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          }
        } else {
          // Log the status code and response body for debugging
          print('Failed to delete manager: ${response.statusCode}');
          print('Response body: ${response.body}');
          final languageController = Get.find<LanguageController>();
          String message;
          try {
            final decoded = jsonDecode(response.body);
            message = decoded['message']?.toString() ?? 'Failed to delete manager';
          } catch (_) {
            message = 'Failed to delete manager';
          }
          Get.snackbar(
            languageController.getTranslation('error'),
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          errorMessage('Failed to delete manager: ${response.body}');
        }
      } catch (e) {
        errorMessage('An error occurred: $e');
      } finally {
        isLoading(false);
      }
    }

  // Method to fetch applications
  Future<void> getApplications() async {
    try {
      isApplicationsLoading(true);
      applicationsErrorMessage('');
      String? token = await getToken();
      if (token == null) {
        throw Exception('Token is null');
      }

      var response = await http.get(
        Uri.parse('$baseUrl/api/getApplications'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final data = jsonResponse['data'] as List;
          applicationsList.value = data
              .map((appJson) => Application.fromJson(appJson))
              .toList();
        } else {
          applicationsList.clear();
        }
      } else {
        applicationsErrorMessage('Failed to fetch applications');
      }
    } catch (e) {
      applicationsErrorMessage('An error occurred: $e');
      print("Error fetching applications: $e");
    } finally {
      isApplicationsLoading(false);
    }
  }

  // Method to toggle application selection
  void toggleApplicationSelection(int applicationId) {
    if (selectedApplicationIds.contains(applicationId)) {
      selectedApplicationIds.remove(applicationId);
    } else {
      selectedApplicationIds.add(applicationId);
    }
  }

  // Method to clear selected applications
  void clearSelectedApplications() {
    selectedApplicationIds.clear();
  }

  // Method to clear selections when navigating between screens
  void clearSelectionsForNavigation() {
    selectedApplicationIds.clear();
  }

  // Method to handle assigned applications from API response
}

// Model class for Manager
class Manager {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String createdAt;

  Manager({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.createdAt,
  });

  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phonenumber'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
  @override
  String toString() {
    return 'Manager(id: $id, firstName: $firstName, lastName: $lastName, email: $email, phoneNumber: $phoneNumber, createdAt: $createdAt)';
  }
}

// Model class for Application
class Application {
  final int id;
  final int userId;
  final String merchantKey;
  final String? siteUrl;
  final String? successLink;
  final String? failLink;
  final String logo;
  final String name;
  final String? webhookUrl;
  final String description;
  final String? jsonData;
  final String? currencyId;
  final String? thumb;
  final String publicKey;
  final String secretKey;
  final String? ipnUrl;
  final String balance;
  final String mtnBalance;
  final String orangeBalance;
  final String createdAt;
  final String updatedAt;

  Application({
    required this.id,
    required this.userId,
    required this.merchantKey,
    this.siteUrl,
    this.successLink,
    this.failLink,
    required this.logo,
    required this.name,
    this.webhookUrl,
    required this.description,
    this.jsonData,
    this.currencyId,
    this.thumb,
    required this.publicKey,
    required this.secretKey,
    this.ipnUrl,
    required this.balance,
    required this.mtnBalance,
    required this.orangeBalance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'],
      userId: json['user_id'],
      merchantKey: json['merchant_key'] ?? '',
      siteUrl: json['site_url'],
      successLink: json['success_link'],
      failLink: json['fail_link'],
      logo: json['logo'] ?? '',
      name: json['name'] ?? '',
      webhookUrl: json['webhook_url'],
      description: json['description'] ?? '',
      jsonData: json['json_data'],
      currencyId: json['currency_id'],
      thumb: json['thumb'],
      publicKey: json['public_key'] ?? '',
      secretKey: json['secret_key'] ?? '',
      ipnUrl: json['ipn_url'],
      balance: json['balance'] ?? '0.00',
      mtnBalance: json['mtn_balance'] ?? '0.00',
      orangeBalance: json['orange_balance'] ?? '0.00',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Application(id: $id, name: $name, description: $description)';
  }
}


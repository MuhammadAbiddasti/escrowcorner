import 'package:dacotech/view/screens/managers/screen_managers.dart';
import 'package:dacotech/view/screens/managers/screen_update_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../widgets/custom_token/constant_token.dart';
import '../../../widgets/custom_api_url/constant_url.dart';

class ManagersController extends GetxController {
  RxList<Manager> managersList = <Manager>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var selectedManagerId = ''.obs;
  var isEditing = false.obs;
  var managerId = ''.obs;



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

    if (email.isEmpty ) {
      Get.snackbar(
        'Error',
        'Email is required.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (firstName.isEmpty ) {
      Get.snackbar(
        'Error',
        'First name is required.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (lastName.isEmpty ) {
      Get.snackbar(
        'Error',
        'Last name is required.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (phone.isEmpty ) {
      Get.snackbar(
        'Error',
        'Phone is required.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (password.isEmpty ) {
      Get.snackbar(
        'Error',
        'Password is required.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (ConfPassword.isEmpty ) {
      Get.snackbar(
        'Error',
        'Confirm Password is required.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (password != ConfPassword ) {
      Get.snackbar(
        'Error',
        'Password and Confirm Password not match',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading(true);
      errorMessage('');
      String? token = await getToken();
      if (token == null) {
        throw Exception('Token is null');
      }
      var response = await http.post(
        Uri.parse('$baseUrl/api/create_manager'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'password': password,
          'phone': phone,
        }),
      );
      print('Response body: ${response.body}');

      if (response.statusCode >= 200 || response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          // Handle success
          Get.snackbar('Success', jsonResponse['data'],
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,); // Display success message
          Get.off(ScreenManagers()); // Navigate to the managers screen
          fetchManagers(); // Refresh the list of managers
        } else {
          // Handle specific error message from the server
          //errorMessage(jsonResponse['message']);
          Get.snackbar('Error', jsonResponse['message'],
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
        }
      } else {
        // Handle unexpected errors
        print('Failed to create manager. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        //errorMessage('Failed to create manager: ${response.statusCode}');
        Get.snackbar('Error', 'Failed to create manager${response.statusCode}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      //errorMessage('An error occurred: $e');
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  // Method to Fetch Managers Details
  Future<void> fetchManagerDetails(int id) async {
    try {
      isLoading(true);
      String? token = await getToken(); // Fetch the auth token
      if (token == null) {
        throw Exception('Token is null');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/edit_manager/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          var managerData = Manager.fromJson(jsonResponse['data']);
          print('Manager Data: $managerData');
          Get.to(() => ScreenUpdateManger(manager: managerData));
        } else {
          throw Exception('Failed to load manager details');
        }
      } else {
        errorMessage('Failed to fetch manager details');
      }
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
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
    if (password.isEmpty ) {
      Get.snackbar(
        'Error',
        'Password is required.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (confPassword.isEmpty ) {
      Get.snackbar(
        'Error',
        'Confirm Password is required.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (password != confPassword ) {
      Get.snackbar(
        'Error',
        'Password and Confirm Password not match',
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
        body: jsonEncode({
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          Get.off(ScreenManagers());  // Return to the previous screen
          Get.snackbar('Success', 'Update Manager Successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,);
          fetchManagers();
        } else {
          errorMessage('Failed to update manager details');
          print("Failed to edit manager: ${jsonResponse['message']}");
        }
      } else if (response.statusCode == 302) {
        print("Redirect detected: ${response.headers['location']}");
        errorMessage('Failed to edit manager: Redirect detected');
      } else {
        errorMessage('Failed to edit manager');
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
          // Remove the manager from the list after a successful deletion
          managersList.removeWhere((manager) => manager.id == managerId);
          Get.snackbar("Success", "Deleted Successfully",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,);
        } else {
          // Log the status code and response body for debugging
          print('Failed to delete manager: ${response.statusCode}');
          print('Response body: ${response.body}');
          errorMessage('Failed to delete manager: ${response.body}');
        }
      } catch (e) {
        errorMessage('An error occurred: $e');
      } finally {
        isLoading(false);
      }
    }
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


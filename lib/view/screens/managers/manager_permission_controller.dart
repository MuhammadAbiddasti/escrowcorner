import 'dart:convert';
import 'package:escrowcorner/widgets/custom_api_url/constant_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../widgets/custom_token/constant_token.dart';
import 'package:escrowcorner/view/screens/user_profile/user_profile_controller.dart';

class ManagersPermissionController extends GetxController {
  var isLoading = true.obs;
  var allowedModules = <String>[].obs;
  Map<String, List<String>> modulePermissions = {};


  Future<Map<String, dynamic>> fetchManagerPermissions(String managerId) async {
    final url = Uri.parse('$baseUrl/api/managerPermission/$managerId');
    if (managerId.isEmpty) {
      throw Exception('Manager ID is empty');
    }

    String? token = await getToken();
    if (token == null) {
      throw Exception('Token is null');
    }
    print('Retrieved Token: $token');
    final response = await http.get(
      Uri.parse('$baseUrl/api/managerPermission/$managerId'),
      headers: {
        'Authorization': 'Bearer $token', // Replace with your token
      },
    );
    print("response code: ${response.statusCode}");
    print("response body: ${response.body}");
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      
      // Handle different response structures
      if (responseData['data'] != null) {
        if (responseData['data'] is Map<String, dynamic>) {
          _extractAllowedModules(responseData['data']);
        } else if (responseData['data'] is List) {
          // If data is a list, create a wrapper map
          _extractAllowedModules({'modules': responseData['data']});
        } else {
          print("Unexpected data type: ${responseData['data'].runtimeType}");
          _extractAllowedModules({});
        }
      } else {
        // If no 'data' key, try to use the response directly
        if (responseData is Map<String, dynamic>) {
          _extractAllowedModules(responseData);
        } else if (responseData is List) {
          _extractAllowedModules({'modules': responseData});
        } else {
          print("Unexpected response type: ${responseData.runtimeType}");
          _extractAllowedModules({});
        }
      }
      
      return responseData;
    } else {
      throw Exception('Failed to load permissions');
    }
  }

  // Extract modules with allowed permissions
  void _extractAllowedModules(Map<String, dynamic> jsonData) {
    try {
      allowedModules.clear(); // Clear the previous list
      modulePermissions.clear(); // Clear previous permissions map

      // Safely check if 'modules' key exists and is not null
      final modulesData = jsonData['modules'];
      if (modulesData != null && modulesData is List) {
        final modules = modulesData.map((module) => Module.fromJson(module)).toList();
        print("Allowed Modules: ${allowedModules.join(', ')}");

        for (var module in modules) {
          bool hasAllowedPermission = module.permissions.values.any((permission) => permission.allow == 1);

          if (hasAllowedPermission) {
            allowedModules.add(module.moduleName); // Add module name to allowedModules

            // Store the allowed permissions for this module
            List<String> permissions = [];
            module.permissions.forEach((key, permission) {
              if (permission.allow == 1) {
                permissions.add(permission.name); // Add allowed permission name to the list
              }
            });

            // Store the permissions in the modulePermissions map with the module name as the key
            if (permissions.isNotEmpty) {
              modulePermissions[module.moduleName] = permissions;
              print("Allowed permission: ${modulePermissions}");
            }
          }
        }

        // Define the custom order you want
        List<String> customOrder = [
          'Home',
          'Dashboard',
          'Transfer Money',
          'Request Money',
          'Payment Link',
          'Escrow History',
          'Support Ticket',
          'Transactions',
          'My Sub Accounts',
          'Managers',
          'Settings'
        ];

        // Reorder allowedModules based on the custom order
        allowedModules.sort((a, b) {
          int indexA = customOrder.indexOf(a);
          int indexB = customOrder.indexOf(b);

          // If module is in customOrder, prioritize its position; else keep it at the end
          if (indexA == -1) indexA = customOrder.length; // Modules not in customOrder will be placed last
          if (indexB == -1) indexB = customOrder.length;

          return indexA.compareTo(indexB);
        });
      } else {
        print("No modules data found or modules is not a list. Data: $jsonData");
      }
    } catch (e) {
      print("Error extracting allowed modules: $e");
      // Set default modules if extraction fails
      allowedModules.value = [
        'Home',
        'Dashboard',
        'Transfer Money',
        'Request Money',
        'Payment Link',
        'Escrow History',
        'Support Ticket',
        'Transactions',
        'Settings'
      ];
    }
  }

  void onPermissionUpdateNotification(String managerId) {
    final userProfileController = Get.find<UserProfileController>();
    if (managerId != null && managerId.isNotEmpty && userProfileController.isManager.value == '1') {
      fetchManagerPermissions(managerId).then((_) {
        print("Permissions updated successfully");
      }).catchError((error) {
        print("Failed to update permissions: $error");
      });
    }
  }

  // Printing allowed module names
  Future<bool> assignPermission(int permissionId, String managerId,
      int isAllow, BuildContext context) async {
    final url = Uri.parse('$baseUrl/api/assign_permission');
    String? token = await getToken();
    if (token == null) {
      throw Exception('Token is null');
    }
    print('Retrieved Token: $token');

    try {
      // Adding token in the headers for authorization
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          // Include token in the Authorization header
          'Content-Type': 'application/x-www-form-urlencoded',
          // Specify the content type
        },
        body: {
          'permission_id': permissionId.toString(),
          'manager_id': managerId,
          'is_allow': isAllow.toString(),
        },
      );

      // Log the response status code and body for debugging
      print("Response code: ${response.statusCode}");
      print("Response body: ${response.body}");

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Log the success status from the response
        print("API success: ${responseData['success']}");

        // Get the message from API response
        String apiMessage = responseData['message'] ?? 'Permission updated successfully!';

        // Show success Snackbar with API message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 3),
            content: Text(apiMessage),
            backgroundColor: Colors.green, // Green for success
            behavior: SnackBarBehavior
                .fixed, // To keep the Snackbar at the bottom
          ),
        );
        return responseData['success'] ??
            false; // Return true if success, false otherwise
      } else {
        print("API call failed with status code: ${response.statusCode}");

        // Show failure Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 3),
            content: Text('Failed to update permission.'),
            backgroundColor: Colors.red, // Red for failure
            behavior: SnackBarBehavior
                .fixed, // To keep the Snackbar at the bottom
          ),
        );
        return false; // Return false if status code is not 200
      }
    } catch (e) {
      // Catch any errors during the API call
      print("Error assigning permission: $e");

      // Show error Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 3),
          content: Text('An error occurred while updating permission.'),
          backgroundColor: Colors.red, // Red for error
          behavior: SnackBarBehavior
              .fixed, // To keep the Snackbar at the bottom
        ),
      );
      return false;
    }
  }


}

class ManagerPermission {
  final String pageTitle;
  final String managerId;
  final List<Module> modules;
  final List<String> permissions;

  ManagerPermission({
    required this.pageTitle,
    required this.managerId,
    required this.modules,
    required this.permissions,
  });

  factory ManagerPermission.fromJson(Map<String, dynamic> json) {
    return ManagerPermission(
      pageTitle: json['page_title'],
      managerId: json['manager_id'],
      modules: (json['modules'] as List)
          .map((module) => Module.fromJson(module))
          .toList(),
      permissions: List<String>.from(json['permissions'] ?? []),
    );
  }
}

class Module {
  final int id;
  final String moduleName;
  final String? fr; // French translation field
  final Map<String, Permission> permissions;

  Module({
    required this.id,
    required this.moduleName,
    this.fr,
    required this.permissions,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    // Parse the permissions map and return only allowed ones
    final permissions = (json['permissionss'] as Map<String, dynamic>).map(
          (key, value) {
        final permission = Permission.fromJson(value);
        return MapEntry(key, permission);
      },
    );

    return Module(
      id: json['id'],
      moduleName: json['module_name'],
      fr: json['fr'], // Parse the French translation field
      permissions: permissions,
    );
  }
}

class Permission {
  final int id;
  final String name;
  int allow;

  Permission({
    required this.id,
    required this.name,
    required this.allow,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'],
      name: json['name'],
      allow: json['allow'],
    );
  }

  // Static list of permission types (can be expanded if needed)
  static const List<String> permissionTypes = ["View", "Add", "Edit", "Delete"];
}




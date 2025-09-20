import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/common_header/common_header.dart';
import '../user_profile/user_profile_controller.dart';
import 'manager_permission_controller.dart';
import '../../controller/language_controller.dart';

class PermissionsScreen extends StatefulWidget {
  final String managerId;

  const PermissionsScreen({Key? key, required this.managerId}) : super(key: key);

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final ManagersPermissionController controller = Get.put(ManagersPermissionController());
  late Future<ManagerPermission> permissionsFuture;
  final UserProfileController userProfileController = Get.find<UserProfileController>();
  final LanguageController languageController = Get.find<LanguageController>();


  @override
  void initState() {
    super.initState();
    permissionsFuture = controller.fetchManagerPermissions(widget.managerId)
        .then((data) => ManagerPermission.fromJson(data['data']));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: languageController.getTranslation('permissions'),
        managerId: userProfileController.userId.value,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Fetch fresh data and update the future
          permissionsFuture = controller.fetchManagerPermissions(widget.managerId)
              .then((data) => ManagerPermission.fromJson(data['data']));
          // Trigger a rebuild by calling setState
          setState(() {});
        },
        child: FutureBuilder<ManagerPermission>(
          future: permissionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SpinKitFadingFour(
                  duration: Duration(seconds: 3),
                  size: 120,
                  color: Colors.green,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('${languageController.getTranslation('error')}: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text(languageController.getTranslation('no_data_available')));
            }

            final data = snapshot.data!;
            return Column(
              children: [
                Text(
                  languageController.getTranslation('assign_permission_to_manager'),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ).paddingOnly(top: 10),
                Container(
                  height: MediaQuery.of(context).size.height*.79,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0xffFFFFFF),
                  ),
                  child: ListView.builder(
                    itemCount: data.modules.length,
                    itemBuilder: (context, index) {
                      final module = data.modules[index];
                      return ExpansionTile(
                        title: Text(_getModuleDisplayName(module)),
                        children: module.permissions.entries.map((entry) {
                          final permission = entry.value;

                          // Skip delete permission for specific modules
                          if ((module.moduleName.toLowerCase().contains('support') ||
                               module.moduleName.toLowerCase().contains('deposits') ||
                               module.moduleName.toLowerCase().contains('withdrawals') ||
                               module.moduleName.toLowerCase().contains('settings')) && 
                              permission.name.toLowerCase().contains('delete')) {
                            return SizedBox.shrink(); // Return empty widget to hide this permission
                          }

                          // Determine the correct text to show based on permission name
                          String displayName = permission.name;

                          // Handle specific permission names
                          if (displayName == 'transfer_in') {
                            displayName = languageController.getTranslation('transfer_in');
                          } else if (displayName == 'transfer_out') {
                            displayName = languageController.getTranslation('transfer_out');
                          } else if (displayName.contains('view')) {
                            displayName = languageController.getTranslation('view');
                          } else if (displayName.contains('add')) {
                            displayName = languageController.getTranslation('add');
                          } else if (displayName.contains('edit')) {
                            displayName = languageController.getTranslation('edit');
                          } else if (displayName.contains('delete')) {
                            displayName = languageController.getTranslation('delete');
                          } else {
                            // Try to translate the permission name directly
                            String translation = languageController.getTranslation(displayName);
                            if (translation != displayName) {
                              displayName = translation;
                            }
                          }

                          return CheckboxListTile(
                            title: Text(displayName),
                            value: permission.allow == 1,
                            onChanged: (bool? value) async {
                              // Update local state immediately
                              setState(() {
                                permission.allow = value! ? 1 : 0;
                              });

                              // Make API call to assign the permission
                              bool success = await controller.assignPermission(
                                permission.id,
                                data.managerId,
                                permission.allow,
                                context,
                              );

                              if (!success) {
                                // If API call fails, revert the checkbox state
                                setState(() {
                                  permission.allow = permission.allow == 1 ? 0 : 1;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(languageController.getTranslation('failed_to_update_permission'))),
                                );
                              }
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                )
                    .paddingSymmetric(horizontal: 15, vertical: 15),
              ],
            );
          },
        ),
      ),

    ));
  }

  // Helper method to get the correct module display name based on current language
  String _getModuleDisplayName(Module module) {
    final currentLocale = languageController.getCurrentLanguageLocale();
    
    // Check if we have a French translation from the API
    if (currentLocale == 'fr' && module.fr?.isNotEmpty == true) {
      return module.fr!;
    }
    
    // Handle specific module names that need translation
    String moduleName = module.moduleName;
    if (moduleName == 'transfer_in') {
      return languageController.getTranslation('transfer_in');
    } else if (moduleName == 'transfer_out') {
      return languageController.getTranslation('transfer_out');
    }
    
    // For other modules, try to get translation or fall back to module name
    String translation = languageController.getTranslation(moduleName);
    if (translation != moduleName) {
      return translation;
    }
    
    return moduleName;
  }
}

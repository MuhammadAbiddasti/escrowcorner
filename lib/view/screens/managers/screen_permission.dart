import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../user_profile/user_profile_controller.dart';
import 'manager_permission_controller.dart';

class PermissionsScreen extends StatefulWidget {
  final String managerId;

  const PermissionsScreen({Key? key, required this.managerId}) : super(key: key);

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final ManagersPermissionController controller = Get.put(ManagersPermissionController());
  late Future<ManagerPermission> permissionsFuture;
  final UserProfileController userProfileController =Get.find<UserProfileController>();


  @override
  void initState() {
    super.initState();
    permissionsFuture = controller.fetchManagerPermissions(widget.managerId)
        .then((data) => ManagerPermission.fromJson(data['data']));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: Color(0xff191f28),
        title: AppBarTitle(),
        leading: CustomPopupMenu(managerId: userProfileController.userId.value,),
        actions: [
          PopupMenuButtonAction(),
          AppBarProfileButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchManagerPermissions(widget.managerId);
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
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No data available'));
            }

            final data = snapshot.data!;
            return Column(
              children: [
                Text(
                  "Assign Permission To Manager",
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
                        title: Text(module.moduleName),
                        children: module.permissions.entries.map((entry) {
                          final permission = entry.value;

                          // Determine the correct text to show based on permission name
                          String displayName = permission.name;

                          if (displayName.contains('view')) {
                            displayName = 'View';
                          } else if (displayName.contains('add')) {
                            displayName = 'Add';
                          } else if (displayName.contains('edit')) {
                            displayName = 'Edit';
                          } else if (displayName.contains('delete')) {
                            displayName = 'Delete';
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
                                  SnackBar(content: Text('Failed to update permission.')),
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

    );
  }
}

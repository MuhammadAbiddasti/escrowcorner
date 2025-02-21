import 'package:dacotech/view/screens/managers/controller_managers.dart';
import 'package:dacotech/view/screens/managers/screen_add_new_manager.dart';
import 'package:dacotech/view/screens/managers/screen_permission.dart';
import 'package:dacotech/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../controller/logo_controller.dart';
import '../user_profile/user_profile_controller.dart';
import 'manager_permission_controller.dart';

class ScreenManagers extends StatelessWidget {
  LogoController logoController = Get.put(LogoController());
  ManagersController controller = Get.put(ManagersController());
  final UserProfileController userProfileController =
      Get.find<UserProfileController>();
  final ManagersPermissionController permissionController =
      Get.find<ManagersPermissionController>();

  @override
  Widget build(BuildContext context) {
    final isManager = userProfileController.isManager.value == '1';
    final isNotManager = userProfileController.isManager.value == '0';
    final allowedModules = permissionController.modulePermissions;
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: Color(0xff0766AD),
        title: AppBarTitle(),
        leading: CustomPopupMenu(
          managerId: userProfileController.userId.value,
        ),
        actions: [
          PopupMenuButtonAction(),
          AppBarProfileButton(),
        ],
      ),
      body: Stack(children: [
        RefreshIndicator(
          onRefresh: () async {
            await controller.fetchManagers();
          },
          child: ListView(children: [
            Center(
              child: Column(
                children: [
                  //CustomBtcContainer().paddingOnly(top: 20),
                  // Container(
                  //   //height: MediaQuery.of(context).size.height * .2,
                  //   width: MediaQuery.of(context).size.width * 0.9,
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(10),
                  //     color: Color(0xffFFFFFF),
                  //   ),
                  //   child: Column(
                  //     children: [
                  //       CustomButton(
                  //           text: "ADD MANAGER",
                  //           onPressed: () {
                  //             Get.to(ScreenNewManager());
                  //           }).paddingSymmetric(horizontal: 20, vertical: 20)
                  //     ],
                  //   ),
                  // ).paddingOnly(top: 20),
                  if (isManager &&
                      allowedModules.containsKey('Managers') &&
                      allowedModules['Managers']!.contains('add_manager'))
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xffFFFFFF),
                      ),
                      child: Column(
                        children: [
                          CustomButton(
                            text: "ADD NEW",
                            onPressed: () {
                              Get.to(ScreenNewManager());
                            },
                          ).paddingSymmetric(horizontal: 20, vertical: 15),
                        ],
                      ),
                    ).paddingOnly(top: 20)
                  else if (isManager)
                    SizedBox(height: 50),
                  // Add some space when `add_send` is not allowed.
                  if (isNotManager)
                    Container(
                      //height: MediaQuery.of(context).size.height * .15,
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xffFFFFFF),
                      ),
                      child: Column(
                        children: [
                          CustomButton(
                            text: "ADD NEW",
                            onPressed: () {
                              Get.to(ScreenNewManager());
                            },
                          ).paddingSymmetric(horizontal: 20, vertical: 15)
                        ],
                      ),
                    ).paddingOnly(top: 20),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.57,
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xffFFFFFF),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "All Managers",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xff18CE0F),
                              fontFamily: 'Nunito'),
                        ).paddingOnly(top: 10),
                        Divider(
                          color: Color(0xffDDDDDD),
                        ),
                        Obx(() {
                          if (controller.isLoading.value) {
                            return Center(
                              child: SpinKitFadingFour(
                                duration: Duration(seconds: 3),
                                size: 120,
                                color: Colors.green,
                              ),
                            );
                          } else if (controller.errorMessage.isNotEmpty) {
                            return Center(child: Text("No Data Available"));
                          } else {
                            return Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight:
                                        MediaQuery.of(context).size.height,
                                  ),
                                  child: SingleChildScrollView(
                                    child: DataTable(
                                      columns: [
                                        DataColumn(label: Text('Sr No.')),
                                        DataColumn(label: Text('First Name')),
                                        DataColumn(label: Text('Last Name')),
                                        DataColumn(label: Text('Email')),
                                        DataColumn(label: Text('Phone Number')),
                                        DataColumn(label: Text('Created At')),
                                        DataColumn(label: Text('Action')),
                                        // Uncomment if you want to add an action column
                                      ],
                                      rows: controller.managersList
                                          .map((manager) {
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(
                                                '${controller.managersList.indexOf(manager) + 1}')),
                                            DataCell(Text(manager.firstName)),
                                            DataCell(Text(manager.lastName)),
                                            DataCell(Text(manager.email)),
                                            DataCell(Text(manager.phoneNumber)),
                                            DataCell(Text(
                                                '${DateFormat('dd-MM-yyyy   HH:mm a').format(DateTime.parse(manager.createdAt))}')),
                                            DataCell(
                                              Row(
                                                children: [
                                                  if (isManager &&
                                                      allowedModules
                                                          .containsKey(
                                                              'Managers') &&
                                                      allowedModules[
                                                              'Managers']!
                                                          .contains(
                                                              'edit_manager'))
                                                    Container(
                                                      height: 20,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.17,
                                                      child: OutlinedButton(
                                                        onPressed: () {
                                                          controller
                                                              .fetchManagerDetails(
                                                                  manager.id);
                                                        },
                                                        child: Text(
                                                          'Edit',
                                                          style: TextStyle(
                                                            fontSize: 7.0,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        style: OutlinedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.blue,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  else if (isManager)
                                                    Container(
                                                      height: 20,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.17,
                                                      child: OutlinedButton(
                                                        onPressed: () {
                                                          Get.snackbar(
                                                              "Message",
                                                              "You have no Permission ",
                                                              snackPosition:
                                                                  SnackPosition
                                                                      .BOTTOM,
                                                              backgroundColor:
                                                                  Colors.red,
                                                              colorText:
                                                                  Colors.white);
                                                        },
                                                        child: Text(
                                                          'Edit',
                                                          style: TextStyle(
                                                            fontSize: 7.0,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        style: OutlinedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.blue,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  // Add some space when `add_send` is not allowed.
                                                  if (isNotManager)
                                                    Container(
                                                      height: 20,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.17,
                                                      child: OutlinedButton(
                                                        onPressed: () {
                                                          controller
                                                              .fetchManagerDetails(
                                                                  manager.id);
                                                        },
                                                        child: Text(
                                                          'Edit',
                                                          style: TextStyle(
                                                            fontSize: 7.0,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        style: OutlinedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.blue,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  if (isManager &&
                                                      allowedModules
                                                          .containsKey(
                                                              'Managers') &&
                                                      allowedModules[
                                                              'Managers']!
                                                          .contains(
                                                              'delete_manager'))
                                                    Container(
                                                      height: 20,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.20,
                                                      child: OutlinedButton(
                                                        onPressed: () {
                                                          controller
                                                              .deleteManager(
                                                                  context,
                                                                  manager.id);
                                                        },
                                                        child: Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                            fontSize: 7.0,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        style: OutlinedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.red,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  else if (isManager)
                                                    Container(
                                                      height: 20,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.17,
                                                      child: OutlinedButton(
                                                        onPressed: () {
                                                          Get.snackbar(
                                                              "Message",
                                                              "You have no Permission ",
                                                              snackPosition:
                                                                  SnackPosition
                                                                      .BOTTOM,
                                                              backgroundColor:
                                                                  Colors.red,
                                                              colorText:
                                                                  Colors.white);
                                                        },
                                                        child: Text(
                                                          'Edit',
                                                          style: TextStyle(
                                                            fontSize: 7.0,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        style: OutlinedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.blue,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  // Add some space when `add_send` is not allowed.
                                                  if (isNotManager)
                                                    Container(
                                                      height: 20,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.20,
                                                      child: OutlinedButton(
                                                        onPressed: () {
                                                          showDeleteConfirmationDialog(context,
                                                              manager.id);
                                                        },
                                                        child: Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                            fontSize: 7.0,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        style: OutlinedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.red,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Container(
                                                    height: 20,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.24,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Get.to(PermissionsScreen(
                                                            managerId: manager
                                                                .id
                                                                .toString()));
                                                      },
                                                      child: Text(
                                                        'permission',
                                                        style: TextStyle(
                                                          fontSize: 7.0,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.grey,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        })
                      ],
                    ).paddingSymmetric(horizontal: 15),
                  ).paddingOnly(top: 15, bottom: 15),
                  CustomBottomContainer()
                ],
              ),
            ),
          ]),
        ),
        Align(alignment: Alignment.bottomCenter, child: CustomBottomContainer())
      ]),
    );
  }
  void showDeleteConfirmationDialog(BuildContext context, int managerId) {
    Get.defaultDialog(
      title: "",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, color: Colors.orange, size: 40),
          SizedBox(height: 10),
          Text(
            "Are you sure?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "You won’t be able to revert this",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        CustomButton(width: 95,
            text: "Cancel", onPressed: (){
              Get.back();
            }),
        CustomButton(width: 140,
          backGroundColor: Colors.red,
          text: "Yes, Delete it", onPressed: () {
            controller.deleteManager(
            context,
                managerId
            );
            Get.back();
          },
        )
      ],
    );
  }

}

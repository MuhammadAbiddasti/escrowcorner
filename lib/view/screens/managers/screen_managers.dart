import 'package:escrowcorner/view/screens/managers/controller_managers.dart';
import 'package:escrowcorner/view/screens/managers/screen_add_new_manager.dart';
import 'package:escrowcorner/view/screens/managers/screen_permission.dart';
import 'package:escrowcorner/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../controller/logo_controller.dart';
import '../user_profile/user_profile_controller.dart';
import 'manager_permission_controller.dart';
import '../../../widgets/common_header/common_header.dart';
import '../../controller/language_controller.dart';

class ScreenManagers extends StatelessWidget {
  LogoController logoController = Get.put(LogoController());
  ManagersController controller = Get.put(ManagersController());
  final UserProfileController userProfileController =
      Get.find<UserProfileController>();
  final ManagersPermissionController permissionController =
      Get.find<ManagersPermissionController>();
  final LanguageController languageController = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    final isManager = userProfileController.isManager.value == '1';
    final isNotManager = userProfileController.isManager.value == '0';
    final allowedModules = permissionController.modulePermissions;
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: Get.find<LanguageController>().getTranslation('managers'),
        managerId: userProfileController.userId.value,
      ),
      body: RefreshIndicator(
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
                //         borderRadius: BorderRadius.circular(10),
                //         color: Color(0xffFFFFFF),
                //   ),
                //   child: Column(
                //         children: [
                //           CustomButton(
                //               text: "ADD MANAGER",
                //               onPressed: () {
                //                 Get.to(ScreenNewManager());
                //               }).paddingSymmetric(horizontal: 20, vertical: 20)
                //         ],
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
                          text: languageController.getTranslation('add_new'),
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
                          text: languageController.getTranslation('add_new'),
                          onPressed: () {
                            Get.to(ScreenNewManager());
                          },
                        ).paddingSymmetric(horizontal: 20, vertical: 15)
                      ],
                    ),
                  ).paddingOnly(top: 20),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0xffFFFFFF),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                        languageController.getTranslation('all_managers'),
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xff18CE0F),
                            fontFamily: 'Nunito'),
                      )).paddingOnly(top: 10),
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
                          return Center(child: Obx(() => Text(languageController.getTranslation('no_data_available'))));
                        } else {
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.only(bottom: 25),
                              itemCount: controller.managersList.length,
                              separatorBuilder: (_, __) => SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final manager = controller.managersList[index];
                                return Card(
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Obx(() => Text(
                                              '${languageController.getTranslation('first_name')}: ',
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                            )),
                                            Expanded(
                                              child: Text(
                                                manager.firstName,
                                                style: TextStyle(fontSize: 12, color: Colors.black87),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Obx(() => Text(
                                              '${languageController.getTranslation('last_name')}: ',
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                            )),
                                            Expanded(
                                              child: Text(
                                                manager.lastName,
                                                style: TextStyle(fontSize: 12, color: Colors.black87),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Obx(() => Text(
                                              '${languageController.getTranslation('email')}: ',
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                            )),
                                            Expanded(
                                              child: Text(
                                                manager.email,
                                                style: TextStyle(fontSize: 12, color: Colors.black87),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Obx(() => Text(
                                              '${languageController.getTranslation('phone')}: ',
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                            )),
                                            Expanded(
                                              child: Text(
                                                manager.phoneNumber,
                                                style: TextStyle(fontSize: 12, color: Colors.black87),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Obx(() => Text(
                                              '${languageController.getTranslation('created_at')}: ',
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                            )),
                                            Expanded(
                                              child: Text(
                                                DateFormat('dd-MM-yyyy   HH:mm a').format(DateTime.parse(manager.createdAt)),
                                                style: TextStyle(fontSize: 12, color: Colors.black87),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            if (isManager &&
                                                allowedModules.containsKey('Managers') &&
                                                allowedModules['Managers']!.contains('edit_manager'))
                                              SizedBox(
                                                height: 28,
                                                child: OutlinedButton(
                                                  onPressed: () {
                                                    controller.fetchManagerDetails(manager.id);
                                                  },
                                                  style: OutlinedButton.styleFrom(
                                                    backgroundColor: Colors.blue,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                                  ),
                                                  child: Obx(() => Text(
                                                    languageController.getTranslation('edit'),
                                                    style: TextStyle(fontSize: 10, color: Colors.white),
                                                  )),
                                                ),
                                              )
                                            else if (isManager)
                                              SizedBox(
                                                height: 28,
                                                child: OutlinedButton(
                                                  onPressed: () {
                                                    Get.snackbar(
                                                      languageController.getTranslation('error'),
                                                      languageController.getTranslation('you_have_no_permission'),
                                                      snackPosition: SnackPosition.BOTTOM,
                                                      backgroundColor: Colors.red,
                                                      colorText: Colors.white,
                                                    );
                                                  },
                                                  style: OutlinedButton.styleFrom(
                                                    backgroundColor: Colors.blue,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                                  ),
                                                  child: Obx(() => Text(
                                                    languageController.getTranslation('edit'),
                                                    style: TextStyle(fontSize: 10, color: Colors.white),
                                                  )),
                                                ),
                                              ),
                                            if (isNotManager)
                                              SizedBox(
                                                height: 28,
                                                child: OutlinedButton(
                                                  onPressed: () {
                                                    controller.fetchManagerDetails(manager.id);
                                                  },
                                                  style: OutlinedButton.styleFrom(
                                                    backgroundColor: Colors.blue,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                                  ),
                                                  child: Obx(() => Text(
                                                    languageController.getTranslation('edit'),
                                                    style: TextStyle(fontSize: 10, color: Colors.white),
                                                  )),
                                                ),
                                              ),
                                            if (isManager &&
                                                allowedModules.containsKey('Managers') &&
                                                allowedModules['Managers']!.contains('delete_manager'))
                                              SizedBox(
                                                height: 28,
                                                child: OutlinedButton(
                                                  onPressed: () {
                                                    controller.deleteManager(context, manager.id);
                                                  },
                                                  style: OutlinedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                                  ),
                                                  child: Obx(() => Text(
                                                    languageController.getTranslation('delete'),
                                                    style: TextStyle(fontSize: 10, color: Colors.white),
                                                  )),
                                                ),
                                              )
                                            else if (isManager)
                                              SizedBox(
                                                height: 28,
                                                child: OutlinedButton(
                                                  onPressed: () {
                                                    Get.snackbar(
                                                      languageController.getTranslation('error'),
                                                      languageController.getTranslation('you_have_no_permission'),
                                                      snackPosition: SnackPosition.BOTTOM,
                                                      backgroundColor: Colors.red,
                                                      colorText: Colors.white,
                                                    );
                                                  },
                                                  style: OutlinedButton.styleFrom(
                                                    backgroundColor: Colors.blue,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                                  ),
                                                  child: Obx(() => Text(
                                                    languageController.getTranslation('edit'),
                                                    style: TextStyle(fontSize: 10, color: Colors.white),
                                                  )),
                                                ),
                                              ),
                                            if (isNotManager)
                                              SizedBox(
                                                height: 28,
                                                child: OutlinedButton(
                                                  onPressed: () {
                                                    showDeleteConfirmationDialog(context, manager.id);
                                                  },
                                                  style: OutlinedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                                  ),
                                                  child: Obx(() => Text(
                                                    languageController.getTranslation('delete'),
                                                    style: TextStyle(fontSize: 10, color: Colors.white),
                                                  )),
                                                ),
                                              ),
                                            SizedBox(
                                              height: 28,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Get.to(PermissionsScreen(managerId: manager.id.toString()));
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.grey,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                                ),
                                                child: Obx(() => Text(
                                                  languageController.getTranslation('permission'),
                                                  style: TextStyle(fontSize: 10, color: Colors.white),
                                                )),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                          );
                        }
                      })
                    ],
                  ).paddingSymmetric(horizontal: 15),
                ).paddingOnly(top: 15, bottom: 15),
              ],
            ),
          ),
        ]),
      ),
              bottomNavigationBar: CustomBottomContainerPostLogin(),
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
          Obx(() => Text(
            languageController.getTranslation('are_you_sure'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          )),
          SizedBox(height: 8),
          Obx(() => Text(
            languageController.getTranslation('you_will_not_be_able_to_revert_this'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          )),
        ],
      ),
      actions: [
        CustomButton(width: 95,
            text: languageController.getTranslation('cancel'), onPressed: (){
              Get.back();
            }),
        CustomButton(width: 140,
          backGroundColor: Colors.red,
          text: languageController.getTranslation('yes') + ', ' + languageController.getTranslation('delete_it'), onPressed: () {
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

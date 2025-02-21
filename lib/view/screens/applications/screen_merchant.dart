import 'package:dacotech/view/screens/applications/screen_add_merchant.dart';
import 'package:dacotech/view/screens/applications/screen_merchant_integration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../controller/logo_controller.dart';
import '../managers/manager_permission_controller.dart';
import '../user_profile/user_profile_controller.dart';
import 'merchant_controller.dart';

class ScreenMerchant extends StatelessWidget {
  final LogoController logoController = Get.put(LogoController());
  final MerchantController controller = Get.put(MerchantController());
  final UserProfileController userProfileController =Get.find<UserProfileController>();
  final ManagersPermissionController permissionController =Get.find<ManagersPermissionController>();

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
        leading: CustomPopupMenu(managerId: userProfileController.userId.value,),
        actions: [
          PopupMenuButtonAction(),
          AppBarProfileButton(),
        ],
      ),
      body: Stack(
        children:[
          RefreshIndicator(
          onRefresh: () async {
            await controller.fetchMerchants();
          },
          child: ListView(
            children:[
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
                  //         text: "ADD APPLICATION",
                  //         onPressed: () {
                  //           if (controller.merchants.length >= 1) {
                  //             Get.snackbar(
                  //               'Error',
                  //               'There is a limit to creating applications. You cannot create more than 1 application.',
                  //               snackPosition: SnackPosition.BOTTOM,
                  //               backgroundColor: Colors.red,
                  //               colorText: Colors.white,
                  //             );
                  //           } else {
                  //             Get.to(ScreenAddMerchant());
                  //           }
                  //         },
                  //       ).paddingSymmetric(horizontal: 20, vertical: 10),
                  //     ],
                  //   ),
                  // ).paddingOnly(top: 20),
                  if (isManager &&
                      allowedModules.containsKey('My Application') &&
                      allowedModules['My Application']!.contains('add_application'))
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xffFFFFFF),
                      ),
                      child: Column(
                        children: [
                          CustomButton(
                            text: "ADD APPLICATION",
                            onPressed: () {
                              if (controller.merchants.length >= 1) {
                                Get.snackbar(
                                  'Error',
                                  'There is a limit to creating applications. You cannot create more than 1 application.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              } else {
                                Get.to(ScreenAddMerchant());
                              }
                            },
                          ).paddingSymmetric(horizontal: 20, vertical: 10),
                        ],
                      ),
                    ).paddingOnly(top: 20)
                  else if (isManager)
                    SizedBox(height: 50), // Add some space when `add_send` is not allowed.
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
                            text: "ADD APPLICATION",
                            onPressed: () {
                              if (controller.merchants.length >= 1) {
                                Get.snackbar(
                                  'Error',
                                  'There is a limit to creating applications. You cannot create more than 1 application.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              } else {
                                Get.to(ScreenAddMerchant());
                              }
                            },
                          ).paddingSymmetric(horizontal: 20, vertical: 10),
                        ],
                      ),
                    ).paddingOnly(top: 20),
                  Container(
                    height: MediaQuery.of(context).size.height * .58,
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xffFFFFFF),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "All Application",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xff18CE0F),
                            fontFamily: 'Nunito',
                          ),
                        ),
                        Divider(color: Color(0xffDDDDDD)),
                        Expanded(
                          child: Obx(() {
                            print("Merchant: ${controller.merchants.length}");
                            if (controller.isLoading.value) {
                              return Center(child: SpinKitFadingFour(
                                duration: Duration(seconds: 3),
                                size: 120,
                                color: Colors.green,
                              ),);
                            } else {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SingleChildScrollView(
                                  child: DataTable(
                                    columns: [
                                      DataColumn(label: Text('#')),
                                      DataColumn(label: Text('Logo')),
                                      DataColumn(label: Text('Application Name')),
                                      DataColumn(label: Text('Webhook URL')),
                                      DataColumn(label: Text('Website URL')),
                                      DataColumn(label: Text('')),
                                    ],
                                    rows: controller.merchants.isEmpty
                                        ? [
                                      DataRow(cells: [
                                        DataCell(Text('')),
                                        DataCell(Text('')),
                                        DataCell(Text('')),
                                        DataCell(Text('')),
                                        DataCell(Text('')),
                                        DataCell(Text('')),
                                      ]),
                                    ]
                                        : controller.merchants.map((merchant) {
                                      return DataRow(cells: [
                                        DataCell(Text('${controller.merchants.indexOf(merchant) + 1}')),
                                        DataCell(
                                          merchant.logo.isNotEmpty
                                              ? Image.network(
                                            merchant.logo,
                                            height: 40,
                                            width: 40,
                                            errorBuilder: (context, error, stackTrace) {
                                              // Fallback to text if the image fails to load
                                              return Row(
                                                children: [
                                                  Icon(Icons.broken_image,color: Colors.black,),
                                                  Text('  Merchant Logo'),
                                                ],
                                              );
                                            },
                                          )
                                              : Text('No Logo'),
                                        ),

                                        DataCell(Text(merchant.name)),
                                        DataCell(Text(merchant.webhookUrl)),
                                        DataCell(
                                          Text(
                                            merchant.siteUrl,
                                            style: TextStyle(color: Colors.green),
                                          ),
                                        ),
                                        DataCell(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomButton(backGroundColor: Colors.blue,
                                              height: 35,
                                              width: MediaQuery.of(context).size.width * .5,
                                              onPressed: () {
                                                Get.to(ScreenMerchantIntegration(
                                                  merchantId: merchant.id.toString(),
                                                ));
                                              },
                                              text: "Integration Guide",
                                            ),
                                            SizedBox(width: 10,),
                                            CustomButton(
                                              height: 35,
                                              width: MediaQuery.of(context).size.width * .25,
                                              onPressed: () {
                                                Get.snackbar('Message', 'Please Contact support to Update the application',
                                                  snackPosition: SnackPosition.BOTTOM,
                                                  backgroundColor: Colors.red,
                                                  colorText: Colors.white,
                                                );
                                              },
                                              text: "Edit",
                                            ),
                                          ],
                                        )),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                              );
                            }
                          }),
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 15),
                  ).paddingOnly(top: 20, bottom: 20),
                ],
              ),
            ),]
          ),
        ),
          Align(
              alignment: Alignment.bottomCenter,
              child: CustomBottomContainer()
          )
        ]
      ),
    );
  }
}

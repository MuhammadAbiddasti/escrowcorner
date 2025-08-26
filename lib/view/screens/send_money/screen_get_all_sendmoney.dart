import 'package:escrowcorner/view/screens/send_money/controller_sendmoney.dart';
import 'package:escrowcorner/view/screens/send_money/screen_sendmoney.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../controller/logo_controller.dart';
import '../managers/manager_permission_controller.dart';
import '../user_profile/user_profile_controller.dart';

class ScreenGetAllSendMoney extends StatelessWidget {
  LogoController logoController = Get.put(LogoController());
  SendMoneyController sendMoneyController = Get.put(SendMoneyController());
  final UserProfileController userProfileController =
      Get.put(UserProfileController());
  final ManagersPermissionController controller =
      Get.put(ManagersPermissionController());

  @override
  void initState() {
    //super.initState();
    // Fetch escrows only once when the screen is initialized
    sendMoneyController.sendMoneyList();
  }

  void onInit() {
    sendMoneyController.sendMoneyList();
  }

  @override
  Widget build(BuildContext context) {
    final refresh = Get.arguments?['refresh'] ?? false;
    if (refresh) {
      // Call method to refresh merchant list
      sendMoneyController.fetchAllSendMoney();
    }
    final isManager = userProfileController.isManager.value == '1';
    final isNotManager = userProfileController.isManager.value == '0';
    final allowedModules = controller.modulePermissions;
    return Scaffold(
        backgroundColor: Color(0xffE6F0F7),
              appBar: AppBar(
        backgroundColor: Color(0xff191f28),
          title: AppBarTitle(),
          leading: CustomPopupMenu(
            managerId: userProfileController.userId.value,
          ),
          actions: [
            PopupMenuButtonAction(),
            AppBarProfileButton(),
          ],
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              await sendMoneyController.fetchAllSendMoney();
            },
            child: ListView(children: [
              Center(
                child: Column(
                  children: [
                    //CustomBtcContainer().paddingOnly(top: 20),
                    if (isManager &&
                        allowedModules.containsKey('Transfer Money') &&
                        allowedModules['Transfer Money']!.contains('add_send'))
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
                                Get.to(ScreenSendMoney());
                              },
                            ).paddingSymmetric(horizontal: 20, vertical: 15),
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
                              text: "ADD NEW",
                              onPressed: () {
                                Get.to(ScreenSendMoney());
                              },
                            ).paddingSymmetric(horizontal: 20, vertical: 15)
                          ],
                        ),
                      ).paddingOnly(top: 20),
                    Container(
                      height: MediaQuery.of(context).size.height * .59,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xffFFFFFF),
                      ),
                      child: Column(
                        children: [
                          // Header Title
                          Text(
                            "Transfer Money",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xff18CE0F),
                              fontFamily: 'Nunito',
                            ),
                          ),
                          Divider(color: Color(0xffDDDDDD)),

                          // Data Table or Loading/Empty State
                          Expanded(
                            child: Obx(() {
                              if (sendMoneyController.isLoading.value) {
                                return Center(
                                  child: SpinKitFadingFour(
                                    duration: Duration(seconds: 3),
                                    size: 120,
                                    color: Colors.green,
                                  ),
                                );
                              } else if (sendMoneyController
                                  .sendMoneyList.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No data available',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              } else {
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SingleChildScrollView(
                                    child: DataTable(
                                      columns: const [
                                        DataColumn(label: Text('S.NO')),
                                        DataColumn(label: Text('DateTime')),
                                        DataColumn(
                                            label: Text('Transfer By')),
                                        DataColumn(
                                            label: Text('Transfer To')),
                                        DataColumn(
                                            label: Text('Description')),
                                        DataColumn(label: Text('Status')),
                                        DataColumn(label: Text('Currency')),
                                        DataColumn(label: Text('Amount')),
                                      ],
                                      rows: sendMoneyController.sendMoneyList
                                          .map((sendMoney) {
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(
                                              '${sendMoneyController.sendMoneyList.indexOf(sendMoney) + 1}',
                                            )),
                                            DataCell(Text(
                                              DateFormat(
                                                      'yyyy-MM-dd   HH:mm a')
                                                  .format(DateTime.parse(
                                                      sendMoney.dateTime)),
                                            )),
                                            DataCell(
                                                Text(sendMoney.transferBy)),
                                            DataCell(
                                                Text(sendMoney.transferTo)),
                                            DataCell(
                                                Text(sendMoney.description)),
                                            DataCell(Text(sendMoney.status)),
                                            DataCell(
                                                Text(sendMoney.currency)),
                                            DataCell(Text(
                                              double.parse(sendMoney.amount)
                                                  .toStringAsFixed(2),
                                            )),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              }
                            }),
                          ),
                          // Pagination Controls
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(vertical: 8.0),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       IconButton(
                          //         icon: Icon(Icons.arrow_back),
                          //         onPressed: sendMoneyController.hasPreviousPage.value
                          //             ? () {
                          //           print("Going to previous page...");
                          //           sendMoneyController.fetchAllSendMoney(page: sendMoneyController.currentPage.value - 1);
                          //         }
                          //             : null,
                          //       ),
                          //       Obx(() => Text(
                          //         'Page ${sendMoneyController.currentPage.value} of ${sendMoneyController.totalPages.value}',
                          //         style: TextStyle(
                          //           fontWeight: FontWeight.bold,
                          //           fontSize: 14,
                          //         ),
                          //       )),
                          //       IconButton(
                          //         icon: Icon(Icons.arrow_forward),
                          //         onPressed: sendMoneyController.hasNextPage.value
                          //             ? () {
                          //           print("Going to next page...");
                          //           sendMoneyController.fetchAllSendMoney(page: sendMoneyController.currentPage.value + 1);
                          //         }
                          //             : null,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    ).paddingSymmetric(horizontal: 15, vertical: 10),
                  ],
                ),
              ),
            ]),
        ),
        bottomNavigationBar: CustomBottomContainerPostLogin(),
    );
  }
}

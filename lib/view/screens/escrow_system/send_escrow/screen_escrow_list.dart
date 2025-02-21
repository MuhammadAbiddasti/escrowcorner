import 'package:dacotech/view/screens/escrow_system/send_escrow/screen_create_escrow.dart';
import 'package:dacotech/view/screens/escrow_system/send_escrow/send_escrow_controller.dart';
import 'package:dacotech/view/screens/escrow_system/send_escrow/send_escrow_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../../widgets/custom_button/custom_button.dart';
import '../../managers/manager_permission_controller.dart';
import '../../user_profile/user_profile_controller.dart';

class ScreenEscrowList extends StatefulWidget {
  @override
  _ScreenEscrowListState createState() => _ScreenEscrowListState();
}

class _ScreenEscrowListState extends State<ScreenEscrowList> {
  //final ReceivedEscrowsController controller = Get.put(ReceivedEscrowsController());
  final SendEscrowsController controller = Get.put(SendEscrowsController());
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
  final UserProfileController userProfileController =Get.find<UserProfileController>();
  final ManagersPermissionController permissionController =Get.find<ManagersPermissionController>();
 initState() {
    super.initState();
    if (!Get.isRegistered<SendEscrowsController>()) {
      Get.put(SendEscrowsController());
    }
    controller.fetchSendEscrows();
  }


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
            controller.fetchSendEscrows();
          },
          child: ListView(
            children: [
              Column(
              children: [
                // Container(
                //   width: MediaQuery.of(context).size.width * 0.9,
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(10),
                //     color: Color(0xffFFFFFF),
                //   ),
                //   child: CustomButton(
                //     text: "ADD New Escrow",
                //     onPressed: () {
                //       Get.to(ScreenCreateEscrow());
                //     },
                //   ).paddingSymmetric(horizontal: 20, vertical: 10),
                // ).paddingOnly(top: 20),
                if (isManager &&
                    allowedModules.containsKey('Send Escrow') &&
                    allowedModules['Send Escrow']!.contains('add_send_escrow'))
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xffFFFFFF),
                    ),
                    child: Column(
                      children: [
                        CustomButton(
                          text: "ADD New Escrow",
                          onPressed: () {
                            Get.to(ScreenCreateEscrow());
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
                          text: "ADD New Escrow",
                          onPressed: () {
                            Get.to(ScreenCreateEscrow());
                          },
                        ).paddingSymmetric(horizontal: 20, vertical: 15)
                      ],
                    ),
                  ).paddingOnly(top: 20),
                Container(
                  height: MediaQuery.of(context).size.height * 0.59,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0xffFFFFFF),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Escrow",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xff18CE0F),
                          fontFamily: 'Nunito',
                        ),
                      ).paddingOnly(top: 10),
                      Divider(color: Color(0xffDDDDDD)),
                      Obx(() {
                        if (controller.isLoading.value) {
                          return Center(child:SpinKitFadingFour(
                            duration: Duration(seconds: 3),
                            size: 120,
                            color: Colors.green,
                          ));
                        } else if (controller.escrows.isEmpty) {
                          return Center(child: Text("No Escrows Available"));
                        } else {
                          return Expanded(
                            flex: 8,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                child: DataTable(
                                  columns: const [
                                    //DataColumn(label: Text('Sr No.')),
                                    DataColumn(label: Text('Action')),
                                    DataColumn(label: Text('From')),
                                    DataColumn(label: Text('To')),
                                    DataColumn(label: Text('Amount')),
                                    DataColumn(label: Text('Status')),
                                    DataColumn(label: Text('Started at')),

                                  ],
                                  rows: List<DataRow>.generate(
                                    controller.escrows.length,
                                        (index) {
                                      final escrow = controller.escrows[index];
                                      return DataRow(
                                        cells: [
                                          //DataCell(Text('${index + 1}')),
                                          DataCell(
                                            CustomButton(
                                              width: 80,
                                              height: 30,
                                              text: 'View',
                                              onPressed: () async {
                                               controller.fetchEscrowDetail(escrow.id);
                                               await Future.delayed(Duration(milliseconds: 500));
                                               Get.to(() =>SendEscrowDetailScreen(escrowId: escrow.id,));
                                              },
                                            ),
                                          ),
                                          DataCell(Text(escrow.userId.toString())),
                                          DataCell(Text(escrow.to.toString())),
                                          DataCell(Text(
                                            '${escrow.currencySymbol} ${double.tryParse(escrow.gross.toString())?.toStringAsFixed(3) ?? '0.000'}',
                                          )),

                                          DataCell(Text(
                                            escrow.statusLabel.toString(),
                                          )),
                                          DataCell(Text(formatter.format(escrow.createdAt))),

                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      }),
                    ],
                  ).paddingSymmetric(horizontal: 15),
                ).paddingOnly(top: 20, bottom: 15),

              ],
            ),
      ]
          ),
        ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomContainer()
          )
        ],
      ),
    );
  }
}


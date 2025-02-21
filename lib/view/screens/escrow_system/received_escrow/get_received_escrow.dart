import 'package:dacotech/view/screens/escrow_system/received_escrow/received_escrow_controller.dart';
import 'package:dacotech/view/screens/escrow_system/send_escrow/send_escrow_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../../widgets/custom_button/custom_button.dart';
import '../../user_profile/user_profile_controller.dart';
import '../send_escrow/send_escrow_detail.dart';


class ScreenReceivedEscrow extends StatefulWidget {
  @override
  _ScreenEscrowListState createState() => _ScreenEscrowListState();
}

class _ScreenEscrowListState extends State<ScreenReceivedEscrow> {
  final ReceivedEscrowsController controller = Get.put(ReceivedEscrowsController());
  final SendEscrowsController sendController = Get.put(SendEscrowsController());
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
  final UserProfileController userProfileController =Get.find<UserProfileController>();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ReceivedEscrowsController>()) {
      Get.put(ReceivedEscrowsController());
    }
    controller.fetchReceiverEscrows();
  }


  @override
  Widget build(BuildContext context) {
    controller.fetchReceiverEscrows();
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
            await controller.fetchReceiverEscrows();
          },
          child: ListView(
            children:[
              Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.69,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0xffFFFFFF),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Received Escrow",
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
                          return Center(child: SpinKitFadingFour(
                            duration: Duration(seconds: 3),
                            size: 120,
                            color: Colors.green,
                          ));
                        } else if (controller.receiverEscrows.isEmpty) {
                          return Center(child: Text("No Received Escrows Available"));
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
                                    controller.receiverEscrows.length,
                                        (index) {
                                      final receivedEscrow = controller.receiverEscrows[index];
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            CustomButton(
                                              width: 80,
                                              height: 30,
                                              text: 'View',
                                              onPressed: () async {
                                                sendController.fetchEscrowDetail(receivedEscrow.id);
                                                await Future.delayed(Duration(milliseconds: 500)); // Add a delay of 500ms
                                                Get.to(() =>SendEscrowDetailScreen(escrowId: receivedEscrow.id));
                                              },
                                            ),
                                          ),
                                          DataCell(Text(receivedEscrow.email.toString())),
                                          DataCell(Text(receivedEscrow.to.toString())),
                                          DataCell(Text(
                                            double.tryParse(receivedEscrow.gross)?.toStringAsFixed(3) ?? '0.000',
                                          )),
                                          DataCell(Text(
                                            receivedEscrow.statusLabel.toString(),
                                          )),
                                          DataCell(Text(formatter.format(receivedEscrow.createdAt))),
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
                      // Add the Row for the pagination buttons here
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 10),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       IconButton(
                      //         icon: Icon(Icons.arrow_back),
                      //         onPressed: controller.receivedHasPreviousPage ? controller.previousPage : null,
                      //       ),
                      //       IconButton(
                      //         icon: Icon(Icons.arrow_forward),
                      //         onPressed: controller.receivedHasNextPage ? controller.nextPage : null,
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ).paddingSymmetric(horizontal: 15),
                ).paddingOnly(top: 20, bottom: 15),
                Container(height: 50),
              ],
            ),
      ]
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
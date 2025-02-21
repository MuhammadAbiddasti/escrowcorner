import 'package:dacotech/view/screens/escrow_system/get_requested_escrow/requested_escrow_controller.dart';
import 'package:dacotech/view/screens/escrow_system/request_escrow/request_escrow_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../../widgets/custom_button/custom_button.dart';
import '../../user_profile/user_profile_controller.dart';
import '../request_escrow/request_escrow_detail.dart';

class GetRequestedEscrow extends StatefulWidget {
  const GetRequestedEscrow({super.key});

  @override
  State<GetRequestedEscrow> createState() => _GetRequestedEscrowState();
}

class _GetRequestedEscrowState extends State<GetRequestedEscrow> {
  final RequestedEscrowController controller = Get.put(RequestedEscrowController());
  final RequestEscrowController requestController = Get.put(RequestEscrowController());
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
  final UserProfileController userProfileController =Get.find<UserProfileController>();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<RequestEscrowController>()) {
      Get.put(RequestEscrowController());
    }
    controller.fetchRequestedEscrows();
  }
  @override

  Widget build(BuildContext context) {
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
        children: [
          RefreshIndicator(
          onRefresh: () async {
            await controller.fetchRequestedEscrows();
          },
          child: ListView(
            children: [
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
                          "Requested Escrow",
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
                          } else if (controller.requestEscrows.isEmpty) {
                            return Center(child: Text("No Request Escrows Available"));
                          } else {
                            return Expanded(
                              flex: 8,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SingleChildScrollView(
                                  child: DataTable(
                                    columns: const [
                                      // DataColumn(label: Text('Sr No.')),
                                      DataColumn(label: Text('Action')),
                                      DataColumn(label: Text('From')),
                                      DataColumn(label: Text('To')),
                                      DataColumn(label: Text('Amount')),
                                      DataColumn(label: Text('Status')),
                                      DataColumn(label: Text('Started at')),

                                    ],
                                    rows: List<DataRow>.generate(
                                      controller.requestEscrows.length,
                                          (index) {
                                        final requestEscrow = controller.requestEscrows[index];
                                        return DataRow(
                                          cells: [
                                            //DataCell(Text('${index + 1}')),
                                            DataCell(
                                              CustomButton(
                                                width: 80,
                                                height: 30,
                                                text: 'View',
                                                onPressed: () async {
                                                  Get.to(RequestEscrowDetailScreen(escrowId: requestEscrow.id,));
                                                  await Future.delayed(Duration(milliseconds: 500)); // Add a delay of 500ms
                                                  requestController.fetchRequestEscrowDetail(requestEscrow.id);
                                                },
                                              ),
                                            ),
                                            DataCell(Text(requestEscrow.userId.toString())),
                                            DataCell(Text(requestEscrow.to.toString())),
                                            DataCell(Text(
                                              double.tryParse(requestEscrow.gross)?.toStringAsFixed(3) ?? '0.000',
                                            )),
                                            DataCell(Text(
                                              requestEscrow.statusLabel.toString(),
                                            )),
                                            DataCell(Text(formatter.format(requestEscrow.createdAt))),

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
                      ]
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
    ]
      ),
    );
  }
}

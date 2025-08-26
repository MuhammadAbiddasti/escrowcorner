import 'package:escrowcorner/view/screens/deposit/mydeposit_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_ballance_container/custom_btc_container.dart';
import '../../controller/get_controller.dart';
import '../../controller/logo_controller.dart';
import '../user_profile/user_profile_controller.dart';

class ScreenMyDeposit extends StatelessWidget {
  final LogoController logoController = Get.put(LogoController());
  final MyDepositsController myDepositsController = Get.put(MyDepositsController());
  final InfoController infoController = Get.put(InfoController());
  final UserProfileController userProfileController =Get.find<UserProfileController>();

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
      body: Stack(
        children:[
          RefreshIndicator(
          onRefresh: () async{
            await myDepositsController.fetchMyDeposits();
          },
          child: ListView(
            children:[
              Center(
              child: Column(
                children: [
                  //CustomBtcContainer().paddingOnly(top: 20),
                  Container(
                    height: MediaQuery.of(context).size.height*0.70,
                    width: MediaQuery.of(context).size.width*0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xffFFFFFF),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "My Deposits",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xff18CE0F),
                              fontFamily: 'Nunito'),).paddingOnly(top: 10),
                        Divider(color: Color(0xffDDDDDD),),
                        Obx(() {
                          if (myDepositsController.isLoading.value) {
                            return Center(child: SpinKitFadingFour(
                              duration: Duration(seconds: 3),
                              size: 120,
                              color: Colors.green,
                            ));
                          } else if(myDepositsController.mydeposits.isEmpty){
                            return Center(child: buildInfoContainer(infoController));
                          } else {
                            return Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: MediaQuery
                                        .of(context)
                                        .size
                                        .height,
                                  ),
                                  child: SingleChildScrollView(
                                    child: DataTable(
                                      columns: [
                                        DataColumn(label: Text('Sr No.')),
                                        DataColumn(label: Text('Date Time')),
                                        DataColumn(label: Text('Transaction ID')),
                                        DataColumn(label: Text('Method')),
                                        DataColumn(label: Text('Currency')),
                                        DataColumn(label: Text('Gross')),
                                        DataColumn(label: Text('Fee')),
                                        DataColumn(label: Text('Net')),
                                        DataColumn(label: Text('Status')),
                                      ],
                                      rows: myDepositsController.mydeposits
                                          .map((mydeposits) {
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(
                                                '${myDepositsController.mydeposits
                                                    .indexOf(mydeposits) + 1}')),
                                            DataCell(Text('${DateFormat(
                                                'yyyy-MM-dd  HH:mm a').format(
                                                DateTime.parse(
                                                    mydeposits.dateTime))}')),
                                            DataCell(
                                                Text(mydeposits.transactionId)),
                                            DataCell(Text(mydeposits.method)),
                                            DataCell(Text(mydeposits.currency)),
                                            DataCell(Text(mydeposits.gross)),
                                            DataCell(Text(mydeposits.fee)),
                                            DataCell(Text(mydeposits.net)),
                                            DataCell(
                                              Container(
                                                height: 28,
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width * 0.25,
                                                child: OutlinedButton(
                                                  onPressed: () {},
                                                  child: Text(
                                                    mydeposits.status.name,
                                                    style: TextStyle(
                                                      fontSize: 8,
                                                      color: mydeposits.status
                                                          .name.toLowerCase() ==
                                                          'completed'
                                                          ? Color(
                                                          0xff18CE0F) // Green color for completed status
                                                          : mydeposits.status.name
                                                          .toLowerCase() ==
                                                          'pending'
                                                          ? Color(
                                                          0xff1E90FF) // Blue color for pending status
                                                          : Color(
                                                          0xff18CE0F), // Default color (or use a different default color)
                                                    ),
                                                  ),
                                                  style: OutlinedButton.styleFrom(
                                                    side: BorderSide(
                                                      color: mydeposits.status
                                                          .name.toLowerCase() ==
                                                          'completed'
                                                          ? Color(
                                                          0xff18CE0F) // Green border for completed status
                                                          : mydeposits.status.name
                                                          .toLowerCase() ==
                                                          'pending'
                                                          ? Color(
                                                          0xff1E90FF) // Blue border for pending status
                                                          : Color(
                                                          0xff18CE0F), // Default border color
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius
                                                          .circular(5.0),
                                                    ),
                                                  ),
                                                ),
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
                        }),
                      ],
                    ).paddingSymmetric(horizontal: 15),
                  ).paddingOnly(top: 15,bottom: 20),
                ],
              ),
            ),]
          ),
        ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomContainerPostLogin()
          )
        ]
      ),
    );
  }

  Widget buildInfoContainer(InfoController infoController) {
    return Container(
      height: Get.height * .17,
      width: Get.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Color(0xff2CA8FF),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.white,
                size: 30,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "Info",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Nunito"),
              ),
            ],
          ),
          Text(
            "Your account is Fresh and New !",
            style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                fontFamily: "Nunito"),
          ),
          Text(
            "Start by requesting money from friends or by selling"
                " online and collecting payments in your wallet.",
            style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: "Nunito"),
          ),
        ],
      ).paddingSymmetric(horizontal: 10),
    ).paddingSymmetric(horizontal: 15, vertical: 10);
  }
}

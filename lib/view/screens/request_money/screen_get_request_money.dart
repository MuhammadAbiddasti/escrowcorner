import 'package:escrowcorner/view/screens/request_money/controller_requestmoney.dart';
import 'package:escrowcorner/view/screens/request_money/screen_new_requestmoney.dart';
import 'package:escrowcorner/view/screens/user_profile/user_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_ballance_container/custom_btc_container.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../controller/logo_controller.dart';
import '../managers/manager_permission_controller.dart';
import 'screen_request_money_otp.dart';

class ScreenGetRequestMonay extends StatelessWidget {
  LogoController logoController = Get.put(LogoController());
  RequestMoneyController requestMoneyController =
      Get.put(RequestMoneyController());
  UserProfileController controller = Get.find<UserProfileController>();
  final ManagersPermissionController permissionController =
  Get.find<ManagersPermissionController>();
  void initState() {
    //super.initState();
    // Fetch escrows only once when the screen is initialized
    requestMoneyController.fetchAllRequestMoney();
  }

  void onInit() {
    requestMoneyController.fetchAllRequestMoney();
  }

  @override
  Widget build(BuildContext context) {
    final isManager = controller.isManager.value == '1';
    final isNotManager = controller.isManager.value == '0';
    final allowedModules = permissionController.modulePermissions;
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: Color(0xff191f28),
        title: AppBarTitle(),
        leading: CustomPopupMenu(managerId: controller.userId.value,),
        actions: [
          PopupMenuButtonAction(),
          AppBarProfileButton(),
        ],
      ),
      body: Stack(
        children:[
          RefreshIndicator(
          onRefresh: () async {
            await requestMoneyController.fetchAllRequestMoney();
          },
          child: ListView(
            children:[
              Center(
              child: Column(
                children: [
                  //CustomBtcContainer().paddingOnly(top: 20),
                  // Container(
                  //   //height: MediaQuery.of(context).size.height * .15,
                  //   width: MediaQuery.of(context).size.width * 0.9,
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(10),
                  //     color: Color(0xffFFFFFF),
                  //   ),
                  //   child: Column(
                  //     children: [
                  //       CustomButton(
                  //           text: "ADD NEW",
                  //           onPressed: () {
                  //             Get.to(ScreenNewRequestMoney());
                  //           }).paddingSymmetric(horizontal: 20, vertical: 15)
                  //     ],
                  //   ),
                  // ).paddingOnly(top: 20),
                  if (isManager &&
                      allowedModules.containsKey('Request Money') &&
                      allowedModules['Request Money']!.contains('add_request_money'))
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
                              Get.to(ScreenNewRequestMoney());
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
                              Get.to(ScreenNewRequestMoney());
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
                        Text(
                          "Request Money",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xff18CE0F),
                              fontFamily: 'Nunito'),
                        ),
                        Divider(color: Color(0xffDDDDDD)),
                        Expanded(
                          child: Obx(() {
                            if (requestMoneyController.isLoading.value) {
                              return Center(
                                child: SpinKitFadingFour(
                                  duration: Duration(seconds: 3),
                                  size: 120,
                                  color: Colors.green,
                                ),
                              );
                            } else if (requestMoneyController
                                .requestMoneyList.isEmpty) {
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
                              return Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SingleChildScrollView(
                                    child: DataTable(
                                      columns: const [
                                        DataColumn(label: Text('S.NO')),
                                        DataColumn(label: Text('DateTime')),
                                        DataColumn(label: Text('Requested By')),
                                        DataColumn(label: Text('Requested To')),
                                        DataColumn(label: Text('Description')),
                                        DataColumn(label: Text('Status')),
                                        DataColumn(label: Text('Currency')),
                                        DataColumn(label: Text('Amount')),
                                        DataColumn(label: Text('Action')),
                                      ],
                                      rows: requestMoneyController.requestMoneyList
                                          .map((requestMoney) {
                                        return DataRow(cells: [
                                          DataCell(Text(
                                              '${requestMoneyController.requestMoneyList.indexOf(requestMoney) + 1}')),
                                          DataCell(Text(
                                              '${DateFormat('dd-MM-yyyy   HH:mm a').format(DateTime.parse(requestMoney.dateTime))}')),
                                          DataCell(Text(requestMoney.requestedBy)),
                                          DataCell(Text(requestMoney.requestedTo)),
                                          DataCell(Text(requestMoney.description)),
                                          DataCell(Text(requestMoney.status)),
                                          DataCell(Text(requestMoney.currency)),
                                          DataCell(Text(
                                              double.parse(requestMoney.amount)
                                                  .toStringAsFixed(2))),
                                          DataCell(CustomButton(
                                              width: 140,
                                              height: 35,
                                              backGroundColor: _getButtonColor(requestMoney.status, requestMoney.requestedBy),
                                              text: _getButtonText(requestMoney.status, requestMoney.requestedBy),
                                              onPressed: () {
                                                _getButtonAction(requestMoney.status, requestMoney.requestedBy, requestMoney.id);
                                              }))
                                        ]);
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              );
                            }
                          }),
                        ),
                      ],
                    ).paddingOnly(top: 20, bottom: 20),
                  ).paddingSymmetric(horizontal: 15, vertical: 10),
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

  Color _getButtonColor(String status, String requestedBy) {
    // Debugging values


    // Ensure controller.email.value is not null or empty
    if (controller.email.value == null || controller.email.value.isEmpty) {
     // print('Error: Controller email is null or empty.');
      return Colors.grey;
    }

    // Normalize status and trim email values
    status = status.toLowerCase().trim();
    requestedBy = requestedBy.trim();
    final currentUser = controller.email.value.trim();

    // Determine if the current user is the sender
    final isCurrentUser = requestedBy == currentUser;
    //print('isCurrentUser: $isCurrentUser'); // Debugging user check

    // Match status and determine color
    if (status == 'confirm' && !isCurrentUser) {
      //print('Returning Blue: Confirm button for other user.');
      return Colors.blue; // Other user sent request
    } else if (status == 'pending' && isCurrentUser) {
      //print('Returning Blue: Pending button for current user.');
      return Colors.orangeAccent; // Current user sent request
    } else if (status == 'pending' && !isCurrentUser) {
     // print('Returning Blue: Pending button for other user\'s request.');
      return Colors.blue; // Other user sent request, pending
    } else if (status == 'completed') {
      //print('Returning Green: Completed request.');
      return Color(0xff18CE0F); // Both confirmed the request
    } else {
      //print('Returning Grey: Default case.');
      return Colors.grey; // Default case
    }
  }


  String _getButtonText(String status, String requestedBy) {
    //print('Debugging _getButtonText...');
    //print('Status: "$status", RequestedBy: "$requestedBy", CurrentUser: "${controller.email.value}"');

    // Normalize inputs
    status = status.toLowerCase().trim();
    requestedBy = requestedBy.trim();
    final currentUser = controller.email.value.trim();

    // Determine if the current user is the sender
    final isCurrentUser = requestedBy == currentUser;
    //print('isCurrentUser: $isCurrentUser');

    // Match status and determine button text
    if (status == 'confirm' && !isCurrentUser) {
      //print('Returning "Confirm"');
      return 'Confirm'; // Other user sent request, current user can confirm
    } else if (status == 'pending' && !isCurrentUser) {
      //('Returning "Confirm" for Pending from other user');
      return 'Confirm'; // Pending, and other user sent request
    } else if (status == 'pending' && isCurrentUser) {
      //print('Returning "Pending" for current user');
      return 'Pending'; // Pending, and current user sent request
    } else if (status == 'completed') {
      //print('Returning "Completed"');
      return 'Completed'; // Both confirmed the request
    } else {
      //print('Returning default text: "Unknown"');
      return 'Unknown'; // Default text for unhandled statuses
    }
  }


  VoidCallback? _getButtonAction(String status, String requestedBy, String requestId) {
    //print('Debugging _getButtonAction...');
    //print('Status: "$status", RequestedBy: "$requestedBy", CurrentUser: "${controller.email.value}"');

    bool isCurrentUser = requestedBy == controller.email.value;
    String buttonText = _getButtonText(status, requestedBy);

    // Check if button text is "Confirm" and the current user is not the requester
    if (buttonText == 'Confirm' && !isCurrentUser) {
      //print('Button clicked! Proceeding to confirm the request.');
      print('Request ID: $requestId');

      if (requestId.isNotEmpty) {
        // Navigate to OTP verification screen instead of directly confirming
        Get.to(() => ScreenRequestMoneyOtp(
          requestId: requestId,
          userEmail: controller.email.value,
        ));
      } else {
        print('Error: Request ID is empty');
        Get.snackbar('Error', 'Request ID is empty',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,);
      }
    } else {
      print('Button action skipped.');
    }

    return null; // Button is disabled for other cases
  }




}

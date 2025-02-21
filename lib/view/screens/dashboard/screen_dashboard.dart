import 'package:dacotech/view/screens/dashboard/complete_transaction_controller.dart';
import 'package:dacotech/view/screens/escrow_system/escrow_controller.dart';
import 'package:dacotech/view/controller/wallet_controller.dart';
import 'package:dacotech/view/screens/managers/screen_managers.dart';
import 'package:dacotech/widgets/custom_appbar/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_ballance_container/custom_btc_container.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../escrow_system/received_escrow/received_escrow_controller.dart';
import '../escrow_system/request_escrow/request_escrow_controller.dart';
import '../escrow_system/send_escrow/send_escrow_controller.dart';
import '../managers/controller_managers.dart';
import '../managers/manager_permission_controller.dart';
import 'dashboard_controller.dart';
import '../../controller/get_controller.dart';
import '../../controller/logo_controller.dart';
import '../user_profile/user_profile_controller.dart';

class ScreenDashboard extends StatelessWidget {
  final WalletController walletController = Get.put(WalletController());
  final SendEscrowsController sendEscrowController =
      Get.put(SendEscrowsController());
  final ReceivedEscrowsController receivedEscrowController =
      Get.put(ReceivedEscrowsController());
  final RequestEscrowController requestEscrowController =
      Get.put(RequestEscrowController());
  final MenubuttonController controller = Get.put(MenubuttonController());
  final LogoController logoController = Get.put(LogoController());
  final InfoController infoController = Get.put(InfoController());
  final HomeController homeController = Get.put(HomeController());
  final CompleteTransactionController completeController =
      Get.put(CompleteTransactionController());
  final UserProfileController userProfileController =
      Get.put(UserProfileController());
  final UserEscrowsController escrowController =
      Get.put(UserEscrowsController());
  final SendEscrowsController senderEscrowController =
      Get.put(SendEscrowsController());
  final ManagersController managerController = Get.put(ManagersController());
  final ManagersPermissionController permissionController =
      Get.put(ManagersPermissionController());

  void initState() {
    //super.initState();
    if (!Get.isRegistered<WalletController>()) {
      Get.put(WalletController());
    }
    userProfileController.fetchUserDetails();
    walletController.walletBalance();
    // permissionController
    //     .fetchManagerPermissions(userProfileController.userId.value);
    //walletController.fetchWalletBalance(userProfileController.walletId.value);
    //userProfileController.fetchUserDetails(co);
  }

  final GlobalKey popupMenuKey = GlobalKey();

  void onInit() {
    walletController.walletBalance.value;
    homeController.fetchFilteredData("today");
    completeController.fetchFilteredData("today");
    completeController.fetchCompleteTransaction("today");
    homeController.fetchPendingMoneyRequests('today');
    homeController.fetchPendingData('today');
    sendEscrowController.fetchSendEscrows();
    walletController.fetchWalletBalance(userProfileController.walletId.value);
    receivedEscrowController.fetchReceiverEscrows();
    requestEscrowController.fetchRequestEscrows();
    permissionController
        .fetchManagerPermissions(userProfileController.userId.value);
  }

  @override
  Widget build(BuildContext context) {
    final isManager = userProfileController.isManager.value == '1';
    final isNotManager = userProfileController.isManager.value == '0';
    final kycStatus = userProfileController.kyc.value == '3';
    final allowedModules = permissionController.modulePermissions;
    List<String> selectedCurrencies = [
      'XAF',
    ]; // Example: it could be ['USD'], ['BTC'], or a combination
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: Color(0xff0766AD),
        title: AppBarTitle(),
        leading: CustomPopupMenu(
          managerId: userProfileController.userId.value,
        ),
        actions: [
          AppBarProfileButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          userProfileController.fetchUserDetails();
          walletController
              .fetchWalletBalance(userProfileController.walletId.value);
          walletController.walletBalance.value;
          homeController.fetchFilteredData("today");
          completeController.fetchCompleteTransaction("today");
          homeController.fetchPendingMoneyRequests('today');
          homeController.fetchPendingData('today');
          sendEscrowController.fetchSendEscrows();
          receivedEscrowController.fetchReceiverEscrows();
          requestEscrowController.fetchRequestEscrows();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (isManager &&
                  allowedModules.containsKey('Dashboard') &&
                  allowedModules['Dashboard']!.contains('view_dashboard'))
                Column(
                  children: [
                    Obx(() {
                      return controller.isWalletCreated.value
                          ? NewContainer(controller)
                          : Container(
                              height: MediaQuery.of(context).size.height * .47,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Color(0xffCDE0EF),
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(30),
                                      bottomRight: Radius.circular(30)),
                                  boxShadow: [
                                    BoxShadow(
                                        offset: Offset(1, 1),
                                        blurRadius: 6,
                                        color: Colors.grey)
                                  ]),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .25,
                                      width: Get.width * .55,
                                      child: Image(
                                        image: AssetImage(
                                            "assets/images/dashboard.png"),
                                        fit: BoxFit.fill,
                                      )).paddingOnly(top: 10),
                                  Text(
                                    "Welcome back ${userProfileController.userName.value} !",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20,
                                        fontFamily: 'Nunito'),
                                    textAlign: TextAlign.center,
                                  ).paddingOnly(top: 20),
                                  CustomButton(
                                      height: 37,
                                      width: MediaQuery.of(context).size.width *
                                          0.55,
                                      text: "CREATE WALLET",
                                      onPressed: () {
                                        walletController
                                            .fetchWalletCurrencies();
                                        controller.createWallet();
                                      }).paddingOnly(top: 20),
                                ],
                              ),
                            );
                    }),
                    // CustomButton(
                    //     height: 37,
                    //     width: MediaQuery.of(context).size.width * .55,
                    //     text: 'MANAGERS',
                    //     onPressed: () {
                    //       Get.to(ScreenManagers());
                    //     }).paddingSymmetric(horizontal: 20, vertical: 10),
                    SizedBox(
                      height: 20,
                    ),
                    CustomBtcContainer(),
                    Obx(
                      () => GestureDetector(
                        onTap: () {
                          // Open the PopupMenuButton programmatically
                          final dynamic state = popupMenuKey.currentState;
                          state.showButtonMenu();
                        },
                        child: Container(
                          height: 42,
                          width: MediaQuery.of(context).size.width * .9,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                homeController.selectedOption.value,
                                style: TextStyle(fontSize: 16),
                              ),
                              PopupMenuButton<String>(
                                key: popupMenuKey,
                                // Assign the GlobalKey to the PopupMenuButton
                                icon: Icon(Icons.expand_more),
                                onSelected: (String value) {
                                  homeController.selectedOption.value =
                                      value; // Update the selected option
                                  completeController
                                      .fetchCompleteTransaction(value);
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  PopupMenuItem<String>(
                                    value: 'today',
                                    child: Text('Today'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'This Week',
                                    child: Text('This Week'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'This Month',
                                    child: Text('This Month'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'This Year',
                                    child: Text('This Year'),
                                  ),
                                ],
                              ),
                            ],
                          ).paddingSymmetric(horizontal: 15),
                        ).paddingOnly(top: 10, bottom: 10),
                      ),
                    ),
                    buildTransactionContainers(selectedCurrencies),
                    buildPendingMoneyRequestsList(
                        homeController.pendingMoneyRequests),
                    //buildEscrowReleaseSystemList(sendEscrowController.escrows),
                    //buildEscrowRejectSystemList(receivedEscrowController.receiverEscrows),
                    //buildEscrowCancelledSystemList(requestEscrowController.requestEscrows),
                    buildWellDoneContainer(),
                    buildPendingTransactionList(homeController),
                    SizedBox(
                      height: 20,
                    ),
                    buildTransactionList(homeController),
                    Obx(() => infoController.isVisible.value
                        ? buildInfoContainer(infoController)
                        : Container().paddingOnly(top: 20, bottom: 10)),
                    CustomBottomContainer()
                  ],
                )
              else if (isManager)
                Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.1,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "You have not permission for this page!",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ).paddingSymmetric(horizontal: 20,vertical: 70),
                    CustomBottomContainer().paddingOnly(top:
                    MediaQuery.of(context).size.height * 0.49),
                  ],
                ),
              if (isNotManager)
                Column(
                  children: [
                    Obx(() {
                      return controller.isWalletCreated.value
                          ? NewContainer(controller)
                          : Container(
                              height: MediaQuery.of(context).size.height * .47,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Color(0xffCDE0EF),
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(30),
                                      bottomRight: Radius.circular(30)),
                                  boxShadow: [
                                    BoxShadow(
                                        offset: Offset(1, 1),
                                        blurRadius: 6,
                                        color: Colors.grey)
                                  ]),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .25,
                                      width: Get.width * .55,
                                      child: Image(
                                        image: AssetImage(
                                            "assets/images/dashboard.png"),
                                        fit: BoxFit.fill,
                                      )).paddingOnly(top: 10),
                                  Text(
                                    "Welcome back ${userProfileController.userName.value} !",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20,
                                        fontFamily: 'Nunito'),
                                    textAlign: TextAlign.center,
                                  ).paddingOnly(top: 20),
                                  CustomButton(
                                      height: 37,
                                      width: MediaQuery.of(context).size.width *
                                          0.55,
                                      text: "CREATE WALLET",
                                      onPressed: () {
                                        walletController
                                            .fetchWalletCurrencies();
                                        controller.createWallet();
                                      }).paddingOnly(top: 20),
                                ],
                              ),
                            );
                    }),
                    // CustomButton(
                    //     height: 37,
                    //     width: MediaQuery.of(context).size.width * .55,
                    //     text: 'MANAGERS',
                    //     onPressed: () {
                    //       Get.to(ScreenManagers());
                    //     }).paddingSymmetric(horizontal: 20, vertical: 10),
                    SizedBox(
                      height: 20,
                    ),
                    CustomBtcContainer(),
                    Obx(
                      () => GestureDetector(
                        onTap: () {
                          // Open the PopupMenuButton programmatically
                          final dynamic state = popupMenuKey.currentState;
                          state.showButtonMenu();
                        },
                        child: Container(
                          height: 42,
                          width: MediaQuery.of(context).size.width * .9,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                homeController.selectedOption.value,
                                style: TextStyle(fontSize: 16),
                              ),
                              PopupMenuButton<String>(
                                key: popupMenuKey,
                                // Assign the GlobalKey to the PopupMenuButton
                                icon: Icon(Icons.expand_more),
                                onSelected: (String value) {
                                  homeController.selectedOption.value =
                                      value; // Update the selected option
                                  completeController
                                      .fetchCompleteTransaction(value);
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  PopupMenuItem<String>(
                                    value: 'today',
                                    child: Text('Today'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'This Week',
                                    child: Text('This Week'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'This Month',
                                    child: Text('This Month'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'This Year',
                                    child: Text('This Year'),
                                  ),
                                ],
                              ),
                            ],
                          ).paddingSymmetric(horizontal: 15),
                        ).paddingOnly(top: 10, bottom: 10),
                      ),
                    ),
                    buildTransactionContainers(selectedCurrencies),
                    buildPendingMoneyRequestsList(
                        homeController.pendingMoneyRequests),
                    //buildEscrowReleaseSystemList(sendEscrowController.escrows),
                    //buildEscrowRejectSystemList(receivedEscrowController.receiverEscrows),
                    //buildEscrowCancelledSystemList(requestEscrowController.requestEscrows),
                    buildWellDoneContainer(),
                    buildPendingTransactionList(homeController),
                    SizedBox(
                      height: 20,
                    ),
                    buildTransactionList(homeController),
                    Obx(() => infoController.isVisible.value
                        ? buildInfoContainer(infoController)
                        : Container().paddingOnly(top: 20, bottom: 10)),
                    CustomBottomContainer()
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  // Method to build transaction containers based on selected currencies
  Widget buildTransactionContainers(List<String> currencies) {
    // Map each currency to the appropriate transaction containers
    Map<String, List<String>> transactionMap = {
      'XAF': [
        'MTN Mobile Money CFA franc',
        'Orange Money CFA franc',
      ],
      'USD': [
        'USDT Wallet USDT',
      ],
      'BTC': [
        'BTC Onchain BTC',
        'BTC Lightening BTC',
      ],
    };

    // Container list to hold the widgets for the selected currencies
    List<Widget> transactionContainers = [];

    // Loop through each selected currency
    for (var currency in currencies) {
      if (transactionMap.containsKey(currency)) {
        for (var transaction in transactionMap[currency]!) {
          transactionContainers.add(buildTransactionContainer(transaction));
        }
      }
    }

    // Return the list of transaction containers as a Column
    return Column(
      children: transactionContainers,
    );
  }

  Widget buildTransactionContainer(String text) {
    return Container(
      height: Get.height * 0.09,
      width: Get.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xff666565),
            ),
          ),
          Spacer(), // This will push the Row to the bottom
          Row(
            children: [
              Icon(
                Icons.arrow_circle_down,
                color: Colors.green,
              ),
              SizedBox(width: 5),
              Text(
                "0",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(width: 25),
              Icon(
                Icons.arrow_circle_up,
                color: Colors.red,
              ),
              SizedBox(width: 5),
              Text(
                "0",
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    ).paddingSymmetric(horizontal: 15, vertical: 5);
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
              Spacer(),
              IconButton(
                onPressed: () {
                  infoController.hideContainer();
                },
                icon: Icon(
                  Icons.clear,
                  color: Colors.white,
                  size: 30,
                ),
              )
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

  Widget buildWellDoneContainer() {
    return Obx(() {
      if (homeController.isLoading.value) {
        return Center(child: Container());
      } else if (homeController.pendingTransactions.isEmpty) {
        return Container();
      } else {
        return Container(
          height: Get.height * .18,
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
                  Text(
                    "Well done!",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Nunito"),
                  ).paddingOnly(top: 30),
                ],
              ),
              Text(
                "Now you just have to confirm that this"
                " transaction is yours so that the money goes to it's destiny.",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Nunito"),
              ),
            ],
          ).paddingSymmetric(horizontal: 10),
        ).paddingSymmetric(horizontal: 15, vertical: 10);
      }
    });
  }

  Widget buildTransactionList(HomeController homeController) {
    return Obx(() {
      if (homeController.isLoading.value) {
        return Center(child: Container());
      } else if (completeController.dashboard.isEmpty) {
        return Container();
      } else {
        return Container(
          //height: Get.height*.8,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(15)),
          child: Column(
            children: [
              Text(
                "Complete Transactions",
                style: TextStyle(
                    fontSize: 18,
                    color: Color(0xff18CE0F),
                    fontWeight: FontWeight.w600),
              ).paddingOnly(top: 5),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      //minHeight: Get.size.height,
                      ),
                  child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(
                          label: Text('ID',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Date',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Name',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Gross',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Fee',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Net',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Balance',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: completeController.dashboard
                        .asMap()
                        .entries
                        .map((entry) {
                      int index =
                          entry.key + 1; // Add 1 to make index start from 1
                      var dashboard = entry.value;
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(Text(index.toString())),
                          DataCell(Column(
                            children: [
                              Text(
                                  '${DateFormat('dd MMM yyyy').format(DateTime.parse(dashboard.createdAt))}'),
                              Container(
                                  height: 25,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Color(0xff18CE0F)),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                      child: Text(
                                    'Complete',
                                    style: TextStyle(color: Color(0xff18CE0F)),
                                  )))
                            ],
                          )),
                          //DataCell(Text('Pending Funds Availability')), // Assuming 'Pending Funds Availability' is static or based on logic
                          DataCell(Text(
                              '${dashboard.activityTitle}\nTo ${dashboard.entityName}')),
                          // Adjust the name as per your data structure
                          DataCell(Text(
                              '${dashboard.moneyFlow} ${dashboard.currencySymbol} ${dashboard.gross.toString()}')),
                          DataCell(Text(
                              '${dashboard.currencySymbol} ${dashboard.fee.toString()}')),
                          DataCell(Text(
                              '${dashboard.moneyFlow} ${dashboard.currencySymbol} ${dashboard.net.toString()}')),
                          DataCell(Text(
                              '${dashboard.currencySymbol} ${dashboard.balance}')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     IconButton(
              //       icon: Icon(Icons.arrow_back),
              //       onPressed: completeController.dashboardHasPreviousPage
              //           ? completeController.previousPage
              //           : null,
              //     ),
              //     Text('Page ${completeController.dashboardCurrentPage.value} of ${completeController.dashboardTotalPages.value}'),
              //     IconButton(
              //       icon: Icon(Icons.arrow_forward),
              //       onPressed: completeController.dashboardHasNextPage
              //           ? completeController.nextPage
              //           : null,
              //     ),
              //   ],
              // )
            ],
          ),
        ).paddingSymmetric(horizontal: 15);
      }
    });
  }

  Widget buildPendingTransactionList(HomeController homeController) {
    return Obx(() {
      if (homeController.isLoading.value) {
        return Center(child: Container());
      } else if (homeController.pendingTransactions.isEmpty) {
        return Container();
      } else {
        return Container(
          //height: Get.height*.8,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(15)),
          child: Column(
            children: [
              Text(
                "Pending Transactions",
                style: TextStyle(
                    fontSize: 18,
                    color: Color(0xff18CE0F),
                    // Changed color to distinguish from complete transactions
                    fontWeight: FontWeight.w600),
              ).paddingOnly(top: 5),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      //minHeight: Get.size.height,
                      ),
                  child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(
                          label: Text('ID',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Date',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('time to expire',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Name',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Gross',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Fee',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Net',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Status',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      // Added status column
                    ],
                    rows: homeController.pendingTransactions
                        .asMap()
                        .entries
                        .map((entry) {
                      int index =
                          entry.key + 1; // Add 1 to make index start from 1
                      var transaction = entry.value;
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(Text(index.toString())),
                          DataCell(Column(
                            children: [
                              Text(
                                  '${DateFormat('dd MMM yyyy').format(DateTime.parse(transaction.createdAt))}'),
                              Container(
                                  height: 25,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.blueAccent),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                      child: Text(
                                    '${transaction.statusName}',
                                    style: TextStyle(color: Colors.blueAccent),
                                  )))
                            ],
                          )),
                          DataCell(Text('Funds\nAvailability')),
                          DataCell(
                              Text('Money Sent\nTo ${transaction.entityName}')),
                          DataCell(Text(
                              '${transaction.moneyFlow} ${transaction.currencySymbol} ${transaction.gross.toString()}')),
                          DataCell(Text(
                              '${transaction.currencySymbol} ${transaction.fee.toString()}')),
                          DataCell(Text(
                              '${transaction.moneyFlow}${transaction.currencySymbol} ${transaction.net}')),
                          DataCell(Container(
                              height: 30,
                              width: 80,
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xff18CE0F)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                  child: Text(
                                "Confirm",
                                style: TextStyle(color: Color(0xff18CE0F)),
                              ))))
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     IconButton(
              //       icon: Icon(Icons.arrow_back),
              //       onPressed: homeController.pendingHasPreviousPage
              //           ? homeController.previousPage
              //           : null,
              //     ),
              //     Text('Page ${homeController.pendingCurrentPage.value} of ${homeController.pendingTotalPages.value}'),
              //     IconButton(
              //       icon: Icon(Icons.arrow_forward),
              //       onPressed: homeController.pendingHasNextPage
              //           ? homeController.nextPage
              //           : null,
              //     ),
              //   ],
              // )
            ],
          ),
        ).paddingSymmetric(horizontal: 15, vertical: 10);
      }
    });
  }

  Widget buildPendingMoneyRequestsList(List<PendingMoneyRequest> requests) {
    return Obx(() {
      if (homeController.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else {
        return SingleChildScrollView(
          // Add a scroll view if the content might overflow
          child: Column(
            children: requests.map((request) {
              return buildPendingMoneyRequest(request);
            }).toList(),
          ),
        );
      }
    });
  }

  Widget buildPendingMoneyRequest(PendingMoneyRequest request) {
    return Container(
      height: Get.height * 0.15,
      margin: EdgeInsets.only(top: 8.0),
      padding: EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Displaying ID, Status, and "Money Request"
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "#${request.id} :: ",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      TextSpan(
                        text: "Pending ",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      TextSpan(
                        text: "Money Request",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5.0),
                // Displaying "To" and Name
                Row(
                  children: [
                    Text(
                      "To",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      " ${request.name}",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.0),
                // Displaying Currency and Amount
                Text(
                  "${request.currencySymbol}${request.net}",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ).paddingSymmetric(horizontal: 10),
          ),
          IconButton(
            icon: Icon(Icons.close),
            color: Colors.grey,
            onPressed: () {
              // Handle close action
            },
          ),
        ],
      ),
    ).paddingSymmetric(horizontal: 15);
  }

  Widget buildEscrowReleaseSystemList(List<Escrow> requests) {
    return Obx(() {
      // Filter the requests where statusLabel is "on hold"
      List<Escrow> filteredRequests = requests
          .where((request) => request.statusLabel == "on hold")
          .toList();

      // If filteredRequests is empty, you can display a message or leave the UI blank
      if (filteredRequests.isEmpty) {
        return Center(child: Container());
      }

      if (sendEscrowController.isLoading.value) {
        return Center(child: Container());
      } else {
        return SingleChildScrollView(
          // Add a scroll view if the content might overflow
          child: Column(
            children: filteredRequests.map((request) {
              return buildEscrowReleaseSystem(request);
            }).toList(),
          ),
        );
      }
    });
  }

  Widget buildEscrowReleaseSystem(Escrow escrow) {
    return Container(
      //height: Get.height * 0.15,
      margin: EdgeInsets.only(top: 8.0),
      padding: EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "${escrow.statusLabel} ",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "- ${escrow.currencySymbol}  ${double.parse(escrow.gross.toString()).toStringAsFixed(2)}",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "Escrow money to",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      " ${escrow.to}",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.0),
                InkWell(
                  onTap: () async {
                    await senderEscrowController.escrowRelease('${escrow.id}');
                  },
                  child: Container(
                      height: 25,
                      width: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                          child: Text(
                        'Release',
                        style: TextStyle(color: Colors.blueAccent),
                      ))),
                )
              ],
            ).paddingSymmetric(horizontal: 10),
          ),
          IconButton(
            icon: Icon(Icons.close),
            color: Colors.grey,
            onPressed: () {
              // Handle close action
            },
          ),
        ],
      ),
    ).paddingSymmetric(horizontal: 15);
  }

  Widget buildEscrowRejectSystemList(List<ReceivedEscrow> requests) {
    return Obx(() {
      // Filter the requests where statusLabel is "Pending"
      List<ReceivedEscrow> filteredRequests = requests
          .where((request) => request.statusLabel == "on hold")
          .toList();

      // If filteredRequests is empty, you can display a message or leave the UI blank
      if (filteredRequests.isEmpty) {
        return Center(child: Container());
      }

      if (receivedEscrowController.isLoading.value) {
        return Center(child: Container());
      } else {
        return SingleChildScrollView(
          // Add a scroll view if the content might overflow
          child: Column(
            children: filteredRequests.map((request) {
              return buildEscrowRejectSystem(request);
            }).toList(),
          ),
        );
      }
    });
  }

  Widget buildEscrowRejectSystem(ReceivedEscrow receiverEscrows) {
    return Container(
      //height: Get.height * 0.15,
      margin: EdgeInsets.only(top: 8.0),
      padding: EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "${receiverEscrows.statusLabel} ",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "+ ${receiverEscrows.currencySymbol}  ${double.parse(receiverEscrows.gross).toStringAsFixed(2)}",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "Escrow money from",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      " ${receiverEscrows.to}",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.0),
                InkWell(
                  onTap: () async {
                    //await escrowController.escrowReject('${receiverEscrows.id}');
                  },
                  child: Container(
                      height: 25,
                      width: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                          child: Text(
                        'Reject',
                        style: TextStyle(color: Colors.red),
                      ))),
                )
              ],
            ).paddingSymmetric(horizontal: 10),
          ),
          IconButton(
            icon: Icon(Icons.close),
            color: Colors.grey,
            onPressed: () {
              // Handle close action
            },
          ),
        ],
      ),
    ).paddingSymmetric(horizontal: 15);
  }

  Widget buildEscrowCancelledSystemList(List<RequestEscrow> requests) {
    return Obx(() {
      // Filter the requests where statusLabel is "padding"
      List<RequestEscrow> filteredRequests = requests
          .where((request) => request.statusLabel == "Pending")
          .toList();

      // If filteredRequests is empty, you can display a message or leave the UI blank
      if (filteredRequests.isEmpty) {
        return Center(child: Container());
      }

      if (requestEscrowController.isLoading.value) {
        return Center(child: Container());
      } else {
        return SingleChildScrollView(
          // Add a scroll view if the content might overflow
          child: Column(
            children: filteredRequests.map((request) {
              return buildEscrowCancelledSystem(request);
            }).toList(),
          ),
        );
      }
    });
  }

  Widget buildEscrowCancelledSystem(RequestEscrow cancelEscrows) {
    return Container(
      //height: Get.height * 0.15,
      margin: EdgeInsets.only(top: 8.0),
      padding: EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "${cancelEscrows.statusLabel} ",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "- ${cancelEscrows.currencySymbol}  ${double.parse(cancelEscrows.gross).toStringAsFixed(2)}",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "Escrow money from",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      " ${cancelEscrows.to}",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.0),
                InkWell(
                  onTap: () async {
                    await escrowController.escrowCancel('${cancelEscrows.id}');
                  },
                  child: Container(
                      height: 25,
                      width: 140,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                          child: Text(
                        'Cancel Request',
                        style: TextStyle(color: Colors.red),
                      ))),
                )
              ],
            ).paddingSymmetric(horizontal: 10),
          ),
          IconButton(
            icon: Icon(Icons.close),
            color: Colors.grey,
            onPressed: () {
              // Handle close action
            },
          ),
        ],
      ),
    ).paddingSymmetric(horizontal: 15);
  }
}

class NewContainer extends StatelessWidget {
  final MenubuttonController controller;

  NewContainer(this.controller);

  final WalletController walletController = Get.put(WalletController());

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .47,
      width: double.infinity,
      decoration: BoxDecoration(
          color: Color(0xffCDE0EF),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30)),
          boxShadow: [
            BoxShadow(offset: Offset(1, 1), blurRadius: 6, color: Colors.grey)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Select the Wallet\nCurrency",
                style: TextStyle(
                    color: Color(0xff484848),
                    fontWeight: FontWeight.w700,
                    fontSize: 28),
              ),
              IconButton(
                  onPressed: () {
                    controller.goBack();
                  },
                  icon: Icon(
                    Icons.clear,
                    size: 40,
                  ))
            ],
          ),
          Expanded(
            child: Obx(() {
              if (walletController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              } else if (walletController.walletCurrencies.isEmpty) {
                return Center(child: Text('No currencies available'));
              } else {
                return ListView.builder(
                  itemCount: walletController.walletCurrencies.length,
                  itemBuilder: (context, index) {
                    final currency = walletController.walletCurrencies[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        leading: currency.thumb.isNotEmpty
                            ? Image.network(currency.thumb,
                                width: 40, height: 40, fit: BoxFit.cover)
                            : Image.asset("assets/images/user.png",
                                width: 40, height: 40),
                        title: Text(
                          currency.name,
                          style: TextStyle(
                            color: Color(0xff484848),
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          "${currency.symbol} 0.00",
                          style: TextStyle(
                            color: Color(0xff666565),
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                        onTap: () async {
                          walletController.setWalletCurrency(currency);
                          int accountIdentifierMechanismId = 1; // Example ID
                          await walletController.createWallet(
                              currency.id, accountIdentifierMechanismId);
                        },
                      ),
                    ).paddingOnly(top: 10);
                  },
                );
              }
            }),
          )
        ],
      ).paddingSymmetric(horizontal: 15),
    );
  }
}

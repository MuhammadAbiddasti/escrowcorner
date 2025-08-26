import 'package:escrowcorner/view/screens/dashboard/complete_transaction_controller.dart';
import 'package:escrowcorner/view/screens/escrow_system/escrow_controller.dart';
import 'package:escrowcorner/view/controller/wallet_controller.dart';
import 'package:escrowcorner/view/screens/deposit/screen_deposit.dart';
import 'package:escrowcorner/view/screens/withdraw/screen_withdrawal.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:escrowcorner/widgets/custom_api_url/constant_url.dart';
import 'package:escrowcorner/view/screens/managers/screen_managers.dart';
import 'package:escrowcorner/widgets/custom_appbar/custom_appbar.dart';
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
import 'dashboard_controller.dart' as dash;
import '../../controller/get_controller.dart';
import '../../controller/logo_controller.dart';
import '../../../widgets/language_selector/language_selector_widget.dart';
import '../user_profile/user_profile_controller.dart';
import '../../controller/language_controller.dart';
import '../../../widgets/common_header/common_header.dart';

class ScreenDashboard extends StatefulWidget {
  @override
  _ScreenDashboardState createState() => _ScreenDashboardState();
}

class _ScreenDashboardState extends State<ScreenDashboard> {
  final WalletController walletController = Get.put(WalletController());
  final SendEscrowsController sendEscrowController = Get.put(SendEscrowsController());
  final ReceivedEscrowsController receivedEscrowController = Get.put(ReceivedEscrowsController());
  final RequestEscrowController requestEscrowController = Get.put(RequestEscrowController());
  final MenubuttonController controller = Get.put(MenubuttonController());
  final LogoController logoController = Get.put(LogoController());
  final InfoController infoController = Get.put(InfoController());
  final dash.HomeController homeController = Get.put(dash.HomeController(), tag: 'dashboard_home_controller');
  final CompleteTransactionController completeController = Get.put(CompleteTransactionController());
  final UserProfileController userProfileController = Get.find<UserProfileController>();
  final UserEscrowsController escrowController = Get.put(UserEscrowsController());
  final SendEscrowsController senderEscrowController = Get.put(SendEscrowsController());
  final ManagersController managerController = Get.put(ManagersController());
  final ManagersPermissionController permissionController = Get.put(ManagersPermissionController());
  final LanguageController languageController = Get.find<LanguageController>();

  final GlobalKey popupMenuKey = GlobalKey();

  void initState() {
    super.initState();
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

  void onInit() {
    walletController.walletBalance.value;
    homeController.fetchFilteredData("today");
    completeController.fetchFilteredData("today");
    completeController.fetchCompleteTransaction("today");
    homeController.fetchPendingMoneyRequests('today');
    homeController.fetchPendingData('today');
    homeController.fetchBalanceData("today");
    sendEscrowController.fetchSendEscrows();
    walletController.fetchWalletBalance(userProfileController.walletId.value);
    receivedEscrowController.fetchReceiverEscrows();
    requestEscrowController.fetchRequestEscrows();
    permissionController.fetchManagerPermissions(userProfileController.userId.value);
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: "Dashboard",
        managerId: userProfileController.userId.value,
      ),
      body: Stack(
        children: [
          // Main content
          RefreshIndicator(
            onRefresh: () async {
              userProfileController.fetchUserDetails();
              walletController.fetchWalletBalance(userProfileController.walletId.value);
              walletController.walletBalance.value;
              homeController.fetchFilteredData("today");
              completeController.fetchCompleteTransaction("today");
              homeController.fetchPendingMoneyRequests('today');
              homeController.fetchPendingData('today');
              homeController.fetchBalanceData("today");
              homeController.fetchDashboardSettings(); // Fetch dashboard settings
              sendEscrowController.fetchSendEscrows();
              receivedEscrowController.fetchReceiverEscrows();
              requestEscrowController.fetchRequestEscrows();
            },
            child: SingleChildScrollView(
              child: Obx(() {
                final isManager = userProfileController.isManager.value == '1';
                final isNotManager = userProfileController.isManager.value == '0';
                final kycStatus = userProfileController.kyc.value == '3';
                final allowedModules = permissionController.modulePermissions;
                return Column(
                  children: [
                    if (isManager &&
                        allowedModules.containsKey('Dashboard') &&
                        allowedModules['Dashboard']!.contains('view_dashboard'))
                      Column(
                        children: [
                          Obx(() {
                            return controller.isWalletCreated.value
                                ? NewContainer(controller)
                                : Column(
                                    children: [
                                      Container(
                                        height: MediaQuery.of(context).size.height * .35,
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
                                        child: Obx(() {
                                          if (homeController.isDashboardSettingsLoading.value) {
                                            return Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          }
                                          
                                          return homeController.dashboardImage.value.startsWith('http')
                                              ? Image.network(
                                                  homeController.dashboardImage.value,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Image.asset(
                                                      'assets/images/dashboard.png',
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                                )
                                              : Image.asset(
                                                  homeController.dashboardImage.value,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Image.asset(
                                                      'assets/images/dashboard.png',
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                                );
                                        }),
                                      ),
                                      // Welcome text and Create Wallet button below image
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                        child: Column(
                                          children: [
                                            Text(
                                              languageController.getTranslation('welcome_back') + " ${userProfileController.userName.value} !",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 20,
                                                  fontFamily: 'Nunito',
                                                  color: Colors.black87),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 20),
                                            CustomButton(
                                                height: 37,
                                                width: MediaQuery.of(context).size.width * 0.55,
                                                text: languageController.getTranslation('create_a_wallet'),
                                                onPressed: () {
                                                  walletController.fetchWalletCurrencies();
                                                  controller.createWallet();
                                                }),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                          }),
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
                                      _getTranslatedOption(homeController.selectedOption.value),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    PopupMenuButton<String>(
                                      key: popupMenuKey,
                                      icon: Icon(Icons.expand_more),
                                      onSelected: (String value) {
                                        homeController.selectedOption.value =
                                            value; // Update the selected option
                                        completeController
                                            .fetchCompleteTransaction(value);
                                        homeController.fetchBalanceData(value.toLowerCase());
                                      },
                                      itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry<String>>[
                                        PopupMenuItem<String>(
                                          value: 'Today',
                                          child: Text(languageController.getTranslation('today')),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'This Week',
                                          child: Text(languageController.getTranslation('this_week')),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'This Month',
                                          child: Text(languageController.getTranslation('this_month')),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'This Year',
                                          child: Text(languageController.getTranslation('this_year')),
                                        ),
                                      ],
                                    ),
                                  ],
                                ).paddingSymmetric(horizontal: 15),
                              ).paddingOnly(top: 10, bottom: 10),
                            ),
                          ),
                          buildDynamicBalanceContainers(),
                          buildPendingMoneyRequestsList(
                              homeController.pendingMoneyRequests),
                          buildWellDoneContainer(),
                          buildPendingTransactionList(homeController),
                          SizedBox(
                            height: 20,
                          ),
                          buildTransactionList(homeController),
                          Obx(() => infoController.isVisible.value
                              ? buildInfoContainer(infoController)
                              : Container().paddingOnly(top: 20, bottom: 10)),
                          CustomBottomContainerPostLogin()
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
                                languageController.getTranslation('no_permission_message'),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ).paddingSymmetric(horizontal: 20, vertical: 70),
                          CustomBottomContainerPostLogin().paddingOnly(top:
                              MediaQuery.of(context).size.height * 0.49),
                        ],
                      ),
                    if (isNotManager)
                      Column(
                        children: [
                          Obx(() {
                            return controller.isWalletCreated.value
                                ? NewContainer(controller)
                                : Column(
                                    children: [
                                      Container(
                                        height: MediaQuery.of(context).size.height * .35,
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
                                        child: Obx(() {
                                          if (homeController.isDashboardSettingsLoading.value) {
                                            return Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          }
                                          
                                          return homeController.dashboardImage.value.startsWith('http')
                                              ? Image.network(
                                                  homeController.dashboardImage.value,
                                                  fit: BoxFit.fill,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Image.asset(
                                                      'assets/images/dashboard.png',
                                                      fit: BoxFit.fill,
                                                    );
                                                  },
                                                )
                                              : Image.asset(
                                                  homeController.dashboardImage.value,
                                                  fit: BoxFit.fill,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Image.asset(
                                                      'assets/images/dashboard.png',
                                                      fit: BoxFit.fill,
                                                    );
                                                  },
                                                );
                                        }),
                                      ),
                                      // Welcome text and Create Wallet button below image
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                        child: Column(
                                          children: [
                                            Text(
                                              languageController.getTranslation('welcome_back') + " ${userProfileController.userName.value} !",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 20,
                                                  fontFamily: 'Nunito',
                                                  color: Colors.black87),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 20),
                                            CustomButton(
                                                height: 37,
                                                width: MediaQuery.of(context).size.width * 0.55,
                                                text: languageController.getTranslation('create_a_wallet'),
                                                onPressed: () {
                                                  walletController.fetchWalletCurrencies();
                                                  controller.createWallet();
                                                }),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                          }),
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
                                      _getTranslatedOption(homeController.selectedOption.value),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    PopupMenuButton<String>(
                                      key: popupMenuKey,
                                      icon: Icon(Icons.expand_more),
                                      onSelected: (String value) {
                                        homeController.selectedOption.value = value;
                                        completeController.fetchCompleteTransaction(value);
                                        homeController.fetchBalanceData(value.toLowerCase());
                                      },
                                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                        PopupMenuItem<String>(
                                          value: 'Today',
                                          child: Text(languageController.getTranslation('today')),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'This Week',
                                          child: Text(languageController.getTranslation('this_week')),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'This Month',
                                          child: Text(languageController.getTranslation('this_month')),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'This Year',
                                          child: Text(languageController.getTranslation('this_year')),
                                        ),
                                      ],
                                    ),
                                  ],
                                ).paddingSymmetric(horizontal: 15),
                              ).paddingOnly(top: 10, bottom: 10),
                            ),
                          ),
                          buildDynamicBalanceContainers(),
                          buildDepositButton(),
                          buildWithdrawButton(),
                          buildPendingMoneyRequestsList(
                              homeController.pendingMoneyRequests),
                          buildWellDoneContainer(),
                          buildPendingTransactionList(homeController),
                          SizedBox(
                            height: 20,
                          ),
                          buildTransactionList(homeController),
                          Obx(() => infoController.isVisible.value
                              ? buildInfoContainer(infoController)
                              : Container().paddingOnly(top: 20, bottom: 10)),
                          CustomBottomContainerPostLogin()
                        ],
                      ),
                  ],
                );
              }),
            ),
          ),
          // Loading overlay
          Obx(() => homeController.isBalanceLoading.value
              ? _buildLoadingOverlay()
              : Container()),
        ],
      ),
    );
  }

  // Helper method to translate the selected option
  String _getTranslatedOption(String option) {
    switch (option) {
      case 'Today':
        return languageController.getTranslation('today');
      case 'This Week':
        return languageController.getTranslation('this_week');
      case 'This Month':
        return languageController.getTranslation('this_month');
      case 'This Year':
        return languageController.getTranslation('this_year');
      default:
        return option;
    }
  }

  // Method to build dynamic balance containers from API data
  Widget buildDynamicBalanceContainers() {
    return Obx(() {
      if (homeController.balanceData.isEmpty) {
        return Container(); // Return empty container if no data
      }
      
      return Column(
        children: homeController.balanceData.map((dash.BalanceData balance) => 
          buildBalanceContainer(balance)
        ).toList(),
      );
    });
  }



  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  strokeWidth: 4,
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBalanceContainer(dash.BalanceData balance) {
    return Container(
      height: Get.height * 0.09, // Restored to original height since labels are removed
      width: Get.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5), // Restored to original padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${balance.paymentMethodName} ${balance.currency}",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xff666565),
            ),
          ),
          SizedBox(height: 8), // Keep some spacing for better layout
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_circle_down,
                      color: Colors.green,
                      size: 20,
                    ),
                    SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        balance.totalDeposit,
                        style: TextStyle(fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_circle_up,
                      color: Colors.red,
                      size: 20,
                    ),
                    SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        balance.totalWithdraw,
                        style: TextStyle(fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).paddingSymmetric(horizontal: 15, vertical: 5);
  }



  Widget buildInfoContainer(InfoController infoController) {
    return Obx(() {
      // Check if there are any transactions (pending or complete)
      bool hasTransactions = homeController.pendingTransactions.isNotEmpty || 
                             completeController.dashboard.isNotEmpty;
      
      // Don't show the container if there are transactions
      if (hasTransactions) {
        return Container();
      }
      
      return Container(
        width: Get.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Color(0xff2CA8FF),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  languageController.getTranslation('info'),
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
              languageController.getTranslation('your_account_is_fresh_and_new') + " !",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  fontFamily: "Nunito"),
            ),
            Text(
              languageController.getTranslation('start_by_requesting_money_from_friends_or_by_selling_online_and_collecting_payments_in_your_wallet'),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Nunito"),
            ),
          ],
          ),
        ),
      ).paddingSymmetric(horizontal: 15, vertical: 6);
    }).paddingSymmetric(horizontal: 15, vertical: 10);
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
                    languageController.getTranslation('well_done'),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Nunito"),
                  ).paddingOnly(top: 30),
                ],
              ),
              Text(
                languageController.getTranslation('now_you_just_have_to_confirm_that_this_transaction_is_yours_so_that_the_money_goes_to_its_destiny'),
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

  Widget buildTransactionList(dash.HomeController homeController) {
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
                languageController.getTranslation('complete_transactions'),
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
                    columns: <DataColumn>[
                      DataColumn(
                          label: Text(languageController.getTranslation('serial_no'),
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text(languageController.getTranslation('date'),
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text(languageController.getTranslation('name'),
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text(languageController.getTranslation('gross'),
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text(languageController.getTranslation('fee'),
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text(languageController.getTranslation('net'),
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text(languageController.getTranslation('balance'),
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
                                    languageController.getTranslation('complete'),
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

  Widget buildPendingTransactionList(dash.HomeController homeController) {
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
                languageController.getTranslation('pending_transactions'),
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
                    columns: <DataColumn>[
                      DataColumn(
                          label: Text(languageController.getTranslation('serial_no'),
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text(languageController.getTranslation('date'),
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text(languageController.getTranslation('time_to_expire'),
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text(languageController.getTranslation('name'),
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text(languageController.getTranslation('gross'),
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text(languageController.getTranslation('fee'),
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text(languageController.getTranslation('net'),
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text(languageController.getTranslation('status'),
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
                          DataCell(Text(languageController.getTranslation('funds_availability'))),
                          DataCell(
                              Text('${languageController.getTranslation('money_sent')}\n${languageController.getTranslation('to')} ${transaction.entityName}')),
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
                                languageController.getTranslation('confirm'),
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

  Widget buildPendingMoneyRequestsList(List<dash.PendingMoneyRequest> requests) {
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

  Widget buildPendingMoneyRequest(dash.PendingMoneyRequest request) {
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
  // Method to build deposit button with KYC condition
  Widget buildDepositButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: ElevatedButton(
        onPressed: () {
          // Check KYC status
          if (userProfileController.kyc.value != '3') {
            // Show KYC required message
            Get.dialog(
              AlertDialog(
                title: Text(languageController.getTranslation('kyc_required')),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(languageController.getTranslation('in_order_to_deposit_submit_kyc_first')),
                    SizedBox(height: 10),
                    Text(languageController.getTranslation('visit_website_to_complete_kyc')),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        // Launch URL in browser
                        final url = Uri.parse('$baseUrl');
                        launchUrl(url, mode: LaunchMode.externalApplication);
                      },
                      child: Text(
                        baseUrl,
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            // KYC is approved, navigate to deposit screen
            Get.to(() => ScreenDeposit());
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xff18CE0F),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: Size(double.infinity, 50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: Colors.white),
            SizedBox(width: 10),
            Text(
              languageController.getTranslation('deposit'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to build withdraw button with KYC condition
  Widget buildWithdrawButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: ElevatedButton(
        onPressed: () {
          // Check KYC status
          if (userProfileController.kyc.value != '3') {
            // Show KYC required message
            Get.dialog(
              AlertDialog(
                title: Text(languageController.getTranslation('kyc_required')),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(languageController.getTranslation('in_order_to_withdraw_submit_kyc_first')),
                    SizedBox(height: 10),
                    Text(languageController.getTranslation('visit_website_to_complete_kyc')),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        // Launch URL in browser
                        final url = Uri.parse('$baseUrl');
                        launchUrl(url, mode: LaunchMode.externalApplication);
                      },
                      child: Text(
                        baseUrl,
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            // KYC is approved, navigate to withdraw screen
            Get.to(() => ScreenWithdrawal());
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xffFF6B6B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: Size(double.infinity, 50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.remove_circle_outline, color: Colors.white),
            SizedBox(width: 10),
            Text(
              languageController.getTranslation('withdraw'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewContainer extends StatelessWidget {
  final MenubuttonController controller;

  NewContainer(this.controller);

  final WalletController walletController = Get.put(WalletController());
  final LanguageController languageController = Get.find<LanguageController>();

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
                languageController.getTranslation('select_the_wallet_currency'),
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
                                  return Center(child: Text(languageController.getTranslation('no_currencies_available')));
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
                        leading: Icon(Icons.account_balance_wallet, size: 40, color: Color(0xff484848)),
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

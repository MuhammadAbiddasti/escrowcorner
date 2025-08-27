import 'package:escrowcorner/view/Kyc_screens/screen_kyc1.dart';
import 'package:escrowcorner/view/controller/logout_controller.dart';
import 'package:escrowcorner/widgets/dynamic_branding/dynamic_branding_widgets.dart';
import 'package:escrowcorner/view/screens/escrow_system/cancelled_escrow/get_cancelled_escrow.dart';
import 'package:escrowcorner/view/screens/escrow_system/get_requested_escrow/get_requested_escrow.dart';
import 'package:escrowcorner/view/screens/escrow_system/rejected_escrow/get_rejected_escrow.dart';
import 'package:escrowcorner/view/screens/escrow_system/send_escrow/screen_escrow_list.dart';
import 'package:escrowcorner/view/screens/managers/screen_managers.dart';
import 'package:escrowcorner/view/screens/send_money/screen_get_all_sendmoney.dart';
import 'package:escrowcorner/view/screens/request_money/screen_get_request_money.dart';
import 'package:escrowcorner/view/screens/settings/screen_settings_portion.dart';
import 'package:escrowcorner/widgets/custom_button/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../view/screens/applications/screen_merchant.dart';
import '../../view/screens/escrow_system/received_escrow/get_received_escrow.dart';
import '../../view/screens/escrow_system/request_escrow/request_escrow.dart';
import '../../view/screens/managers/manager_permission_controller.dart';
import '../../view/screens/send_money/controller_sendmoney.dart';
import '../../view/screens/user_profile/user_profile_controller.dart';
import '../../view/controller/language_controller.dart';
import '../../view/screens/dashboard/screen_dashboard.dart';
import '../../view/screens/deposit/screen_my_deposit.dart';
import '../../view/screens/withdraw/screen_my_withdraw.dart';
import '../../view/screens/Transactions/screen_all_transactions.dart';
import '../../view/screens/tickets/screen_support_tickets.dart';
import '../../view/screens/user_profile/screen_person_info.dart';
import '../../view/Home_Screens/screen_home.dart';
import '../../widgets/custom_api_url/constant_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Custom App Bar Leading
// class PopupMenuButtonLeading extends StatefulWidget {
//   @override
//   State<PopupMenuButtonLeading> createState() => _PopupMenuButtonLeadingState();
// }
//
// class _PopupMenuButtonLeadingState extends State<PopupMenuButtonLeading> {
//   bool showSwapOptions = false;
//   String lastSelectedOption = '';
//   final UserProfileController userProfileController =
//       Get.put(UserProfileController());
//
//   @override
//   Widget build(BuildContext context) {
//     return PopupMenuButton<String>(
//       color: Color(0xff0766AD),
//       splashRadius: 5,
//       icon: Icon(
//         Icons.menu,
//         color: Colors.white,
//       ),
//       offset: Offset(0, 50),
//       onSelected: (String result) {
//         // Check if the selected option is the same as the last selected one
//       },
//       itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//         PopupMenuItem<String>(
//           value: 'option1',
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.stacked_bar_chart, color: Colors.white),
//                   TextButton(
//                     child: Text(
//                       "Dashboard",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     onPressed: () {
//                       Get.off(() => ScreenDashboard());
//                     },
//                   ),
//                 ],
//               ),
//               Divider(
//                 color: Color(0xffCDE0EF),
//               )
//             ],
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'option2',
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.arrow_circle_right_outlined, color: Colors.white),
//                   TextButton(
//                     child: Text("Transfer Money",
//                         style: TextStyle(color: Colors.white)),
//                     onPressed: () {
//                       Get.off(() => ScreenGetAllSendMoney());
//                     },
//                   ),
//                 ],
//               ),
//               SizedBox(width: 10),
//               Divider(
//                 color: Color(0xffCDE0EF),
//               )
//             ],
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'option3',
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.arrow_circle_left_outlined, color: Colors.white),
//                   TextButton(
//                     child: Text("Request Money",
//                         style: TextStyle(color: Colors.white)),
//                     onPressed: () {
//                       Get.off(() => ScreenGetRequestMonay());
//                     },
//                   ),
//                 ],
//               ),
//               Divider(
//                 color: Color(0xffCDE0EF),
//               )
//             ],
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'option4',
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.link, color: Colors.white),
//                   TextButton(
//                     child: Text("Payment Link",
//                         style: TextStyle(color: Colors.white)),
//                     onPressed: () {
//                       Get.off(() => ScreenPaymentLinks());
//                     },
//                   ),
//                 ],
//               ),
//               Divider(
//                 color: Color(0xffCDE0EF),
//               )
//             ],
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'option5',
//           child: StatefulBuilder(
//             builder: (BuildContext context, StateSetter setState) {
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.shopping_cart_outlined, color: Colors.white),
//                       TextButton(
//                         child: Text("Escrow System",
//                             style: TextStyle(color: Colors.white)),
//                         onPressed: () {
//                           setState(() {
//                             showSwapOptions = !showSwapOptions;
//                           });
//                         },
//                       ),
//                       Spacer(),
//                       IconButton(
//                         onPressed: () {
//                           setState(() {
//                             showSwapOptions = !showSwapOptions;
//                           });
//                         },
//                         icon: Icon(
//                           showSwapOptions
//                               ? Icons.arrow_drop_up
//                               : Icons.arrow_drop_down,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (showSwapOptions) ...[
//                     PopupMenuItem<String>(
//                       value: 'option6',
//                       child: Row(
//                         children: [
//                           Icon(Icons.arrow_forward, color: Colors.white),
//                           TextButton(
//                             child: Text("Send Escrow",
//                                 style: TextStyle(color: Colors.white)),
//                             onPressed: () {
//                               Get.off(() => ScreenEscrowList());
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem<String>(
//                       value: 'option7',
//                       child: Row(
//                         children: [
//                           Icon(Icons.arrow_forward, color: Colors.white),
//                           TextButton(
//                             child: Text("Request Escrow",
//                                 style: TextStyle(color: Colors.white)),
//                             onPressed: () {
//                               Get.off(() => GetRequestEscrow());
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem<String>(
//                       value: 'option8',
//                       child: Row(
//                         children: [
//                           Icon(Icons.arrow_forward, color: Colors.white),
//                           TextButton(
//                             child: Text("Received Escrow",
//                                 style: TextStyle(color: Colors.white)),
//                             onPressed: () {
//                               Get.off(() => ScreenReceivedEscrow());
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem<String>(
//                       value: 'option9',
//                       child: Row(
//                         children: [
//                           Icon(Icons.arrow_forward, color: Colors.white),
//                           TextButton(
//                             child: Text("Rejected Escrow",
//                                 style: TextStyle(color: Colors.white)),
//                             onPressed: () {
//                               Get.off(() => GetRejectedEscrow());
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem<String>(
//                       value: 'option10',
//                       child: Row(
//                         children: [
//                           Icon(Icons.arrow_forward, color: Colors.white),
//                           TextButton(
//                             child: Text("Requested Escrow",
//                                 style: TextStyle(color: Colors.white)),
//                             onPressed: () {
//                               Get.off(() => GetRequestedEscrow());
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem<String>(
//                       value: 'option11',
//                       child: Row(
//                         children: [
//                           Icon(Icons.arrow_forward, color: Colors.white),
//                           TextButton(
//                             child: Text("Cancelled Escrow",
//                                 style: TextStyle(color: Colors.white)),
//                             onPressed: () {
//                               Get.off(() => GetCancelledEscrow());
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                   Divider(color: Color(0xffCDE0EF)),
//                 ],
//               );
//             },
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'option12',
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.speed, color: Colors.white),
//                   TextButton(
//                     child: Text("Support Tickets",
//                         style: TextStyle(color: Colors.white)),
//                     onPressed: () {
//                       Get.off(() => ScreenSupportTicket());
//                     },
//                   ),
//                 ],
//               ),
//               Divider(
//                 color: Color(0xffCDE0EF),
//               )
//             ],
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'option13',
//           child: StatefulBuilder(
//             builder: (BuildContext context, StateSetter setState) {
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.shopping_cart_outlined, color: Colors.white),
//                       TextButton(
//                         child: Text("Transactions",
//                             style: TextStyle(color: Colors.white)),
//                         onPressed: () {
//                           setState(() {
//                             showSwapOptions = !showSwapOptions;
//                           });
//                         },
//                       ),
//                       Spacer(),
//                       IconButton(
//                         onPressed: () {
//                           setState(() {
//                             showSwapOptions = !showSwapOptions;
//                           });
//                         },
//                         icon: Icon(
//                           showSwapOptions
//                               ? Icons.arrow_drop_up
//                               : Icons.arrow_drop_down,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (showSwapOptions) ...[
//                     PopupMenuItem<String>(
//                       value: 'option14',
//                       child: Row(
//                         children: [
//                           Icon(Icons.arrow_forward, color: Colors.white),
//                           TextButton(
//                             child: Text("My Deposits",
//                                 style: TextStyle(color: Colors.white)),
//                             onPressed: () {
//                               Get.off(() => ScreenMyDeposit());
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem<String>(
//                       value: 'option15',
//                       child: Row(
//                         children: [
//                           Icon(Icons.arrow_forward, color: Colors.white),
//                           TextButton(
//                             child: Text("My Withdrawals",
//                                 style: TextStyle(color: Colors.white)),
//                             onPressed: () {
//                               Get.off(() => ScreenMyWithDraw());
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem<String>(
//                       value: 'option16',
//                       child: Row(
//                         children: [
//                           Icon(Icons.arrow_forward, color: Colors.white),
//                           TextButton(
//                             child: Text("All Transactions",
//                                 style: TextStyle(color: Colors.white)),
//                             onPressed: () {
//                               Get.off(() => ScreenAllTransactions());
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                   Divider(color: Color(0xffCDE0EF)),
//                 ],
//               );
//             },
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'option17',
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.supervisor_account_outlined, color: Colors.white),
//                   TextButton(
//                     child:
//                         Text("Managers", style: TextStyle(color: Colors.white)),
//                     onPressed: () {
//                       Get.off(() => ScreenManagers());
//                     },
//                   ),
//                 ],
//               ),
//               Divider(
//                 color: Color(0xffCDE0EF),
//               )
//             ],
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'option18',
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.settings_outlined, color: Colors.white),
//                   TextButton(
//                     child:
//                         Text("Settings", style: TextStyle(color: Colors.white)),
//                     onPressed: () {
//                       Get.off(() => ScreenSettingsPortion());
//                     },
//                   ),
//                 ],
//               ),
//               Divider(
//                 color: Color(0xffCDE0EF),
//               )
//             ],
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'option19',
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.link, color: Colors.white),
//                   TextButton(
//                     child: Text("My Applications",
//                         style: TextStyle(color: Colors.white)),
//                     onPressed: () {
//                       Get.off(() => ScreenMerchant());
//                     },
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

class CustomPopupMenu extends StatefulWidget {
  final String managerId; // Pass manager ID as an argument.

  CustomPopupMenu({required this.managerId});

  @override
  _CustomPopupMenuState createState() => _CustomPopupMenuState();
}

class _CustomPopupMenuState extends State<CustomPopupMenu> {
  bool isLoading = true; // To show loading indicator
  Map<String, dynamic>? permissions; // Permissions fetched from API
  final ManagersPermissionController controller =
      Get.put(ManagersPermissionController());
  final SendMoneyController sendController = Get.put(SendMoneyController());
  final LanguageController languageController = Get.find<LanguageController>();
  bool showSwapOptions = false;
  String lastSelectedOption = '';

  UserProfileController get userProfileController => getUserProfileController();

  @override
  void initState() {
    super.initState();
    //controller.fetchManagerPermissions(widget.managerId);
    sendController.fetchUnreadTransferMoneyCount();
    sendController.fetchUnreadRequestMoneyCount();
    sendController.fetchUnreadSupportTicketCount();
    controller.onPermissionUpdateNotification(
        userProfileController.userId.value);
  }
  @override
  Widget build(BuildContext context) {
    // controller.fetchManagerPermissions(widget.managerId);
    return Obx(() {
      final isManager = userProfileController.isManager.value == '1';
      final allowedModules = controller.allowedModules;

      print("Is Manager: $isManager");
      print("Allowed Modules: $allowedModules");

      // Show loading if the manager's allowed modules are not loaded yet
      if (isManager && allowedModules.isEmpty) {
        return Center(
            child: IconButton(
                onPressed: () {
                  controller.onPermissionUpdateNotification(
                      userProfileController.userId.value);
                },
                icon: Icon(Icons.menu, color: Colors.white)));
      }

      return PopupMenuButton<String>(
        color: Color(0xff191f28),
        splashRadius: 5,
        icon: Icon(Icons.menu, color: Colors.white),
        offset: Offset(0, 50),
        onSelected: (String result) {

        },
        itemBuilder: (BuildContext context) {
          return isManager
              ? _buildManagerMenuItems(allowedModules)
              : _buildNonManagerMenuItems();
        },
      );
    });
  }

  List<PopupMenuEntry<String>> _buildManagerMenuItems(
      RxList<String> allowedModules) {
    bool showSwapOptions = false;
    bool showTransactionOptions = false;

    List<Widget> _buildEscrowSubMenuItems() {
      List<Widget> subMenuItems = [];
      if (allowedModules.contains('Received Escrow')) {
        subMenuItems.add(_buildEscrowMenuItem(
          icon: Icons.arrow_forward,
          label: languageController.getTranslation('received_escrow'),
          onTap: () => Get.off(() => ScreenReceivedEscrow()),
        ));
      }
      if (allowedModules.contains('Rejected Escrow')) {
        subMenuItems.add(_buildEscrowMenuItem(
          icon: Icons.arrow_forward,
          label: languageController.getTranslation('rejected_escrow'),
          onTap: () => Get.off(() => GetRejectedEscrow()),
        ));
      }
      if (allowedModules.contains('Requested Escrow')) {
        subMenuItems.add(_buildEscrowMenuItem(
          icon: Icons.arrow_forward,
          label: languageController.getTranslation('requested_escrow'),
          onTap: () => Get.off(() => GetRequestedEscrow()),
        ));
      }
      if (allowedModules.contains('Cancelled Escrow')) {
        subMenuItems.add(_buildEscrowMenuItem(
          icon: Icons.arrow_forward,
          label: languageController.getTranslation('cancelled_escrow'),
          onTap: () => Get.off(() => GetCancelledEscrow()),
        ));
      }
      return subMenuItems;
    }

    List<Widget> _buildTransactionSubMenuItems() {
      List<Widget> subMenuItems = [];
      if (allowedModules.contains('My Deposits')) {
        subMenuItems.add(_buildEscrowMenuItem(
          icon: Icons.arrow_forward,
          label: languageController.getTranslation('my_deposits'),
          onTap: () => Get.off(() => ScreenMyDeposit()),
        ));
      }
      if (allowedModules.contains('My Withdrawals')) {
        subMenuItems.add(_buildEscrowMenuItem(
          icon: Icons.arrow_forward,
          label: languageController.getTranslation('my_withdrawals'),
          onTap: () => Get.off(() => ScreenMyWithDraw()),
        ));
      }
      if (allowedModules.contains('All Transactions')) {
        subMenuItems.add(_buildEscrowMenuItem(
          icon: Icons.arrow_forward,
          label: languageController.getTranslation('all_transactions'),
          onTap: () => Get.off(() => ScreenAllTransactions()),
        ));
      }
      // API transaction items are only shown for non-manager users under "All Transactions"
      return subMenuItems;
    }

    return allowedModules
        .map((module) {
          switch (module) {
            case 'Home':
              return PopupMenuItem<String>(
                value: 'home',
                child: _buildMenuItem(
                  icon: Icons.home,
                  label: languageController.getTranslation('home'),
                  onTap: () => Get.off(() => ScreenHome()),
                ),
              );
            case 'Dashboard':
              return PopupMenuItem<String>(
                value: 'dashboard',
                child: _buildMenuItem(
                  icon: Icons.stacked_bar_chart,
                  label: languageController.getTranslation('dashboard'),
                  onTap: () => Get.off(() => ScreenDashboard()),
                ),
              );
            case 'Send Escrow':
              return PopupMenuItem<String>(
                value: 'send_escrow',
                child: _buildMenuItem(
                  icon: Icons.arrow_forward,
                  label: languageController.getTranslation('send_escrow'),
                  onTap: () => Get.off(() => ScreenEscrowList()),
                ),
              );
            case 'Request Escrow':
              return PopupMenuItem<String>(
                value: 'request_escrow',
                child: _buildMenuItem(
                  icon: Icons.arrow_forward,
                  label: languageController.getTranslation('request_escrow'),
                  onTap: () => Get.off(() => GetRequestEscrow()),
                ),
              );
            case 'Escrow History':
              final escrowSubMenuItems = _buildEscrowSubMenuItems();
              return PopupMenuItem<String>(
                value: 'escrow_system',
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.shopping_cart_outlined,
                                color: Colors.white),
                            TextButton(
                              child: Text(languageController.getTranslation('escrow_history'),
                                  style: TextStyle(color: Colors.white)),
                              onPressed: () {
                                setState(() {
                                  showSwapOptions = !showSwapOptions;
                                });
                              },
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  showSwapOptions = !showSwapOptions;
                                });
                              },
                              icon: Icon(
                                showSwapOptions
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        if (showSwapOptions) ...escrowSubMenuItems,
                      ],
                    );
                  },
                ),
              );
            case 'Transactions':
              final transactionSubMenuItems = _buildTransactionSubMenuItems();
              return PopupMenuItem<String>(
                value: 'transaction',
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.shopping_cart_outlined,
                                color: Colors.white),
                            TextButton(
                              child: Text(languageController.getTranslation('transactions'),
                                  style: TextStyle(color: Colors.white)),
                              onPressed: () {
                                setState(() {
                                  showTransactionOptions =
                                      !showTransactionOptions;
                                });
                              },
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  showTransactionOptions =
                                      !showTransactionOptions;
                                });
                              },
                              icon: Icon(
                                showTransactionOptions
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        if (showTransactionOptions) ...transactionSubMenuItems,
                      ],
                    );
                  },
                ),
              );
            case 'Managers':
              return PopupMenuItem<String>(
                value: 'manager',
                child: _buildMenuItem(
                  icon: Icons.supervisor_account_outlined,
                  label: languageController.getTranslation('managers'),
                  onTap: () => Get.off(() => ScreenManagers()),
                ),
              );
            case 'Settings':
              return PopupMenuItem<String>(
                value: 'settings',
                child: _buildMenuItem(
                  icon: Icons.settings_outlined,
                  label: languageController.getTranslation('settings'),
                  onTap: () => Get.off(() => ScreenSettingsPortion()),
                ),
              );
            case 'My Sub Accounts':
              return PopupMenuItem<String>(
                value: 'my_sub_accounts',
                child: _buildMenuItem(
                  icon: Icons.link,
                  label: languageController.getTranslation('my_sub_accounts'),
                  onTap: () => Get.off(() => ScreenMerchant()),
                ),
              );
              case 'Customers Support':
              return PopupMenuItem<String>(
                value: 'support_ticket',
                child:_buildNotificationMenuItem(
                  icon: Icons.link,
                  label: languageController.getTranslation('customer_support'),
                  onTap: () => Get.off(() => ScreenSupportTicket()),
                  unreadCount: sendController.unreadSupportTicketCount.value,
                ),
              );
            default:
              return null; // Ensure nothing is returned for unhandled cases
          }
        })
        .whereType<PopupMenuEntry<String>>()
        .toList()
      ..addAll([
        // Home menu item - always available for logged-in users
        PopupMenuItem<String>(
          value: 'home',
          child: _buildMenuItem(
            icon: Icons.home,
            label: languageController.getTranslation('home'),
            onTap: () => Get.off(() => ScreenHome()),
          ),
        ),
        PopupMenuItem<String>(
          value: 'escrow_system',
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shopping_cart_outlined, color: Colors.white),
                      TextButton(
                        child: Text(languageController.getTranslation('escrow_history'),
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          setState(() {
                            showSwapOptions = !showSwapOptions;
                          });
                        },
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            showSwapOptions = !showSwapOptions;
                          });
                        },
                        icon: Icon(
                          showSwapOptions
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (showSwapOptions) ..._buildEscrowSubMenuItems(),
                ],
              );
            },
          ),
        ),
        PopupMenuItem<String>(
          value: 'transaction',
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shopping_cart_outlined, color: Colors.white),
                      TextButton(
                        child: Text(languageController.getTranslation('transactions'),
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          setState(() {
                            showTransactionOptions = !showTransactionOptions;
                          });
                        },
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            showTransactionOptions = !showTransactionOptions;
                          });
                        },
                        icon: Icon(
                          showTransactionOptions
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (showTransactionOptions)
                    ..._buildTransactionSubMenuItems(),
                ],
              );
            },
          ),
        ),
      ]);
  }

  List<PopupMenuEntry<String>> _buildNonManagerMenuItems() {
    return [
      // Home menu item - always available for logged-in users
      PopupMenuItem<String>(
        value: 'home',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.home, color: Colors.white),
                TextButton(
                  child: Text(
                    languageController.getTranslation('home'),
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Get.off(() => ScreenHome());
                  },
                ),
              ],
            ),
            Divider(
              color: Color(0xffCDE0EF),
            )
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'option1',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.stacked_bar_chart, color: Colors.white),
                TextButton(
                  child: Text(
                    languageController.getTranslation('dashboard'),
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Get.off(() => ScreenDashboard());
                  },
                ),
              ],
            ),
            Divider(
              color: Color(0xffCDE0EF),
            )
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'send_escrow',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.arrow_forward, color: Colors.white),
                TextButton(
                  child: Text(languageController.getTranslation('send_escrow'),
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Get.off(() => ScreenEscrowList());
                  },
                ),
              ],
            ),
            Divider(
              color: Color(0xffCDE0EF),
            )
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'request_escrow',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.arrow_forward, color: Colors.white),
                TextButton(
                  child: Text(languageController.getTranslation('request_escrow'),
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Get.off(() => GetRequestEscrow());
                  },
                ),
              ],
            ),
            Divider(
              color: Color(0xffCDE0EF),
            )
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'option5',
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shopping_cart_outlined, color: Colors.white),
                    TextButton(
                      child: Text(languageController.getTranslation('escrow_history'),
                          style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        setState(() {
                          showSwapOptions = !showSwapOptions;
                        });
                      },
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          showSwapOptions = !showSwapOptions;
                        });
                      },
                      icon: Icon(
                        showSwapOptions
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (showSwapOptions) ...[
                  PopupMenuItem<String>(
                    value: 'option8',
                    child: Row(
                      children: [
                        Icon(Icons.arrow_forward, color: Colors.white),
                        TextButton(
                          child: Text(languageController.getTranslation('received_escrow'),
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            Get.off(() => ScreenReceivedEscrow());
                          },
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'option9',
                    child: Row(
                      children: [
                        Icon(Icons.arrow_forward, color: Colors.white),
                        TextButton(
                          child: Text(languageController.getTranslation('rejected_escrow'),
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            Get.off(() => GetRejectedEscrow());
                          },
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'option10',
                    child: Row(
                      children: [
                        Icon(Icons.arrow_forward, color: Colors.white),
                        TextButton(
                          child: Text(languageController.getTranslation('requested_escrow'),
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            Get.off(() => GetRequestedEscrow());
                          },
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'option11',
                    child: Row(
                      children: [
                        Icon(Icons.arrow_forward, color: Colors.white),
                        TextButton(
                          child: Text(languageController.getTranslation('cancelled_escrow'),
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            Get.off(() => GetCancelledEscrow());
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                Divider(color: Color(0xffCDE0EF)),
              ],
            );
          },
        ),
      ),
      PopupMenuItem<String>(
        value: 'option12',
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shopping_cart_outlined, color: Colors.white),
                    TextButton(
                      child: Text(languageController.getTranslation('transactions'),
                          style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        setState(() {
                          showSwapOptions = !showSwapOptions;
                        });
                      },
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          showSwapOptions = !showSwapOptions;
                        });
                      },
                      icon: Icon(
                        showSwapOptions
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (showSwapOptions) ...[
                  PopupMenuItem<String>(
                    value: 'option13',
                    child: Row(
                      children: [
                        Icon(Icons.arrow_forward, color: Colors.white),
                        TextButton(
                          child: Text(languageController.getTranslation('my_deposits'),
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            Get.off(() => ScreenMyDeposit());
                          },
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'option14',
                    child: Row(
                      children: [
                        Icon(Icons.arrow_forward, color: Colors.white),
                        TextButton(
                          child: Text(languageController.getTranslation('my_withdrawals'),
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            Get.off(() => ScreenMyWithDraw());
                          },
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'option15',
                    child: Row(
                      children: [
                        Icon(Icons.arrow_forward, color: Colors.white),
                        TextButton(
                          child: Text(languageController.getTranslation('all_transactions'),
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            Get.off(() => ScreenAllTransactions());
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                Divider(color: Color(0xffCDE0EF)),
              ],
            );
          },
        ),
      ),
      PopupMenuItem<String>(
        value: 'option16',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.supervisor_account_outlined, color: Colors.white),
                TextButton(
                  child:
                      Text(languageController.getTranslation('managers'), style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Get.off(() => ScreenManagers());
                  },
                ),
              ],
            ),
            Divider(
              color: Color(0xffCDE0EF),
            )
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'option17',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings_outlined, color: Colors.white),
                TextButton(
                  child:
                      Text(languageController.getTranslation('settings'), style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Get.off(() => ScreenSettingsPortion());
                  },
                ),
              ],
            ),
            Divider(
              color: Color(0xffCDE0EF),
            )
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'option18',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.link, color: Colors.white),
                TextButton(
                  child: Text(languageController.getTranslation('my_sub_accounts'),
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Get.off(() => ScreenMerchant());
                  },
                ),
              ],
            ),
            Divider(
              color: Color(0xffCDE0EF),
            )
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'option19',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed, color: Colors.white),
                TextButton(
                  child: Text(languageController.getTranslation('customer_support'),
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Get.off(() => ScreenSupportTicket());
                  },
                ),
                SizedBox(width: 10),
                Obx(() {
                  // Check if the value is greater than 0
                  if (sendController.unreadSupportTicketCount.value > 0) {
                    return Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        // The container's background remains transparent
                        border: Border.all(
                          color: Colors.red, // White border
                          width: 2.0, // Adjust the thickness of the border
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          "${sendController.unreadSupportTicketCount.value}",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  } else {
                    return SizedBox
                        .shrink(); // Return an empty widget if the value is 0
                  }
                })
              ],
            ),
          ],
        ),
      ),
      // Add more static menu items for non-managers...
    ];
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white),
            TextButton(
              onPressed: onTap,
              child: Text(
                label,
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
        Divider(
          color: Color(0xffCDE0EF),
        )
      ],
    );
  }

  Widget _buildNotificationMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required int unreadCount, // Add a parameter for the unread count
  }) {
    if (unreadCount > 0) {
      // Show the container when the count is greater than zero
      return Column(
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white),
              TextButton(
                onPressed: onTap,
                child: Text(
                  label,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 10),
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  // The container's background remains transparent
                  border: Border.all(
                    color: Colors.red, // White border
                    width: 2.0, // Adjust the thickness of the border
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(
                    unreadCount.toString(),
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
          Divider(
            color: Color(0xffCDE0EF),
          )
        ],
      );
    } else {
      // Show the standard menu item when the count is zero
      return Column(
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white),
              TextButton(
                onPressed: onTap,
                child: Text(
                  label,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
          Divider(
            color: Color(0xffCDE0EF),
          )
        ],
      );
    }
  }

  Widget _buildEscrowMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 8),
            TextButton(
              onPressed: onTap,
              child: Text(
                label,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AppBarTitle extends StatelessWidget {
//LogoController logoController = Get.put(LogoController());
  @override
  Widget build(BuildContext context) {
    return Container(
      child: DynamicLogoWidget(
        height: 40,
        fit: BoxFit.contain,
      ),
      //Obx(() => LogoWidget(logoController.logoUrl.value)),
    );
  }
}

//Custom Languages in App Bar [Action]
class PopupMenuButtonAction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
    // return PopupMenuButton<String>(
    //   icon: Icon(Icons.language,color: Colors.transparent,size: 30,),
    // onSelected: (String result) {
    // },
    //   itemBuilder: (BuildContext context) =>
    //   <PopupMenuEntry<String>>[
    //     PopupMenuItem<String>(
    //       value: 'US',
    //       child: Text('English'),
    //     ),
    //     PopupMenuItem<String>(
    //       value: 'FR',
    //       child: Text('French'),
    //     ),
    //     PopupMenuItem<String>(
    //       value: 'CH',
    //       child: Text('Chinese'),
    //     ),
    //     PopupMenuItem<String>(
    //       value: 'PT',
    //       child: Text('Portuguese'),
    //     ),
    //     PopupMenuItem<String>(
    //       value: 'SP',
    //       child: Text('Spanish'),
    //     ),
    //   ],
    // );
  }
}

// Custom Profile Button in App Bar [Action]
class AppBarProfileButton extends StatelessWidget {
  final ManagersPermissionController controller =
      Get.put(ManagersPermissionController());
  final LogoutController logoutController = Get.put(LogoutController());
  final LanguageController languageController = Get.find<LanguageController>();

  UserProfileController get userProfileController => getUserProfileController();

  void initState() {
    controller.fetchManagerPermissions(userProfileController.userId.value);
  }

  @override
  Widget build(BuildContext context) {
    final isManager = userProfileController.isManager.value == '1';
    final allowedModules = controller.allowedModules;
    // Ensure user details are loaded when logged in so the username shows
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if ((token != null && token.isNotEmpty) && userProfileController.userName.value.isEmpty) {
          await userProfileController.fetchUserDetails();
        }
      } catch (e) {
        // ignore errors silently
      }
    });
    return PopupMenuButton<String>(
      color: Colors.white,
      icon: Obx(() {
        // Check if a custom avatar file is available
        if (userProfileController.avatar.value != null &&
            userProfileController.avatar.value!.path.isNotEmpty) {
          return CircleAvatar(
            backgroundImage: FileImage(userProfileController.avatar.value!),
            radius: 15, // Adjust the size as needed
          );
        }
        // Check if a URL image is available and is not the default image
        else if (userProfileController.avatarUrl.value.isNotEmpty &&
            !userProfileController.avatarUrl.value
                .toLowerCase()
                .contains("default")) {
          return CircleAvatar(
            backgroundImage: NetworkImage(
                "$baseUrl/${userProfileController.avatarUrl.value}"),
            radius: 15, // Adjust the size as needed
          );
        }
        // Default icon
        else {
          return Icon(
            Icons.account_circle,
            color: Color(0xffFEAF39),
            size: 30,
          );
        }
      }),
      onSelected: (String result) {},
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          child: Obx(() {
            final name = userProfileController.userName.value;
            return Text(
              name.isNotEmpty ? name.toUpperCase() : languageController.getTranslation('profile'),
              style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w700, fontSize: 14),
            );
          }),
        ),
        PopupMenuItem<String>(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 24,
              width: MediaQuery.of(context).size.width * .35,
              decoration: BoxDecoration(
                  border: Border.all(color: Color(0xff18CE0F), width: 1),
                  borderRadius: BorderRadius.circular(5)),
              child: Center(
                child: Text(
                  languageController.getTranslation('verified'),
                  // "SP#${userProfileController.id.value}",
                  style: TextStyle(
                      color: Color(0xff18CE0F),
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Divider(
              color: Color(0xffDDDDDD),
            ),
            Container(
              height: 35,
              child: ListTile(
                onTap: () {
                  Get.to(ScreenDashboard());
                },
                leading: Icon(Icons.dashboard_outlined, size: 25),
                title: Text(
                  languageController.getTranslation('dashboard'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Divider(
              color: Color(0xffDDDDDD),
            ),
            Container(
              height: 35,
              child: ListTile(
                onTap: () async {
                  await userProfileController.fetchUserDetails();
                  Get.to(ScreenKyc1());
                },
                leading: Icon(Icons.verified_outlined, size: 25),
                title: Text(
                  languageController.getTranslation('general_kyc'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            )
          ],
        )),
        PopupMenuItem<String>(
          child: Container(
            height: 35,
            child: ListTile(
              onTap: () async {
                await userProfileController.fetchUserDetails();
                Get.to(ScreenPersonInfo());
              },
              leading: Icon(
                Icons.person_outline,
                size: 30,
              ),
              //Image.asset('assets/images/user.png'),
              title: Text(languageController.getTranslation('profile'),
                  style: TextStyle(
                      //color: Color(0xff18CE0F),
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
          ),
        ),
        if (isManager && allowedModules.contains('Settings'))
          PopupMenuItem<String>(
            child: GestureDetector(
              onTap: () {
                Get.to(ScreenSettingsPortion());
              },
              child: Container(
                height: 40,
                child: ListTile(
                  leading: Icon(
                    Icons.settings_outlined,
                    size: 26,
                  ),
                  title: Obx(() {
                    final _ = languageController.selectedLanguage.value;
                    return Text(
                      languageController.getTranslation('settings'),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    );
                  }),
                ),
              ),
            ),
          ),
        if (userProfileController.isManager.value == '0')
          PopupMenuItem<String>(
            child: GestureDetector(
              onTap: () {
                Get.to(ScreenSettingsPortion());
              },
              child: Container(
                height: 40,
                child: ListTile(
                  leading: Icon(
                    Icons.settings_outlined,
                    size: 26,
                  ),
                  title: Obx(() {
                    final _ = languageController.selectedLanguage.value;
                    return Text(
                      languageController.getTranslation('settings'),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    );
                  }),
                ),
              ),
            ),
          ),
        PopupMenuItem<String>(
          child: GestureDetector(
            onTap: () {
              showDeleteConfirmationDialog(context);
            },
            child: Container(
              height: 40,
              child: ListTile(
                leading: Image.asset(
                  'assets/images/logout.png',
                  height: 25,
                  width: 25,
                ),
                //Icon(Icons.logout, size: 26,)
                //color: Color(0xffFEAF39),),
                title: Text(languageController.getTranslation('logout'),
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
              ),
            ),
          ),
        ),
      ],
    );
  }
  void showDeleteConfirmationDialog(BuildContext context) {
    Get.defaultDialog(
      title: "",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, color: Colors.orange, size: 40),
          SizedBox(height: 10),
          Obx(() {
            final _ = languageController.selectedLanguage.value;
            return Text(
              languageController.getTranslation('are_you_sure'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            );
          }),
          SizedBox(height: 8),
          Obx(() {
            final _ = languageController.selectedLanguage.value;
            return Text(
              languageController.getTranslation('confirm_logout'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            );
          }),
        ],
      ),
      actions: [
        Obx(() => CustomButton(width: 95,
            text: languageController.getTranslation('cancel'), onPressed: (){
          Get.back();
        })),
        Obx(() => CustomButton(width: 140,
          backGroundColor: Colors.red,
          text: languageController.getTranslation('yes_logout'), onPressed: () {
    logoutController.logout(context);
    },
        ))
      ],
    );
  }

}

//PopupMenuButton<String>(
//         color: Color(0xff0766AD),
//         splashRadius: 5,
//         icon: Icon(
//           Icons.menu,
//           color: Colors.white,
//         ),
//         offset: Offset(0, 50),
//         onSelected: (String result) {
//           if (userProfileController.isManager.value == 1) {
//             // Handle non-manager selection
//             // For example:
//             controller.fetchManagerPermissions(userProfileController.userId.value.toString());
//           } else {
//             // Handle manager selection
//           }
//         },
//         itemBuilder: (BuildContext context) {
//           if (userProfileController.isManager.value == 0) {
//             return <PopupMenuEntry<String>>[
//               if (controller.allowedModules.contains('Dashboard')) ...[
//                 PopupMenuItem<String>(
//                   value: 'option1',
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.stacked_bar_chart, color: Colors.white),
//                           TextButton(
//                             child: Text("Dashboard",
//                                 style: TextStyle(color: Colors.white)),
//                             onPressed: () {
//                               Get.off(() => ScreenDashboard());
//                             },
//                           ),
//                         ],
//                       ),
//                       Divider(
//                         color: Color(0xffCDE0EF),
//                       )
//                     ],
//                   ),
//                 ),],
//               if (controller.allowedModules.contains('Transfer Money')) ...[
//                 PopupMenuItem<String>(
//                   value: 'option2',
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.arrow_circle_right_outlined,
//                               color: Colors.white),
//                           TextButton(
//                             child: Text("Transfer Money",
//                                 style: TextStyle(color: Colors.white)),
//                             onPressed: () {
//                               Get.off(() => ScreenGetAllSendMoney());
//                             },
//                           ),
//                         ],
//                       ),
//                       Divider(
//                         color: Color(0xffCDE0EF),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//               if (controller.allowedModules.contains('Request Money')) ...[
//                 PopupMenuItem<String>(
//                   value: 'option3',
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.arrow_circle_left_outlined,
//                               color: Colors.white),
//                           TextButton(
//                             child: Text("Request Money",
//                                 style: TextStyle(color: Colors.white)),
//                             onPressed: () {
//                               Get.off(() => ScreenGetRequestMonay());
//                             },
//                           ),
//                         ],
//                       ),
//                       Divider(
//                         color: Color(0xffCDE0EF),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//               if (controller.allowedModules.contains('Payment Link')) ...[
//                 PopupMenuItem<String>(
//                   value: 'option4',
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.arrow_circle_left_outlined,
//                               color: Colors.white),
//                           TextButton(
//                             child: Text("Payment Link",
//                                 style: TextStyle(color: Colors.white)),
//                             onPressed: () {
//                               Get.off(() => ScreenPaymentLinks());
//                             },
//                           ),
//                         ],
//                       ),
//                       Divider(
//                         color: Color(0xffCDE0EF),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//
//               PopupMenuItem<String>(
//                 value: 'option5',
//                 child: StatefulBuilder(
//                   builder: (BuildContext context, StateSetter setState) {
//                     return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(Icons.shopping_cart_outlined,
//                                   color: Colors.white),
//                               TextButton(
//                                 child: Text("Escrow System",
//                                     style: TextStyle(color: Colors.white)),
//                                 onPressed: () {
//                                   setState(() {
//                                     showSwapOptions = !showSwapOptions;
//                                   });
//                                 },
//                               ),
//                               Spacer(),
//                               IconButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     showSwapOptions = !showSwapOptions;
//                                   });
//                                 },
//                                 icon: Icon(
//                                   showSwapOptions
//                                       ? Icons.arrow_drop_up
//                                       : Icons.arrow_drop_down,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           if (showSwapOptions) ...[
//                             // Dynamically show options based on allowed modules
//                             if (controller.allowedModules
//                                 .contains("Send Escrow"))
//                               PopupMenuItem<String>(
//                                 value: 'option6',
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.arrow_forward,
//                                         color: Colors.white),
//                                     TextButton(
//                                       child: Text("Send Escrow",
//                                           style:
//                                           TextStyle(color: Colors.white)),
//                                       onPressed: () {
//                                         Get.off(() => ScreenEscrowList());
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             if (controller.allowedModules
//                                 .contains("Request Escrow"))
//                               PopupMenuItem<String>(
//                                 value: 'option7',
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.arrow_forward,
//                                         color: Colors.white),
//                                     TextButton(
//                                       child: Text("Request Escrow",
//                                           style:
//                                           TextStyle(color: Colors.white)),
//                                       onPressed: () {
//                                         Get.off(() => GetRequestEscrow());
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             if (controller.allowedModules
//                                 .contains("Received Escrow"))
//                               PopupMenuItem<String>(
//                                 value: 'option8',
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.arrow_forward,
//                                         color: Colors.white),
//                                     TextButton(
//                                       child: Text("Received Escrow",
//                                           style:
//                                           TextStyle(color: Colors.white)),
//                                       onPressed: () {
//                                         Get.off(() => ScreenReceivedEscrow());
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             if (controller.allowedModules
//                                 .contains("Rejected Escrow"))
//                               PopupMenuItem<String>(
//                                 value: 'option9',
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.arrow_forward,
//                                         color: Colors.white),
//                                     TextButton(
//                                       child: Text("Rejected Escrow",
//                                           style:
//                                           TextStyle(color: Colors.white)),
//                                       onPressed: () {
//                                         Get.off(() => GetRejectedEscrow());
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             if (controller.allowedModules
//                                 .contains("Requested Escrow"))
//                               PopupMenuItem<String>(
//                                 value: 'option10',
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.arrow_forward,
//                                         color: Colors.white),
//                                     TextButton(
//                                       child: Text("Requested Escrow",
//                                           style:
//                                           TextStyle(color: Colors.white)),
//                                       onPressed: () {
//                                         Get.off(() => GetRequestedEscrow());
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             if (controller.allowedModules
//                                 .contains("Cancelled Escrow"))
//                               PopupMenuItem<String>(
//                                 value: 'option11',
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.arrow_forward,
//                                         color: Colors.white),
//                                     TextButton(
//                                       child: Text("Cancelled Escrow",
//                                           style:
//                                           TextStyle(color: Colors.white)),
//                                       onPressed: () {
//                                         Get.off(() => GetCancelledEscrow());
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                           ],
//                           Divider(color: Color(0xffCDE0EF)),
//                         ]);
//                   },
//                 ),
//               ),
//               if (controller.allowedModules.contains('Support Ticket')) ...[
//                 PopupMenuItem<String>(
//                   value: 'option12',
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.speed, color: Colors.white),
//                           TextButton(
//                             child: Text("Support Tickets",
//                                 style: TextStyle(color: Colors.white)),
//                             onPressed: () {
//                               Get.off(() => ScreenSupportTicket());
//                             },
//                           ),
//                         ],
//                       ),
//                       Divider(
//                         color: Color(0xffCDE0EF),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//               // if (controller.allowedModules.contains('All Transactions My Deposit My Withdrawals',)) ...[
//               PopupMenuItem<String>(
//                 value: 'option13',
//                 child: StatefulBuilder(
//                   builder: (BuildContext context, StateSetter setState) {
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(Icons.shopping_cart_outlined,
//                                 color: Colors.white),
//                             TextButton(
//                               child: Text("Transactions",
//                                   style: TextStyle(color: Colors.white)),
//                               onPressed: () {
//                                 setState(() {
//                                   showSwapOptions = !showSwapOptions;
//                                 });
//                               },
//                             ),
//                             Spacer(),
//                             IconButton(
//                               onPressed: () {
//                                 setState(() {
//                                   showSwapOptions = !showSwapOptions;
//                                 });
//                               },
//                               icon: Icon(
//                                 showSwapOptions
//                                     ? Icons.arrow_drop_up
//                                     : Icons.arrow_drop_down,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                         if (showSwapOptions) ...[
//                           if (controller.allowedModules
//                               .contains('My Deposits')) ...[
//                             PopupMenuItem<String>(
//                               value: 'option14',
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.arrow_forward,
//                                       color: Colors.white),
//                                   TextButton(
//                                     child: Text("My Deposits",
//                                         style: TextStyle(color: Colors.white)),
//                                     onPressed: () {
//                                       Get.off(() => ScreenMyDeposit());
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             if (controller.allowedModules
//                                 .contains('My Withdrawals')) ...[
//                               PopupMenuItem<String>(
//                                 value: 'option15',
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.arrow_forward,
//                                         color: Colors.white),
//                                     TextButton(
//                                       child: Text("My Withdrawals",
//                                           style:
//                                           TextStyle(color: Colors.white)),
//                                       onPressed: () {
//                                         Get.off(() => ScreenMyWithDraw());
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ]
//                           ],
//                           if (controller.allowedModules
//                               .contains('All Transactions')) ...[
//                             PopupMenuItem<String>(
//                               value: 'option16',
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.arrow_forward,
//                                       color: Colors.white),
//                                   TextButton(
//                                     child: Text("All Transactions",
//                                         style: TextStyle(color: Colors.white)),
//                                     onPressed: () {
//                                       Get.off(() => ScreenAllTransactions());
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ],
//                         Divider(color: Color(0xffCDE0EF)),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//               if (controller.allowedModules.contains('Managers')) ...[
//                 PopupMenuItem<String>(
//                   value: 'option17',
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.supervisor_account_outlined,
//                               color: Colors.white),
//                           TextButton(
//                             child: Text("Managers",
//                                 style: TextStyle(color: Colors.white)),
//                             onPressed: () {
//                               Get.off(() => ScreenManagers());
//                             },
//                           ),
//                         ],
//                       ),
//                       Divider(
//                         color: Color(0xffCDE0EF),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//               if (controller.allowedModules.contains('Settings')) ...[
//                 PopupMenuItem<String>(
//                   value: 'option18',
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.settings_outlined, color: Colors.white),
//                           TextButton(
//                             child: Text("Settings",
//                                 style: TextStyle(color: Colors.white)),
//                             onPressed: () {
//                               Get.off(() => ScreenSettingsPortion());
//                             },
//                           ),
//                         ],
//                       ),
//                       Divider(
//                         color: Color(0xffCDE0EF),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//               if (controller.allowedModules.contains('My Application')) ...[
//                 PopupMenuItem<String>(
//                   value: 'option19',
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.link, color: Colors.white),
//                           TextButton(
//                             child: Text("My Applications",
//                                 style: TextStyle(color: Colors.white)),
//                             onPressed: () {
//                               Get.off(() => ScreenMerchant());
//                             },
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//
//               // Add other options similarly
//             ];
//           } else {
//             return <PopupMenuEntry<String>>[
//               PopupMenuItem<String>(
//                 value: 'option1',
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.stacked_bar_chart, color: Colors.white),
//                         TextButton(
//                           child: Text(
//                             "Dashboard",
//                             style: TextStyle(color: Colors.white),
//                           ),
//                           onPressed: () {
//                             Get.off(() => ScreenDashboard());
//                           },
//                         ),
//                       ],
//                     ),
//                     Divider(
//                       color: Color(0xffCDE0EF),
//                     )
//                   ],
//                 ),
//               ),
//               PopupMenuItem<String>(
//                 value: 'option2',
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.arrow_circle_right_outlined, color: Colors.white),
//                         TextButton(
//                           child: Text("Transfer Money",
//                               style: TextStyle(color: Colors.white)),
//                           onPressed: () {
//                             Get.off(() => ScreenGetAllSendMoney());
//                           },
//                         ),
//                       ],
//                     ),
//                     SizedBox(width: 10),
//                     Divider(
//                       color: Color(0xffCDE0EF),
//                     )
//                   ],
//                 ),
//               ),
//               PopupMenuItem<String>(
//                 value: 'option3',
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.arrow_circle_left_outlined, color: Colors.white),
//                         TextButton(
//                           child: Text("Request Money",
//                               style: TextStyle(color: Colors.white)),
//                           onPressed: () {
//                             Get.off(() => ScreenGetRequestMonay());
//                           },
//                         ),
//                       ],
//                     ),
//                     Divider(
//                       color: Color(0xffCDE0EF),
//                     )
//                   ],
//                 ),
//               ),
//               PopupMenuItem<String>(
//                 value: 'option4',
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.link, color: Colors.white),
//                         TextButton(
//                           child: Text("Payment Link",
//                               style: TextStyle(color: Colors.white)),
//                           onPressed: () {
//                             Get.off(() => ScreenPaymentLinks());
//                           },
//                         ),
//                       ],
//                     ),
//                     Divider(
//                       color: Color(0xffCDE0EF),
//                     )
//                   ],
//                 ),
//               ),
//               PopupMenuItem<String>(
//                 value: 'option5',
//                 child: StatefulBuilder(
//                   builder: (BuildContext context, StateSetter setState) {
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(Icons.shopping_cart_outlined, color: Colors.white),
//                             TextButton(
//                               child: Text("Escrow System",
//                                   style: TextStyle(color: Colors.white)),
//                               onPressed: () {
//                                 setState(() {
//                                   showSwapOptions = !showSwapOptions;
//                                 });
//                               },
//                             ),
//                             Spacer(),
//                             IconButton(
//                               onPressed: () {
//                                 setState(() {
//                                   showSwapOptions = !showSwapOptions;
//                                 });
//                               },
//                               icon: Icon(
//                                 showSwapOptions
//                                     ? Icons.arrow_drop_up
//                                     : Icons.arrow_drop_down,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                         if (showSwapOptions) ...[
//                           PopupMenuItem<String>(
//                             value: 'option6',
//                             child: Row(
//                               children: [
//                                 Icon(Icons.arrow_forward, color: Colors.white),
//                                 TextButton(
//                                   child: Text("Send Escrow",
//                                       style: TextStyle(color: Colors.white)),
//                                   onPressed: () {
//                                     Get.off(() => ScreenEscrowList());
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                           PopupMenuItem<String>(
//                             value: 'option7',
//                             child: Row(
//                               children: [
//                                 Icon(Icons.arrow_forward, color: Colors.white),
//                                 TextButton(
//                                   child: Text("Request Escrow",
//                                       style: TextStyle(color: Colors.white)),
//                                   onPressed: () {
//                                     Get.off(() => GetRequestEscrow());
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                           PopupMenuItem<String>(
//                             value: 'option8',
//                             child: Row(
//                               children: [
//                                 Icon(Icons.arrow_forward, color: Colors.white),
//                                 TextButton(
//                                   child: Text("Received Escrow",
//                                       style: TextStyle(color: Colors.white)),
//                                   onPressed: () {
//                                     Get.off(() => ScreenReceivedEscrow());
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                           PopupMenuItem<String>(
//                             value: 'option9',
//                             child: Row(
//                               children: [
//                                 Icon(Icons.arrow_forward, color: Colors.white),
//                                 TextButton(
//                                   child: Text("Rejected Escrow",
//                                       style: TextStyle(color: Colors.white)),
//                                   onPressed: () {
//                                     Get.off(() => GetRejectedEscrow());
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                           PopupMenuItem<String>(
//                             value: 'option10',
//                             child: Row(
//                               children: [
//                                 Icon(Icons.arrow_forward, color: Colors.white),
//                                 TextButton(
//                                   child: Text("Requested Escrow",
//                                       style: TextStyle(color: Colors.white)),
//                                   onPressed: () {
//                                     Get.off(() => GetRequestedEscrow());
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                           PopupMenuItem<String>(
//                             value: 'option11',
//                             child: Row(
//                               children: [
//                                 Icon(Icons.arrow_forward, color: Colors.white),
//                                 TextButton(
//                                   child: Text("Cancelled Escrow",
//                                       style: TextStyle(color: Colors.white)),
//                                   onPressed: () {
//                                     Get.off(() => GetCancelledEscrow());
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                         Divider(color: Color(0xffCDE0EF)),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//               PopupMenuItem<String>(
//                 value: 'option12',
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.speed, color: Colors.white),
//                         TextButton(
//                           child: Text("Support Tickets",
//                               style: TextStyle(color: Colors.white)),
//                           onPressed: () {
//                             Get.off(() => ScreenSupportTicket());
//                           },
//                         ),
//                       ],
//                     ),
//                     Divider(
//                       color: Color(0xffCDE0EF),
//                     )
//                   ],
//                 ),
//               ),
//               PopupMenuItem<String>(
//                 value: 'option13',
//                 child: StatefulBuilder(
//                   builder: (BuildContext context, StateSetter setState) {
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(Icons.shopping_cart_outlined, color: Colors.white),
//                             TextButton(
//                               child: Text("Transactions",
//                                   style: TextStyle(color: Colors.white)),
//                               onPressed: () {
//                                 setState(() {
//                                   showSwapOptions = !showSwapOptions;
//                                 });
//                               },
//                             ),
//                             Spacer(),
//                             IconButton(
//                               onPressed: () {
//                                 setState(() {
//                                   showSwapOptions = !showSwapOptions;
//                                 });
//                               },
//                               icon: Icon(
//                                 showSwapOptions
//                                     ? Icons.arrow_drop_up
//                                     : Icons.arrow_drop_down,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                         if (showSwapOptions) ...[
//                           PopupMenuItem<String>(
//                             value: 'option14',
//                             child: Row(
//                               children: [
//                                 Icon(Icons.arrow_forward, color: Colors.white),
//                                 TextButton(
//                                   child: Text("My Deposits",
//                                       style: TextStyle(color: Colors.white)),
//                                   onPressed: () {
//                                     Get.off(() => ScreenMyDeposit());
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                           PopupMenuItem<String>(
//                             value: 'option15',
//                             child: Row(
//                               children: [
//                                 Icon(Icons.arrow_forward, color: Colors.white),
//                                 TextButton(
//                                   child: Text("My Withdrawals",
//                                       style: TextStyle(color: Colors.white)),
//                                   onPressed: () {
//                                     Get.off(() => ScreenMyWithDraw());
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                           PopupMenuItem<String>(
//                             value: 'option16',
//                             child: Row(
//                               children: [
//                                 Icon(Icons.arrow_forward, color: Colors.white),
//                                 TextButton(
//                                   child: Text("All Transactions",
//                                       style: TextStyle(color: Colors.white)),
//                                   onPressed: () {
//                                     Get.off(() => ScreenAllTransactions());
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                         Divider(color: Color(0xffCDE0EF)),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//               PopupMenuItem<String>(
//                 value: 'option17',
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.supervisor_account_outlined, color: Colors.white),
//                         TextButton(
//                           child:
//                           Text("Managers", style: TextStyle(color: Colors.white)),
//                           onPressed: () {
//                             Get.off(() => ScreenManagers());
//                           },
//                         ),
//                       ],
//                     ),
//                     Divider(
//                       color: Color(0xffCDE0EF),
//                     )
//                   ],
//                 ),
//               ),
//               PopupMenuItem<String>(
//                 value: 'option18',
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.settings_outlined, color: Colors.white),
//                         TextButton(
//                           child:
//                           Text("Settings", style: TextStyle(color: Colors.white)),
//                           onPressed: () {
//                             Get.off(() => ScreenSettingsPortion());
//                           },
//                         ),
//                       ],
//                     ),
//                     Divider(
//                       color: Color(0xffCDE0EF),
//                     )
//                   ],
//                 ),
//               ),
//               PopupMenuItem<String>(
//                 value: 'option19',
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.link, color: Colors.white),
//                         TextButton(
//                           child: Text("My Applications",
//                               style: TextStyle(color: Colors.white)),
//                           onPressed: () {
//                             Get.off(() => ScreenMerchant());
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ];
//           }
//         });

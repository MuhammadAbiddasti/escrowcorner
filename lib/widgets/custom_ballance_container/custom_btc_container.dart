// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../view/controller/wallet_controller.dart';
// import '../view/screens/screen_deposit.dart';
// import '../view/screens/screen_withdrawal.dart';
//
// class CustomBtcContainer extends StatelessWidget {
//   final WalletController walletController = Get.find<WalletController>();
//
//   @override
//   Widget build(BuildContext context) {
//     // Fetch currencies on initialization
//     walletController.fetchCurrencies();
//
//     return Obx(() {
//       if (walletController.isLoading.isTrue) {
//         return Center(child: CircularProgressIndicator());
//       }
//
//       return Container(
//         padding: EdgeInsets.all(16.0),
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(offset: Offset(1, 1), blurRadius: 10, color: Colors.grey)
//             ]
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Align(
//               alignment: Alignment.topRight,
//               child: GestureDetector(
//                 onTap: () async {
//                   final selectedCurrency = await showCustomDialog(context);
//                   if (selectedCurrency != null) {
//                     walletController.setSelectedCurrency(selectedCurrency);
//                   }
//                 },
//                 child: Container(
//                   height: 24,
//                   width: 24,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(3),
//                     color: Colors.grey.withOpacity(.30),
//                   ),
//                   child: Icon(
//                     Icons.add,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),
//             ),
//             Container(
//               constraints: BoxConstraints(minWidth: 100),
//               child: FittedBox(
//                 fit: BoxFit.scaleDown,
//                 alignment: Alignment.centerLeft,
//                 child: Padding(
//                   padding: EdgeInsets.only(bottom: 10),
//                   child: Obx(() => Text(
//                     walletController.selectedCurrency.value == null
//                         ? '\$0.00'
//                         : '${walletController.walletBalance.value}',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 35,
//                       color: Color(0xff484848),
//                       fontFamily: 'Nunito',
//                     ),
//                   )),
//                 ),
//               ),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     Get.to(ScreenDeposit());
//                   },
//                   child: Text('DEPOSIT'),
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.white, backgroundColor: Color(0xff18CE0F),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(5.0),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 ElevatedButton(
//                   onPressed: () {
//                     Get.to(ScreenWithdrawal());
//                   },
//                   child: Text('WITHDRAW'),
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.white, backgroundColor: Color(0xff18CE0F),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(5.0),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       );
//     });
//   }
//
//   Future<Currency?> showCustomDialog(BuildContext context) {
//     final currentCurrency = walletController.selectedCurrency.value;
//     return showDialog<Currency>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Select Currency'),
//           content: Obx(() {
//             if (walletController.isLoading.value) {
//               return Center(child: CircularProgressIndicator());
//             } else if (walletController.currencies.isEmpty) {
//               return Center(child: Text('No currencies available'));
//             } else {
//               return SizedBox(
//                 width: 200,
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: walletController.currencies.length,
//                   itemBuilder: (context, index) {
//                     final currency = walletController.currencies[index];
//                     return ListTile(
//                       title: Center(
//                         child: Text(
//                           currency.name,
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                       onTap: () {
//                         Navigator.pop(context, currency);
//                       },
//                     );
//                   },
//                 ),
//               );
//             }
//           }),
//         );
//       },
//     );
//   }
// }
//
//
//
// // Future<Currency?> showCustomDialog(BuildContext context) {
// //     final WalletController walletController = Get.find();
// //     final currentCurrency = walletController.selectedCurrency.value;
// //
// //     return Get.defaultDialog<Currency>(
// //       title: 'Select Currency',
// //       content: Obx(() {
// //         if (walletController.isLoading.value) {
// //           return Center(child: CircularProgressIndicator());
// //         } else if (walletController.currencies.isEmpty) {
// //           return Center(child: Text('No currencies available'));
// //         } else {
// //           return SizedBox(
// //             width: 200,
// //             child: ListView.builder(
// //               shrinkWrap: true,
// //               itemCount: walletController.currencies.length,
// //               itemBuilder: (context, index) {
// //                 final currency = walletController.currencies[index];
// //                 return ListTile(
// //                   title: Center(
// //                     child: Text(
// //                       currency.name,
// //                       textAlign: TextAlign.center,
// //                     ),
// //                   ),
// //                   onTap: () {
// //                     Get.back(result: currency);
// //                   },
// //                 );
// //               },
// //             ),
// //           );
// //         }
// //       }),
// //     );
// //   }
//
import 'package:dacotech/view/controller/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../view/screens/deposit/screen_deposit.dart';
import '../../view/screens/managers/manager_permission_controller.dart';
import '../../view/screens/swapping/swapping_screen.dart';
import '../../view/screens/user_profile/user_profile_controller.dart';
import '../../view/screens/withdraw/screen_withdrawal.dart';

class CustomBtcContainer extends StatefulWidget {
  @override
  _WalletWidgetState createState() => _WalletWidgetState();
}

class _WalletWidgetState extends State<CustomBtcContainer> {
  WalletController walletController =
      Get.put(WalletController(), permanent: true);
  final UserProfileController userProfileController =
      Get.put(UserProfileController());
  final ManagersPermissionController permissionController =
      Get.put(ManagersPermissionController());

  @override
  void initState() {
    _initializeCurrencies();
    walletController.walletBalance.value;
    userProfileController.fetchUserDetails();
    walletController.fetchWalletBalance(userProfileController.walletId.value);
    super.initState();
  }

  void _initializeCurrencies() async {
    walletController.isLoading.value = true;
    await walletController.fetchCurrencies(
      context,
    );

    // Only set the initial currency if it's not already set
    if (walletController.selectedCurrency.value == null &&
        walletController.currencies.isNotEmpty) {
      walletController.setSelectedCurrency(
          context, walletController.currencies.first);
      await _fetchBalanceForSelectedCurrency(walletController.currencies.first);
    }
    walletController.isLoading.value = false;
  }

  Future<void> _fetchBalanceForSelectedCurrency(
      Currency selectedCurrency) async {
    walletController.isLoading.value = true;
    walletController.walletBalance.value = ' '; // Clear existing balance
    String? walletId;
    for (var wallet in walletController.wallets) {
      if (wallet['currency_id'].toString() == selectedCurrency.id.toString()) {
        walletId = wallet['id'].toString();
        break;
      }
    }

    if (walletId != null) {
      await walletController.fetchWalletBalance(walletId);
      walletController.walletBalance.value =
          '${selectedCurrency.symbol} ${walletController.walletBalance.value.split(' ')[1]}';
    } else {
      print("Wallet Id not found: Wallet id: ${walletId}");
      Get.snackbar('Error', 'Wallet ID not found for the selected currency');
    }
    walletController.isLoading.value = false; // Stop loading
  }

  void _showCurrencySelection(BuildContext context) {
    if (walletController.currencies.isEmpty) {
      Get.snackbar('Error', 'No currencies available');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Currency'),
          content: Obx(() {
            if (walletController.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }

            if (walletController.currencies.isEmpty) {
              return Text('No currencies available');
            }

            return SingleChildScrollView(
              child: ListBody(
                children: walletController.currencies.map((currency) {
                  return ListTile(
                    title: Text(currency.name),
                    onTap: () {
                      Navigator.pop(context);
                      print("Selected Currency ID: ${currency.id}");
                      print(
                          "Selected wallet ID: ${userProfileController.walletId.value}");
                      // After selecting the currency, fetch the wallet balance
                      walletController.fetchWalletBalance(
                        userProfileController.walletId.value,
                      );
                    },
                  );
                }).toList(),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //walletController.walletBalance.value;
    //walletController.fetchWalletBalance(userProfileController.walletId.value);
    final isManager = userProfileController.isManager.value == '1';
    final isNotManager = userProfileController.isManager.value == '0';
    final allowedModules = permissionController.modulePermissions;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(offset: Offset(1, 1), blurRadius: 10, color: Colors.grey)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => _showCurrencySelection(context),
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.grey.withOpacity(0.3),
                ),
                child: Icon(Icons.add, color: Colors.grey),
              ).paddingOnly(top: 5),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Obx(() {
              // walletController
              //     .fetchWalletBalance(userProfileController.walletId.value);
              return Text(
                walletController.walletBalance.value.isEmpty
                    ? 'Fetching...'
                    : walletController.walletBalance.value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 35,
                  color: Color(0xff484848),
                  fontFamily: 'Nunito',
                ),
              );
            }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  Get.to(ScreenDeposit());
                },
                child: Text(
                  'DEPOSIT',
                  style: TextStyle(color: Color(0xff18CE0F), fontSize: 9),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(110, 25),
                  maximumSize: Size(110, 25),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Color(0xff18CE0F)),
                  shape: RoundedRectangleBorder(
                    //borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              // if (isManager &&
              //     allowedModules.containsKey('My Deposits') &&
              //     allowedModules['My Deposits']!
              //         .contains('add_deposit'))
              //   ElevatedButton(
              //     onPressed: () {
              //       Get.to(ScreenDeposit());
              //     },
              //     child: Text(
              //       'DEPOSIT',
              //       style:
              //           TextStyle(color: Color(0xff18CE0F), fontSize: 9),
              //     ),
              //     style: ElevatedButton.styleFrom(
              //       minimumSize: Size(110, 25),
              //       maximumSize: Size(110, 25),
              //       foregroundColor: Colors.white,
              //       backgroundColor: Colors.white,
              //       side: BorderSide(color: Color(0xff18CE0F)),
              //       shape: RoundedRectangleBorder(
              //           //borderRadius: BorderRadius.circular(5.0),
              //           ),
              //     ),
              //   ).paddingOnly(top: 20)
              // else if (isManager)
              //   ElevatedButton(
              //     onPressed: () {
              //       // Get.to(ScreenDeposit());
              //       Get.snackbar(
              //           "Message",
              //           "You have no Permission ",
              //           snackPosition:
              //           SnackPosition
              //               .BOTTOM,
              //           backgroundColor:
              //           Colors.red,
              //           colorText:
              //           Colors.white);
              //     },
              //     child: Text(
              //       'DEPOSIT',
              //       style: TextStyle(color: Color(0xff18CE0F), fontSize: 9),
              //     ),
              //     style: ElevatedButton.styleFrom(
              //       minimumSize: Size(110, 25),
              //       maximumSize: Size(110, 25),
              //       foregroundColor: Colors.white,
              //       backgroundColor: Colors.white,
              //       side: BorderSide(color: Color(0xff18CE0F)),
              //       shape: RoundedRectangleBorder(
              //           //borderRadius: BorderRadius.circular(5.0),
              //           ),
              //     ),
              //   ),
              // if (isNotManager)
              //   ElevatedButton(
              //     onPressed: () {
              //       Get.to(ScreenDeposit());
              //     },
              //     child: Text(
              //       'DEPOSIT',
              //       style:
              //           TextStyle(color: Color(0xff18CE0F), fontSize: 9),
              //     ),
              //     style: ElevatedButton.styleFrom(
              //       minimumSize: Size(110, 25),
              //       maximumSize: Size(110, 25),
              //       foregroundColor: Colors.white,
              //       backgroundColor: Colors.white,
              //       side: BorderSide(color: Color(0xff18CE0F)),
              //       shape: RoundedRectangleBorder(
              //           //borderRadius: BorderRadius.circular(5.0),
              //           ),
              //     ),
              //   ).paddingOnly(top: 20),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  Get.to(ScreenWithdrawal());
                },
                child: Text(
                  'WITHDRAW',
                  style: TextStyle(color: Color(0xff18CE0F), fontSize: 9),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(110, 25),
                  maximumSize: Size(110, 25),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Color(0xff18CE0F)),
                  shape: RoundedRectangleBorder(
                      //borderRadius: BorderRadius.circular(5.0),
                      ),
                ),
              ),
              // if (isManager &&
              //     allowedModules.containsKey('My Withdrawals') &&
              //     allowedModules['My Withdrawals']!
              //         .contains('add_withdraw'))
              //   ElevatedButton(
              //     onPressed: () {
              //       Get.to(ScreenWithdrawal());
              //     },
              //     child: Text(
              //       'WITHDRAW',
              //       style: TextStyle(color: Color(0xff18CE0F), fontSize: 9),
              //     ),
              //     style: ElevatedButton.styleFrom(
              //       minimumSize: Size(110, 25),
              //       maximumSize: Size(110, 25),
              //       foregroundColor: Colors.white,
              //       backgroundColor: Colors.white,
              //       side: BorderSide(color: Color(0xff18CE0F)),
              //       shape: RoundedRectangleBorder(
              //         //borderRadius: BorderRadius.circular(5.0),
              //       ),
              //     ),
              //   ).paddingOnly(top: 20)
              // else if (isManager)
              //   ElevatedButton(
              //     onPressed: () {
              //       Get.snackbar(
              //           "Message",
              //           "You have no Permission ",
              //           snackPosition:
              //           SnackPosition
              //               .BOTTOM,
              //           backgroundColor:
              //           Colors.red,
              //           colorText:
              //           Colors.white);
              //     },
              //     child: Text(
              //       'WITHDRAW',
              //       style: TextStyle(color: Color(0xff18CE0F), fontSize: 9),
              //     ),
              //     style: ElevatedButton.styleFrom(
              //       minimumSize: Size(110, 25),
              //       maximumSize: Size(110, 25),
              //       foregroundColor: Colors.white,
              //       backgroundColor: Colors.white,
              //       side: BorderSide(color: Color(0xff18CE0F)),
              //       shape: RoundedRectangleBorder(
              //         //borderRadius: BorderRadius.circular(5.0),
              //       ),
              //     ),
              //   ),
              // if (isNotManager)
              //   ElevatedButton(
              //     onPressed: () {
              //       Get.snackbar(
              //           "Message",
              //           "You have no Permission ",
              //           snackPosition:
              //           SnackPosition
              //               .BOTTOM,
              //           backgroundColor:
              //           Colors.red,
              //           colorText:
              //           Colors.white);
              //     },
              //     child: Text(
              //       'WITHDRAW',
              //       style: TextStyle(color: Color(0xff18CE0F), fontSize: 9),
              //     ),
              //     style: ElevatedButton.styleFrom(
              //       minimumSize: Size(110, 25),
              //       maximumSize: Size(110, 25),
              //       foregroundColor: Colors.white,
              //       backgroundColor: Colors.white,
              //       side: BorderSide(color: Color(0xff18CE0F)),
              //       shape: RoundedRectangleBorder(
              //         //borderRadius: BorderRadius.circular(5.0),
              //       ),
              //     ),
              //   ),
            ],
          ).paddingOnly(bottom: 10),
          // ElevatedButton(
          //   onPressed: () {
          //     Get.to(SwappingScreen());
          //   },
          //   child: Text(
          //     'Swapping',
          //     style: TextStyle(color: Color(0xff18CE0F), fontSize: 9),
          //   ),
          //   style: ElevatedButton.styleFrom(
          //     minimumSize: Size(150, 25),
          //     maximumSize: Size(150, 25),
          //     foregroundColor: Colors.white,
          //     backgroundColor: Colors.white,
          //     side: BorderSide(color: Color(0xff18CE0F)),
          //     shape: RoundedRectangleBorder(
          //       //borderRadius: BorderRadius.circular(5.0),
          //     ),
          //   ),
          // ),
        ],
      ).paddingSymmetric(horizontal: 15),
    ).paddingSymmetric(horizontal: 15);
  }

  bool get wantKeepAlive => true; // Keeps the state alive
}

import 'package:escrowcorner/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../user_profile/user_profile_controller.dart';
import 'setting_controller.dart';

class ScreenFeesCharges extends StatefulWidget {
  @override
  State<ScreenFeesCharges> createState() => _ScreenFeesChargesState();
}

class _ScreenFeesChargesState extends State<ScreenFeesCharges> {
  final SettingController chargesController = Get.put(SettingController());
  final UserProfileController userProfileController =Get.find<UserProfileController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chargesController.fetchCharges(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: const Color(0xff191f28),
        title: AppBarTitle(),
        leading: CustomPopupMenu(managerId: userProfileController.userId.value,),
        actions: [
          PopupMenuButtonAction(),
          AppBarProfileButton(),
        ],
      ),
      body: Column(
        children: [
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xffFFFFFF),
                ),
                child: Column(
                  children: [
                    Text("Fee And Charges Setting",style: TextStyle(
                        fontSize: 17,fontWeight: FontWeight.w700,color: Colors.black87
                    ),),
                    Divider(),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      //height: MediaQuery.of(context).size.height * .3,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Obx(() {
                        print('Charges values: ${chargesController.charges}');
                        if (chargesController.isLoading.value) {
                          return Center(
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                height: 15,
                                width: 100,
                                color: Colors.white,
                              ),
                            ),
                          );
                        } else if (chargesController.charges.isEmpty) {
                          return Center(child: Text('No charges available'));
                        } else {
                          final charges = chargesController.charges;
                          return Column(
                            children: [
                              Text("Deposit MTN Fee:   ${charges['mtn_deposit_percentage_fee']}%",
                                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 15))
                                  .paddingOnly(top: 5),
                              Text("Withdraw MTN Fee:  ${charges['mtn_withdraw_percentage_fee']}%",
                                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 15))
                                  .paddingOnly(top: 5),
                              Text("Deposit Orange Fee:   ${charges['orange_deposit_percentage_fee']}%",
                                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 15))
                                  .paddingOnly(top: 5),
                              Text("Withdraw Orange Fee:   ${charges['orange_withdraw_percentage_fee']}%",
                                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 15))
                                  .paddingOnly(top: 5),
                              Text("Deposit USDT Fee:   ${charges['usdt_deposit_percentage_fee']}%",
                                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 15))
                                  .paddingOnly(top: 5),
                              Text("Withdraw USDT Fee:   ${charges['usdt_withdraw_percentage_fee']}%",
                                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 15))
                                  .paddingOnly(top: 5),
                              Text("Deposit BTC Fee:   ${charges['btc_deposit_percentage_fee']}%",
                                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 15))
                                  .paddingOnly(top: 5),
                              Text("Withdraw BTC Fee:   ${charges['btc_withdraw_percentage_fee']}%",
                                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 15))
                                  .paddingOnly(top: 5),
                            ],
                          );
                        }
                      }),

                    ).paddingOnly(top: 15,bottom: 10),
                    // Divider(),
                    // Text("Who pays the deposit charge?",style: TextStyle(
                    //     fontSize: 20,fontWeight: FontWeight.bold
                    // ),),
                    // Obx(() {
                    //   return Column(
                    //     children: [
                    //       RadioListTile<String>(
                    //         value: 'Merchant',
                    //         groupValue: chargesController.depselectedRole.value,
                    //         onChanged: (value) {
                    //           chargesController.depselectedRole.value = value!;
                    //         },
                    //         title: RichText(
                    //           text: TextSpan(
                    //             text: 'Merchant',
                    //             style: TextStyle(color: Colors.black),
                    //             children: [
                    //               TextSpan(
                    //                 text: ' (Recommended)',
                    //                 style: TextStyle(color: Colors.grey),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //         activeColor: Colors.blue,
                    //       ),
                    //       RadioListTile<String>(
                    //         value: 'Customer',
                    //         groupValue: chargesController.depselectedRole.value,
                    //         onChanged: (value) {
                    //           chargesController.depselectedRole.value = value!;
                    //         },
                    //         title: Text('Customer'),
                    //         activeColor: Colors.blue,
                    //       ),
                    //     ],
                    //   );
                    // }),
                    // SizedBox(height: 10,),
                    // Text("Who pays the withdrawal  charge?",style: TextStyle(
                    //     fontSize: 20,fontWeight: FontWeight.bold
                    // ),),
                    // Obx(() {
                    //   return Column(
                    //     children: [
                    //       RadioListTile<String>(
                    //         value: 'Merchant',
                    //         groupValue: chargesController.witselectedRole.value,
                    //         onChanged: (value) {
                    //           chargesController.witselectedRole.value = value!;
                    //         },
                    //         title: RichText(
                    //           text: TextSpan(
                    //             text: 'Merchant',
                    //             style: TextStyle(color: Colors.black),
                    //             children: [
                    //               TextSpan(
                    //                 text: ' (Recommended)',
                    //                 style: TextStyle(color: Colors.grey),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //         activeColor: Colors.blue,
                    //       ),
                    //       RadioListTile<String>(
                    //         value: 'Customer',
                    //         groupValue: chargesController.witselectedRole.value,
                    //         onChanged: (value) {
                    //           chargesController.witselectedRole.value = value!;
                    //         },
                    //         title: Text('Customer'),
                    //         activeColor: Colors.blue,
                    //       ),
                    //     ],
                    //   );
                    // }),
                    // SizedBox(height: 20),
                    // CustomButton(
                    //     onPressed: () async {
                    //       await chargesController.payBothCharges();
                    //     },
                    //     text:('Save')
                    // ),
                    // Divider().paddingOnly(top: 10,bottom: 10),
                    // Text("Allow withdrawals through API?",style: TextStyle(
                    //     fontSize: 20,fontWeight: FontWeight.bold
                    // ),),
                    // Obx(() {
                    //   return Column(
                    //     children: [
                    //       RadioListTile<String>(
                    //         value: 'Yes',
                    //         groupValue: chargesController.allowApiWithdrawal.value,
                    //         onChanged: (value) {
                    //           chargesController.allowApiWithdrawal.value = value!;
                    //         },
                    //         title: Text("Yes"),
                    //         activeColor: Colors.blue,
                    //       ),
                    //       RadioListTile<String>(
                    //         value: 'No',
                    //         groupValue: chargesController.allowApiWithdrawal.value,
                    //         onChanged: (value) {
                    //           chargesController.allowApiWithdrawal.value = value!;
                    //         },
                    //         title: Text('No'),
                    //         activeColor: Colors.blue,
                    //       ),
                    //     ],
                    //   );
                    // }),
                    // CustomButton(text: 'Save', onPressed: () async {
                    //   await chargesController.setApiWithdrawal();
                    // },),
                  ],
                ).paddingSymmetric(horizontal: 15,vertical: 20),
              ).paddingOnly(top: 20)
            ],
          ).paddingSymmetric(horizontal: 15,vertical: 10),
          Spacer(),
          CustomBottomContainerPostLogin()
        ],
      ),
    );
  }
}

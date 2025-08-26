import 'package:escrowcorner/view/screens/settings/setting_controller.dart';
import 'package:escrowcorner/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:escrowcorner/widgets/custom_ballance_container/custom_btc_container.dart';
import 'package:escrowcorner/widgets/custom_button/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/common_header/common_header.dart';
import '../../controller/language_controller.dart';
import '../../controller/logo_controller.dart';
import '../../controller/logout_controller.dart';
import '../user_profile/user_profile_controller.dart';

class ScreenSettings extends StatelessWidget {
  final RxString selectedRole = 'Merchant'.obs;
  final LogoController logoController = Get.find();
  final LogoutController logoutController = Get.put(LogoutController());
  final SettingController chargesController = Get.put(SettingController());
  final UserProfileController userProfileController = Get.find<UserProfileController>();

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final userProfileController = Get.find<UserProfileController>();
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: languageController.getTranslation('settings'),
        managerId: userProfileController.userId.value,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //CustomBtcContainer().paddingOnly(top: 20, bottom: 20),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .07,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.lightBlueAccent,
                    ),
                    child: Center(
                        child: Text(
                      "App Name/Logo",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white),
                    )),
                  ).paddingOnly(top: 20),
                  Divider().paddingOnly(top: 10, bottom: 10),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .07,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.lightBlueAccent,
                    ),
                    child: Center(
                        child: Text(
                      "Charges",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white),
                    )),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    //height: MediaQuery.of(context).size.height * .3,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Obx(() {
                      if (chargesController.isLoading.value) {
                        return Center(child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: 15,
                            width: 100,
                            color: Colors.white,
                          ),
                        ));
                      } else if (chargesController.charges.isEmpty) {
                        return Center(child: Text('No charges available'));
                      } else {
                        final charges = chargesController.charges;
                        String formatCharge(String fixed, String percentage) {
                          return "$fixed + $percentage%";
                        }
                        return Column(children: [
                          Text("Deposit MTN Fee: ${formatCharge(charges['mtn_deposit_fixed_fee'], charges['mtn_deposit_percentage_fee'])}",style: TextStyle(fontWeight: FontWeight.w300,fontSize: 15),).paddingOnly(top: 5),
                          Text("Withdraw MTN Fee: ${formatCharge(charges['mtn_withdraw_fixed_fee'], charges['mtn_withdraw_percentage_fee'])}",style: TextStyle(fontWeight: FontWeight.w300,fontSize: 15)).paddingOnly(top: 5),
                          Text("Deposit Orange fee: ${formatCharge(charges['orange_deposit_fixed_fee'], charges['orange_deposit_percentage_fee'])}",style: TextStyle(fontWeight: FontWeight.w300,fontSize: 15)).paddingOnly(top: 5),
                          Text("Withdraw Orange fee: ${formatCharge(charges['orange_withdraw_fixed_fee'], charges['orange_withdraw_percentage_fee'])}",style: TextStyle(fontWeight: FontWeight.w300,fontSize: 15)).paddingOnly(top: 5),
                          Text("Deposit USDT fee: ${formatCharge(charges['usdt_deposit_fixed_fee'], charges['usdt_deposit_percentage_fee'])}",style: TextStyle(fontWeight: FontWeight.w300,fontSize: 15)).paddingOnly(top: 5),
                          Text("Withdraw USDT fee: ${formatCharge(charges['usdt_withdraw_fixed_fee'], charges['usdt_withdraw_percentage_fee'])}",style: TextStyle(fontWeight: FontWeight.w300,fontSize: 15)).paddingOnly(top: 5),
                          Text("Deposit BTC fee: ${formatCharge(charges['btc_deposit_fixed_fee'], charges['btc_deposit_percentage_fee'])}",style: TextStyle(fontWeight: FontWeight.w300,fontSize: 15)).paddingOnly(top: 5),
                          Text("Withdraw BTC fee: ${formatCharge(charges['btc_withdraw_fixed_fee'], charges['btc_withdraw_percentage_fee'])}",style: TextStyle(fontWeight: FontWeight.w300,fontSize: 15)).paddingOnly(top: 5),
                                        ]);
                      }
                    }),
                  ).paddingOnly(top: 15,bottom: 10),
                  Text("Who pays the deposit charge?",style: TextStyle(
                    fontSize: 20,fontWeight: FontWeight.bold
                  ),),
                  Obx(() {
                    return Column(
                      children: [
                        RadioListTile<String>(
                          value: 'Merchant',
                          groupValue: chargesController.depselectedRole.value,
                          onChanged: (value) {
                            chargesController.depselectedRole.value = value!;
                          },
                          title: RichText(
                            text: TextSpan(
                              text: 'Merchant',
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                  text: ' (Recommended)',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          activeColor: Colors.blue,
                        ),
                        RadioListTile<String>(
                          value: 'Customer',
                          groupValue: chargesController.depselectedRole.value,
                          onChanged: (value) {
                            chargesController.depselectedRole.value = value!;
                          },
                          title: Text('Customer'),
                          activeColor: Colors.blue,
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: 10,),
                  Text("Who pays the withdrawal  charge?",style: TextStyle(
                      fontSize: 20,fontWeight: FontWeight.bold
                  ),),
                  Obx(() {
                    return Column(
                      children: [
                        RadioListTile<String>(
                          value: 'Merchant',
                          groupValue: chargesController.witselectedRole.value,
                          onChanged: (value) {
                            chargesController.witselectedRole.value = value!;
                          },
                          title: RichText(
                            text: TextSpan(
                              text: 'Merchant',
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                  text: ' (Recommended)',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          activeColor: Colors.blue,
                        ),
                        RadioListTile<String>(
                          value: 'Customer',
                          groupValue: chargesController.witselectedRole.value,
                          onChanged: (value) {
                            chargesController.witselectedRole.value = value!;
                          },
                          title: Text('Customer'),
                          activeColor: Colors.blue,
                        ),
                      ],
                    );
                  }),
              SizedBox(height: 20),
              CustomButton(
                onPressed: () async {
                  await chargesController.payBothCharges(context);
                },
                text:('Save')
                ),
                  Divider().paddingOnly(top: 10,bottom: 10),
                  Text("Allow withdrawals through API?",style: TextStyle(
                      fontSize: 20,fontWeight: FontWeight.bold
                  ),),
                  Obx(() {
                    return Column(
                      children: [
                        RadioListTile<String>(
                          value: 'Yes',
                          groupValue: chargesController.allowApiWithdrawal.value,
                          onChanged: (value) {
                            chargesController.allowApiWithdrawal.value = value!;
                          },
                          title: Text("Yes"),
                          activeColor: Colors.blue,
                        ),
                        RadioListTile<String>(
                          value: 'No',
                          groupValue: chargesController.allowApiWithdrawal.value,
                          onChanged: (value) {
                            chargesController.allowApiWithdrawal.value = value!;
                          },
                          title: Text('No'),
                          activeColor: Colors.blue,
                        ),
                      ],
                    );
                  }),
                  CustomButton(text: 'Save', onPressed: () async {
                    await chargesController.setApiWithdrawal();
                  },),
                  Divider().paddingOnly(top: 10,bottom: 10),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .07,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.lightBlueAccent,
                    ),
                    child: Center(
                        child: Text(
                          "Authorised numbers for withdrawals",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white),
                        )),
                  ).paddingOnly(bottom: 20),
                  Text(
                    'MTN MoMo Withdrawal Number (None)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black,width: .5),
                      //borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.withOpacity(.3),
                    ),
                    child: Row(
                      children: [
                        Image.asset("assets/images/cmflag.png",
                          width: 30,
                          height: 30,),
                        SizedBox(width: 8),
                        Text(
                          '+237',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 48,
                      child: TextField(
                        //controller: chargesController.momoNumberController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 5,left: 5),
                          border: OutlineInputBorder(
                            //borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          hintText: '6 71 23 45 67',
                        ),
                      ),
                    ),
                  ),
                ],
              ).paddingOnly(top: 10,bottom: 15),
                  CustomButton(text: "Save",
                    onPressed: () async {
                      //await chargesController.saveMtnNumber();
                    },).paddingOnly(bottom: 20),
                  Text(
                    'MTN MoMo Withdrawal Number (None)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black,width: .5),
                          //borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.withOpacity(.3),
                        ),
                        child: Row(
                          children: [
                            Image.asset("assets/images/cmflag.png",
                              width: 30,
                              height: 30,),
                            SizedBox(width: 8),
                            Text(
                              '+237',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 48,
                          child: TextField(
                            //controller: chargesController.orangeNumberController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(top: 5,left: 5),
                              border: OutlineInputBorder(
                                //borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              hintText: '6 71 23 45 67',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).paddingOnly(top: 10,bottom: 15),
                  CustomButton(text: "Save",
                    onPressed: () async {
                      await chargesController.saveOrangeNumber();
                    },),
                  Divider().paddingOnly(top: 10,bottom: 10),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .07,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.lightBlueAccent,
                    ),
                    child: Center(
                        child: Text(
                          "API Allowed IPs",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white),
                        )),
                  ).paddingOnly(bottom: 20),
                  Text(
                    'IP addresses allowed to access API. Maximum 5 (Separate each one with a comma)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    height: 49,
                    child: TextField(
                    controller: chargesController.allowedIpsController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 5,left: 5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      hintText: 'IP addresses allowed to access API',
                      hintStyle: TextStyle(color: Colors.grey)
                    ),
                              ),
                  ),
                  SizedBox(height: 10,),
                  CustomButton(text: "Save",
                    onPressed: () async {
                      await chargesController.saveAllowedIps();
                    },),
                  Obx(() {
                    return Column(
                      children: [
                        CheckboxListTile(
                          title: Text('All deposits'),
                          value: chargesController.notifyDeposits.value,
                          onChanged: (value) {
                            chargesController.notifyDeposits.value = value!;
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: Colors.blue,
                        ),
                        CheckboxListTile(
                          title: Text('All withdrawals'),
                          value: chargesController.notifyWithdrawals.value,
                          onChanged: (value) {
                            chargesController.notifyWithdrawals.value = value!;
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: Colors.blue,
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: 10,),
                  CustomButton(text: "Save",
                    onPressed: () async {
                      // await chargesController.saveDepositAlert();
                      // await chargesController.saveWithdrawalAlert();
                    },),
                  SizedBox(height: 10,),
                  Text(
                    'MTN low balance threshold',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    height: 49,
                    child: TextField(
                      controller: chargesController.mtnLowBalanceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 5,left: 5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  CustomButton(text: "Save",
                    onPressed: () async {
                      await chargesController.saveMtnLowBalance();
                    },),
                  SizedBox(height: 10,),
                  Text(
                    'Orange  low balance threshold',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    height: 49,
                    child: TextField(
                      controller: chargesController.orangeLowBalanceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 5,left: 5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  CustomButton(text: "Save",
                    onPressed: () async {
                      await chargesController.saveOrangeLowBalance();
                    },),


                ]
            ).paddingSymmetric(horizontal: 15),
                  ),
            SizedBox(height: 10,),
            CustomBottomContainerPostLogin()
          ],
        ),
      )
    );
  }
}

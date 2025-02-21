import 'package:dacotech/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';
import 'setting_controller.dart';
import '../user_profile/user_profile_controller.dart';

class ScreenGeneralSettings extends StatefulWidget {
  @override
  State<ScreenGeneralSettings> createState() => _ScreenGeneralSettingsState();
}

class _ScreenGeneralSettingsState extends State<ScreenGeneralSettings> {
  final SettingController chargesController = Get.put(SettingController());

  final UserProfileController userController = Get.put(UserProfileController());

  @override
  void setState(VoidCallback fn) {
    userController.fetchUserDetails();
    super.setState(fn);
  }

  void onInit() {
    userController.fetchUserDetails();

  }

  @override
  Widget build(BuildContext context) {
    chargesController.fetchCharges(context);
    return Scaffold(backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: const Color(0xff0766AD),
        title: AppBarTitle(),
        leading: CustomPopupMenu(managerId: userController.userId.value,),
        actions: [
          PopupMenuButtonAction(),
          AppBarProfileButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
         await userController.fetchUserDetails();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Damaspay Settings",style: TextStyle(
                    fontSize: 17,fontWeight: FontWeight.w700,color: Colors.black87
                  ),).paddingOnly(bottom: 20),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .05,
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
                            readOnly: true,
                                controller: userController.mtnNumber, // Shows fetched MTN MoMo number
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly, // Allow only digits
                                  LengthLimitingTextInputFormatter(10), // Limit input to 10 digits
                                ],
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(top: 5, left: 5),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                              )
                        ),
                      )
                    ],
                  ).paddingOnly(top: 10),
                  FFButtonWidget(
                    onPressed: () async {
                      //await chargesController.saveMtnNumber();
                      Get.snackbar('Message', 'Please Contact support to change the number',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      },
                    text: 'Change Number',
                    options: FFButtonOptions(
                      width: Get.width,
                      height: 45.0,
                      padding: EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 0.0),
                      iconPadding: EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 0.0),
                      color: DamaspayTheme.of(context).primary,
                      textStyle:
                      DamaspayTheme.of(context).titleSmall.override(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      ),
                      elevation: 2.0,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ).paddingOnly(top: 20,bottom: 20),
                  Text(
                    'Orange Money Withdrawal Number (None)',
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
                            readOnly: true,
                            controller: userController.orangeNumber,
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
                              hintText: '',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).paddingOnly(top: 10),
                  FFButtonWidget(
                    onPressed: () async {
                      //await chargesController.saveOrangeNumber();
                      Get.snackbar('Message', 'Please Contact support to change the number',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    },
                    text: 'Change Number',
                    options: FFButtonOptions(
                      width: Get.width,
                      height: 45.0,
                      padding: EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 0.0),
                      iconPadding: EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 0.0),
                      color: DamaspayTheme.of(context).primary,
                      textStyle:
                      DamaspayTheme.of(context).titleSmall.override(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      ),
                      elevation: 2.0,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ).paddingOnly(top: 20,bottom: 20),
                  Divider().paddingOnly(bottom: 10),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .05,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.lightBlueAccent,
                    ),
                    child: Center(
                        child: Text(
                          "Email Alerts",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white),
                        )),
                  ).paddingOnly(bottom: 20),
                  // Text(
                  //   'IP addresses allowed to access API. Maximum 5 (Separate each one with a comma)',
                  //   style: TextStyle(
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // Container(
                  //   height: 49,
                  //   child: TextField(
                  //     controller: chargesController.allowedIpsController,
                  //     keyboardType: TextInputType.text,
                  //     decoration: InputDecoration(
                  //         contentPadding: EdgeInsets.only(top: 5,left: 5),
                  //         border: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(8),
                  //           borderSide: BorderSide(color: Colors.grey),
                  //         ),
                  //         focusedBorder: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(8),
                  //           borderSide: BorderSide(color: Colors.grey),
                  //         ),
                  //         hintText: 'IP addresses allowed to access API',
                  //         hintStyle: TextStyle(color: Colors.grey)
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 10,),
                  // CustomButton(text: "Save",
                  //   onPressed: () async {
                  //     await chargesController.saveAllowedIps();
                  //   },),
                  Obx(() {
                    return Column(
                      children: [
                        CheckboxListTile(
                          title: Text('All deposits'),
                          value: chargesController.notifyDeposits.value,
                          onChanged: (bool? newValue) {
                            chargesController.notifyDeposits.value = newValue ?? false;
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: Colors.blue,
                        ),
                        CheckboxListTile(
                          title: Text('All withdrawals'),
                          value: chargesController.notifyWithdrawals.value,
                          onChanged: (bool? newValue) {
                            chargesController.notifyWithdrawals.value = newValue ?? false;
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: Colors.blue,
                        ),
                      ],
                    );
                  }),
                  FFButtonWidget(
                    onPressed: () async {
                      await chargesController.saveEmailAlerts();
                      chargesController.fetchCharges(context); // Refresh data after saving
                    },
                    text: 'Save',
                    options: FFButtonOptions(
                      width: Get.width,
                      height: 45.0,
                      padding: EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 0.0),
                      iconPadding: EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 0.0),
                      color: DamaspayTheme.of(context).primary,
                      textStyle:
                      DamaspayTheme.of(context).titleSmall.override(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      ),
                      elevation: 2.0,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ).paddingOnly(top: 20,bottom: 20),
                  Divider(),
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
                  FFButtonWidget(
                    onPressed: () async {
                      await chargesController.savePayCharges();
                      chargesController.fetchCharges(context); // Refresh data after saving
                    },
                    text: 'Save',
                    options: FFButtonOptions(
                      width: Get.width,
                      height: 45.0,
                      padding: EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 0.0),
                      iconPadding: EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 0.0),
                      color: DamaspayTheme.of(context).primary,
                      textStyle:
                      DamaspayTheme.of(context).titleSmall.override(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      ),
                      elevation: 2.0,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ).paddingOnly(top: 10,bottom: 20),
                  Divider().paddingOnly(top: 10,bottom: 10),
                  Text("Allow withdrawals through API?",style: TextStyle(
                      fontSize: 20,fontWeight: FontWeight.bold
                  ),),
                  Obx(() {
                    return Column(
                      children: [
                        RadioListTile<String>(
                          value: 'Yes',
                          groupValue: chargesController.allowApiWithdrawal.value ?? '', // Handle null case
                          onChanged: (value) {
                            chargesController.allowApiWithdrawal.value = value!;
                          },
                          title: Text("Yes"),
                          activeColor: Colors.blue,
                        ),
                        RadioListTile<String>(
                          value: 'No',
                          groupValue: chargesController.allowApiWithdrawal.value ?? '', // Handle null case
                          onChanged: (value) {
                            chargesController.allowApiWithdrawal.value = value!;
                          },
                          title: Text("No"),
                          activeColor: Colors.blue,
                        ),
                        SizedBox(height: 10),
                        FFButtonWidget(
                          onPressed: chargesController.allowApiWithdrawal.value != null
                              ? () async {
                            await chargesController.setApiWithdrawal();
                            await chargesController.fetchCharges(context);
                          }
                              : null, // Disable button if value is null
                          text: 'Save',
                          options: FFButtonOptions(
                            width: Get.width,
                            height: 45.0,
                            color: chargesController.allowApiWithdrawal.value != null
                                ? DamaspayTheme.of(context).primary
                                : Colors.grey,
                            textStyle: DamaspayTheme.of(context).titleSmall.override(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                            ),
                            elevation: 2.0,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ).paddingOnly(top: 10, bottom: 20),

                      ],
                    );
                  })

                  // Text(
                  //   'MTN low balance threshold',
                  //   style: TextStyle(
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // SizedBox(height: 10,),
                  // Container(
                  //   height: 49,
                  //   child: TextField(
                  //     controller: chargesController.mtnLowBalanceController,
                  //     keyboardType: TextInputType.number,
                  //     decoration: InputDecoration(
                  //       contentPadding: EdgeInsets.only(top: 5,left: 5),
                  //       border: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(8),
                  //         borderSide: BorderSide(color: Colors.grey),
                  //       ),
                  //       focusedBorder: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(8),
                  //         borderSide: BorderSide(color: Colors.grey),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 10,),
                  // CustomButton(text: "Save",
                  //   onPressed: () async {
                  //     await chargesController.saveMtnLowBalance();
                  //   },),
                  // SizedBox(height: 10,),
                  // Text(
                  //   'Orange  low balance threshold',
                  //   style: TextStyle(
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // SizedBox(height: 10,),
                  // Container(
                  //   height: 49,
                  //   child: TextField(
                  //     controller: chargesController.orangeLowBalanceController,
                  //     keyboardType: TextInputType.number,
                  //     decoration: InputDecoration(
                  //       contentPadding: EdgeInsets.only(top: 5,left: 5),
                  //       border: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(8),
                  //         borderSide: BorderSide(color: Colors.grey),
                  //       ),
                  //       focusedBorder: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(8),
                  //         borderSide: BorderSide(color: Colors.grey),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 10,),
                  // CustomButton(text: "Save",
                  //   onPressed: () async {
                  //     await chargesController.saveOrangeLowBalance();
                  //   },),
                ],
              ).paddingSymmetric(horizontal: 15,vertical: 10),
              CustomBottomContainer()
            ],
          ),
        ),
      ),
    );
  }
}

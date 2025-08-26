import 'package:escrowcorner/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';
import 'setting_controller.dart';
import '../user_profile/user_profile_controller.dart';
import '../../../widgets/common_header/common_header.dart';
import '../../controller/language_controller.dart';

class ScreenGeneralSettings extends StatefulWidget {
  @override
  State<ScreenGeneralSettings> createState() => _ScreenGeneralSettingsState();
}

class _ScreenGeneralSettingsState extends State<ScreenGeneralSettings> {
  final SettingController chargesController = Get.put(SettingController());

  final UserProfileController userController = Get.find<UserProfileController>();

  @override
  void setState(VoidCallback fn) {
    userController.fetchUserDetails();
    super.setState(fn);
  }
  //final KycController kycController = Get.put(KycController());
  // @override
  // void initState() {
  //   super.initState();
  //   controller.fetchUserDetails(); // Fetch user details on screen load
  // }

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    chargesController.fetchCharges(context);
    chargesController.fetchSiteDetails(); // Fetch site details when page loads
    return Scaffold(backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: languageController.getTranslation('general_settings'),
        managerId: userController.userId.value,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
         await userController.fetchUserDetails();
         await chargesController.fetchSiteDetails(); // Also refresh site details
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                    "${chargesController.siteName.value} ${languageController.getTranslation('settings')}",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  )).paddingOnly(bottom: 20),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .05,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.lightBlueAccent,
                    ),
                    child: Center(
                      child: Obx(() => Text(
                        languageController.getTranslation('authorised_numbers_for_withdrawals'),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      )),
                    ),
                  ).paddingOnly(bottom: 20),
                  Obx(() => Text(
                        "${languageController.getTranslation('mtn_momo_withdrawal_number')} (" + languageController.getTranslation('none') + ")",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
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
                  Obx(() => FFButtonWidget(
                    onPressed: () async {
                      //await chargesController.saveMtnNumber();
                      Get.snackbar(languageController.getTranslation('message'), languageController.getTranslation('please_contact_support_to_change_the_number'),
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      },
                    text: languageController.getTranslation('change_number'),
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
                  ).paddingOnly(top: 20,bottom: 20)),
                  Obx(() => Text(
                        "${languageController.getTranslation('orange_money_withdrawal_number')} (" + languageController.getTranslation('none') + ")",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
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
                              contentPadding: EdgeInsets.only(top: 5, left: 5),
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
                  Obx(() => FFButtonWidget(
                    onPressed: () async {
                      //await chargesController.saveOrangeNumber();
                      Get.snackbar(languageController.getTranslation('message'), languageController.getTranslation('please_contact_support_to_change_the_number'),
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    },
                    text: languageController.getTranslation('change_number'),
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
                        width: 1.0),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ).paddingOnly(top: 20,bottom: 20)),
                  Divider().paddingOnly(bottom: 10),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .05,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.lightBlueAccent,
                    ),
                    child: Center(
                      child: Obx(() => Text(
                        languageController.getTranslation('email_alerts'),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      )),
                    ),
                  ).paddingOnly(bottom: 20),
                  Obx(() {
                    return Column(
                      children: [
                        CheckboxListTile(
                          title: Text(languageController.getTranslation('all_deposits')),
                          value: chargesController.notifyDeposits.value,
                          onChanged: (bool? newValue) {
                            chargesController.notifyDeposits.value = newValue ?? false;
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: Colors.blue,
                        ),
                        CheckboxListTile(
                          title: Text(languageController.getTranslation('all_withdrawals')),
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
                  Obx(() => FFButtonWidget(
                    onPressed: () async {
                      await chargesController.saveEmailAlerts();
                      chargesController.fetchCharges(context); // Refresh data after saving
                    },
                    text: languageController.getTranslation('save'),
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
                  ).paddingOnly(top: 20,bottom: 20)),
                  Divider(),
                ],
              ).paddingSymmetric(horizontal: 15,vertical: 10),
              CustomBottomContainerPostLogin()
            ],
          ),
        ),
      ),
    );
  }
}

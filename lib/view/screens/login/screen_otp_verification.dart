import 'package:escrowcorner/view/screens/login/login_controller.dart';
import 'package:escrowcorner/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../Home_Screens/custom_leading_appbar.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';
import '../managers/manager_permission_controller.dart';
import '../user_profile/user_profile_controller.dart';
import '../../../widgets/language_selector/language_selector_widget.dart';
import '../../controller/language_controller.dart';

class OtpVerificationScreen extends StatelessWidget {
  final LoginController otpController = Get.put(LoginController());
  final TextEditingController otpCodeController = TextEditingController();
  final ManagersPermissionController managerController = Get.put(ManagersPermissionController());
  final UserProfileController userProfileController =Get.put(UserProfileController());

  @override
  Widget build(BuildContext context) {
    final otpMessage = Get.arguments as String?;
    final languageController = Get.find<LanguageController>();
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(backgroundColor: Color(0xff0f9373),
        title: AppBarTitle(),
        leading: CustomLeadingAppbar(),
        actions: [
          QuickLanguageSwitcher(),
          IconButton(onPressed: (){}, icon: Icon(Icons.account_circle,color: Color(0xffFEA116), size: 30,))
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                Obx(() {
                  final _ = languageController.selectedLanguage.value;
                  return Text(
                    otpMessage ?? languageController.getTranslation('enter_the_code_sent_to_your_email'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  );
                }).paddingOnly(bottom: 15),
                Obx(() {
                  final _ = languageController.selectedLanguage.value;
                  return TextField(
                    controller: otpCodeController,
                    decoration: InputDecoration(
                      labelText: languageController.getTranslation('enter_code'),
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }),
                SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() {
                      final _ = languageController.selectedLanguage.value;
                      return FFButtonWidget(
                        onPressed: () async {
                          String otpCode = otpCodeController.text.trim();
                          print('OTP Code: $otpCode');
                          await otpController.verifyOtpLogin(context, otpCode);
                          managerController.fetchManagerPermissions(userProfileController.userId.value);
                        },
                        text: languageController.getTranslation('verify'),
                        options: FFButtonOptions(
                          width: Get.width * .3,
                          height: 45.0,
                          padding: EdgeInsetsDirectional.zero,
                          color: DamaspayTheme.of(context).primary,
                          textStyle: DamaspayTheme.of(context).titleSmall.override(
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
                      ).paddingSymmetric(vertical: 10);
                    }),
                    Obx(() {
                      final _ = languageController.selectedLanguage.value;
                      return FFButtonWidget(
                        onPressed: () async {
                          await otpController.resendOtp();
                        },
                        text: languageController.getTranslation('resend_otp'),
                        options: FFButtonOptions(
                          width: Get.width * .3,
                          height: 45.0,
                          padding: EdgeInsetsDirectional.zero,
                          color: DamaspayTheme.of(context).secondary,
                          textStyle: DamaspayTheme.of(context).titleSmall.override(
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
                      ).paddingSymmetric(vertical: 10);
                    }),
                  ],
                ),
              ],
            ),
          ).paddingSymmetric(horizontal: 20),
          Spacer(),
          CustomBottomContainerPostLogin(),
        ],
      ),
    );
  }
}

import 'package:escrowcorner/view/screens/login/login_controller.dart';
import 'package:escrowcorner/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../Home_Screens/custom_leading_appbar.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';
import 'deposit_withdraw_request_controller.dart';
import '../../../widgets/common_header/common_header.dart';
import '../user_profile/user_profile_controller.dart';
import '../../controller/language_controller.dart';

class WithdrawOtpVerificationScreen extends StatelessWidget {
  final String paymentMethodId;
  final String amount;
  final String phoneNumber;
  final String confirmNumber;
  final String? description;

  WithdrawOtpVerificationScreen({
    required this.paymentMethodId,
    required this.amount,
    required this.phoneNumber,
    required this.confirmNumber,
    this.description,
  });
  final DepositWithdrawRequestController otpController = Get.put(DepositWithdrawRequestController());
  final TextEditingController otpCodeController = TextEditingController();
  final UserProfileController userProfileController = Get.find<UserProfileController>();
  final LanguageController languageController = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    final otpMessage = Get.arguments as String?;
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
             appBar: CommonHeader(
         title: languageController.getTranslation('otp_verification'),
         managerId: userProfileController.userId.value,
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
                                 Text(
                   otpMessage ?? languageController.getTranslation('enter_code_sent_to_email'),
                   style: TextStyle(
                     fontSize: 20,
                     fontWeight: FontWeight.bold,
                     color: Colors.grey[700],
                   ),
                   textAlign: TextAlign.center,
                 ).paddingOnly(bottom: 15),
                                 TextField(
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
                 ),
                SizedBox(height: 20),
                FFButtonWidget(
                  onPressed: () async {
                    String otpCode = otpCodeController.text.trim();
                    print('OTP Code: $otpCode');
                    print('method: $paymentMethodId');
                    print('amount: $amount');
                    print('phone: $phoneNumber');
                    // Adding a delay of 2 seconds before the API call
                    await Future.delayed(Duration(seconds: 2));
                    // Verify OTP and proceed to make withdrawal request
                    await otpController.verifyOtpCode(
                      otpCode: otpCode,
                      paymentMethodId: paymentMethodId,
                      amount: amount,
                      phoneNumber: phoneNumber,
                      confirmNumber: confirmNumber,
                    );
                  },
                                     text: languageController.getTranslation('verify'),
                  options: FFButtonOptions(
                    width: Get.width,
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
                ).paddingSymmetric(vertical: 10),

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

import 'package:escrowcorner/view/screens/user_profile/user_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/common_header/common_header.dart';
import '2fa_security_controller.dart';
import 'package:escrowcorner/view/controller/language_controller.dart';

class Screen2faSecurity extends StatefulWidget {
  @override
  State<Screen2faSecurity> createState() => _Screen2faSecurityState();
}

class _Screen2faSecurityState extends State<Screen2faSecurity> {
  final UserProfileController userController = Get.find<UserProfileController>();
  final TwoFactorController controller = Get.put(TwoFactorController());
  final LanguageController languageController = Get.find<LanguageController>();

  @override
  void initState() {
    super.initState();
    userController.fetchUserDetails(); // Fetch user details on screen load
  }

  @override
  Widget build(BuildContext context) {
    controller.fetchQRCode();
    return Scaffold(
      backgroundColor: const Color(0xffE6F0F7),
      appBar: CommonHeader(title: languageController.getTranslation('2fa_security'), managerId: userController.userId.value),
      body:
          Stack(
            children: [
              RefreshIndicator(
              onRefresh: () async {
                await userController.fetchUserDetails();
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 2FA Options
                    Obx(() {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            Obx(() => Text(
                              languageController.getTranslation('two_factor_authentication'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            )),
                            Obx(() => Text(
                              languageController.getTranslation('please_choose_how_you_want_to_receive_your_confirmation_code'),
                              style: TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                            ).paddingSymmetric(horizontal: 20)),
                            const SizedBox(height: 20),
                            //Google 2FA Checkbox
                            CheckboxListTile(
                              title: Obx(() => Text(
                                languageController.getTranslation('google_authenticator'),
                                style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                              )),
                              subtitle: Obx(() => Text(
                                languageController.getTranslation('get_new_confirmation_codes_from_your_google_authenticator_app'),
                                style: TextStyle(fontSize: 12),
                              )),
                              value: userController.enableGoogle2fa.value,
                              onChanged: (value) async {
                                if (value == true) {
                                  await _handle2faChange("google");
                                }
                              },
                              activeColor: Colors.blue,
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                            //Email 2FA Checkbox
                            CheckboxListTile(
                              title: Obx(() => Text(
                                languageController.getTranslation('email'),
                                style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                              )),
                              value: userController.enableEmail2fa.value,
                              onChanged: (value) async {
                                if (value == true) {
                                  await _handle2faChange("email");
                                }
                              },
                              activeColor: Colors.blue,
                              controlAffinity: ListTileControlAffinity.leading,
                              subtitle: Obx(() => Text(
                                languageController.getTranslation('well_send_confirmation_codes_to_your_registered_email_address'),
                                style: TextStyle(fontSize: 12),
                              )),
                            ),
                          ],
                        ),
                      ).paddingSymmetric(horizontal: 20, vertical: 15);
                    }),
                    Obx(() {
                      if (userController.enableEmail2fa == true) {
                        return Column(
                            children: [
                              Container(),
                            ]);
                      } else if (controller.isLoading.value) {
                        controller.fetchQRCode();
                        return Column(
                          children: [
                            const Center(child: SpinKitFadingFour(
                              duration: Duration(seconds: 3),
                              size: 120,
                              color: Colors.green,
                            ),),
                          ],
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Obx(() => Text(
                                languageController.getTranslation('scan_qr_with_2fa_app'),
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                              )),
                              const SizedBox(height: 7),
                              if (controller.qrCodeImage.value != null)
                                Image.memory(
                                  controller.qrCodeImage.value!,
                                  height: 180,
                                  width: 180,
                                  errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.error, size: 100),
                                )
                              else
                                Column(
                                  children: [
                                    const Icon(Icons.broken_image, size: 100),
                                    Obx(() => Text(languageController.getTranslation('qr_code_image_not_available')))
                                  ],
                                ),
                              const SizedBox(height: 7),
                              Obx(() => Text(
                                languageController.getTranslation('or'),
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              )),
                              const SizedBox(height: 7),
                              Obx(() => Text(
                                languageController.getTranslation('add_following_code_into_google_authenticator_app'),
                                style: TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              )),
                              const SizedBox(height: 7),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.black, width: 2),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          controller.qrCodeValue.value,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.copy, color: Colors.blue),
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(
                                                text: controller.qrCodeValue.value));
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }),
                  ],
                ),
              ),
            ),
    Align(
    alignment: Alignment.bottomCenter,
              child: const CustomBottomContainerPostLogin(),
    ),
          ]),
          // Positioned Bottom Container



    );
  }

  Future<void> _handle2faChange(String type) async {
    try {
      // Send OTP for the selected type
      await controller.sendOtp(type);

      // If OTP is sent successfully, show the verification dialog
      final isVerified = await _showVerificationDialog(type);
      if (isVerified) {
        // Update 2FA status based on the type
        if (type == "google") {
          userController.enableGoogle2fa.value = true;
          userController.enableEmail2fa.value = false; // Disable Email 2FA
        } else if (type == "email") {
          userController.enableEmail2fa.value = true;
          userController.enableGoogle2fa.value = false; // Disable Google 2FA
        }
        // Refresh data and rebuild UI after successful verification
        await userController.fetchUserDetails();
        await controller.fetchQRCode();
        if (mounted) setState(() {});
        // Call API to update the 2FA status on the server
        //controller.update2fa(type);
      }
    } catch (e) {
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('failed_to_enable_2fa_please_try_again'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white
      );
    }
  }

  Future<bool> _showVerificationDialog(String type) async {
    final TextEditingController codeController = TextEditingController();
    return await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Obx(() => Text(languageController.getTranslation('verify_otp'))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => Text(
                type == 'google'
                    ? languageController.getTranslation('enter_otp_sent_to_email')
                    : languageController.getTranslation('enter_otp_from_authenticator_app'),
              )),
              const SizedBox(height: 10),
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  hintText: languageController.getTranslation('enter_otp'),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false), // Cancel
              child: Obx(() => Text(
                languageController.getTranslation('cancel'),
                style: TextStyle(
                  color: Colors.black,
                ),
              )),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff18CE0F),
              ),
              onPressed: () async {
                if (controller.isLoading.value) return;
                if (codeController.text.isNotEmpty) {
                  final otherType =
                  type == 'email' ? 'authenticator' : 'email';
                  bool verified;
                  if (type == 'email') {
                    // Email checkbox flow: verify code for Google Authenticator
                    verified = await controller.verifyGoogleOtpCode(context, codeController.text);
                  } else {
                    verified = await controller.verifyOtpCode(context,
                      codeController.text,
                      otherType,
                    );
                  }
                  print("type: $otherType");
                  if (verified) {
                    // Dismiss dialog only if verification is successful
                    Navigator.pop(ctx, true); // Return 'true' to indicate success
                  } else {
                    Navigator.pop(ctx, true);
                  }
                } else {
                  Get.snackbar(
                    languageController.getTranslation('error'),
                    languageController.getTranslation('please_enter_the_otp_code'),
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white
                  );
                }

                userController.fetchUserDetails();
              },
              child: Obx(() => controller.isLoading.value
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      languageController.getTranslation('verify'),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )),
            ),
          ],
        );
      },
    ) ?? false; // Return false if dialog is dismissed without verification
  }


}
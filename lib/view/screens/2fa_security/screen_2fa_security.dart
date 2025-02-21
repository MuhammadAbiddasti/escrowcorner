import 'package:dacotech/view/screens/user_profile/user_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '2fa_security_controller.dart';

class Screen2faSecurity extends StatefulWidget {
  @override
  State<Screen2faSecurity> createState() => _Screen2faSecurityState();
}

class _Screen2faSecurityState extends State<Screen2faSecurity> {
  final UserProfileController userController = Get.put(UserProfileController());
  final TwoFactorController controller = Get.put(TwoFactorController());

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
      appBar: AppBar(
        backgroundColor: Color(0xff0766AD),
        title: AppBarTitle(),
        leading: CustomPopupMenu(managerId: userController.userId.value,),
        actions: [
          PopupMenuButtonAction(),
          AppBarProfileButton(),
        ],
      ),
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
                             Text(
                              "Two-Factor Authentication",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Please Choose how you want to receive your confirmation code',
                              style: TextStyle(fontSize: 12),
                              textAlign: TextAlign.center, // Center-aligns the text
                            ).paddingSymmetric(horizontal: 20),
                            const SizedBox(height: 20),
                            //Google 2FA Checkbox
                            CheckboxListTile(
                              title: const Text(
                                'Enable Google Authenticator 2FA',
                                style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Get new confirmation codes from your Google authenticator app.',
                                style: TextStyle(fontSize: 12),
                              ),
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
                              title: const Text(
                                'Enable Email 2FA',
                                style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                              ),
                              value: userController.enableEmail2fa.value,
                              onChanged: (value) async {
                                if (value == true) {
                                  await _handle2faChange("email");
                                }
                              },
                              activeColor: Colors.blue,
                              controlAffinity: ListTileControlAffinity.leading,
                              subtitle: Text(
                                "We'll send a confirmation code to your registered email address",
                                style: TextStyle(fontSize: 12),
                              ),
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
                              Text(
                                'Scan the QR code below with your 2FA app:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
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
                                    const Text("QR Code Image Not available")
                                  ],
                                ),
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
                                          userController.googleSecretCode.value,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.copy, color: Colors.blue),
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(
                                                text: userController.googleSecretCode.value));
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
    child: const CustomBottomContainer(),
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
        // Call API to update the 2FA status on the server
        //controller.update2fa(type);
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to enable $type 2FA. Please try again.",
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
          title: const Text("Verify OTP"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Enter OTP sent to your ${type == 'email' ? 'authenticator' : 'email'}",
              ),
              const SizedBox(height: 10),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false), // Cancel
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff18CE0F),
              ),
              onPressed: () async {
                if (codeController.text.isNotEmpty) {
                  final otherType =
                  type == 'email' ? 'authenticator' : 'email';
                  // Adding a delay of 3 seconds before the API call
                  await Future.delayed(Duration(seconds: 2));
                  final verified = await controller.verifyOtpCode(context,
                    codeController.text,
                    otherType,
                  );
                  print("type: $otherType");
                  if (verified) {
                    // Dismiss dialog only if verification is successful
                    Navigator.pop(ctx, true); // Return 'true' to indicate success
                  } else {
                    Navigator.pop(ctx, true);
                  }
                } else {
                  Get.snackbar(
                    "Message",
                    "Please enter the verification code.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white
                  );
                }

                userController.fetchUserDetails();
              },
              child: const Text(
                'Verify',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false; // Return false if dialog is dismissed without verification
  }


}
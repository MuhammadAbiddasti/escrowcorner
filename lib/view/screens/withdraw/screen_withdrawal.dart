import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';
import '../2fa_security/2fa_security_controller.dart';
import '../user_profile/user_profile_controller.dart';
import 'deposit_withdraw_request_controller.dart';
import '../../controller/logo_controller.dart';
import '../payment_links/payment_link_controller.dart';

class ScreenWithdrawal extends StatelessWidget {
  final TextEditingController methodController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController();
  final LogoController logoController = Get.put(LogoController());
  final PaymentLinkController paymentLinkController =Get.put(PaymentLinkController());
  final DepositWithdrawRequestController withdrawController = Get.put(DepositWithdrawRequestController());
  final TwoFactorController controller = Get.put(TwoFactorController());
  final UserProfileController userProfileController =Get.find<UserProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: Color(0xff0766AD),
        title: AppBarTitle(),
        leading: CustomPopupMenu(managerId: userProfileController.userId.value,),
        actions: [
          PopupMenuButtonAction(),
          AppBarProfileButton(),
        ],
      ),
      body:Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.70,
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xffFFFFFF),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Withdraw From Damaspay",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xff18CE0F),
                              fontFamily: 'Nunito'),
                        ).paddingOnly(top: 10),
                        const Text(
                          "Payment Method",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xff484848),
                              fontFamily: 'Nunito'),
                        ).paddingOnly(top: 10, bottom: 10),
                        Obx(() {
                          if (paymentLinkController.paymentMethods.isEmpty) {
                            return Center(child: CircularProgressIndicator());
                          } else {
                            return TextFormField(
                              onTap: () {
                                showMenu<PaymentMethod>(
                                  context: context,
                                  position: RelativeRect.fromLTRB(10, 180, 0, 10),
                                  items: paymentLinkController.paymentMethods.map((PaymentMethod method) {
                                    return PopupMenuItem<PaymentMethod>(
                                      value: method,
                                      child: Text(method.name),
                                    );
                                  }).toList(),
                                ).then((selectedMethod) {
                                  if (selectedMethod != null) {
                                    paymentLinkController.selectedMethod.value = selectedMethod;
                                    // Update methodController with the selected method ID
                                    methodController.text = selectedMethod.id.toString();
                                  }
                                });
                              },

                              controller: TextEditingController(text: paymentLinkController.selectedMethod.value?.name ?? ''),
                              readOnly: true,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 5),
                                hintText: paymentLinkController.selectedMethod.value?.name ?? "Select Method",
                                hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xff666565)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xff666565)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xff666565)),
                                ),
                                suffixIcon: Icon(Icons.arrow_drop_down),
                              ),
                            );

                          }
                        }),
                        const Text(
                          "Amount",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xff484848),
                              fontFamily: 'Nunito'),
                        ).paddingOnly(top: 10, bottom: 10),
                        Container(
                          height: 42,
                          child: TextFormField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(top: 4, left: 5),
                              hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xff666565))),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xff666565))),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Color(0xff666565)),
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          "Phone Number",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              fontFamily: 'Nunito'),
                        ).paddingOnly(top: 10, bottom: 10),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(

                                border: Border.all(color: Colors.black,width: .5),
                                //borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.withOpacity(.3),
                              ),
                              child: Text(
                                '+237',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                  height: 42,
                                  child: TextField(

                                    controller: phoneController, // Shows fetched MTN MoMo number
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly, // Allow only digits
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
                        ),
                        const Text(
                          "Confirm Number",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xff484848),
                              fontFamily: 'Nunito'),
                        ).paddingOnly(top: 10, bottom: 10),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black,width: .5),
                                //borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.withOpacity(.3),
                              ),
                              child: Text(
                                '+237',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                  height: 42,
                                  child: TextField(
                                    controller: countryCodeController, // Shows fetched MTN MoMo number
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly, // Allow only digits
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
                        ),
                        const Text(
                          "Description",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xff484848),
                              fontFamily: 'Nunito'),
                        ).paddingOnly(top: 10, bottom: 10),
                        Container(
                          height: 42,
                          child: TextFormField(
                            controller: descriptionController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(top: 4, left: 5),
                              hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xff666565))),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xff666565))),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Color(0xff666565)),
                              ),
                            ),
                          ),
                        ),
                        FFButtonWidget(
                          onPressed: () async {
                            if(methodController.text.isEmpty){
                              Get.snackbar(
                                "Error",
                                "Select a valid method",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }
                            if (amountController.text.isEmpty || double.tryParse(amountController.text)! <= 0) {
                              Get.snackbar(
                                "Error",
                                "Enter a valid amount",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }
                            if(phoneController.text.isEmpty){
                              Get.snackbar(
                                "Error",
                                "Enter phone number",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }
                            if(countryCodeController.text.isEmpty){
                              Get.snackbar(
                                "Error",
                                "Enter Confirm phone number",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }
                            if (phoneController.text != countryCodeController.text) {
                              Get.snackbar(
                                "Error",
                                "Phone number and confirm phone number do not match",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }
                            // Adding a delay of 2 seconds before the API call
                            await Future.delayed(Duration(seconds: 2));
                           await withdrawController.sendOtpRequest(
                              paymentMethodId: methodController.text.toString(),
                              amount: amountController.text,
                              phoneNumber: phoneController.text,
                            );
                            paymentLinkController.selectedMethod.value = null;
                          },
                          text: 'SUBMIT',
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
                        ).paddingSymmetric(vertical: 20),

                      ],
                    ).paddingSymmetric(horizontal: 15),
                  ).paddingOnly(top: 20, bottom: 20),
                ],
              ),
            ),
          ),
          // Fixed Bottom Container
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomContainer(),
          ),
        ],
      ),
    );
  }


  Future<void> _handle2faChange(BuildContext context, String type) async {
    try {


      print("Otp Send to $type");
      // If OTP is sent successfully, show the verification dialog
      //await _showOtpDialog(context,type);
    } catch (e) {
      Get.snackbar(
        "Message",
        "Failed to enable $type 2FA. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Future<bool> _showOtpDialog(BuildContext context,String type) async {
  //   final TextEditingController codeController = TextEditingController();
  //
  //   return await showDialog<bool>(
  //     context: context,
  //     builder: (ctx) {
  //       return AlertDialog(
  //         title: const Text("Verify OTP"),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text(
  //               "$type",
  //             ),
  //             const SizedBox(height: 10),
  //             TextField(
  //               controller: codeController,
  //               decoration: const InputDecoration(
  //                 labelText: 'Enter OTP',
  //                 border: OutlineInputBorder(),
  //               ),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(ctx, false), // Cancel
  //             child: const Text(
  //               'Cancel',
  //               style: TextStyle(
  //                 color: Colors.black,
  //               ),
  //             ),
  //           ),
  //           ElevatedButton(
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: const Color(0xff18CE0F),
  //             ),
  //             onPressed: () async {
  //               if(codeController.text.isEmpty){
  //                 Get.snackbar("Message", "Please Fill the Code");
  //                 return;
  //               }
  //               int methodId = int.tryParse(methodController.text) ?? 0;
  //               // Call the API method with methodId as a string
  //               await withdrawController.makeWithdrawRequest(
  //                 methodId: methodId, // Pass methodId directly as a string
  //                 amount: double.tryParse(amountController.text) ?? 0.0,
  //                 phoneNumber: '${phoneController.text}', // Ensure +237 is prefixed and trimmed
  //                 description: descriptionController.text.trim(),
  //               );
  //               if (codeController.text.isNotEmpty) {
  //                 final otherType =
  //                 type == 'email' ? 'authenticator' : 'email';
  //                 final verified = await controller.verifyOtpCode(context,
  //                   codeController.text,
  //                   otherType,
  //                 );
  //                 //print("type: $otherType");
  //                 if (verified) {
  //                   // Dismiss dialog only if verification is successful
  //                   Navigator.pop(ctx, true); // Return 'true' to indicate success
  //                 } else {
  //                   Navigator.pop(ctx, true);
  //                 }
  //               } else {
  //                 Get.snackbar(
  //                   "Message",
  //                   "Please enter the verification code.",
  //                   snackPosition: SnackPosition.BOTTOM,
  //                 );
  //               }
  //               // Debug prints
  //               print("Method ID: ${methodController.text}");
  //               print("Amount: ${amountController.text}");
  //               print("Payee Number: ${phoneController.text}");
  //               print("Description: ${descriptionController.text}");
  //               Navigator.pop(ctx, false);
  //             },
  //             child: const Text(
  //               'Verify',
  //               style: TextStyle(
  //                 color: Colors.white,
  //               ),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   ) ?? false; // Return false if dialog is dismissed without verification
  // }
}

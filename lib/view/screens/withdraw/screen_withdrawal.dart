import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../widgets/common_header/common_header.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';
import '../user_profile/user_profile_controller.dart';
import 'deposit_withdraw_request_controller.dart';
import '../../controller/logo_controller.dart';
import '../payment_links/payment_link_controller.dart';
import '../settings/setting_controller.dart';
import '../../controller/language_controller.dart';

class ScreenWithdrawal extends StatelessWidget {
  final TextEditingController methodController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController confirmNumberController = TextEditingController();
  final LogoController logoController = Get.put(LogoController());
  final PaymentLinkController paymentLinkController = Get.put(PaymentLinkController());
  final DepositWithdrawRequestController withdrawController = Get.put(DepositWithdrawRequestController());
  final UserProfileController userProfileController = Get.find<UserProfileController>();
  final SettingController settingController = Get.find<SettingController>();
  final LanguageController languageController = Get.find<LanguageController>();

  ScreenWithdrawal() {
    // Listen to changes in selectedMethod and update methodController accordingly
    ever(paymentLinkController.selectedMethod, (PaymentMethod? method) {
      if (method != null) {
        methodController.text = method.id.toString();
      }
    });
    
    // Ensure payment methods are fetched when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Always fetch payment methods to ensure they're fresh
      paymentLinkController.fetchPaymentMethods();
      
      // Wait a bit for payment methods to be fetched, then auto-select
      Future.delayed(Duration(milliseconds: 1000), () {
        _selectFirstPaymentMethod();
      });
    });
    
    // Also listen to changes in paymentMethods to auto-select when they become available
    ever(paymentLinkController.paymentMethods, (List<PaymentMethod> methods) {
      if (methods.isNotEmpty && paymentLinkController.selectedMethod.value == null) {
        print("Payment methods loaded, auto-selecting first one...");
        _selectFirstPaymentMethod();
      }
    });
  }
  
  void _selectFirstPaymentMethod() {
    print("_selectFirstPaymentMethod called");
    print("Payment methods count: ${paymentLinkController.paymentMethods.length}");
    print("Selected method: ${paymentLinkController.selectedMethod.value?.name ?? 'null'}");
    
    if (paymentLinkController.paymentMethods.isNotEmpty) {
      final firstMethod = paymentLinkController.paymentMethods.first;
      print("First method available: ${firstMethod.name} (ID: ${firstMethod.id})");
      
      // Always set the first method if none is selected
      if (paymentLinkController.selectedMethod.value == null) {
        paymentLinkController.selectedMethod.value = firstMethod;
        methodController.text = firstMethod.id.toString();
        print("Auto-selected first payment method: ${firstMethod.name} (ID: ${firstMethod.id})");
      } else {
        print("Payment method already selected: ${paymentLinkController.selectedMethod.value?.name}");
      }
    } else {
      print("No payment methods available yet");
    }
  }
  
  void _clearAllFormFields() {
    print("Clearing all form fields...");
    amountController.clear();
    phoneController.clear();
    confirmNumberController.clear();
    // Don't clear methodController as it should keep the selected payment method
    print("All form fields cleared");
  }
  
  void _resetScreen() {
    print("Resetting withdrawal screen...");
    _clearAllFormFields();
    // Force a rebuild of the screen
    Get.forceAppUpdate();
    print("Withdrawal screen reset complete");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: "Withdraw",
        managerId: userProfileController.userId.value,
      ),
             body: SingleChildScrollView(
         child: Center(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.center,
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Container(
                 constraints: BoxConstraints(
                   minHeight: MediaQuery.of(context).size.height * 0.60,
                   maxHeight: MediaQuery.of(context).size.height * 0.80,
                 ),
                 width: MediaQuery.of(context).size.width * 0.9,
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(20),
                   color: const Color(0xffFFFFFF),
                 ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                                     Obx(() => Text(
                     "${languageController.getTranslation('withdraw')} ${languageController.getTranslation('from')} ${settingController.siteName.value}",
                     style: TextStyle(
                         fontWeight: FontWeight.w700,
                         fontSize: 16,
                         color: Color(0xff18CE0F),
                         fontFamily: 'Nunito'),
                   )).paddingOnly(top: 10),
                                     Obx(() => Text(
                     languageController.getTranslation('payment_method'),
                     style: TextStyle(
                         fontWeight: FontWeight.w400,
                         fontSize: 14,
                         color: Color(0xff484848),
                         fontFamily: 'Nunito'),
                   )).paddingOnly(top: 10, bottom: 10),
                                     Obx(() {
                     if (paymentLinkController.paymentMethods.isEmpty) {
                       return Center(child: CircularProgressIndicator());
                     } else {
                       // Ensure we have a selected method (auto-select first if none selected)
                       if (paymentLinkController.selectedMethod.value == null && 
                           paymentLinkController.paymentMethods.isNotEmpty) {
                         print("Obx: No payment method selected, auto-selecting...");
                         WidgetsBinding.instance.addPostFrameCallback((_) {
                           _selectFirstPaymentMethod();
                         });
                       }
                       
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
                               methodController.text = selectedMethod.id.toString();
                             }
                           });
                         },
                         controller: TextEditingController(text: paymentLinkController.selectedMethod.value?.name ?? ''),
                         readOnly: true,
                         decoration: InputDecoration(
                           contentPadding: EdgeInsets.only(left: 5),
                           hintText: paymentLinkController.selectedMethod.value?.name ?? "",
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
                                     Obx(() => Text(
                     languageController.getTranslation('amount'),
                     style: TextStyle(
                         fontWeight: FontWeight.w400,
                         fontSize: 14,
                         color: Color(0xff484848),
                         fontFamily: 'Nunito'),
                   )).paddingOnly(top: 10, bottom: 10),
                  Container(
                    height: 42,
                    child: TextFormField(
                      obscureText: false,
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
                                     Obx(() => Text(
                     languageController.getTranslation('phone_number'),
                     style: TextStyle(
                         fontWeight: FontWeight.w400,
                         fontSize: 14,
                         fontFamily: 'Nunito'),
                   )).paddingOnly(top: 10, bottom: 10),
                                     Row(
                     children: [
                       Container(
                         padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                         decoration: BoxDecoration(
                           border: Border.all(color: Colors.black, width: .5),
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
                             controller: phoneController,
                             keyboardType: TextInputType.phone,
                             inputFormatters: [
                               FilteringTextInputFormatter.digitsOnly,
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
                           ),
                         ),
                       ),
                     ],
                   ),
                                       Obx(() => Text(
                      languageController.getTranslation('confirm_number'),
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    )).paddingOnly(top: 10, bottom: 10),
                   Row(
                     children: [
                       Container(
                         padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                         decoration: BoxDecoration(
                           border: Border.all(color: Colors.black, width: .5),
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
                             controller: confirmNumberController,
                             keyboardType: TextInputType.phone,
                             inputFormatters: [
                               FilteringTextInputFormatter.digitsOnly,
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
                           ),
                         ),
                       ),
                     ],
                   ),
                                                           FFButtonWidget(
                                           onPressed: () async {
                         // Ensure we have a selected method (auto-select first if none selected)
                         if (paymentLinkController.selectedMethod.value == null && 
                             paymentLinkController.paymentMethods.isNotEmpty) {
                           print("Submit button: Auto-selecting first payment method...");
                           _selectFirstPaymentMethod();
                         }
                         
                         // Double-check and force selection if still needed
                         if (paymentLinkController.selectedMethod.value == null && 
                             paymentLinkController.paymentMethods.isNotEmpty) {
                           print("Submit button: Forcing payment method selection...");
                           final firstMethod = paymentLinkController.paymentMethods.first;
                           paymentLinkController.selectedMethod.value = firstMethod;
                           methodController.text = firstMethod.id.toString();
                         }
                         
                                                 if(methodController.text.isEmpty){
                           Get.snackbar(
                             languageController.getTranslation('error'),
                             languageController.getTranslation('select_valid_method'),
                             snackPosition: SnackPosition.BOTTOM,
                             backgroundColor: Colors.red,
                             colorText: Colors.white,
                           );
                           return;
                         }
                                              if (amountController.text.isEmpty || double.tryParse(amountController.text)! <= 0) {
                          Get.snackbar(
                            languageController.getTranslation('error'),
                            languageController.getTranslation('enter_valid_amount'),
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }
                                              if(phoneController.text.isEmpty){
                          Get.snackbar(
                            languageController.getTranslation('error'),
                            languageController.getTranslation('enter_phone_number'),
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }
                                              if(confirmNumberController.text.isEmpty){
                          Get.snackbar(
                            languageController.getTranslation('error'),
                            languageController.getTranslation('enter_confirm_phone_number'),
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }
                                              if (phoneController.text != confirmNumberController.text) {
                          Get.snackbar(
                            languageController.getTranslation('error'),
                            languageController.getTranslation('phone_number_not_matched_with_confirm_phone_number'),
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }
                                                                        // Call withdrawal API (OTP logic is handled in the controller)
                         bool success = await withdrawController.makeWithdrawRequest(
                           methodId: methodController.text.toString(),
                           amount: amountController.text,
                           phoneNumber: phoneController.text,
                           confirmNumber: confirmNumberController.text,
                           description: "", // Add description field if needed
                         );
                         
                         // If withdrawal was successful (OTP not required), reset the screen
                         if (success) {
                           print("Withdrawal successful, resetting screen...");
                           Future.delayed(Duration(seconds: 2), () {
                             _resetScreen();
                           });
                         }
                     },
                                         text: languageController.getTranslation('submit'),
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
               SizedBox(height: 100), // Add extra space for keyboard
             ],
           ),
         ),
       ),
    );
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../widgets/common_header/common_header.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';
import '../user_profile/user_profile_controller.dart';
import '../withdraw/deposit_withdraw_request_controller.dart';
import '../payment_links/payment_link_controller.dart';
import '../settings/setting_controller.dart';
import '../../controller/language_controller.dart';

class ScreenDeposit extends StatefulWidget {
  @override
  _ScreenDepositState createState() => _ScreenDepositState();
}

class _ScreenDepositState extends State<ScreenDeposit> {
  // Controllers for input fields
  final TextEditingController amountController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController();
  final PaymentLinkController paymentLinkController = Get.put(PaymentLinkController());
  final DepositWithdrawRequestController depositController = Get.put(DepositWithdrawRequestController());
  final UserProfileController userProfileController = Get.find<UserProfileController>();
  final SettingController settingController = Get.find<SettingController>();
  final LanguageController languageController = Get.find<LanguageController>();

  @override
  void initState() {
    super.initState();
    paymentLinkController.fetchPaymentMethods();
    
    // Auto-select the first payment method when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Wait a bit for payment methods to be fetched, then auto-select
      Future.delayed(Duration(milliseconds: 500), () {
        _selectFirstPaymentMethod();
      });
    });
    
    // Also listen to changes in paymentMethods to auto-select when they become available
    ever(paymentLinkController.paymentMethods, (List<PaymentMethod> methods) {
      if (methods.isNotEmpty && paymentLinkController.selectedMethod.value == null) {
        _selectFirstPaymentMethod();
      }
    });
  }
  
  void _selectFirstPaymentMethod() {
    if (paymentLinkController.paymentMethods.isNotEmpty && 
        paymentLinkController.selectedMethod.value == null) {
      final firstMethod = paymentLinkController.paymentMethods.first;
      paymentLinkController.selectedMethod.value = firstMethod;
      print("Auto-selected first payment method: ${firstMethod.name} (ID: ${firstMethod.id})");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: "Deposit",
        managerId: userProfileController.userId.value,
      ),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.60,
          width: MediaQuery.of(context).size.width * 0.9,
          margin: EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xffFFFFFF),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                             Obx(() => Text(
                 "${languageController.getTranslation('funding')} ${settingController.siteName.value} ${languageController.getTranslation('account')}",
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
                   return Center(child: Text(languageController.getTranslation('no_payment_methods_available')));
                 } else {
                   // Ensure we have a selected method (auto-select first if none selected)
                   if (paymentLinkController.selectedMethod.value == null && 
                       paymentLinkController.paymentMethods.isNotEmpty) {
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
                      borderSide: BorderSide(color: Color(0xff666565)),
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
              FFButtonWidget(
                onPressed: () async {
                  // Ensure we have a selected method (auto-select first if none selected)
                  if (paymentLinkController.selectedMethod.value == null && 
                      paymentLinkController.paymentMethods.isNotEmpty) {
                    _selectFirstPaymentMethod();
                  }
                  
                                       if (paymentLinkController.selectedMethod.value == null) {
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
                                       if (phoneController.text.isEmpty) {
                       Get.snackbar(
                         languageController.getTranslation('error'),
                         languageController.getTranslation('enter_phone_number'),
                         snackPosition: SnackPosition.BOTTOM,
                         backgroundColor: Colors.red,
                         colorText: Colors.white,
                       );
                       return;
                     }
                                     String methodId = paymentLinkController.selectedMethod.value!.id.toString();
                   await Future.delayed(Duration(seconds: 3));
                   bool success = await depositController.makeDepositRequest(
                     methodId: methodId,
                     amount: (amountController.text),
                     phoneNumber: "${phoneController.text}",
                     description: '',
                   );
                   if (success) {
                     // Clear form fields on success
                     amountController.clear();
                     phoneController.clear();
                     paymentLinkController.selectedMethod.value = null;
                   }
                   // No additional messages - only the API response message is shown
                },
                                   text: languageController.getTranslation('submit'),
                options: FFButtonOptions(
                  width: Get.width,
                  height: 45.0,
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
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
              ).paddingOnly(top: 30),
            ],
          ).paddingSymmetric(horizontal: 15),
        ).paddingOnly(top: 10, bottom: 20),
      ),
    );
  }
}

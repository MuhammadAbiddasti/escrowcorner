import 'package:escrowcorner/view/screens/send_money/controller_sendmoney.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../controller/logo_controller.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';
import '../user_profile/user_profile_controller.dart';

class ScreenSendMoney extends StatelessWidget {
  final LogoController logoController = Get.put(LogoController());
  final SendMoneyController controller =Get.put(SendMoneyController());
  final UserProfileController userProfileController =Get.find<UserProfileController>();

  void initState() {
    //super.initState();
    // Fetch escrows only once when the screen is initialized
    controller.fetchSendmoneyCurrencies();
  }
  void onInit() {
    controller.fetchSendmoneyCurrencies();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: Color(0xff191f28),
        title: AppBarTitle(),
        leading: CustomPopupMenu(managerId: userProfileController.userId.value,),
        actions: [
          PopupMenuButtonAction(),
          AppBarProfileButton(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Color(0xffFFFFFF),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Send Money",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Color(0xff18CE0F),
                                  fontFamily: 'Nunito'),
                            ).paddingOnly(top: 10),
                            Text(
                              "Currency",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Color(0xff484848),
                                  fontFamily: 'Nunito'),
                            ).paddingOnly(top: 10, bottom: 10),
                            Obx(() {
                              if (controller.currencies.isEmpty) {
                                return Center(child: TextFormField(
                                  onTap: () {
                                    // Trigger the menu manually
                                    showMenu<Currency>(
                                      context: context,
                                      position: RelativeRect.fromLTRB(10, 230, 0, 0),
                                      items: controller.currencies.map((Currency method) {
                                        return PopupMenuItem<Currency>(
                                          value: method,
                                          child: Text(method.name),
                                        );
                                      }).toList(),
                                    ).then((selectedCurrency) {
                                      // Update the selected currency when the menu item is selected
                                      if (selectedCurrency != null) {
                                        controller.selectedCurrency.value = selectedCurrency;
                                      }
                                    });
                                  },
                                  obscureText: false,
                                  controller: TextEditingController(
                                      text: controller.selectedCurrency.value?.name ?? "Select Currency"),
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 5),
                                    hintText: controller.selectedCurrency.value?.name ?? "Select Currency",
                                    hintStyle: TextStyle(color: Color(0xff666565)),
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
                                ));
                              } else {
                                return TextFormField(
                                  onTap: () {
                                    // Trigger the menu manually
                                    showMenu<Currency>(
                                      context: context,
                                      position: RelativeRect.fromLTRB(10, 230, 0, 0),
                                      items: controller.currencies.map((Currency method) {
                                        return PopupMenuItem<Currency>(
                                          value: method,
                                          child: Text(method.name),
                                        );
                                      }).toList(),
                                    ).then((selectedCurrency) {
                                      // Update the selected currency when the menu item is selected
                                      if (selectedCurrency != null) {
                                        controller.selectedCurrency.value = selectedCurrency;
                                      }
                                    });
                                  },
                                  obscureText: false,
                                  controller: TextEditingController(
                                      text: controller.selectedCurrency.value?.name ?? ""),
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 5),
                                    hintText: controller.selectedCurrency.value?.name ?? "Select Currency",
                                    hintStyle: TextStyle(color: Color(0xff666565)),
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
                            // Payment Method Dropdown (added below currency dropdown)
                            SizedBox(height: 10),
                            Text(
                              "Payment Method",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Color(0xff484848),
                                  fontFamily: 'Nunito'),
                            ).paddingOnly(top: 10, bottom: 10),
                            Obx(() {
                              if (controller.paymentMethods.isEmpty) {
                                controller.fetchPaymentMethods();
                                return TextFormField(
                                  enabled: false,
                                  decoration: InputDecoration(
                                    hintText: 'Loading payment methods...',
                                    border: OutlineInputBorder(),
                                  ),
                                );
                              }
                              return DropdownButtonFormField<PaymentMethod>(
                                value: controller.selectedPaymentMethod.value,
                                isExpanded: true,
                                items: controller.paymentMethods
                                    .map((method) => DropdownMenuItem<PaymentMethod>(
                                          value: method,
                                          child: Text(method.name),
                                        ))
                                    .toList(),
                                onChanged: (method) {
                                  controller.selectedPaymentMethod.value = method;
                                },
                                validator: (value) => value == null ? 'Payment method is required' : null,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: '',
                                ),
                              );
                            }),
                            Text(
                              "Amount:",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Color(0xff484848),
                                  fontFamily: 'Nunito'),
                            ).paddingOnly(top: 10, bottom: 10),
                            Container(
                              height: 42,
                              child: TextFormField(
                                obscureText: false,
                                controller: controller.amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(top: 4, left: 5),
                                  hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xff666565))),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xff666565))),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xff666565),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              "Recipient Email:",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Color(0xff484848),
                                  fontFamily: 'Nunito'),
                            ).paddingOnly(top: 10, bottom: 10),
                            Container(
                              height: 54,
                              child: TextFormField(
                                obscureText: false,
                                controller: controller.emailController,
                                decoration: InputDecoration(
                                  hintText: "example@gmail.com",
                                  prefixIcon: Icon(Icons.mail),
                                  hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xff666565))),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xff666565))),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xff666565),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              "Note for Recipient:",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Color(0xff484848),
                                  fontFamily: 'Nunito'),
                            ).paddingOnly(top: 10, bottom: 10),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.12,
                              child: TextFormField(
                                controller: controller.noteController,
                                maxLines: 4,
                                obscureText: false,
                                decoration: InputDecoration(
                                  hintText: "Write a note...",
                                  contentPadding: EdgeInsets.only(top: 4, left: 5),
                                  hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xff666565))),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xff666565))),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xff666565),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                              child: FFButtonWidget(
                                onPressed: () async {
                                  await Future.delayed(Duration(seconds: 2));
                                  controller.isLoading.value = true;
                                  await controller.sendMoney(context).then((_) {
                                    controller.isLoading.value = false;
                                  }).catchError((error) {
                                    controller.isLoading.value = false;
                                    Get.snackbar('Message', 'Failed to send money.');
                                  });
                                  print("Currency: \u001b[32m${controller.selectedCurrency.value?.id}\u001b[0m");
                                  print("Amount: ${controller.amountController.text}");
                                  print("Email: ${controller.emailController.text}");
                                  print("Note: ${controller.noteController.text}");
                                },
                                text: 'Send Money',
                                options: FFButtonOptions(
                                  width: Get.width,
                                  height: 45.0,
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
                              ),
                            ),
                          ],
                        ).paddingSymmetric(horizontal: 15),
                      ).paddingOnly(top: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
              bottomNavigationBar: CustomBottomContainerPostLogin(),
    );

  }

  void showLoadingSpinner(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: SpinKitFadingFour(
            duration: Duration(seconds: 3),
            size: 120,
            color: Colors.white,
          ),
        );
      },
    );
  }
}

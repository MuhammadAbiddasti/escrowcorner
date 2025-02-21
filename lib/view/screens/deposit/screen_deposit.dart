import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';
import '../user_profile/user_profile_controller.dart';
import '../withdraw/deposit_withdraw_request_controller.dart';
import '../payment_links/payment_link_controller.dart';

class ScreenDeposit extends StatelessWidget {
  // Controllers for input fields
  final TextEditingController methodController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController();
  final PaymentLinkController paymentLinkController =Get.put(PaymentLinkController());
  final DepositWithdrawRequestController depositController = Get.put(DepositWithdrawRequestController());
  final UserProfileController userProfileController =Get.find<UserProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: const Color(0xff0766AD),
        title: AppBarTitle(),
        leading: CustomPopupMenu(managerId: userProfileController.userId.value,),
        actions: [
          PopupMenuButtonAction(),
          AppBarProfileButton(),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.60,
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xffFFFFFF),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Funding Damaspay Account",
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
                          "Description (Optional)",
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
                            obscureText: false,
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
                            print("method: ${methodController.text}");
                            print("amount: ${amountController.text}");
                            print("phone: ${phoneController.text}");
                            print("description: ${descriptionController.text}");
                            String methodId = (methodController.text);
                            // Adding a delay of 3 seconds before the API call
                            await Future.delayed(Duration(seconds: 3));
                            // Call the API method with methodId as a string
                            await depositController.makeDepositRequest(
                              methodId: methodId, // Correct: Passing methodId as an integer
                              amount: (amountController.text), // Correct: Parsing amount as double
                              phoneNumber: "${phoneController.text}", // Correct: Using string interpolation
                              description: descriptionController.text, // Correct: Passing description directly
                            );

                            amountController.clear();
                            phoneController.clear();
                            descriptionController.clear();
                            paymentLinkController.selectedMethod.value = null;
                          },
                          text: 'SUBMIT',
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
                        ).paddingOnly(top: 30),
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
}

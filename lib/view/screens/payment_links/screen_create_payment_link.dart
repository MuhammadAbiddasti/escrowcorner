import 'package:escrowcorner/view/screens/dashboard/screen_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../controller/logo_controller.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';
import '../user_profile/user_profile_controller.dart';
import 'payment_link_controller.dart';

class ScreenCreatePaymentLink extends StatelessWidget {
  final LogoController logoController = Get.put(LogoController());
  final PaymentLinkController paymentLinkController =Get.put(PaymentLinkController());
  final UserProfileController userProfileController =Get.find<UserProfileController>();

  @override
  Widget build(BuildContext context) {
    // Fetch payment methods when the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      paymentLinkController.fetchPaymentMethods();
    });
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              //height: 469,
              //height: MediaQuery.of(context).size.height * 0.65,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(offset: Offset(2, 2),blurRadius: 10,color: Colors.grey)],
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20)),
                color: Color(0xffFFFFFF),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Method",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xff484848),
                        fontFamily: 'Nunito'),
                  ).paddingOnly(top: 10,bottom: 10),
                  Obx(() {
                    if (paymentLinkController.paymentMethods.isEmpty) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return TextFormField(
                        onTap: () {
                          // Trigger the menu manually when the TextFormField is tapped
                          showMenu<PaymentMethod>(
                            context: context,
                            position:RelativeRect.fromLTRB(10, 180, 0, 10),
                            items: paymentLinkController.paymentMethods.map((PaymentMethod method) {
                              return PopupMenuItem<PaymentMethod>(
                                value: method,
                                child: Text(method.name),
                              );
                            }).toList(),
                          ).then((selectedMethod) {
                            // Update the selected method when an item is selected from the menu
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
                  Text(
                    "Link Name",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xff484848),
                        fontFamily: 'Nunito'),
                  ).paddingOnly(top: 10,bottom: 10),
                  Container(
                    height: 42,
                    child: TextFormField(
                      controller: paymentLinkController.nameController,
                      decoration: InputDecoration(
                        hintText: "Name of your link",
                        contentPadding: EdgeInsets.only(top: 4,left: 5),
                        hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                        border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff666565))),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff666565))),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff666565),),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "Amount:",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xff484848),
                        fontFamily: 'Nunito'),
                  ).paddingOnly(top: 10,bottom: 10),
                  Container(
                    height: 42,
                    child: TextFormField(
                      controller: paymentLinkController.amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Payment request amount",
                        contentPadding: EdgeInsets.only(top: 4,left: 5),
                        hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                        border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff666565))),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff666565))),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff666565),),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "Description",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xff484848),
                        fontFamily: 'Nunito'),
                  ).paddingOnly(top: 10,bottom: 10),
                  Container(
                    height: MediaQuery.of(context).size.height*.12,
                    child: TextFormField(
                      controller: paymentLinkController.descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Tell your customer why you are requesting this payment...",
                        contentPadding: EdgeInsets.only(top: 4,left: 5),
                        hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                        border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff666565))),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff666565))),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff666565),),
                        ),
                      ),
                    ),
                  ),
                  FFButtonWidget(
                    onPressed: () async {
                      // Adding a delay of 3 seconds before the API call
                      await Future.delayed(Duration(seconds: 2));
                     await paymentLinkController.createPaymentLink(context);
                      //paymentLinkController.nameController.clear();
                     // paymentLinkController.amountController.clear();
                      //paymentLinkController.descriptionController.clear();
                      print("Method: ${paymentLinkController.selectedMethod.value}");
                    },
                    text: 'Create Payment Link',
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
                  ).paddingOnly(top: 30,bottom: 20),
                ],
              ).paddingSymmetric(horizontal: 15,vertical: 20),
            ),
          ],
        ),
      ),
              bottomNavigationBar: const CustomBottomContainerPostLogin(),
    );
  }
}

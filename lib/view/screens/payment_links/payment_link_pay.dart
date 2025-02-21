import 'package:dacotech/view/screens/payment_links/payment_link_controller.dart';
import 'package:dacotech/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../user_profile/user_profile_controller.dart';

class PaymentLinkPay extends StatelessWidget {
  final PaymentLinkController paymentLinkController = Get.find<PaymentLinkController>();
  TextEditingController controller = TextEditingController();
  final UserProfileController userProfileController =Get.find<UserProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: Color(0xff0766AD),
        title: AppBarTitle(),
        leading: CustomPopupMenu(managerId: userProfileController.userId.value,),
        actions: [
          PopupMenuButtonAction(),
          AppBarProfileButton(),
        ],
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height*.45,
            decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
            child: Obx(() {
              if (paymentLinkController.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (paymentLinkController.paymentLinks.isEmpty) {
                return Center(
                  child: Text(
                    'No payment details available',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                );
              }
              final paymentLink = paymentLinkController.paymentLinks.first; // Displaying the first payment link
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Amount: ${paymentLink.currency.symbol} ${paymentLink.amount.toString()}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Detail: ${paymentLink.paymentlinkDetails ?? 'No detail provided'}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Receiver ${paymentLink.currencyId == 1? "MTN Mobile Money" : "Orange Money"}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black,width: .5),
                            //borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.withOpacity(.3),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '+237',
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                              height: 48,
                              child: TextField(
                                controller: controller,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              )
                          ),
                        )
                      ],
                    ).paddingOnly(top: 10),
                    SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle Pay Button Press
                          Get.snackbar(
                            'Payment',
                            'Payment processing...',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        },
                        child: Text('Pay',style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ).paddingSymmetric(horizontal: 20,vertical: 15),
          Align(alignment: Alignment.bottomCenter,
              child: CustomBottomContainer())
        ],
      )
    );
  }
}

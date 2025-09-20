import 'package:escrowcorner/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:escrowcorner/widgets/custom_button/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../user_profile/user_profile_controller.dart';
import 'request_escrow/request_escrow.dart';

class ScreenEscrowDetails extends StatelessWidget {

  final UserProfileController userProfileController =Get.find<UserProfileController>();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar:  AppBar(
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
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color(0xffFFFFFF),
              ),
              child: Column(
                children: [
                  Text(
                    "What is Escrow and How does it work ?",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xff484848),
                        fontFamily: 'Nunito'),
                  ).paddingOnly(top: 10,bottom: 10),
                  SizedBox(height: 30,),
                  Text(
                    "An escrow is a financial arrangement where"
                        " a third party holds and regulates payment"
                        " of the funds required for two parties involved"
                        " in a given transaction. It helps make transactions"
                        " more secure by keeping the payment in a secure escrow"
                        " account which is only released when all of the terms of"
                        " an agreement are met as overseen by the escrow company.",
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 14,
                        color: Color(0xff484848),
                        fontFamily: 'Nunito'),
                  ).paddingOnly(top: 10,bottom: 10),
                  SizedBox(height: 50,),
                  Text(
                        "1. Buyer and Seller agree to terms - the Buyer begins a transaction. After creating an Escrow, all parties have agreed before to the terms of the transaction.\n"
                        "2. Buyer sends payment to seller - The Buyer submits a payment by existing seller wallet account, we verify the payment, the Seller is notified that funds have been secured 'In Escrow'.\n"
                        "3. Seller ships merchandise to Buyer - Upon payment verification, the Seller is authorised to send the merchandise and submit tracking information. We verify that the Buyer receives the merchandise.\n"
                        "4. Buyer accepts merchandise - The Buyer has a set number of days to inspect the merchandise and the option to accept or reject it. The Buyer accepts the merchandise.\n"
                        "5. Buyer releases payment to seller - we release the held funds to the seller from the Escrow Account.",
                    style: TextStyle(fontSize: 14,fontWeight: FontWeight.w300, color: Color(0xff484848),
                    )),
                  CustomButton(text: "Back To Escrow Page", onPressed: (){
                    // Navigate back to request_escrow screen
                    Get.off(() => GetRequestEscrow());
                  }).paddingOnly(top: 40,bottom: 20)
                ],
              ).paddingSymmetric(horizontal: 10,vertical: 5),
            ).paddingSymmetric(horizontal: 10,vertical: 20),
            CustomBottomContainerPostLogin()
          ],
        ),
      ),
    );
  }
}

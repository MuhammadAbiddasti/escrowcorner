import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_ballance_container/custom_btc_container.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../controller/logo_controller.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';
import 'virtualcard_controller.dart';

class ScreenAddVirtualCard extends StatelessWidget {
  final LogoController logoController = Get.put(LogoController());
  final VirtualCardController addVirtualCardController = Get.put(VirtualCardController());
  final TextEditingController amountController = TextEditingController();
  final TextEditingController cardHolderNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar:  AppBar(
        backgroundColor: Color(0xff0766AD),
        title: AppBarTitle(),
       // leading: PopupMenuButtonLeading(),
        actions: [
          PopupMenuButtonAction(),
          AppBarProfileButton(),

        ],
      ),
      body: Stack(
         children: [
           SingleChildScrollView(
             child: Center(
               child: Column(mainAxisAlignment: MainAxisAlignment.center,
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                   //CustomBtcContainer().paddingOnly(top: 20),
                   Container(
                     //height: 469,
                     //height: MediaQuery.of(context).size.height * 0.5,
                     width: MediaQuery.of(context).size.width * 0.9,
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(20),
                       color: Color(0xffFFFFFF),
                     ),
                     child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         RichText(
                           text: TextSpan(
                             style: TextStyle(fontSize: 16.0),
                             children: <TextSpan>[
                               TextSpan(
                                   text: "Add a New",
                                   style: TextStyle(color: Colors.green,
                                       fontWeight: FontWeight.w700)),
                               TextSpan(
                                   text: " Virtual Card",
                                   style: TextStyle(
                                       color: Color(0xffFEAF39),
                                       fontWeight: FontWeight.w700)),
                             ],
                           ),
                         ).paddingOnly(top: 10),
                         Row(
                           children: [
                             Text(
                               "Card creation fee:",
                               style: TextStyle(
                                 fontWeight: FontWeight.w400,
                                 fontSize: 14,
                                 color: Color(0xff484848),),
                             ),
                             Container(
                               width: 35,height: 18,
                               decoration: BoxDecoration(color: Color(0xffD9D9D9),
                                   borderRadius: BorderRadius.circular(5)),
                               child: Center(
                                 child: Text(
                                   "\$1",
                                   style: TextStyle(
                                       fontWeight: FontWeight.w400,
                                       fontSize: 14,
                                       color: Color(0xff484848),
                                       fontFamily: 'Nunito'),
                                 ),
                               ),
                             )
                           ],
                         ).paddingOnly(top: 20),
                         Row(
                           children: [
                             Text(
                               "Minimum Pre-fund amount:",
                               style: TextStyle(
                                 fontWeight: FontWeight.w400,
                                 fontSize: 14,
                                 color: Color(0xff484848),),
                             ),
                             Container(
                               width: 35,height: 18,
                               decoration: BoxDecoration(color: Color(0xffD9D9D9),
                                   borderRadius: BorderRadius.circular(5)),
                               child: Center(
                                 child: Text(
                                   "\$5",
                                   style: TextStyle(
                                       fontWeight: FontWeight.w400,
                                       fontSize: 14,
                                       color: Color(0xff484848),
                                       fontFamily: 'Nunito'),
                                 ),
                               ),
                             )
                           ],
                         ).paddingOnly(top: 5),
                         Text(
                           "Amount to Pre-fund the Card:",
                           style: TextStyle(
                               fontWeight: FontWeight.w400,
                               fontSize: 14,
                               color: Color(0xff484848),
                               fontFamily: 'Nunito'),
                         ).paddingOnly(top: 20,bottom: 10),
                         Container(
                           height: 54,
                           child: TextFormField(
                             keyboardType: TextInputType.number,
                             controller: amountController,
                             decoration: InputDecoration(
                               //contentPadding: EdgeInsets.only(left: 5),
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
                           "Card Holder’s Name",
                           style: TextStyle(
                               fontWeight: FontWeight.w400,
                               fontSize: 14,
                               color: Color(0xff484848),
                               fontFamily: 'Nunito'),
                         ).paddingOnly(top: 10,bottom: 10),
                         Container(
                           height: MediaQuery.of(context).size.height*.12,
                           child: TextFormField(
                             keyboardType: TextInputType.text,
                             controller: cardHolderNameController,
                             decoration: InputDecoration(
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
                             double amount = double.tryParse(amountController.text) ?? 0.0;
                             String cardHolderName = cardHolderNameController.text.trim();
                             if (amount >= 5.0 && cardHolderName.isNotEmpty) {
                               await addVirtualCardController.createVirtualCard(amount, cardHolderName);
                               // Check if the card was successfully added
                               if (addVirtualCardController.isCardAddedSuccessfully.value) {
                                 Get.snackbar("Success", "Virtual card created successfully");
                               } else {
                                 Get.snackbar("Error", "Failed to create virtual card",
                                     backgroundColor: Color(0xffE6F0F7));
                               }
                             } else {
                               Get.snackbar("Error", "Amount is less then \$5\n"
                                   "Fill all Fields");
                             }
                           },
                           text: 'Create Virtual Card',
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
                         ).paddingOnly(bottom: 20),
                       ],
                     ).paddingSymmetric(horizontal: 15),
                   ).paddingOnly(top: 30,bottom: 20),

                 ],
               ),
             ),
           ),
           Align(
               alignment: Alignment.bottomRight,
               child: CustomBottomContainer())
         ],
      ),
    );
  }
}

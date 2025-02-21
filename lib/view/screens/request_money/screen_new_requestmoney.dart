import 'package:dacotech/view/screens/request_money/controller_requestmoney.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../controller/logo_controller.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';
import '../user_profile/user_profile_controller.dart';

class ScreenNewRequestMoney extends StatelessWidget {
  final LogoController logoController = Get.put(LogoController());
  final RequestMoneyController requestController =Get.put(RequestMoneyController());
  final TextEditingController currencyController =TextEditingController();
  final UserProfileController userProfileController =Get.find<UserProfileController>();

  void initState() {
    //super.initState();
    if (!Get.isRegistered<RequestMoneyController>()) {
      Get.put(RequestMoneyController());
    }
    requestController.fetchRequestMoneyCurrencies();
  }

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
      body: Stack(
        children: [
          RefreshIndicator(
          onRefresh: () async {

          },
          child: SingleChildScrollView(
            child: Center(
              child: Column(crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //CustomBtcContainer().paddingOnly(top: 20),
                  Container(
                    //height: 469,
                    //height: MediaQuery.of(context).size.height * 0.68,
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xffFFFFFF),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Money Request",
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
                        ).paddingOnly(top: 10,bottom: 10),
                        Obx(() {
                          return TextFormField(
                            onTap: () {
                              if (requestController.selectedCurrency.isEmpty) {
                                // Trigger the fetchRequestMoneyCurrencies function if the list is empty
                                requestController.fetchRequestMoneyCurrencies();
                              } else {
                                // Show the menu if the list is already populated
                                showMenu<RCurrency>(
                                  context: context,
                                  position: RelativeRect.fromLTRB(10, 230, 0, 0),
                                  items: requestController.selectedCurrency.map((RCurrency method) {
                                    return PopupMenuItem<RCurrency>(
                                      value: method,
                                      child: Text(method.name),
                                    );
                                  }).toList(),
                                ).then((selectedMethod) {
                                  if (selectedMethod != null) {
                                    requestController.selectedMethod.value = selectedMethod;
                                  }
                                });
                              }
                            },
                            obscureText: false,
                            controller: TextEditingController(
                              text: requestController.selectedMethod.value?.name ?? "Select Method",
                            ),
                            readOnly: true,
                            decoration: InputDecoration(
                              suffixIcon: requestController.isCurrencyLoading.value
                                  ? Container(height: 20,width: 20,
                                  child: CircularProgressIndicator())
                                  : Icon(Icons.arrow_drop_down), // Show loading indicator instead of icon
                              hintText: requestController.selectedMethod.value?.name ?? "Select Method",
                              contentPadding: EdgeInsets.only(top: 4, left: 5),
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
                        ).paddingOnly(top: 10,bottom: 10),
                        Container(
                          height: 42,
                          child: TextFormField(
                            onChanged: (value) => requestController.amount.value = value,
                            keyboardType: TextInputType.number,
                            obscureText: false,
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
                        Text(
                          "User Email:",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xff484848),
                              fontFamily: 'Nunito'),
                        ).paddingOnly(top: 10,bottom: 10),
                        Container(
                          height: 54,
                          child: TextFormField(
                            onChanged: (value) => requestController.email.value = value,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: "example@gmail.com",
                              prefixIcon: Icon(Icons.mail),
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
                          "Note for Recipient:",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xff484848),
                              fontFamily: 'Nunito'),
                        ).paddingOnly(top: 10,bottom: 10),
                        Container(
                          height: MediaQuery.of(context).size.height*.12,
                          child: TextFormField(
                            onChanged: (value) => requestController.note.value = value,
                            maxLines: 4,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: "Write a note...",
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
                            await Future.delayed(Duration(seconds: 3));
                            await requestController.requestMoney(context,requestController.amount.value,
                                requestController.email.value,
                                requestController.note.value);
                          },
                          text: 'Request Money',
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
                    ).paddingSymmetric(horizontal: 15),
                  ).paddingOnly(top: 20,bottom: 50),
                ],
              ),
            ),
          ),
        ),
          Align(
            alignment: Alignment.bottomRight,
            child: const CustomBottomContainer(),
          ),
    ]
      ),

    );
  }
}


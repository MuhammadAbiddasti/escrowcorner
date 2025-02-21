import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';
import '../user_profile/user_profile_controller.dart';
import 'merchant_controller.dart';

class ScreenAddMerchant extends StatelessWidget {
  final MerchantController controller = Get.put(MerchantController());
  final UserProfileController userProfileController =Get.find<UserProfileController>();
  //final TextEditingController currencyController = TextEditingController();
  final TextEditingController merchantNameController = TextEditingController();
  final TextEditingController merchantSiteUrlController =
      TextEditingController();
  final TextEditingController webhookUrlControler =
      TextEditingController();
  final TextEditingController merchantSuccessLinkController =
      TextEditingController();
  final TextEditingController merchantFailLinkController =
      TextEditingController();
  final TextEditingController merchantIpnLinkController =
      TextEditingController();
  final TextEditingController merchantDescriptionController =
      TextEditingController();

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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //CustomBtcContainer(),
              Container(
                //height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xffFFFFFF),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "New Application",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xff18CE0F),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10),
                    Text(
                      "Application Logo",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10, bottom: 10),
                    Divider(
                      color: Color(0xffDDDDDD),
                    ),
                    Center(
                      child: Container(
                        //height: MediaQuery.of(context).size.height * 0.26,
                        width: MediaQuery.of(context).size.width * 0.56,
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: Obx(() {
                          if (controller.avatar.value != null) {
                            return Image.file(
                              controller.avatar.value!,
                              fit: BoxFit.cover,
                            );
                          } else if (controller.avatarUrl.value.isNotEmpty) {
                            return Image.network(
                              controller.avatarUrl.value,
                              fit: BoxFit.cover,
                            );
                          } else {
                            return Image.asset(
                              "assets/images/profile.png",
                              fit: BoxFit.cover,
                            );
                          }
                        }),
                      ).paddingOnly(top: 10),
                    ),
                    Divider(
                      color: Color(0xffDDDDDD),
                    ).paddingOnly(top: 20),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            controller.pickImage();
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Color(0xffDDDDDD),
                            ),
                            child: Center(
                              child: Text(
                                "Choose a File",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                            onPressed: () {},
                            child: Text(
                              "No file choosen",
                              style: TextStyle(color: Color(0xff666565)),
                            ))
                      ],
                    ).paddingOnly(bottom: 20)
                  ],
                ).paddingSymmetric(horizontal: 15),
              ).paddingOnly(top: 20),
              Container(
                //height: 469,
                //height: MediaQuery.of(context).size.height * 0.95,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xffFFFFFF),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Application Name",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10, bottom: 10),
                    TextFormField(
                      controller: TextEditingController(text: controller.merchantName.value),
                      onChanged: (value) {
                        controller.merchantName.value = value;
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 5),
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
                  //   Text(
                  //     "Merchant Currency",
                  //     style: TextStyle(
                  //         fontWeight: FontWeight.w400,
                  //         fontSize: 14,
                  //         color: Color(0xff484848),
                  //         fontFamily: 'Nunito'),
                  //   ).paddingOnly(top: 10, bottom: 10),
                  // Obx(() {
                  //   if (controller.currencies.isEmpty) {
                  //     return Center(child: CircularProgressIndicator());
                  //   } else {
                  //     return TextFormField(
                  //       controller: TextEditingController(text: controller.selectedCurrency.value?.name ??""),                            //initialValue: controller.selectedMethod.value?.name ?? '',
                  //       readOnly: true,
                  //       decoration: InputDecoration(
                  //         contentPadding: EdgeInsets.only(left: 5),
                  //         hintText: controller.selectedCurrency.value?.name ?? "Select Method",
                  //         hintStyle: TextStyle(color: Color(0xff666565)),
                  //         border: OutlineInputBorder(
                  //           borderSide: BorderSide(color: Color(0xff666565)),
                  //         ),
                  //         enabledBorder: OutlineInputBorder(
                  //           borderSide: BorderSide(color: Color(0xff666565)),
                  //         ),
                  //         focusedBorder: OutlineInputBorder(
                  //           borderSide: BorderSide(color: Color(0xff666565)),
                  //         ),
                  //         suffixIcon: PopupMenuButton<MCurrency>(
                  //           icon: Icon(Icons.expand_more),
                  //           onSelected: (MCurrency results) {
                  //             controller.selectedCurrency.value= results;
                  //           },
                  //           itemBuilder: (BuildContext context) {
                  //             return controller.currencies.map((MCurrency method) {
                  //               return PopupMenuItem<MCurrency>(
                  //                 value: method,
                  //                 child: Text(method.name),
                  //               );
                  //             }).toList();
                  //           },
                  //         ),
                  //
                  //       ),
                  //     );
                  //   }
                  // }),
                    Text(
                      "Webhook URL",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10, bottom: 10),
                    TextFormField(
                      controller: TextEditingController(text: controller.webhookUrl.value),
                      onChanged: (value) {
                        controller.webhookUrl.value = value;
                      },
                      //onChanged: (value) => controller.merchantIpnLink(value),
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 5),
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
                    Text(
                      "Site URL",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10, bottom: 10),
                    TextFormField(
                      keyboardType: TextInputType.url,
                      controller: TextEditingController(text: controller.merchantSiteUrl.value),
                      onChanged: (value) {
                        controller.merchantSiteUrl.value = value;
                      },
                      //onChanged: (value) => controller.merchantSiteUrl(value),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 5),
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
                    // Text(
                    //   "Success URL:",
                    //   style: TextStyle(
                    //       fontWeight: FontWeight.w400,
                    //       fontSize: 14,
                    //       color: Color(0xff484848),
                    //       fontFamily: 'Nunito'),
                    // ).paddingOnly(top: 10, bottom: 10),
                    // Container(
                    //   height: 42,
                    //   child: TextFormField(
                    //     keyboardType: TextInputType.url,
                    //     controller: TextEditingController(text: controller.merchantSuccessLink.value),
                    //     onChanged: (value) {
                    //       controller.merchantSuccessLink.value = value;
                    //     },
                    //     //onChanged: (value) => controller.merchantSuccessLink(value),
                    //     decoration: InputDecoration(
                    //       contentPadding: EdgeInsets.only(left: 5),
                    //       hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                    //       border: OutlineInputBorder(
                    //           borderSide: BorderSide(color: Color(0xff666565))),
                    //       enabledBorder: OutlineInputBorder(
                    //           borderSide: BorderSide(color: Color(0xff666565))),
                    //       focusedBorder: OutlineInputBorder(
                    //         borderSide: BorderSide(
                    //           color: Color(0xff666565),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // Text(
                    //   "Fail URL",
                    //   style: TextStyle(
                    //       fontWeight: FontWeight.w400,
                    //       fontSize: 14,
                    //       color: Color(0xff484848),
                    //       fontFamily: 'Nunito'),
                    // ).paddingOnly(top: 10, bottom: 10),
                    // Container(
                    //   height: 42,
                    //   child: TextFormField(
                    //     keyboardType: TextInputType.url,
                    //     //onChanged: (value) => controller.merchantFailLink(value),
                    //     controller: TextEditingController(text: controller.merchantFailLink.value),
                    //     onChanged: (value) {
                    //       controller.merchantFailLink.value = value;
                    //     },
                    //     decoration: InputDecoration(
                    //       contentPadding: EdgeInsets.only(left: 5),
                    //       hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                    //       border: OutlineInputBorder(
                    //           borderSide: BorderSide(color: Color(0xff666565))),
                    //       enabledBorder: OutlineInputBorder(
                    //           borderSide: BorderSide(color: Color(0xff666565))),
                    //       focusedBorder: OutlineInputBorder(
                    //         borderSide: BorderSide(
                    //           color: Color(0xff666565),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Text(
                      "Application Description",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10, bottom: 10),
                    TextFormField(
                      controller: TextEditingController(text: controller.merchantDescription.value),
                      onChanged: (value) {
                        controller.merchantDescription.value = value;
                      },
                      //onChanged: (value) => controller.merchantDescription(value),
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Write description...",
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
                    FFButtonWidget(
                      onPressed: () async {
                        // Adding a delay of 3 seconds before the API call
                        await Future.delayed(Duration(seconds: 3));
                        await controller.createMerchant(context
                          // Use code instead of name
                        );},
                      text: 'Save',
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
              ).paddingOnly(top: 20, bottom: 20),
              CustomBottomContainer()
            ],
          ),
        ),
      ),
    );
  }
}



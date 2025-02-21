import 'package:dacotech/view/screens/change_password/change_password_controller.dart';
import 'package:dacotech/view/screens/change_password/textfeild.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';
import '../user_profile/user_profile_controller.dart';

class ScreenChangePassword extends StatefulWidget {
  ScreenChangePassword({Key? key}) : super(key: key);

  @override
  _ScreenChangePasswordState createState() => _ScreenChangePasswordState();
}

class _ScreenChangePasswordState extends State<ScreenChangePassword> {
  ChangePasswordController controller = Get.put(ChangePasswordController());
  final UserProfileController userProfileController =Get.find<UserProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: Color(0xff0766AD),
        title: AppBarTitle(),
        leading: CustomPopupMenu(managerId: userProfileController.userId.value,),
        actions: [
          PopupMenuButtonAction(),
          AppBarProfileButton(),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // To push content and bottom container apart
        children: [
          Expanded(
            child: SingleChildScrollView(
              child:Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xffFFFFFF),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Old Password",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xff484848),
                            ),
                          ).paddingOnly(top: 10, bottom: 10),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xff666565), // Border color
                              ),
                              borderRadius: BorderRadius.circular(10), // Rounded corners
                            ),
                            child: CustomNewField(
                              controller: controller.oldPasswordController,
                              obscureText: false,
                              hint: 'Enter old password',
                              textStyle: TextStyle(fontSize: 13),
                              isPasswordField: true,
                            ),
                          ),
                          const Text(
                            "New password",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xff484848),
                            ),
                          ).paddingOnly(top: 10, bottom: 10),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xff666565), // Border color
                              ),
                              borderRadius: BorderRadius.circular(10), // Rounded corners
                            ),
                            child: CustomNewField(
                              obscureText: false,
                              controller: controller.newPasswordController,
                              hint: 'Enter new password',
                              textStyle: TextStyle(fontSize: 13),
                              isPasswordField: true,
                            ),
                          ),
                          const Text(
                            "Repeat your new password",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xff484848),
                            ),
                          ).paddingOnly(top: 10, bottom: 10),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xff666565), // Border color
                              ),
                              borderRadius: BorderRadius.circular(10), // Rounded corners
                            ),
                            child: CustomNewField(
                              obscureText: false,
                              controller: controller.confirmNewPasswordController,
                              hint: "Confirm New Password",
                              textStyle: TextStyle(fontSize: 13),
                              isPasswordField: true,
                            ),
                          ),
                          FFButtonWidget(
                            onPressed: () async {
                              // Adding a delay of 3 seconds before the API call
                              await Future.delayed(Duration(seconds: 2));
                              controller.sendOtpRequest(
                                oldPassword: controller.oldPasswordController.text,
                                newPassword: controller.newPasswordController.text,
                                confirmPassword: controller.confirmNewPasswordController.text,
                              );
                            },
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
                          ).paddingOnly(top: 30, bottom: 30),
                        ],
                      ).paddingSymmetric(horizontal: 15),
                    ).paddingSymmetric(horizontal: 15, vertical: 20),
                  ],
                ),
              ),
            ),

          const CustomBottomContainer(), // Stays at the bottom
        ],
      ),
    );
  }
}







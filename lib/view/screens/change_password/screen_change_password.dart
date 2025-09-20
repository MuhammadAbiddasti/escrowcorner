import 'package:escrowcorner/view/screens/change_password/change_password_controller.dart';
import 'package:escrowcorner/view/screens/change_password/textfeild.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';
import '../user_profile/user_profile_controller.dart';
import '../../../widgets/common_header/common_header.dart';
import '../../controller/language_controller.dart';

class ScreenChangePassword extends StatefulWidget {
  ScreenChangePassword({Key? key}) : super(key: key);

  @override
  _ScreenChangePasswordState createState() => _ScreenChangePasswordState();
}

class _ScreenChangePasswordState extends State<ScreenChangePassword> {
  ChangePasswordController controller = Get.put(ChangePasswordController());
  final UserProfileController userProfileController =Get.find<UserProfileController>();
  final LanguageController languageController = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xffE6F0F7),
      appBar: CommonHeader(title: Get.find<LanguageController>().getTranslation('change_password'), managerId: userProfileController.userId.value),
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
                          Obx(() => Text(
                            languageController.getTranslation('old_password'),
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xff484848),
                            ),
                          ).paddingOnly(top: 10, bottom: 10)),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xff666565), // Border color
                              ),
                              borderRadius: BorderRadius.circular(10), // Rounded corners
                            ),
                            child: Obx(() => CustomNewField(
                              controller: controller.oldPasswordController,
                              obscureText: false,
                              hint: languageController.getTranslation('enter_old_password'),
                              textStyle: TextStyle(fontSize: 13),
                              isPasswordField: true,
                            )),
                          ),
                          Obx(() => Text(
                            languageController.getTranslation('new_password'),
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xff484848),
                            ),
                          ).paddingOnly(top: 10, bottom: 10)),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xff666565), // Border color
                              ),
                              borderRadius: BorderRadius.circular(10), // Rounded corners
                            ),
                            child: Obx(() => CustomNewField(
                              obscureText: false,
                              controller: controller.newPasswordController,
                              hint: languageController.getTranslation('enter_new_password'),
                              textStyle: TextStyle(fontSize: 13),
                              isPasswordField: true,
                            )),
                          ),
                          Obx(() => Text(
                            languageController.getTranslation('confirm_new_password'),
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xff484848),
                            ),
                          ).paddingOnly(top: 10, bottom: 10)),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xff666565), // Border color
                              ),
                              borderRadius: BorderRadius.circular(10), // Rounded corners
                            ),
                            child: Obx(() => CustomNewField(
                              obscureText: false,
                              controller: controller.confirmNewPasswordController,
                              hint: languageController.getTranslation('confirm_new_password'),
                              textStyle: TextStyle(fontSize: 13),
                              isPasswordField: true,
                            )),
                          ),
                          Obx(() => CustomButton(
                            text: languageController.getTranslation('change_password'),
                            onPressed: () {
                              controller.changePassword();
                            },
                            loading: controller.isLoading.value,
                          ).paddingOnly(top: 20, bottom: 20)),
                        ],
                      ).paddingSymmetric(horizontal: 20),
                    ).paddingOnly(top: 30, bottom: 20),
                  ]
              ),
            ),
          ),
          CustomBottomContainerPostLogin(),
        ],
      ),
    );
  }
}







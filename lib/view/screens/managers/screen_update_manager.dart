import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/common_header/common_header.dart';
import '../../controller/language_controller.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_ballance_container/custom_btc_container.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';
import '../change_password/textfeild.dart';
import '../user_profile/user_profile_controller.dart';
import 'controller_managers.dart';
import '../../controller/logo_controller.dart';

class ScreenUpdateManger extends StatefulWidget {
  final Manager? manager;
  ScreenUpdateManger({ this.manager});
  @override
  State<ScreenUpdateManger> createState() => _ScreenUpdateMangerState();
}

class _ScreenUpdateMangerState extends State<ScreenUpdateManger> {
  LogoController logoController =Get.put(LogoController());
  ManagersController managersController =Get.find();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final UserProfileController userProfileController =Get.find<UserProfileController>();
  final LanguageController languageController = Get.find<LanguageController>();

  @override
  void initState() {
    super.initState();
    if (widget.manager != null) {
      // Populate fields with existing manager data if available
      _emailController.text = widget.manager!.email;
      _firstNameController.text = widget.manager!.firstName;
      _lastNameController.text = widget.manager!.lastName;
      _phoneController.text = widget.manager!.phoneNumber;
    }
    
    // Fetch applications when the screen loads
    managersController.getApplications();
  }

  @override
  void dispose() {
    // Clear selected applications when leaving the screen
    managersController.clearSelectionsForNavigation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(title: Get.find<LanguageController>().getTranslation('edit_manager'), managerId: userProfileController.userId.value),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              //CustomBtcContainer().paddingOnly(top: 20),
              Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.5,
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xffFFFFFF),
                ),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                        languageController.getTranslation('email'),
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xff484848),
                            fontFamily: 'Nunito'),
                      ).paddingOnly(top: 10, bottom: 10)),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xff666565), // Border color
                          ),
                          borderRadius: BorderRadius.circular(5), // Rounded corners
                        ),
                        child: Obx(() => CustomNewField(
                          obscureText: false,
                          controller: _emailController,
                          hint: languageController.getTranslation('email'),
                          textStyle: TextStyle(fontSize: 13),
                        )),
                      ),
                      Obx(() => Text(
                        languageController.getTranslation('first_name'),
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xff484848),
                            fontFamily: 'Nunito'),
                      ).paddingOnly(top: 10, bottom: 10)),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xff666565), // Border color
                          ),
                          borderRadius: BorderRadius.circular(5), // Rounded corners
                        ),
                        child: Obx(() => CustomNewField(
                          obscureText: false,
                          controller: _firstNameController,
                          hint: languageController.getTranslation('first_name'),
                          textStyle: TextStyle(fontSize: 13),
                        )),
                      ),
                      Obx(() => Text(
                        languageController.getTranslation('last_name'),
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xff484848),
                            fontFamily: 'Nunito'),
                      ).paddingOnly(top: 10, bottom: 10)),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xff666565), // Border color
                          ),
                          borderRadius: BorderRadius.circular(5), // Rounded corners
                        ),
                        child: Obx(() => CustomNewField(
                          obscureText: false,
                          controller: _lastNameController,
                          hint: languageController.getTranslation('last_name'),
                          textStyle: TextStyle(fontSize: 13),
                        )),
                      ),
                      Obx(() => Text(
                        languageController.getTranslation('phone_number'),
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xff484848),
                            fontFamily: 'Nunito'),
                      ).paddingOnly(top: 10, bottom: 10)),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xff666565), // Border color
                          ),
                          borderRadius: BorderRadius.circular(5), // Rounded corners
                        ),
                        child: Obx(() => CustomNewField(
                          obscureText: false,
                          controller: _phoneController,
                          hint: languageController.getTranslation('phone_number'),
                          textStyle: TextStyle(fontSize: 13),
                        )),
                      ),
                      Obx(() => Text(
                        languageController.getTranslation('password'),
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xff484848),
                            fontFamily: 'Nunito'),
                      ).paddingOnly(top: 10, bottom: 10)),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xff666565), // Border color
                          ),
                          borderRadius: BorderRadius.circular(5), // Rounded corners
                        ),
                        child: Obx(() => CustomNewField(
                          obscureText: true,
                          controller: _passwordController,
                          hint: languageController.getTranslation('password'),
                          textStyle: TextStyle(fontSize: 13),
                        )),
                      ),
                      Obx(() => Text(
                        languageController.getTranslation('confirm_password'),
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xff484848),
                            fontFamily: 'Nunito'),
                      ).paddingOnly(top: 10, bottom: 10)),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xff666565), // Border color
                          ),
                          borderRadius: BorderRadius.circular(5), // Rounded corners
                        ),
                        child: Obx(() => CustomNewField(
                          obscureText: true,
                          controller: _confPasswordController,
                          hint: languageController.getTranslation('confirm_password'),
                          textStyle: TextStyle(fontSize: 13),
                        )),
                      ),
                      
                      // Applications Section
                      Obx(() {
                        if (managersController.applicationsList.isNotEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                languageController.getTranslation('assign_sub_accounts'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color(0xff484848),
                                  fontFamily: 'Nunito',
                                ),
                              ).paddingOnly(top: 20, bottom: 10),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xff666565),
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Column(
                                  children: managersController.applicationsList.map<Widget>((app) {
                                    return CheckboxListTile(
                                      title: Text(
                                        app.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Nunito',
                                        ),
                                      ),
                                      value: managersController.selectedApplicationIds.contains(app.id),
                                      onChanged: (bool? value) {
                                        managersController.toggleApplicationSelection(app.id);
                                      },
                                      controlAffinity: ListTileControlAffinity.leading,
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                      visualDensity: VisualDensity.compact,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          );
                        } else if (managersController.isApplicationsLoading.value) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      }),
                      
                      SizedBox(height: 20), // Add extra bottom spacing
                      
                      Obx(() => FFButtonWidget(
                        onPressed: () async {
                         await managersController.editManager(
                            id: widget.manager!.id.toString(),
                            email: _emailController.text,
                            firstName: _firstNameController.text,
                            lastName: _lastNameController.text,
                            password: _passwordController.text,
                            confPassword: _confPasswordController.text,
                            phone: _phoneController.text,
                          );
                        },
                        text: languageController.getTranslation('update_manager'),
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
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ).paddingOnly(top: 20)),
                     
                     SizedBox(height: 30), // Add extra spacing after button
                   ],
                  ).paddingSymmetric(horizontal: 15),
                ),
              ).paddingOnly(top: 20, bottom: 15),
              SizedBox(height: 20), // Add space between main container and footer
              CustomBottomContainerPostLogin()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    final TextInputType? keyBoardType,
    bool obscureText = false,
  }) {
    return Container(
      height: 42,
      child: TextFormField(
        keyboardType: keyBoardType,
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(left: 5),
          hintText: hintText,
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
      ),
    );
  }
}


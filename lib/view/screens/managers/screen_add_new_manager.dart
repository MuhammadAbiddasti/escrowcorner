import 'package:escrowcorner/view/screens/managers/controller_managers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_ballance_container/custom_btc_container.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../controller/logo_controller.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';
import '../change_password/textfeild.dart';
import '../user_profile/user_profile_controller.dart';
import '../../../widgets/common_header/common_header.dart';
import '../../controller/language_controller.dart';

// Create controllers outside of the widget

class ScreenNewManager extends StatefulWidget {
  @override
  _ScreenNewManagerState createState() => _ScreenNewManagerState();
}

class _ScreenNewManagerState extends State<ScreenNewManager> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  LogoController logoController = Get.put(LogoController());
  ManagersController managersController = Get.find();
  final UserProfileController userProfileController = Get.find<UserProfileController>();
  final LanguageController languageController = Get.find<LanguageController>();

  @override
  void initState() {
    super.initState();
    // Clear any previously selected applications when adding a new manager
    managersController.clearSelectionsForNavigation();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      managersController.getApplications();
    });
  }

  @override
  void dispose() {
    // Clear selected applications when leaving the screen
    managersController.clearSelectionsForNavigation();
    
    // Dispose text controllers
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confPasswordController.dispose();
    _phoneController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: Get.find<LanguageController>().getTranslation('create_manager'),
        managerId: userProfileController.userId.value,
      ),
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
                          fontFamily: 'Nunito',
                        ),
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
                          fontFamily: 'Nunito',
                        ),
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
                          fontFamily: 'Nunito',
                        ),
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
                          fontFamily: 'Nunito',
                        ),
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
                          hint: languageController.getTranslation('phone'),
                          textStyle: TextStyle(fontSize: 13),
                        )),
                      ),
                      Obx(() => Text(
                        languageController.getTranslation('password'),
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito',
                        ),
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
                          controller: _passwordController,
                          hint: languageController.getTranslation('password'),
                          textStyle: TextStyle(fontSize: 13),
                          isPasswordField: true,
                        )),
                      ),
                      Obx(() => Text(
                        languageController.getTranslation('confirm_password'),
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito',
                        ),
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
                          controller: _confPasswordController,
                          hint: languageController.getTranslation('confirm_password'),
                          textStyle: TextStyle(fontSize: 13),
                          isPasswordField: true,
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
                          // Adding a delay of 3 seconds before the API call
                          await Future.delayed(Duration(seconds: 2));
                          // Creating a new manager
                          await managersController.createManager(
                            context: context,
                            email: _emailController.text,
                            firstName: _firstNameController.text,
                            lastName: _lastNameController.text,
                            password: _passwordController.text,
                            ConfPassword: _confPasswordController.text,
                            phone: _phoneController.text,
                          );
                        },
                        text: languageController.getTranslation('create_manager'),
                        options: FFButtonOptions(
                          width: Get.width,
                          height: 45.0,
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                          color: DamaspayTheme.of(context).primary,
                          textStyle: DamaspayTheme.of(context).titleSmall.override(
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
                      ).paddingOnly(top: 15)),
                      
                      SizedBox(height: 30), // Add more bottom spacing for the button
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
    bool obscureText = false,
    final TextInputType? keyBoardType,
  }) {
    return Container(
      height: 44,
      child: TextFormField(
        cursorColor: Colors.black,
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

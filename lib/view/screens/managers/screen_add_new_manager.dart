import 'package:dacotech/view/screens/managers/controller_managers.dart';
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

// Create controllers outside of the widget


class ScreenNewManager extends StatelessWidget {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  LogoController logoController =Get.put(LogoController());
 ManagersController managersController =Get.find();
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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              //CustomBtcContainer().paddingOnly(top: 20),
          Container(
            height: MediaQuery.of(context).size.height * .79,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0xffFFFFFF),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Email",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xff484848),
                      fontFamily: 'Nunito'),
                ).paddingOnly(top: 10, bottom: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xff666565), // Border color
                    ),
                    borderRadius: BorderRadius.circular(5), // Rounded corners
                  ),
                  child: CustomNewField(
                    obscureText: false,
                    controller: _emailController,
                    hint: "Email",
                    textStyle: TextStyle(fontSize: 13),
                  ),
                ),

                Text(
                  "First Name",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xff484848),
                      fontFamily: 'Nunito'),
                ).paddingOnly(top: 10, bottom: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xff666565), // Border color
                    ),
                    borderRadius: BorderRadius.circular(5), // Rounded corners
                  ),
                  child: CustomNewField(
                    obscureText: false,
                    controller: _firstNameController,
                    hint: "First Name",
                    textStyle: TextStyle(fontSize: 13),
                  ),
                ),
                Text(
                  "Last Name",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xff484848),
                      fontFamily: 'Nunito'),
                ).paddingOnly(top: 10, bottom: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xff666565), // Border color
                    ),
                    borderRadius: BorderRadius.circular(5), // Rounded corners
                  ),
                  child: CustomNewField(
                    obscureText: false,
                    controller: _lastNameController,
                    hint: "Last Name",
                    textStyle: TextStyle(fontSize: 13),
                  ),
                ),
                Text(
                  "Phone Number",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xff484848),
                      fontFamily: 'Nunito'),
                ).paddingOnly(top: 10, bottom: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xff666565), // Border color
                    ),
                    borderRadius: BorderRadius.circular(5), // Rounded corners
                  ),
                  child: CustomNewField(
                    obscureText: false,
                    controller: _phoneController,
                    hint: "Phone",
                    textStyle: TextStyle(fontSize: 13),
                  ),
                ),
                Text(
                  "Password",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xff484848),
                      fontFamily: 'Nunito'),
                ).paddingOnly(top: 10, bottom: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xff666565), // Border color
                    ),
                    borderRadius: BorderRadius.circular(5), // Rounded corners
                  ),
                  child: CustomNewField(
                    obscureText: false,
                    controller: _passwordController,
                    hint: "Password",
                    textStyle: TextStyle(fontSize: 13),
                    isPasswordField: true,
                  ),
                ),

                Text(
                  "Confirm Password",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xff484848),
                      fontFamily: 'Nunito'),
                ).paddingOnly(top: 10, bottom: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xff666565), // Border color
                    ),
                    borderRadius: BorderRadius.circular(5), // Rounded corners
                  ),
                  child: CustomNewField(
                    obscureText: false,
                    controller: _confPasswordController,
                    hint: "Confirm Password",
                    textStyle: TextStyle(fontSize: 13),
                    isPasswordField: true,
                  ),
                ),
                FFButtonWidget(
                  onPressed: () async {
                    // Adding a delay of 3 seconds before the API call
                    await Future.delayed(Duration(seconds: 2));
                    // Creating a new manager
                   await managersController.createManager(context: context,
                      email: _emailController.text,
                      firstName: _firstNameController.text,
                      lastName: _lastNameController.text,
                      password: _passwordController.text,
                     ConfPassword: _confPasswordController.text,
                      phone: _phoneController.text,
                    );
                  },
                  text: 'Create Manager',
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
                ).paddingOnly(top: 15),
              ],
            ).paddingSymmetric(horizontal: 15),
          ).paddingOnly(top: 20, bottom: 15),
              CustomBottomContainer()
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
   final TextInputType? keyBoardType
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

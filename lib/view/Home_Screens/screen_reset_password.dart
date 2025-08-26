import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_appbar/custom_appbar.dart';
import '../../widgets/custom_button/damaspay_button.dart';
import '../theme/damaspay_theme/Damaspay_theme.dart';
import '../controller/forgot_password_controller.dart';
import 'custom_leading_appbar.dart';
import '../../widgets/language_selector/language_selector_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login/screen_login.dart';
import '../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../controller/language_controller.dart';

class ScreenResetPassword extends StatelessWidget {
  final ForgotPasswordController controller = Get.put(ForgotPasswordController());
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final args = Get.arguments as Map?;
    final userId = args != null ? args['userId'] : null;
    final email = args != null ? args['email'] : null;
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: Color(0xff0f9373),
        title: AppBarTitle(),
        leading: CustomLeadingAppbar(),
        actions: [
          QuickLanguageSwitcher(),
          IconButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('auth_token');
              if (token == null || token.isEmpty) {
                Get.offAll(() => ScreenLogin());
              }
            },
            icon: Icon(Icons.account_circle, color: Color(0xffFEA116), size: 30),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  languageController.getTranslation('reset_password'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Color(0xff484848),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                TextField(
                  controller: otpController,
                  decoration: InputDecoration(
                    labelText: languageController.getTranslation('enter_code'),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: languageController.getTranslation('new_password'),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: languageController.getTranslation('confirm_password'),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 32),
                FFButtonWidget(
                  onPressed: () async {
                    final otp = otpController.text.trim();
                    final password = passwordController.text.trim();
                    final confirmPassword = confirmPasswordController.text.trim();
                    await controller.submitResetPassword(
                      otp: otp,
                      password: password,
                      confirmPassword: confirmPassword,
                      userId: userId,
                      email: email,
                    );
                  },
                  text: languageController.getTranslation('submit'),
                  options: FFButtonOptions(
                    width: Get.width,
                    height: 45.0,
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
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomContainer(),
    );
  }
} 
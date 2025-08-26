import 'package:escrowcorner/view/controller/forgot_password_controller.dart';
import 'package:escrowcorner/view/screens/login/screen_login.dart';
import 'package:escrowcorner/view/screens/register/screen_signup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_appbar/custom_appbar.dart';

import '../../widgets/custom_button/damaspay_button.dart';
import '../../widgets/custom_textField/custom_field.dart';
import '../controller/logo_controller.dart';
import '../theme/damaspay_theme/Damaspay_theme.dart';
import 'custom_leading_appbar.dart';
import '../controller/language_controller.dart';
import '../../widgets/language_selector/language_selector_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenForgotPassword extends StatelessWidget {
  final LogoController logoController = Get.put(LogoController());
  final ForgotPasswordController forgotPasswordController =Get.put(ForgotPasswordController());
  final LanguageController languageController = Get.find<LanguageController>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(backgroundColor: Color(0xffE6F0F7),
        appBar: AppBar(backgroundColor: Color(0xff0f9373),
          title: AppBarTitle(),
          leading: CustomLeadingAppbar(),
          actions: [
            QuickLanguageSwitcher(),
            IconButton(onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('auth_token');
              if (token == null || token.isEmpty) {
                Get.offAll(() => ScreenLogin());
              }
            }, icon: Icon(Icons.account_circle,color: Color(0xffFEA116), size: 30,))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height*.36,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Color(0xffCDE0EF),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(offset: Offset(1, 1),blurRadius:6,color: Colors.grey )
                    ]
                ),
                child: Container(
                    height: 240,
                    width: Get.width*.3,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage("assets/images/forgot.png",))
                  ),
                    ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Text(languageController.getTranslation('reset_password'),style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xff666565),
                    fontSize: 28,
                    fontFamily:'Nunito'
                ),).paddingOnly(top: 30),
              ),
              SizedBox(height: 10,),
              CustomField(
                label: languageController.getTranslation('email_address'),
                controller: forgotPasswordController.emailController,
              ),
              FFButtonWidget(
                onPressed: () async {
                  await forgotPasswordController.resetPassword(forgotPasswordController.emailController.text);
                },
                text: languageController.getTranslation('reset_password'),
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
              ).paddingSymmetric(horizontal: 20, vertical: 30),
              Row(
                children: [
                  Text(
                    languageController.getTranslation('dont_have_an_account_yet'),style: TextStyle(
                      fontSize: 14,fontWeight: FontWeight.w400,
                      color: Color(0xff666565)
                  ),
                  ),
                  SizedBox(width: 20,),
                  GestureDetector(
                    onTap: (){
                      Get.to(ScreenSignUp());
                    },
                    child: Container(
                      height: 25,width: 68,
                      decoration:BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xffCDE0EF)
                      ),
                      child: Center(
                        child: Text(
                          languageController.getTranslation('sign_up'),style: TextStyle(
                            fontSize: 14,fontWeight: FontWeight.w400,
                            color: Color(0xff666565)
                
                        ),
                        ),
                      ),
                    ),
                  )
                ],
              ).paddingSymmetric(horizontal: 20,vertical: 30),
              Row(
                children: [
                  Text(
                    languageController.getTranslation('have_account'),style: TextStyle(
                      fontSize: 14,fontWeight: FontWeight.w400,
                      color: Color(0xff666565)
                  ),
                  ),
                  SizedBox(width: 20,),
                  GestureDetector(
                    onTap: (){
                      Get.to(ScreenLogin());
                    },
                    child: Container(
                      height: 25,width: 68,
                      decoration:BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xffCDE0EF)
                      ),
                      child: Center(
                        child: Text(
                          languageController.getTranslation('sign_in'),style: TextStyle(
                            fontSize: 14,fontWeight: FontWeight.w400,
                            color: Color(0xff666565)
                
                        ),
                        ),
                      ),
                    ),
                  )
                ],
              ).paddingSymmetric(horizontal: 20)
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:dacotech/view/controller/forgot_password_controller.dart';
import 'package:dacotech/view/screens/login/screen_login.dart';
import 'package:dacotech/view/screens/register/screen_signup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_appbar/custom_appbar.dart';
import '../../widgets/custom_button/custom_button.dart';
import '../../widgets/custom_button/damaspay_button.dart';
import '../../widgets/custom_textField/custom_field.dart';
import '../controller/logo_controller.dart';
import '../theme/damaspay_theme/Damaspay_theme.dart';
import 'custom_leading_appbar.dart';

class ScreenForgotPassword extends StatelessWidget {
  final LogoController logoController = Get.put(LogoController());
  final ForgotPasswordController forgotPasswordController =Get.put(ForgotPasswordController());
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(backgroundColor: Color(0xffE6F0F7),
        appBar: AppBar(backgroundColor: Color(0xff0766AD),
          title: AppBarTitle(),
          leading: CustomLeadingAppbar(),
          actions: [
            IconButton(onPressed: (){}, icon: Icon(Icons.language,color: Colors.green,size: 30,)),
            IconButton(onPressed: (){
              Get.to(ScreenLogin());
            }, icon: Icon(Icons.account_circle,color: Color(0xffFEA116),
              size: 30,))
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
                child: Text("Reset Password",style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xff666565),
                    fontSize: 28,
                    fontFamily:'Nunito'
                ),).paddingOnly(top: 30),
              ),
              SizedBox(height: 10,),
              CustomField(
                label: "Email Address",
                controller: forgotPasswordController.emailController,
              ),
              FFButtonWidget(
                onPressed: () async {
                  await forgotPasswordController.resetPassword(forgotPasswordController.emailController.text);
                },
                text: 'RESET PASSWORD',
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
                    "Don't have an account?",style: TextStyle(
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
                          "Sign Up",style: TextStyle(
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
                    "Have an account?",style: TextStyle(
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
                          "Sign In",style: TextStyle(
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

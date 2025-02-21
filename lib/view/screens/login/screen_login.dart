import 'package:dacotech/view/screens/login/login_controller.dart';
import 'package:dacotech/view/Home_Screens/screen_forgotPassword.dart';
import 'package:dacotech/view/screens/register/screen_signup.dart';
import 'package:dacotech/widgets/custom_button/custom_button.dart';
import 'package:dacotech/widgets/custom_textField/custom_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../controller/logo_controller.dart';
import '../../Home_Screens/custom_leading_appbar.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';

class ScreenLogin extends StatelessWidget {
  final LogoController logoController = Get.put(LogoController());
  final LoginController loginController= Get.put(LoginController());

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
              //Get.to(ScreenKyc1());
            }, icon: Icon(Icons.account_circle,color: Color(0xffFEA116),
              size: 30,))
          ],
        ),
        body:
        SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height*.41,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xffCDE0EF),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(offset: Offset(1, 1),blurRadius:10,color: Colors.grey )
                  ]
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        height: 250,
                        width: Get.width*.83,
                        child: Image(image: AssetImage("assets/images/login.png"),
                        fit: BoxFit.fill,)).paddingOnly(top: 10),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Text("User Login",style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  color: Color(0xff666565),
                  fontFamily:'Nunito'
                ),).paddingOnly(top: 30),
              ),
              SizedBox(height: 10,),
              CustomField(
                label: "Email",
                controller: loginController.emailController,
              ),
              CustomField(
                label: 'password',
                controller: loginController.passwordController,
                isPasswordField: true,
              ),
              FFButtonWidget(
                onPressed: () async {
                  if (!loginController.isLoading.value) {
                    await loginController.login(context);
                    loginController.emailController.clear();
                    loginController.passwordController.clear();
                  }
                },
                text: 'LOGIN',
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
              ).paddingSymmetric(horizontal: 20, vertical: 10),
              Obx(() => loginController.errorMessage.isNotEmpty
                  ? Text(
                loginController.errorMessage.value,
                style: TextStyle(color: Colors.red),
              ).paddingOnly(top: 10)
                  : SizedBox.shrink()),
              TextButton(onPressed: (){
                Get.to(ScreenForgotPassword());
              }, child: Text(
                "Forgot Password?",style: TextStyle(
                fontSize: 14,fontWeight: FontWeight.w400,
                color: Color(0xff666565)

              ),
              )).paddingSymmetric(horizontal: 10,vertical: 5),
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
              ).paddingSymmetric(horizontal: 20)
            ],
          ),
        ),
      ),
    );
  }
}

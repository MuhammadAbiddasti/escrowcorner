import 'package:dacotech/view/Home_Screens/screen_forgotPassword.dart';
import 'package:dacotech/view/screens/login/screen_login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import 'package:country_code_picker/country_code_picker.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../../widgets/custom_textField/custom_field.dart';
import '../../controller/logo_controller.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';
import 'sign_up_controller.dart';
import '../../Home_Screens/custom_leading_appbar.dart'; // Adjust the path as necessary

class ScreenSignUp extends StatelessWidget {
  final SignUpController signUpController = Get.put(SignUpController());
  final LogoController logoController = Get.put(LogoController());

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: Color(0xff0766AD),
        title: AppBarTitle(),
        leading: CustomLeadingAppbar(),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.language, color: Colors.green, size: 30),
          ),
          IconButton(
            onPressed: () {},
            icon:
                Icon(Icons.account_circle, color: Color(0xffFEA116), size: 30),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeaderImage(context),
            buildSignUpForm(context),
            buildTermsAndConditions(),
            buildSignUpButton(context),
            buildForgotPassword(),
            buildSignInOption(),
          ],
        ),
      ),
    );
  }

  Widget buildHeaderImage(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .41,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xffCDE0EF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(offset: Offset(1, 1), blurRadius: 6, color: Colors.grey),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 250,
            //width: Get.width * .84,
            child: Image(
              image: AssetImage("assets/images/signup.png"),
              fit: BoxFit.fill,
            ),
          ).paddingOnly(top: 10),
        ],
      ),
    );
  }
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Widget buildSignUpForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              "User Signup",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xff484848),
                fontSize: 28,
                fontFamily: 'Nunito',
              ),
            ).paddingOnly(top: 30),
          ),
          CustomField(
              label: "User Name",
              //controller: signUpController.nameController,
              controller: signUpController.nameController,
              counterColor: Colors.black),
          CustomField(
              label: "First Name",
              controller: signUpController.firstNameController),
          CustomField(
              label: "Last Name",
              controller: signUpController.lastNameController),
          CustomField(
            label: 'Email',
            controller: signUpController.emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          Obx(() {
            // Synchronize the controller with the selected country
            signUpController.countrypic.text = signUpController.selectedCountry.value;
            return CustomField(
              readOnly: true,
              label: "Select Your Country",
              controller: signUpController.countrypic, // Pass the TextEditingController
              suffix: IconButton(
                onPressed: () {
                  _showCountrySelectionDialog(context); // Show country selection dialog
                },
                icon: Icon(Icons.expand_more),
              ),
            );
          }),
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(right: 8.0), // Add space between the country code and TextField
                child: Obx((){
                  final code = signUpController.countryCode.value;
                  return Text(
                    code.isEmpty ? '+237' : code, // Show the default country code if not set
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  );
                }
                ),
              ),
              Expanded(
                child: CustomField(
                  label: "Mobile Number",
                  controller: signUpController.phoneController,
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ).paddingSymmetric(horizontal: 25),

          CustomField(
              label: "Password",
              controller: signUpController.passwordController,
              isPasswordField: true),
          CustomField(
              label: "Repeat Password",
              controller: signUpController.confirmPasswordController,
              isPasswordField: true),
        ],
      ),
    );
  }

  Widget buildTermsAndConditions() {
    return Row(
      children: [
        Obx(
          () => Checkbox(
            activeColor: Color(0xff18CE0F),
            value: signUpController.isChecked.value,
            onChanged: (bool? value) {
              signUpController.isChecked.value = value ?? false;
            },
          ),
        ),
        RichText(
          text: TextSpan(
            style: TextStyle(color: Color(0xff666565), fontSize: 16.0),
            children: <TextSpan>[
              TextSpan(text: 'I read and agree to the '),
              TextSpan(
                text: 'Terms of Usage',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildSignUpButton(BuildContext context) {
    return FFButtonWidget(
      onPressed: ()  async {
        print("${signUpController.nameController.text}");
        print("${signUpController.firstNameController.text}");
        print("${signUpController.lastNameController.text}");
        print("${signUpController.emailController.text}");
        print("${signUpController.countrypic.text}");
        print("${signUpController.nameController.text}");
        print("${signUpController.passwordController.text}");
        print("${signUpController.countrycode.value.text}");
         await signUpController.signUp(context);
      },
      text: 'SIGN UP',
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
    ).paddingSymmetric(horizontal: 20, vertical: 10);
  }

  Widget buildForgotPassword() {
    return TextButton(
      onPressed: () {
        Get.to(() => ScreenForgotPassword());
      },
      child: Text(
        "Forgot Password?",
        style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xff666565)),
      ),
    ).paddingSymmetric(horizontal: 10, vertical: 5);
  }

  Widget buildSignInOption() {
    return Row(
      children: [
        Text(
          "Have an account?",
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xff666565)),
        ).paddingOnly(bottom: 20),
        SizedBox(width: 20),
        GestureDetector(
          onTap: () {
            Get.to(() => ScreenLogin());
          },
          child: Container(
            height: 25,
            width: 68,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xffCDE0EF)),
            child: Center(
              child: Text(
                "Sign In",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff666565)),
              ),
            ),
          ).paddingOnly(bottom: 20),
        ),
      ],
    ).paddingSymmetric(horizontal: 20);
  }
  void updateCountryCode(String countryCode) {
    // Set the country code reactively
    signUpController.countryCode.value = countryCode;
  }

  void _showCountrySelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Country'),
          content: Container(
            width: double.maxFinite,
            child: Obx(() {
              if (signUpController.countryList.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: signUpController.countryList.length,
                itemBuilder: (BuildContext context, int index) {
                  final country = signUpController.countryList[index];
                  return ListTile(
                    title: Text(country.name),
                    onTap: () {
                      // Update the selected country and dial code
                      signUpController.selectedCountry.value = country.name;
                      signUpController.countrycode.text = country.dialCode;
                      updateCountryCode(country.dialCode);
                      print("hohoh:${signUpController.countryCode.value}");
                      Navigator.pop(context);
                    },
                  );
                },
              );
            }),
          ),
        );
      },
    );
  }

}
class Country {
  final String name;
  final String dialCode;

  Country({required this.name, required this.dialCode});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'],
      dialCode: json['prefix'],  // Assuming 'prefix' holds the dial code in the API response
    );
  }
}


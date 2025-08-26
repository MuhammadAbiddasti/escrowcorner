import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../../widgets/custom_textField/custom_field.dart';

import '../../controller/logo_controller.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';
import 'sign_up_controller.dart';
import '../../Home_Screens/custom_leading_appbar.dart'; // Adjust the path as necessary

import '../../../widgets/language_selector/language_selector_widget.dart';
import '../../controller/language_controller.dart'; // Added for language selection
import 'package:shared_preferences/shared_preferences.dart';
import '../login/screen_login.dart';

class ScreenSignUp extends StatelessWidget {
  final SignUpController signUpController = Get.put(SignUpController());
  final LogoController logoController = Get.put(LogoController());
  final LanguageController languageController = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {

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
      body: RefreshIndicator(
        onRefresh: () async {
          signUpController.nameController.clear();
          signUpController.firstNameController.clear();
          signUpController.lastNameController.clear();
          signUpController.emailController.clear();
          signUpController.passwordController.clear();
          signUpController.confirmPasswordController.clear();
          signUpController.phoneController.clear();
          signUpController.countrypic.clear();
          signUpController.countrycode.clear();
          signUpController.isChecked.value = false;
          signUpController.selectedCountry.value = '';
          signUpController.countryCode.value = '+237';
          
          // Reset signup language to local default (do not change global app language)
          signUpController.selectedLanguage.value = 'English';
          signUpController.selectedLanguageId.value = 1;
          signUpController.selectedLanguageLocale.value = 'en';
          signUpController.languagepic.text = 'English';
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHeaderImage(context),
              buildSignUpForm(context),
              buildTermsAndConditions(),
              buildSignUpButton(context),
            ],
          ),
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
          BoxShadow(
            offset: Offset(1, 1),
            blurRadius: 10,
            color: Colors.grey,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 250,
            width: Get.width * .83,
            child: Image(
              image: AssetImage("assets/images/signup.png"),
              fit: BoxFit.fill,
            ),
          ).paddingOnly(top: 10),
          Text(
            languageController.getTranslation('create_account'),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 28,
              color: Color(0xff666565),
              fontFamily: 'Nunito',
            ),
          ).paddingOnly(top: 20),
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
          CustomField(
              label: languageController.getTranslation('user_name'),
              //controller: signUpController.nameController,
              controller: signUpController.nameController,
              counterColor: Colors.black),
          CustomField(
              label: languageController.getTranslation('first_name'),
              controller: signUpController.firstNameController),
          CustomField(
              label: languageController.getTranslation('last_name'),
              controller: signUpController.lastNameController),
          CustomField(
            label: languageController.getTranslation('email'),
            controller: signUpController.emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          Obx(() {
            // Synchronize the controller with the selected country
            signUpController.countrypic.text = signUpController.selectedCountry.value;
            return CustomField(
              readOnly: true,
              label: languageController.getTranslation('select_your_country'),
              controller: signUpController.countrypic, // Pass the TextEditingController
              suffix: IconButton(
                onPressed: () {
                  _showCountrySelectionDialog(context); // Show country selection dialog
                },
                icon: Icon(Icons.expand_more),
              ),
            );
          }),
          // Language selection (read-only field with dialog, similar to country)
          Obx(() {
            // Rebuild when the signup-selected language changes, but do not sync from global header
            final _ = signUpController.selectedLanguage.value;
            return CustomField(
              readOnly: true,
              label: languageController.getTranslation('select_your_language'),
              controller: signUpController.languagepic,
              suffix: IconButton(
                onPressed: () {
                  _showLanguageSelectionDialog(context);
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
                  label: languageController.getTranslation('enter_whatsapp_number'),
                  controller: signUpController.phoneController,
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ).paddingSymmetric(horizontal: 25),

          CustomField(
              label: languageController.getTranslation('password'),
              controller: signUpController.passwordController,
              isPasswordField: true),
          CustomField(
              label: languageController.getTranslation('repeat_password'),
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
              TextSpan(text: languageController.getTranslation('i_read_and_agree_to_the')),
              TextSpan(
                text: languageController.getTranslation('terms_of_usage'),
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
      text: languageController.getTranslation('sign_up'),
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

  void updateCountryCode(String countryCode) {
    // Set the country code reactively
    signUpController.countryCode.value = countryCode;
  }

  void _showCountrySelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageController.getTranslation('select_country')),
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
  
  void _showLanguageSelectionDialog(BuildContext context) {
    final lc = Get.find<LanguageController>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageController.getTranslation('select_your_language')),
          content: Container(
            width: double.maxFinite,
            child: Obx(() {
              if (lc.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              if (lc.hasError.value) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(languageController.getTranslation('failed_to_load_languages')),
                    SizedBox(height: 8),
                    TextButton(
                      onPressed: () => lc.refreshLanguages(),
                      child: Text(languageController.getTranslation('retry')),
                    )
                  ],
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: lc.languages.length,
                itemBuilder: (BuildContext context, int index) {
                  final language = lc.languages[index];
                  return ListTile(
                    leading: Icon(Icons.language),
                    title: Text(language.name),
                    subtitle: Text(language.locale.toUpperCase()),
                    onTap: () {
                      // Only update signup-local selection; do not change global app language
                      signUpController.selectedLanguage.value = language.name;
                      signUpController.selectedLanguageId.value = language.id;
                      signUpController.selectedLanguageLocale.value = language.locale;
                      signUpController.languagepic.text = language.name;
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


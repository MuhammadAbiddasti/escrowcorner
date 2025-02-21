import 'package:country_code_picker/country_code_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:dacotech/view/Kyc_screens/screen_kyc4.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_appbar/custom_appbar.dart';
import '../../widgets/custom_button/custom_button.dart';
import '../screens/user_profile/user_profile_controller.dart';

class ScreenKyc3 extends StatelessWidget {
  TextEditingController countrypic = TextEditingController();
  TextEditingController countrycode = TextEditingController();
  final UserProfileController userProfileController =Get.find<UserProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffE6F0F7),
       appBar: AppBar(
        backgroundColor: const Color(0xff0766AD),
    title: AppBarTitle(),
         leading: CustomPopupMenu(managerId: userProfileController.userId.value,),
         actions: [
    PopupMenuButtonAction(),
    AppBarProfileButton(),
    ],
    ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              //height: MediaQuery.of(context).size.height * .75,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xffFFFFFF),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("KYC Setting",style: TextStyle(
                      fontSize: 17,fontWeight: FontWeight.w700,color: Colors.black87
                  ),).paddingOnly(bottom: 20,top: 10),
                  Text("Submit Your KYC - Step 3",style: TextStyle(
                      fontSize: 20,fontWeight: FontWeight.w700,color: Colors.black
                  ),),
        
                  Text(
                    "Country:",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xff484848),
                        fontFamily: 'Nunito'),
                  ).paddingOnly(top: 10, bottom: 10),
                  _buildTextField(
                    readOnly: true,
                    controller: countrypic,
                    suffix: IconButton(
                      onPressed: () {
                        showCountryPicker(
                          context: context,
                          favorite: <String>['CM'],
                          showPhoneCode: true,
                          onSelect: (Country country) {
                            countrypic.text = '${country.name}';
                          },
                        );
                      },
                      icon: Icon(Icons.expand_more),
                    ),
                    //controller: _lastNameController,
                    hintText: '',
                  ),
                  Text(
                    "Number for MTN",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xff484848),
                        fontFamily: 'Nunito'),
                  ).paddingOnly(top: 10, bottom: 10),
                  _buildTextField(
                    //controller: _lastNameController,
                    keyboardType: TextInputType.number,
                    prefix: CountryCodePicker(
                      onChanged: (value) {
                        countrycode.text = value.code ?? '';
                      },
                      initialSelection: 'CM',
                    ),
                    hintText: '',
                  ),
                  Text(
                    "Number for Orange",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xff484848),
                        fontFamily: 'Nunito'),
                  ).paddingOnly(top: 10, bottom: 10),
                  _buildTextField(
                    //controller: _lastNameController,
                    keyboardType: TextInputType.number,
                    prefix: CountryCodePicker(
                      onChanged: (value) {
                        countrycode.text = value.code ?? '';
                      },
                      initialSelection: 'CM',
                    ),
                    hintText: '',
                  ),
        
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(
                        width: MediaQuery.of(context).size.width * 0.4,
                        text: "Step Back",
                        onPressed: () {
                          Get.back(); // Navigates back
                        },
                      ),
                      CustomButton(
                        width: MediaQuery.of(context).size.width * 0.4,
                        text: "Next",
                        onPressed: () {
                          Get.to(ScreenKyc4());
                        },
                      ),
                    ],
                  ).paddingOnly(top: 30, bottom: 30),
                ],
              ).paddingSymmetric(horizontal: 10),
            ).paddingOnly(top: 15,bottom: 15)
          ],
        ).paddingSymmetric(horizontal: 15),
      ),
    );
  }

  Widget _buildTextField({
    final TextEditingController? controller,
    required String hintText,
    bool obscureText = false,
    final Widget? suffix,
    final Widget? prefix,
    final bool? readOnly,
    final TextInputType? keyboardType

  }) {
    return Container(
      height: 50,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly ?? false,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          suffixIcon: suffix,
          prefixIcon: prefix,
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

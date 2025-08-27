import 'package:escrowcorner/widgets/custom_api_url/constant_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/common_layout/common_layout.dart';
import '../../../widgets/common_header/common_header.dart';
import '../../controller/language_controller.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../controller/logo_controller.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';
import 'user_profile_controller.dart';

class ScreenPersonInfo extends StatelessWidget {
  final LogoController logoController = Get.put(LogoController());
  final UserProfileController userProfileController = Get.find<UserProfileController>();
  FocusNode firstNameFocusNode = FocusNode();
  FocusNode lastNameFocusNode = FocusNode();
  FocusNode userNameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();

  void dispose() {
    // Dispose the FocusNodes to prevent memory leaks
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    userNameFocusNode.dispose();
    emailFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: languageController.getTranslation('personal_information'),
        managerId: userProfileController.userId.value,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await userProfileController.fetchUserDetails();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Center(
            child: Column(
              children: [
                buildProfileInfoSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget buildPopupMenuItem(BuildContext context, String title, Widget screen) {
    return PopupMenuItem<String>(
      value: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            child: Text(
              title,
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Get.off(screen);
            },
          ),
          Divider(
            color: Color(0xffCDE0EF),
          )
        ],
      ),
    );
  }


  Widget buildProfileInfoSection(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    return Container(
      //height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color(0xffFFFFFF),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                     Obx(() {
             final _ = languageController.selectedLanguage.value;
             return Text(
               languageController.getTranslation('personal_information'),
               style: TextStyle(
                   fontWeight: FontWeight.w700,
                   fontSize: 14,
                   color: Color(0xff18CE0F),
                   fontFamily: 'Nunito'),
             ).paddingOnly(top: 8);
           }),
                     Obx(() {
             final _ = languageController.selectedLanguage.value;
             return Text(
               languageController.getTranslation('profile_picture'),
               style: TextStyle(
                   fontWeight: FontWeight.w400,
                   fontSize: 12,
                   color: Color(0xff484848),
                   fontFamily: 'Nunito'),
             ).paddingOnly(top: 8);
           }),
                                           Container(
              height: 200,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Obx(() {
                // Check if the image file exists
                if (userProfileController.avatar.value != null &&
                    userProfileController.avatar.value!.path.isNotEmpty) {
                  return Image.file(
                    userProfileController.avatar.value!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.contain,
                  );
                } else if (userProfileController.avatarUrl.value.isNotEmpty) {
                  final avatarUrl = "$baseUrl/${userProfileController.avatarUrl.value}";
                  return Image.network(
                    avatarUrl,
                    height: 200,
                    width: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        "assets/images/userinfo.png",
                        height: 200,
                        width: 200,
                        fit: BoxFit.contain,
                      );
                    },
                  );
                } else {
                  return Image.asset(
                    "assets/images/userinfo.png",
                    height: 200,
                    width: 200,
                    fit: BoxFit.contain,
                  );
                }
              }),
            ),

                     Obx(() {
             final _ = languageController.selectedLanguage.value;
             return Text(
               languageController.getTranslation('upload_profile_picture'),
               style: TextStyle(
                   fontWeight: FontWeight.w400,
                   fontSize: 12,
                   color: Color(0xff484848),
                   fontFamily: 'Nunito'),
             ).paddingOnly(top: 8);
           }),

          Row(
            children: [
              GestureDetector(
                onTap: () => userProfileController.pickImage(),
                                 child: Container(
                   height: 35,
                   width: MediaQuery.of(context).size.width * 0.35,
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(5),
                     color: Color(0xffDDDDDD),
                   ),
                                     child: Center(
                     child: Obx(() {
                       final _ = languageController.selectedLanguage.value;
                       return Text(
                         languageController.getTranslation('choose_file'),
                         style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                       );
                     }),
                   ),
                ),
              ),
              SizedBox(width: 8), // Add some spacing between the elements
              // Obx(() {
              //   // Display the selected file name or "No file chosen"
              //   final fileName = userProfileController.avatarUrl.value?.split('/').last ?? "No file chosen";
              //   return Expanded(
              //     child: Text(
              //       fileName,
              //       style: TextStyle(color: Color(0xff666565)),
              //       maxLines: 1, // Limit to one line
              //       overflow: TextOverflow.ellipsis, // Add ellipses if text overflows
              //     ),
              //   );
              // }),
            ],
          ),

          buildTextField(languageController.getTranslation('first_name'), userProfileController.firstNameController,firstNameFocusNode, fieldKey: 'first_name'),
          buildTextField(languageController.getTranslation('last_name'), userProfileController.lastNameController,lastNameFocusNode, fieldKey: 'last_name'),
          buildTextField(languageController.getTranslation('user_name'), userProfileController.userNameController,userNameFocusNode, readOnly: true, fieldKey: 'user_name'),
          buildTextField(languageController.getTranslation('email'), userProfileController.emailController,emailFocusNode, readOnly: true, fieldKey: 'email'),
          buildAccountTypeField(languageController),
                     FFButtonWidget(
             onPressed: () async {
               // Adding a delay of 2 seconds before the API call
               await Future.delayed(Duration(seconds: 2));
              await userProfileController.updateUserDetails();
             },
             text: languageController.getTranslation('save'),
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
           ).paddingOnly(top: 20, bottom: 15),
                 ],
       ).paddingSymmetric(horizontal: 15),
     ).paddingOnly(top: 15, bottom: 10);
  }

     Widget buildAccountTypeField(LanguageController languageController) {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text(
           languageController.getTranslation('account_type'),
           style: TextStyle(
               fontWeight: FontWeight.w400,
               fontSize: 12,
               color: Color(0xff484848),
               fontFamily: 'Nunito'),
         ).paddingOnly(top: 8, bottom: 6),
         Container(
           height: 35,
           child: Obx(() {
             return TextFormField(
               readOnly: true,
               initialValue: userProfileController.accountType.value,
               decoration: InputDecoration(
                 contentPadding: EdgeInsets.only(top: 2, left: 5),
                 hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                 border: OutlineInputBorder(
                     borderSide: BorderSide(color: Color(0xff666565))),
                 enabledBorder: OutlineInputBorder(
                     borderSide: BorderSide(color: Color(0xff666565))),
                 focusedBorder: OutlineInputBorder(
                   borderSide: BorderSide(
                     color: Color(0xff666565),
                   ),
                 ),
                 filled: true,
                 fillColor: Colors.grey.withOpacity(.40),
               ),
             );
           }),
         ),
       ],
     );
   }

     Widget buildTextField(String label, TextEditingController controller,FocusNode focusNode, {bool readOnly = false, String? fieldKey}) {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text(
           label,
           style: TextStyle(
               fontWeight: FontWeight.w400,
               fontSize: 12,
               color: Color(0xff484848),
               fontFamily: 'Nunito'),
         ).paddingOnly(top: 8, bottom: 6),
         Container(
           height: 35,
           child: TextFormField(
             focusNode: focusNode,
             controller: controller,
             onChanged: (value) {
               if (fieldKey == 'first_name') {
                 userProfileController.firstName.value = value;
               } else if (fieldKey == 'last_name') {
                 userProfileController.lastName.value = value;
               }
             },
             readOnly: readOnly,
                            decoration: InputDecoration(
                 contentPadding: EdgeInsets.only(top: 2, left: 5),
                 hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                 border: OutlineInputBorder(
                     borderSide: BorderSide(color: Color(0xff666565))),
                 enabledBorder: OutlineInputBorder(
                     borderSide: BorderSide(color: Color(0xff666565))),
                 focusedBorder: OutlineInputBorder(
                   borderSide: BorderSide(
                     color: Color(0xff666565),
                   ),
                 ),
                 filled: readOnly,
                 fillColor: readOnly ? Colors.grey.withOpacity(.40) : null,
               ),
           ),
         ),
       ],
     );
   }
}

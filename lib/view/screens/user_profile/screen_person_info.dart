import 'package:dacotech/widgets/custom_api_url/constant_url.dart';
import 'package:dacotech/widgets/custom_appbar/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../controller/logo_controller.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';
import 'user_profile_controller.dart';

class ScreenPersonInfo extends StatelessWidget {
  final LogoController logoController = Get.put(LogoController());
  final UserProfileController userProfileController = Get.put(UserProfileController());
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
      body: RefreshIndicator(
        onRefresh: () async{
          await userProfileController.fetchUserDetails();
        },
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                buildProfileInfoSection(context),
                CustomBottomContainer(),
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
          Text(
            "Personal Information",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xff18CE0F),
                fontFamily: 'Nunito'),
          ).paddingOnly(top: 10),
          Text(
            "Profile Picture",
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xff484848),
                fontFamily: 'Nunito'),
          ).paddingOnly(top: 10),
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Obx(() {
              // Check if the image file exists
              if (userProfileController.avatar.value != null &&
                  userProfileController.avatar.value!.path.isNotEmpty) {
                return Image.file(
                  userProfileController.avatar.value!,
                  height: 300,
                  width: 200,
                  fit: BoxFit.fill,
                );
              } else if (userProfileController.avatarUrl.value.isNotEmpty) {
                final avatarUrl = "$baseUrl/${userProfileController.avatarUrl.value}";
                return Image.network(
                  avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "assets/images/userinfo.png",
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    );
                  },
                );
              } else {
                return Image.asset(
                  "assets/images/userinfo.png",
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                );
              }
            }),
          ),

          Text(
            "Upload Profile Picture",
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xff484848),
                fontFamily: 'Nunito'),
          ).paddingOnly(top: 10),

          Row(
            children: [
              GestureDetector(
                onTap: () => userProfileController.pickImage(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.05,
                  width: MediaQuery.of(context).size.width * 0.35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Color(0xffDDDDDD),
                  ),
                  child: Center(
                    child: Text(
                      "Choose File",
                      style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                    ),
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

          buildTextField("First Name", userProfileController.firstNameController,firstNameFocusNode),
          buildTextField("Last Name", userProfileController.lastNameController,lastNameFocusNode),
          buildTextField("User Name", userProfileController.userNameController,userNameFocusNode, readOnly: true),
          buildTextField("Email", userProfileController.emailController,emailFocusNode, readOnly: true),
          FFButtonWidget(
            onPressed: () async {
              // Adding a delay of 2 seconds before the API call
              await Future.delayed(Duration(seconds: 2));
             await userProfileController.updateUserDetails();
            },
            text: 'Save',
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
          ).paddingOnly(top: 30,bottom: 20),
        ],
      ).paddingSymmetric(horizontal: 15),
    ).paddingOnly(top: 20, bottom: 20);
  }

  Widget buildTextField(String label, TextEditingController controller,FocusNode focusNode, {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xff484848),
              fontFamily: 'Nunito'),
        ).paddingOnly(top: 10, bottom: 10),
        Container(
          height: 42,
          child: TextFormField(
            focusNode: focusNode,
            controller: controller,
            onChanged: (value) {
              if (label == "First Name") {
                userProfileController.firstName.value = value;
              } else if (label == "Last Name") {
                userProfileController.lastName.value = value;
              }
            },
            readOnly: readOnly,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(top: 4, left: 5),
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

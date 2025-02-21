import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/custom_appbar/custom_appbar.dart';
import '../../widgets/custom_button/custom_button.dart';
import '../screens/user_profile/user_profile_controller.dart';

class ScreenKyc4 extends StatelessWidget {
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
      body: Column(
        children: [

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0xffFFFFFF),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("KYC Setting",style: TextStyle(
                    fontSize: 17,fontWeight: FontWeight.w700,color: Colors.black87
                ),).paddingOnly(bottom: 20,top: 10),
                Text("Submit Your KYC - Step 4",style: TextStyle(
                    fontSize: 20,fontWeight: FontWeight.w700,color: Colors.black
                ),),
                Text(
                  "Please download the papers, fill them, scan, and re-submit.",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xff484848),
                      fontFamily: 'Nunito'),
                ).paddingOnly( bottom: 10),
                _buildDownloadButton(context),
                _buildTermsAndConditionsCheckbox(),
                _buildFileUploadSection(),
                _buildActionButtons(context),
              ],
            ).paddingSymmetric(horizontal: 15),
          ).paddingOnly(top: 15, bottom: 15),
        ],
      ).paddingSymmetric(horizontal: 15),
    );
  }

  // Widget for the "Download Attachment" button
  Widget _buildDownloadButton(BuildContext context) {
    return CustomButton(text: 'Download Attachment', onPressed: (){});
  }
  // Widget for the "I agree to the terms and conditions" checkbox
  Widget _buildTermsAndConditionsCheckbox() {
    bool isChecked = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Row(
          children: [
            Checkbox(
              value: isChecked,
              onChanged: (bool? value) {
                setState(() {
                  isChecked = value ?? false;
                });
              },
            ),
            Text("I agree to the terms and conditions"),
          ],
        );
      },
    ).paddingOnly(bottom: 20);
  }

  // Widget for the file upload section
  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Scan and Upload the Form:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        _buildFileChooser(),
      ],
    ).paddingOnly(bottom: 30);
  }

  // Helper method for File Chooser Button
  Widget _buildFileChooser() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xff666565)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () {
              // Logic to choose file
            },
            child: Text("Choose File"),
          ),
          SizedBox(width: 10),
          Text("No file chosen"),
        ],
      ),
    );
  }

  // Widget for the action buttons "Step Back" and "Submit"
  Widget _buildActionButtons(BuildContext context) {
    return Row(
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
          text: "Submit",
          onPressed: () {
            // Logic to submit form
          },
        ),
      ],
    ).paddingOnly(top: 20,bottom: 20);
  }
}

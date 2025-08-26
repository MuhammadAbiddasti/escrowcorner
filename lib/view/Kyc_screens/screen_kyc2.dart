import 'package:escrowcorner/view/Kyc_screens/screen_kyc3.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/custom_appbar/custom_appbar.dart';
import '../../widgets/custom_button/custom_button.dart';
import '../screens/user_profile/user_profile_controller.dart';

class ScreenKyc2 extends StatefulWidget {
  const ScreenKyc2({super.key});

  @override
  _ScreenKyc2State createState() => _ScreenKyc2State();
}

class _ScreenKyc2State extends State<ScreenKyc2> {
  final TextEditingController _idController = TextEditingController();
  String? selectedCategory;
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
                Text(
                  "KYC Setting",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ).paddingOnly(bottom: 20, top: 10),
                Text(
                  "Submit Your KYC - Step 2",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "Select just one identification and submit",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ).paddingOnly(bottom: 10),
                _buildDropdownField(),
                if (selectedCategory != null) _buildFileUploadWidgets(),
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
                        Get.to(ScreenKyc3());
                      },
                    ),
                  ],
                ).paddingOnly(top: 30, bottom: 30),
              ],
            ).paddingSymmetric(horizontal: 15),
          ).paddingOnly(top: 15, bottom: 15),
        ],
      ).paddingSymmetric(horizontal: 15),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      height: 42,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xff666565)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: selectedCategory,
        hint: Text('Select Identification'),
        icon: Icon(Icons.arrow_drop_down),
        underline: SizedBox(), // Remove default underline
        onChanged: (value) {
          setState(() {
            selectedCategory = value;
          });
        },
        items: [
          DropdownMenuItem(value: "Select", child: Text("Select")),
          DropdownMenuItem(value: "ID Card", child: Text("ID Card")),
          DropdownMenuItem(value: "Driver's License", child: Text("Driver's License")),
          DropdownMenuItem(value: "Passport", child: Text("Passport")),

        ],
      ),
    );
  }

  // Widget to build file upload options based on selected category
  Widget _buildFileUploadWidgets() {
    switch (selectedCategory) {
      case "ID Card":
        return _buildIdCardWidgets();
      case "Driver's License":
        return _buildDrivingLicenseWidgets();
      case "Passport":
        return _buildPassportWidgets();
      default:
        return SizedBox.shrink();
    }
  }

  // Widgets for ID Card
  Widget _buildIdCardWidgets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Government Issued ID Card (Front):"),
        _buildFileChooser(),
        SizedBox(height: 15),
        Text("Government Issued ID Card (Back):"),
        _buildFileChooser(),
        SizedBox(height: 15),
        Text("Self photo of yourself holding your ID Card:"),
        _buildFileChooser(),
      ],
    ).paddingOnly(top: 20);
  }

  // Widgets for Driving License
  Widget _buildDrivingLicenseWidgets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Government Issued Driving License:"),
        _buildFileChooser(),
        SizedBox(height: 15),
        Text("Self photo of yourself holding your Driving License:"),
        _buildFileChooser(),
      ],
    ).paddingOnly(top: 20);
  }

// Widgets for Passport
  Widget _buildPassportWidgets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Document Upload for $selectedCategory:"),
        _buildFileChooser(),
        SizedBox(height: 15),
        Text("Self photo of yourself holding your $selectedCategory:"),
        _buildFileChooser(),
      ],
    ).paddingOnly(top: 20);
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
}

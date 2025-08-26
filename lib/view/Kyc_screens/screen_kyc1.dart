import 'package:country_picker/country_picker.dart';
import 'package:escrowcorner/view/Kyc_screens/screen_kyc2.dart';
import 'package:escrowcorner/view/screens/user_profile/user_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_appbar/custom_appbar.dart';
import '../../widgets/custom_button/custom_button.dart';
import 'kyc_controller.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/custom_api_url/constant_url.dart';
import '../controller/language_controller.dart';
import '../../widgets/common_header/common_header.dart';

class ScreenKyc1 extends StatefulWidget {
  @override
  State<ScreenKyc1> createState() => _ScreenKyc1State();
}

class _ScreenKyc1State extends State<ScreenKyc1> {
  TextEditingController countryCon = TextEditingController();

  TextEditingController dateController = TextEditingController();

  final UserProfileController controller =
      Get.isRegistered<UserProfileController>()
          ? Get.find<UserProfileController>()
          : Get.put(UserProfileController());
@override
  void setState(VoidCallback fn) {
  controller.fetchUserDetails();
    super.setState(fn);
  }
  //final KycController kycController = Get.put(KycController());
  // @override
  // void initState() {
  //   super.initState();
  //   controller.fetchUserDetails(); // Fetch user details on screen load
  // }

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    //kycController.fetchKycStatus();
    // Remove KYC status checks for blocking UI
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: languageController.getTranslation('general_kyc'),
        managerId: controller.userId.value,
      ),
      // Always show the KYC form/content, never block or restrict
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchUserDetails();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Remove rejection message and blocking UI
              // The form is always shown and is filled with user data
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
                      languageController.getTranslation('kyc_setting'),
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87),
                    ).paddingOnly(bottom: 20, top: 10),
                    Obx(() {
                      final kycValue = controller.kyc.value ?? '';
                      print("KYC Status: $kycValue");

                      final Map<String, dynamic> statusStyles = {
                        '0': {
                          'message': languageController.getTranslation('kyc_status_pending'),
                          'textColor': Colors.blue,
                          'containerColor': Colors.blue.withOpacity(0.1),
                        },
                        '1': {
                          'message': languageController.getTranslation('kyc_status_pending_for_approval'),
                          'textColor': Colors.orange,
                          'containerColor': Colors.orange.withOpacity(0.1),
                        },
                        '2': {
                          'message': languageController.getTranslation('kyc_status_rejected_submit_again'),
                          'textColor': Colors.red,
                          'containerColor': Colors.red.withOpacity(0.1),
                        },
                        '3': {
                          'message': languageController.getTranslation('your_kyc_status_is_approved'),
                          'textColor': Colors.green,
                          'containerColor': Colors.green.withOpacity(0.1),
                        },
                      };

                      final statusStyle = statusStyles[kycValue] ?? {'message': '', 'textColor': Colors.black, 'containerColor': Colors.transparent};

                      // Show message and hide form if KYC is not approved
                      if (kycValue != '3') {
                        return GestureDetector(
                          onTap: () async {
                            if (await canLaunch(baseUrl)) {
                              await launch(baseUrl);
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(vertical: 24),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: statusStyle['containerColor'],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  languageController.getTranslation('please_complete_kyc_visit_the_website'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: statusStyle['textColor'],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  baseUrl,
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Only show the form if KYC is approved
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: statusStyle['containerColor'],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusStyle['message'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: statusStyle['textColor'],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),

                    Text(
                      languageController.getTranslation('first_name'),
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10, bottom: 10),
                    _buildTextField(
                      controller: controller.firstNameController,
                      hintText: '',
                    ),
                    Text(
                      languageController.getTranslation('last_name'),
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10, bottom: 10),
                    _buildTextField(
                      controller: controller.lastNameController,
                      hintText: '',
                    ),
                    Text(
                      languageController.getTranslation('birth_day'),
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10, bottom: 10),
                    _buildTextField(
                      controller: controller.dobController,
                      //controller: dateController, // Add your TextEditingController for date
                      hintText: 'MM/dd/yyyy',
                      readOnly: true,
                      // Specify that this is a date field
                      suffix: IconButton(
                        onPressed: () async {
                          DateTime? selectedDate = await showDatePicker(
                            context: context,
                            // Ensure you have the correct context
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );

                          if (selectedDate != null) {
                            // Format the selected date and set it to the controller
                            String formattedDate =
                                DateFormat('MM-dd-yyyy').format(selectedDate);
                            controller.dobController.text = formattedDate;
                          }
                        },
                        icon:
                            Icon(Icons.calendar_today), // Use any icon you prefer
                      ),
                    ),
                    Text(
                      languageController.getTranslation('address_line_1'),
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10, bottom: 10),
                    _buildTextField(
                      controller: controller.address1Controller,
                      hintText: '',
                    ),
                    Text(
                      languageController.getTranslation('city'),
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10, bottom: 10),
                    _buildTextField(
                      controller: controller.cityController,
                      hintText: '',
                    ),
                    Text(
                      languageController.getTranslation('country'),
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10, bottom: 10),
                    _buildTextField(
                      readOnly: true,
                      controller: controller.countryController,
                      suffix: IconButton(
                        onPressed: () {
                          showCountryPicker(
                            context: context,
                            favorite: <String>['CM'],
                            showPhoneCode: true,
                            onSelect: (Country country) {
                              countryCon.text = '${country.name}';
                            },
                          );
                        },
                        icon: Icon(Icons.expand_more),
                      ),
                      hintText: '',
                    ),
                    Text(
                      languageController.getTranslation('whatsapp_number'),
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10, bottom: 10),
                    _buildTextField(
                      readOnly: true,
                      controller: controller.whatsappController,
                      hintText: '',
                    ),
                    Obx(() {
                      return Center(
                        child: Text(
                          getKycStatusMessage(controller.kyc.value),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green, // Green text for "Approved" or "Pending for Approval"
                          ),
                        ).paddingOnly(top: 30, bottom: 20),
                      );
                      //     : CustomButton(
                      //   width: MediaQuery.of(context).size.width * 0.9,
                      //   text: "Next",
                      //   onPressed: () {
                      //     Get.to(ScreenKyc2());
                      //   },
                      // ).paddingOnly(top: 30, bottom: 30);
                    }),

                  ],
                ).paddingSymmetric(horizontal: 10),
              ).paddingOnly(top: 15, bottom: 15)
            ],
          ).paddingSymmetric(horizontal: 15),
        ),
      ),
    );
  }

  Widget _buildTextField({
    final TextEditingController? controller,
    required String hintText,
    bool obscureText = false,
    final Widget? suffix,
    final bool? readOnly,
  }) {
    return Container(
      height: 42,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly ?? false,
        decoration: InputDecoration(
          suffixIcon: suffix,
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

  String getKycStatusMessage(String kycStatus) {
    final languageController = Get.find<LanguageController>();
    switch (kycStatus) {
      case '0':
        return languageController.getTranslation('your_kyc_status_is_pending');
      case '1':
        return languageController.getTranslation('your_kyc_status_is_under_review');
      case '2':
        return languageController.getTranslation('your_kyc_has_been_rejected_upload_again');
      case '3':
        return languageController.getTranslation('your_kyc_status_is_approved');
      default:
        return languageController.getTranslation('your_kyc_status_is_unknown');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/common_header/common_header.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';

import '../../theme/damaspay_theme/Damaspay_theme.dart';
import '../user_profile/user_profile_controller.dart';
import '../../controller/language_controller.dart';
import 'merchant_controller.dart';

class ScreenAddMerchant extends StatefulWidget {
  @override
  _ScreenAddMerchantState createState() => _ScreenAddMerchantState();
}

class _ScreenAddMerchantState extends State<ScreenAddMerchant> {
  final MerchantController controller = Get.put(MerchantController());
  final UserProfileController userProfileController = Get.find<UserProfileController>();
  final LanguageController languageController = Get.find<LanguageController>();
  
  //final TextEditingController currencyController = TextEditingController();
  final TextEditingController merchantNameController = TextEditingController();
  
  // Loading state for submit button
  bool _isSubmitting = false;

  final TextEditingController merchantSuccessLinkController =
      TextEditingController();
  final TextEditingController merchantFailLinkController =
      TextEditingController();
  final TextEditingController merchantIpnLinkController =
      TextEditingController();
  final TextEditingController merchantDescriptionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Refresh/reset the screen every time it's loaded
    // Use addPostFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshScreen();
    });
  }

  void _refreshScreen() {
    // Reset all form controllers
    merchantNameController.clear();
    merchantDescriptionController.clear();
    
    // Reset controller values using GetX reactive variables
    controller.merchantName.value = '';
    controller.merchantDescription.value = '';
    controller.avatar.value = null;
    controller.avatarUrl.value = '';
    
    // Reset submit state
    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: languageController.getTranslation('add_merchant'),
        managerId: userProfileController.userId.value,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 20), // Add bottom padding to prevent footer overlap
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //CustomBtcContainer(),
              Container(
                //height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xffFFFFFF),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageController.getTranslation('new_sub_account'),
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xff18CE0F),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 2),
                    Text(
                      languageController.getTranslation('sub_account_logo'),
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 2, bottom: 2),
                    Divider(
                      color: Color(0xffDDDDDD),
                    ),
                    Center(
                      child: Container(
                        height: MediaQuery.of(context).size.width * 0.56, // Fixed height equal to width for perfect circle
                        width: MediaQuery.of(context).size.width * 0.56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200], // Background color for the circle
                        ),
                        child: ClipOval(
                          child: Obx(() {
                            if (controller.avatar.value != null) {
                              return Image.file(
                                controller.avatar.value!,
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width * 0.56,
                                height: MediaQuery.of(context).size.width * 0.56,
                              );
                            } else if (controller.avatarUrl.value.isNotEmpty) {
                              return Image.network(
                                controller.avatarUrl.value,
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width * 0.56,
                                height: MediaQuery.of(context).size.width * 0.56,
                              );
                            } else {
                              return Image.asset(
                                "assets/images/profile.png",
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width * 0.56,
                                height: MediaQuery.of(context).size.width * 0.56,
                              );
                            }
                          }),
                        ),
                      ).paddingOnly(top: 2),
                    ),
                    Divider(
                      color: Color(0xffDDDDDD),
                    ).paddingOnly(top: 4),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            controller.pickImage();
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Color(0xffDDDDDD),
                            ),
                            child: Center(
                              child: Text(
                                languageController.getTranslation('choose_file'),
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                            onPressed: () {},
                            child: Text(
                              languageController.getTranslation('no_file_chosen'),
                              style: TextStyle(color: Color(0xff666565)),
                            ))
                      ],
                    ).paddingOnly(bottom: 4)
                  ],
                ).paddingSymmetric(horizontal: 15),
              ).paddingOnly(top: 6),
              Container(
                //height: 469,
                //height: MediaQuery.of(context).size.height * 0.95,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xffFFFFFF),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageController.getTranslation('sub_account_name'),
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 6, bottom: 6),
                    TextFormField(
                      controller: merchantNameController,
                      onChanged: (value) {
                        controller.merchantName.value = value;
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 5, top: 12, bottom: 12),
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
                      ),
                    ),
                    Text(
                      languageController.getTranslation('sub_account_description'),
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 6, bottom: 6),
                    TextFormField(
                      controller: merchantDescriptionController,
                      onChanged: (value) {
                        controller.merchantDescription.value = value;
                      },
                      //onChanged: (value) => controller.merchantDescription(value),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: languageController.getTranslation('write_description'),
                        contentPadding: EdgeInsets.only(top: 8, left: 5, bottom: 8),
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
                      ),
                    ),
                    Container(
                      width: Get.width,
                      height: 45.0,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : () async {
                          // Prevent multiple submissions
                          if (_isSubmitting) return;
                          
                          // Validate form fields
                          if (merchantNameController.text.trim().isEmpty) {
                            Get.snackbar(
                              languageController.getTranslation('error'),
                              languageController.getTranslation('please_enter_sub_account_name'),
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }
                          
                                                     if (controller.avatar.value == null && controller.avatarUrl.value.isEmpty) {
                             Get.snackbar(
                               languageController.getTranslation('error'),
                               languageController.getTranslation('sub_account_logo_is_requird'),
                               backgroundColor: Colors.red,
                               colorText: Colors.white,
                             );
                             return;
                           }
                           
                           if (merchantDescriptionController.text.trim().isEmpty) {
                             Get.snackbar(
                               languageController.getTranslation('error'),
                               languageController.getTranslation('sub_account_description_required'),
                               backgroundColor: Colors.red,
                               colorText: Colors.white,
                             );
                             return;
                           }
                          
                          setState(() {
                            _isSubmitting = true;
                          });
                          
                          print('Save button pressed');
                          print('Form values:');
                          print('Name: ${merchantNameController.text}');
                          print('Description: ${merchantDescriptionController.text}');
                          print('Avatar: ${controller.avatar.value?.path}');
                          
                          // Update controller values from form controllers
                          controller.merchantName.value = merchantNameController.text;
                          controller.merchantDescription.value = merchantDescriptionController.text;
                          
                                                     try {
                             // Adding a delay of 3 seconds before the API call
                             await Future.delayed(Duration(seconds: 3));
                             print('Delay completed, calling createMerchant...');
                             
                             // Call the API - the controller will handle the response and show appropriate messages
                             await controller.createMerchant(context);
                             print('createMerchant call completed');
                             
                             // Note: The controller now handles success/error messages and navigation
                             // We don't reset the form here anymore - let the controller handle it
                             // The form will only be reset on successful creation (success: true)
                           } catch (e) {
                             print('Error creating merchant: $e');
                             Get.snackbar(
                               languageController.getTranslation('error'),
                               languageController.getTranslation('an_error_occurred'),
                               backgroundColor: Colors.red,
                               colorText: Colors.white,
                             );
                           } finally {
                             // Reset loading state
                             setState(() {
                               _isSubmitting = false;
                             });
                           }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DamaspayTheme.of(context).primary,
                          foregroundColor: Colors.white,
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: _isSubmitting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  languageController.getTranslation('processing') + "...",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              languageController.getTranslation('save'),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                      ),
                    ).paddingOnly(top: 15, bottom: 12),
                  ],
                ).paddingSymmetric(horizontal: 15),
              ).paddingOnly(top: 12, bottom: 12),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomContainerPostLogin(),
    );
  }
}



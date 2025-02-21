import 'package:country_picker/country_picker.dart';
import 'package:dacotech/view/Kyc_screens/screen_kyc2.dart';
import 'package:dacotech/view/screens/user_profile/user_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_appbar/custom_appbar.dart';
import '../../widgets/custom_button/custom_button.dart';
import 'kyc_controller.dart';

class ScreenKyc1 extends StatefulWidget {
  @override
  State<ScreenKyc1> createState() => _ScreenKyc1State();
}

class _ScreenKyc1State extends State<ScreenKyc1> {
  TextEditingController countryCon = TextEditingController();

  TextEditingController dateController = TextEditingController();

  final UserProfileController controller = Get.find<UserProfileController>();
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
    //kycController.fetchKycStatus();
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: const Color(0xff0766AD),
        title: AppBarTitle(),
        leading: controller.kyc.value == '3'
            ? CustomPopupMenu(managerId: controller.userId.value,)
            : IconButton(
                icon: Icon(Icons.menu,
                color: Colors.white,), // Menu icon as fallback
                onPressed: () {
                  // Show SnackBar with KYC status message when menu button is clicked
                  final kycMessage = getKycStatusMessage(controller.kyc.value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(kycMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              ),
        actions: [
          controller.kyc.value == '3'
              ?AppBarProfileButton()
              : IconButton(
            icon: Icon(Icons.account_circle,
              color: Color(0xffFEAF39),
              size: 30,),
            onPressed: () {
              // Show SnackBar with KYC status message when menu button is clicked
              final kycMessage = getKycStatusMessage(controller.kyc.value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(kycMessage),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),

        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchUserDetails();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                //height: MediaQuery.of(context).size.height * .75,
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
                          color: Colors.black87),
                    ).paddingOnly(bottom: 20, top: 10),
                    Obx(() {
                      print("KYC Status: ${controller.kyc.value}");

                      final Map<String, dynamic> statusStyles = {
                        '0': {
                          'message': 'KYC Status: Pending',
                          'textColor': Colors.blue,
                          'containerColor': Colors.blue.withOpacity(0.1),
                        },
                        '1': {
                          'message': 'KYC Status: Pending for Approval',
                          'textColor': Colors.orange,
                          'containerColor': Colors.orange.withOpacity(0.1),
                        },
                        '2': {
                          'message': 'KYC Status: Rejected. Submit Again',
                          'textColor': Colors.red,
                          'containerColor': Colors.red.withOpacity(0.1),
                        },
                        '3': {
                          'message': 'KYC Status: Approved',
                          'textColor': Colors.green,
                          'containerColor': Colors.green.withOpacity(0.1),
                        },
                      };

                      // Determine styles based on KYC status, defaulting to "Unknown" if not matched
                      final statusStyle = statusStyles[controller.kyc.value] ?? statusStyles['Unknown']!;

                      return Container(
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
                      );
                    }),

                    Text(
                      "First Name:",
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
                      "Last Name:",
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
                      "Birth Day:",
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
                            dateController.text = formattedDate;
                          }
                        },
                        icon:
                            Icon(Icons.calendar_today), // Use any icon you prefer
                      ),
                    ),
                    Text(
                      "Address line 1:",
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
                      "City:",
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
                      "Zip Code:",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10, bottom: 10),
                    _buildTextField(
                      controller: controller.zipController,
                      hintText: '',
                    ),
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
                      "Whatsapp Number:",
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
    switch (kycStatus) {
      case '0':
        return 'Your KYC status is Pending';
      case '1':
        return 'Your KYC status is Pending for Approval';
      case '2':
        return 'Your KYC status is Rejected. Submit Again';
      case '3':
        return 'Your KYC status is Approved';
      default:
        return 'Your KYC status is Unknown';
    }
  }
}

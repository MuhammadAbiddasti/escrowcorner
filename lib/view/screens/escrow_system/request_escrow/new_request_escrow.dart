import 'dart:io';

import 'package:escrowcorner/view/screens/escrow_system/request_escrow/request_escrow_controller.dart';
import 'package:escrowcorner/view/screens/escrow_system/screen_escrow_details.dart';
import 'package:escrowcorner/view/screens/escrow_system/escrow_controller.dart';
import 'package:escrowcorner/view/screens/escrow_system/models/escrow_models.dart';
import 'package:escrowcorner/view/controller/language_controller.dart';
import 'package:escrowcorner/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../widgets/custom_button/damaspay_button.dart';
import '../../../../widgets/common_header/common_header.dart';
import '../../../theme/damaspay_theme/Damaspay_theme.dart';
import '../../user_profile/user_profile_controller.dart';
import '../escrow_controller.dart';
import '../../settings/setting_controller.dart';

class ScreenNewRequestEscrow extends StatefulWidget {
  @override
  State<ScreenNewRequestEscrow> createState() => _ScreenNewRequestEscrowState();
}

class _ScreenNewRequestEscrowState extends State<ScreenNewRequestEscrow> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  bool acceptTerms = false;
  final UserEscrowsController escrowController = Get.put(UserEscrowsController());
  final RequestEscrowController requestEscrowController = Get.put(RequestEscrowController());
  final UserProfileController userProfileController =Get.find<UserProfileController>();
  final SettingController settingController = Get.find<SettingController>();
  String? selectedCategory;
  String? selectedCurrency;
  final ImagePicker _picker = ImagePicker();
  List<File> selectedFiles = [];

  Future<void> _pickImageFile() async {
    // Use ImagePicker to pick multiple images
    final List<XFile> files = await _picker.pickMultiImage();

    if (files.isNotEmpty) {
      setState(() {
        selectedFiles.addAll(files.map((file) => File(file.path))); // Convert XFiles to Files
      });
    }
  }

  Future<void> _pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          selectedFiles.addAll(
            result.files
                .where((file) => file.path != null)
                .map((file) => File(file.path!))
          );
        });
        print("Picked files: ${selectedFiles.length} files");
      } else {
        print("No files selected.");
      }
    } catch (e) {
      print("Error picking files: $e");
    }
  }


  // Function to show the options
  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.image, color: Colors.blue),
                title: Text("Select Image"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFile();
                },
              ),
              ListTile(
                leading: Icon(Icons.file_copy, color: Colors.green),
                title: Text("Select File"),
                onTap: () {
                  Navigator.pop(context);
                  _pickPdfFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Fetch escrows only once when the screen is initialized
    escrowController.fetchCategories();
    escrowController.fetchCurrencies();
    escrowController.fetchPaymentMethods();
  }
  void onInit() {
    escrowController.fetchCategories();
    escrowController.fetchCurrencies();
  }

  @override
  Widget build(BuildContext context) {

    return  Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: 'New Request Escrow',
        managerId: userProfileController.userId.value,
      ),
      body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0xffFFFFFF),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () {
                          final settingController = Get.find<SettingController>();
                          settingController.openTermsAndConditions();
                        },
                        child: Text(
                          "What is Escrow and How does it work ?",
                          style: TextStyle(decoration: TextDecoration.underline,decorationColor: Colors.blue,
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "Title",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xff484848),
                            fontFamily: 'Nunito'),
                      ).paddingOnly(bottom: 10),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 4, left: 5),
                          hintText: "Enter title",
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
                      Text(
                        "Recipient Email",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xff484848),
                            fontFamily: 'Nunito'),
                      ).paddingOnly(top: 10,bottom: 10),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 4, left: 5),
                          hintText: "Ex: example@example.com",
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
                      Text(
                        "Category of the escrow",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xff484848),
                            fontFamily: 'Nunito'),
                      ).paddingOnly(top: 10,bottom: 10),
                      Obx(() {
                        // Listen to language changes to refresh the dropdown
                        final currentLocale = languageController.getCurrentLanguageLocale();
                        
                        return DropdownButtonFormField<EscrowCategory>(
                          items: escrowController.categories.map((EscrowCategory category) {
                            return DropdownMenuItem<EscrowCategory>(
                              value: category,
                              child: Container(
                                width: double.infinity,
                                child: Text(
                                  category.getLocalizedTitle(currentLocale),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            escrowController.selectedCategory.value = value;
                            print("Selected Category: ${value?.getLocalizedTitle(currentLocale)}");
                          },
                          value: escrowController.selectedCategory.value,
                          icon: escrowController.isLoading.value
                              ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : Icon(Icons.arrow_drop_down, color: Color(0xff666565)),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(top: 4, left: 5),
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
                          isExpanded: true, // Make dropdown take full width
                        );
                      }),
                      Text(
                        "Currency",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xff484848),
                            fontFamily: 'Nunito'),
                      ).paddingOnly(top: 10,bottom: 10),
                      Obx(() {
                        return DropdownButtonFormField<int>(
                          value: escrowController.selectedCurrencyId.value,
                          items: escrowController.currencies.map((EscrowCurrency currency) {
                            return DropdownMenuItem<int>(
                              value: currency.id,
                              child: Text(currency.name ?? "Unknown"), // Handle null gracefully
                            );
                          }).toList(),
                          onChanged: (value) {
                            escrowController.selectedCurrencyId.value = value;
                            print("Selected Currency ID: $value");
                          },
                          icon: escrowController.isLoading.value
                              ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : Icon(Icons.arrow_drop_down, color: Color(0xff666565)),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(top: 4, left: 5),
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
                        );
                      }),
                      Text(
                        "Payment Method",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xff484848),
                            fontFamily: 'Nunito'),
                      ).paddingOnly(top: 10,bottom: 10),
                      Obx(() {
                        print('=== PAYMENT METHODS DEBUG ===');
                        print('Payment methods count: ${escrowController.paymentMethods.length}');
                        print('Is loading: ${escrowController.isLoading.value}');
                        print('Selected payment method ID: ${escrowController.selectedPaymentMethodId.value}');
                        
                        if (escrowController.paymentMethods.isNotEmpty) {
                          print('Payment methods details:');
                          for (var method in escrowController.paymentMethods) {
                            print('  ID: ${method.id}, Name: "${method.name}", PaymentMethodName: "${method.paymentMethodName}"');
                          }
                        }
                        
                        if (escrowController.paymentMethods.isEmpty) {
                          return Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Color(0xff666565)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              escrowController.isLoading.value 
                                  ? 'Loading payment methods...' 
                                  : 'No payment methods available',
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }
                        
                        return DropdownButtonFormField<int>(
                          value: escrowController.selectedPaymentMethodId.value,
                          items: escrowController.paymentMethods.map((EscrowPaymentMethod paymentMethod) {
                            return DropdownMenuItem<int>(
                              value: paymentMethod.id,
                              child: Text(paymentMethod.paymentMethodName ?? paymentMethod.name ?? "Unknown"),
                            );
                          }).toList(),
                          onChanged: (value) {
                            escrowController.selectedPaymentMethodId.value = value;
                            print("Selected Payment Method ID: $value");
                          },
                          icon: escrowController.isLoading.value
                              ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : Icon(Icons.arrow_drop_down, color: Color(0xff666565)),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(top: 4, left: 5),
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
                        );
                      }),
                      Text(
                        "Amount",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xff484848),
                            fontFamily: 'Nunito'),
                      ).paddingOnly(top: 10,bottom: 10),
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 4, left: 5),
                          hintText: "5.00",
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
                      Text(
                        "Product Name",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xff484848),
                            fontFamily: 'Nunito'),
                      ).paddingOnly(top: 10,bottom: 10),
                      TextField(
                        controller: productNameController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 4, left: 5),
                          hintText: "Enter product name",
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Note for Recipient | Your Deal Agreement",
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Color(0xff484848),
                                fontFamily: 'Nunito'),
                          ).paddingOnly(top: 10,bottom: 10),
                          TextField(
                            controller: noteController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(8),
                              hintText: "Write a note...",
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
                        ],
                      ),
                      Text(
                        "Product photos or information",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xff484848),
                            fontFamily: 'Nunito'),
                      ).paddingOnly(top: 10,bottom: 10),
                      // Display selected files
                      if (selectedFiles.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Selected Files (${selectedFiles.length}):",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Color(0xff484848),
                                ),
                              ),
                              SizedBox(height: 8),
                              ...selectedFiles.asMap().entries.map((entry) {
                                int index = entry.key;
                                File file = entry.value;
                                return Container(
                                  margin: EdgeInsets.only(bottom: 5),
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          file.path.split('/').last,
                                          style: TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.close, size: 16, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            selectedFiles.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                      
                      InkWell(
                        onTap: () => _showPickerOptions(context),
                        child: Container(
                          height: 40,
                          width: 150,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.black)
                          ),
                          child: Center(child:
                          Text(selectedFiles.isNotEmpty
                              ? 'Add More Files'
                              : "Choose Files",)),
                        ),
                      ),
                      SizedBox(height: 20),
                      Divider(),
                      Row(
                        children: [
                          Checkbox(
                            value: acceptTerms,
                            onChanged: (value) {
                              setState(() {
                                acceptTerms = value ?? false;
                              });
                            },
                          ),
                          Text("Accept ", style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xff484848),
                              fontFamily: 'Nunito'),),
                          GestureDetector(
                            onTap: () {
                              settingController.openTermsAndConditions();
                            },
                            child: Text(
                              "Terms & Conditions",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.blue,
                                  fontFamily: 'Nunito',
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      FFButtonWidget(
                        onPressed: () async {
                          if (titleController.text.isEmpty) {
                            Get.snackbar(
                              "Error",
                              "Title is required.",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }
                          if (emailController.text.isEmpty || !GetUtils.isEmail(emailController.text)) {
                            Get.snackbar(
                              "Error",
                              "Please enter a valid email address.",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }
                          if (escrowController.selectedCategory.value?.id == null) {
                            Get.snackbar(
                              "Error",
                              "Please select a valid category.",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }
                          if (escrowController.selectedCurrencyId.value == null) {
                            Get.snackbar(
                              "Error",
                              "Please select a valid currency.",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }

                          if (amountController.text.isEmpty ||
                              double.tryParse(amountController.text) == null ||
                              double.parse(amountController.text) <= 0) {
                            Get.snackbar(
                              "Error",
                              "Please enter a valid amount greater than zero.",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }
                          if (noteController.text.isEmpty) {
                            Get.snackbar(
                              "Error",
                              "Note for recipient is required.",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }
                          if (!acceptTerms) {
                            Get.snackbar(
                              "Error",
                              "You must accept the terms and conditions.",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }
                          // Adding a delay of 3 seconds before the API call
                          await Future.delayed(Duration(seconds: 3));
                          // If all validations pass, proceed to store the escrow.
                          await requestEscrowController.storeRequestEscrow(
                            title: titleController.text,
                            amount: double.parse(amountController.text),
                            email: emailController.text,
                            escrowCategoryId: escrowController.selectedCategory.value!.id,
                            currency: '${escrowController.selectedCurrencyId}',        // Pass the selected currency ID directly
                            description: noteController.text.isNotEmpty ? noteController.text : "No description provided",
                            escrowTermConditions: acceptTerms,
                            attachments: selectedFiles.isNotEmpty ? selectedFiles : null,
                            productName: productNameController.text.isNotEmpty ? productNameController.text : null,
                            paymentMethodId: escrowController.selectedPaymentMethodId.value,
                          );
                          requestEscrowController.fetchRequestEscrows();
                        },
                        text: 'Request Escrow',
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
                      ).paddingOnly(bottom: 20),
                    ],
                  ).paddingSymmetric(horizontal: 10),
                ).paddingSymmetric(horizontal: 10,vertical: 20),
                CustomBottomContainerPostLogin()
              ],
            ),
          )
      ),
    );
  }
}

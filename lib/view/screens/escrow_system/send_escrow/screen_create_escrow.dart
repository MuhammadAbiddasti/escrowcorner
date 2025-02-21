import 'dart:io';

import 'package:dacotech/view/screens/escrow_system/screen_escrow_details.dart';
import 'package:dacotech/view/screens/escrow_system/send_escrow/send_escrow_controller.dart';
import 'package:dacotech/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:dacotech/widgets/custom_textField/custom_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../../widgets/custom_button/damaspay_button.dart';
import '../../../theme/damaspay_theme/Damaspay_theme.dart';
import '../../user_profile/user_profile_controller.dart';
import '../escrow_controller.dart';

class ScreenCreateEscrow extends StatefulWidget {
  @override
  State<ScreenCreateEscrow> createState() => _ScreenCreateEscrowState();
}

class _ScreenCreateEscrowState extends State<ScreenCreateEscrow> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  bool acceptTerms = false;
    final UserEscrowsController escrowController = Get.put(UserEscrowsController());
    final SendEscrowsController controller = Get.put(SendEscrowsController());
    final UserProfileController userProfileController =Get.find<UserProfileController>();

  String? selectedCategory;
    String? selectedCurrency;
    final ImagePicker _picker = ImagePicker();
  File? selectedFile;
    //File? selectedPdfFile;

  Future<void> _pickImageFile() async {
    // Use ImagePicker to pick an image
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        selectedFile = File(file.path); // Convert XFile to File
      });
    }
  }

  Future<void> _pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'doc'],
      );

      if (result != null && result.files.isNotEmpty && result.files.single.path != null) {
        setState(() {
          selectedFile = File(result.files.single.path!);
        });
        print("Picked file: ${selectedFile?.path}");
      } else {
        print("No file selected.");
      }
    } catch (e) {
      print("Error picking file: $e");
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
  }
  void onInit() {
    escrowController.fetchCategories();
    escrowController.fetchCurrencies();
  }

    @override
  Widget build(BuildContext context) {

    return  Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar:  AppBar(
        backgroundColor: Color(0xff0766AD),
        title: AppBarTitle(),
        leading: CustomPopupMenu(managerId: userProfileController.userId.value,),
        actions: [
          PopupMenuButtonAction(),
          AppBarProfileButton(),

        ],
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
                        Get.to(ScreenEscrowDetails());
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
                      "User Email",
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
                      return DropdownButtonFormField<EscrowCategory>(
                        items: escrowController.categories.map((EscrowCategory category) {
                          return DropdownMenuItem<EscrowCategory>(
                            value: category,
                            child: Text(category.title),
                          );
                        }).toList(),
                        onChanged: (value) {
                          escrowController.selectedCategory.value = value;
                          print("Selected Category: ${value?.title}");
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

                    // Amount Field
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
                    // Note Field
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
                      "Attachment (Optional)",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10,bottom: 10),
                    InkWell(
                      onTap: () => _showPickerOptions(context),
                      child: Container(
                        height: 40,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black)
                        ),
                        child: Center(
                            child: Text(selectedFile != null
                            ? 'File Selected'
                            : "Choose File",)),
                      ),
                    ),
                    SizedBox(height: 20),
                    Divider(),
                    // Terms and Conditions
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
                        Text(
                          "Accept ",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xff484848),
                            fontFamily: 'Nunito',
                          ),
                        ),
                        Text(
                          "Terms & Conditions",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Colors.blue,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    FFButtonWidget(
                      onPressed: () async {
                        print("${escrowController.selectedCategory.value?.id}");
                        print("${escrowController.selectedCurrencyId.value}");
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
                        print("${selectedCurrency}");
                        // Adding a delay of 3 seconds before the API call
                        await Future.delayed(Duration(seconds: 3));
                        // If all validations pass, proceed to store the escrow.
                        await escrowController.storeEscrow(
                          title: titleController.text,
                          amount: double.parse(amountController.text),
                          email: emailController.text,
                          escrowCategoryId: escrowController.selectedCategory.value!.id,
                          currency: '${escrowController.selectedCurrencyId}', // Pass the selected currency ID directly
                          description: noteController.text.isNotEmpty ? noteController.text : "No description provided",
                          escrowTermConditions: acceptTerms,
                          attachment: selectedFile != null ? File(selectedFile!.path) : null,
                        );
                        print("attachment: $selectedFile");
                        controller.fetchSendEscrows();
                      },
                      text: 'Start Escrow',
                      options: FFButtonOptions(
                        width: Get.width,
                        height: 45.0,
                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        color: DamaspayTheme.of(context).primary,
                        textStyle: DamaspayTheme.of(context).titleSmall.override(
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
              CustomBottomContainer()
            ],
          ),
        )
      ),
    );
  }
}

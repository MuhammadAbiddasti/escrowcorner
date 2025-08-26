import 'dart:io';

import 'package:escrowcorner/view/screens/escrow_system/screen_escrow_details.dart';
import 'package:escrowcorner/view/screens/escrow_system/request_escrow/request_escrow_controller.dart';
import 'package:escrowcorner/view/screens/escrow_system/request_escrow/request_escrow.dart';
import 'package:escrowcorner/view/screens/escrow_system/models/escrow_models.dart';
import 'package:escrowcorner/view/screens/escrow_system/escrow_controller.dart';
import 'package:escrowcorner/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:escrowcorner/widgets/custom_textField/custom_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../widgets/custom_button/damaspay_button.dart';
import '../../../../widgets/common_header/common_header.dart';
import '../../../theme/damaspay_theme/Damaspay_theme.dart';
import '../../user_profile/user_profile_controller.dart';
import '../escrow_controller.dart';
import '../../../../view/controller/language_controller.dart';
import '../../../../widgets/custom_api_url/constant_url.dart';
import 'package:flutter/services.dart'; // Added for inputFormatters

class ScreenCreateRequestEscrow extends StatefulWidget {
  @override
  State<ScreenCreateRequestEscrow> createState() => _ScreenCreateRequestEscrowState();
}

class _ScreenCreateRequestEscrowState extends State<ScreenCreateRequestEscrow> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  bool acceptTerms = false;
  final UserEscrowsController escrowController = Get.put(UserEscrowsController());
  final RequestEscrowController controller = Get.put(RequestEscrowController());
  final UserProfileController userProfileController = Get.find<UserProfileController>();
  final LanguageController languageController = Get.find<LanguageController>();

  String? selectedCategory;
  String? selectedCurrency;
  final ImagePicker _picker = ImagePicker();
  List<File> selectedFiles = [];





  Future<void> _pickImageFile() async {
    // Use ImagePicker to pick multiple images
    final List<XFile> files = await _picker.pickMultiImage();

    if (files.isNotEmpty) {
      // Check if adding these files would exceed the 5 file limit
      if (selectedFiles.length + files.length > 5) {
        Get.snackbar(
          languageController.getTranslation('error'),
          languageController.getTranslation('maximum_five_files_are_allowed'),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
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
        allowedExtensions: ['pdf', 'docx', 'jpg', 'jpeg', 'png', 'PNG'],
      );

      if (result != null && result.files.isNotEmpty) {
        // Check if adding these files would exceed the 5 file limit
        if (selectedFiles.length + result.files.length > 5) {
          Get.snackbar(
            languageController.getTranslation('error'),
            languageController.getTranslation('maximum_five_files_are_allowed'),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        
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
                title: Text(languageController.getTranslation('select_image')),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFile();
                },
              ),
              ListTile(
                leading: Icon(Icons.file_copy, color: Colors.green),
                title: Text(languageController.getTranslation('select_file')),
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
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
             appBar: CommonHeader(
         title: languageController.getTranslation('request_escrow'),
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
                         Get.to(ScreenEscrowDetails());
                       },
                       child: Text(
                         languageController.getTranslation('what_is_escrow_and_how_does_it_work'),
                         style: TextStyle(decoration: TextDecoration.underline,decorationColor: Colors.blue,
                             color: Colors.blue, fontWeight: FontWeight.bold),
                       ),
                     ),
                     Text(
                       languageController.getTranslation('title'),
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
                         hintText: languageController.getTranslation('enter_title'),
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
                       languageController.getTranslation('recipient_email'),
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
                         hintText: languageController.getTranslation('enter_recipient_email'),
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
                       languageController.getTranslation('category_of_the_escrow'),
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
                       languageController.getTranslation('currency'),
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
                       languageController.getTranslation('payment_method'),
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
                                 ? languageController.getTranslation('loading_payment_methods')
                                 : languageController.getTranslation('no_payment_methods_available'),
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
                       languageController.getTranslation('amount'),
                       style: TextStyle(
                           fontWeight: FontWeight.w400,
                           fontSize: 14,
                           color: Color(0xff484848),
                           fontFamily: 'Nunito'),
                     ).paddingOnly(top: 10,bottom: 10),
                     TextField(
                       controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      onChanged: (value) {
                        // Amount field changed - no fee calculation needed
                      },
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
                       languageController.getTranslation('product_name'),
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
                                                 hintText: languageController.getTranslation('enter_product_name'),
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
                           "${languageController.getTranslation('note_for_the_recipient')} | ${languageController.getTranslation('your_agreement')}",
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
                             hintText: languageController.getTranslation('write_a_note'),
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
                       languageController.getTranslation('product_photos_or_information'),
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
                               languageController.getTranslation('selected_files_count').replaceAll('{count}', '${selectedFiles.length}'),
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
                       onTap: selectedFiles.length >= 5 ? null : () => _showPickerOptions(context),
                       child: Container(
                         height: 40,
                         width: 150,
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(5),
                           border: Border.all(
                             color: selectedFiles.length >= 5 ? Colors.grey : Colors.black
                           ),
                           color: selectedFiles.length >= 5 ? Colors.grey.shade300 : Colors.white,
                         ),
                         child: Center(
                           child: Text(
                             selectedFiles.isNotEmpty
                               ? languageController.getTranslation('add_more_files')
                               : languageController.getTranslation('choose_files'),
                             style: TextStyle(
                               color: selectedFiles.length >= 5 ? Colors.grey : Colors.black,
                               fontSize: 12,
                             ),
                           ),
                         ),
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
                         Text(languageController.getTranslation('accept') + " ", style: TextStyle(
                             fontWeight: FontWeight.w400,
                             fontSize: 14,
                             color: Color(0xff484848),
                             fontFamily: 'Nunito'),),
                         Text(
                           languageController.getTranslation('terms_and_conditions'),
                           style: TextStyle(
                               fontWeight: FontWeight.w400,
                               fontSize: 14,
                               color: Colors.blue,
                               fontFamily: 'Nunito'),
                         ),
                      ],
                    ),
                    SizedBox(height: 20),
                                           FFButtonWidget(
                        onPressed: () async {
                         if (titleController.text.isEmpty) {
                           Get.snackbar(
                             languageController.getTranslation('error'),
                             languageController.getTranslation('title_is_required'),
                             backgroundColor: Colors.red,
                             colorText: Colors.white,
                             snackPosition: SnackPosition.BOTTOM,
                           );
                           return;
                         }
                         if (emailController.text.isEmpty || !GetUtils.isEmail(emailController.text)) {
                           Get.snackbar(
                             languageController.getTranslation('error'),
                             languageController.getTranslation('please_enter_a_valid_email_address'),
                             backgroundColor: Colors.red,
                             colorText: Colors.white,
                             snackPosition: SnackPosition.BOTTOM,
                           );
                           return;
                         }
                         if (escrowController.selectedCategory.value?.id == null) {
                           Get.snackbar(
                             languageController.getTranslation('error'),
                             languageController.getTranslation('please_select_a_valid_category'),
                             backgroundColor: Colors.red,
                             colorText: Colors.white,
                             snackPosition: SnackPosition.BOTTOM,
                           );
                           return;
                         }
                         if (escrowController.selectedCurrencyId.value == null) {
                           Get.snackbar(
                             languageController.getTranslation('error'),
                             languageController.getTranslation('please_select_a_valid_currency'),
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
                             languageController.getTranslation('error'),
                             languageController.getTranslation('please_enter_a_valid_amount_greater_than_zero'),
                             backgroundColor: Colors.red,
                             colorText: Colors.white,
                             snackPosition: SnackPosition.BOTTOM,
                           );
                           return;
                         }
                         if (noteController.text.isEmpty) {
                           Get.snackbar(
                             languageController.getTranslation('error'),
                             languageController.getTranslation('note_for_recipient_is_required'),
                             backgroundColor: Colors.red,
                             colorText: Colors.white,
                             snackPosition: SnackPosition.BOTTOM,
                           );
                           return;
                         }
                         if (!acceptTerms) {
                           Get.snackbar(
                             languageController.getTranslation('error'),
                             languageController.getTranslation('you_must_accept_the_terms_and_conditions'),
                             backgroundColor: Colors.red,
                             colorText: Colors.white,
                             snackPosition: SnackPosition.BOTTOM,
                           );
                           return;
                         }
                                                   if (selectedFiles.length > 5) {
                            Get.snackbar(
                              languageController.getTranslation('error'),
                              languageController.getTranslation('maximum_five_files_are_allowed'),
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }
                          
                          if (selectedFiles.isEmpty) {
                            Get.snackbar(
                              languageController.getTranslation('error'),
                              languageController.getTranslation('please_upload_product_photo_or_information'),
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }
                         
                         // Show loading indicator
                         Get.dialog(
                           Center(
                             child: CircularProgressIndicator(),
                           ),
                           barrierDismissible: false,
                         );
                         
                         try {
                           // If all validations pass, proceed to store the escrow.
                           final result = await controller.storeRequestEscrow(
                             title: titleController.text,
                             amount: double.parse(amountController.text),
                             email: emailController.text,
                             escrowCategoryId: escrowController.selectedCategory.value!.id,
                             currency: '${escrowController.selectedCurrencyId.value}',
                             description: noteController.text.isNotEmpty ? noteController.text : languageController.getTranslation('no_description_provided'),
                             escrowTermConditions: acceptTerms,
                             attachments: selectedFiles.isNotEmpty ? selectedFiles : null,
                             productName: productNameController.text.isNotEmpty ? productNameController.text : null,
                             paymentMethodId: escrowController.selectedPaymentMethodId.value,
                           );
                           
                           // Close loading dialog
                           Get.back();
                           
                                                       // Check the result and show appropriate message
                            if (result != null) {
                              // Check if the API response indicates success or failure
                              if (result['success'] == true) {
                                // Show success message with API response
                                Get.snackbar(
                                  languageController.getTranslation('success'),
                                  result['message'] ?? languageController.getTranslation('escrow_request_created_successfully'),
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: Duration(seconds: 2),
                                );
                                
                                // Navigate back to request escrow list after short delay
                                await Future.delayed(Duration(seconds: 2));
                                Get.off(() => GetRequestEscrow());
                              } else {
                                // Show error message from API response
                                Get.snackbar(
                                  languageController.getTranslation('error'),
                                  result['message'] ?? languageController.getTranslation('failed_to_create_escrow_request'),
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: Duration(seconds: 4),
                                );
                                // Stay on current screen for error cases
                              }
                            } else {
                              // Show generic error message
                              Get.snackbar(
                                languageController.getTranslation('error'),
                                languageController.getTranslation('failed_to_create_escrow_request'),
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                         } catch (e) {
                           // Close loading dialog
                           Get.back();
                           
                           // Show error message with exception details
                           Get.snackbar(
                             languageController.getTranslation('error'),
                             '${languageController.getTranslation('an_error_occurred')}: $e',
                             backgroundColor: Colors.red,
                             colorText: Colors.white,
                             snackPosition: SnackPosition.BOTTOM,
                           );
                         }
                       },
                       text: languageController.getTranslation('request_escrow'),
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

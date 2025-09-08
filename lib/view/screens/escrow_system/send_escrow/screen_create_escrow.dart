import 'dart:io';
import 'dart:convert'; // Added for json
import 'package:http/http.dart' as http; // Added for http

import 'package:escrowcorner/view/screens/escrow_system/screen_escrow_details.dart';
import 'package:escrowcorner/view/screens/escrow_system/send_escrow/send_escrow_controller.dart';
import 'package:escrowcorner/view/screens/escrow_system/send_escrow/screen_escrow_list.dart';
import 'package:escrowcorner/view/screens/escrow_system/models/escrow_models.dart';
import 'package:escrowcorner/view/screens/escrow_system/escrow_controller.dart';
import 'package:escrowcorner/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:escrowcorner/widgets/custom_textField/custom_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../../widgets/custom_button/damaspay_button.dart';
import '../../../../widgets/common_header/common_header.dart';
import '../../../theme/damaspay_theme/Damaspay_theme.dart';
import '../../user_profile/user_profile_controller.dart';
import '../escrow_controller.dart';
import '../../../../view/controller/language_controller.dart';
import '../../../../widgets/custom_api_url/constant_url.dart';
import '../../../../widgets/custom_token/constant_token.dart'; // Added for getToken
import 'package:flutter/services.dart'; // Added for inputFormatters
import '../../settings/setting_controller.dart';

class ScreenCreateEscrow extends StatefulWidget {
  @override
  State<ScreenCreateEscrow> createState() => _ScreenCreateEscrowState();
}

class _ScreenCreateEscrowState extends State<ScreenCreateEscrow> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  // Controllers for disabled fields
  final TextEditingController escrowFeeController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  bool acceptTerms = false;
    final UserEscrowsController escrowController = Get.put(UserEscrowsController());
    final SendEscrowsController controller = Get.put(SendEscrowsController());
    final UserProfileController userProfileController =Get.find<UserProfileController>();
    final LanguageController languageController = Get.find<LanguageController>();
    final SettingController settingController = Get.find<SettingController>();

  String? selectedCategory;
    String? selectedCurrency;
    final ImagePicker _picker = ImagePicker();
  List<File> selectedFiles = [];
    //File? selectedPdfFile;

  // Escrow fee variables
  double escrowFixedFee = 0.0;
  double escrowPercentFee = 0.0; // Remove default value, let API set it
  bool escrowFeesLoaded = false; // Track if fees are loaded

  // Fetch escrow fees from API
  Future<void> _fetchEscrowFees() async {
    try {
      print('Calling API: $baseUrl/api/get_escrow_fee');
      
      // Get the auth token using the getToken function
      final String? authToken = await getToken();
      
      if (authToken == null) {
        print('Error: No auth token available');
        return;
      }
      
      print('Token retrieved: ${authToken.substring(0, 20)}...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/get_escrow_fee'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );
      
      print('API Response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Get the values from API response
        escrowFixedFee = double.parse(data['escrows_fixed_fee']);
        escrowPercentFee = double.parse(data['escrows_percent_fee']);
        escrowFeesLoaded = true;
        
        print('Values set: Fixed=$escrowFixedFee, Percent=$escrowPercentFee');
        
        // Update UI
        setState(() {});
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _pickImageFile() async {
    // Check if already have 5 files
    if (selectedFiles.length >= 5) {
      Get.snackbar(
        languageController.getTranslation('error'),
        languageController.getTranslation('maximum_5_files_allowed'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    // Calculate how many more files can be added
    final int remainingSlots = 5 - selectedFiles.length;
    
    // Use ImagePicker to pick multiple images
    final List<XFile> files = await _picker.pickMultiImage();
    
    if (files.isNotEmpty) {
      // Limit the number of files to remaining slots
      final List<XFile> limitedFiles = files.take(remainingSlots).toList();
      
      setState(() {
        selectedFiles.addAll(limitedFiles.map((file) => File(file.path)));
      });
      
      // Show message if some files were not added due to limit
      if (files.length > remainingSlots) {
        Get.snackbar(
          languageController.getTranslation('info'),
          languageController.getTranslation('maximum_five_files_are_allowed'),
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<void> _pickPdfFile() async {
    try {
      // Check if already have 5 files
      if (selectedFiles.length >= 5) {
        Get.snackbar(
          languageController.getTranslation('error'),
          languageController.getTranslation('maximum_5_files_allowed'),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      // Calculate how many more files can be added
      final int remainingSlots = 5 - selectedFiles.length;
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'jpg', 'jpeg', 'png', 'PNG'],
      );

      if (result != null && result.files.isNotEmpty) {
        // Limit the number of files to remaining slots
        final List<PlatformFile> limitedFiles = result.files.take(remainingSlots).toList();
        
        setState(() {
          selectedFiles.addAll(
            limitedFiles
                .where((file) => file.path != null)
                .map((file) => File(file.path!))
          );
        });
        
        print("Picked files: ${limitedFiles.length} files");
        
        // Show message if some files were not added due to limit
        if (result.files.length > remainingSlots) {
          Get.snackbar(
            languageController.getTranslation('info'),
            languageController.getTranslation('maximum_five_files_are_allowed'),
            backgroundColor: Colors.blue,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        print("No files selected.");
      }
    } catch (e) {
      print("Error picking files: $e");
    }
  }


  // Function to show the options
  void _showPickerOptions(BuildContext context) {
    // Check if file limit reached
    final bool isLimitReached = selectedFiles.length >= 5;
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show current file count
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  '${languageController.getTranslation('files')}: ${selectedFiles.length}/5',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isLimitReached ? Colors.red : Colors.green,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.image, 
                  color: isLimitReached ? Colors.grey : Colors.blue
                ),
                title: Text(
                  languageController.getTranslation('select_image'),
                  style: TextStyle(
                    color: isLimitReached ? Colors.grey : Colors.black,
                  ),
                ),
                onTap: isLimitReached ? null : () {
                  Navigator.pop(context);
                  _pickImageFile();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.file_copy, 
                  color: isLimitReached ? Colors.grey : Colors.green
                ),
                title: Text(
                  languageController.getTranslation('select_file'),
                  style: TextStyle(
                    color: isLimitReached ? Colors.grey : Colors.black,
                  ),
                ),
                onTap: isLimitReached ? null : () {
                  Navigator.pop(context);
                  _pickPdfFile();
                },
              ),
              if (isLimitReached) ...[
                SizedBox(height: 8),
                Text(
                  languageController.getTranslation('maximum_5_files_reached_remove_some'),
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    print('INIT STATE - Starting...');
    
    // Add listener to amount controller to update fee calculations
    amountController.addListener(() {
      setState(() {
        // Update the disabled field controllers with new calculated values
        escrowFeeController.text = '${_calculateEscrowFee().toStringAsFixed(2)}';
        totalAmountController.text = '${_calculateTotalAmount().toStringAsFixed(2)}';
      }); // Trigger rebuild when amount changes
    });
    
    // Add language change listener to refresh categories
    languageController.addListener(() {
      if (mounted) {
        escrowController.fetchCategories();
      }
    });
    
    print('ScreenCreateEscrow initState called');
    // Fetch escrow fees and other data
    _initializeData();
    print('All fetch methods called');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Always refresh fees when screen comes into focus
    _fetchEscrowFees();
    
    // Refresh categories when language changes to update dropdown text
    escrowController.fetchCategories();
  }

  // Initialize all data
  Future<void> _initializeData() async {
    print('_initializeData - Starting...');
    // Fetch escrow fees first
    await _fetchEscrowFees();
    print('_initializeData - Escrow fees fetched, now fetching other data...');
    // Then fetch other data
    escrowController.fetchCategories();
    escrowController.fetchCurrencies();
    escrowController.fetchPaymentMethods();
    print('_initializeData - All data fetch completed');
  }

  // Force refresh escrow fees
  void _forceRefreshFees() {
    setState(() {
      escrowFeesLoaded = false;
    });
    _fetchEscrowFees();
  }

  @override
  void dispose() {
    // Remove language change listener
    languageController.removeListener(() {});
    super.dispose();
  }

    @override
  Widget build(BuildContext context) {
    // Ensure fees are fetched every time the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!escrowFeesLoaded) {
        _fetchEscrowFees();
      }
    });

    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: "Create Escrow",
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
                    // What is Escrow button - now opens Terms and Conditions PDF
                    TextButton(
                      onPressed: () {
                        settingController.openTermsAndConditions();
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
                           contentPadding: EdgeInsets.only(top: 4, left: 5, right: 5),
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

                    // Amount Field
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
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')), // Only allow numbers and up to 2 decimal places
                      ],
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 4, left: 5),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff666565)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff666565)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff18CE0F)),
                        ),
                      ),
                    ),
                    
                    // Escrow Fee Field
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          languageController.getTranslation('escrow_fee'),
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xff484848),
                              fontFamily: 'Nunito'),
                        ),
                        IconButton(
                          icon: Icon(Icons.refresh, size: 16, color: Color(0xff18CE0F)),
                          onPressed: () {
                            _fetchEscrowFees();
                          },
                          tooltip: 'Refresh fees',
                        ),
                      ],
                    ).paddingOnly(top: 10,bottom: 10),
                    TextField(
                      enabled: false, // Disable the field
                      controller: escrowFeeController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 4, left: 5),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff666565)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff666565)),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff666565)),
                        ),
                        filled: true,
                        fillColor: Color(0xffF5F5F5), // Light gray background to indicate disabled state
                      ),
                    ),
                     // Fee breakdown info
                     Padding(
                       padding: EdgeInsets.only(top: 4),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           if (escrowFeesLoaded) ...[
                             // Show Fixed fee only if greater than 0
                             if (escrowFixedFee > 0) ...[
                               Text(
                                 '${languageController.getTranslation('fixed_fee')}: ${escrowFixedFee.toStringAsFixed(2)}',
                                 style: TextStyle(
                                   color: Color(0xff666565),
                                   fontSize: 12,
                                   fontStyle: FontStyle.italic,
                                 ),
                               ),
                               SizedBox(height: 2),
                             ],
                             // Show Percentage fee only if greater than 0
                             if (escrowPercentFee > 0) ...[
                               Text(
                                 '${languageController.getTranslation('percentage_fee')}: ${escrowPercentFee.toStringAsFixed(2)}%',
                                 style: TextStyle(
                                   color: Color(0xff666565),
                                   fontSize: 12,
                                   fontStyle: FontStyle.italic,
                                 ),
                               ),
                             ],
                           ] else ...[
                             Text(
                               'Loading escrow fees...',
                               style: TextStyle(
                                 color: Colors.grey,
                                 fontSize: 12,
                                 fontStyle: FontStyle.italic,
                               ),
                             ),
                           ],
                         ],
                       ),
                     ),
                    
                    // Total Amount Field
                    SizedBox(height: 15),
                    Text(
                      languageController.getTranslation('total_amount'),
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10,bottom: 10),
                    TextField(
                      enabled: false, // Disable the field
                      controller: totalAmountController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 4, left: 5),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff18CE0F)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff18CE0F)),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff18CE0F)),
                        ),
                        filled: true,
                        fillColor: Color(0xff18CE0F).withOpacity(0.1), // Light green background
                      ),
                    ),
                    
                    // Product Name Field
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
                          languageController.getTranslation('accept'),
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xff484848),
                            fontFamily: 'Nunito',
                          ),
                        ),
                        SizedBox(width: 4), // Add space between the two texts
                        GestureDetector(
                          onTap: () {
                            settingController.openTermsAndConditions();
                          },
                          child: Text(
                            languageController.getTranslation('terms_and_conditions'),
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.blue,
                              fontFamily: 'Nunito',
                              decoration: TextDecoration.underline,
                            ),
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
                        print("${selectedCurrency}");
                        // Adding a delay of 3 seconds before the API call
                        await Future.delayed(Duration(seconds: 3));
                        // If all validations pass, proceed to store the escrow.
                        final result = await escrowController.storeEscrow(
                          title: titleController.text,
                          amount: double.parse(amountController.text),
                          email: emailController.text,
                          escrowCategoryId: escrowController.selectedCategory.value!.id,
                          currency: '${escrowController.selectedCurrencyId}', // Pass the selected currency ID directly
                          description: noteController.text.isNotEmpty ? noteController.text : "No description provided",
                          escrowTermConditions: acceptTerms,
                          attachments: selectedFiles.isNotEmpty ? selectedFiles : null,
                          paymentMethodId: escrowController.selectedPaymentMethodId.value,
                          productName: productNameController.text.isNotEmpty ? productNameController.text : null,
                        );
                        print("attachments: ${selectedFiles.length} files");
                        
                                                 // Check if escrow creation was successful
                         if (result != null && result['success'] == true) {
                           // Show success message
                           Get.snackbar(
                             languageController.getTranslation('success'),
                             result['message'] ?? languageController.getTranslation('escrow_created_successfully'),
                             snackPosition: SnackPosition.BOTTOM,
                             backgroundColor: Colors.green,
                             colorText: Colors.white,
                           );
                           
                           // Navigate to Send Escrow screen
                           Get.off(() => ScreenEscrowList());
                           
                           // Force refresh the data on the Send Escrow screen after navigation
                           WidgetsBinding.instance.addPostFrameCallback((_) async {
                             final sendEscrowController = Get.find<SendEscrowsController>();
                             await sendEscrowController.forceRefreshData();
                           });
                         } else {
                          // Show error message
                          Get.snackbar(
                            languageController.getTranslation('error'),
                            result?['message'] ?? languageController.getTranslation('failed_to_create_escrow'),
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      text: languageController.getTranslation('start_escrow'),
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
              CustomBottomContainerPostLogin()
            ],
          ),
        )
      ),
    );
  }

  // Calculate escrow fee based on API data
  double _calculateEscrowFee() {
    final double amount = double.tryParse(amountController.text) ?? 0.0;
    // Calculate: Fixed fee + (Amount * Percentage fee / 100)
    return escrowFixedFee + (amount * escrowPercentFee / 100);
  }

  // Calculate total amount including fee
  double _calculateTotalAmount() {
    final double amount = double.tryParse(amountController.text) ?? 0.0;
    final double fee = _calculateEscrowFee();
    return amount + fee;
  }
}

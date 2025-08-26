import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../../widgets/custom_textField/custom_field.dart';
import '../user_profile/user_profile_controller.dart';
import 'merchant_controller.dart';
import 'screen_merchant.dart';

class ScreenTransferOut extends StatefulWidget {
  final String merchantId;
  final String merchantName;

  ScreenTransferOut({required this.merchantId, required this.merchantName});

  @override
  _ScreenTransferOutState createState() => _ScreenTransferOutState();
}

class _ScreenTransferOutState extends State<ScreenTransferOut> {
  final MerchantController controller = Get.put(MerchantController());
  final UserProfileController userProfileController = Get.find<UserProfileController>();
  
  final TextEditingController amountController = TextEditingController();
  var selectedPaymentMethod = Rxn<PaymentMethod>();
  var isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    controller.fetchPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: Color(0xff191f28),
        title: AppBarTitle(),
        leading: CustomPopupMenu(managerId: userProfileController.userId.value,),
        actions: [
          PopupMenuButtonAction(),
          AppBarProfileButton(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      margin: EdgeInsets.all(16.0),
                      padding: EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Transfer Out",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Color(0xff18CE0F),
                              fontFamily: 'Nunito',
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Sub Account: ${widget.merchantName}",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          Divider(color: Color(0xffDDDDDD), height: 30),
                          
                          // Payment Method Dropdown
                          Text(
                            "Payment Method",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Color(0xff484848),
                              fontFamily: 'Nunito',
                            ),
                          ),
                          SizedBox(height: 8),
                          Obx(() {
                            if (controller.isLoading.value) {
                              return Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xff666565)),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xff0766AD)),
                                  ),
                                ),
                              );
                            } else {
                              return Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xff666565)),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: DropdownButtonFormField<PaymentMethod>(
                                  value: selectedPaymentMethod.value,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                    border: InputBorder.none,
                                    hintText: "",
                                    hintStyle: TextStyle(
                                      color: Color(0xffA9A9A9),
                                      fontSize: 14,
                                    ),
                                  ),
                                  items: controller.paymentMethods.map((method) {
                                    return DropdownMenuItem<PaymentMethod>(
                                      value: method,
                                      child: Text(
                                        method.name,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (PaymentMethod? newValue) {
                                    selectedPaymentMethod.value = newValue;
                                  },
                                  isExpanded: true,
                                ),
                              );
                            }
                          }),
                          
                          SizedBox(height: 20),
                          
                          // Amount Field
                          Text(
                            "Amount",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Color(0xff484848),
                              fontFamily: 'Nunito',
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                              hintText: "Enter amount",
                              hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xff666565)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xff666565)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xff0766AD)),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 30),
                          
                          // Submit Button
                          Obx(() {
                            return CustomButton(
                              text: isLoading.value ? "Processing..." : "Submit",
                              onPressed: isLoading.value ? () {} : () {
                                _handleTransferOut();
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Fixed footer at bottom
          CustomBottomContainerPostLogin(),
        ],
      ),
    );
  }

  void _handleTransferOut() async {
    // Validate fields
    if (selectedPaymentMethod.value == null) {
      Get.snackbar(
        'Error',
        'Please select a payment method',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (amountController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter an amount',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    double? amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Show processing state
    isLoading.value = true;

    try {
      // Call the controller method to submit transfer out request
      final result = await controller.submitTransferOutRequest(
        widget.merchantId,
        selectedPaymentMethod.value!.id.toString(),
        amount.toString(),
      );

      if (result['success']) {
        isLoading.value = false;
        
        // Show success message from API
        Get.snackbar(
          'Success',
          result['message'],
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
        
        // Clear form
        amountController.clear();
        selectedPaymentMethod.value = null;
        
        // Refresh merchant data and redirect to All Sub Account page
        await controller.fetchMerchants();
        Get.off(ScreenMerchant());
      } else {
        isLoading.value = false;
        
        // Show error message from API
        Get.snackbar(
          'Error',
          result['message'],
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 4),
        );
        
        // Don't navigate back, let user see the error and try again
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'An error occurred while submitting the request',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
} 
import 'package:escrowcorner/view/screens/swapping/swapping_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';
import '../user_profile/user_profile_controller.dart';

class SwappingScreen extends StatefulWidget {
  @override
  State<SwappingScreen> createState() => _SwappingScreenState();
}

class _SwappingScreenState extends State<SwappingScreen> {
  final List<Map<String, dynamic>> currencies = [
    {'name': 'USD', 'value': 1},
    {'name': 'BTC', 'value': 2},
  ];
  final UserProfileController userProfileController =Get.find<UserProfileController>();

  Map<String, dynamic>? selectedFromCurrency;
  Map<String, dynamic>? selectedToCurrency;

  final SwappingController controller = Get.put(SwappingController());

  void _checkCurrencySelection() {
    if (selectedFromCurrency != null &&
        selectedToCurrency != null &&
        selectedFromCurrency!['value'] == selectedToCurrency!['value']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: Cannot select the same currency for both fields!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: Color(0xff191f28),
        title: AppBarTitle(),
        leading: CustomPopupMenu(managerId: userProfileController.userId.value,),
        actions: [
          PopupMenuButtonAction(),
          AppBarProfileButton(),

        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xffFFFFFF),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "How much you want to swap?",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xff18CE0F),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10),
                    Text(
                      "From Currency:",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10,bottom: 10),
                    TextFormField(
                      readOnly: true,
                          obscureText: false,
                      onTap: () {
                        showMenu(
                          context: context,
                          position: RelativeRect.fromLTRB(10, 210, 0, 0),
                          items: currencies.map((currency) {
                            return PopupMenuItem<Map<String, dynamic>>(
                              value: currency,
                              child: Text(currency['name']),
                            );
                          }).toList(),
                        ).then((value) {
                          if (value != null) {
                            setState(() {
                              selectedFromCurrency = value;
                            });
                            _checkCurrencySelection();
                          }
                        });
                      },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 5),
                            hintText: selectedFromCurrency != null
                                ? selectedFromCurrency!['name']
                                : "Select Method",
                            hintStyle: TextStyle(color: Color(0xff666565)),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff666565)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff666565)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff666565)),
                            ),
                            suffixIcon: Icon(Icons.arrow_drop_down),
                          ),
                    ),
                    Text(
                      "To Currency:",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10,bottom: 10),
                    TextFormField(
                      readOnly: true,
                      onTap: () {
                        showMenu(
                          context: context,
                          position: RelativeRect.fromLTRB(10, 300, 0, 0),
                          items: currencies.map((currency) {
                            return PopupMenuItem<Map<String, dynamic>>(
                              value: currency,
                              child: Text(currency['name']),
                            );
                          }).toList(),
                        ).then((value) {
                          if (value != null) {
                            setState(() {
                              selectedToCurrency = value;
                            });
                            _checkCurrencySelection();
                          }
                        });
                      },
                      obscureText: false,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 4,left: 5),
                        hintText: selectedToCurrency != null
                            ? selectedToCurrency!['name']
                            : "Select Method",
                        hintStyle: TextStyle(color: Color(0xff666565)),
                        border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff666565))),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff666565))),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff666565),),
                        ),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                    ),
                    Text(
                     "Amount in ${selectedFromCurrency != null ? selectedFromCurrency!['name'] : ''}",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10,bottom: 10),
                    TextFormField(
                      obscureText: false,
                      controller: controller.amountController,
                      onChanged: (value) {
                        final amount = double.tryParse(value);
                        if (amount != null && selectedFromCurrency != null && selectedToCurrency != null) {
                          controller.fetchExchangeRate(
                            fromCurrencyId: selectedFromCurrency!['value'],
                            toCurrencyId: selectedToCurrency!['value'],
                            amount: amount,
                          );
                        } else {
                          controller.exchangeResult.value = ''; // Reset if input is invalid
                        }
                      },
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                        border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff666565))),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff666565))),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff666565)),
                        ),
                      ),
                    ),
                    Text(
                      "Amount in ${selectedToCurrency != null ? selectedToCurrency!['name'] : ''}",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xff484848),
                        fontFamily: 'Nunito',
                      ),
                    ).paddingOnly(top: 10, bottom: 10),
                    Obx(() => TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: controller.exchangeResult.value.isNotEmpty
                            ? controller.exchangeResult.value
                            : '', // Display the exchange result
                      ),
                      decoration: InputDecoration(
                        hintText: "Converted Amount",
                        hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                        border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff666565))),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff666565))),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff666565)),
                        ),
                      ),
                    )),


                    FFButtonWidget(
                      onPressed: () async {
                        if (selectedFromCurrency == null ||
                            selectedToCurrency == null) {
                          Get.snackbar(
                            "Error",
                            "Please select both currencies.",
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        if (selectedFromCurrency ==
                            selectedToCurrency) {
                          Get.snackbar(
                            "Error",
                            "Cannot swap the same currency.",
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        final amount = double.tryParse(controller.amountController.text);
                        if (amount == null || amount <= 0) {
                          Get.snackbar(
                            "Error",
                            "Invalid amount entered.",
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        await controller.swapCurrency(
                          fromCurrencyId: selectedFromCurrency!['value'],
                          toCurrencyId: selectedToCurrency!['value'],
                        );
                        await controller.currencyExchange(
                          fromCurrencyId: selectedFromCurrency!['value'].toString(),
                          toCurrencyId: selectedToCurrency!['value'].toString(),
                          amount: controller.amountController.text,
                        );
                      },
                      text: 'Submit',
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
                    ).paddingOnly(top: 30,bottom: 20),
                  ],
                ).paddingSymmetric(horizontal: 15),
              ).paddingOnly(top: 20,bottom: 30),

              CustomBottomContainerPostLogin().paddingOnly(top: 60),
            ],
          ),
        ),
      ),
    );
  }
}

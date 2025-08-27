import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../../widgets/common_header/common_header.dart';
import '../../controller/logo_controller.dart';
import '../../controller/language_controller.dart';
import '../user_profile/user_profile_controller.dart';
import 'transaction_controller.dart';

class ScreenAllTransactions extends StatelessWidget {
  final LogoController logoController = Get.put(LogoController());
  final TransactionsController transactionsController =
      Get.put(TransactionsController());
  final UserProfileController userProfileController = Get.find<UserProfileController>();
  final LanguageController languageController = Get.find<LanguageController>();
  
  // Create unique GlobalKeys for each dropdown
  final GlobalKey allTypesDropdownKey = GlobalKey();
  final GlobalKey allStatusDropdownKey = GlobalKey();
  final GlobalKey timeOrderDropdownKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
        backgroundColor: Color(0xffE6F0F7),
        appBar: CommonHeader(
          title: languageController.getTranslation('all_transactions'),
          managerId: userProfileController.userId.value,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await transactionsController.fetchTransactions();
          },
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                                 children: [
                   // Filters Container
                   SizedBox(height: 20),
                   Container(
                     width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Color(0xffFFFFFF),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            languageController.getTranslation('filters'),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Color(0xff18CE0F),
                              fontFamily: 'Nunito',
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                                                 child: buildDropdownField(
                                   context,
                                   languageController.getTranslation('all_types'),
                                   transactionsController.selectedType,
                                   [
                                     'all_types',
                                     'withdrawals',
                                     'deposits',
                                   ],
                                   (value) => transactionsController.updateSelectedType(value),
                                   allTypesDropdownKey,
                                 ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      languageController.getTranslation('all_status'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: Color(0xff484848),
                                        fontFamily: 'Nunito',
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Obx(() {
                                      if (transactionsController.transactionStatuses.isEmpty) {
                                        return Center(
                                          child: SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        );
                                      } else {
                                        return Container(
                                          key: allStatusDropdownKey,
                                          height: 35,
                                          child: TextFormField(
                                            onTap: () {
                                              final RenderBox? button = allStatusDropdownKey.currentContext?.findRenderObject() as RenderBox?;
                                              if (button != null) {
                                                final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
                                                final RelativeRect position = RelativeRect.fromRect(
                                                  Rect.fromPoints(
                                                    button.localToGlobal(Offset.zero, ancestor: overlay),
                                                    button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                                                  ),
                                                  Offset.zero & overlay.size,
                                                );
                                                
                                                showMenu<String>(
                                                  context: context,
                                                  position: position,
                                                  items: [
                                                    // First option: All Status
                                                    PopupMenuItem<String>(
                                                      value: 'all_status',
                                                      child: Text(
                                                        languageController.getTranslation('all_status'),
                                                        style: TextStyle(fontSize: 12),
                                                      ),
                                                    ),
                                                    // Dynamic statuses from API
                                                    ...transactionsController.transactionStatuses.map((status) {
                                                      return PopupMenuItem<String>(
                                                        value: status.name,
                                                        child: Text(
                                                          status.name,
                                                          style: TextStyle(fontSize: 12),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ],
                                                ).then((selectedStatus) {
                                                  if (selectedStatus != null) {
                                                    transactionsController.updateSelectedStatus(selectedStatus);
                                                  }
                                                });
                                              }
                                            },
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide(color: Color(0xffE0E0E0)),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide(color: Color(0xffE0E0E0)),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide(color: Color(0xffE0E0E0)),
                                              ),
                                              suffixIcon: Icon(Icons.arrow_drop_down, color: Color(0xff666666)),
                                            ),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xff484848),
                                              fontFamily: 'Nunito',
                                            ),
                                            controller: TextEditingController(
                                              text: transactionsController.selectedStatus.value == 'all_status' 
                                                ? languageController.getTranslation('all_status')
                                                : transactionsController.selectedStatus.value,
                                            ),
                                          ),
                                        );
                                      }
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                                                     SizedBox(height: 15),
                           Row(
                             children: [
                               Expanded(
                                 child: buildDropdownField(
                                   context,
                                   languageController.getTranslation('time_order'),
                                   transactionsController.selectedTimeOrder,
                                   [
                                     'time_ascending',
                                     'time_descending',
                                   ],
                                   (value) => transactionsController.updateSelectedTimeOrder(value),
                                   timeOrderDropdownKey,
                                 ),
                               ),
                               SizedBox(width: 15),
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(
                                       languageController.getTranslation('payment_method'),
                                       style: TextStyle(
                                         fontWeight: FontWeight.w500,
                                         fontSize: 12,
                                         color: Color(0xff484848),
                                         fontFamily: 'Nunito',
                                       ),
                                     ),
                                     SizedBox(height: 8),
                                     Obx(() {
                                       if (transactionsController.selectedOperator.isEmpty) {
                                         return Center(
                                           child: SizedBox(
                                             height: 20,
                                             width: 20,
                                             child: CircularProgressIndicator(strokeWidth: 2),
                                           ),
                                         );
                                       } else {
                                         final GlobalKey operatorDropdownKey = GlobalKey();
                                         return Container(
                                           key: operatorDropdownKey,
                                           height: 35,
                                           child: TextFormField(
                                             onTap: () {
                                               final RenderBox? button = operatorDropdownKey.currentContext?.findRenderObject() as RenderBox?;
                                               if (button != null) {
                                                 final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
                                                 final RelativeRect position = RelativeRect.fromRect(
                                                   Rect.fromPoints(
                                                     button.localToGlobal(Offset.zero, ancestor: overlay),
                                                     button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                                                   ),
                                                   Offset.zero & overlay.size,
                                                 );
                                                 
                                                 showMenu<OperatorMethod>(
                                                   context: context,
                                                   position: position,
                                                   items: transactionsController.selectedOperator.map((method) {
                                                     return PopupMenuItem<OperatorMethod>(
                                                       value: method,
                                                       child: Text(
                                                         method.name,
                                                         style: TextStyle(fontSize: 12),
                                                       ),
                                                     );
                                                   }).toList(),
                                                 ).then((selectedMethod) {
                                                   if (selectedMethod != null) {
                                                     transactionsController.selectedMethod.value = selectedMethod;
                                                   }
                                                 });
                                               }
                                             },
                                             controller: TextEditingController(
                                               text: transactionsController.selectedMethod.value?.name ?? '',
                                             ),
                                             readOnly: true,
                                             style: TextStyle(fontSize: 12),
                                             decoration: InputDecoration(
                                               contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                               hintText: transactionsController.selectedMethod.value?.name ?? languageController.getTranslation('select_method'),
                                               hintStyle: TextStyle(color: Color(0xffA9A9A9), fontSize: 11),
                                               border: OutlineInputBorder(
                                                 borderRadius: BorderRadius.circular(8),
                                                 borderSide: BorderSide(color: Color(0xffDDDDDD)),
                                               ),
                                               enabledBorder: OutlineInputBorder(
                                                 borderRadius: BorderRadius.circular(8),
                                                 borderSide: BorderSide(color: Color(0xffDDDDDD)),
                                               ),
                                               focusedBorder: OutlineInputBorder(
                                                 borderRadius: BorderRadius.circular(8),
                                                 borderSide: BorderSide(color: Color(0xff18CE0F)),
                                               ),
                                               suffixIcon: Icon(Icons.arrow_drop_down, size: 18),
                                             ),
                                           ),
                                         );
                                       }
                                     }),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                           SizedBox(height: 15),
                           Row(
                             children: [
                               Expanded(
                                                                   child: buildDateField(
                                    context,
                                    languageController.getTranslation('from_date'),
                                    (value) => transactionsController.updateFromDate(value),
                                    transactionsController.fromDate,
                                  ),
                               ),
                               SizedBox(width: 15),
                               Expanded(
                                                                   child: buildDateField(
                                    context,
                                    languageController.getTranslation('to_date'),
                                    (value) => transactionsController.updateToDate(value),
                                    transactionsController.toDate,
                                  ),
                               ),
                             ],
                           ),
                           SizedBox(height: 15),
                           Row(
                             children: [
                               Expanded(
                                 child: buildTextField(
                                   context,
                                   languageController.getTranslation('phone_number'),
                                   TextInputType.number,
                                   (value) => transactionsController.updatePhoneNumber(value),
                                 ),
                               ),
                               SizedBox(width: 15),
                                                               Expanded(
                                  child: Container(
                                    height: 35,
                                    margin: EdgeInsets.only(top: 28),
                                    child: Obx(() => transactionsController.isViewButtonLoading.value
                                        ? Container(
                                            height: 35,
                                            decoration: BoxDecoration(
                                              color: Color(0xff18CE0F),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              ),
                                            ),
                                          )
                                                                                 : CustomButton(
                                             text: languageController.getTranslation('view'),
                                             onPressed: () async {
                                               // Close mobile keypad if open
                                               FocusScope.of(context).unfocus();
                                               // Fetch transactions
                                               transactionsController.fetchTransactions();
                                             },
                                           )),
                                  ),
                                ),
                             ],
                           ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Transactions Container
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xffFFFFFF),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                                                 Padding(
                           padding: EdgeInsets.only(left: 20),
                           child: Text(
                             languageController.getTranslation('all_transactions'),
                             style: TextStyle(
                               fontWeight: FontWeight.w700,
                               fontSize: 16,
                               color: Color(0xff18CE0F),
                               fontFamily: 'Nunito',
                             ),
                           ),
                         ),
                        Divider(
                          color: Color(0xffDDDDDD),
                        ),
                        Obx(() {
                          if (transactionsController.isLoading.value) {
                            return Center(
                              child: SpinKitFadingFour(
                                duration: Duration(seconds: 3),
                                size: 120,
                                color: Colors.green,
                              ),
                            );
                                                     } else if (transactionsController.transactions.isEmpty) {
                             return Text(languageController.getTranslation('no_data_available'));
                           } else {
                            return Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: MediaQuery.of(context).size.height,
                                  ),
                                  child: SingleChildScrollView(
                                    child: DataTable(
                                                                             columns: [
                                         DataColumn(label: Text(languageController.getTranslation('serial_no'))),
                                         DataColumn(label: Text(languageController.getTranslation('date_time'))),
                                         DataColumn(label: Text(languageController.getTranslation('method'))),
                                         DataColumn(label: Text(languageController.getTranslation('phone_number'))),
                                         DataColumn(label: Text(languageController.getTranslation('description'))),
                                         DataColumn(label: Text(languageController.getTranslation('status'))),
                                         DataColumn(label: Text(languageController.getTranslation('transaction_id'))),
                                         DataColumn(label: Text(languageController.getTranslation('activity_title'))),
                                         DataColumn(label: Text(languageController.getTranslation('gross'))),
                                         DataColumn(label: Text(languageController.getTranslation('fee'))),
                                         DataColumn(label: Text(languageController.getTranslation('net'))),
                                         DataColumn(label: Text(languageController.getTranslation('balance'))),
                                       ],
                                      rows: transactionsController.transactions
                                          .map((transaction) {
                                                                                 return DataRow(
                                           cells: [
                                             DataCell(Text(
                                                 '${transactionsController.transactions.indexOf(transaction) + 1}')),
                                             DataCell(Text("${DateFormat('yyyy-MM-dd  HH:mm a').format(DateTime.parse(transaction.dateTime))}")),
                                             DataCell(Text(transaction.methodLabel)),
                                             DataCell(Text(transaction.phonenumber)),
                                             DataCell(Text(transaction.descriptionLabel)),
                                             DataCell(Text(transaction.status)),
                                             DataCell(Text(transaction.transactionableId)),
                                             DataCell(Text(transaction.title)),
                                             DataCell(Text('${transaction.gross} ${transaction.currency}')),
                                             DataCell(Text('${transaction.fee} ${transaction.currency}')),
                                             DataCell(Text('${transaction.net} ${transaction.currency}')),
                                             DataCell(Text('${transaction.balance} ${transaction.currency}')),
                                           ],
                                         );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  CustomBottomContainerPostLogin()
                ],
              ),
            ),
          ),
        ),
      ));
  }

  Widget buildDropdownField(
    BuildContext context,
    String label,
    RxString selectedValue,
    List<String> options,
    void Function(String) onSelected,
    GlobalKey dropdownKey,
  ) {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: Color(0xff484848),
            fontFamily: 'Nunito',
          ),
        ),
        SizedBox(height: 8),
        Container(
          key: dropdownKey,
          height: 35,
          child: Obx(() => TextFormField(
            onTap: () {
              final RenderBox? button = dropdownKey.currentContext?.findRenderObject() as RenderBox?;
              if (button != null) {
                final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
                final RelativeRect position = RelativeRect.fromRect(
                  Rect.fromPoints(
                    button.localToGlobal(Offset.zero, ancestor: overlay),
                    button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                  ),
                  Offset.zero & overlay.size,
                );
                
                showMenu<String>(
                  context: context,
                  position: position,
                  items: options.map((String option) {
                    return PopupMenuItem<String>(
                      value: option,
                      child: Text(
                        languageController.getTranslation(option),
                        style: TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                ).then((selectedOption) {
                  if (selectedOption != null) {
                    onSelected(selectedOption);
                  }
                });
              }
            },
            readOnly: true,
            style: TextStyle(fontSize: 12),
            controller: TextEditingController(text: languageController.getTranslation(selectedValue.value)),
            decoration: InputDecoration(
              suffixIcon: Icon(Icons.arrow_drop_down, size: 18),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              hintStyle: TextStyle(color: Color(0xffA9A9A9), fontSize: 11),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xffDDDDDD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xffDDDDDD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xff18CE0F)),
              ),
            ),
          )),
        ),
      ],
    );
  }

  Widget buildTextField(
    BuildContext context,
    String label,
    TextInputType keyboardType,
    void Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: Color(0xff484848),
            fontFamily: 'Nunito',
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 35,
          child: TextFormField(
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 12),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              hintStyle: TextStyle(color: Color(0xffA9A9A9), fontSize: 11),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xffDDDDDD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xffDDDDDD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xff18CE0F)),
              ),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget buildDateField(
    BuildContext context,
    String label,
    void Function(String) onChanged,
    RxString dateValue,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: Color(0xff484848),
            fontFamily: 'Nunito',
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 35,
          child: Obx(() => TextFormField(
              readOnly: true,
              style: TextStyle(fontSize: 12),
              controller: TextEditingController(text: dateValue.value),
                             decoration: InputDecoration(
                 contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                 hintText: languageController.getTranslation('select_date'),
                 hintStyle: TextStyle(color: Color(0xffA9A9A9), fontSize: 11),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xffDDDDDD)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xffDDDDDD)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xff18CE0F)),
                ),
                suffixIcon: Icon(Icons.calendar_today, size: 18),
              ),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  onChanged(picked.toIso8601String().split('T')[0]);
                }
              },
            )),
        ),
      ],
    );
  }
}

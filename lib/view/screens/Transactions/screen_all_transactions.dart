import 'package:escrowcorner/view/screens/payment_links/payment_link_controller.dart';
import 'package:escrowcorner/widgets/custom_appbar/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../controller/logo_controller.dart';
import '../user_profile/user_profile_controller.dart';
import 'transaction_controller.dart';

class ScreenAllTransactions extends StatelessWidget {
  final LogoController logoController = Get.put(LogoController());
  final TransactionsController transactionsController =
      Get.put(TransactionsController());
  final UserProfileController userProfileController = Get.find<UserProfileController>();

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
        body: RefreshIndicator(
            onRefresh: () async {
              await transactionsController.fetchTransactions();
            },
            child: SingleChildScrollView(
                child: Center(
                    child: Column(children: [
              //CustomBtcContainer().paddingOnly(top: 20),
              Container(
                //height: MediaQuery.of(context).size.height * 0.7,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xffFFFFFF),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildDropdownField(
                      context,
                      "All Types",
                      transactionsController.selectedType,
                      [
                        'All Types',
                        'Withdrawals',
                        'Deposits',
                      ],
                          (value) => transactionsController.updateSelectedType(value),
                      left: 100, // Position it 50 units from the left
                      top: 180,   // Position it at the top of the screen (or adjust as necessary)
                    ),
                    Text(
                      "Operators",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xff484848),
                        fontFamily: 'Nunito',
                      ),
                    ).paddingOnly(top: 10, bottom: 10),
                    Obx(() {
                      if (transactionsController.selectedOperator.isEmpty) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        return TextFormField(
                          onTap: () {
                            // Trigger the menu manually when the TextFormField is tapped
                            showMenu<OperatorMethod>(
                              context: context,
                              position:RelativeRect.fromLTRB(10, 180, 0, 10),
                              items: transactionsController.selectedOperator.map((method) {
                                return PopupMenuItem<OperatorMethod>(
                                  value: method,
                                  child: Text(method.name),
                                );
                              }).toList(),
                            ).then((selectedMethod) {
                              // Update the selected method when an item is selected from the menu
                              if (selectedMethod != null) {
                                transactionsController.selectedMethod.value = selectedMethod;
                              }
                            });
                          },
                          controller: TextEditingController(
                              text: transactionsController.selectedMethod.value?.name ?? '',),
                          readOnly: true,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 5),
                            hintText: transactionsController.selectedMethod.value?.name ?? "Select Method",
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
                            suffixIcon: Icon(Icons.arrow_drop_down),
                          ),
                        );

                      }
                    }),

                    buildDropdownField(
                      context,
                      "All Status",
                      transactionsController.selectedStatus,
                      [
                        'All Status',
                        'Completed',
                        'Pending',
                        'Cancelled',
                      ],
                          (value) => transactionsController.updateSelectedStatus(value),
                      left: 100, // Adjust as needed
                      top: 350,  // Adjust vertical position
                    ),

                    buildDropdownField(
                      context,
                      "Time Order",
                      transactionsController.selectedTimeOrder,
                      [
                        'Time Ascending',
                        'Time Descending',
                      ],
                          (value) => transactionsController.updateSelectedTimeOrder(value),
                      left: 10, // Customize positioning
                      top: 430,  // Adjust vertical position
                    ),

                    buildTextField(
                      context,
                      "Phone Number",
                      TextInputType.number,
                      (value) =>
                          transactionsController.updatePhoneNumber(value),
                    ),
                    CustomButton(text: "View",
                      onPressed: () async{
                        // Adding a delay of 3 seconds before the API call
                        await Future.delayed(Duration(seconds: 2));
                        transactionsController.fetchTransactions();
                      },).paddingOnly(bottom: 20),
                  ],
                ).paddingSymmetric(horizontal: 15),
              ).paddingOnly(top: 20),
              Container(
                height: MediaQuery.of(context).size.height* 0.5,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xffFFFFFF),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "All Transactions",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xff18CE0F),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10),
                    Divider(
                      color: Color(0xffDDDDDD),
                    ),
                    Obx(() {
                      if (transactionsController.isLoading.value) {
                        return Center(child: SpinKitFadingFour(
                          duration: Duration(seconds: 3),
                          size: 120,
                          color: Colors.green,
                        ));
                      } else if(transactionsController.transactions.isEmpty){
                        return Text("No Transactions Here");
                      } else {
                        return Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: MediaQuery
                                    .of(context)
                                    .size
                                    .height,
                              ),
                              child: SingleChildScrollView(
                                child: DataTable(
                                  columns: [
                                    DataColumn(label: Text('Sr No.')),
                                    DataColumn(label: Text('Date Time')),
                                    DataColumn(label: Text('Method')),
                                    DataColumn(label: Text('Phone Number')),
                                    DataColumn(label: Text('Description')),
                                    DataColumn(label: Text('Status')),
                                    DataColumn(label: Text('Transaction ID')),
                                    DataColumn(label: Text('Currency')),
                                    DataColumn(label: Text('Activity Tittle')),
                                    DataColumn(label: Text('Gross')),
                                    DataColumn(label: Text('Fee')),
                                    DataColumn(label: Text('Net')),
                                    DataColumn(label: Text('Balance')),
                                  ],
                                  rows: transactionsController.transactions
                                      .map((transaction) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(
                                            '${transactionsController
                                                .transactions.indexOf(
                                                transaction) + 1}')),
                                        DataCell(Text("${DateFormat(
                                            'yyyy-MM-dd  HH:mm a').format(
                                            DateTime.parse(
                                                transaction.dateTime))}")),
                                        DataCell(Text(transaction.methodLabel)),
                                        DataCell(Text(transaction.phonenumber)),
                                        DataCell(Text(transaction.descriptionLabel)),
                                        DataCell(Text(transaction.status)),
                                        DataCell(
                                            Text(transaction.transactionId)),
                                        DataCell(Text(transaction.currency)),
                                        DataCell(Text(transaction.title)),
                                        DataCell(Text(transaction.gross)),
                                        DataCell(Text(transaction.fee)),
                                        DataCell(Text(transaction.net)),
                                        DataCell(Text(transaction.balance)),
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
                ).paddingSymmetric(horizontal: 15),
              ).paddingOnly(top: 15, bottom: 15),
              CustomBottomContainerPostLogin()
            ])))));
  }

  Widget buildDropdownField(
      BuildContext context,
      String label,
      RxString selectedValue,
      List<String> options,
      void Function(String) onSelected,
      {double? left, double? top, double? right, double? bottom} // Optional position parameters
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xff484848),
            fontFamily: 'Nunito',
          ),
        ).paddingOnly(top: 10, bottom: 10),
        Container(
          height: 42,
          child: Obx(() => TextFormField(
            onTap: () {
              // Show the dropdown menu manually using showMenu with customized position
              showMenu<String>(
                context: context,
                position: RelativeRect.fromLTRB(
                  left ?? 0,  // Set left offset, default to 0 if not provided
                  top ?? 0,   // Set top offset, default to 0 if not provided
                  right ?? 0, // Set right offset, default to 0 if not provided
                  bottom ?? 0, // Set bottom offset, default to 0 if not provided
                ),
                items: options.map((String option) {
                  return PopupMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
              ).then((selectedOption) {
                if (selectedOption != null) {
                  onSelected(selectedOption); // Update the selected value
                }
              });
            },
            readOnly: true,
            controller: TextEditingController(text: selectedValue.value),
            decoration: InputDecoration(
              suffixIcon: Icon(Icons.arrow_drop_down),
              contentPadding: EdgeInsets.only(top: 4, left: 5),
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Color(0xff484848),
          fontFamily: 'Nunito',
        ),
      ).paddingOnly(top: 10, bottom: 10),
      Container(
        height: MediaQuery.of(context).size.height * 0.12,
        child: TextFormField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(top: 4, left: 5),
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
          onChanged: onChanged,
        ),
      ).paddingOnly(
        top: 10,
      )
    ]);
  }
}

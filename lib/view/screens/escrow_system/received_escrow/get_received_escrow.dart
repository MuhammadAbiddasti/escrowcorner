import 'package:escrowcorner/view/screens/escrow_system/received_escrow/received_escrow_controller.dart';
import 'package:escrowcorner/view/screens/escrow_system/send_escrow/send_escrow_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../../widgets/custom_button/custom_button.dart';
import '../../../../widgets/common_header/common_header.dart';
import '../../../../view/controller/language_controller.dart';
import '../../user_profile/user_profile_controller.dart';
import 'received_escrow_detail.dart';
import 'received_escrow_information.dart';


class ScreenReceivedEscrow extends StatefulWidget {
  @override
  _ScreenEscrowListState createState() => _ScreenEscrowListState();
}

class _ScreenEscrowListState extends State<ScreenReceivedEscrow> {
  final ReceivedEscrowsController controller = Get.put(ReceivedEscrowsController());
  final SendEscrowsController sendController = Get.put(SendEscrowsController());
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
  final UserProfileController userProfileController = Get.find<UserProfileController>();
  final LanguageController languageController = Get.find<LanguageController>();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ReceivedEscrowsController>()) {
      Get.put(ReceivedEscrowsController());
    }
    controller.fetchReceiverEscrows();
    
    // Listen for language changes to refresh content
    try {
      ever(languageController.selectedLanguage, (_) async {
        print('Language changed, refreshing received escrow content');
        setState(() {}); // Trigger rebuild for language change
      });
    } catch (e) {
      print('Language controller not available for received escrow: $e');
    }
  }


    @override
  Widget build(BuildContext context) {
    controller.fetchReceiverEscrows();
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: languageController.getTranslation('received_escrow'),
        managerId: userProfileController.userId.value,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              controller.fetchReceiverEscrows();
            },
            child: ListView(
              children: [
                Column(
                  children: [
                                         // Received escrow cards section
                     Align(
                       alignment: Alignment.centerLeft,
                       child: Padding(
                         padding: EdgeInsets.only(left: 28),
                         child: Text(
                           languageController.getTranslation('received_escrow'),
                           style: TextStyle(
                             fontWeight: FontWeight.w700,
                             fontSize: 16,
                             color: Color(0xff18CE0F),
                             fontFamily: 'Nunito',
                           ),
                         ),
                       ),
                     ).paddingOnly(top: 20, bottom: 10),
                    
                    Obx(() {
                      if (controller.isLoading.value) {
                        return Center(
                          child: SpinKitFadingFour(
                            duration: Duration(seconds: 3),
                            size: 120,
                            color: Colors.green,
                          ),
                        );
                      } else if (controller.receiverEscrows.isEmpty) {
                        return Center(
                          child: Text(languageController.getTranslation('no_received_escrows_available')),
                        );
                      } else {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.75,
                          child: ListView.builder(
                            padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 100),
                            itemCount: controller.receiverEscrows.length,
                            itemBuilder: (context, index) {
                              final receivedEscrow = controller.receiverEscrows[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 15, left: 8, right: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.15),
                                      spreadRadius: 2,
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Simple field layout
                                      _buildFieldRow(
                                        languageController.getTranslation('date'),
                                        formatter.format(receivedEscrow.createdAt),
                                      ),
                                      SizedBox(height: 8),
                                      
                                                                             _buildFieldRow(
                                         languageController.getTranslation('amount'),
                                         '${double.tryParse(receivedEscrow.gross.toString())?.toStringAsFixed(3) ?? '0.000'} ${receivedEscrow.currencySymbol}',
                                         valueColor: Color(0xff18CE0F),
                                       ),
                                      SizedBox(height: 8),
                                      
                                                                             _buildFieldRow(
                                         languageController.getTranslation('status'),
                                         _getTranslatedStatus(receivedEscrow.statusLabel.toString()),
                                         valueColor: _getStatusColor(receivedEscrow.statusLabel.toString()),
                                       ),
                                      SizedBox(height: 8),
                                      
                                      _buildFieldRow(
                                        languageController.getTranslation('from'),
                                        receivedEscrow.email.toString(),
                                      ),
                                      SizedBox(height: 8),
                                      
                                      _buildFieldRow(
                                        languageController.getTranslation('to'),
                                        receivedEscrow.to.toString(),
                                      ),
                                      
                                      SizedBox(height: 15),
                                      
                                                                             // View and Information buttons on same line
                                       Row(
                                         children: [
                                           // View button
                                           Expanded(
                                             flex: 1,
                                             child: SizedBox(
                                               height: 28,
                                               child: CustomButton(
                                                 text: languageController.getTranslation('view'),
                                                 textStyle: TextStyle(fontSize: 10, color: Colors.white),
                                                                                                   onPressed: () async {
                                                    controller.fetchEscrowAgreementDetail(receivedEscrow.id);
                                                    await Future.delayed(Duration(milliseconds: 500));
                                                    Get.to(() => ReceivedEscrowDetailScreen(escrowId: receivedEscrow.id));
                                                  },
                                               ).paddingSymmetric(horizontal: 8),
                                             ),
                                           ),
                                           SizedBox(width: 8),
                                           // Information button
                                           Expanded(
                                             flex: 1,
                                             child: SizedBox(
                                               height: 28,
                                               child: CustomButton(
                                                 text: languageController.getTranslation('information'),
                                                 textStyle: TextStyle(fontSize: 10, color: Colors.white),
                                                 backGroundColor: Colors.blue,
                                                                                                 onPressed: () async {
                                                  Get.to(() => ReceivedEscrowInformationScreen(escrowId: receivedEscrow.id));
                                                },
                                               ).paddingSymmetric(horizontal: 8),
                                             ),
                                           ),
                                         ],
                                       ),
                                       
                                       SizedBox(height: 8),
                                       
                                                                               // Reject button below View and Information buttons - only show when status is "on hold"
                                        if (receivedEscrow.statusLabel.toString().toLowerCase() == 'on hold' ||
                                            receivedEscrow.statusLabel.toString().toLowerCase() == 'onhold')
                                          SizedBox(
                                            width: double.infinity,
                                            height: 28,
                                                                                           child: Obx(() => CustomButton(
                                                 text: languageController.getTranslation('reject'),
                                                 textStyle: TextStyle(fontSize: 10, color: Colors.white),
                                                 backGroundColor: Colors.red,
                                                 loading: controller.isRejecting.value,
                                                 onPressed: () async {
                                                   // Call the reject API and wait for completion
                                                   await controller.rejectEscrow(receivedEscrow.id);
                                                   // Refresh the screen with fresh data regardless of success/failure
                                                   await controller.fetchReceiverEscrows();
                                                 },
                                               )).paddingSymmetric(horizontal: 8),
                                          ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    }),
                  ],
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomContainerPostLogin()
          )
        ],
      ),
    );
  }
  
  // Helper method to get status color based on status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Color(0xffFFC107); // Yellow
      case 'Completed':
        return Color(0xff4CAF50); // Green
      case 'Cancelled':
        return Color(0xffF44336); // Red
      default:
        return Color(0xff607D8B); // Grey
    }
  }

  Widget _buildFieldRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  
  // Helper method to get translated status text
  String _getTranslatedStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return languageController.getTranslation('pending');
      case 'completed':
      case 'complete':
        return languageController.getTranslation('completed');
      case 'on hold':
      case 'onhold':
        return languageController.getTranslation('on_hold');
      case 'cancelled':
      case 'canceled':
        return languageController.getTranslation('cancelled');
      case 'rejected':
        return languageController.getTranslation('rejected');
      default:
        return status; // Return original status if no translation found
    }
  }
}
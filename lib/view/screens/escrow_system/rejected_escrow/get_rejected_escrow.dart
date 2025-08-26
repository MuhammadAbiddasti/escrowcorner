import 'package:escrowcorner/view/screens/escrow_system/rejected_escrow/rejected_escrow_controller.dart';
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
import '../send_escrow/send_escrow_detail.dart';
import 'rejected_escrow_detail.dart';
import 'rejected_escrow_information.dart';


class GetRejectedEscrow extends StatefulWidget {
  const GetRejectedEscrow({super.key});

  @override
  State<GetRejectedEscrow> createState() => _GetRejectedEscrowState();
}

class _GetRejectedEscrowState extends State<GetRejectedEscrow> {
  final RejectedEscrowController controller = Get.put(RejectedEscrowController());
  final SendEscrowsController sendController = Get.put(SendEscrowsController());
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
  final UserProfileController userProfileController = Get.find<UserProfileController>();
  final LanguageController languageController = Get.find<LanguageController>();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<RejectedEscrowController>()) {
      Get.put(RejectedEscrowController());
    }
    controller.fetchRejectedEscrows();
    
    // Listen for language changes to refresh content
    try {
      ever(languageController.selectedLanguage, (_) async {
        print('Language changed, refreshing rejected escrow content');
        setState(() {}); // Trigger rebuild for language change
      });
    } catch (e) {
      print('Language controller not available for rejected escrow: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    controller.fetchRejectedEscrows();
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: languageController.getTranslation('rejected_escrow'),
        managerId: userProfileController.userId.value,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              controller.fetchRejectedEscrows();
            },
            child: ListView(
              children: [
                Column(
                  children: [
                    // Rejected escrow cards section
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 28),
                        child: Text(
                          languageController.getTranslation('rejected_escrow'),
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
                      } else if (controller.rejectedEscrows.isEmpty) {
                        return Center(
                          child: Text(languageController.getTranslation('no_rejected_escrows_available')),
                        );
                      } else {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.75,
                          child: ListView.builder(
                            padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 100),
                            itemCount: controller.rejectedEscrows.length,
                            itemBuilder: (context, index) {
                              final rejectEscrow = controller.rejectedEscrows[index];
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
                                        formatter.format(rejectEscrow.createdAt),
                                      ),
                                      SizedBox(height: 8),
                                      
                                                                             _buildFieldRow(
                                         languageController.getTranslation('amount'),
                                         '${double.tryParse(rejectEscrow.gross.toString())?.toStringAsFixed(3) ?? '0.000'} ${rejectEscrow.currencySymbol}',
                                         valueColor: Color(0xff18CE0F),
                                       ),
                                      SizedBox(height: 8),
                                      
                                      _buildFieldRow(
                                        languageController.getTranslation('status'),
                                        _getTranslatedStatus(rejectEscrow.statusLabel.toString()),
                                        valueColor: _getStatusColor(rejectEscrow.statusLabel.toString()),
                                      ),
                                      SizedBox(height: 8),
                                      
                                      _buildFieldRow(
                                        languageController.getTranslation('from'),
                                        rejectEscrow.userId.toString(),
                                      ),
                                      SizedBox(height: 8),
                                      
                                      _buildFieldRow(
                                        languageController.getTranslation('to'),
                                        rejectEscrow.to.toString(),
                                      ),
                                      
                                      SizedBox(height: 15),
                                      
                                      // View and Information buttons on same line
                                      Row(
                                        children: [
                                          // View button
                                          Expanded(
                                            flex: 1,
                                            child: SizedBox(
                                              height: 35,
                                              child: CustomButton(
                                                text: languageController.getTranslation('view'),
                                                textStyle: TextStyle(fontSize: 14, color: Colors.white),
                                                                                                 onPressed: () async {
                                                   // Navigate to rejected escrow detail screen
                                                   Get.to(() => RejectedEscrowDetailScreen(escrowId: rejectEscrow.id));
                                                 },
                                              ).paddingSymmetric(horizontal: 8),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          // Information button
                                          Expanded(
                                            flex: 1,
                                            child: SizedBox(
                                              height: 35,
                                              child: CustomButton(
                                                text: languageController.getTranslation('information'),
                                                textStyle: TextStyle(fontSize: 14, color: Colors.white),
                                                backGroundColor: Colors.blue,
                                                onPressed: () async {
                                                  // Navigate to rejected escrow information screen
                                                  Get.to(() => RejectedEscrowInformationScreen(escrowId: rejectEscrow.id));
                                                },
                                              ).paddingSymmetric(horizontal: 8),
                                            ),
                                          ),
                                        ],
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

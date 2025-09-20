import 'package:escrowcorner/view/screens/escrow_system/cancelled_escrow/cancelled_escrow_controller.dart';
import 'package:escrowcorner/view/screens/escrow_system/cancelled_escrow/get_cancelled_escrow.dart';
import 'package:escrowcorner/view/screens/user_profile/user_profile_controller.dart';
import 'package:escrowcorner/view/controller/language_controller.dart';
import 'package:escrowcorner/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:escrowcorner/widgets/common_header/common_header.dart';
import 'package:escrowcorner/widgets/custom_button/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CancelledEscrowDetailScreen extends StatefulWidget {
  final int escrowId;

  CancelledEscrowDetailScreen({required this.escrowId});

  @override
  _CancelledEscrowDetailScreenState createState() => _CancelledEscrowDetailScreenState();
}

class _CancelledEscrowDetailScreenState extends State<CancelledEscrowDetailScreen> {
  final CancelledEscrowController controller = Get.put(CancelledEscrowController());
  final UserProfileController userController = Get.put(UserProfileController());
  final LanguageController languageController = Get.find<LanguageController>();
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    // Fetch cancelled escrow details when screen initializes
    controller.fetchCancelledEscrowDetail(widget.escrowId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: languageController.getTranslation('cancelled_escrow_details'),
        managerId: userController.userId.value,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await controller.fetchCancelledEscrowDetail(widget.escrowId);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.65,
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Color(0xffFFFFFF),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() {
                              if (controller.cancelledEscrowDetail.isNotEmpty) {
                                                                       final cancelledDetails = controller.cancelledEscrowDetail.first;
                                       return Text(
                                         cancelledDetails.title ?? languageController.getTranslation('cancelled_escrow_details'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Color(0xff18CE0F),
                                    fontFamily: 'Nunito',
                                  ),
                                ).paddingOnly(top: 10);
                              } else {
                                return Text(
                                  languageController.getTranslation('cancelled_escrow_details'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Color(0xff18CE0F),
                                    fontFamily: 'Nunito',
                                  ),
                                ).paddingOnly(top: 10);
                              }
                            }),
                            Divider(color: Color(0xffDDDDDD)),
                            Obx(() {
                              if (controller.isLoadingCancelledDetail.value) {
                                return Expanded(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(height: 16),
                                        Text(
                                          'Loading cancelled escrow details...',
                                          style: TextStyle(fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else if (controller.cancelledEscrowDetail.isEmpty) {
                                return Expanded(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          languageController.getTranslation('no_details_available'),
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Debug: Check console for API response details',
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'API Endpoint: /api/requestedEscrowDetail/${widget.escrowId}',
                                          style: TextStyle(fontSize: 10, color: Colors.grey),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Controller cancelledEscrowDetail length: ${controller.cancelledEscrowDetail.length}',
                                          style: TextStyle(fontSize: 10, color: Colors.grey),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Controller isLoadingCancelledDetail: ${controller.isLoadingCancelledDetail.value}',
                                          style: TextStyle(fontSize: 10, color: Colors.grey),
                                        ),
                                        SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            print('Manual refresh triggered for ID: ${widget.escrowId}');
                                            controller.fetchCancelledEscrowDetail(widget.escrowId);
                                          },
                                          child: Text('Manual Refresh'),
                                        ),
                                        SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            print('Checking controller state...');
                                            controller.checkCurrentState();
                                          },
                                          child: Text('Check State'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                final cancelledDetails = controller.cancelledEscrowDetail.first;
                                
                                return Expanded(
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                                                                                                                // Display the requested fields
                                            _buildDetailRow(
                                              languageController.getTranslation('holding_period'), 
                                              cancelledDetails.holdingPeriod ?? 'N/A'
                                            ),
                                           _buildDetailRow(
                                             languageController.getTranslation('created_at'), 
                                             cancelledDetails.createdAt != null ? formatter.format(cancelledDetails.createdAt!) : 'N/A'
                                           ),
                                           _buildDetailRow(
                                             languageController.getTranslation('sender_email'), 
                                             cancelledDetails.senderEmail ?? 'N/A'
                                           ),
                                           _buildDetailRow(
                                             languageController.getTranslation('receiver_email'), 
                                             cancelledDetails.receiverEmail ?? 'N/A'
                                           ),
                                           _buildDetailRow(
                                             languageController.getTranslation('status'), 
                                             _getTranslatedStatus(cancelledDetails.statusLabel.toString())
                                           ),
                                           if (cancelledDetails.paymentMethodName != null)
                                             _buildDetailRow(
                                               languageController.getTranslation('method'), 
                                               cancelledDetails.paymentMethodName!
                                             ),
                                           _buildDetailRow(
                                             languageController.getTranslation('amount'),
                                             '${cancelledDetails.currencySymbol ?? ''} ${cancelledDetails.gross}'
                                           ),
                                           
                                           // Go Back button
                                           SizedBox(height: 20),
                                           SizedBox(
                                             height: 40,
                                             width: double.infinity,
                                             child: CustomButton(
                                               text: languageController.getTranslation('go_back'),
                                               textStyle: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                               backGroundColor: Colors.grey[200],
                                               onPressed: () {
                                                 // Navigate back to get_cancelled_escrow screen
                                                 Get.off(() => GetCancelledEscrow());
                                               },
                                             ),
                                           ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }),
                          ],
                        ).paddingSymmetric(horizontal: 15),
                      ).paddingOnly(top: 30, bottom: 30),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomContainerPostLogin().paddingOnly(top: 60),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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
        return status;
    }
  }
}

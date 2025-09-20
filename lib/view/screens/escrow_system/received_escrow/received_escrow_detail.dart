import 'package:escrowcorner/view/screens/escrow_system/received_escrow/received_escrow_controller.dart';
import 'package:escrowcorner/view/screens/escrow_system/received_escrow/get_received_escrow.dart';
import 'package:escrowcorner/view/screens/user_profile/user_profile_controller.dart';
import 'package:escrowcorner/view/controller/language_controller.dart';
import 'package:escrowcorner/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:escrowcorner/widgets/common_header/common_header.dart';
import 'package:escrowcorner/widgets/custom_button/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReceivedEscrowDetailScreen extends StatefulWidget {
  final int escrowId;

  ReceivedEscrowDetailScreen({required this.escrowId});

  @override
  _ReceivedEscrowDetailScreenState createState() => _ReceivedEscrowDetailScreenState();
}

class _ReceivedEscrowDetailScreenState extends State<ReceivedEscrowDetailScreen> {
  final ReceivedEscrowsController controller = Get.put(ReceivedEscrowsController());
  final UserProfileController userController = Get.put(UserProfileController());
  final LanguageController languageController = Get.find<LanguageController>();
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    // Fetch escrow agreement details when screen initializes
    controller.fetchEscrowAgreementDetail(widget.escrowId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: languageController.getTranslation('received_escrow_detail'),
        managerId: userController.userId.value,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await controller.fetchEscrowAgreementDetail(widget.escrowId);
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
                              if (controller.escrowAgreementDetail.isNotEmpty) {
                                final agreementDetails = controller.escrowAgreementDetail.first;
                                return Text(
                                  agreementDetails.title ?? languageController.getTranslation('received_escrow_detail'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Color(0xff18CE0F),
                                    fontFamily: 'Nunito',
                                  ),
                                ).paddingOnly(top: 10);
                              } else {
                                return Text(
                                  languageController.getTranslation('received_escrow_detail'),
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
                              if (controller.isLoadingAgreementDetail.value) {
                                return Expanded(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(height: 16),
                                        Text(
                                          'Loading escrow agreement details...',
                                          style: TextStyle(fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else if (controller.escrowAgreementDetail.isEmpty) {
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
                                          'API Endpoint: /api/escrowagreement/${widget.escrowId}',
                                          style: TextStyle(fontSize: 10, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                final agreementDetails = controller.escrowAgreementDetail.first;
                                
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
                                            agreementDetails.holdingPeriod != null && agreementDetails.holdingPeriod! > 0 
                                              ? '${agreementDetails.holdingPeriod} ${languageController.getTranslation('days')}'
                                              : 'N/A'
                                          ),
                                          _buildDetailRow(
                                            languageController.getTranslation('created_at'), 
                                            agreementDetails.createdAt != null ? formatter.format(agreementDetails.createdAt!) : 'N/A'
                                          ),
                                          _buildDetailRow(
                                            languageController.getTranslation('sender_email'), 
                                            agreementDetails.senderEmail ?? 'N/A'
                                          ),
                                          _buildDetailRow(
                                            languageController.getTranslation('receiver_email'), 
                                            agreementDetails.receiverEmail ?? 'N/A'
                                          ),
                                          _buildDetailRow(
                                            languageController.getTranslation('status'), 
                                            _getTranslatedStatus(agreementDetails.statusLabel.toString())
                                          ),
                                          if (agreementDetails.paymentMethodName != null)
                                            _buildDetailRow(
                                              languageController.getTranslation('method'), 
                                              agreementDetails.paymentMethodName!
                                            ),
                                                                                    _buildDetailRow(
                                            languageController.getTranslation('amount'),
                                            '${agreementDetails.currencySymbol ?? ''} ${agreementDetails.gross}'
                                          ),
                                          
                                                                                     // Add some spacing before the Reject button (only show if status is "on hold")
                                           if (agreementDetails.statusLabel.toString().toLowerCase() == 'on hold' ||
                                               agreementDetails.statusLabel.toString().toLowerCase() == 'onhold')
                                             ...[
                                               SizedBox(height: 20),
                                               
                                               // Reject button centered below amount - only show when status is "on hold"
                                               Center(
                                                 child: SizedBox(
                                                   width: 200,
                                                   height: 40,
                                                   child: Obx(() => CustomButton(
                                                     text: languageController.getTranslation('reject'),
                                                     textStyle: TextStyle(fontSize: 16, color: Colors.white),
                                                     backGroundColor: Colors.red,
                                                     loading: controller.isRejecting.value,
                                                     onPressed: () async {
                                                       // Call the reject API and wait for completion
                                                       await controller.rejectEscrow(widget.escrowId);
                                                       // Refresh the detail screen with fresh data regardless of success/failure
                                                       await controller.fetchEscrowAgreementDetail(widget.escrowId);
                                                     },
                                                   )),
                                                 ),
                                               ),
                                             ],
                                             
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
                                                // Navigate back to get_received_escrow screen
                                                Get.off(() => ScreenReceivedEscrow());
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

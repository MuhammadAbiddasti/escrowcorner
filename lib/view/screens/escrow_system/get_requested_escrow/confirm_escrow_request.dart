import 'package:escrowcorner/view/screens/escrow_system/get_requested_escrow/requested_escrow_controller.dart';
import 'package:escrowcorner/view/screens/user_profile/user_profile_controller.dart';
import 'package:escrowcorner/view/controller/language_controller.dart';
import 'package:escrowcorner/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:escrowcorner/widgets/common_header/common_header.dart';
import 'package:escrowcorner/widgets/custom_button/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:escrowcorner/view/screens/escrow_system/get_requested_escrow/requested_escrow_detail.dart';

class ConfirmEscrowRequestScreen extends StatefulWidget {
  final int escrowId;
  final String escrowTitle;
  final String escrowAmount;
  final String currencySymbol;

  const ConfirmEscrowRequestScreen({
    Key? key,
    required this.escrowId,
    required this.escrowTitle,
    required this.escrowAmount,
    required this.currencySymbol,
  }) : super(key: key);

  @override
  _ConfirmEscrowRequestScreenState createState() => _ConfirmEscrowRequestScreenState();
}

class _ConfirmEscrowRequestScreenState extends State<ConfirmEscrowRequestScreen> {
  final RequestedEscrowController controller = Get.put(RequestedEscrowController());
  final UserProfileController userController = Get.put(UserProfileController());
  final LanguageController languageController = Get.find<LanguageController>();

  @override
  void initState() {
    super.initState();
    controller.isApproveSuccessful.value = false;
    
    if (controller.escrowAgreementDetail.isEmpty) {
      controller.confirmEscrowRequest(widget.escrowId);
    }
  }

  @override
  void dispose() {
    controller.clearData();
    super.dispose();
  }

  Future<void> _loadEscrowData() async {
    await controller.confirmEscrowRequest(widget.escrowId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: languageController.getTranslation('confirm_escrow'),
        managerId: userController.userId.value,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadEscrowData,
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
                        height: MediaQuery.of(context).size.height * 0.75,
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
                                  agreementDetails.title ?? languageController.getTranslation('confirm_escrow'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Color(0xff18CE0F),
                                    fontFamily: 'Nunito',
                                  ),
                                ).paddingOnly(top: 10);
                              } else {
                                return Text(
                                  languageController.getTranslation('confirm_escrow'),
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
                            Expanded(
                              child: Obx(() {
                                if (controller.isLoadingAgreementDetail.value && controller.escrowAgreementDetail.isEmpty) {
                                  return Center(
                                    child: SpinKitFadingFour(
                                      duration: Duration(seconds: 3),
                                      size: 120,
                                      color: Colors.green,
                                    ),
                                  );
                                } else if (controller.escrowAgreementDetail.isEmpty) {
                                  return Center(
                                    child: Text(languageController.getTranslation('loading_escrow_details')),
                                  );
                                } else {
                                  return SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (controller.escrowAgreementDetail.first.holdingPeriod != null &&
                                              controller.escrowAgreementDetail.first.holdingPeriod!.isNotEmpty)
                                            _buildDetailRow(
                                              languageController.getTranslation('holding_period'),
                                              controller.escrowAgreementDetail.first.holdingPeriod!
                                            ),
                                          
                                          _buildDetailRow(
                                            languageController.getTranslation('created_at'),
                                            controller.escrowAgreementDetail.first.createdAt.isNotEmpty ?
                                            controller.escrowAgreementDetail.first.createdAt : 'N/A'
                                          ),
                                          
                                          _buildDetailRow(
                                            languageController.getTranslation('sender_email'), 
                                            controller.escrowAgreementDetail.first.senderEmail ?? 'N/A'
                                          ),
                                          
                                          _buildDetailRow(
                                            languageController.getTranslation('receiver_email'), 
                                            controller.escrowAgreementDetail.first.receiverEmail ?? 'N/A'
                                          ),
                                          
                                          _buildDetailRow(
                                            languageController.getTranslation('status'), 
                                            _getTranslatedStatus(controller.escrowAgreementDetail.first.statusLabel.toString())
                                          ),
                                          
                                          if (controller.escrowAgreementDetail.first.method != null)
                                            _buildDetailRow(
                                              languageController.getTranslation('method'),
                                              controller.escrowAgreementDetail.first.method!
                                            ),
                                          
                                          _buildDetailRow(
                                            languageController.getTranslation('amount'),
                                            '${controller.escrowAgreementDetail.first.currencySymbol ?? ''} ${controller.escrowAgreementDetail.first.gross}'
                                          ),
                                          
                                          SizedBox(height: 8),
                                          
                                          if (controller.escrowAgreementDetail.first.fixedEscrowFee != null && 
                                              controller.escrowAgreementDetail.first.fixedEscrowFee!.isNotEmpty &&
                                              controller.escrowAgreementDetail.first.fixedEscrowFee != '0' &&
                                              controller.escrowAgreementDetail.first.fixedEscrowFee != '0.00' &&
                                              controller.escrowAgreementDetail.first.fixedEscrowFee != '0.0')
                                            _buildFeeRow(
                                              languageController.getTranslation('fixed_fee'),
                                              '${controller.escrowAgreementDetail.first.currencySymbol ?? ''} ${controller.escrowAgreementDetail.first.fixedEscrowFee}',
                                              Colors.red,
                                            ),
                                          
                                          if (controller.escrowAgreementDetail.first.percentageEscrowFee != null && 
                                              controller.escrowAgreementDetail.first.percentageEscrowFee!.isNotEmpty &&
                                              controller.escrowAgreementDetail.first.percentageEscrowFee != '0' &&
                                              controller.escrowAgreementDetail.first.percentageEscrowFee != '0.00' &&
                                              controller.escrowAgreementDetail.first.percentageEscrowFee != '0.0' &&
                                              controller.escrowAgreementDetail.first.percentageEscrowFee != '0%' &&
                                              controller.escrowAgreementDetail.first.percentageEscrowFee != '0.00%' &&
                                              controller.escrowAgreementDetail.first.percentageEscrowFee != '0.0%')
                                            _buildFeeRow(
                                              languageController.getTranslation('percentage_fee'),
                                              controller.escrowAgreementDetail.first.percentageEscrowFee!,
                                              Colors.red,
                                            ),
                                          
                                          if (controller.escrowAgreementDetail.first.fee != null && 
                                              controller.escrowAgreementDetail.first.fee!.isNotEmpty &&
                                              controller.escrowAgreementDetail.first.fee != '0' &&
                                              controller.escrowAgreementDetail.first.fee != '0.00' &&
                                              controller.escrowAgreementDetail.first.fee != '0.0')
                                            _buildFeeRow(
                                              languageController.getTranslation('total_fee'),
                                              '${controller.escrowAgreementDetail.first.currencySymbol ?? ''} ${controller.escrowAgreementDetail.first.fee}',
                                              Colors.red,
                                            ),
                                          
                                          if (controller.escrowAgreementDetail.first.totalAmount != null && 
                                              controller.escrowAgreementDetail.first.totalAmount!.isNotEmpty)
                                            _buildDetailRow(
                                              languageController.getTranslation('total_amount'),
                                              '${controller.escrowAgreementDetail.first.currencySymbol ?? ''} ${controller.escrowAgreementDetail.first.totalAmount}'
                                            ),
                                          
                                          SizedBox(height: 20),
                                          
                                          SizedBox(
                                            height: 40,
                                            width: double.infinity,
                                            child: CustomButton(
                                              text: languageController.getTranslation('cancel'),
                                              textStyle: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                              backGroundColor: Colors.grey[200],
                                              onPressed: () {
                                                Get.back();
                                              },
                                            ),
                                          ),
                                          
                                          SizedBox(height: 16),
                                          
                                          SizedBox(
                                            height: 40,
                                            width: double.infinity,
                                            child: Obx(() => CustomButton(
                                              text: controller.isApproving.value 
                                                ? '' 
                                                : languageController.getTranslation('confirm_approval'),
                                              textStyle: TextStyle(fontSize: 12, color: Colors.white),
                                              backGroundColor: Colors.green,
                                              loading: controller.isApproving.value,
                                              onPressed: () async {
                                                if (!controller.isApproving.value) {
                                                  try {
                                                    print('Starting approve request for escrowId: ${widget.escrowId}');
                                                    
                                                    // Call the approve_request API and wait for completion
                                                    bool success = await controller.approveRequest(widget.escrowId);
                                                    
                                                    print('Approve request completed. Success: $success');
                                                    
                                                    // Wait a moment for any data updates to complete
                                                    await Future.delayed(Duration(milliseconds: 500));
                                                    
                                                    // Always navigate to detail screen regardless of success/failure
                                                    print('Navigating to RequestedEscrowDetailScreen...');
                                                    Get.off(() => RequestedEscrowDetailScreen(escrowId: widget.escrowId));
                                                    
                                                  } catch (e) {
                                                    print('Error approving request: $e');
                                                    
                                                    // Show error message to user
                                                    Get.snackbar(
                                                      languageController.getTranslation('error'),
                                                      'Failed to approve request: $e',
                                                      backgroundColor: Colors.red,
                                                      colorText: Colors.white,
                                                      duration: Duration(seconds: 3),
                                                    );
                                                    
                                                    // Wait a moment before navigation
                                                    await Future.delayed(Duration(milliseconds: 500));
                                                    
                                                    // Navigate to detail screen even on error
                                                    print('Navigating to RequestedEscrowDetailScreen after error...');
                                                    Get.off(() => RequestedEscrowDetailScreen(escrowId: widget.escrowId));
                                                  }
                                                }
                                              },
                                            )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              }),
                            ),
                          ],
                        ).paddingSymmetric(horizontal: 15),
                      ).paddingOnly(top: 30, bottom: 30).marginOnly(bottom: 100),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomContainerPostLogin().paddingOnly(top: 180),
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
                fontSize: 10,
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
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.visible,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
                fontSize: 10,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.visible,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

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

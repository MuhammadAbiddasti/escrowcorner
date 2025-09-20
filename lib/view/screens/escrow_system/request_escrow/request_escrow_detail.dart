import 'package:escrowcorner/view/screens/escrow_system/request_escrow/request_escrow_controller.dart';
import 'package:escrowcorner/view/screens/escrow_system/request_escrow/request_escrow.dart';
import 'package:escrowcorner/view/screens/user_profile/user_profile_controller.dart';
import 'package:escrowcorner/view/controller/language_controller.dart';
import 'package:escrowcorner/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:escrowcorner/widgets/common_header/common_header.dart';
import 'package:escrowcorner/widgets/custom_button/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RequestEscrowDetailScreen extends StatefulWidget {
  final int escrowId;

  RequestEscrowDetailScreen({required this.escrowId});

  @override
  _RequestEscrowDetailScreenState createState() => _RequestEscrowDetailScreenState();
}

class _RequestEscrowDetailScreenState extends State<RequestEscrowDetailScreen> {
  final RequestEscrowController controller = Get.put(RequestEscrowController());
  final UserProfileController userController = Get.put(UserProfileController());
  final LanguageController languageController = Get.find<LanguageController>();
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    // Fetch escrow agreement details when screen initializes
    controller.fetchRequestEscrowDetail(widget.escrowId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: languageController.getTranslation('request_escrow_details'),
        managerId: userController.userId.value,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await controller.fetchRequestEscrowDetail(widget.escrowId);
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
                              if (controller.escrowDetail.isNotEmpty) {
                                final agreementDetails = controller.escrowDetail.first;
                                return Text(
                                  agreementDetails.title ?? languageController.getTranslation('request_escrow_details'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Color(0xff18CE0F),
                                    fontFamily: 'Nunito',
                                  ),
                                ).paddingOnly(top: 10);
                              } else {
                                return Text(
                                  languageController.getTranslation('request_escrow_details'),
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
                              if (controller.isLoading.value) {
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
                              } else if (controller.escrowDetail.isEmpty) {
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
                                          'Controller escrowDetail length: ${controller.escrowDetail.length}',
                                          style: TextStyle(fontSize: 10, color: Colors.grey),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Controller isLoading: ${controller.isLoading.value}',
                                          style: TextStyle(fontSize: 10, color: Colors.grey),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Escrow ID: ${widget.escrowId}',
                                          style: TextStyle(fontSize: 10, color: Colors.grey),
                                        ),
                                        SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            print('Manual refresh triggered for ID: ${widget.escrowId}');
                                            controller.fetchRequestEscrowDetail(widget.escrowId);
                                          },
                                          child: Text('Manual Refresh'),
                                        ),
                                        SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            print('Manual reset loading triggered');
                                            controller.resetLoading();
                                          },
                                          child: Text('Reset Loading'),
                                        ),
                                        SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            print('Adding test data');
                                            controller.addTestData();
                                          },
                                          child: Text('Add Test Data'),
                                        ),
                                        SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            print('Showing API response fields');
                                            controller.showApiResponseFields();
                                          },
                                          child: Text('Show API Fields'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                final agreementDetails = controller.escrowDetail.first;
                                
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
                                            agreementDetails.escrows_hpd > 0 
                                              ? '${agreementDetails.escrows_hpd} ${languageController.getTranslation('days')}'
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
                                                                                     // Payment method not available in this model
                                           _buildDetailRow(
                                             languageController.getTranslation('amount'),
                                             '${agreementDetails.currencySymbol ?? ''} ${agreementDetails.gross}'
                                           ),
                                           
                                           // Go Back button - Just below amount
                                           SizedBox(height: 20),
                                           SizedBox(
                                             height: 40,
                                             width: double.infinity,
                                             child: CustomButton(
                                               text: languageController.getTranslation('go_back'),
                                               textStyle: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                               backGroundColor: Colors.grey[200],
                                               onPressed: () {
                                                 // Navigate back to request_escrow screen
                                                 Get.off(() => GetRequestEscrow());
                                               },
                                             ),
                                           ),
                                           
                                           // Add some spacing before the other buttons
                                           SizedBox(height: 20),
                                           
                                           // Cancel Request button - show when status is NOT completed and NOT rejected
                                           if (agreementDetails.statusLabel.toString().toLowerCase() != 'completed' && 
                                               agreementDetails.statusLabel.toString().toLowerCase() != 'rejected')
                                             ...[
                                               Center(
                                                 child: SizedBox(
                                                   width: 280,
                                                   height: 40,
                                                   child: Obx(() {
                                                     final isLoading = controller.getCancelLoading(widget.escrowId);
                                                     print("=== Cancel Request Button Obx Update ===");
                                                     print("Escrow ID: ${widget.escrowId}");
                                                     print("Loading state: $isLoading");
                                                     print("================================");
                                                     
                                                     return CustomButton(
                                                       text: languageController.getTranslation('cancel_request'),
                                                       textStyle: TextStyle(fontSize: 12, color: Colors.white),
                                                       backGroundColor: Colors.red,
                                                       loading: isLoading,
                                                       onPressed: () async {
                                                         print("=== Cancel Request Button Clicked ===");
                                                         print("Escrow ID: ${widget.escrowId}");
                                                         print("Current loading state: ${controller.getCancelLoading(widget.escrowId)}");
                                                         
                                                         if (!controller.getCancelLoading(widget.escrowId)) {
                                                           print("Calling cancelRequestEscrow API...");
                                                           // Call the cancel API and wait for completion
                                                           await controller.cancelRequestEscrow('${widget.escrowId}');
                                                           // Redirect to main request escrow screen with fresh data
                                                           Get.off(() => GetRequestEscrow());
                                                         } else {
                                                           print("Button is already loading, ignoring click");
                                                         }
                                                       },
                                                     );
                                                   }),
                                                 ),
                                               ),
                                               SizedBox(height: 16),
                                               
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
                                                     // Navigate back to request_escrow screen
                                                     Get.off(() => GetRequestEscrow());
                                                   },
                                                 ),
                                               ),
                                             ],
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

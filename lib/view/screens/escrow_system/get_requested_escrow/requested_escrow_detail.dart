import 'package:escrowcorner/view/screens/escrow_system/get_requested_escrow/requested_escrow_controller.dart';
import 'package:escrowcorner/view/screens/user_profile/user_profile_controller.dart';
import 'package:escrowcorner/view/controller/language_controller.dart';
import 'package:escrowcorner/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:escrowcorner/widgets/common_header/common_header.dart';
import 'package:escrowcorner/widgets/custom_button/custom_button.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:escrowcorner/view/screens/escrow_system/get_requested_escrow/confirm_escrow_request.dart';

class RequestedEscrowDetailScreen extends StatefulWidget {
  final int escrowId;

  RequestedEscrowDetailScreen({required this.escrowId});

  @override
  _RequestedEscrowDetailScreenState createState() => _RequestedEscrowDetailScreenState();
}

class _RequestedEscrowDetailScreenState extends State<RequestedEscrowDetailScreen> {
  late final RequestedEscrowController controller;
  final UserProfileController userController = Get.put(UserProfileController());
  final LanguageController languageController = Get.find<LanguageController>();
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    
    // Get the existing controller or create a new one if needed
    if (Get.isRegistered<RequestedEscrowController>()) {
      controller = Get.find<RequestedEscrowController>();
    } else {
      controller = Get.put(RequestedEscrowController());
    }
    
    // Check if data is already loaded from previous screen
    print('RequestedEscrowDetailScreen initState - escrowId: ${widget.escrowId}');
    print('Current escrowAgreementDetail length: ${controller.escrowAgreementDetail.length}');
    
    // Don't clear data immediately, just fetch if needed
    if (controller.escrowAgreementDetail.isEmpty) {
      print('No data found, fetching escrow agreement details...');
      // Fetch escrow agreement details when screen initializes
      controller.fetchEscrowAgreementDetail(widget.escrowId);
    } else {
      print('Data already loaded, using existing data');
    }
  }

  @override
  void dispose() {
    print('RequestedEscrowDetailScreen: dispose called');
    // Clear data when leaving the screen
    try {
      if (mounted && controller != null) {
        controller.clearData();
      }
    } catch (e) {
      print('RequestedEscrowDetailScreen: Error in dispose: $e');
    }
    super.dispose();
  }

  Future<void> _loadEscrowData() async {
    try {
      if (mounted && controller != null) {
        await controller.fetchEscrowAgreementDetail(widget.escrowId);
      }
    } catch (e) {
      print('RequestedEscrowDetailScreen: Error in _loadEscrowData: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
             appBar: CommonHeader(
         title: languageController.getTranslation('requested_escrow_details'),
         managerId: userController.userId.value,
       ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              try {
                await _loadEscrowData();
              } catch (e) {
                print('RequestedEscrowDetailScreen: Error in refresh: $e');
              }
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
                                                         Text(
                               controller.escrowAgreementDetail.isNotEmpty 
                                 ? (controller.escrowAgreementDetail.first.title ?? languageController.getTranslation('requested_escrow_details'))
                                 : languageController.getTranslation('requested_escrow_details'),
                               style: TextStyle(
                                 fontWeight: FontWeight.w700,
                                 fontSize: 16,
                                 color: Color(0xff18CE0F),
                                 fontFamily: 'Nunito',
                               ),
                             ).paddingOnly(top: 10),
                                                                                      Divider(color: Color(0xffDDDDDD)),
                             
                              Obx(() => Expanded(
                                 child: controller.isLoadingAgreementDetail.value
                                   ? Center(
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
                                     )
                                   : controller.escrowAgreementDetail.isEmpty
                                     ? Center(
                                         child: Column(
                                           mainAxisAlignment: MainAxisAlignment.center,
                                           children: [
                                             Text(
                                               languageController.getTranslation('no_details_available'),
                                               style: TextStyle(fontSize: 16),
                                             ),
                                             SizedBox(height: 16),
                                             ElevatedButton(
                                               onPressed: () => _loadEscrowData(),
                                               child: Text('Retry'),
                                             ),
                                           ],
                                         ),
                                       )
                                     : SingleChildScrollView(
                                         child: Padding(
                                           padding: const EdgeInsets.all(16.0),
                                           child: Column(
                                             crossAxisAlignment: CrossAxisAlignment.start,
                                             children: [
                                               // Display the requested fields
                                               // Holding Period
                                               if (controller.escrowAgreementDetail.first.holdingPeriod != null &&
                                                   controller.escrowAgreementDetail.first.holdingPeriod!.isNotEmpty)
                                                 _buildDetailRow(
                                                   languageController.getTranslation('holding_period'),
                                                   controller.escrowAgreementDetail.first.holdingPeriod!
                                                 ),
                                               
                                               // Created At
                                               _buildDetailRow(
                                                 languageController.getTranslation('created_at'),
                                                 controller.escrowAgreementDetail.first.createdAt.isNotEmpty ?
                                                 controller.escrowAgreementDetail.first.createdAt :
                                                 'N/A'
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
                                               
                                               // Method
                                               if (controller.escrowAgreementDetail.first.method != null)
                                                 _buildDetailRow(
                                                   languageController.getTranslation('method'), 
                                                   controller.escrowAgreementDetail.first.method!
                                                 ),
                                                                                 
                                               _buildDetailRow(
                                                 languageController.getTranslation('amount'),
                                                 '${controller.escrowAgreementDetail.first.currencySymbol ?? ''} ${controller.escrowAgreementDetail.first.gross}'
                                               ),
                                               
                                               // Action buttons - only show if status is pending
                                               if (controller.escrowAgreementDetail.first.status == 0) ...[
                                                 SizedBox(height: 20),
                                                 // Reject Request button on first row
                                                 SizedBox(
                                                   height: 40,
                                                   width: double.infinity,
                                                   child: CustomButton(
                                                     text: languageController.getTranslation('reject_request'),
                                                     textStyle: TextStyle(fontSize: 14, color: Colors.white),
                                                     backGroundColor: Colors.red,
                                                     onPressed: () {
                                                       controller.rejectRequest(widget.escrowId);
                                                     },
                                                   ),
                                                 ),
                                                 SizedBox(height: 16),
                                                                                                   // Approve Request button on second row
                                                  SizedBox(
                                                    height: 40,
                                                    width: double.infinity,
                                                    child: CustomButton(
                                                      text: languageController.getTranslation('approve_request'),
                                                      textStyle: TextStyle(fontSize: 14, color: Colors.white),
                                                      backGroundColor: Colors.green,
                                                                                                             onPressed: () async {
                                                         try {
                                                           // First call the confirm_escrow_request API
                                                           await controller.confirmEscrowRequest(widget.escrowId);
                                                           
                                                           // Check if data was loaded successfully
                                                           if (controller.escrowAgreementDetail.isNotEmpty) {
                                                             // Then navigate to confirm escrow request screen
                                                             Get.to(() => ConfirmEscrowRequestScreen(
                                                               escrowId: widget.escrowId,
                                                               escrowTitle: controller.escrowAgreementDetail.first.title,
                                                               escrowAmount: controller.escrowAgreementDetail.first.gross,
                                                               currencySymbol: controller.escrowAgreementDetail.first.currencySymbol ?? '',
                                                             ));
                                                           } else {
                                                             // Show error if no data was loaded
                                                             Get.snackbar(
                                                               languageController.getTranslation('error'),
                                                               'Failed to load escrow details. Please try again.',
                                                               backgroundColor: Colors.red,
                                                               colorText: Colors.white,
                                                               duration: Duration(seconds: 4),
                                                             );
                                                           }
                                                         } catch (e) {
                                                           print('Error in Approve Request button: $e');
                                                           Get.snackbar(
                                                             languageController.getTranslation('error'),
                                                             'An error occurred. Please try again.',
                                                             backgroundColor: Colors.red,
                                                             colorText: Colors.white,
                                                             duration: Duration(seconds: 4),
                                                           );
                                                         }
                                                       },
                                                    ),
                                                  ),
                                               ],
                                               
                                               // Release Request button - only show if status is on hold
                                               if (controller.escrowAgreementDetail.first.status == 3) ...[
                                                 SizedBox(height: 20),
                                                 SizedBox(
                                                   height: 40,
                                                   width: double.infinity,
                                                   child: Obx(() => CustomButton(
                                                     text: controller.isReleasing.value 
                                                       ? '' 
                                                       : languageController.getTranslation('release_request'),
                                                     textStyle: TextStyle(fontSize: 14, color: Colors.white),
                                                     backGroundColor: Colors.blue,
                                                     loading: controller.isReleasing.value,
                                                     onPressed: () async {
                                                       if (!controller.isReleasing.value) {
                                                         try {
                                                           await controller.releaseRequest(widget.escrowId);
                                                           if (controller.isReleaseSuccessful.value) {
                                                             // Refresh the data after successful release
                                                             await controller.fetchEscrowAgreementDetail(widget.escrowId);
                                                           }
                                                         } catch (e) {
                                                           print('Error releasing request: $e');
                                                         }
                                                       }
                                                     },
                                                   )),
                                                 ),
                                               ],
                                               
                                               // Confirmation buttons
                                               SizedBox(height: 20),
                                                                                          ],
                                            ),
                                          ),
                                        ),
                                )),
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
              overflow: TextOverflow.visible,
              softWrap: true,
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

  // Helper method to get category display text based on language
  String _getCategoryDisplayText(EscrowAgreementDetail agreementDetails) {
    final currentLanguage = languageController.selectedLanguage.value;
    final displayCategory = currentLanguage == 'fr' && agreementDetails.categoryFrTitle != null
        ? agreementDetails.categoryFrTitle!
        : (agreementDetails.categoryName ?? 'N/A');
    
    print('Category Display Debug - Language: $currentLanguage, Title: ${agreementDetails.categoryName}, FR: ${agreementDetails.categoryFrTitle}, Display: $displayCategory');
    
    return displayCategory;
  }
}

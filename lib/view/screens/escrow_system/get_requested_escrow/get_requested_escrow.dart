import 'package:escrowcorner/view/screens/escrow_system/get_requested_escrow/requested_escrow_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../../widgets/custom_button/custom_button.dart';
import '../../../../widgets/common_header/common_header.dart';
import '../../user_profile/user_profile_controller.dart';
import 'requested_escrow_detail.dart';
import 'requested_escrow_information.dart';

import 'confirm_escrow_request.dart';
import '../../../../view/controller/language_controller.dart';


class GetRequestedEscrow extends StatefulWidget {
  const GetRequestedEscrow({super.key});

  @override
  State<GetRequestedEscrow> createState() => _GetRequestedEscrowState();
}

class _GetRequestedEscrowState extends State<GetRequestedEscrow> {
  late final RequestedEscrowController controller;
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
  final UserProfileController userProfileController = Get.find<UserProfileController>();
  final LanguageController languageController = Get.find<LanguageController>();

  @override
  void initState() {
    super.initState();
    print('GetRequestedEscrow initState called');
    
    // Initialize controller
    controller = Get.put(RequestedEscrowController());
    
    // Refresh data when screen is accessed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('Post frame callback - refreshing data');
      controller.refreshData();
    });
  }

  @override
  void dispose() {
    print('GetRequestedEscrow: dispose called');
    // Clear data when leaving the screen
    try {
      if (mounted && controller != null) {
        controller.clearData();
      }
    } catch (e) {
      print('GetRequestedEscrow: Error in dispose: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: languageController.getTranslation('requested_escrows'),
        managerId: userProfileController.userId.value,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              print('Pull to refresh triggered');
              await controller.clearAndRefresh();
            },
            child: ListView(
              children: [
                Column(
                  children: [
                    // Requested escrow title section
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 28),
                        child: Text(
                          languageController.getTranslation('requested_escrow'),
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
                      } else if (controller.requestEscrows.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                languageController.getTranslation('no_requested_escrows_available'),
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.75,
                          child: ListView.builder(
                            padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 100),
                            itemCount: controller.requestEscrows.length,
                            itemBuilder: (context, index) {
                              final requestEscrow = controller.requestEscrows[index];
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
                                        formatter.format(requestEscrow.createdAt),
                                      ),
                                      SizedBox(height: 8),
                                      
                                      _buildFieldRow(
                                        languageController.getTranslation('amount'),
                                        '${double.tryParse(requestEscrow.gross.toString())?.toStringAsFixed(3) ?? '0.000'} ${requestEscrow.currencySymbol ?? ''}',
                                        valueColor: Color(0xff18CE0F),
                                      ),
                                      SizedBox(height: 8),
                                      
                                      _buildFieldRow(
                                        languageController.getTranslation('status'),
                                        _getTranslatedStatus(requestEscrow.statusLabel.toString()),
                                        valueColor: _getStatusColor(requestEscrow.statusLabel.toString()),
                                      ),
                                      SizedBox(height: 8),
                                      
                                      _buildFieldRow(
                                        languageController.getTranslation('from'),
                                        requestEscrow.userId.toString(),
                                      ),
                                      SizedBox(height: 8),
                                      
                                      _buildFieldRow(
                                        languageController.getTranslation('to'),
                                        requestEscrow.to.toString(),
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
                                                onPressed: () {
                                                  // Navigate first, then fetch data
                                                  Get.to(() => RequestedEscrowDetailScreen(escrowId: requestEscrow.id));
                                                  
                                                  // Fetch data after navigation is complete
                                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                                    if (mounted) {
                                                      controller.fetchEscrowAgreementDetail(requestEscrow.id);
                                                    }
                                                  });
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
                                                onPressed: () {
                                                  // Navigate to information screen
                                                  Get.to(() => RequestedEscrowInformationScreen(escrowId: requestEscrow.id));
                                                },
                                              ).paddingSymmetric(horizontal: 8),
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      SizedBox(height: 20),
                                      
                                      // Reject and Approve buttons on same line below - only show if status is pending
                                      if (requestEscrow.statusLabel.toString().toLowerCase() == 'pending')
                                        Row(
                                          children: [
                                            // Reject Request button
                                            Expanded(
                                              flex: 1,
                                              child: SizedBox(
                                                height: 35,
                                                child: Obx(() => CustomButton(
                                                  text: controller.isRejecting.value 
                                                    ? languageController.getTranslation('rejecting') 
                                                    : languageController.getTranslation('reject'),
                                                  textStyle: TextStyle(fontSize: 14, color: Colors.white),
                                                  backGroundColor: Colors.red,
                                                  onPressed: () {
                                                    // Don't allow action if already processing
                                                    if (controller.isRejecting.value) return;
                                                    
                                                    // Show confirmation dialog
                                                    showDialog<bool>(
                                                      context: context,
                                                      barrierDismissible: false, // Prevent closing by tapping outside
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          title: Text(languageController.getTranslation('confirm_rejection')),
                                                          content: Text(languageController.getTranslation('are_you_sure_to_reject_escrow')),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: controller.isRejecting.value ? null : () => Navigator.of(context).pop(false),
                                                              child: Text(languageController.getTranslation('cancel')),
                                                            ),
                                                            Obx(() => TextButton(
                                                              onPressed: controller.isRejecting.value ? null : () async {
                                                                // Call reject API
                                                                await controller.rejectRequest(requestEscrow.id);
                                                                // Close dialog after API call
                                                                Navigator.of(context).pop(true);
                                                                // Refresh the list after rejection
                                                                await controller.fetchRequestedEscrows();
                                                              },
                                                              child: controller.isRejecting.value
                                                                ? Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      SizedBox(
                                                                        width: 16,
                                                                        height: 16,
                                                                        child: CircularProgressIndicator(
                                                                          strokeWidth: 2,
                                                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                                                        ),
                                                                      ),
                                                                      SizedBox(width: 8),
                                                                      Text(
                                                                        languageController.getTranslation('rejecting'),
                                                                        style: TextStyle(color: Colors.red),
                                                                      ),
                                                                    ],
                                                                  )
                                                                : Text(
                                                                    languageController.getTranslation('reject'),
                                                                    style: TextStyle(color: Colors.red),
                                                                  ),
                                                            )),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                )),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            // Approve Request button
                                            Expanded(
                                              flex: 1,
                                              child: SizedBox(
                                                height: 35,
                                                child: Obx(() => CustomButton(
                                                  text: controller.isApproving.value 
                                                    ? languageController.getTranslation('approving') 
                                                    : languageController.getTranslation('approve'),
                                                  textStyle: TextStyle(fontSize: 14, color: Colors.white),
                                                  backGroundColor: Colors.green,
                                                                                                     onPressed: () async {
                                                     // Don't allow action if already processing
                                                     if (controller.isApproving.value) return;
                                                     
                                                     try {
                                                       // First call the confirm_escrow_request API
                                                       await controller.confirmEscrowRequest(requestEscrow.id);

                                                       // Check if data was loaded successfully
                                                       if (controller.escrowAgreementDetail.isNotEmpty) {
                                                         // Then navigate to confirm escrow request screen
                                                         Get.to(() => ConfirmEscrowRequestScreen(
                                                           escrowId: requestEscrow.id,
                                                           escrowTitle: requestEscrow.title,
                                                           escrowAmount: requestEscrow.gross,
                                                           currencySymbol: requestEscrow.currencySymbol ?? '',
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
                                                       print('Error in Approve button: $e');
                                                       Get.snackbar(
                                                         languageController.getTranslation('error'),
                                                         'An error occurred. Please try again.',
                                                         backgroundColor: Colors.red,
                                                         colorText: Colors.white,
                                                         duration: Duration(seconds: 4),
                                                       );
                                                     }
                                                   },
                                                )),
                                              ),
                                            ),
                                          ],
                                        ),
                                      
                                      // Release Request button - only show if status is on hold
                                      if (requestEscrow.statusLabel.toString().toLowerCase() == 'on hold')
                                        Padding(
                                          padding: EdgeInsets.only(top: 15),
                                          child: SizedBox(
                                            width: double.infinity,
                                            height: 35,
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
                                                    await controller.releaseRequest(requestEscrow.id);
                                                    if (controller.isReleaseSuccessful.value) {
                                                      // Refresh the data after successful release
                                                      await controller.fetchRequestedEscrows();
                                                    }
                                                  } catch (e) {
                                                    print('Error releasing request: $e');
                                                  }
                                                }
                                              },
                                            )),
                                          ),
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

import 'dart:io';
import 'package:escrowcorner/view/screens/escrow_system/send_escrow/send_escrow_controller.dart';
import 'package:escrowcorner/view/screens/escrow_system/models/escrow_models.dart';
import 'package:escrowcorner/view/screens/user_profile/user_profile_controller.dart';
import 'package:escrowcorner/view/controller/language_controller.dart';
import 'package:escrowcorner/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:escrowcorner/widgets/common_header/common_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../widgets/custom_button/damaspay_button.dart';
import '../../../theme/damaspay_theme/Damaspay_theme.dart';

class SendEscrowDetailScreen extends StatefulWidget {
  final int escrowId;

  SendEscrowDetailScreen({required this.escrowId});

  @override
  _SendEscrowDetailScreenState createState() => _SendEscrowDetailScreenState();
}

class _SendEscrowDetailScreenState extends State<SendEscrowDetailScreen> {
  final SendEscrowsController controller = Get.put(SendEscrowsController());
  final UserProfileController userController = Get.put(UserProfileController());
  final LanguageController languageController = Get.find<LanguageController>();
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
  
  // Loading state for release payment button
  bool _isReleasingPayment = false;

  @override
  void initState() {
    super.initState();
    // Fetch escrow details when screen initializes
    controller.fetchEscrowDetail(widget.escrowId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: languageController.getTranslation('escrow_detail'),
        managerId: userController.userId.value,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await controller.fetchEscrowDetail(widget.escrowId);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              // Ensures the RefreshIndicator works
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
                                final escrowDetails = controller.escrowDetail.first;
                                return Text(
                                  escrowDetails.title ?? languageController.getTranslation('escrow_detail'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Color(0xff18CE0F),
                                    fontFamily: 'Nunito',
                                  ),
                                ).paddingOnly(top: 10);
                              } else {
                                return Text(
                                  languageController.getTranslation('escrow_detail'),
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
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              } else if (controller.escrowDetail.isEmpty) {
                                return Expanded(
                                  child: Center(
                                    child: Text(languageController.getTranslation('no_details_available')),
                                  ),
                                );
                              } else {
                                final escrowDetails = controller.escrowDetail.first;
                                
                                return Expanded(
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Display category title if available
                                          if (escrowDetails.escrowCategory != null)
                                            _buildDetailRow(
                                              languageController.getTranslation('category'), 
                                              _getCategoryTitle(escrowDetails.escrowCategory!, languageController.getCurrentLanguageLocale())
                                            ),
                                          _buildDetailRow(languageController.getTranslation('holding_period'), '${escrowDetails.escrows_hpd.toString()} ${languageController.getTranslation('days')}'),
                                          _buildDetailRow(languageController.getTranslation('created_at'), escrowDetails.createdAt ?? 'N/A'),
                                          _buildDetailRow(languageController.getTranslation('sender_email'), escrowDetails.senderEmail ?? 'N/A'),
                                          _buildDetailRow(languageController.getTranslation('receiver_email'), escrowDetails.receiverEmail ?? 'N/A'),
                                          _buildDetailRow(languageController.getTranslation('status'), escrowDetails.statusLabel.toString()),
                                          _buildDetailRow(languageController.getTranslation('method'), escrowDetails.paymentMethodName ?? 'N/A'),
                                          _buildDetailRow(languageController.getTranslation('gross'), '${escrowDetails.currencySymbol} ${escrowDetails.gross}'),
                                          _buildDetailRow(languageController.getTranslation('fee'), '${escrowDetails.currencySymbol} ${escrowDetails.fee}'),
                                          _buildDetailRow(languageController.getTranslation('net'), '${escrowDetails.currencySymbol} ${escrowDetails.net}'),
                                          
                                          // Add Release Payment button centered below Net amount (conditional)
                                          if (escrowDetails.senderEmail == userController.email.value &&
                                              escrowDetails.statusLabel == "On Hold" &&
                                              escrowDetails.attachment != null &&
                                              escrowDetails.attachment!.isNotEmpty)
                                            Center(
                                              child: Container(
                                                margin: const EdgeInsets.only(top: 25.0, bottom: 10.0),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(12.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.green.withOpacity(0.3),
                                                      spreadRadius: 2,
                                                      blurRadius: 8,
                                                      offset: Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: Material(
                                                  elevation: 0,
                                                  borderRadius: BorderRadius.circular(12.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Color(0xFF4CAF50), // Green gradient start
                                                          Color(0xFF45A049), // Green gradient end
                                                        ],
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                      ),
                                                      borderRadius: BorderRadius.circular(12.0),
                                                      border: Border.all(
                                                        color: Color(0xFF2E7D32).withOpacity(0.3),
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                    child: ElevatedButton(
                                                      onPressed: _isReleasingPayment ? null : () async {
                                                        print("=== RELEASE PAYMENT BUTTON CLICKED ===");
                                                        print("Escrow ID: ${escrowDetails.id}");
                                                        
                                                        // Set loading state
                                                        setState(() {
                                                          _isReleasingPayment = true;
                                                        });
                                                        
                                                        try {
                                                          final result = await controller.escrowRelease('${escrowDetails.id}');
                                                          
                                                          if (result != null && result['status'] == 'success') {
                                                            // Show success message
                                                            Get.snackbar(
                                                              languageController.getTranslation('success'),
                                                              result['message'] ?? languageController.getTranslation('escrow_release_successful'),
                                                              snackPosition: SnackPosition.BOTTOM,
                                                              backgroundColor: Colors.green,
                                                              colorText: Colors.white,
                                                            );
                                                            
                                                            // Refresh the screen data
                                                            await controller.fetchEscrowDetail(widget.escrowId);
                                                            
                                                            // Navigate back to the list screen and refresh it
                                                            Get.back();
                                                            
                                                            // Refresh the parent list screen
                                                            final listController = Get.find<SendEscrowsController>();
                                                            await listController.fetchSendEscrows();
                                                          } else {
                                                            // Show error message
                                                            Get.snackbar(
                                                              languageController.getTranslation('error'),
                                                              result?['message'] ?? languageController.getTranslation('failed_to_release_escrow'),
                                                              snackPosition: SnackPosition.BOTTOM,
                                                              backgroundColor: Colors.red,
                                                              colorText: Colors.white,
                                                            );
                                                            
                                                            // Refresh the screen data even on error
                                                            await controller.fetchEscrowDetail(widget.escrowId);
                                                          }
                                                        } catch (e) {
                                                          print("Error in release payment process: $e");
                                                          // Show error message
                                                          Get.snackbar(
                                                            languageController.getTranslation('error'),
                                                            languageController.getTranslation('an_error_occurred'),
                                                            snackPosition: SnackPosition.BOTTOM,
                                                            backgroundColor: Colors.red,
                                                            colorText: Colors.white,
                                                          );
                                                          
                                                          // Refresh the screen data even on exception
                                                          await controller.fetchEscrowDetail(widget.escrowId);
                                                        } finally {
                                                          // Reset loading state
                                                          if (mounted) {
                                                            setState(() {
                                                              _isReleasingPayment = false;
                                                            });
                                                          }
                                                        }
                                                        
                                                        print("=== RELEASE PAYMENT PROCESS COMPLETED ===");
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.transparent,
                                                        shadowColor: Colors.transparent,
                                                        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(12.0),
                                                        ),
                                                      ),
                                                      child: _isReleasingPayment
                                                          ? Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                SizedBox(
                                                                  width: 20.0,
                                                                  height: 20.0,
                                                                  child: CircularProgressIndicator(
                                                                    strokeWidth: 2.0,
                                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                                  ),
                                                                ),
                                                                SizedBox(width: 12.0),
                                                                Text(
                                                                  languageController.getTranslation('releasing') ?? 'Releasing...',
                                                                  style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: 16.0,
                                                                    fontWeight: FontWeight.w600,
                                                                    fontFamily: 'Nunito',
                                                                    letterSpacing: 0.5,
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          : Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Icon(
                                                                  Icons.payment,
                                                                  color: Colors.white,
                                                                  size: 20.0,
                                                                ),
                                                                SizedBox(width: 8.0),
                                                                Text(
                                                                  languageController.getTranslation('release_payment'),
                                                                  style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: 16.0,
                                                                    fontWeight: FontWeight.w600,
                                                                    fontFamily: 'Nunito',
                                                                    letterSpacing: 0.5,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          
                                          // Go Back Button - always visible
                                          Center(
                                            child: Container(
                                              margin: const EdgeInsets.only(top: 15.0, bottom: 20.0),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.withOpacity(0.2),
                                                    spreadRadius: 1,
                                                    blurRadius: 6,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Material(
                                                elevation: 0,
                                                borderRadius: BorderRadius.circular(12.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Color(0xFF6C757D), // Grey gradient start
                                                        Color(0xFF5A6268), // Grey gradient end
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                    ),
                                                    borderRadius: BorderRadius.circular(12.0),
                                                    border: Border.all(
                                                      color: Color(0xFF495057).withOpacity(0.3),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  child: ElevatedButton(
                                                    onPressed: () async {
                                                      print("=== GO BACK BUTTON CLICKED ===");
                                                      
                                                      try {
                                                        // Refresh the current screen data first
                                                        print("Refreshing escrow detail data...");
                                                        await controller.fetchEscrowDetail(widget.escrowId);
                                                        print("Escrow detail data refreshed successfully");
                                                        
                                                        // Clear and force refresh the send escrow list data
                                                        print("Clearing and force refreshing send escrow list...");
                                                        final listController = Get.find<SendEscrowsController>();
                                                        listController.clearData(); // Clear existing data first
                                                        await listController.fetchSendEscrows(forceRefresh: true);
                                                        print("Send escrow list cleared and force refreshed successfully");
                                                        
                                                        // Navigate back to send_escrow_list with refresh result
                                                        Get.back(result: 'refresh');
                                                        
                                                      } catch (e) {
                                                        print("Error refreshing data: $e");
                                                        // Still navigate back even if refresh fails
                                                        Get.back(result: 'refresh');
                                                      }
                                                      
                                                      print("=== GO BACK PROCESS COMPLETED ===");
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.transparent,
                                                      shadowColor: Colors.transparent,
                                                      padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12.0),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.arrow_back,
                                                          color: Colors.white,
                                                          size: 20.0,
                                                        ),
                                                        SizedBox(width: 8.0),
                                                        Text(
                                                          languageController.getTranslation('go_back'),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16.0,
                                                            fontWeight: FontWeight.w600,
                                                            fontFamily: 'Nunito',
                                                            letterSpacing: 0.5,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }),
                            // Reject Payment button for non-sender users
                            Obx(() {
                              final currentUserEmail = userController.email.value;
                              final escrowDetails = controller.escrowDetail.isNotEmpty
                                  ? controller.escrowDetail.first
                                  : null;
                              if (escrowDetails != null) {
                                // Check if the current user is NOT the sender
                                if (escrowDetails.senderEmail != currentUserEmail &&
                                    escrowDetails.statusLabel == "On Hold") {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(escrowDetails.description ?? ''),
                                      ),
                                      Center(
                                        child: FFButtonWidget(
                                          text: languageController.getTranslation('reject_payment'),
                                          onPressed: () async {
                                            print("=== REJECT BUTTON CLICKED ===");
                                            print("Escrow ID: ${escrowDetails.id}");
                                            print("Widget Escrow ID: ${widget.escrowId}");
                                            
                                            try {
                                              // Call the reject API
                                              print("Calling escrowReject API...");
                                              await controller.escrowReject('${escrowDetails.id}');
                                              print("escrowReject API completed");
                                              
                                              // Explicitly refresh the detail screen to ensure UI updates
                                              print("Calling fetchEscrowDetail to refresh...");
                                              await controller.fetchEscrowDetail(widget.escrowId);
                                              print("fetchEscrowDetail completed");
                                              
                                              print("=== REJECT PROCESS COMPLETED ===");
                                            } catch (e) {
                                              print("Error in reject process: $e");
                                              // Still try to refresh even if there's an error
                                              await controller.fetchEscrowDetail(widget.escrowId);
                                            }
                                          },
                                          options: FFButtonOptions(
                                            width: 170,
                                            height: 45.0,
                                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                            iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                            color: Colors.red,
                                            // Red color for reject button
                                            textStyle: DamaspayTheme.of(context).titleSmall.override(
                                              fontFamily: 'Poppins',
                                              color: Colors.white,
                                            ),
                                            elevation: 2.0,
                                            borderSide: BorderSide(
                                              color: Colors.transparent,
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.circular(5.0),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              }
                              return SizedBox.shrink(); // Return an empty widget if the condition is not met.
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

  Widget _buildDetailRow(
    String label,
    String? value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          Expanded(
            child: controller.isLoading.value
                ? Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: double.infinity,
                      height: 16,
                      color: Colors.grey,
                    ),
                  )
                : Text(
                    value ?? 'N/A',
                    style: TextStyle(color: Colors.black),
                    overflow: TextOverflow.ellipsis, // Handle long text gracefully
                  ),
          ),
        ],
      ),
    );
  }

  // Helper method to get category title in the appropriate language
  String _getCategoryTitle(EscrowCategory category, String locale) {
    return category.getLocalizedTitle(locale);
  }

  void downloadFile(String filePath) async {
    try {
      // Extract file name and extension
      var fileName = basename(filePath); // Get the file name with extension
      // var fileExtension = extension(fileName); // Get the file extension

      // Generate the local file path based on the file extension
      var path = "/storage/emulated/0/Download/$fileName"; // Save with original file name and extension
      var file = File(path);

      // Get the file content from the URL
      var res = await get(Uri.parse(filePath));

      if (res.statusCode == 200) {
        // Write the content to the file
        await file.writeAsBytes(res.bodyBytes);

        print('File downloaded to $path');
        Get.snackbar(
          languageController.getTranslation('message'),
          languageController.getTranslation('file_download'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        print('Failed to download file. Status code: ${res.statusCode}');
        Get.snackbar(
          languageController.getTranslation('message'),
          languageController.getTranslation('file_not_download'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error downloading file: $e');
      Get.snackbar(
        languageController.getTranslation('message'),
        languageController.getTranslation('error_downloading_file'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

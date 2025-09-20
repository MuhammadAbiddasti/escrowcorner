import 'dart:io';
import 'dart:convert';
import 'package:escrowcorner/view/screens/escrow_system/request_escrow/request_escrow_controller.dart';
import 'package:escrowcorner/view/screens/escrow_system/request_escrow/request_escrow.dart';

import 'package:escrowcorner/view/screens/user_profile/user_profile_controller.dart';
import 'package:escrowcorner/view/controller/language_controller.dart';
import 'package:escrowcorner/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:escrowcorner/widgets/common_header/common_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:shimmer/shimmer.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../widgets/custom_button/damaspay_button.dart';
import '../../../theme/damaspay_theme/Damaspay_theme.dart';

class InformationEscrowRequestScreen extends StatefulWidget {
  final int escrowId;

  InformationEscrowRequestScreen({required this.escrowId});

  @override
  _InformationEscrowRequestScreenState createState() => _InformationEscrowRequestScreenState();
}

class _InformationEscrowRequestScreenState extends State<InformationEscrowRequestScreen> {
  late final RequestEscrowController controller;
  final UserProfileController userController = Get.put(UserProfileController());
  final LanguageController languageController = Get.find<LanguageController>();
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    
    // Get existing controller or create new one if needed
    if (Get.isRegistered<RequestEscrowController>()) {
      controller = Get.find<RequestEscrowController>();
      print("Found existing controller: ${controller.hashCode}");
    } else {
      controller = Get.put(RequestEscrowController());
      print("Created new controller: ${controller.hashCode}");
    }
    
    print("=== InformationEscrowRequestScreen initState ===");
    print("Escrow ID: ${widget.escrowId}");
    print("Controller instance: ${controller.hashCode}");
    print("Current escrowInfoDetail length: ${controller.escrowInfoDetail.length}");
    
    // Data should already be fetched from the information button click
    // Only fetch if no data is available
    if (controller.escrowInfoDetail.isEmpty) {
      print("No data available, fetching escrow information details");
      controller.fetchRequestEscrowDetailForInfo(widget.escrowId);
    } else {
      print("Data already available, no need to fetch again");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: languageController.getTranslation('escrow_information'),
        managerId: userController.userId.value,
      ),
      body: Stack(children: [
        RefreshIndicator(
            onRefresh: () async {
              await controller.fetchRequestEscrowDetailForInfo(widget.escrowId);
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
                             height: MediaQuery.of(context).size.height * 0.85,
                             width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xffFFFFFF),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(() {
                                  if (controller.escrowInfoDetail.isNotEmpty) {
                                    final escrowInfo = controller.escrowInfoDetail.first;
                                    return Text(
                                      escrowInfo.title ?? languageController.getTranslation('escrow_information'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Color(0xff18CE0F),
                                        fontFamily: 'Nunito',
                                      ),
                                    ).paddingOnly(top: 10);
                                  } else {
                                    return Text(
                                      languageController.getTranslation('escrow_information'),
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
                                   print("=== Information Screen Obx Build ===");
                                   print("isLoading: ${controller.isLoading.value}");
                                   print("escrowInfoDetail length: ${controller.escrowInfoDetail.length}");
                                  
                                  if (controller.isLoading.value) {
                                    print("Showing loading indicator");
                                    return Expanded(
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(),
                                            SizedBox(height: 16),
                                            Text("Loading escrow information..."),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else if (controller.escrowInfoDetail.isEmpty) {
                                    print("No data available, showing empty state");
                                    return Expanded(
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(languageController.getTranslation('no_information_available')),
                                            SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: () {
                                                print("Manual refresh button clicked");
                                                controller.fetchRequestEscrowDetailForInfo(widget.escrowId);
                                              },
                                              child: Text("Refresh"),
                                            ),
                                            SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: () {
                                                print("Debug: Check current state");
                                                controller.checkCurrentState();
                                              },
                                              child: Text("Debug State"),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    final escrowInfo = controller.escrowInfoDetail.first;
                                    print("Data found, building content");
                                    
                                    // Debug prints to verify data
                                    print("=== Information Screen Debug ===");
                                    print("Title: ${escrowInfo.title}");
                                    print("Gross: ${escrowInfo.gross}");
                                    print("Status: ${escrowInfo.statusLabel}");
                                    print("Holding Period: ${escrowInfo.escrows_hpd}");
                                    print("Category: ${escrowInfo.categoryName}");
                                    print("Payment Method: ${escrowInfo.paymentMethodName}");
                                    print("Fee: ${escrowInfo.fee}");
                                    print("Net: ${escrowInfo.net}");
                                    print("================================");
                                    
                                    return Expanded(
                                      child: SingleChildScrollView(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                                                             // Display available information
                                               _buildInfoRow(languageController.getTranslation('holding_period'), '${escrowInfo.escrows_hpd} ${languageController.getTranslation('days')}'),
                                               if (escrowInfo.categoryName != null)
                                                 _buildInfoRow(languageController.getTranslation('category'), escrowInfo.categoryName!),
                                               _buildInfoRow(languageController.getTranslation('created_at'), escrowInfo.createdAt != null ? formatter.format(escrowInfo.createdAt!) : 'N/A'),
                                               _buildInfoRow(languageController.getTranslation('sender_email'), escrowInfo.senderEmail ?? 'N/A'),
                                               _buildInfoRow(languageController.getTranslation('receiver_email'), escrowInfo.receiverEmail ?? 'N/A'),
                                               _buildInfoRow(languageController.getTranslation('status'), escrowInfo.statusLabel.toString()),
                                               if (escrowInfo.paymentMethodName != null)
                                                 _buildInfoRow(languageController.getTranslation('payment_method'), escrowInfo.paymentMethodName!),
                                               _buildInfoRow(languageController.getTranslation('amount'), '${escrowInfo.currencySymbol ?? ''} ${escrowInfo.gross}'),

                                              
                                              // Product Photos or Information section
                                              if (escrowInfo.attachment != null && escrowInfo.attachment!.isNotEmpty)
                                                _buildAttachmentsSection(escrowInfo.attachment!),
                                              if (escrowInfo.description.isNotEmpty)
                                                _buildDescriptionRow(languageController.getTranslation('description'), escrowInfo.description),
                                                
                                              // Go Back button
                                              SizedBox(height: 20),
                                              SizedBox(
                                                height: 40,
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    // Navigate back to request_escrow screen
                                                    Get.off(() => GetRequestEscrow());
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.grey[200],
                                                    foregroundColor: Colors.grey[700],
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    languageController.getTranslation('go_back'),
                                                    style: TextStyle(fontSize: 14),
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
                              ],
                            ).paddingSymmetric(horizontal: 15),
                          ).paddingOnly(top: 30, bottom: 80),
                        ),
                      ]),
                ])),
        Align(
          alignment: Alignment.bottomCenter,
          child: CustomBottomContainerPostLogin().paddingOnly(top: 60),
        )
      ]),
    );
  }

  Widget _buildInfoRow(
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
                    overflow: TextOverflow.visible,
                    softWrap: true,
                  ),
          ),
        ],
      ),
    );
  }

  // Special method for description field with vertical layout
  Widget _buildDescriptionRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          controller.isLoading.value
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
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
        ],
      ),
    );
  }



  // Build attachments section with download functionality
  Widget _buildAttachmentsSection(String attachment) {
    try {
      // Parse the attachment string (it's a JSON array string)
      final List<dynamic> attachments = jsonDecode(attachment);
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              languageController.getTranslation('product_photos_or_information'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          ...attachments.map((attachmentUrl) => _buildAttachmentItem(attachmentUrl.toString())).toList(),
        ],
      );
    } catch (e) {
      print('Error parsing attachments: $e');
      return SizedBox.shrink();
    }
  }

  // Build individual attachment item with download button
  Widget _buildAttachmentItem(String attachmentUrl) {
    final fileName = attachmentUrl.split('/').last;
    final fullUrl = 'https://escrowcorner.com/$attachmentUrl'; // Base URL + attachment path
    
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () => _downloadFile(fullUrl, fileName),
            icon: Icon(Icons.download, size: 18),
            label: Text(languageController.getTranslation('download_attachment')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Download file functionality
  Future<void> _downloadFile(String url, String fileName) async {
    try {
      // Show loading indicator
      Get.dialog(
        Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Download the file
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        // Get the downloads directory
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        
        // Write the file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        // Close loading dialog
        Get.back();
        
        // Show success message
        Get.snackbar(
          languageController.getTranslation('download_successful'),
          languageController.getTranslation('file_downloaded_to_device').replaceAll('{fileName}', fileName),
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        
        print('File downloaded successfully to: $filePath');
      } else {
        Get.back(); // Close loading dialog
        Get.snackbar(
          languageController.getTranslation('download_failed'),
          languageController.getTranslation('failed_to_download_file')
              .replaceAll('{fileName}', fileName)
              .replaceAll('{status}', response.statusCode.toString()),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        languageController.getTranslation('download_error'),
        languageController.getTranslation('error_downloading_file')
            .replaceAll('{fileName}', fileName)
            .replaceAll('{error}', e.toString()),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error downloading file: $e');
    }
  }
}

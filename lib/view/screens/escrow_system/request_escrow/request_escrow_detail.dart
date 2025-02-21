import 'dart:io';

import 'package:dacotech/view/screens/escrow_system/request_escrow/request_escrow_controller.dart';
import 'package:dacotech/view/screens/user_profile/user_profile_controller.dart';
import 'package:dacotech/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:dacotech/widgets/custom_button/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../../widgets/custom_button/damaspay_button.dart';
import '../../../theme/damaspay_theme/Damaspay_theme.dart';
import '../send_escrow/send_escrow_controller.dart';

class RequestEscrowDetailScreen extends StatelessWidget {
  final int escrowId;

  RequestEscrowDetailScreen({required this.escrowId});

  final RequestEscrowController controller = Get.put(RequestEscrowController());
  final SendEscrowsController sendController = Get.put(SendEscrowsController());
  final UserProfileController userController = Get.put(UserProfileController());
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

  void initState() {
    if (!Get.isRegistered<RequestEscrowController>()) {
      Get.put(RequestEscrowController());
    }
    controller.fetchRequestEscrowDetail(escrowId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: Color(0xff0766AD),
        title: AppBarTitle(),
        leading: CustomPopupMenu(managerId: userController.userId.value,),
        actions: [
          AppBarProfileButton(),
        ],
      ),
      body: Stack(children: [
        RefreshIndicator(
          onRefresh: () async {
            await controller.fetchRequestEscrowDetail(escrowId);
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
                            Text(
                              "Escrow Detail",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Color(0xff18CE0F),
                                fontFamily: 'Nunito',
                              ),
                            ).paddingOnly(top: 10),
                            Divider(color: Color(0xffDDDDDD)),
                            Obx(() {
                              if (controller.isLoading.value) {
                                return Expanded(
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: ListView.builder(
                                      itemCount: 5,
                                      // Placeholder for shimmer loading items
                                      itemBuilder: (context, index) => Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: List.generate(
                                            3,
                                            (_) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: Container(
                                                width: double.infinity,
                                                height: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              } else if (controller.escrowDetail.isEmpty) {
                                return Center(
                                    child: Text("No Details Available"));
                              } else {
                                return Expanded(
                                  child: ListView.builder(
                                    itemCount: controller.escrowDetail.length,
                                    itemBuilder: (context, index) {
                                      final escrowDetails =
                                          controller.escrowDetail[index];
                                      return Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildDetailRow('Holding Period:',
                                                '${escrowDetails.escrows_hpd.toString()} days'),
                                            _buildDetailRow('Sender Email:',
                                                escrowDetails.senderEmail),
                                            _buildDetailRow('Receiver Email:',
                                                escrowDetails.receiverEmail),
                                            _buildDetailRow(
                                                'Status:',
                                                escrowDetails.statusLabel
                                                    .toString()),
                                            _buildDetailRow('Gross:',
                                                '${escrowDetails.currencySymbol} ${double.tryParse(escrowDetails.gross.toString())?.toStringAsFixed(3) ?? '0.000'}'),
                                            _buildDetailRow('Fee:',
                                                '${escrowDetails.currencySymbol} 0.0'),
                                            _buildDetailRow('Net:',
                                                '${escrowDetails.currencySymbol} ${double.tryParse(escrowDetails.gross.toString())?.toStringAsFixed(3) ?? '0.000'}'),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }
                            }),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Agreement |",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black.withOpacity(.80),
                                        fontSize: 18),
                                  ),
                                  TextSpan(
                                    text:
                                        " The agreement between the Buyer and Seller",
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(.40),
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ).paddingOnly(bottom: 15),
                            Obx(() {
                              if (controller.escrowDetail.isNotEmpty) {
                                final escrowDetails =
                                    controller.escrowDetail.first;
                                // Handle the case where there is no data
                                print(
                                    "description:${escrowDetails.description.toString()}");
                                return Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        escrowDetails.description,
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ).paddingOnly(bottom: 10),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: escrowDetails.attachment != null &&
                                              escrowDetails
                                                  .attachment!.isNotEmpty
                                          ? GestureDetector(
                                              onTap: () async {
                                                final fileName =
                                                    escrowDetails.attachment;
                                                if (fileName == null ||
                                                    fileName.isEmpty) {
                                                  print(
                                                      'No attachment available');
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'No attachment available to download')),
                                                  );
                                                  return;
                                                }
                                                downloadFile(fileName);
                                              },
                                              child: Text(
                                                'Download Agreement Document',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            )
                                          : SizedBox(), // Return an empty widget if no attachment is available
                                    ).paddingOnly(bottom: 15),
                                  ],
                                );
                              } else {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Text("No escrow details available"),
                                );
                              }
                            }),
                            Obx(() {
                              final currentUserEmail =
                                  userController.email.value;
                              final escrowDetails =
                                  controller.escrowDetail.isNotEmpty
                                      ? controller.escrowDetail.first
                                      : null;

                              if (escrowDetails == null) {
                                return SizedBox
                                    .shrink(); // No buttons if there are no details
                              }

                              if (escrowDetails.senderEmail ==
                                      currentUserEmail &&
                                  escrowDetails.statusLabel == "Pending") {
                                // Current user is the sender, and status is Pending
                                return Align(
                                  alignment: Alignment.topRight,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(height: 20),
                                      FFButtonWidget(
                                        onPressed: () async {
                                          print(
                                              "Cancel Request ID: ${escrowDetails.id}");
                                          await controller.cancelRequestEscrow(
                                              '${escrowDetails.id}');
                                          await controller
                                              .fetchRequestEscrowDetail(
                                                  escrowId);
                                        },
                                        text: 'Cancel Request',
                                        options: FFButtonOptions(
                                          width: 170,
                                          height: 45.0,
                                          color: DamaspayTheme.of(context)
                                              .secondary,
                                          textStyle: DamaspayTheme.of(context)
                                              .titleSmall
                                              .override(
                                                fontFamily: 'Poppins',
                                                color: Colors.white,
                                              ),
                                          elevation: 2.0,
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  ),
                                );
                              } else if (escrowDetails.senderEmail !=
                                      currentUserEmail &&
                                  escrowDetails.statusLabel == "Pending") {
                                // Current user is not the sender, and status is Pending
                                return Align(
                                  alignment: Alignment.topRight,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      FFButtonWidget(
                                        onPressed: () async {
                                          print(
                                              "Reject Request ID: ${escrowDetails.id}");
                                          await controller.rejectRequestEscrow(
                                              '${escrowDetails.id}');
                                          await controller
                                              .fetchRequestEscrowDetail(
                                                  escrowId);
                                        },
                                        text: 'Reject Request',
                                        options: FFButtonOptions(
                                          width: 170,
                                          height: 45.0,
                                          color: DamaspayTheme.of(context)
                                              .secondary,
                                          textStyle: DamaspayTheme.of(context)
                                              .titleSmall
                                              .override(
                                                fontFamily: 'Poppins',
                                                color: Colors.white,
                                              ),
                                          elevation: 2.0,
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      FFButtonWidget(
                                        onPressed: () async {
                                          print(
                                              "Approve Request ID: ${escrowDetails.id}");
                                          await controller.approveRequestEscrow(
                                              '${escrowDetails.id}');
                                          await controller
                                              .fetchRequestEscrowDetail(
                                                  escrowId);
                                        },
                                        text: 'Approve Request',
                                        options: FFButtonOptions(
                                          width: 170,
                                          height: 45.0,
                                          color:
                                              DamaspayTheme.of(context).primary,
                                          textStyle: DamaspayTheme.of(context)
                                              .titleSmall
                                              .override(
                                                fontFamily: 'Poppins',
                                                color: Colors.white,
                                              ),
                                          elevation: 2.0,
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ),
                                );
                              } else if (escrowDetails.senderEmail !=
                                      currentUserEmail &&
                                  escrowDetails.statusLabel == "On Hold") {
                                // Current user is not the sender, and status is On Hold
                                return Align(
                                  alignment: Alignment.topRight,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(height: 20),
                                      FFButtonWidget(
                                        onPressed: () async {
                                          print(
                                              "Release Payment ID: ${escrowDetails.id}");
                                          await controller.releaseRequestEscrow(
                                              '${escrowDetails.id}');
                                          await controller
                                              .fetchRequestEscrowDetail(
                                                  escrowId);
                                        },
                                        text: 'Release Payment',
                                        options: FFButtonOptions(
                                          width: 170,
                                          height: 45.0,
                                          color:
                                              DamaspayTheme.of(context).primary,
                                          textStyle: DamaspayTheme.of(context)
                                              .titleSmall
                                              .override(
                                                fontFamily: 'Poppins',
                                                color: Colors.white,
                                              ),
                                          elevation: 2.0,
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  ),
                                );
                              } else {
                                // Default case: no buttons
                                return SizedBox.shrink();
                              }
                            }),
                          ],
                        ).paddingSymmetric(horizontal: 15),
                      ).paddingOnly(top: 30, bottom: 30),
                    ),
                  ],
                ),
              ]),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: CustomBottomContainer()
              .paddingOnly(top: MediaQuery.of(context).size.height * .04),
        ),
      ]),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
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
                    overflow:
                        TextOverflow.ellipsis, // Handle long text gracefully
                  ),
          ),
        ],
      ),
    );
  }

  void downloadFile(String filePath) async {
    try {
      var time = DateTime.now().millisecondsSinceEpoch;

      // Extract file name and extension
      var fileName = basename(filePath); // Get the file name with extension
      var fileExtension = extension(fileName); // Get the file extension

      // Generate the local file path based on the file extension
      var path =
          "/storage/emulated/0/Download/$fileName"; // Save with original file name and extension
      var file = File(path);

      // Get the file content from the URL
      var res = await get(Uri.parse(filePath));

      if (res.statusCode == 200) {
        // Write the content to the file
        await file.writeAsBytes(res.bodyBytes);

        print('File downloaded to $path');
        Get.snackbar(
          'Message',
          "File Download",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        print('Failed to download file. Status code: ${res.statusCode}');
        Get.snackbar(
          'Message',
          "File Not Download",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error downloading file: $e');
      Get.snackbar(
        'Message',
        "Error downloading file:, $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../../widgets/common_header/common_header.dart';
import '../../controller/language_controller.dart';
import 'ticket_controller.dart';
import '../user_profile/user_profile_controller.dart';
import 'dart:convert';

class ScreenTicketDetails extends StatefulWidget {
  final String ticketId;
  ScreenTicketDetails({required this.ticketId});

  @override
  State<ScreenTicketDetails> createState() => _ScreenTicketDetailsState();
}

class _ScreenTicketDetailsState extends State<ScreenTicketDetails> {
  final TicketController ticketController = Get.put(TicketController(), permanent: true);
  final UserProfileController userController = Get.find<UserProfileController>();
  final LanguageController languageController = Get.find<LanguageController>();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<TicketController>()) {
      Get.put(TicketController());
    }
    ticketController.fetchTicketDetail(widget.ticketId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: languageController.getTranslation('ticket_details'),
        managerId: userController.userId.value,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ticketController.fetchTicketDetail(widget.ticketId);
              },
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      Obx(() {
                        final details = ticketController.ticketDetails;
                        final isLoading = ticketController.isLoading.value;
                        final createdAt = details['created_at'] ?? 'N/A';
                        final formattedDate = createdAt != 'N/A'
                            ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(createdAt))
                            : 'N/A';

                        return Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xffFFFFFF),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    languageController.getTranslation('ticket_details'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff484848),
                                    ),
                                  ).paddingOnly(top: 10),

                                  // Ticket ID
                                  Row(
                                    children: [
                                      Text(
                                                                                 "${languageController.getTranslation('ticket_id')}:",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xff484848),
                                        ),
                                      ),
                                      isLoading
                                          ? Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[100]!,
                                              child: Container(
                                                height: 15,
                                                width: 50,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(
                                              ' #${details['ticket_id'] ?? 'N/A'} ',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xff484848),
                                              ),
                                            ),
                                    ],
                                  ).paddingOnly(top: 10),
                                  Divider(),
                                  
                                  // Status
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        languageController.getTranslation('status'),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xff484848),
                                        ),
                                      ),
                                      isLoading
                                          ? Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[100]!,
                                              child: Container(
                                                height: 35,
                                                width: 120,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Container(
                                              height: 35,
                                              width: 120,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5),
                                                color: Color(0xff18CE0F),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  _getTranslatedStatus(details['status'] ?? 'N/A'),
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ],
                                  ).paddingOnly(top: 5, bottom: 5),

                                  // Category Name
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        languageController.getTranslation('category'),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xff484848),
                                        ),
                                      ),
                                      isLoading
                                          ? Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[100]!,
                                              child: Container(
                                                height: 15,
                                                width: 150,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(
                                              _getTranslatedCategoryName(details['category']),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xff484848),
                                              ),
                                            ),
                                    ],
                                  ).paddingOnly(top: 5, bottom: 5),

                                  // Created
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        languageController.getTranslation('created'),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xff484848),
                                        ),
                                      ),
                                      isLoading
                                          ? Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[100]!,
                                              child: Container(
                                                height: 15,
                                                width: 150,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(
                                              formattedDate,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xff484848),
                                              ),
                                            ),
                                    ],
                                  ).paddingOnly(top: 5, bottom: 5),
                                  Divider(),

                                  SizedBox(height: 10),
                                ],
                              ).paddingSymmetric(horizontal: 20),
                            ).paddingOnly(top: 20, bottom: 10),
                          ],
                        );
                      }),
                      
                      Obx(() {
                        final replies = ticketController.ticketReplies;
                        final isLoading = ticketController.isLoading.value;

                        return Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Column(
                            children: [
                              if (isLoading)
                                Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    height: 100,
                                    width: double.infinity,
                                    color: Colors.white,
                                  ),
                                )
                              else
                                Column(
                                  children: [
                                    // Existing replies only (no original ticket message)
                                    ...replies.map((reply) {
                                      final replyDate = reply['created_at'] != null
                                          ? DateFormat('MMM dd yyyy hh:mm a').format(DateTime.parse(reply['created_at']))
                                          : 'N/A';
                                      final message = reply['message'] ?? 'No message';
                                      final userName = reply['user_name'] ?? '${userController.firstName} ${userController.lastName}';
                                      final attachments = reply['attachments'];

                                      final containerColor = userName == "Customer Support" ? Colors.blue : Color(0xff18CE0F);

                                      return Container(
                                        width: MediaQuery.of(context).size.width * 0.9,
                                        margin: EdgeInsets.only(bottom: 10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context).size.width * 0.9,
                                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: containerColor,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(5),
                                                  topRight: Radius.circular(5),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                                                                      Flexible(
                                                      child: Text(
                                                        "${languageController.getTranslation('name')}: $userName",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: Colors.white,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                        softWrap: false,
                                                      ),
                                                    ),
                                                  Text(
                                                    replyDate,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: MediaQuery.of(context).size.width * 0.9,
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(color: Colors.grey[300]!),
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft: Radius.circular(5),
                                                  bottomRight: Radius.circular(5),
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Message text
                                                  Text(
                                                    message,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  // Attachments below the message for each reply
                                                  if (attachments != null && attachments.toString().isNotEmpty) ...[
                                                    SizedBox(height: 10),
                                                    _buildTicketAttachments(attachments),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                            ],
                          ),
                        ).paddingOnly(bottom: 20);
                      }),
                      
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Color(0xff18CE0F),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5),
                                ),
                              ),
                              child: Text(
                                                                 languageController.getTranslation('post_reply'),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(5),
                                  bottomRight: Radius.circular(5),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    languageController.getTranslation('message'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff484848),
                                    ),
                                  ).paddingOnly(bottom: 8),
                                  TextField(
                                    controller: ticketController.messageController,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      hintText: languageController.getTranslation('write_your_message'),
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey[500],
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide(color: Color(0xff18CE0F)),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    ),
                                  ).paddingOnly(bottom: 10),
                                  
                                  // Attachment Files Section
                                  Text(
                                    "${languageController.getTranslation('attachment_files')} (${languageController.getTranslation('optional')})",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff484848),
                                    ),
                                  ).paddingOnly(bottom: 8),
                                  
                                  // Selected Files Display
                                  Obx(() {
                                    if (ticketController.selectedFiles.isEmpty) {
                                      return Container();
                                    }
                                    
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: ticketController.selectedFiles.map((file) {
                                          return Container(
                                            margin: EdgeInsets.only(bottom: 5),
                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius: BorderRadius.circular(5),
                                              border: Border.all(color: Colors.grey[300]!),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.attach_file,
                                                  size: 16,
                                                  color: Colors.grey[600],
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    file.path.split('/').last,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[700],
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () => ticketController.removeFile(ticketController.selectedFiles.indexOf(file)),
                                                  icon: Icon(
                                                    Icons.close,
                                                    size: 16,
                                                    color: Colors.red,
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    );
                                  }),
                                  
                                                                     // Add Attachment Button
                                   Obx(() {
                                     final isDisabled = ticketController.selectedFiles.length >= 2;
                                     return InkWell(
                                       onTap: isDisabled ? null : () {
                                         ticketController.showPickerOptions(context);
                                       },
                                       child: Container(
                                         width: double.infinity,
                                         padding: EdgeInsets.symmetric(vertical: 12),
                                         decoration: BoxDecoration(
                                           border: Border.all(color: isDisabled ? Colors.grey[400]! : Colors.grey[300]!),
                                           borderRadius: BorderRadius.circular(5),
                                           color: isDisabled ? Colors.grey[100] : Colors.white,
                                         ),
                                         child: Row(
                                           mainAxisAlignment: MainAxisAlignment.center,
                                           children: [
                                             Icon(
                                               Icons.attach_file,
                                               size: 16,
                                               color: isDisabled ? Colors.grey[400] : Colors.grey[600],
                                             ),
                                             SizedBox(width: 8),
                                             Text(
                                               isDisabled 
                                                 ? languageController.getTranslation('max_files_reached')
                                                 : languageController.getTranslation('add_attachment_files'),
                                               style: TextStyle(
                                                 fontSize: 14,
                                                 color: isDisabled ? Colors.grey[400] : Colors.grey[600],
                                               ),
                                             ),
                                           ],
                                         ),
                                       ),
                                     );
                                   }).paddingOnly(bottom: 10),
                                  FFButtonWidget(
                                    onPressed: ticketController.isSubmittingReply.value 
                                      ? null 
                                      : () async {
                                          await ticketController.postReply(context, widget.ticketId, ticketController.messageController.text);
                                          ticketController.messageController.clear();
                                        },
                                    text: ticketController.isSubmittingReply.value ? languageController.getTranslation('submitting') : languageController.getTranslation('submit'),
                                    options: FFButtonOptions(
                                      width: double.infinity,
                                      height: 40,
                                      color: Color(0xff18CE0F),
                                      textStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                      borderSide: BorderSide(
                                        color: Colors.transparent,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).paddingOnly(bottom: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          CustomBottomContainerPostLogin(),
        ],
      ),
    );
  }

  Widget _buildTicketAttachments(dynamic attachments) {
    if (attachments == null || attachments.toString().isEmpty) {
      return Container();
    }

    try {
      List<String> attachmentList = [];
      
      // Handle different attachment formats
      if (attachments is String) {
        // If it's a JSON string, try to parse it
        if (attachments.startsWith('[') || attachments.startsWith('{')) {
          try {
            var parsed = jsonDecode(attachments);
            if (parsed is List) {
              attachmentList = parsed.cast<String>().toList();
            } else if (parsed is Map) {
              attachmentList = parsed.values.cast<String>().toList();
            }
          } catch (e) {
            // If JSON parsing fails, treat as comma-separated
            attachmentList = attachments.split(',').map((e) => e.trim()).toList();
          }
        } else {
          // Treat as comma-separated string
          attachmentList = attachments.split(',').map((e) => e.trim()).toList();
        }
      } else if (attachments is List) {
        attachmentList = attachments.cast<String>().toList();
      }

      if (attachmentList.isEmpty) {
        return Container();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${languageController.getTranslation('attachments')}:",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xff484848),
            ),
          ).paddingOnly(bottom: 8),
          ...attachmentList.map((attachmentUrl) => _buildAttachmentDownloadLink(attachmentUrl)).toList(),
        ],
      );
    } catch (e) {
      print('Error parsing attachments: $e');
      return Container();
    }
  }

  Widget _buildAttachmentDownloadLink(String attachmentUrl) {
    // Extract filename from URL for display
    String fileName = attachmentUrl.split('/').last;
    
    // Ensure the URL has the base URL prepended
    String fullUrl = attachmentUrl;
    if (!attachmentUrl.startsWith('http')) {
      // If it's a relative path, prepend the base URL from controller
      fullUrl = '${ticketController.apiBaseUrl}/$attachmentUrl';
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // Download attachment
          ticketController.downloadAttachmentFromUrl(fullUrl, fileName);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.blue.shade200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.download,
                size: 16,
                color: Colors.blue.shade600,
              ),
              SizedBox(width: 8),
              Expanded(
                                  child: Text(
                    languageController.getTranslation('download_attachment_files'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTranslatedCategoryName(dynamic category) {
    if (category == null) return 'N/A';
    
    // Check if category is an object with name and fr fields
    if (category is Map) {
      if (languageController.selectedLanguage.value?.locale == 'fr' && category['fr'] != null) {
        return category['fr'];
      } else {
        return category['name'] ?? 'N/A';
      }
    } else {
      // Fallback for old structure
      return category.toString();
    }
  }

  String _getTranslatedStatus(String status) {
    if (status == 'N/A') return 'N/A';
    
    switch (status.toLowerCase()) {
      case 'open':
        return languageController.getTranslation('open');
      case 'closed':
        return languageController.getTranslation('closed');
      case 'pending':
        return languageController.getTranslation('pending');
      case 'in progress':
        return languageController.getTranslation('in_progress');
      default:
        return languageController.getTranslation('unknown') ?? status;
    }
  }
}

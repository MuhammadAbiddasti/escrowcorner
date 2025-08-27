import 'package:escrowcorner/view/screens/tickets/screen_new_ticket.dart';
import 'package:escrowcorner/view/screens/tickets/screen_ticket_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../../widgets/common_header/common_header.dart';
import '../../controller/logo_controller.dart';
import '../managers/manager_permission_controller.dart';
import '../user_profile/user_profile_controller.dart';
import '../../controller/language_controller.dart';
import 'ticket_controller.dart';

class ScreenSupportTicket extends StatefulWidget {
  @override
  _ScreenSupportTicketState createState() => _ScreenSupportTicketState();
}

class _ScreenSupportTicketState extends State<ScreenSupportTicket> {
  final LogoController logoController = Get.put(LogoController());
  final TicketController ticketsController = Get.put(TicketController());
  final UserProfileController userProfileController = Get.find<UserProfileController>();
  final ManagersPermissionController controller = Get.find<ManagersPermissionController>();
  final LanguageController languageController = Get.find<LanguageController>();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ticketsController.fetchTickets();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (!ticketsController.isLoadingMore.value && ticketsController.hasMoreData.value) {
        ticketsController.loadMoreTickets();
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final isManager = userProfileController.isManager.value == '1';
    final isNotManager = userProfileController.isManager.value == '0';
    final allowedModules = controller.modulePermissions;
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: languageController.getTranslation('support_tickets'),
        managerId: userProfileController.userId.value,
      ),
      body: Column(
        children: [
          // Add New Ticket Button Section
          if (isManager &&
              allowedModules.containsKey('Support Ticket') &&
              allowedModules['Support Ticket']!.contains('add_support_ticket'))
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xffFFFFFF),
              ),
              child: Column(
                children: [
                  CustomButton(
                    text: languageController.getTranslation('add_new'),
                    onPressed: () {
                      Get.to(ScreenNewTicket());
                    },
                  ).paddingSymmetric(horizontal: 20, vertical: 15),
                ],
              ),
            ).paddingOnly(top: 20)
          else if (isManager)
            SizedBox(height: 50), // Add some space when `add_send` is not allowed.
          if (isNotManager)
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xffFFFFFF),
              ),
              child: Column(
                children: [
                  CustomButton(
                    text: languageController.getTranslation('add_new'),
                    onPressed: () {
                      Get.to(ScreenNewTicket());
                    },
                  ).paddingSymmetric(horizontal: 20, vertical: 15)
                ],
              ),
            ).paddingOnly(top: 20),
          
          // Tickets List Section
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ticketsController.currentPage.value = 1;
                ticketsController.hasMoreData.value = true;
                await ticketsController.fetchTickets();
              },
              child: Obx(() {
                if (ticketsController.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  );
                }
                
                if (ticketsController.tickets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.support_agent,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          languageController.getTranslation('no_ticket_found'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          languageController.getTranslation('no_ticket_created_yet'),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                
                                      return ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        itemCount: ticketsController.tickets.length + (ticketsController.hasMoreData.value ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == ticketsController.tickets.length) {
                            // Show loading indicator at the bottom
                            return Obx(() {
                              if (ticketsController.isLoadingMore.value) {
                                return Container(
                                  padding: EdgeInsets.all(20),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                    ),
                                  ),
                                );
                              } else if (ticketsController.hasMoreData.value) {
                                return Container(
                                  padding: EdgeInsets.all(20),
                                  child: Center(
                                    child: Text(
                                      languageController.getTranslation('scroll_to_load_more_tickets'),
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return Container(
                                  padding: EdgeInsets.all(20),
                                  child: Center(
                                    child: Text(
                                      languageController.getTranslation('no_more_tickets_to_load'),
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            });
                          }
                          
                          final ticket = ticketsController.tickets[index];
                          return _buildTicketCard(ticket);
                        },
                      );
              }),
            ),
          ),
          
          // Bottom Container
          CustomBottomContainerPostLogin(),
        ],
      ),
    );
  }

  Widget _buildTicketCard(dynamic ticket) {
    // Handle the new category structure from API response
    String categoryName = 'Unknown';
    
    // Check if category is an object with name and fr fields
    if (ticket.category is Map) {
      var category = ticket.category;
      if (languageController.selectedLanguage.value?.locale == 'fr' && category['fr'] != null) {
        categoryName = category['fr'];
      } else {
        categoryName = category['name'] ?? 'Unknown';
      }
    } else {
      // Fallback for old structure
      categoryName = ticket.category?.toString() ?? 'Unknown';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ticketsController.fetchTicketDetail(ticket.ticket_id);
            Get.to(ScreenTicketDetails(ticketId: ticket.ticket_id));
          },
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Title (Clickable)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          ticketsController.fetchTicketDetail(ticket.ticket_id);
                          Get.to(ScreenTicketDetails(ticketId: ticket.ticket_id));
                        },
                        child: Text(
                          "#${ticket.ticket_id} - ${ticket.title}",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey.shade400,
                      size: 16,
                    ),
                  ],
                ),
                
                SizedBox(height: 12),
                
                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(ticket.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(ticket.status).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getTranslatedStatus(ticket.status).toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(ticket.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Ticket Details
                _buildDetailRow(languageController.getTranslation('category'), categoryName, Icons.category),
                SizedBox(height: 12),
                _buildDetailRow(languageController.getTranslation('last_updated'), DateFormat('yyyy-MM-dd HH:mm a').format(DateTime.parse(ticket.lastUpdated)), Icons.access_time),
                
                // Attachments Section - Dynamic from API data (download only, no visual display)
                if (ticket.attachment != null && ticket.attachment!.isNotEmpty) ...[
                  _buildAttachmentsFromApi(ticket.attachment!),
                ],
                
                SizedBox(height: 16),
                
                // Action Button
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ticketsController.fetchTicketDetail(ticket.ticket_id);
                      Get.to(ScreenTicketDetails(ticketId: ticket.ticket_id));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.visibility, size: 18),
                        SizedBox(width: 8),
                        Text(
                          languageController.getTranslation('view_details'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.blue;
      case 'closed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getTranslatedStatus(String status) {
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

  Widget _buildAttachmentsFromApi(String attachmentsJson) {
    // Mimic the website logic: @if(!empty($ticket->attachments))
    if (attachmentsJson.isEmpty) {
      return Container();
    }

    List<String> attachments = [];
    
    try {
      // Mimic: $attachments = json_decode($ticket->attachments, true);
      List<dynamic> jsonAttachments = jsonDecode(attachmentsJson);
      
      // Mimic: @if(is_array($attachments))
      if (jsonAttachments is List) {
        // Mimic: @foreach($attachments as $attachment)
        attachments = jsonAttachments.map((attachment) => attachment.toString()).toList();
      }
    } catch (e) {
      print('Error parsing attachments JSON: $e');
      return Container();
    }

    // If no valid attachments found
    if (attachments.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Individual download links - mimic @foreach($attachments as $attachment)
        ...attachments.map((attachment) => Column(
          children: [
            _buildDownloadLink(attachment),
            SizedBox(height: 6),
          ],
        )).toList(),
      ],
    );
  }

  Widget _buildDownloadLink(String attachmentUrl) {
    // Extract filename from URL for display
    String fileName = attachmentUrl.split('/').last;
    
    // Ensure the URL has the base URL prepended
    String fullUrl = attachmentUrl;
    if (!attachmentUrl.startsWith('http')) {
      // If it's a relative path, prepend the base URL
      fullUrl = '${ticketsController.apiBaseUrl}/$attachmentUrl';
    }
    
    print('Original attachment URL: $attachmentUrl');
    print('Full download URL: $fullUrl');
    
    return InkWell(
      onTap: () {
        // Direct download using the full attachment URL
        ticketsController.downloadAttachmentFromUrl(fullUrl, fileName);
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
    );
  }

  Widget _buildDownloadButton(String fileName) {
    return InkWell(
      onTap: () {
        ticketsController.downloadAttachment(fileName);
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
                fileName,
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
    );
  }

  Widget _buildAttachmentsSection(String attachment) {
    // Parse attachment string - it might be JSON array or comma-separated
    List<String> attachments = [];
    
    try {
      // Try to parse as JSON first
      List<dynamic> jsonAttachments = jsonDecode(attachment);
      attachments = jsonAttachments.map((item) => item.toString()).toList();
    } catch (e) {
      // If not JSON, try comma-separated
      attachments = attachment.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
    }

    if (attachments.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.attach_file,
                size: 18,
                color: Colors.orange.shade600,
              ),
            ),
            SizedBox(width: 12),
            Text(
              '${languageController.getTranslation('attachments')} (${attachments.length})',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ...attachments.map((fileName) => Container(
          margin: EdgeInsets.only(bottom: 6),
          child: InkWell(
            onTap: () {
              ticketsController.downloadAttachment(fileName);
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
                      fileName,
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
        )).toList(),
      ],
    );
  }
}

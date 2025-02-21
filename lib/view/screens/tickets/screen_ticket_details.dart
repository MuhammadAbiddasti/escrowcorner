import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';
import 'ticket_controller.dart';
import '../user_profile/user_profile_controller.dart';

class ScreenTicketDetails extends StatefulWidget {
  final String
      ticketId; // Pass the ticket ID from previous screens or as a parameter
  ScreenTicketDetails({required this.ticketId});


  @override
  State<ScreenTicketDetails> createState() => _ScreenTicketDetailsState();
}

class _ScreenTicketDetailsState extends State<ScreenTicketDetails> {
  final TicketController ticketController =
      Get.put(TicketController(), permanent: true);

  final UserProfileController userController = Get.find<UserProfileController>();

   initState() {
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
        appBar: AppBar(
          backgroundColor: Color(0xff0766AD),
          title: AppBarTitle(),
          leading: CustomPopupMenu(managerId: userController.userId.value,),

          actions: [
            PopupMenuButtonAction(),
            AppBarProfileButton(),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await ticketController.fetchTicketDetail(widget.ticketId);
          },
          child: SingleChildScrollView(
              child: Center(
                  child: Column(children: [
            //CustomBtcContainer().paddingOnly(top: 20),
            Obx(() {
              final details = ticketController.ticketDetails;
              final isLoading = ticketController.isLoading.value;
              final createdAt = details['created_at'] ?? 'N/A';
              final formattedDate = createdAt != 'N/A'
                  ? DateFormat('yyyy-MM-dd HH:mm')
                      .format(DateTime.parse(createdAt))
                  : 'N/A';

              return Column(
                children: [
                  Container(
                    //height: Get.height * .7,
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xffFFFFFF),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Ticket Details",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff484848),
                            )).paddingOnly(top: 10),

                        // Ticket ID
                        Row(
                          children: [
                            Text("Ticket:",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff484848),
                                )),
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
                                : Text(' #${details['ticket_id'] ?? 'N/A'} ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xff484848),
                                    )),
                          ],
                        ).paddingOnly(top: 10),
                        Divider(),
                        // Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Status",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff484848),
                                )),
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
                                        color: Color(0xff18CE0F)),
                                    child: Center(
                                      child: Text(
                                          '${details['status'] ?? 'N/A'}',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white)),
                                    ),
                                  ),
                          ],
                        ).paddingOnly(top: 5, bottom: 5),
                        Divider(),
                        //Name
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Name",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff484848),
                                )),
                            isLoading
                                ? Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      height: 15,
                                      width: 100,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    '${userController.firstName} ${userController.lastName}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff484848),
                                    )),
                          ],
                        ).paddingOnly(top: 5, bottom: 5),
                        Divider(),
                        // Category Name
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Category",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff484848),
                                )),
                            isLoading
                                ? Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      height: 15,
                                      width: 120,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    '${details['category']['name'] ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff484848),
                                    )),
                          ],
                        ).paddingOnly(top: 5, bottom: 5),
                        Divider(),
                        //Email
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("E-mail",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff484848),
                                )),
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
                                    '${userController.email}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff484848),
                                    )),
                          ],
                        ).paddingOnly(top: 5, bottom: 5),
                        Divider(),

                        //Created
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Created",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff484848),
                                )),
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
                                : Text(formattedDate,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff484848),
                                    )),
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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            // Header
                            Center(
                              child: Text(
                                "Post Replies",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black54,
                                ),
                              ).paddingOnly(bottom: 10),
                            ),
                            // Shimmer effect if loading
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
                                children: replies.map((reply) {
                                  final replyDate = reply['created_at'] != null
                                      ? DateFormat('MMM dd yyyy hh:mm a').format(
                                    DateTime.parse(reply['created_at']),
                                  )
                                      : 'N/A';
                                  final message = reply['message'] ?? 'No message';
                                  final userName = reply['user_name'] ??
                                      '${userController.firstName} ${userController.lastName}'; // Fallback if user_name is null

                                  // Determine the container color
                                  final containerColor = userName == "Customer Support"
                                      ? Colors.blue
                                      : Color(0xff18CE0F);

                                  return Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Name and Date row
                                        Container(
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
                                              // Name Text
                                              Flexible(
                                                child: Text(
                                                  "Name: $userName",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                  overflow: TextOverflow.ellipsis, // Handles overflow with ellipsis
                                                  maxLines: 1, // Limits the text to one line
                                                  softWrap: false, // Prevents wrapping
                                                ),
                                              ),
                                              // Reply Date
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
                                        // Message content
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(color: Colors.grey[300]!),
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(5),
                                              bottomRight: Radius.circular(5),
                                            ),
                                          ),
                                          child: Text(
                                            message,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ).paddingSymmetric(horizontal: 15),
                      ).paddingOnly(top: 10, bottom: 20);
                    }),
                    Container(
              height: Get.height * .3,
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xffFFFFFF),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Message",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xff484848),
                      fontFamily: 'Nunito',
                    ),
                  ).paddingOnly(top: 10, bottom: 10),
                  TextField(
                    controller: ticketController.messageController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Write your message...",
                      contentPadding: EdgeInsets.only(top: 4, left: 5),
                      hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff666565)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff666565)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff666565)),
                      ),
                    ),
                  ),
                  FFButtonWidget(
                    onPressed: () async {
                      final message =
                          ticketController.messageController.text;
                      if(message.isEmpty){
                        Get.snackbar("Message", "Your Message Field is empty",
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,);
                        return;
                      }
                      if (message.isNotEmpty) {
                        await ticketController.postReply(context,
                            widget.ticketId,message);
                        ticketController.messageController.clear(); // Clear the text field after submission
                        await ticketController.fetchTicketDetail(widget
                            .ticketId); // Fetch ticket details again to update the UI
                      }
                    },
                    text: 'Submit',
                    options: FFButtonOptions(
                      width: Get.width,
                      height: 45.0,
                      padding: EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 0.0),
                      iconPadding: EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 0.0),
                      color: DamaspayTheme.of(context).primary,
                      textStyle:
                      DamaspayTheme.of(context).titleSmall.override(
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
                  ).paddingOnly(top: 15,bottom: 20),
                ],
              ).paddingSymmetric(horizontal: 15).paddingOnly(bottom: 10),
            ).paddingOnly(bottom: 20),
            CustomBottomContainer()
          ]))),
        ));
  }
}

class MessageController extends GetxController {
  static final instance = MessageController._();
  final TextEditingController _controller = TextEditingController();

  MessageController._();

  TextEditingController get controller => _controller;
}

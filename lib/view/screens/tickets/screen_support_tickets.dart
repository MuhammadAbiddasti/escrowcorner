import 'package:dacotech/view/screens/tickets/screen_new_ticket.dart';
import 'package:dacotech/view/screens/tickets/screen_ticket_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../controller/logo_controller.dart';
import '../managers/manager_permission_controller.dart';
import '../user_profile/user_profile_controller.dart';
import 'ticket_controller.dart';

class ScreenSupportTicket extends StatelessWidget {
  final LogoController logoController = Get.put(LogoController());
  final TicketController ticketsController = Get.put(TicketController());
  final UserProfileController userProfileController =Get.find<UserProfileController>();
  final ManagersPermissionController controller =Get.find<ManagersPermissionController>();

  @override
  void initState() {
    //super.initState();
    // Fetch escrows only once when the screen is initialized
    ticketsController.fetchTickets();
  }
  void onInit() {
    ticketsController.fetchTickets();
  }
  @override
  Widget build(BuildContext context) {
    final isManager = userProfileController.isManager.value == '1';
    final isNotManager = userProfileController.isManager.value == '0';
    final allowedModules = controller.modulePermissions;
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar:  AppBar(
        backgroundColor: Color(0xff0766AD),
        title: AppBarTitle(),
        leading: CustomPopupMenu(managerId: userProfileController.userId.value,),
        actions: [
          PopupMenuButtonAction(),
          AppBarProfileButton(),

        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
          onRefresh: ()async{
            ticketsController.fetchTickets();
          },
          child: ListView(
            children:[
              Center(
              child: Column(
                children: [
                  //CustomBtcContainer().paddingOnly(top: 20),
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
                            text: "ADD NEW",
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
                      //height: MediaQuery.of(context).size.height * .15,
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xffFFFFFF),
                      ),
                      child: Column(
                        children: [
                          CustomButton(
                            text: "ADD NEW",
                            onPressed: () {
                              Get.to(ScreenNewTicket());
                            },
                          ).paddingSymmetric(horizontal: 20, vertical: 15)
                        ],
                      ),
                    ).paddingOnly(top: 20),
                  Container(
                    height: MediaQuery.of(context).size.height*0.6,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xffFFFFFF),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "My Tickets",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xff18CE0F),
                              fontFamily: 'Nunito'),
                        ),
                        Divider(color: Color(0xffDDDDDD),),
                        Obx(() {
                          if (ticketsController.isLoading.value) {
                            return Center(child: SpinKitFadingFour(
                              duration: Duration(seconds: 3),
                              size: 120,
                              color: Colors.green,
                            ));
                          }
                          else if (ticketsController.tickets.isEmpty) {
                            return Text(
                              "You have not created any tickets.",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Color(0xff484848),
                                  fontFamily: 'Nunito'),
                              textAlign: TextAlign.center,
                            ).paddingOnly(top: 15, bottom: 20);
                          }
                          else {
                            return Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SingleChildScrollView(
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text('Category')),
                                      DataColumn(label: Text('\tTicket ID')),
                                     // DataColumn(label: Text('Title')),
                                      DataColumn(label: Text('Status')),
                                      DataColumn(label: Text('Last Updated')),
                                      DataColumn(label: Text('Action')),
                                    ],
                                    rows: ticketsController.tickets.map((ticket) {
                                      String categoryName = ticketsController.categories
                                          .firstWhere(
                                              (category) {
                                            int categoryId = int.tryParse(ticket.category) ?? -1;
                                            return category.id == categoryId;
                                          },
                                          orElse: () => Category(id: 0, name: 'Unknown', createdAt: '', updatedAt: '')
                                      )
                                          .name;
                                      return DataRow(cells: [
                                        DataCell(Text(categoryName)),
                                        DataCell(TextButton(
                                          onPressed: () {
                                            ticketsController.fetchTicketDetail(ticket.ticket_id);
                                            Get.to(ScreenTicketDetails(ticketId: ticket.ticket_id,));
                                          },
                                          child: Text("#${ticket.ticket_id} - ${ticket.title}",style:TextStyle(color: Colors.blue)),
                                        )),
                                        //DataCell(Text(ticket.title,style: TextStyle(color: Colors.blue),)),
                                        DataCell(Text(ticket.status)),
                                        DataCell(Text('${DateFormat('yyyy-MM-dd  HH:mm a').format(DateTime.parse(ticket.lastUpdated))}')),
                                        DataCell(
                                          CustomButton(
                                            width: 80,
                                            height: 30,
                                            text: 'View',
                                            onPressed: () {
                                              ticketsController.fetchTicketDetail(ticket.ticket_id);
                                              Get.to(ScreenTicketDetails(ticketId: ticket.ticket_id,));
                                            },
                                          ),
                                        ),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                              ),
                            );
                          }
                        }),
                      ],
                    ),
                  ).paddingSymmetric(horizontal: 15,vertical: 15),
                ],
              ),
            ),]
          ),
        ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomContainer()
          )
        ]
      ),
    );
  }
}

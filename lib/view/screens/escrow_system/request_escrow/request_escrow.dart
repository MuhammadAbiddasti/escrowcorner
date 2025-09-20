import 'package:escrowcorner/view/screens/escrow_system/request_escrow/request_escrow_controller.dart';
import 'package:escrowcorner/view/screens/escrow_system/request_escrow/request_escrow_detail.dart';
import 'package:escrowcorner/view/screens/escrow_system/request_escrow/information_escrow_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../../widgets/custom_button/custom_button.dart';
import '../../../../widgets/common_header/common_header.dart';
import '../../managers/manager_permission_controller.dart';
import '../../user_profile/user_profile_controller.dart';
import '../../../../view/controller/language_controller.dart';
import 'screen_create_request_escrow.dart';

class GetRequestEscrow extends StatefulWidget {
  const GetRequestEscrow({super.key});

  @override
  State<GetRequestEscrow> createState() => _GetRequestEscrowState();
}

class _GetRequestEscrowState extends State<GetRequestEscrow> with WidgetsBindingObserver {
  late final RequestEscrowController controller;
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
  final UserProfileController userProfileController =Get.find<UserProfileController>();
  final ManagersPermissionController permissionController =Get.find<ManagersPermissionController>();
  final LanguageController languageController = Get.find<LanguageController>();

  @override
  void initState() {
    super.initState();
    // Add observer for lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    
    // Get existing controller or create new one if needed
    if (!Get.isRegistered<RequestEscrowController>()) {
      Get.put(RequestEscrowController());
    }
    
    // Get the controller instance
    controller = Get.find<RequestEscrowController>();
    print("=== Request Escrow Screen initState ===");
    print("Controller instance: ${controller.hashCode}");
    
    // Reset loading state and fetch data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.resetAllStates();
      controller.fetchRequestEscrows();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This will be called when the screen becomes visible again
    // Ensure data is fresh when navigating back to this screen
    if (controller.requestEscrows.isEmpty && !controller.isLoading.value) {
      controller.fetchRequestEscrows();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When app becomes visible again, refresh data
    if (state == AppLifecycleState.resumed && mounted) {
      controller.fetchRequestEscrows();
    }
  }

  @override
  void dispose() {
    // Remove observer when widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override

  Widget build(BuildContext context) {
    final isManager = userProfileController.isManager.value == '1';
    final isNotManager = userProfileController.isManager.value == '0';
    final allowedModules = permissionController.modulePermissions;
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: languageController.getTranslation('request_escrow'),
        managerId: userProfileController.userId.value,
      ),
      body: Stack(
        children:[
          RefreshIndicator(
          onRefresh: ()async{
            await controller.fetchRequestEscrows();
          },
          child: ListView(
            children:[
              Column(
              children: [
                // Container(
                //   width: MediaQuery.of(context).size.width * 0.9,
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(10),
                //     color: Color(0xffFFFFFF),
                //   ),
                //   child: CustomButton(
                //     text: "Request Escrow",
                //     onPressed: () {
                //       Get.to(ScreenNewRequestEscrow());
                //     },
                //   ).paddingSymmetric(horizontal: 20, vertical: 10),
                // ).paddingOnly(top: 20),
                if (isManager &&
                    allowedModules.containsKey(languageController.getTranslation('request_escrow')) &&
                    allowedModules[languageController.getTranslation('request_escrow')]!.contains('add_request_escrow'))
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
                          height: 30,
                          textStyle: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
                          onPressed: () {
                            Get.to(ScreenCreateRequestEscrow());
                          },
                        ).paddingSymmetric(horizontal: 20, vertical: 10),
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
                           text: languageController.getTranslation('add_new'),
                           height: 30,
                           textStyle: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
                           onPressed: () {
                             Get.to(ScreenCreateRequestEscrow());
                           },
                         ).paddingSymmetric(horizontal: 20, vertical: 10)
                      ],
                    ),
                  ).paddingOnly(top: 20),
                    // Escrow cards section
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 28),
                        child: Text(
                          languageController.getTranslation('request_escrow'),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xff18CE0F),
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    ).paddingOnly(bottom: 10),
                    
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
                          child: Text(languageController.getTranslation('no_request_escrow_available')),
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
                                        '${requestEscrow.currencySymbol ?? ''} ${double.tryParse(requestEscrow.gross.toString())?.toStringAsFixed(3) ?? '0.000'}',
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
                                      
                                      // View and Information buttons on one line
                                      Row(
                                        children: [
                                          // View button
                                          Expanded(
                                            flex: 2,
                                            child: SizedBox(
                                              height: 28,
                                              child: CustomButton(
                                                text: languageController.getTranslation('view'),
                                                textStyle: TextStyle(fontSize: 10, color: Colors.white),
                                                onPressed: () async {
                                                  controller.fetchRequestEscrowDetail(requestEscrow.id);
                                                  await Future.delayed(Duration(milliseconds: 500));
                                                  Get.to(() => RequestEscrowDetailScreen(escrowId: requestEscrow.id));
                                                },
                                              ).paddingSymmetric(horizontal: 8),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          // Information button - wider
                                          Expanded(
                                            flex: 3,
                                            child: SizedBox(
                                              height: 28,
                                              child: CustomButton(
                                                text: languageController.getTranslation('information'),
                                                textStyle: TextStyle(fontSize: 10, color: Colors.white),
                                                backGroundColor: Colors.blue,
                                                                                                                                                                                                                                            onPressed: () async {
                                                   print("=== Information Button Clicked ===");
                                                   print("Escrow ID: ${requestEscrow.id}");
                                                   
                                                   // Show loading indicator
                                                   Get.dialog(
                                                     Center(
                                                       child: CircularProgressIndicator(),
                                                     ),
                                                     barrierDismissible: false,
                                                   );
                                                   
                                                   try {
                                                     // Call the API to fetch escrow details
                                                     await controller.fetchRequestEscrowDetailForInfo(requestEscrow.id);
                                                     
                                                     // Close loading dialog
                                                     Get.back();
                                                     
                                                     // Check if data was fetched successfully
                                                     if (controller.escrowInfoDetail.isNotEmpty) {
                                                       print("Data fetched successfully, navigating to information screen");
                                                       // Navigate to the new information screen
                                                       Get.to(() => InformationEscrowRequestScreen(escrowId: requestEscrow.id));
                                                     } else {
                                                       print("No data fetched, showing error message");
                                                       Get.snackbar(
                                                         'Error',
                                                         'Failed to fetch escrow information',
                                                         backgroundColor: Colors.red,
                                                         colorText: Colors.white,
                                                       );
                                                     }
                                                   } catch (e) {
                                                     // Close loading dialog
                                                     Get.back();
                                                     print("Error fetching data: $e");
                                                     Get.snackbar(
                                                       'Error',
                                                       'Failed to fetch escrow information: $e',
                                                       backgroundColor: Colors.red,
                                                       colorText: Colors.white,
                                                     );
                                                   }
                                                 },
                                              ).paddingSymmetric(horizontal: 8),
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                                                             // Cancel Request button - show when status is NOT completed and NOT rejected
                                       if (requestEscrow.statusLabel.toString().toLowerCase() != 'completed' && 
                                           requestEscrow.statusLabel.toString().toLowerCase() != 'rejected') ...[
                                         SizedBox(height: 12),
                                         SizedBox(
                                           width: double.infinity,
                                           height: 28,
                                           child: Obx(() => CustomButton(
                                             text: languageController.getTranslation('cancel_request'),
                                             textStyle: TextStyle(fontSize: 10, color: Colors.white),
                                             backGroundColor: Colors.red,
                                             loading: controller.getCancelLoading(requestEscrow.id),
                                             onPressed: () {
                                               if (!controller.getCancelLoading(requestEscrow.id)) {
                                                 // Call the cancel API - controller will handle refresh
                                                 controller.cancelRequestEscrow('${requestEscrow.id}');
                                               }
                                             },
                                           )).paddingSymmetric(horizontal: 8),
                                         ),
                                       ],
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
      ]
          ),
        ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomContainerPostLogin()
          )
    ]
      ),
    );
  }
  
  // Helper method to get status color based on status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'pending_approval':
        return Color(0xffFFC107); // Yellow
      case 'approved':
      case 'active':
        return Color(0xff4CAF50); // Green
      case 'rejected':
      case 'cancelled':
      case 'canceled':
        return Color(0xffF44336); // Red
      case 'completed':
      case 'finished':
        return Color(0xff4CAF50); // Green
      case 'processing':
        return Color(0xff9C27B0); // Purple
      case 'on hold':
      case 'onhold':
        return Color(0xffFF9800); // Orange
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
      case 'approved':
        return languageController.getTranslation('approved');
      case 'processing':
        return languageController.getTranslation('processing');
      case 'active':
        return languageController.getTranslation('active');
      default:
        return status;
    }
  }
}

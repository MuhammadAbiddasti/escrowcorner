import 'package:escrowcorner/view/screens/escrow_system/cancelled_escrow/cancelled_escrow_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../widgets/common_header/common_header.dart';
import '../../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../../widgets/custom_button/custom_button.dart';
import '../../user_profile/user_profile_controller.dart';
import 'cancelled_escrow_detail.dart';
import 'cancelled_escrow_information.dart';
import '../../../../view/controller/language_controller.dart';

class GetCancelledEscrow extends StatefulWidget {
  const GetCancelledEscrow({super.key});

  @override
  State<GetCancelledEscrow> createState() => _GetCancelledEscrowState();
}

class _GetCancelledEscrowState extends State<GetCancelledEscrow> with WidgetsBindingObserver {
  late final CancelledEscrowController controller;
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
  final UserProfileController userProfileController = Get.find<UserProfileController>();
  final LanguageController languageController = Get.find<LanguageController>();

  @override
  void initState() {
    super.initState();
    // Add observer for lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    
    // Get existing controller or create new one if needed
    if (!Get.isRegistered<CancelledEscrowController>()) {
      Get.put(CancelledEscrowController());
    }
    
    // Get the controller instance
    controller = Get.find<CancelledEscrowController>();
    print("=== Cancelled Escrow Screen initState ===");
    print("Controller instance: ${controller.hashCode}");
    
    // Reset loading state and fetch data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.handleNavigationFromOtherScreen();
      controller.fetchCanceledEscrows();
    });
    
    // Listen for language changes to refresh content
    try {
      ever(languageController.selectedLanguage, (_) async {
        print('Language changed, refreshing cancelled escrow content');
        setState(() {}); // Trigger rebuild for language change
      });
    } catch (e) {
      print('Language controller not available for cancelled escrow: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This will be called when the screen becomes visible again
    // Ensure data is fresh when navigating back to this screen
    if (controller.canceledEscrows.isEmpty && !controller.isLoading.value) {
      controller.fetchCanceledEscrows();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When app becomes visible again, refresh data
    if (state == AppLifecycleState.resumed && mounted) {
      controller.fetchCanceledEscrows();
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
    controller.fetchCanceledEscrows();
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: languageController.getTranslation('cancelled_escrow'),
        managerId: userProfileController.userId.value,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              controller.clearData();
              await controller.fetchCanceledEscrows();
            },
            child: ListView(
              children: [
                Column(
                  children: [
                    // Cancelled escrow cards section
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 28),
                        child: Text(
                          languageController.getTranslation('cancelled_escrow'),
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
                      if (controller.shouldShowLoading) {
                        return Center(
                          child: SpinKitFadingFour(
                            duration: Duration(seconds: 3),
                            size: 120,
                            color: Colors.green,
                          ),
                        );
                      } else if (controller.canceledEscrows.isEmpty) {
                        return Center(
                          child: Text(languageController.getTranslation('no_cancelled_escrows_available')),
                        );
                      } else {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.75,
                          child: ListView.builder(
                            padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 100),
                            itemCount: controller.canceledEscrows.length,
                            itemBuilder: (context, index) {
                              final cancelledEscrow = controller.canceledEscrows[index];
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
                                        formatter.format(cancelledEscrow.createdAt),
                                      ),
                                      SizedBox(height: 8),
                                      
                                      _buildFieldRow(
                                        languageController.getTranslation('amount'),
                                        '${double.tryParse(cancelledEscrow.gross.toString())?.toStringAsFixed(3) ?? '0.000'} ${cancelledEscrow.currencySymbol}',
                                        valueColor: Color(0xff18CE0F),
                                      ),
                                      SizedBox(height: 8),
                                      
                                      _buildFieldRow(
                                        languageController.getTranslation('status'),
                                        _getTranslatedStatus(cancelledEscrow.statusLabel.toString()),
                                        valueColor: _getStatusColor(cancelledEscrow.statusLabel.toString()),
                                      ),
                                      SizedBox(height: 8),
                                      
                                      _buildFieldRow(
                                        languageController.getTranslation('from'),
                                        cancelledEscrow.userId.toString(),
                                      ),
                                      SizedBox(height: 8),
                                      
                                      _buildFieldRow(
                                        languageController.getTranslation('to'),
                                        cancelledEscrow.to.toString(),
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
                                                onPressed: () async {
                                                  controller.fetchCancelledEscrowDetail(cancelledEscrow.id);
                                                  await Future.delayed(Duration(milliseconds: 500));
                                                  Get.to(() => CancelledEscrowDetailScreen(escrowId: cancelledEscrow.id));
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
                                                onPressed: () async {
                                                  // Navigate to information screen
                                                  Get.to(() => CancelledEscrowInformationScreen(escrowId: cancelledEscrow.id));
                                                },
                                              ).paddingSymmetric(horizontal: 8),
                                            ),
                                          ),
                                        ],
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

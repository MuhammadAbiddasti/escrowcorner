import 'package:escrowcorner/view/screens/escrow_system/send_escrow/screen_create_escrow.dart';
import 'package:escrowcorner/view/screens/escrow_system/send_escrow/send_escrow_controller.dart';
import 'package:escrowcorner/view/screens/escrow_system/send_escrow/send_escrow_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../../widgets/custom_button/custom_button.dart';
import '../../../../widgets/common_header/common_header.dart';
import '../../managers/manager_permission_controller.dart';
import '../../user_profile/user_profile_controller.dart';
import '../../../../view/controller/language_controller.dart';
import 'package:escrowcorner/view/screens/escrow_system/send_escrow/send_escrow_information.dart';

class ScreenEscrowList extends StatefulWidget {
  @override
  _ScreenEscrowListState createState() => _ScreenEscrowListState();
}

class _ScreenEscrowListState extends State<ScreenEscrowList> with WidgetsBindingObserver {
  late final SendEscrowsController controller;
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
  final UserProfileController userProfileController = Get.find<UserProfileController>();
  final ManagersPermissionController permissionController = Get.find<ManagersPermissionController>();
  final LanguageController languageController = Get.find<LanguageController>();
  
  // Track loading state for each escrow release
  final Map<int, bool> _releaseLoadingStates = {};
  
  @override
  void initState() {
    super.initState();
    // Add observer for lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    
    // Get existing controller or create new one if needed
    if (Get.isRegistered<SendEscrowsController>()) {
      controller = Get.find<SendEscrowsController>();
      print("Found existing SendEscrowsController: ${controller.hashCode}");
    } else {
      controller = Get.put(SendEscrowsController());
      print("Created new SendEscrowsController: ${controller.hashCode}");
    }
    
    // Handle navigation from other escrow screens
    controller.handleNavigationFromOtherScreen();
    
    // Only fetch data if no data is already available
    if (controller.escrows.isEmpty && !controller.isLoading.value) {
      controller.fetchSendEscrows();
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This will be called when the screen becomes visible again
    // Ensure data is fresh when navigating back to this screen
    controller.onScreenVisible();
    
    // Always fetch fresh data when navigating to this screen
    // This ensures we get the latest data after creating a new escrow
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.forceRefreshData();
    });
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When app becomes visible again, refresh data if needed
    if (state == AppLifecycleState.resumed && mounted) {
      if (controller.escrows.isEmpty && !controller.isLoading.value) {
        controller.fetchSendEscrows();
      }
    }
  }
  
  @override
  void dispose() {
    // Remove observer when widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final isManager = userProfileController.isManager.value == '1';
    final isNotManager = userProfileController.isManager.value == '0';
    final allowedModules = permissionController.modulePermissions;
    
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: languageController.getTranslation('send_escrow'),
        managerId: userProfileController.userId.value,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              // Force refresh by clearing data first
              controller.clearData();
              await controller.fetchSendEscrows();
            },
            child: ListView(
              children: [
                Column(
                  children: [
                    if (isManager &&
                        allowedModules.containsKey('Send Escrow') &&
                        allowedModules['Send Escrow']!.contains('add_send_escrow'))
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xffFFFFFF),
                        ),
                        child: Column(
                          children: [
                            CustomButton(
                              text: languageController.getTranslation('add_escrow'),
                              onPressed: () {
                                Get.to(ScreenCreateEscrow());
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
                              text: languageController.getTranslation('add_escrow'),
                              onPressed: () {
                                Get.to(ScreenCreateEscrow());
                              },
                            ).paddingSymmetric(horizontal: 20, vertical: 15),
                          ],
                        ),
                      ).paddingOnly(top: 20),
                    
                    // Escrow cards section
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 28),
                        child: Text(
                          languageController.getTranslation('escrow'),
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
                      if (controller.shouldShowLoading) {
                        return Center(
                          child: SpinKitFadingFour(
                            duration: Duration(seconds: 3),
                            size: 120,
                            color: Colors.green,
                          ),
                        );
                      } else if (controller.escrows.isEmpty) {
                        return Center(
                          child: Text(languageController.getTranslation('no_escrows_available')),
                        );
                      } else {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.75,
                          child: ListView.builder(
                            padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 100),
                            itemCount: controller.escrows.length,
                            itemBuilder: (context, index) {
                              final escrow = controller.escrows[index];
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
                                        formatter.format(escrow.createdAt),
                                      ),
                                      SizedBox(height: 8),
                                      
                                      _buildFieldRow(
                                        languageController.getTranslation('amount'),
                                        '${escrow.currencySymbol} ${double.tryParse(escrow.gross.toString())?.toStringAsFixed(3) ?? '0.000'}',
                                        valueColor: Color(0xff18CE0F),
                                      ),
                                      SizedBox(height: 8),
                                      
                                      _buildFieldRow(
                                        languageController.getTranslation('status'),
                                        escrow.statusLabel.toString(),
                                        valueColor: _getStatusColor(escrow.statusLabel.toString()),
                                      ),
                                      SizedBox(height: 8),
                                      
                                      _buildFieldRow(
                                        languageController.getTranslation('from'),
                                        escrow.userId.toString(),
                                      ),
                                      SizedBox(height: 8),
                                      
                                      _buildFieldRow(
                                        languageController.getTranslation('to'),
                                        escrow.to.toString(),
                                      ),
                                      
                                      SizedBox(height: 15),
                                      
                                      // View and Information buttons on one line, Release button on new line (only if not completed)
                                      Column(
                                        children: [
                                          // First row: View and Information buttons
                                          Row(
                                            children: [
                                              // View button
                                              Expanded(
                                                flex: 2,
                                                child: SizedBox(
                                                  height: 35,
                                                  child: CustomButton(
                                                    text: languageController.getTranslation('view'),
                                                    textStyle: TextStyle(fontSize: 14, color: Colors.white),
                                                    onPressed: () async {
                                                      print("View button clicked for escrow ID: ${escrow.id}");
                                                      try {
                                                        controller.fetchEscrowDetail(escrow.id);
                                                        await Future.delayed(Duration(milliseconds: 500));
                                                        print("Navigating to detail screen...");
                                                        
                                                        // Try different navigation approaches
                                                        final result = await Get.to(
                                                          () => SendEscrowDetailScreen(escrowId: escrow.id),
                                                          transition: Transition.rightToLeft,
                                                          duration: Duration(milliseconds: 300),
                                                        );
                                                        
                                                        print("Navigation result: $result");
                                                      } catch (e) {
                                                        print("Error navigating to detail screen: $e");
                                                        Get.snackbar(
                                                          languageController.getTranslation('error'),
                                                          languageController.getTranslation('failed_to_open_detail_screen'),
                                                          backgroundColor: Colors.red,
                                                          colorText: Colors.white,
                                                        );
                                                      }
                                                    },
                                                  ).paddingSymmetric(horizontal: 8),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              // Information button - wider
                                              Expanded(
                                                flex: 3,
                                                child: SizedBox(
                                                  height: 35,
                                                  child: CustomButton(
                                                    text: languageController.getTranslation('information'),
                                                    textStyle: TextStyle(fontSize: 14, color: Colors.white),
                                                    onPressed: () async {
                                                      controller.fetchEscrowInformation(escrow.id);
                                                      await Future.delayed(Duration(milliseconds: 500));
                                                      Get.to(() => SendEscrowInformationScreen(escrowId: escrow.id));
                                                    },
                                                  ).paddingSymmetric(horizontal: 8),
                                                ),
                                              ),
                                            ],
                                          ),
                                          // Show Release button only if status is not completed
                                          if (escrow.statusLabel.toString().toLowerCase() != 'completed') ...[
                                            SizedBox(height: 8),
                                            // Debug print for loading state
                                            Builder(
                                              builder: (context) {
                                                final isLoading = _releaseLoadingStates[escrow.id] == true;
                                                print("Building Release button for escrow ID: ${escrow.id}");
                                                print("Loading state: ${_releaseLoadingStates[escrow.id]}");
                                                print("isLoading boolean: $isLoading");
                                                print("Loading value passed to CustomButton: $isLoading");
                                                return SizedBox(
                                                  width: double.infinity,
                                                  height: 35,
                                                  child: CustomButton(
                                                    text: languageController.getTranslation('release'),
                                                    textStyle: TextStyle(fontSize: 14, color: Colors.white),
                                                    backGroundColor: Colors.blue,
                                                    loading: _releaseLoadingStates[escrow.id] == true,
                                                    onPressed: () async {
                                                      // Don't allow action if already loading
                                                      if (_releaseLoadingStates[escrow.id] == true) {
                                                        return;
                                                      }
                                                      
                                                      print("Release button clicked for escrow ID: ${escrow.id}");
                                                      try {
                                                        // Set loading state for this specific escrow
                                                        print("About to set loading state to true for escrow ID: ${escrow.id}");
                                                        setState(() {
                                                          _releaseLoadingStates[escrow.id] = true;
                                                        });
                                                        print("Loading state set to true for escrow ID: ${escrow.id}");
                                                        print("Current loading states: $_releaseLoadingStates");
                                                        print("After setState - loading state: ${_releaseLoadingStates[escrow.id]}");
                                                        
                                                                                                                 // Call the correct API endpoint
                                                         final response = await controller.escrowRelease('${escrow.id}');
                                                         
                                                         // Show the actual API response message
                                                         if (response != null && response['status'] == 'success') {
                                                           // Refresh the escrow list after successful release
                                                           await controller.forceRefreshData();
                                                          Get.snackbar(
                                                            languageController.getTranslation('success'),
                                                            response['message'] ?? 'Escrow released successfully',
                                                            backgroundColor: Colors.green,
                                                            colorText: Colors.white,
                                                            snackPosition: SnackPosition.BOTTOM,
                                                          );
                                                                                                                 } else {
                                                           // Refresh the escrow list even on error to show current state
                                                           await controller.forceRefreshData();
                                                           
                                                           Get.snackbar(
                                                             languageController.getTranslation('error'),
                                                             response?['message'] ?? 'Failed to release escrow',
                                                             backgroundColor: Colors.red,
                                                             colorText: Colors.white,
                                                             snackPosition: SnackPosition.BOTTOM,
                                                           );
                                                         }
                                                                                                             } catch (e) {
                                                         print("Error releasing escrow: $e");
                                                         // Refresh the escrow list even on exception to show current state
                                                         await controller.forceRefreshData();
                                                         
                                                         Get.snackbar(
                                                           languageController.getTranslation('error'),
                                                           'Error: ${e.toString()}',
                                                           backgroundColor: Colors.red,
                                                           colorText: Colors.white,
                                                           snackPosition: SnackPosition.BOTTOM,
                                                         );
                                                       } finally {
                                                        // Reset loading state regardless of success/failure
                                                        setState(() {
                                                          _releaseLoadingStates[escrow.id] = false;
                                                        });
                                                      }
                                                    },
                                                  ).paddingSymmetric(horizontal: 8),
                                                );
                                              },
                                            ),
                                          ],
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
}

// Helper method to get status colors
Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
    case 'pending_approval':
      return Colors.orange;
    case 'approved':
    case 'active':
      return Colors.green;
    case 'rejected':
    case 'cancelled':
      return Colors.red;
    case 'completed':
    case 'finished':
      return Colors.blue;
    case 'processing':
      return Colors.purple;
    default:
      return Colors.grey;
  }
}


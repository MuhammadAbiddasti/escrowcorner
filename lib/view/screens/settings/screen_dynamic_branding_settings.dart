import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/common_layout/common_layout.dart';
import '../../../view/controller/dynamic_branding_controller.dart';
import '../../../widgets/dynamic_branding/dynamic_branding_widgets.dart';

class DynamicBrandingSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brandingController = Get.find<DynamicBrandingController>();
    
    return CommonLayout(
      title: "Branding Settings",
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Branding Section
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Current Branding",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Logo Preview
                    Row(
                      children: [
                        Text("Logo:", style: TextStyle(fontWeight: FontWeight.w500)),
                        SizedBox(width: 16),
                        DynamicLogoWidget(
                          width: 100,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Icon Preview
                    Row(
                      children: [
                        Text("Icon:", style: TextStyle(fontWeight: FontWeight.w500)),
                        SizedBox(width: 16),
                        DynamicIconWidget(
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Status Widget
                    DynamicBrandingStatusWidget(),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Actions Section
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Actions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Refresh Button
                    ListTile(
                      leading: Icon(Icons.refresh),
                      title: Text("Refresh Branding"),
                      subtitle: Text("Fetch latest branding from server"),
                      trailing: DynamicBrandingRefreshButton(
                        onRefreshComplete: () {
                          Get.snackbar(
                            "Success",
                            "Branding refreshed successfully",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        },
                      ),
                      onTap: () async {
                        await brandingController.forceRefresh();
                        Get.snackbar(
                          "Success",
                          "Branding refreshed successfully",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                    ),
                    
                    Divider(),
                    
                    // Clear Cache Button
                    ListTile(
                      leading: Icon(Icons.clear_all),
                      title: Text("Clear Cache"),
                      subtitle: Text("Remove cached branding files"),
                      onTap: () async {
                        await brandingController.clearCache();
                        Get.snackbar(
                          "Success",
                          "Cache cleared successfully",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.blue,
                          colorText: Colors.white,
                        );
                      },
                    ),
                    
                    Divider(),
                    
                    // Cache Info
                    Obx(() {
                      final lastFetch = brandingController.lastFetchTime.value;
                      return ListTile(
                        leading: Icon(Icons.info),
                        title: Text("Last Updated"),
                        subtitle: Text(
                          lastFetch.toString().substring(0, 19),
                          style: TextStyle(fontSize: 12),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Information Section
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    Text(
                      "• Branding is automatically updated every 24 hours",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "• You can manually refresh branding anytime",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "• Cached files are stored locally for offline use",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "• Fallback to default assets if server is unavailable",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
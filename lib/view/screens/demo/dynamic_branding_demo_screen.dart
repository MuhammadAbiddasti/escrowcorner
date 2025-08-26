import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/dynamic_branding_controller.dart';
import '../../../widgets/dynamic_branding/dynamic_branding_widgets.dart';

class DynamicBrandingDemoScreen extends StatelessWidget {
  const DynamicBrandingDemoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brandingController = Get.find<DynamicBrandingController>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic Branding Demo'),
        backgroundColor: Color(0xff0f9373),
        foregroundColor: Colors.white,
        actions: [
          DynamicBrandingRefreshButton(
            onRefreshComplete: () {
              Get.snackbar(
                'Success',
                'Branding refreshed successfully!',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dynamic Branding System',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0f9373),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This demo showcases the dynamic branding system that fetches app icons and logos from the API.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Current Branding Status
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Branding Status',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    DynamicBrandingStatusWidget(),
                    SizedBox(height: 16),
                    Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Logo URL: ${brandingController.getCurrentLogoUrl()}'),
                        SizedBox(height: 8),
                        Text('Icon URL: ${brandingController.getCurrentIconUrl()}'),
                        SizedBox(height: 8),
                        Text('Last Updated: ${brandingController.lastFetchTime.value.toString()}'),
                        SizedBox(height: 8),
                        Text('Cache Status: ${brandingController.isBrandingUpToDate() ? "Up to date" : "Needs refresh"}'),
                      ],
                    )),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Dynamic Logo Display
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dynamic Logo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: DynamicLogoWidget(
                        height: 150,
                        width: 300,
                        fit: BoxFit.contain,
                        placeholder: Container(
                          height: 150,
                          width: 300,
                          color: Colors.grey[200],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                                ),
                                SizedBox(height: 8),
                                Text('Loading logo...'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Dynamic App Icon Display
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dynamic App Icon',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: DynamicIconWidget(
                        height: 100,
                        width: 100,
                        fit: BoxFit.contain,
                        placeholder: Container(
                          height: 100,
                          width: 100,
                          color: Colors.grey[200],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                                ),
                                SizedBox(height: 8),
                                Text('Loading icon...', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Control Buttons
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Controls',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await brandingController.forceRefresh();
                              Get.snackbar(
                                'Success',
                                'Branding refreshed!',
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                              );
                            },
                            icon: Icon(Icons.refresh),
                            label: Text('Refresh Branding'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff0f9373),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await brandingController.clearCache();
                              Get.snackbar(
                                'Success',
                                'Cache cleared!',
                                backgroundColor: Colors.orange,
                                colorText: Colors.white,
                              );
                            },
                            icon: Icon(Icons.clear_all),
                            label: Text('Clear Cache'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Cache Information
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cache Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    FutureBuilder<Map<String, dynamic>>(
                      future: brandingController.getCacheStats(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        
                        if (snapshot.hasError) {
                          return Text('Error loading cache stats: ${snapshot.error}');
                        }
                        
                        final stats = snapshot.data ?? {};
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('File Count: ${stats['file_count'] ?? 0}'),
                            SizedBox(height: 8),
                            Text('Total Size: ${stats['total_size_mb'] ?? '0.00'} MB'),
                            SizedBox(height: 8),
                            Text('Cache Directory: ${stats['cache_directory'] ?? 'N/A'}'),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // API Information
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Endpoint: /api/get_setting'),
                    SizedBox(height: 8),
                    Text('Method: GET'),
                    SizedBox(height: 8),
                    Text('Authentication: Bearer Token (optional)'),
                    SizedBox(height: 8),
                    Text('Response Format: JSON'),
                    SizedBox(height: 16),
                    Text(
                      'Expected Response:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '{\n'
                        '  "success": true,\n'
                        '  "data": {\n'
                        '    "app_icon": "https://escrowcorner.com/assets/images/app_icon.png",\n'
                        '    "site_logo": "https://escrowcorner.com/assets/logo/logo.png"\n'
                        '  }\n'
                        '}',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

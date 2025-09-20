import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'rate_limiter.dart';

class NavigationHelper {
  static const Duration _navigationDebounceDelay = Duration(milliseconds: 500);
  
  /// Navigate to a screen with debouncing to prevent rapid navigation
  static Future<void> navigateWithDebounce({
    required String key,
    required Widget Function() screenBuilder,
    Duration debounceDelay = _navigationDebounceDelay,
    bool showLoadingIndicator = true,
  }) async {
    print('=== NAVIGATION HELPER DEBUG ===');
    print('Navigation key: $key');
    print('===============================');
    if (showLoadingIndicator) {
      // Show a brief loading indicator
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    }
    
    await RateLimiter.debounceVoid(
      key: key,
      delay: debounceDelay,
      function: () async {
        if (showLoadingIndicator && Get.isDialogOpen == true) {
          Get.back(); // Close loading dialog
        }
        Get.off(screenBuilder());
      },
    );
  }
  
  /// Navigate to a screen with throttling to prevent rapid navigation
  static Future<void> navigateWithThrottle({
    required String key,
    required Widget Function() screenBuilder,
    Duration throttleDelay = _navigationDebounceDelay,
  }) async {
    await RateLimiter.throttle(
      key: key,
      delay: throttleDelay,
      function: () async {
        Get.off(screenBuilder());
        return null;
      },
    );
  }
  
  /// Clear navigation debounce for a specific key
  static void clearNavigationDebounce(String key) {
    RateLimiter.clearKey(key);
  }
  
  /// Clear all navigation debounces
  static void clearAllNavigationDebounces() {
    RateLimiter.clearAll();
  }
}

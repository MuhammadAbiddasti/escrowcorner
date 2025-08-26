import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view/controller/dynamic_branding_controller.dart';

class DynamicLogoWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const DynamicLogoWidget({
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brandingController = Get.find<DynamicBrandingController>();
    
    return Obx(() {
      if (brandingController.isLoading.value && brandingController.appLogo.value == null) {
        return placeholder ?? 
          Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
              ),
            ),
          );
      }
      
      return brandingController.getLogoWidget(
        width: width,
        height: height,
        fit: fit,
      );
    });
  }
}

class DynamicIconWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const DynamicIconWidget({
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brandingController = Get.find<DynamicBrandingController>();
    
    return Obx(() {
      print('🎯 DynamicIconWidget build - appIcon.value: ${brandingController.appIcon.value}');
      print('🎯 DynamicIconWidget build - appIcon.value?.path: ${brandingController.appIcon.value?.path}');
      print('🎯 DynamicIconWidget build - isLoading: ${brandingController.isLoading.value}');
      
      if (brandingController.isLoading.value && brandingController.appIcon.value == null) {
        print('⏳ DynamicIconWidget - Showing loading placeholder');
        return placeholder ?? 
          Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
              ),
            ),
          );
      }
      
      if (brandingController.appIcon.value != null) {
        print('🎯 DynamicIconWidget - Using dynamic icon directly');
        return Image.file(
          brandingController.appIcon.value!,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Error loading dynamic icon in widget: $error');
            return _getFallbackIcon(width, height, fit);
          },
        );
      }
      
      print('🎯 DynamicIconWidget - Using fallback icon');
      return _getFallbackIcon(width, height, fit);
    });
  }
  
  Widget _getFallbackIcon(double? width, double? height, BoxFit fit) {
    return Image.asset(
      'assets/icon/icon.png',
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        print('Fallback icon error: $error');
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Icon(Icons.apps, color: Colors.grey[600]),
        );
      },
    );
  }
}

class DynamicBrandingRefreshButton extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onRefreshComplete;

  const DynamicBrandingRefreshButton({
    Key? key,
    this.child,
    this.onRefreshComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brandingController = Get.find<DynamicBrandingController>();
    
    return Obx(() {
      return IconButton(
        onPressed: brandingController.isLoading.value 
          ? null 
          : () async {
              await brandingController.forceRefresh();
              onRefreshComplete?.call();
            },
        icon: brandingController.isLoading.value
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
              ),
            )
          : Icon(Icons.refresh),
        tooltip: 'Refresh branding',
      );
    });
  }
}

class DynamicBrandingStatusWidget extends StatelessWidget {
  const DynamicBrandingStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brandingController = Get.find<DynamicBrandingController>();
    
    return Obx(() {
      final isExpired = brandingController.shouldRefreshCache();
      
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isExpired ? Colors.orange[100] : Colors.green[100],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isExpired ? Icons.warning : Icons.check_circle,
              size: 16,
              color: isExpired ? Colors.orange[800] : Colors.green[800],
            ),
            SizedBox(width: 4),
            Text(
              isExpired ? 'Branding outdated' : 'Branding up to date',
              style: TextStyle(
                fontSize: 12,
                color: isExpired ? Colors.orange[800] : Colors.green[800],
              ),
            ),
          ],
        ),
      );
    });
  }
} 
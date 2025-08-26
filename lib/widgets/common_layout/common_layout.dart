import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../custom_appbar/custom_appbar.dart';
import '../custom_bottom_container/custom_bottom_container.dart';
import '../../view/screens/user_profile/user_profile_controller.dart';

class CommonLayout extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showBottomContainer;
  final Color? backgroundColor;
  final bool enableRefresh;
  final Future<void> Function()? onRefresh;

  const CommonLayout({
    Key? key,
    required this.child,
    this.title,
    this.showBottomContainer = true,
    this.backgroundColor,
    this.enableRefresh = false,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserProfileController userProfileController = Get.find<UserProfileController>();
    
    return Scaffold(
      backgroundColor: backgroundColor ?? const Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: const Color(0xff191f28),
        title: title != null ? Text(title!) : AppBarTitle(),
        leading: Obx(() => CustomPopupMenu(
          managerId: userProfileController.userId.value,
        )),
        actions: [
          AppBarProfileButton(),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          if (enableRefresh && onRefresh != null)
            RefreshIndicator(
              onRefresh: onRefresh!,
              child: _buildBody(),
            )
          else
            _buildBody(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Main content area
        Expanded(
          child: SingleChildScrollView(
            child: child,
          ),
        ),
        // Bottom container (if enabled)
        if (showBottomContainer)
          const CustomBottomContainerPostLogin(),
      ],
    );
  }
}

// Alternative layout for pages that need full screen without bottom container
class CommonLayoutFullScreen extends StatelessWidget {
  final Widget child;
  final String? title;
  final Color? backgroundColor;
  final bool enableRefresh;
  final Future<void> Function()? onRefresh;

  const CommonLayoutFullScreen({
    Key? key,
    required this.child,
    this.title,
    this.backgroundColor,
    this.enableRefresh = false,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserProfileController userProfileController = Get.find<UserProfileController>();
    
    return Scaffold(
      backgroundColor: backgroundColor ?? const Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: const Color(0xff191f28),
        title: title != null ? Text(title!) : AppBarTitle(),
        leading: Obx(() => CustomPopupMenu(
          managerId: userProfileController.userId.value,
        )),
        actions: [
          AppBarProfileButton(),
        ],
      ),
      body: enableRefresh && onRefresh != null
          ? RefreshIndicator(
              onRefresh: onRefresh!,
              child: SingleChildScrollView(child: child),
            )
          : SingleChildScrollView(child: child),
    );
  }
} 
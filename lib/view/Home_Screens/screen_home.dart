import 'package:escrowcorner/view/screens/login/screen_login.dart';
import 'package:escrowcorner/view/screens/register/screen_signup.dart';
import 'package:escrowcorner/view/screens/dashboard/screen_dashboard.dart';
import 'package:escrowcorner/widgets/custom_button/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_appbar/custom_appbar.dart';
import '../../widgets/custom_token/constant_token.dart';
import 'custom_leading_appbar.dart';
import '../controller/home_controller.dart' as home;
import '../controller/language_controller.dart';
import '../../widgets/language_selector/language_selector_widget.dart';

class ScreenHome extends StatefulWidget {
  @override
  _ScreenHomeState createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final home.HomeController homeController = Get.put(home.HomeController());
  final LanguageController languageController = Get.find<LanguageController>();

  @override
  void initState() {
    super.initState();
    // Initialize the AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 40), // Set the duration for one full rotation
    )..repeat(); // Repeat the rotation indefinitely
    
    // Listen for language changes to refresh content
    ever(languageController.selectedLanguage, (_) {
      homeController.refreshContent();
    });
  }


  @override
  void dispose() {
    // Dispose the AnimationController to free up resources
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: Color(0xff0f9373),
        title: AppBarTitle(),
        leading: CustomLeadingAppbar(),
        actions: [
          QuickLanguageSwitcher(),
          // Dynamic Branding Refresh Button
          // DynamicBrandingRefreshButton(),
          FutureBuilder<bool>(
            future: isUserLoggedIn(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.account_circle, color: Color(0xffFEA116), size: 30),
                );
              }
              
              final isLoggedIn = snapshot.data ?? false;
              
              if (isLoggedIn) {
                // User is logged in, show profile button
                return AppBarProfileButton();
              } else {
                // User is not logged in, show login button
                return IconButton(
                  onPressed: () {
                    Get.to(ScreenLogin());
                  },
                  icon: Icon(Icons.account_circle, color: Color(0xffFEA116), size: 30),
                );
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        // Check if translations are still loading
        if (languageController.isLoading.value || languageController.isLoadingLanguageKeys.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading translations...',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }
        
        if (homeController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (homeController.hasError.value || homeController.homeContent.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 64),
                SizedBox(height: 16),
                Obx(() => Text(
                  languageController.getTranslation('error_loading_home_content'),
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                )),
                SizedBox(height: 8),
                Obx(() => Text(
                  languageController.getTranslation('check_internet_connection'),
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                )),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    homeController.fetchHomeContent();
                  },
                  child: Obx(() => Text(languageController.getTranslation('retry'))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff0f9373),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        } else {
          final content = homeController.homeContent.value!;
          return Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Image.network(
                  content.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey),
                ),
              ),
              // Black overlay on the entire image
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.8), // Semi-transparent black
                ),
              ),
              // Content on top of the background image
              Positioned(
                top: MediaQuery.of(context).size.height * 0.04, // Adjust vertical position
                left: 0,
                right: 0,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // App Icon from API
                      // DynamicIconWidget(
                      //   height: 100,
                      //   width: 100,
                      //   fit: BoxFit.contain,
                      //   placeholder: Container(
                      //     height: 100,
                      //     width: 100,
                      //     decoration: BoxDecoration(
                      //       color: Colors.white.withOpacity(0.2),
                      //       borderRadius: BorderRadius.circular(25),
                      //     ),
                      //     child: Center(
                      //       child: Icon(
                      //         Icons.apps,
                      //         size: 50,
                      //         color: Colors.white,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 10),
                      // Branding Status Indicator
                      // DynamicBrandingStatusWidget(),
                      // SizedBox(height: 20),
                      // Rotating Image
                      RotationTransition(
                        turns: _controller, // Link the controller to the RotationTransition
                        child: Image.network(
                          content.image, // Dynamic image
                          height: MediaQuery.of(context).size.height * 0.24,
                          width: MediaQuery.of(context).size.width * 0.6,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.error, color: Colors.white, size: 80),
                        ),
                      ),
                      // Title text - Now using localized content
                      Text(
                        content.getLocalizedTitle(),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white, // White text to contrast with the background
                          fontSize: 28,
                          fontFamily: 'Nunito',
                        ),
                        textAlign: TextAlign.center,
                      ).paddingOnly(top: 25), // Add some padding between image and text
                  
                       // Description text - Now using localized content
                       Text(
                         content.getLocalizedDescription(),
                         style: TextStyle(
                           fontWeight: FontWeight.w400,
                           fontSize: 16,
                           color: Colors.white, // White text to contrast with the background
                         ),
                         textAlign: TextAlign.center,
                       ).paddingOnly(top: 15),
                  
                      // Conditional Get Started button - only show when user is NOT logged in
                      FutureBuilder<bool>(
                        future: isUserLoggedIn(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return SizedBox(height: 50); // Placeholder while loading
                          }
                          
                          final isLoggedIn = snapshot.data ?? false;
                          
                          if (!isLoggedIn) {
                            // User is not logged in, show Get Started button that goes to SignUp
                            return Obx(() => CustomButton(
                              height: 34,
                              width: MediaQuery.of(context).size.width * 0.5,
                              text: languageController.getTranslation('get_started'),
                              onPressed: () {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  Get.to(() => ScreenSignUp());
                                });
                              },
                            ).paddingOnly(top: 40));
                          } else {
                            // User is logged in, don't show the button
                            return SizedBox.shrink();
                          }
                        },
                      ),
                    ],
                  ).paddingSymmetric(horizontal: 15),
                ), // Padding for the column
              ),
            ],
          );
        }
      }),
    );
  }
}

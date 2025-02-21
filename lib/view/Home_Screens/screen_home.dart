import 'dart:ffi';
import 'package:dacotech/view/screens/login/screen_login.dart';
import 'package:dacotech/view/screens/register/screen_signup.dart';
import 'package:dacotech/widgets/custom_button/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_appbar/custom_appbar.dart';
import '../Kyc_screens/screen_kyc1.dart';
import 'custom_leading_appbar.dart';

class ScreenHome extends StatefulWidget {
  @override
  _ScreenHomeState createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 40), // Set the duration for one full rotation
    )..repeat(); // Repeat the rotation indefinitely
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
        backgroundColor: Color(0xff0766AD),
        title: AppBarTitle(),
        leading: CustomLeadingAppbar(),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.language, color: Colors.green, size: 30),
          ),
          IconButton(
            onPressed: () {
              Get.to(ScreenLogin());
            },
            icon: Icon(Icons.account_circle, color: Color(0xffFEA116), size: 30),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              "assets/images/home2.jpeg",
              fit: BoxFit.cover, // Ensure the image covers the whole background
            ),
          ),
          // Black overlay on the entire image
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.8), // Semi-transparent black
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
                  // Rotating Image
                  RotationTransition(
                    turns: _controller, // Link the controller to the RotationTransition
                    child: Image.asset(
                      'assets/images/intro.png', // Replace with your image
                      height: MediaQuery.of(context).size.height * 0.24,
                      width: MediaQuery.of(context).size.width * 0.6,
                    ),
                  ),
                  // Title text
                  Text(
                    "A Payment gateway and\n financial management\n platform.\n"
                        "Damaspay online\n payment gateway.",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white, // White text to contrast with the background
                      fontSize: 28,
                      fontFamily: 'Nunito',
                    ),
                    textAlign: TextAlign.center,
                  ).paddingOnly(top: 25), // Add some padding between image and text
              
                  // Description text
                  Text(
                    "Damaspay, the smart choice for your\n"
                        "business. Sell using your countries currency\n and cryptocurrency,"
                        " Pay in a snap with the\neasy and elegant interface which"
                        " gives you an outstanding experience",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Colors.white, // White text to contrast with the background
                    ),
                    textAlign: TextAlign.center,
                  ).paddingOnly(top: 15),
              
                  // Custom button
                  CustomButton(
                    height: 34,
                    width: MediaQuery.of(context).size.width * 0.5,
                    text: 'GET STARTED',
                    onPressed: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Get.to(() => ScreenSignUp());
                      });
                    },
                  ).paddingOnly(top: 40),
                ],
              ).paddingSymmetric(horizontal: 15),
            ), // Padding for the column
          ),
        ],
      ),
    );
  }
}

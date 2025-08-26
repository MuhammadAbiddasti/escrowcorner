import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_appbar/custom_appbar.dart';

import '../../widgets/custom_token/constant_token.dart';
import '../controller/contact_us_controller.dart';
import '../controller/language_controller.dart';
import '../screens/login/screen_login.dart';
import 'custom_leading_appbar.dart';
import '../../widgets/language_selector/language_selector_widget.dart';

class ScreenContact extends StatelessWidget {
  final ContactUsController contactUsController = Get.put(ContactUsController());
  final LanguageController languageController = Get.find<LanguageController>();
  
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Obx(() {
                if (contactUsController.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageController.getTranslation('contact_us'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: Color(0xff0766AD),
                        fontFamily: 'Nunito',
                      ),
                    ),
                    SizedBox(height: 32),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Color(0xff0766AD)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            contactUsController.address.value,
                            style: TextStyle(fontSize: 18, color: Color(0xff484848)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(Icons.phone, color: Color(0xff0766AD)),
                        SizedBox(width: 12),
                        Text(
                          contactUsController.contact.value,
                          style: TextStyle(fontSize: 18, color: Color(0xff484848)),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(Icons.email, color: Color(0xff0766AD)),
                        SizedBox(width: 12),
                        Text(
                          contactUsController.email.value,
                          style: TextStyle(fontSize: 18, color: Color(0xff484848)),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
            CustomHomeBottomContainer(),
          ],
        ),
      ),
    );
  }
}

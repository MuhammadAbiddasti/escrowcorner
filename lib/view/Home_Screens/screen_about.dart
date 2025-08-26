import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/about_us_controller.dart';
import '../controller/language_controller.dart';
import '../../widgets/custom_appbar/custom_appbar.dart';
import '../../widgets/custom_token/constant_token.dart';
import 'custom_leading_appbar.dart';

import '../screens/login/screen_login.dart';
import '../../widgets/language_selector/language_selector_widget.dart';

class ScreenAbout extends StatelessWidget {
  final AboutUsController aboutUsController = Get.put(AboutUsController());
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
      body: Obx(() {
        if (aboutUsController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (aboutUsController.hasError.value || aboutUsController.aboutUsContent.value == null) {
          return Center(child: Text(languageController.getTranslation('error_loading_about_us')));
        } else {
          final content = aboutUsController.aboutUsContent.value!;
          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      content.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Color(0xff484848),
                        fontFamily: 'Nunito',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      textAlign: TextAlign.center,
                    ).paddingOnly(top: 30),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xffCDE0EF),
                      ),
                      child: Column(
                        children: [
                          if (content.image.isNotEmpty)
                            Container(
                              height: MediaQuery.of(context).size.height * .25,
                              width: MediaQuery.of(context).size.width,
                              child: Image.network(
                                content.image,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                              ),
                            ).paddingOnly(top: 10, bottom: 10),
                          Text(
                            content.description,
                            style: TextStyle(
                              color: Color(0xff666565),
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ).paddingSymmetric(horizontal: 8),
                        ],
                      ),
                    ),
                  ],
                ).paddingSymmetric(horizontal: 16),
                CustomHomeBottomContainer(),
              ],
            ),
          );
        }
      }),
    );
  }
}

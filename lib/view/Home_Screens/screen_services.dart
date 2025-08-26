import 'package:escrowcorner/view/controller/services_controller.dart';
import 'package:escrowcorner/view/controller/language_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_appbar/custom_appbar.dart';

import '../../widgets/custom_token/constant_token.dart';
import '../../widgets/language_selector/language_selector_widget.dart';
import '../screens/login/screen_login.dart';
import 'custom_leading_appbar.dart';

class ScreenServices extends StatelessWidget {
  final ServicesController servicesController = Get.put(ServicesController());
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
      body: RefreshIndicator(
        onRefresh: () => servicesController.refreshServices(),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    languageController.getTranslation('our_services'),
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 37,
                        color: Color(0xff484848),
                        fontFamily: 'Nunito'),
                    textAlign: TextAlign.center,
                  ).paddingOnly(top: 30),
                  Obx(() {
                    if (servicesController.isLoading.value) {
                      return Center(child: CircularProgressIndicator());
                    } else if (servicesController.hasError.value) {
                      return Center(child: Text(languageController.getTranslation('error_fetching_services')));
                    } else if (servicesController.services.isEmpty) {
                      return Center(child: Text(languageController.getTranslation('no_services_available')));
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: servicesController.services.length,
                        itemBuilder: (context, index) {
                          var service = servicesController.services[index];
                          return Container(
                            margin: EdgeInsets.only(top: 10),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color(0xffCDE0EF)),
                            child: Column(
                              children: [
                                Text(
                                  service.title,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                      fontFamily: 'Nunito'),
                                  textAlign: TextAlign.center,
                                ).paddingOnly(bottom: 20),
                                Text(
                                  service.description,
                                  style: TextStyle(
                                    color: Color(0xff666565),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                  ),
                                  textAlign: TextAlign.center,
                                ).paddingSymmetric(horizontal: 8),
                                Container(
                                  height: MediaQuery.of(context).size.height * .25,
                                  width: MediaQuery.of(context).size.width,
                                  child: Image.network(
                                    service.image,
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
                                ).paddingOnly(top: 10),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  }),
                ],
              ).paddingSymmetric(horizontal: 16),
              CustomHomeBottomContainer(),
            ],
          ),
        ),
      ),
    );
  }
}

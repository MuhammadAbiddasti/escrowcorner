import 'package:escrowcorner/view/Home_Screens/screen_about.dart';
import 'package:escrowcorner/view/Home_Screens/screen_contact.dart';
import 'package:escrowcorner/view/Home_Screens/screen_home.dart';
import 'package:escrowcorner/view/screens/login/screen_login.dart';
import 'package:escrowcorner/view/Home_Screens/screen_newsletter.dart';
import 'package:escrowcorner/view/Home_Screens/screen_services.dart';
import 'package:escrowcorner/view/screens/register/screen_signup.dart';
import 'package:escrowcorner/view/Home_Screens/screen_team.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../widgets/custom_appbar/custom_appbar.dart';
import '../../widgets/custom_button/custom_button.dart';

import 'custom_leading_appbar.dart';
import 'package:escrowcorner/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:escrowcorner/widgets/custom_token/constant_token.dart';

class ScreenClient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(backgroundColor: Color(0xff0f9373),
        title: AppBarTitle(),
        leading: CustomLeadingAppbar(),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.language,color: Colors.green,size: 30,)),
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
        child: Center(
          child: Column(crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Our Client",
                style: TextStyle(
                    color: Color(0xff484848),
                    fontWeight: FontWeight.w700,
                    fontSize: 37,
                    fontFamily: 'Nunito'),
                textAlign: TextAlign.center,
              ).paddingOnly(top: 30),
              Text(
                "Lorem ipsum dolor sit amet,\n"
                    " consectetur adipiscing elit, sed do\n"
                    " eiusmod tempor incididunt ut labore et\n"
                    " dolore magna aliqua.",
                style: TextStyle(color: Color(0xff666565),
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              Container(
                 height: MediaQuery.of(context).size.height * .57,
                 width: MediaQuery.of(context).size.width * .92,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                    color: Color(0xffCDE0EF)),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * .42, // Adjust the width of the avatar
                      height: MediaQuery.of(context).size.width * .42, // Adjust the height of the avatar
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xff0766AD), // Color of the border
                          width: 5.0, // Width of the border
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/steve2.png',
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width * .40, // Adjust the width of the image inside the avatar
                          height:MediaQuery.of(context).size.width * .40, // Adjust the height of the image inside the avatar
                        ),
                      ),
                    ).paddingOnly(top: 20),
                    Text(
                      "Client Name",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                      textAlign: TextAlign.center,
                    ).paddingOnly(top: 20),
                    Text(
                      "Profession",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                      textAlign: TextAlign.center,
                    ).paddingOnly(bottom: 20,top: 10),
                    Text(
                      "Lorem ipsum dolor sit amet, consectetur"
                          " adipiscing elit, sed do eiusmod tempor"
                          " incididunt ut labore et dolore magna aliqua.",
                      style: TextStyle(color: Color(0xff666565),
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).paddingOnly(top:20),

              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 44,width: 155,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20)),
                        color: Color(0xffCDE0EF)),
                    child: Center(
                      child: Text('Next',
                        style: TextStyle(
                          color: Color(0xff484848),
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),),
                    ),
                  ),
                  Container(
                    height: 44,width: 155,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(20),),
                        color: Color(0xffCDE0EF)),
                    child: Center(
                      child: Text('Previous',
                        style: TextStyle(
                          color: Color(0xff484848),
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),),
                    ),
                  ),
                ],
              ).paddingOnly(top: 10),
              CustomHomeBottomContainer(),
            ],
          ),
        ),
      ),
    );
  }
}

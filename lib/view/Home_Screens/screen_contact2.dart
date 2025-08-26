import 'package:escrowcorner/view/Home_Screens/screen_about.dart';
import 'package:escrowcorner/view/Home_Screens/screen_client.dart';
import 'package:escrowcorner/view/Home_Screens/screen_contact.dart';
import 'package:escrowcorner/view/Home_Screens/screen_home.dart';
import 'package:escrowcorner/view/screens/login/screen_login.dart';
import 'package:escrowcorner/view/Home_Screens/screen_newsletter.dart';
import 'package:escrowcorner/view/Home_Screens/screen_services.dart';
import 'package:escrowcorner/view/screens/register/screen_signup.dart';
import 'package:escrowcorner/view/Home_Screens/screen_team.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/custom_appbar/custom_appbar.dart';
import '../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../widgets/custom_token/constant_token.dart';
import '../../widgets/custom_button/custom_button.dart';
import '../controller/logo_controller.dart';
import 'custom_leading_appbar.dart';

class ScreenContact2 extends StatelessWidget {
  final LogoController logoController = Get.put(LogoController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Color(0xffE6F0F7),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Reach Out",
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 37,
                    color: Color(0xff484848),
                    fontFamily: 'Nunito'),
                textAlign: TextAlign.center,
              ).paddingOnly(top: 30),
              Text(
                "Lorem ipsum dolor sit amet,\n"
                    " consectetur adipiscing elit, sed do\n"
                    " eiusmod tempor incididunt ut labore et\n"
                    " dolore magna aliqua.",
                style: TextStyle(
                  color: Color(0xff666565),
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              Container(
                  height: MediaQuery.of(context).size.width * .72,
                  //width: 320,
                  width: MediaQuery.of(context).size.height * .4,
                  child: Image(
                    image: AssetImage("assets/images/contact2.png"),
                    fit: BoxFit.fill,
                  )).paddingOnly(top: 10),
              SizedBox(height: 20,),
              Text("Contact",
                  style: TextStyle(
                    color: Color(0xff0766AD),
                    fontFamily: 'Pacifico',
                    fontWeight: FontWeight.w400,
                    fontSize: 22,
                  )),
              SizedBox(
                height: 5,
              ),
              Container(
                  height: 2,
                  width: 80,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xff0766AD), // Same color as the text
                        width: 2, // Adjust the thickness of the line
                      ),
                    ),
                  )),
              Container(
                height: 40,
                width: MediaQuery.of(context).size.height * .4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent, // #666565
                  Color(0xff3985BD).withOpacity(0.20), // #FEA116
                  Colors.transparent,
                    ],
                    stops: [0.0, 0.2, 1.0], // Define the stops for the gradient
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_pin,color: Color(0xff0766AD),size: 15,),
                    Text("  123 Street, New York,USA",
                        style:
                        TextStyle(fontWeight: FontWeight.w400, fontSize: 16),),
                  ],
                ),
              ).paddingOnly(top: 40),
              Container(
                height: 40,
                width: MediaQuery.of(context).size.height * .4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent, // #666565
                      Color(0xff3985BD).withOpacity(0.20), // #FEA116
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.2, 1.0], // Define the stops for the gradient
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone,color: Color(0xff0766AD),size: 15,),
                    Text("  +01234567890",
                        style:
                        TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
                  ],
                ),
              ).paddingOnly(top: 10),
              Container(
                height: 40,
                width: MediaQuery.of(context).size.height * .4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent, // #666565
                      Color(0xff3985BD).withOpacity(0.20), // #FEA116
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.2, 1.0], // Define the stops for the gradient
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mail,color: Color(0xff0766AD),size: 15,),
                    Text("  admin@admin.com",
                        style:
                        TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
                  ],
                ),
              ).paddingOnly(top: 10),
              Container(
                height: 50,
                width: MediaQuery.of(context).size.height * .4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent, // #666565
                      Color(0xff3985BD).withOpacity(0.20), // #FEA116
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.2, 1.0], // Define the stops for the gradient
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Center(
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          height: 35,width: 35,
                          child: Image(image: AssetImage("assets/images/twitter.png",))),
                      SizedBox(width: 15,),
                      Container(
                          height: 35,width: 35,
                          child: Image(image: AssetImage("assets/images/facebook.png"))),
                      SizedBox(width: 15,),
                      Container(
                          height: 35,width: 35,
                          child: Image(image: AssetImage("assets/images/youtube.png"))),
                      SizedBox(width: 15,),
                      Container(
                          height: 35,width: 35,
                          child: Image(image: AssetImage("assets/images/instagram.png"))),

                    ],
                  ),
                ),
              ).paddingOnly(top: 10),
            CustomHomeBottomContainer(),
            ],
          ),
        ),
      ),
    );
  }
}

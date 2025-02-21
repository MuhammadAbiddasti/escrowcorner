import 'package:dacotech/view/Home_Screens/screen_about.dart';
import 'package:dacotech/view/Home_Screens/screen_client.dart';
import 'package:dacotech/view/Home_Screens/screen_home.dart';
import 'package:dacotech/view/screens/login/screen_login.dart';
import 'package:dacotech/view/Home_Screens/screen_newsletter.dart';
import 'package:dacotech/view/Home_Screens/screen_services.dart';
import 'package:dacotech/view/screens/register/screen_signup.dart';
import 'package:dacotech/view/Home_Screens/screen_team.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/custom_appbar/custom_appbar.dart';
import '../../widgets/custom_button/custom_button.dart';
import '../controller/logo_controller.dart';
import 'custom_leading_appbar.dart';

class ScreenContact extends StatelessWidget {
  final LogoController logoController = Get.put(LogoController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(backgroundColor: Color(0xff0766AD),
        title: AppBarTitle(),
        leading: CustomLeadingAppbar(),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.language,color: Colors.green,size: 30,)),
          IconButton(onPressed: (){
            Get.to(ScreenLogin());
          }, icon: Icon(Icons.account_circle,color: Color(0xffFEA116),
            size: 30,))
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Timings",
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
                style: TextStyle(
                  color: Color(0xff666565),
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              Container(
                  height: MediaQuery.of(context).size.width * .8,
                  //width: 320,
                  width: MediaQuery.of(context).size.height * .42,
                  child: Image(
                    image: AssetImage("assets/images/contact.png"),
                    fit: BoxFit.fill,
                  )).paddingOnly(top: 10),
              Text("Opening",
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
                    Colors.transparent,
                    Color(0xff3985BD).withOpacity(0.2),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.2, 1.0], // Define the stops for the gradient
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Center(
                child: Text("Monday - Saturday 09AM - 09PM",
                    style:
                    TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
              ),
            ).paddingOnly(top: 40),
              Container(
                height: 40,
                width: MediaQuery.of(context).size.height * .4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Color(0xff3985BD).withOpacity(0.2),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.2, 1.0], // Define the stops for the gradient
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Center(
                  child: Text("Sunday  10AM - 08PM",
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
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

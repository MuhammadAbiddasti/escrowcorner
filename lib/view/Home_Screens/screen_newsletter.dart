import 'package:escrowcorner/view/Home_Screens/screen_about.dart';
import 'package:escrowcorner/view/Home_Screens/screen_client.dart';
import 'package:escrowcorner/view/Home_Screens/screen_contact.dart';
import 'package:escrowcorner/view/Home_Screens/screen_home.dart';
import 'package:escrowcorner/view/screens/login/screen_login.dart';
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

class ScreenNewLetter extends StatelessWidget {
  final LogoController logoController = Get.put(LogoController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Color(0xffE6F0F7),
      appBar:AppBar(backgroundColor: Color(0xff0f9373),
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
                "Newsletter",
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 37,
                    color: Color(0xff484848),
                    fontFamily: 'Nunito'),
                textAlign: TextAlign.center,
              ).paddingOnly(top: 30,bottom: 20),
              Text(
                "Damaspay - Fintech-wallet and online\n"
                    " payment gateway system\n"
                    "Accept payments from customers in\n"
                    " unlimited currencies or cryptocurrencies\n"
                    " with over 14+ Payment Methods",
                style: TextStyle(
                  color: Color(0xff666565),
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              Container(
                  height: MediaQuery.of(context).size.width * .8,
                  //width: 360,
                  width: MediaQuery.of(context).size.height * .45,
                  child: Image(
                    image: AssetImage("assets/images/newsletter.png"),
                    fit: BoxFit.fill,
                  )).paddingOnly(top: 10),
              CustomButton(text: "LEARN MORE",
                  width: 182,
                  height: 34,
                  onPressed: (){}).paddingOnly(top: 30),
              CustomHomeBottomContainer(),
            ],
          ),
        ),
      ),
    );
  }
}

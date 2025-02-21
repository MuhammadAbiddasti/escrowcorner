import 'package:dacotech/view/Home_Screens/screen_client.dart';
import 'package:dacotech/view/Home_Screens/screen_contact.dart';
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

class ScreenAbout extends StatelessWidget {
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
        child: Column(
          children: [
            SizedBox(height: 20,),
            Container(
                height: MediaQuery.of(context).size.width * .6,
                width:  MediaQuery.of(context).size.height*.6,
                child: Image(image: AssetImage("assets/images/about.png"),
                  fit: BoxFit.fill,)).paddingSymmetric(horizontal: 10),
        
            Text("About Us",style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 37,color: Color(0xff484848),
                fontFamily: 'Nunito'
            ),textAlign: TextAlign.center,),
            SizedBox(height: 15,),
            Text("Are you looking for a custom online payment"
                " solution for your country’s local currency. to"
                " integrate with your local business? or maybe you"
                " want to start your own Payment\n\n"
                "Gateway Site like PayPal. Damaspay is the script"
                " solution you where looking for. With payment"
                " gateway Script you can easily accept any physical"
                " financial company/bank or online payment"
                " platform as deposits and withdrawal methods for"
                " your site. And, set a fee amount to earn on every"
                " online store purchase linked to your site API and"
                " Money transfers made through Damaspay .",style: TextStyle(
              color: Color(0xff666565),
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),textAlign: TextAlign.center,).paddingSymmetric(horizontal: 10),
            CustomButton(
                height: 34,
                width: 180,
                text: 'GET STARTED', onPressed: (){
              Get.to(ScreenSignUp());
            }).paddingOnly(top: 20),
            CustomHomeBottomContainer(),
          ],
        ),
      ),
    );
  }
}

import 'package:dacotech/view/Home_Screens/screen_about.dart';
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

import '../../widgets/custom_button/custom_button.dart';

class CustomLeadingAppbar extends StatelessWidget {
  const CustomLeadingAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PopupMenuButton<String>(
        color: Color(0xff0766AD),
        splashRadius: 5,
        icon: Icon(Icons.menu,color: Colors.white,),
        offset: Offset(0, 50),
        onSelected: (String result) {
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'option1',
            child: Column(
              children: [
                TextButton(child:Text("Home",
                  style: TextStyle(
                      color: Colors.white
                  ),), onPressed: () {
                  Get.to(ScreenHome());
                },),
                SizedBox(width: 10),
                Divider(
                  color: Color(0xffCDE0EF),
                )
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'option2',
            child:  Column(
              children: [
                TextButton(child:Text("API Docs", style: TextStyle(
                    color: Colors.white
                )), onPressed: () {
                },),
                SizedBox(width: 10),
                Divider(
                  color: Color(0xffCDE0EF),
                )
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'option3',
            child:  Column(
              children: [
                TextButton(child:Text("Services", style: TextStyle(
                  color: Colors.white,
                )), onPressed: () {
                  Get.to(ScreenServices());
                },),
                SizedBox(width: 10),
                Divider(
                  color: Color(0xffCDE0EF),
                )
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'option4',
            child:  Column(
              children: [
                TextButton(child:Text("About", style: TextStyle(
                    color: Colors.white
                )), onPressed: () {
                  Get.to(ScreenAbout());
                },),
                SizedBox(width: 10),
                Divider(
                  color: Color(0xffCDE0EF),
                )
              ],
            ),
          ),
          // PopupMenuItem<String>(
          //   value: 'option5',
          //   child:  Column(
          //     children: [
          //       TextButton(child:Text("Our Team", style: TextStyle(
          //           color: Colors.white
          //       )), onPressed: () {
          //         Get.to(ScreenTeam());
          //       },),
          //       SizedBox(width: 10),
          //       Divider(
          //         color: Color(0xffCDE0EF),
          //       )
          //     ],
          //   ),
          // ),
          // PopupMenuItem<String>(
          //   value: 'option6',
          //   child:  Column(
          //     children: [
          //       TextButton(child:Text("Our Client", style: TextStyle(
          //           color: Colors.white
          //       )), onPressed: () {
          //         Get.to(ScreenClient());
          //       },),
          //       SizedBox(width: 10),
          //       Divider(
          //         color: Color(0xffCDE0EF),
          //       )
          //     ],
          //   ),
          // ),
          PopupMenuItem<String>(
            value: 'option5',
            child:  Column(
              children: [
                TextButton(child:Text("Contact Us", style: TextStyle(
                    color: Colors.white
                )), onPressed: () {
                  Get.to(ScreenContact());
                },),
                SizedBox(width: 10),
                Divider(
                  color: Color(0xffCDE0EF),
                )
              ],
            ),
          ),
          // PopupMenuItem<String>(
          //   value: 'option8',
          //   child:  Column(
          //     children: [
          //       TextButton(child:Text("NewsLetter", style: TextStyle(
          //           color: Colors.white
          //       )), onPressed: () {
          //         Get.to(ScreenNewLetter());
          //       },),
          //       SizedBox(width: 10),
          //       Divider(
          //         color: Color(0xffCDE0EF),
          //       )
          //
          //     ],
          //   ),
          // ),
          PopupMenuItem<String>(
            value: 'option6',
            child:  Column(
              children: [
                TextButton(child:Text("Register", style: TextStyle(
                    color: Colors.white
                )), onPressed: () {
                  Get.to(ScreenSignUp());
                },),
                SizedBox(width: 10),
                Divider(
                  color: Color(0xffCDE0EF),
                )

              ],
            ),
          ),
          PopupMenuItem<String>(
              value: 'option7',
              child: CustomButton(
                  text: 'LOGIN', onPressed: (){
                Get.to(ScreenLogin());
              })
          ),
        ],
      ),
    );
  }
}

class CustomHomeBottomContainer extends StatelessWidget {
  const CustomHomeBottomContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      //height: MediaQuery.of(context).size.height,
      //width: Get.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),),
          color: Color(0xff0766AD)
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30,),
          Row(
            children: [
              Text('Company',style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 22,
                  fontFamily: 'Pacifico',
                  color: Color(0xff18CE0F)
              ),),
              Container(
                height: 3,
                width: 50,
                decoration: BoxDecoration(
                    color: Color(0xff18CE0F),
                    borderRadius: BorderRadius.circular(2)
                ),
              ).paddingOnly(left: 20)
            ],
          ).paddingOnly(bottom: 10),
          GestureDetector(
            onTap: (){
              Get.to(ScreenAbout());
            },
            child: Row(
              children: [
                Icon(Icons.arrow_forward_ios,size: 16,
                  color: Colors.white,),
                Text("About Us",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ))
              ],
            ),
          ),
          GestureDetector(
            onTap: (){},
            child: Row(
              children: [
                Icon(Icons.arrow_forward_ios,size: 16,
                  color: Colors.white,),
                Text("Contact Us",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ))
              ],
            ),
          ),
          GestureDetector(
            child: Row(
              children: [
                Icon(Icons.arrow_forward_ios,size: 16,
                    color: Colors.white),
                Text(" Developer Api",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ))
              ],
            ),
          ),
          GestureDetector(
            child: Row(
              children: [
                Icon(Icons.arrow_forward_ios,size: 16,
                  color: Colors.white,),
                Text(" Privacy Policy",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ))
              ],
            ),
          ),
          GestureDetector(
            child: Row(
              children: [
                Icon(Icons.arrow_forward_ios,size: 16,
                  color: Colors.white,),
                Text(" Terms & Condition",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ))
              ],
            ),
          ),
          GestureDetector(
            child: Row(
              children: [
                Icon(Icons.arrow_forward_ios,size: 16,
                  color: Colors.white,),
                Text(" Our Team",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ))
              ],
            ),
          ),
          GestureDetector(
            child: Row(
              children: [
                Icon(Icons.arrow_forward_ios,size: 16,
                  color: Colors.white,),
                Text(" Our Client",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ))
              ],
            ),
          ),
          SizedBox(height: 20,),
          Row(
            children: [
              TextButton(
                child: Text('Contact',style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 22,
                    fontFamily: 'Pacifico',
                    color: Color(0xff18CE0F)
                ),),
                onPressed: (){},
              ),
              Container(
                height: 3,
                width: 50,
                decoration: BoxDecoration(
                    color: Color(0xffF18CE0F),
                    borderRadius: BorderRadius.circular(2)
                ),
              ).paddingOnly(left: 20)
            ],
          ).paddingOnly(bottom: 10),
          Row(
            children: [
              Icon(Icons.location_pin,size: 17,
                color: Colors.white,),
              Text("   123 Street, New York,USA",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ))
            ],
          ),
          Row(
            children: [
              Icon(Icons.phone,size: 17,
                color: Colors.white,),
              Text("   +01234567890",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ))
            ],
          ).paddingOnly(top: 5),
          Row(
            children: [
              Icon(Icons.mail,size: 17,
                color: Colors.white,),
              Text("    admin@admin.com",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ))
            ],
          ).paddingOnly(top: 5),
          Row(
            children: [
              Container(
                  height: 35,width: 35,
                  child: Image(image: AssetImage("assets/images/twitter.png",))),
              SizedBox(width: 5,),
              Container(
                  height: 35,width: 35,
                  child: Image(image: AssetImage("assets/images/facebook.png"))),
              SizedBox(width: 5,),
              Container(
                  height: 35,width: 35,
                  child: Image(image: AssetImage("assets/images/youtube.png"))),
              SizedBox(width: 5,),
              Container(
                  height: 35,width: 35,
                  child: Image(image: AssetImage("assets/images/instagram.png"))),

            ],
          ).paddingOnly(top: 5),
          SizedBox(height: 30,),
          Row(
            children: [
              Text('Opening',style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 22,
                  fontFamily: 'Pacifico',
                  color: Color(0xff18CE0F)
              ),),
              Container(
                height: 3,
                width: 50,
                decoration: BoxDecoration(
                    color: Color(0xff18CE0F),
                    borderRadius: BorderRadius.circular(2)
                ),
              ).paddingOnly(left: 20)
            ],
          ).paddingOnly(bottom: 10),
          Text('Monday - Saturday\n'
              '09AM - 09PM\n'
              'Sunday\n'
              '10AM - 08PM',style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Colors.white
          ),),
          SizedBox(height: 30,),
          Row(
            children: [
              Text('Newsletter',style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 22,
                  fontFamily: 'Pacifico',
                  color: Color(0xff18CE0F)
              ),),
              Container(
                height: 3,
                width: 50,
                decoration: BoxDecoration(
                    color: Color(0xff18CE0F),
                    borderRadius: BorderRadius.circular(2)
                ),
              ).paddingOnly(left: 20)
            ],
          ).paddingOnly(bottom: 10),
          Text('Damaspay - Fintech-wallet and online\npayment gateway system\n\n'
              'Accept payments from customers in\nunlimited currencies'
              'or cryptocurencies\nwith over 14+ Payment Methods',style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Colors.white
          ),),
          SizedBox(height: 30,),
          Divider(
            color: Color(0xffCDE0EF),

          ),
          Align(alignment: Alignment.center,
            child: Text('© Damaspay, All Right Reserved.',style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Colors.white
            ),),
          ),
          Align(alignment: Alignment.center,
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.white, fontSize: 16.0),
                children: <TextSpan>[
                  TextSpan(text: 'Home '),
                  TextSpan(text: '   |   ',
                      style: TextStyle(color: Colors.white)),
                  TextSpan(text: 'Cookies',),
                  TextSpan(text: '   |   ',
                      style: TextStyle(color: Colors.white)),
                  TextSpan(text: 'Help',),
                  TextSpan(text: '   |   ',
                      style: TextStyle(color: Colors.white)),
                  TextSpan(text: 'FQA&',),
                ],
              ),
            ).paddingOnly(top: 20,bottom: 20),
          )
        ],
      ).paddingSymmetric(horizontal: 20),
    ).paddingOnly(top: 40);
  }
}


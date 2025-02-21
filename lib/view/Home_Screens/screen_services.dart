import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_appbar/custom_appbar.dart';
import '../controller/logo_controller.dart';
import '../screens/login/screen_login.dart';
import 'custom_leading_appbar.dart';

class ScreenServices extends StatelessWidget {
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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Our Services",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 37,color: Color(0xff484848),
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
                    height: MediaQuery.of(context).size.height*.53,
                    width: Get.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xffCDE0EF)
                    ),
                    child:Column(
                      children: [
                        Text(
                          " Customer Supports",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              fontFamily: 'Nunito'),
                          textAlign: TextAlign.center,
                        ).paddingOnly(top: 30),
                        SizedBox(height: 20,),
                        Text(
                          "We’re here to help you and your customers"
                              " with anything, from setting up your business"
                              " account to Seller Protection and queries"
                              " with transactions.",
                          style: TextStyle(
                            color: Color(0xff666565),
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ).paddingSymmetric(horizontal: 8),
                        Container(
                            height: MediaQuery.of(context).size.height * .25,
                            //width: 315,
                            width: MediaQuery.of(context).size.width,
                            child: Image(
                              image: AssetImage("assets/images/service1.png"),
                              fit: BoxFit.fill,
                            )).paddingOnly(top: 10)
                      ],
                    ),
                  ).paddingOnly(top: 10),
                  Container(
                    height: MediaQuery.of(context).size.height*.51,
                    width: Get.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xffCDE0EF)
                    ),
                    child:Column(
                      children: [
                        Text(
                          "Virtual Cards issuing",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              fontFamily: 'Nunito'),
                          textAlign: TextAlign.center,
                        ).paddingOnly(top: 30),
                        SizedBox(height: 20,),
                        Text(
                          "The card can use to verify paypal, purchase online"
                              " e.g facebook ads, Google ads, ebay, amazon,"
                              " apple and lots more.",
                          style: TextStyle(
                            color: Color(0xff666565),
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ).paddingSymmetric(horizontal: 8),
                        FittedBox(fit: BoxFit.fill,
                          child: Container(
                              height: MediaQuery.of(context).size.height * .25,
                              //width: 315,
                              width: MediaQuery.of(context).size.width*.8,
                              child: Image(
                                image: AssetImage("assets/images/service2.png"),
                                fit: BoxFit.fill,
                              )).paddingOnly(top: 20),
                        )
                      ],
                    ),
                  ).paddingOnly(top: 10),
                  Container(
                    height: MediaQuery.of(context).size.height*.51,
                    width: Get.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xffCDE0EF)
                    ),
                    child:Column(
                      children: [
                        Text(
                          " Gift Cards",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              fontFamily: 'Nunito'),
                          textAlign: TextAlign.center,
                        ).paddingOnly(top: 30),
                        SizedBox(height: 20,),
                        Text(
                          "14000+ Products in our Gift Cards catalog,"
                              " Increase user and employee engagement"
                              " with digital Gift Cards on one API",
                          style: TextStyle(
                            color: Color(0xff666565),
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ).paddingSymmetric(horizontal: 8),
                        FittedBox(fit: BoxFit.fill,
                          child: Container(
                              height: MediaQuery.of(context).size.height * .25,
                              //width: 315,
                              width: MediaQuery.of(context).size.width *.8,
                              child: Image(
                                image: AssetImage("assets/images/service3.png"),
                                fit: BoxFit.fill,
                              )).paddingOnly(top: 20),
                        )
                      ],
                    ),
                  ).paddingOnly(top: 10),
                  Container(
                    height: MediaQuery.of(context).size.height*.51,
                    width: Get.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xffCDE0EF)
                    ),
                    child:Column(
                      children: [
                        Text(
                          "Mobile Recharge",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              fontFamily: 'Nunito'),
                          textAlign: TextAlign.center,
                        ).paddingOnly(top: 30),
                        SizedBox(height: 20,),
                        Text(
                          " Send mobile recharge of airtime and internet data"
                              " bundle to over 170+ countries with 800+ mobile"
                              " operators instantly within a seconds.",
                          style: TextStyle(
                            color: Color(0xff666565),
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ).paddingSymmetric(horizontal: 8),
                        Container(
                            height: MediaQuery.of(context).size.height * .25,
                            //width: 315,
                            width: MediaQuery.of(context).size.width *.8,
                            child: Image(
                              image: AssetImage("assets/images/service4.png"),
                              fit: BoxFit.fill,
                            )).paddingOnly(top: 20)
                      ],
                    ),
                  ).paddingOnly(top: 10),
                  Container(
                    height: MediaQuery.of(context).size.height*.52,
                    width: Get.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xffCDE0EF)
                    ),
                    child:Column(
                      children: [
                        Text(
                          " Send & Receive",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              fontFamily: 'Nunito'),
                          textAlign: TextAlign.center,
                        ).paddingOnly(top: 30),
                        SizedBox(height: 20,),
                        Text(
                          "Sending Money Globally Within A Few Minutes"
                              " With Multiple Currency Just In a"
                              " Few Clicks.",
                          style: TextStyle(
                            color: Color(0xff666565),
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ).paddingSymmetric(horizontal: 8),
                        Container(
                            height: MediaQuery.of(context).size.height * .26,
                            //width: 315,
                            width: MediaQuery.of(context).size.width *.8,
                            child: Image(
                              image: AssetImage("assets/images/service5.png"),
                              fit: BoxFit.fill,
                            )).paddingOnly(top: 20)
                      ],
                    ),
                  ).paddingOnly(top: 10),
                  Container(
                    height: MediaQuery.of(context).size.height*.51,
                    width: Get.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xffCDE0EF)
                    ),
                    child:Column(
                      children: [
                        Text(
                          "Store Payment",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              fontFamily: 'Nunito'),
                          textAlign: TextAlign.center,
                        ).paddingOnly(top: 30),
                        SizedBox(height: 20,),
                        Text(
                          "The card can use to verify paypal, purchase online"
                              " e.g facebook ads, Google ads, ebay, amazon,"
                              " apple and lots more.",
                          style: TextStyle(
                            color: Color(0xff666565),
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ).paddingSymmetric(horizontal: 8),
                        Container(
                            height: MediaQuery.of(context).size.height * .25,
                            //width: 315,
                            width: MediaQuery.of(context).size.width *.8,
                            child: Image(
                              image: AssetImage("assets/images/service6.png"),
                              fit: BoxFit.fill,
                            )).paddingOnly(top: 20)
                      ],
                    ),
                  ).paddingOnly(top: 10),
                  Container(
                    height: MediaQuery.of(context).size.height*.53,
                    width: Get.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xffCDE0EF)
                    ),
                    child:Column(
                      children: [
                        Text(
                          "P2P & Exchange",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              fontFamily: 'Nunito'),
                          textAlign: TextAlign.center,
                        ).paddingOnly(top: 30),
                        SizedBox(height: 20,),
                        Text(
                          "P2P trading is two individuals trading"
                              " directly with each other without a"
                              " middleman or third party.",
                          style: TextStyle(
                            color: Color(0xff666565),
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ).paddingSymmetric(horizontal: 8),
                        FittedBox(fit: BoxFit.fill,
                          child: Container(
                              height: MediaQuery.of(context).size.height * .25,
                              //width: 315,
                              width: MediaQuery.of(context).size.width *.8,
                              child: Image(
                                image: AssetImage("assets/images/service7.png"),
                                fit: BoxFit.fill,
                              )).paddingOnly(top: 30),
                        )
                      ],
                    ),
                  ).paddingOnly(top: 10),
                  Container(
                    height: MediaQuery.of(context).size.height*.53,
                    width: Get.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xffCDE0EF)
                    ),
                    child:Column(
                      children: [
                        SizedBox(height: 10,),
                        FittedBox(fit: BoxFit.fill,
                          child: Container(
                              height: MediaQuery.of(context).size.height * .25,
                              //width: 315,
                              width: MediaQuery.of(context).size.width *.8,
                              child: Image(
                                image: AssetImage("assets/images/service8.png"),
                                fit: BoxFit.fill,
                              )),
                        ),
                        Text(
                          "Payment Link",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              fontFamily: 'Nunito'),
                          textAlign: TextAlign.center,
                        ).paddingOnly(top: 30),
                        SizedBox(height: 20,),
                        Text(
                          "Payment links can be created quickly and"
                              " easily and can be accessed from a web"
                              " browser, text message, email, or social"
                              " media post.",
                          style: TextStyle(
                            color: Color(0xff666565),
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ).paddingSymmetric(horizontal: 8),
                      ],
                    ),
                  ).paddingOnly(top: 10),
                ],
              ).paddingSymmetric(horizontal: 15),
              CustomHomeBottomContainer(),
            ],
          ),
        ),
      ),
    );
  }
}

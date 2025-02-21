import 'package:dacotech/view/Home_Screens/screen_contact2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_appbar/custom_appbar.dart';
import '../../widgets/custom_button/custom_button.dart';
import '../controller/logo_controller.dart';
import '../screens/login/screen_login.dart';
import 'custom_leading_appbar.dart';

class ScreenTeam extends StatelessWidget {
  final LogoController logoController = Get.put(LogoController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
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
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Our Team",
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
                  CustomProfileContainer(
                    imagePath: 'assets/images/teamimage.jpeg',
                    image: 'assets/images/steve.png',
                    name: 'Mr. Steve',
                    description:  "Lorem ipsum dolor sit amet,\n"
                        " consectetur adipiscing elit, sed do\n"
                        " eiusmod tempor incididunt ut labore et\n"
                        " dolore magna aliqua.",
                    onContactPressed: () {
                      Get.to(ScreenContact2());
                    },
                  ).paddingOnly(top: 10),
                  CustomProfileContainer(
                    imagePath: 'assets/images/teamimage.jpeg',
                    image: 'assets/images/steve2.png',
                    name: 'Mr. Steve',
                    description:  "Lorem ipsum dolor sit amet,\n"
                        " consectetur adipiscing elit, sed do\n"
                        " eiusmod tempor incididunt ut labore et\n"
                        " dolore magna aliqua.",
                    onContactPressed: () {
                      Get.to(ScreenContact2());
                    },
                  ).paddingOnly(top: 10),
                  CustomProfileContainer(
                    imagePath: 'assets/images/teamimage.jpeg',
                    image: 'assets/images/steve.png',
                    name: 'Mr. Steve',
                    description:  "Lorem ipsum dolor sit amet,\n"
                        " consectetur adipiscing elit, sed do\n"
                        " eiusmod tempor incididunt ut labore et\n"
                        " dolore magna aliqua.",
                    onContactPressed: () {
                      Get.to(ScreenContact2());
                    },
                  ).paddingOnly(top: 10),
                  CustomProfileContainer(
                    imagePath: 'assets/images/teamimage.jpeg',
                    image: 'assets/images/steve2.png',
                    name: 'Mr. Steve',
                    description:  "Lorem ipsum dolor sit amet,\n"
                        " consectetur adipiscing elit, sed do\n"
                        " eiusmod tempor incididunt ut labore et\n"
                        " dolore magna aliqua.",
                    onContactPressed: () {
                      Get.to(ScreenContact2());
                    },
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


class CustomProfileContainer extends StatelessWidget {
  final String imagePath;
  final String image;
  final String name;
  final String description;
  final VoidCallback onContactPressed;

  CustomProfileContainer({
    required this.imagePath,
    required this.image,
    required this.name,
    required this.description,
    required this.onContactPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.66,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color(0xffCDE0EF),
      ),
      child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.32,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 120,
            child: ClipPath(
              clipper: DiagonalClipper(),
              child: Container(
                height: MediaQuery.of(context).size.width * .4,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  color: Color(0xffCDE0EF),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Container(
                  width: MediaQuery.of(context).size.width * .42,
                  height: MediaQuery.of(context).size.width * .42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(0xff0766AD),
                      width: 5.0,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width * .4,
                      height: MediaQuery.of(context).size.width * .4,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 37,
                    color: Color(0xff484848),
                    fontFamily: 'Nunito',
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Color(0xff666565),
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                CustomButton(
                  height: 40,
                  width: 160,
                  text: 'CONTACT',
                  onPressed: onContactPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class DiagonalClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     path.lineTo(0.0, size.height);
//     path.lineTo(size.width, size.height);
//     path.lineTo(size.width, size.height - 40);
//     path.lineTo(0.0, size.height - 100.0);
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) {
//     return false;
//   }
// }


class DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, 93); // Start point at the left side, 93 pixels from the top
    path.lineTo(0, size.height); // Line to the bottom left corner
    path.lineTo(size.width, size.height); // Line to the bottom right corner
    path.lineTo(size.width, 0); // Line to the top right corner
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}



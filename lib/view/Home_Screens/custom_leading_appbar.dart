import 'package:escrowcorner/view/Home_Screens/screen_about.dart';
import 'package:escrowcorner/view/Home_Screens/screen_contact.dart';
import 'package:escrowcorner/view/Home_Screens/screen_home.dart';
import 'package:escrowcorner/view/screens/login/screen_login.dart';
import 'package:escrowcorner/view/Home_Screens/screen_services.dart';
import 'package:escrowcorner/view/screens/register/screen_signup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/settings/setting_controller.dart';
import '../../widgets/custom_api_url/constant_url.dart';

import '../../widgets/custom_button/custom_button.dart';
import '../controller/language_controller.dart';

class CustomLeadingAppbar extends StatelessWidget {
  const CustomLeadingAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    return Container(
      child: PopupMenuButton<String>(
        color: Color(0xff0f9373),
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
                TextButton(child:Obx(() => Text(languageController.getTranslation('home'),
                  style: TextStyle(
                      color: Colors.white
                  ),)), onPressed: () {
                  Get.to(ScreenHome());
                },),
                SizedBox(width: 10),
                Divider(
                  color: Color(0xffCDE0EF),
                )
              ],
            ),
          ),
          // PopupMenuItem<String>(
          //   value: 'option2',
          //   child:  Column(
          //     children: [
          //       TextButton(child:Text("API Docs", style: TextStyle(
          //           color: Colors.white
          //       )), onPressed: () async {
          //         final Uri url = Uri.parse('https://damaspay.readme.io');
          //         if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          //           throw 'Could not launch $url';
          //         }
          //       },),
          //       SizedBox(width: 10),
          //       Divider(
          //         color: Color(0xffCDE0EF),
          //       )
          //     ],
          //   ),
          // ),
          PopupMenuItem<String>(
            value: 'option3',
            child:  Column(
              children: [
                TextButton(child:Obx(() => Text(languageController.getTranslation('services'), style: TextStyle(
                  color: Colors.white,
                ))), onPressed: () {
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
                TextButton(child:Obx(() => Text(languageController.getTranslation('about_us'), style: TextStyle(
                    color: Colors.white
                ))), onPressed: () {
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
                TextButton(child:Obx(() => Text(languageController.getTranslation('contact_us'), style: TextStyle(
                    color: Colors.white
                ))), onPressed: () {
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
          //       )), onPressed: () async {
          //         final Uri url = Uri.parse('https://damaspay.readme.io');
          //         if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          //           throw 'Could not launch $url';
          //         }
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
                TextButton(child:Obx(() => Text(languageController.getTranslation('register'), style: TextStyle(
                    color: Colors.white
                ))), onPressed: () {
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
                  text: languageController.getTranslation('login'), onPressed: (){
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

  // Helper method to build social icon fallbacks based on URL
  Widget _buildSocialIconFallback(String url) {
    if (url.contains('facebook.com') || url.contains('fb.com')) {
      return Icon(Icons.facebook, color: Colors.white, size: 20);
    } else if (url.contains('twitter.com') || url.contains('x.com')) {
      return _buildXIcon(); // Custom X icon
    } else if (url.contains('instagram.com')) {
      return Icon(Icons.camera_alt, color: Colors.white, size: 20);
    } else if (url.contains('linkedin.com')) {
      return Icon(Icons.work, color: Colors.white, size: 20);
    } else if (url.contains('t.me') || url.contains('telegram')) {
      return Icon(Icons.send, color: Colors.white, size: 20);
    } else if (url.contains('tiktok.com')) {
      return Icon(Icons.music_note, color: Colors.white, size: 20);
    } else {
      return Icon(Icons.link, color: Colors.white, size: 20);
    }
  }

  // Custom X icon that looks like the X/Twitter logo
  Widget _buildXIcon() {
    // Option 1: Custom painted X icon
    return Container(
      width: 16,
      height: 16,
      child: CustomPaint(
        painter: XIconPainter(),
      ),
    );
    
    // Option 2: Simple X using text (uncomment if you prefer this)
    // return Text(
    //   'X',
    //   style: TextStyle(
    //     color: Colors.white,
    //     fontSize: 12,
    //     fontWeight: FontWeight.bold,
    //   ),
    // );
  }

  // Helper method to build social icons with multiple fallback attempts
  Widget _buildSocialIconWithFallback(Map<String, dynamic> social) {
    final iconName = social['icon'] ?? '';
    final url = social['url'] ?? '';
    
    // Try multiple possible paths for the icon
    final possiblePaths = [
      '$baseUrl/assets/social/$iconName',
      '$baseUrl/storage/social/$iconName',
      '$baseUrl/images/social/$iconName',
      '$baseUrl/uploads/social/$iconName',
      '$baseUrl/public/assets/social/$iconName',
    ];
    
    return _tryImagePaths(possiblePaths, url);
  }

  // Try multiple image paths with fallbacks
  Widget _tryImagePaths(List<String> paths, String url) {
    if (paths.isEmpty) {
      return _buildSocialIconFallback(url);
    }
    
    final currentPath = paths.first;
    final remainingPaths = paths.skip(1).toList();
    
    return Image.network(
      currentPath,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('Failed to load image from: $currentPath');
        if (remainingPaths.isNotEmpty) {
          // Try the next path
          return _tryImagePaths(remainingPaths, url);
        } else {
          // All paths failed, use fallback icon
          print('All image paths failed, using fallback icon for: $url');
          return _buildSocialIconFallback(url);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialize SettingController to ensure site details are loaded
    final settingController = Get.put(SettingController());
    final languageController = Get.find<LanguageController>();
    
    // Fetch site details to ensure opening hours and newsletter are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      settingController.fetchSiteDetails();
    });
    
    return Container(
      //height: MediaQuery.of(context).size.height,
      //width: Get.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),),
          color: Color(0xff0f9373)
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30,),
          Row(
            children: [
              Text(languageController.getTranslation('company'),style: TextStyle(
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
                Text(languageController.getTranslation('about_us'),
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
                Text(languageController.getTranslation('contact_us'),
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
                Text(languageController.getTranslation('privacy_policy'),
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
                Text(languageController.getTranslation('terms_of_usage'),
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
                child: Text(languageController.getTranslation('contact'),style: TextStyle(
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
          Obx(() => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_pin,size: 17,
                color: Colors.white,),
              SizedBox(width: 5),
              Expanded(
                child: Text("${Get.find<SettingController>().siteAddress.value}",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    )),
              ),
            ],
          )),
          Obx(() => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.message,size: 17,
                color: Colors.white,),
              SizedBox(width: 5),
              Expanded(
                child: Text("${Get.find<SettingController>().siteContactNumber.value}",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    )),
              ),
            ],
          )).paddingOnly(top: 5),
          Obx(() => Row(
            children: [
              Icon(Icons.mail,size: 17,
                color: Colors.white,),
              Text("    ${Get.find<SettingController>().siteAdminEmail.value}",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ))
            ],
          )).paddingOnly(top: 5),
          Obx(() {
            print('Social links count: ${settingController.socialLinks.length}');
            return settingController.socialLinks.isNotEmpty 
              ? Row(
                  children: [
                    ...settingController.socialLinks.map((social) {
                      print('Rendering social link: ${social['url']} - Icon: ${social['icon']}');
                      return Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: GestureDetector(
                          onTap: () async {
                            try {
                              final Uri url = Uri.parse(social['url']);
                              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                print('Could not launch ${social['url']}');
                              }
                            } catch (e) {
                              print('Error launching URL: $e');
                            }
                          },
                          child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildSocialIconWithFallback(social),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ).paddingOnly(top: 5)
              : Row(
                  children: [
                    Text(
                      'Loading social links... (${settingController.socialLinks.length} found)',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ).paddingOnly(top: 5);
          }),
          SizedBox(height: 30,),
          Row(
            children: [
              Text(languageController.getTranslation('opening'),style: TextStyle(
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
          Obx(() => Text(settingController.siteOpeningHours.value,style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Colors.white
          ),)),
          SizedBox(height: 30,),
          Row(
            children: [
              Text(languageController.getTranslation('newsletter'),style: TextStyle(
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
          Obx(() => Text(settingController.siteNewsletter.value,style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Colors.white
          ),)),
          SizedBox(height: 30,),
          Divider(
            color: Color(0xffCDE0EF),

          ),
          Align(alignment: Alignment.center,
            child: Obx(() => Text('© ${settingController.siteName.value}, ${languageController.getTranslation('all_rights_reserved')}',style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Colors.white
            ),)),
          ),
          
        ],
      ).paddingSymmetric(horizontal: 20),
         ).paddingOnly(top: 40);
   }
 }

// Custom painter for X icon
class XIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Draw the X shape
    canvas.drawLine(
      Offset(0, 0),
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(0, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

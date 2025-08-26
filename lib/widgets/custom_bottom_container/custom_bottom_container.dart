import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view/controller/language_controller.dart';
import '../../view/screens/settings/setting_controller.dart';

class CustomBottomContainer extends StatelessWidget {
  const CustomBottomContainer({super.key});
  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    
    return Container(
      height: 60,
      width: double.infinity,
      color: Color(0xff0f9373),
      child: Column(mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${languageController.getTranslation('all_rights_reserved')} EscrowCorner',
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ).paddingSymmetric(horizontal: 8, vertical: 2),
        ],
      ),
    );
  }
  // void _launchURL(String url) async {
  //   final Uri uri = Uri.parse(url);
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

}

class CustomBottomContainerPostLogin extends StatelessWidget {
  const CustomBottomContainerPostLogin({super.key});
  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final settingController = Get.find<SettingController>();
    
    return Container(
      height: 60,
      width: double.infinity,
      color: Color(0xff191f28),
      child: Column(mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Obx(() => Text(
            '${languageController.getTranslation('all_rights_reserved')} ${settingController.siteName.value}',
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          )).paddingSymmetric(horizontal: 8, vertical: 2),
        ],
      ),
    );
  }
}

import 'package:dacotech/view/screens/2fa_security/screen_2fa_security.dart';
import 'package:dacotech/view/screens/change_password/screen_change_password.dart';
import 'package:dacotech/view/screens/settings/screen_fees_charges.dart';
import 'package:dacotech/view/screens/login/screen_login_history.dart';
import 'package:dacotech/view/screens/managers/screen_managers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../applications/screen_merchant.dart';
import '../user_profile/user_profile_controller.dart';
import 'screen_general_settings.dart';
import 'package:webview_flutter/webview_flutter.dart';


class ScreenSettingsPortion extends StatelessWidget {
  // Future<void> _launchURL(String url) async {
  //   final Uri uri = Uri.parse(url);
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri, mode: LaunchMode.externalApplication);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }
  final UserProfileController userProfileController =Get.find<UserProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: const Color(0xff0766AD),
        title: AppBarTitle(),
        leading: CustomPopupMenu(managerId: userProfileController.userId.value,),
        actions: [
          AppBarProfileButton(),
        ],
      ),
      body: Container(
        color: const Color(0xffE6F0F7), // background color for the whole screen
        padding: const EdgeInsets.all(16.0), // padding around the list
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Icons.settings,
                    title: 'General Settings',
                    targetScreen: ScreenGeneralSettings(), // Define your next screen here
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.vpn_key,
                    title: 'API Keys',
                    targetScreen: ScreenMerchant(),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.security,
                    title: '2FA Security',
                    targetScreen: Screen2faSecurity(),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.lock,
                    title: 'Change Password',
                    targetScreen: ScreenChangePassword(),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.supervisor_account,
                    title: 'Managers',
                    targetScreen: ScreenManagers(),
                  ),
                  // _buildSettingsTile(
                  //   context,
                  //   icon: Icons.credit_card,
                  //   title: 'Charges or Fees',
                  //   targetScreen: ScreenFeesCharges(),
                  // ),
                  _buildSetTile(
                    context,
                    icon: Icons.book,
                    title: 'API Documentation',
                  ),
                  // _buildUrlTile(
                  //   context,
                  //   icon: Icons.book,
                  //   title: 'API Documentation',
                  //   url: 'https://damaspay.readme.io/reference/welcome', // Link to open
                  // ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.history,
                    title: 'Login History',
                    targetScreen: ScreenLoginHistory(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {
    required IconData icon,
    required String title,
    required Widget targetScreen,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          Get.to(targetScreen);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Container(
            height: 56,
            // Set height like ListTile
            padding: EdgeInsets.symmetric(horizontal: 16),
            // Padding similar to ListTile
            child: Row(
              children: [
                Icon(icon, color: Colors.black54),
                SizedBox(width: 16), // Space between icon and title
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }

  Widget _buildSetTile(BuildContext context, {
    required IconData icon,
    required String title,
    //required Widget targetScreen,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: _launchUrl,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Container(
            height: 56,
            // Set height like ListTile
            padding: EdgeInsets.symmetric(horizontal: 16),
            // Padding similar to ListTile
            child: Row(
              children: [
                Icon(icon, color: Colors.black54),
                SizedBox(width: 16), // Space between icon and title
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }

  final Uri _url = Uri.parse('https://damaspay.readme.io/reference/welcome');
  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
}





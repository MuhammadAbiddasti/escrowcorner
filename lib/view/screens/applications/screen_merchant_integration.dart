import 'package:escrowcorner/widgets/custom_api_url/constant_url.dart';
import 'package:escrowcorner/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:escrowcorner/widgets/custom_textField/custom_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer package
import 'package:url_launcher/url_launcher.dart';

import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../user_profile/user_profile_controller.dart';
import 'merchant_controller.dart';

class ScreenMerchantIntegration extends StatefulWidget {
  final String merchantId;


  ScreenMerchantIntegration({required this.merchantId});

  @override
  _ScreenMerchantIntegrationState createState() =>
      _ScreenMerchantIntegrationState();
}

class _ScreenMerchantIntegrationState extends State<ScreenMerchantIntegration> {
  final MerchantController controller =
      Get.put(MerchantController(), permanent: true);


  final UserProfileController userProfileController = Get.find<UserProfileController>();

  @override
  void initState() {
    super.initState();
    final MerchantController controller = Get.put(MerchantController());
    controller.fetchMerchantIntegration(widget.merchantId);
  }


  @override
  Widget build(BuildContext context) {
    controller.fetchMerchantIntegration(widget.merchantId);
    print("merchant id: ${widget.merchantId}");
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: Color(0xff191f28),
        title: AppBarTitle(),
        leading: CustomPopupMenu(managerId: userProfileController.userId.value,),
        actions: [
          PopupMenuButtonAction(),
          AppBarProfileButton(),
        ],
      ),
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        var data = controller.merchantData;
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.all(16.0),
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Integration",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: " Data",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.0),
                          // Public Key
                          _buildShimmerOrDataRow(
                            'Public Key:',
                            isLoading ? null : data['public_key'], // Dynamically updated when `data` is modified
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CustomButton(
                                width: 140,
                                backGroundColor: Colors.orange,
                                text: "Regenerate",
                                onPressed: () async {
                                  final userId = data['id']; // Might be an `int`
                                  if (userId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("User ID not found."),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    return;
                                  }

                                  final userIdString = userId.toString(); // Ensure it's a string
                                  await controller.regeneratePublicKey(context, userIdString);
                                  controller.fetchMerchantIntegration(widget.merchantId);
                                },
                              ),
                              CustomButton(
                                width: 100,
                                backGroundColor: Colors.black12,
                                text: "Copy",
                                onPressed: () {
                                  if (!isLoading && data['public_key'] != null) {
                                    Clipboard.setData(ClipboardData(text: data['public_key']));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Public Key copied to clipboard!"),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Public Key is not available."),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ).paddingOnly(top: 5, bottom: 5),
                          // Secret Key
                          _buildShimmerOrDataRow(
                            'Secret Key:',
                            isLoading ? null : data['secret_key'], // Dynamically updated when `data` is modified
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CustomButton(
                                width: 140,
                                backGroundColor: Colors.orange,
                                text: "Regenerate",
                                onPressed: () async {
                                  final userId = data['id']; // Might be an `int`
                                  if (userId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("User ID not found."),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    return;
                                  }

                                  final userIdString = userId.toString();
                                  await controller.regenerateSecretKey(context, userIdString);
                                  controller.fetchMerchantIntegration(widget.merchantId);
                                },
                              ),
                              CustomButton(
                                width: 100,
                                backGroundColor: Colors.black12,
                                text: "Copy",
                                onPressed: () {
                                  if (!isLoading && data['secret_key'] != null) {
                                    Clipboard.setData(ClipboardData(text: data['secret_key']));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Secret Key copied to clipboard!"),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Secret Key is not available."),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ).paddingOnly(top: 5, bottom: 5),

                          Text(
                            'Follow the API documentation link to integrate this payment gateway',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w300,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ).paddingOnly(top: 20),
                          SizedBox(height: 16.0),
                          CustomButton(text: "Click Here", onPressed: _launchUrl),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Fixed footer at bottom
            CustomBottomContainerPostLogin(),
          ],
        );
      }),
    );
  }



  Widget _buildShimmerOrDataRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title ',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          value == null
              ? Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 15,
                    width:
                        100, // You can adjust the width for the shimmer effect
                    color: Colors.white,
                  ),
                )
              : Text(
                  "$value",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black87,
                  ),
                ),
        ],
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

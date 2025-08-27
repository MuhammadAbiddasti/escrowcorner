import 'package:escrowcorner/view/screens/applications/screen_add_merchant.dart';
import 'package:escrowcorner/view/screens/applications/screen_merchant_integration.dart';
import 'package:escrowcorner/view/screens/applications/screen_transfer_in.dart';
import 'package:escrowcorner/view/screens/applications/screen_transfer_out.dart';
import 'package:escrowcorner/view/screens/applications/screen_merchant_transaction_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../../widgets/common_header/common_header.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../../widgets/custom_textField/custom_field.dart';
import '../user_profile/user_profile_controller.dart';
import '../../controller/language_controller.dart';
import 'merchant_controller.dart';

class ScreenMerchant extends StatefulWidget {
  @override
  _ScreenMerchantState createState() => _ScreenMerchantState();
}

class _ScreenMerchantState extends State<ScreenMerchant> {
  final MerchantController controller = Get.put(MerchantController());
  final UserProfileController userProfileController = Get.find<UserProfileController>();
  final LanguageController languageController = Get.find<LanguageController>();

  @override
  void initState() {
    super.initState();
    // Refresh merchant data when page is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMerchants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: CommonHeader(
        title: languageController.getTranslation('merchant'),
        managerId: userProfileController.userId.value,
      ),
      body: Stack(
        children: <Widget>[
          RefreshIndicator(
            onRefresh: () async {
              await controller.fetchMerchants();
            },
            child: ListView(
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xffFFFFFF),
                        ),
                        child: Column(
                          children: [
                                                                                                                   CustomButton(
                               text: languageController.getTranslation('add_sub_account'),
                               onPressed: () {
                                 Get.to(ScreenAddMerchant());
                               },
                             ).paddingSymmetric(horizontal: 20, vertical: 10),
                          ],
                        ),
                      ).paddingOnly(top: 20),
                      SizedBox(height: 16),
                                            Obx(() {
                        if (controller.isLoading.value) {
                          return Center(
                            child: SpinKitFadingFour(
                              duration: Duration(seconds: 3),
                              size: 120,
                              color: Colors.green,
                            ),
                          );
                        } else {
                          return controller.merchants.isEmpty
                              ? Center(
                                  child: Text(
                                    languageController.getTranslation('no_sub_accounts_found'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: controller.merchants.length,
                                  itemBuilder: (context, index) {
                                    final merchant = controller.merchants[index];
                                    return Container(
                                      margin: EdgeInsets.only(
                                        bottom: index == controller.merchants.length - 1 ? 0.0 : 12.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.15),
                                            spreadRadius: 1,
                                            blurRadius: 6,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          // Header Section with Sub Account Name
                                          Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                topRight: Radius.circular(10.0),
                                              ),
                                            ),
                                            child: Text(
                                              merchant.name,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                              textAlign: TextAlign.left,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          
                                          // Logo Section
                                          Container(
                                            height: 100,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                            ),
                                            child: Center(
                                              child: merchant.logo.isNotEmpty
                                                  ? ClipRRect(
                                                      borderRadius: BorderRadius.circular(8.0),
                                                      child: Image.network(
                                                        merchant.logo,
                                                        height: 70,
                                                        width: 70,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          return Container(
                                                            height: 70,
                                                            width: 70,
                                                            decoration: BoxDecoration(
                                                              color: Colors.grey.withOpacity(0.1),
                                                              borderRadius: BorderRadius.circular(8.0),
                                                            ),
                                                            child: Icon(
                                                              Icons.business,
                                                              color: Colors.grey[400],
                                                              size: 35,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  : Container(
                                                      height: 70,
                                                      width: 70,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(8.0),
                                                      ),
                                                      child: Icon(
                                                        Icons.business,
                                                        color: Colors.grey[400],
                                                        size: 35,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                          
                                          // Content Section
                                          Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: Column(
                                              children: [
                                                                                                 // First row of information
                                                 Row(
                                                   children: [
                                                     Expanded(
                                                       child: Column(
                                                         crossAxisAlignment: CrossAxisAlignment.start,
                                                         children: [
                                                                                                                       Text(
                                                              'MTN & Orange ${languageController.getTranslation('balance')}',
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                                color: Colors.grey[600],
                                                                fontWeight: FontWeight.w500,
                                                              ),
                                                            ),
                                                           SizedBox(height: 3),
                                                           Text(
                                                             "${merchant.balance ?? '0.00'}",
                                                             style: TextStyle(
                                                               fontSize: 15,
                                                               fontWeight: FontWeight.w600,
                                                               color: Color(0xff18CE0F),
                                                             ),
                                                           ),
                                                         ],
                                                       ),
                                                     ),
                                                     SizedBox(width: 8),
                                                     Expanded(
                                                       child: Column(
                                                         crossAxisAlignment: CrossAxisAlignment.start,
                                                         children: [
                                                           Text(
                                                             languageController.getTranslation('balance'),
                                                             style: TextStyle(
                                                               fontSize: 11,
                                                               color: Colors.grey[600],
                                                               fontWeight: FontWeight.w500,
                                                             ),
                                                           ),
                                                           SizedBox(height: 3),
                                                           Text(
                                                             "${merchant.balance ?? '0.00'}",
                                                             style: TextStyle(
                                                               fontSize: 15,
                                                               fontWeight: FontWeight.w600,
                                                               color: Color(0xff18CE0F),
                                                             ),
                                                           ),
                                                         ],
                                                       ),
                                                     ),
                                                   ],
                                                 ),
                                                SizedBox(height: 12),
                                              ],
                                            ),
                                          ),
                                          
                                          // Buttons Section
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 7.0),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(10.0),
                                                bottomRight: Radius.circular(10.0),
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                // First row of buttons
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        height: 32,
                                                        child: ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Color(0xff18CE0F),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(4),
                                                            ),
                                                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                                          ),
                                                                                                                     onPressed: () {
                                                                                                                           Get.snackbar('Message', languageController.getTranslation('please_contact_support_to_update_the_sub_account'),
                                                               snackPosition: SnackPosition.BOTTOM,
                                                               backgroundColor: Colors.red,
                                                               colorText: Colors.white,
                                                             );
                                                           },
                                                          child: Text(
                                                            languageController.getTranslation('edit'),
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: 10,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 4),
                                                    Expanded(
                                                      child: Container(
                                                        height: 32,
                                                        child: ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.green,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(4),
                                                            ),
                                                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                                          ),
                                                          onPressed: () {
                                                            Get.to(ScreenMerchantTransactionDetails(
                                                              merchantId: merchant.id.toString(),
                                                              merchantName: merchant.name,
                                                            ));
                                                          },
                                                          child: Text(
                                                            languageController.getTranslation('detail'),
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: 10,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 4),
                                                // Second row of buttons
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        height: 32,
                                                        child: ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.orange,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(4),
                                                            ),
                                                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                                          ),
                                                          onPressed: () {
                                                            Get.to(ScreenTransferIn(
                                                              merchantId: merchant.id.toString(),
                                                              merchantName: merchant.name,
                                                            ));
                                                          },
                                                          child: Text(
                                                            languageController.getTranslation('transfer_in'),
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: 10,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 4),
                                                    Expanded(
                                                      child: Container(
                                                        height: 32,
                                                        child: ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.red,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(4),
                                                            ),
                                                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                                          ),
                                                          onPressed: () {
                                                            Get.to(ScreenTransferOut(
                                                              merchantId: merchant.id.toString(),
                                                              merchantName: merchant.name,
                                                            ));
                                                          },
                                                          child: Text(
                                                            languageController.getTranslation('transfer_out'),
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: 10,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                        }
                      }),
                    ],
                  ).paddingSymmetric(horizontal: 15),
                                 ).paddingOnly(top: 20, bottom: 100),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomContainerPostLogin(),
          ),
        ],
      ),
    );
  }
}

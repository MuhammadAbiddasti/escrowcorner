import 'package:escrowcorner/view/screens/escrow_system/escrow_controller.dart';
import 'package:escrowcorner/view/screens/payment_links/payment_link_controller.dart';
import 'package:escrowcorner/view/screens/payment_links/payment_link_pay.dart';
import 'package:escrowcorner/view/screens/payment_links/screen_create_payment_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_ballance_container/custom_btc_container.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../../widgets/custom_api_url/constant_url.dart';
import '../../controller/logo_controller.dart';
import '../user_profile/user_profile_controller.dart';

class ScreenPaymentLinks extends StatelessWidget {
  final LogoController logoController = Get.put(LogoController());
  final PaymentLinkController paymentLinkController =
  Get.put(PaymentLinkController());
  final UserProfileController userProfileController =Get.find<UserProfileController>();
  final MyController controller = Get.put(MyController()); // GetX controller initialization

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: Color(0xff191f28),
        title: AppBarTitle(),
        leading: CustomPopupMenu(managerId: userProfileController.userId.value,),
        actions: [
          InkWell(
              onTap: () async {
                await paymentLinkController.fetchPaymentLinks();
              },
              child: Icon(color: Colors.white, (Icons.refresh))),
          AppBarProfileButton(),
        ],
      ),
      body: Stack(
        children: [
          // Wrap the RefreshIndicator and content in a single scrollable view
          RefreshIndicator(
            onRefresh: () async {
              await paymentLinkController.fetchPaymentLinks();
            },
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    // CustomBtcContainer().paddingOnly(top: 20),
                    Obx(() {
                      // Using Obx to reactively update the UI based on visibility
                      return controller.isVisible.value
                          ? Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xffFFFFFF),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Color(0xff666565),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "Info",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Color(0xff18CE0F),
                                      fontFamily: 'Nunito'),
                                ),
                              ],
                            ),
                            Text(
                              "Your Account is Fresh and New!",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Color(0xff484848),
                                  fontFamily: 'Nunito'),
                            ).paddingOnly(top: 15),
                            Text(
                              "Start by requesting money from Friends and"
                                  " Businesses. Create your first Payment Link.",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Color(0xff484848),
                                  fontFamily: 'Nunito'),
                              textAlign: TextAlign.center,
                            ).paddingOnly(top: 5, bottom: 20),
                            CustomButton(
                              text: "REQUEST PAYMENT",
                              onPressed: () {
                                if (userProfileController.kyc.value != '3') {
                                  Get.toNamed('/kyc');
                                } else {
                                  Get.to(ScreenCreatePaymentLink());
                                }
                              },
                            ).paddingSymmetric(horizontal: 20, vertical: 15)
                          ],
                        ),
                      ).paddingOnly(top: 20, bottom: 20)
                          : SizedBox.shrink().paddingOnly(bottom: 40); // If hidden, show an empty box (nothing visible)
                    }),
                    Obx(
                          () {
                        if (paymentLinkController.isLoading.value) {
                          return Center(
                              child: SpinKitFadingFour(
                                duration: Duration(seconds: 3),
                                size: 120,
                                color: Colors.green,
                              ));
                        }
                        if (paymentLinkController.paymentLinks.isEmpty) {
                          return Container(
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Center(
                                  child: Text('No payment links available'))
                          ).paddingSymmetric(horizontal: 20);
                        }
                        return Container(
                          // height: 300,
                          child: SingleChildScrollView(
                            child: Column(
                              children: paymentLinkController.paymentLinks
                                  .map((paymentLink) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            paymentLink.name ?? 'No Name',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          paymentLink.paymentStatus == 0
                                              ? IconButton(
                                              onPressed: () {
                                                showCustomDialog(context,paymentLink.paymentlinkId);
                                                print("Selected PaymentLink ID: ${paymentLink.paymentlinkId}");
                                              },
                                              icon: Icon(Icons.more_horiz))
                                              : Text('')
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Method: ${paymentLink.receiver
                                            .toString()}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        'Amount: ${paymentLink.amount
                                            .toString()}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Currency: ${paymentLink.currency
                                            ?.name ?? ''} ${paymentLink.currency
                                            ?.symbol ?? 'Unknown'}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Created: ${DateFormat('yyyy-MM-dd')
                                            .format(DateTime.parse(
                                            paymentLink.createdAt))}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Link:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          final Uri _url = Uri.parse(
                                              '$baseUrl/web/payment/${paymentLink
                                                  .link}');
                                          if (!await launchUrl(_url)) {
                                          throw Exception('Could not launch $_url');
                                          }
                                        },
                                        child: Text(
                                          '$baseUrl/web/payment/${paymentLink
                                              .link}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.blue,
                                            decoration:
                                            TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            // Handle button press if necessary
                                          },
                                          child: Text(
                                            paymentLink.paymentStatus == 1
                                                ? "Paid"
                                                : "Active",
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color:
                                              paymentLink.paymentStatus == 1
                                                  ? Color(0xff18CE0F)
                                                  : Colors.blue,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color:
                                              paymentLink.paymentStatus == 1
                                                  ? Color(0xff18CE0F)
                                                  : Colors.blue,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(20.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ).paddingSymmetric(horizontal: 15),
                                ).paddingSymmetric(
                                    horizontal: 20, vertical: 10);
                              }).toList(), // Convert iterable to list
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 100),
                    // Add extra space at the bottom before the bottom container
                  ],
                ),
              ),
            ),
          ),
          Align(alignment: Alignment.bottomCenter,
              child: CustomBottomContainerPostLogin()),
        ],
      ),
    );
  }

  void showCustomDialog(BuildContext context, String paymentLinkId) {
    showDialog(
      context: context,
      barrierDismissible: true, // Allows dismissing by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white, // Set the background color to black
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // To avoid large size
              children: [
                TextButton(
                  onPressed: () async {
                    final Uri _url = Uri.parse(
                        '$baseUrl/web/payment/$paymentLinkId');
                    print("id: $paymentLinkId");
                    if (!await launchUrl(_url)) {
                      throw Exception('Could not launch $_url');
                    }
                  },
                  child: Text(
                    'Preview',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Divider(), // Divider between buttons
                TextButton(
                  onPressed: () {
                    showDeleteConfirmationDialog(context, paymentLinkId);
                  },
                  child: Text(
                    "Delete",
                    style: TextStyle(color: Colors.black), // White text color
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void showDeleteConfirmationDialog(BuildContext context, String PaymentId) {
    Get.defaultDialog(
      title: "",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, color: Colors.orange, size: 40),
          SizedBox(height: 10),
          Text(
            "Are you sure?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "You won’t be able to revert this",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        CustomButton(width: 95,
            text: "Cancel", onPressed: (){
              Get.back();
            }),
        CustomButton(width: 140,
          backGroundColor: Colors.red,
          text: "Yes, Delete it", onPressed: () {
            paymentLinkController.deletePaymentLink(PaymentId, context);
            print("Delete clicked");
            Navigator.pop(context);
            Navigator.pop(context);
          },
        )
      ],
    );
  }

}

class PaymentWebViewScreen extends StatelessWidget {
  final String url;

  const PaymentWebViewScreen({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff0766AD),
        title: const Text("Payment"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await openUrlInBrowser(url);
          },
          child: const Text("Open in Browser"),
        ),
      ),
    );
  }

  Future<void> openUrlInBrowser(String url) async {
    var uri = Uri.https('google.com');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('Could not launch $url');
    }
  }
}

class MyController extends GetxController {
  var isVisible = true.obs; // Observable to track visibility
}




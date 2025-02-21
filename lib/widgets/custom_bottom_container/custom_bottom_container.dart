import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBottomContainer extends StatelessWidget {
  const CustomBottomContainer({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .14,
      width: double.infinity,
      color: Color(0xff0766AD),
      child: Column(mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 14.0),
              children: <TextSpan>[
                TextSpan(
                    text: 'Damaspay ',
                    style: TextStyle(color: Colors.green)),
                TextSpan(
                  text: 'is a Registered ICO, Inc. Georgia [a wholly'
                      ' owned subsidiary of U.S. Bancorp, Minneapolis, MN]\n\n',
                  //style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                    text: "© ALL RIGHT REVERSED.",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text: " DAMASPAY ",
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ).paddingSymmetric(horizontal: 15),
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

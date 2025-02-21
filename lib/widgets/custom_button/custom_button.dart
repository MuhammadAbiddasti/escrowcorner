import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomButton extends StatelessWidget {
  final String text;
  double? width,height;
  final VoidCallback onPressed;
  final Color? textColor;
  final Color? backGroundColor;
  final List<Color>? buttonColor;
  final BoxDecoration? customDecoration;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width??Get.width,
      height: height??45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        // color: backGroundColor??Color(0xffE31C5D)
      ),
      child:ElevatedButton(

          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)
            ),
            backgroundColor: backGroundColor ?? Color(0xff18CE0F),
          ),
          onPressed: onPressed, child: Text(text,style: TextStyle(color: textColor??Colors.white,
          fontWeight: FontWeight.w500,fontSize: 14),)
        // .paddingSymmetric(horizontal: 20
      )

          //.paddingSymmetric(horizontal: 20),
    );
  }

  CustomButton({
    required this.text,
    this.width,
    this.height,
    required this.onPressed,
    this.textColor,
    this.backGroundColor,
    this.buttonColor,
    this.customDecoration,
    this.loading = false,
  });
}

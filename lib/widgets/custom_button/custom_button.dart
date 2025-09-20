import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomButton extends StatelessWidget {
  final String text;
  double? width,height;
  final VoidCallback onPressed;
  final Color? textColor;
  final TextStyle? textStyle;
  final Color? backGroundColor;
  final List<Color>? buttonColor;
  final BoxDecoration? customDecoration;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    // Debug print to see loading state
    print("CustomButton build - text: $text, loading: $loading, loading type: ${loading.runtimeType}");
    
    return Container(
      width: width??Get.width,
      height: height??35,
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
          onPressed: loading ? null : onPressed, 
          child: loading 
            ? Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            : Center(
                child: Text(
                  text,
                  style: textStyle ?? TextStyle(
                    color: textColor ?? Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12
                  ),
                ),
              )
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
    this.textStyle,
    this.backGroundColor,
    this.buttonColor,
    this.customDecoration,
    this.loading = false,
  });
}

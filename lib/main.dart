import 'dart:io';
import 'package:dacotech/view/Home_Screens/screen_home.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  checkDnsResolution();
  runApp(MyApp());
    // DevicePreview(
    //   enabled: !kReleaseMode,
    //   builder: (context) => const MyApp(), // Wrap your app
    // ),);
}
void checkDnsResolution() async {
  try {
    final result = await InternetAddress.lookup('damaspay.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('damaspay.com resolved to ${result[0].address}');
    }
  } on SocketException catch (e) {
    print('Error resolving damaspay.com: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(

        debugShowCheckedModeBanner: false,
        home: ScreenHome());
      }
  }

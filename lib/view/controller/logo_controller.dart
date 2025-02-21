import 'dart:convert';
import 'package:dacotech/widgets/custom_api_url/constant_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LogoController extends GetxController {
  var logoUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLogoUrl();
  }

  Future<void> fetchLogoUrl() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/get_site_details'));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        logoUrl.value = responseData['data']['site_logo'];
      } else {
        print('Failed to fetch logo URL');
      }
    } catch (e) {
      print('Error fetching logo URL: $e');
    }
  }
}

class LogoWidget extends StatelessWidget {
  final String logoUrl;
  LogoWidget(this.logoUrl);
  @override
  Widget build(BuildContext context) {
    return logoUrl.isEmpty
        ? CircularProgressIndicator()
        : Image.network(
              "$baseUrl/$logoUrl",
      height: Get.height*.07,
      width: Get.width*.36,
            );
  }
}


import 'package:dacotech/view/screens/user_profile/user_profile_controller.dart';
import 'package:dacotech/widgets/custom_api_url/constant_url.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../widgets/custom_token/constant_token.dart';

class KycController extends GetxController {
  //RxString kyc = ''.obs;  // Observable variable for KYC status
  final UserProfileController controller = Get.find<UserProfileController>();

  Future<void> fetchKycStatus() async {
    final token = await getToken(); // Retrieve the token
    if (token == null) {
      print('Token is null');
      return;
    }

    print('Checking KYC Status');

    final url = '$baseUrl/api/getKycStatus'; // API endpoint for KYC status
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Include token for authorization
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}'); // For debugging

    if (response.statusCode == 200) {
      String kycStatus = response.body; // Assuming response is a plain string
      controller.kyc.value = kycStatus; // Update RxString using .value
    } else {
      throw Exception('Failed to load KYC status');
    }
  }
}

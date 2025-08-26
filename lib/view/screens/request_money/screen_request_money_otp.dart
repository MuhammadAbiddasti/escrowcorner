import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../request_money/controller_requestmoney.dart';
import '../user_profile/user_profile_controller.dart';
import 'screen_get_request_money.dart';

class ScreenRequestMoneyOtp extends StatefulWidget {
  final String requestId;
  final String userEmail;

  const ScreenRequestMoneyOtp({
    Key? key,
    required this.requestId,
    required this.userEmail,
  }) : super(key: key);

  @override
  _ScreenRequestMoneyOtpState createState() => _ScreenRequestMoneyOtpState();
}

class _ScreenRequestMoneyOtpState extends State<ScreenRequestMoneyOtp> {
  final TextEditingController otpController = TextEditingController();
  final RequestMoneyController requestMoneyController = Get.find<RequestMoneyController>();
  final UserProfileController userProfileController = Get.find<UserProfileController>();
  bool isLoading = false;
  bool isResending = false; // Separate loading state for resend button

  @override
  void initState() {
    super.initState();
    // Send OTP when screen loads (without showing loading state)
    _sendInitialOtp();
  }

  Future<void> _sendInitialOtp() async {
    try {
      await requestMoneyController.sendConfirmOtp(widget.requestId);
      Get.snackbar(
        'Success',
        'OTP sent to your email',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send OTP: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _sendOtp() async {
    setState(() {
      isResending = true;
    });

    try {
      await requestMoneyController.sendConfirmOtp(widget.requestId);
      Get.snackbar(
        'Success',
        'OTP sent to your email',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send OTP: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        isResending = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (otpController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter OTP code',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      print('Starting OTP verification...');
      await requestMoneyController.verifyConfirmOtp(widget.requestId, otpController.text);
      print('OTP verification completed successfully');
      
      // After OTP verification, call confirmRequestMoney API
      print('Starting request confirmation...');
      bool confirmationSuccess = await requestMoneyController.confirmRequestMoney(widget.requestId);
      print('Request confirmation result: $confirmationSuccess');
      
      if (confirmationSuccess) {
        // Navigate back to request money list after successful completion
        print('Navigating back to request money list...');
        // Add a small delay to ensure snackbar is shown before navigation
        await Future.delayed(Duration(milliseconds: 500));
        Get.off(() => ScreenGetRequestMonay());
      }
    } catch (e) {
      print('Error in OTP verification flow: $e');
      Get.snackbar(
        'Error',
        'Invalid OTP code',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: Color(0xff191f28),
        title: AppBarTitle(),
        leading: CustomPopupMenu(managerId: userProfileController.userId.value),
        actions: [
          PopupMenuButtonAction(),
          AppBarProfileButton(),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              
              // Icon
              Icon(
                Icons.verified_user,
                size: 80,
                color: Color(0xff0766AD),
              ),
              
              SizedBox(height: 30),
              
              // Title
              Text(
                'Verify OTP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0766AD),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Description
              Text(
                'We have sent a verification code to your email\n${widget.userEmail}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff666565),
                ),
              ),
              
              SizedBox(height: 40),
              
              // OTP Input Field
              SizedBox(
                width: double.infinity,
                child: TextFormField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter OTP',
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xff0766AD)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xff0766AD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xff0766AD), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              
              SizedBox(height: 30),
              
              // Verify Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: isLoading ? 'Verifying...' : 'Verify OTP',
                  onPressed: isLoading ? () {} : () => _verifyOtp(),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Resend OTP Button
              TextButton(
                onPressed: isResending ? null : () => _sendOtp(),
                child: Text(
                  isResending ? 'Sending...' : 'Resend OTP',
                  style: TextStyle(
                    color: Color(0xff0766AD),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Back Button
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Back to Request List',
                  style: TextStyle(
                    color: Color(0xff666565),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }
} 
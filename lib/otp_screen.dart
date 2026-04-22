import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:pinput/pinput.dart';
import 'package:unipole_inspection/screens/inspection_first_screen.dart';

import 'auth_service.dart';
import 'controller/otp_controller.dart';

class OtpScreen extends StatelessWidget {
  final String? phone;
  final String? otp;

  OtpScreen({super.key, this.phone, this.otp});

  final OtpController controller = Get.put(OtpController());

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};
    final String? phone = args['phone'];
    final String? otp = args['otp'];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Icon(Icons.arrow_back),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Image.asset(
                      'assets/images/adinn_logo.png',
                      height: 40,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 17, color: Colors.black87),
                  children: [
                    TextSpan(text: "We sent a 6-digit verification code to \n"),
                    TextSpan(
                      text: phone ?? '+91 8757656676',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    TextSpan(text: ". Please enter it below."),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Pinput(
                length: 6,
                autofocus: true,
                autofillHints: const [AutofillHints.oneTimeCode],
                defaultPinTheme: PinTheme(
                  width: 50,
                  height: 55,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onCompleted: (pin) async {
                  print("Entered OTP: $pin");

                  if (phone == null) {
                    Get.snackbar("Error", "Phone number missing");
                    return;
                  }

                  Get.dialog(
                    const Center(child: CircularProgressIndicator()),
                    barrierDismissible: false,
                  );

                  final response = await AuthService().verifyOtp(
                    phone: phone!,
                    otp: pin,
                  );

                  Get.back();

                  if (response['success']) {
                    Get.snackbar("Success", response['message']);

                    Get.offAllNamed('/inspection');
                  } else {
                    Get.snackbar("Error", response['message']);
                  }
                },
              ),
            ),
            Text(
              "Test OTP: ${otp ?? ''}",
              style: TextStyle(color: Colors.grey),
            ),
            Obx(() {
              return controller.canResend.value
                  ? TextButton(
                      /* onPressed: () {
                        if (phone != null) {
                          controller.resendOtp(phone);
                        }
                      },*/
                      onPressed: () {},
                      child: Text(
                        "Resend OTP",
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                      ),
                    )
                  : Text(
                      "Resend OTP in 00:${controller.secondsRemaining.value.toString().padLeft(2, '0')}",
                      style: TextStyle(color: Colors.grey),
                    );
            }),
          ],
        ),
      ),
    );
  }
}

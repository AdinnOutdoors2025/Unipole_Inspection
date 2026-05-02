import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:pinput/pinput.dart';
import 'package:unipole_inspection/screens/inspection_first_screen.dart';

import 'auth_service.dart';
import 'controller/otp_controller.dart';
import 'helper/snackbar.dart';

class OtpScreen extends StatelessWidget {
  final String? phone;
  final String? otp;

  OtpScreen({super.key, this.phone, this.otp});

  final OtpController controller = Get.put(OtpController());

  @override
  Widget build(BuildContext context) {
    final currentLang = Get.locale?.languageCode;
    final isTamil = Get.locale?.languageCode == 'ta';
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
                    TextSpan(
                      text: "${"verification_code".tr} \n",
                      style: TextStyle(fontSize: isTamil ? 14 : 17),
                    ),
                    TextSpan(
                      text: phone ?? '+91 8757656676',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    TextSpan(
                      text: ". ${"enter_code_text".tr}",
                      style: TextStyle(fontSize: isTamil ? 14 : 17),
                    ),
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
                    AppToast.showSuccess(response["message"]);
                    Get.offAllNamed('/inspection');
                  } else {
                    AppToast.showError(response["message"]);
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
                        "resent_otp_text".tr,
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: isTamil ? 14 : 16,
                        ),
                      ),
                    )
                  : Text(
                      "${"resent_otp_in_text".tr} 00:${controller.secondsRemaining.value.toString().padLeft(2, '0')}",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: isTamil ? 14 : 16,
                      ),
                    );
            }),
          ],
        ),
      ),
    );
  }
}

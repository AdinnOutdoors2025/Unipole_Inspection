import 'dart:async';

import 'package:get/get.dart';

import '../auth_service.dart';

class OtpController extends GetxController {
  var secondsRemaining = 30.obs;
  var canResend = false.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  void startTimer() {
    canResend.value = false;
    secondsRemaining.value = 30;

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (secondsRemaining.value == 0) {
        canResend.value = true;
        timer.cancel();
      } else {
        secondsRemaining.value--;
      }
    });
  }

  /*void resendOtp(String phone) async {
    // Call your API
    final response = await AuthService().resendOtp(phone: phone);

    if (response['success']) {
      Get.snackbar("OTP Sent", response['message']);
      startTimer(); // restart timer
    } else {
      Get.snackbar("Error", response['message']);
    }
  }*/

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
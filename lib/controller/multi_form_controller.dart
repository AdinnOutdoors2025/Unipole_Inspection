import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class MultiFormController extends GetxController {
  var currentStep = 0.obs;

  var stepCompleted = [false, false, false, false].obs;

  void goToStep(int index) {
    if (index <= currentStep.value) {
      currentStep.value = index;
      return;
    }

    if (!stepCompleted[index - 1]) {
      Get.snackbar("Not allowed", "Complete previous step first");
      return;
    }

    currentStep.value = index;
  }

  void nextStep(GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      stepCompleted[currentStep.value] = true;

      if (currentStep.value < 3) {
        currentStep.value++;
      }
    }
  }

  void prevStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

}

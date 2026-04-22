import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class InspectionController extends GetxController {
  final heightController = TextEditingController();
  final sizeController = TextEditingController();
  final dateController = TextEditingController();
  late TextEditingController visitedByController;

  var heightUnit = "ft".obs;
  var sizeUnit = "ft".obs;
  var selectedDate = "".obs;

  final storage = const FlutterSecureStorage();
  RxString userName = "".obs;

  @override
  void onInit() {
    super.onInit();

    /*   final userName = Get.arguments;

    visitedByController = TextEditingController(
      text: userName?.toString() ?? "",
    );*/
    visitedByController = TextEditingController();
    loadUser();
    final now = DateTime.now();
    final formattedDate = DateFormat('dd MMMM yyyy').format(now);

    selectedDate.value = formattedDate;
    dateController.text = formattedDate;
  }

  void changeHeightUnit(String unit) {
    heightUnit.value = unit;
  }

  void loadUser() async {
    final name = await storage.read(key: "userName") ?? "";
    userName.value = name;
    visitedByController.text = name;
  }

  void changeSizeUnit(String unit) {
    sizeUnit.value = unit;
  }

  @override
  void onClose() {
    heightController.dispose();
    sizeController.dispose();
    dateController.dispose();
    visitedByController.dispose();
    super.onClose();
  }
}

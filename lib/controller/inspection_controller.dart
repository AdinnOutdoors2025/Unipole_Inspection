import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:unipole_inspection/auth_service.dart';

import '../helper/snackbar.dart';

class InspectionController extends GetxController {
  final heightController = TextEditingController();
  final sizeController = TextEditingController();
  final dateController = TextEditingController();
  final locationController = TextEditingController();
  late TextEditingController visitedByController;

  var heightUnit = "ft".obs;
  var sizeUnit = "ft".obs;
  var selectedDate = "".obs;

  final storage = const FlutterSecureStorage();
  RxString userName = "".obs;
  var isFetchingLocation = false.obs;
  var isLocationFetched = false.obs;
  var isExistingInspection = false.obs;

  var latitude = '--'.obs;
  var longitude = '--'.obs;

  @override
  void onInit() {
    super.onInit();

    visitedByController = TextEditingController();
    loadUser();
    loadInspectionData();
    final now = DateTime.now();
    final formattedDate = DateFormat('dd MMMM yyyy').format(now);

    selectedDate.value = formattedDate;
    dateController.text = formattedDate;
  }

  void loadUser() async {
    final name = await storage.read(key: "userName") ?? "";
    userName.value = name;
    visitedByController.text = name;
  }

  void changeHeightUnit(String unit) {
    heightUnit.value = unit;
    heightController.clear();
  }

  void changeSizeUnit(String unit) {
    sizeUnit.value = unit;
    sizeController.clear();
  }

  String get formattedHeight {
    if (heightController.text.trim().isEmpty) return "";
    return "${heightController.text.trim()} ${heightUnit.value}";
  }

  String get formattedSize {
    if (sizeController.text.trim().isEmpty) return "";

    String size = sizeController.text.trim();

    size = size.replaceAll('x', 'X');

    return "$size ${sizeUnit.value.toUpperCase()}";
  }

  Future<void> fetchLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AppSnackBar.showError("Please enable location services");
      return;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        AppSnackBar.showError("Location permission denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      AppSnackBar.showError("Permission permanently denied");
      return;
    }
    try {
      isFetchingLocation.value = true;
      isLocationFetched.value = false;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude.value = position.latitude.toStringAsFixed(6);
      longitude.value = position.longitude.toStringAsFixed(6);
      isLocationFetched.value = true;
    } catch (e) {
      AppSnackBar.showError("Failed to fetch location");
    } finally {
      isFetchingLocation.value = false;
    }
  }

  final AuthService apiService = AuthService();

  Future<void> submitInspection() async {
    if (heightController.text.isEmpty ||
        sizeController.text.isEmpty ||
        locationController.text.isEmpty ||
        latitude.value == "--") {
      AppSnackBar.showError("Please fill all fields");
      return;
    }

    final result = await apiService.createInspection(
      location: locationController.text.trim(),
      latitude: latitude.value,
      longitude: longitude.value,
      unipoleHeight: formattedHeight,
      adStructureSize: formattedSize,
    );

    if (result["success"]) {
      AppSnackBar.showSuccess(result["message"]);
      Get.toNamed('/multiForm');
    } else {
      AppSnackBar.showError(result["message"]);
    }
  }

  Future<void> loadInspectionData() async {
    final res = await apiService.getInspection();

    if (res.success && res.data != null) {
      isExistingInspection.value = true;

      final data = res.data;

      locationController.text = data.location;
      heightController.text = data.unipoleHeight;
      sizeController.text = data.adStructureSize;
      visitedByController.text = data.visitedBy;

      selectedDate.value = data.visitingDate;
      latitude.value = data.geoLocation.latitude.toString();
      longitude.value = data.geoLocation.longitude.toString();

      isLocationFetched.value = true;
    } else {
      isExistingInspection.value = false;
    }
  }

  @override
  void onClose() {
    /*  heightController.dispose();
    sizeController.dispose();
    dateController.dispose();
    locationController.dispose();
    visitedByController.dispose();*/
    super.onClose();
  }
}

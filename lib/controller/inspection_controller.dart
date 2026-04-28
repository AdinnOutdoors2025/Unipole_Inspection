import 'package:flutter/foundation.dart';
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

  /*var latitude = '--'.obs;
  var longitude = '--'.obs;*/
  RxString latitude = "--".obs;
  RxString longitude = "--".obs;

  @override
  void onInit() {
    super.onInit();

    visitedByController = TextEditingController();
    loadUser();
    loadInspectionData();
    fetchLocation();
    // initInspection();
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
      if (kDebugMode) {
        print(result["message"]);
      }
      Get.toNamed('/multiForm');
    } else {
      AppSnackBar.showError(result["message"]);
    }
  }

  Future<void> loadInspectionData() async {
    print("fehfuewa");
    final res = await apiService.getInspection();
    print("API response received");
    print(res);
    if (res.success && res.data != null) {
      print("Data exists");
      isExistingInspection.value = true;

      final data = res.data;
      print("Location: ${data.location}");
      print("Height: ${data.unipoleHeight}");
      print("Size: ${data.adStructureSize}");
      print("Visited By: ${data.visitedBy}");
      print("Date: ${data.visitingDate}");
      print("Latitude: ${data.geoLocation.latitude}");
      print("Longitude: ${data.geoLocation.longitude}");

      locationController.text = data.location;
      print(locationController.text);
      heightController.text = data.unipoleHeight;
      sizeController.text = data.adStructureSize;
      setHeightFromApi(data.unipoleHeight);
      setSizeFromApi(data.adStructureSize);
      visitedByController.text = data.visitedBy;

      selectedDate.value = data.visitingDate;
      /* latitude.value = data.geoLocation.latitude.toString();
      longitude.value = data.geoLocation.longitude.toString();*/
      latitude.value = data.geoLocation.latitude?.toString() ?? '--';
      longitude.value = data.geoLocation.longitude?.toString() ?? '--';

      isLocationFetched.value = true;
    } else {
      print("No inspection data");
      isExistingInspection.value = false;
    }
  }

  /*Future<void> initInspection() async {
    await loadInspectionData();

    */ /*if (!isExistingInspection.value) {
      fetchLocation();
    }*/ /*
    if (latitude.value == '--' || longitude.value == '--') {
      await fetchLocation();
    }
  }*/
  Future<void> initInspection() async {
    if (kDebugMode) {
      print("initInspection started");
    }

    await loadInspectionData();

    if (kDebugMode) {
      print("isExistingInspection: ${isExistingInspection.value}");
    }
    if (kDebugMode) {
      print("latitude after API: ${latitude.value}");
    }

    if (!isExistingInspection.value || latitude.value == '--' || longitude.value == '--') {
      if (kDebugMode) {
        print("Fetching device location...");
      }
      await fetchLocation();
    } else {
      if (kDebugMode) {
        print("Using API location");
      }
    }
  }

  void setHeightFromApi(String value) {
    if (value.trim().isEmpty) return;

    final parts = value.trim().split(" ");

    // Example: "10 inch" or "10 ft ft"
    heightController.text = parts.first;

    if (parts.length > 1) {
      heightUnit.value = parts.last.toLowerCase();
    }
  }

  void setSizeFromApi(String value) {
    if (value.trim().isEmpty) return;

    final parts = value.trim().split(" ");

    // Example: "10 X 40 FT"
    if (parts.length >= 3) {
      sizeController.text = "${parts[0]} ${parts[1]} ${parts[2]}";
    } else {
      sizeController.text = parts.first;
    }

    if (parts.length > 3) {
      sizeUnit.value = parts.last.toLowerCase();
    }
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unipole_inspection/auth_service.dart';
import '../model/inspection_details_model.dart';

class AdminInspectionController extends GetxController {
  var allList = <Datas>[].obs;
  var visibleList = <Datas>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  int pageSize = 10;
  int currentPage = 0;
  Timer? _debounce;
  String searchName = "";
  String searchPhone = "";
  String? fromDate;
  String? toDate;
  int? status;
  String? inspectionStatus;
  var tempStatus = RxnInt();
  var tempInspection = RxnString();
  var tempFromDate = RxnString();
  var tempToDate = RxnString();
  String locationSearch = "";
  var hasLoadedOnce = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInspections();
  }

  Future<void> pickDateRange() async {
    final picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      fromDate = picked.start.toIso8601String().split("T").first;
      toDate = picked.end.toIso8601String().split("T").first;
      fetchInspections();
    }
  }

  void filterByStatus(int value) {
    status = value;
    fetchInspections();
  }

  /*void searchByName(String value) {
    searchName = value;

    Future.delayed(Duration(milliseconds: 500), () {
      if (value == searchName) {
        fetchInspections();
      }
    });
  }*/
  /* void onSearchChanged(String value) {
    final text = value.trim();

    /// Reset all first
    searchName = "";
    searchPhone = "";
    locationSearch = "";

    if (text.isEmpty) {
      fetchInspections();
      return;
    }

    /// Phone (only numbers)
    if (RegExp(r'^\d+$').hasMatch(text)) {
      searchPhone = text;
    }
    /// Name (alphabets only - simple assumption)
    else if (RegExp(r'^[a-zA-Z ]+$').hasMatch(text)) {
      searchName = text;
    }
    /// Otherwise → treat as location
    else {
      locationSearch = text;
    }

    Future.delayed(Duration(milliseconds: 500), () {
      fetchInspections();
    });
  }*/
  void onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(Duration(milliseconds: 500), () {
      final text = value.trim();

      /// reset all
      searchName = "";
      searchPhone = "";
      locationSearch = "";

      if (text.isEmpty) {
        fetchInspections();
        return;
      }

      if (RegExp(r'^\d+$').hasMatch(text)) {
        searchPhone = text;
      }
      else if (RegExp(r'^[a-zA-Z ]+$').hasMatch(text)) {
        searchName = text;
      }
      else {
        locationSearch = text;
      }

      fetchInspections();
    });
  }

  /*Future<void> fetchInspections() async {
    try {
      isLoading.value = true;
      final response = await AuthService().getInspectionDetails();
      allList.value = response.data ?? [];
      loadMore();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      isLoading.value = false;
    }
  }*/

  void applyFilterFromSheet() {
    status = tempStatus.value;
    fromDate = tempFromDate.value;
    toDate = tempToDate.value;
    inspectionStatus = tempInspection.value;

    fetchInspections();
  }

  void resetFilters() {
    tempStatus.value = null;
    tempInspection.value = null;
    tempFromDate.value = null;
    tempToDate.value = null;
  }

  Future<void> fetchInspections() async {
    try {
      isLoading.value = true;

      final response = await AuthService().getInspectionDetails(
        name: searchName,
        phone: searchPhone,
        fromDate: fromDate,
        toDate: toDate,
        status: status,
        inspectionStatus: inspectionStatus,
      );

      /* allList.value = response.data ?? [];*/
      List<Datas> list = response.data ?? [];

      if (locationSearch.isNotEmpty) {
        list = list.where((item) {
          return (item.location ?? "").toLowerCase().contains(
            locationSearch.toLowerCase(),
          );
        }).toList();
      }

      allList.value = list;
      visibleList.clear();
      currentPage = 0;

      loadMore();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      isLoading.value = false;
      hasLoadedOnce.value = true;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value) return;

    int start = currentPage * pageSize;
    if (start >= allList.length) return;

    isLoadingMore.value = true;

    await Future.delayed(Duration(seconds: 1));

    int end = start + pageSize;
    if (end > allList.length) end = allList.length;

    visibleList.addAll(allList.sublist(start, end));

    currentPage++;
    isLoadingMore.value = false;
  }

  void refreshList() {
    visibleList.clear();
    currentPage = 0;
    loadMore();
  }
}

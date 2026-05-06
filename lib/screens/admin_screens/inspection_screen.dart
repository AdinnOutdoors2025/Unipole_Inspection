import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:unipole_inspection/controller/admin_inspection_controller.dart';

final inspectionMap = {
  "Good": "good",
  "Minor": "minor",
  "Critical": "critical",
};

class InspectionScreen extends StatelessWidget {
  final controller = Get.find<AdminInspectionController>();
  final ScrollController scrollController = ScrollController();

  InspectionScreen({super.key}) {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100) {
        controller.loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            buildFilterBar(),
            Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              return Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => controller.refreshList(),
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: controller.visibleList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == controller.visibleList.length) {
                        return Obx(
                          () => controller.isLoadingMore.value
                              ? Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : SizedBox(),
                        );
                      }
                      final item = controller.visibleList[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.visitedBy ?? "No Name",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: item.inspectionStatus == 1
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        item.inspectionStatus == 1
                                            ? "Completed"
                                            : "Pending",
                                        style: TextStyle(
                                          color: item.inspectionStatus == 1
                                              ? Colors.green
                                              : Colors.orange,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 10),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 6),
                                    Text(item.visitedByPhone ?? ""),
                                  ],
                                ),

                                SizedBox(height: 6),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        item.location ?? "",
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 6),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 6),
                                    Text(item.visitingDate ?? ""),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

Widget buildFilterBar() {
  final controller = Get.find<AdminInspectionController>();

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (value) {
              controller.onSearchChanged(value);
            },
            decoration: InputDecoration(
              hintText: "Search name",
              hintStyle: TextStyle(fontSize: 14),
              prefixIcon: Icon(Icons.search, size: 14),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey, width: 1.4),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),

        SizedBox(width: 8),

        /*IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () {
            controller.pickDateRange();
          },
        ),

        PopupMenuButton<int>(
          icon: Icon(Icons.filter_list),
          onSelected: (value) {
            controller.filterByStatus(value);
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 1, child: Text("Completed")),
            PopupMenuItem(value: 0, child: Text("In Progress")),
          ],
        ),
        SizedBox(
          width: 100, // important inside Row
          child: DropdownButtonFormField<String>(
            hint: Text("Status"),
            //   value: controller.selectedStatus, // make sure this exists
            items: ['Good', 'Critical', 'Bad'].map((status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (value) {
              //    controller.selectedStatus = value!;
              // controller.filterByStatus(value);
            },
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey, width: 1.4),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),*/
        IconButton(
          icon: Icon(Icons.filter_list),
          onPressed: () {
            showModalBottomSheet(
              context: Get.context!,
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => FilterBottomSheet(),
            );
          },
        ),
      ],
    ),
  );
}

class FilterBottomSheet extends StatelessWidget {
  FilterBottomSheet({super.key});

  final controller = Get.find<AdminInspectionController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Filters",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(height: 20),

          Text("Status", style: TextStyle(fontWeight: FontWeight.w600)),
          Obx(
            () => Column(
              children: [
                RadioListTile<int>(
                  title: Text("Completed"),
                  value: 1,
                  groupValue: controller.tempStatus.value,
                  onChanged: (val) {
                    controller.tempStatus.value = val;
                  },
                ),
                RadioListTile<int>(
                  title: Text("In Progress"),
                  value: 0,
                  groupValue: controller.tempStatus.value,
                  onChanged: (val) {
                    controller.tempStatus.value = val;
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 10),

          Text("Inspection", style: TextStyle(fontWeight: FontWeight.w600)),

          Obx(
            () => Wrap(
              spacing: 8,
              children: inspectionMap.keys.map((label) {
                return ChoiceChip(
                  label: Text(label),
                  selected:
                      controller.tempInspection.value == inspectionMap[label],
                  onSelected: (_) {
                    controller.tempInspection.value = inspectionMap[label];
                  },
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 20),

          Text("Date Range", style: TextStyle(fontWeight: FontWeight.w600)),

          SizedBox(height: 8),

          Obx(
            () => GestureDetector(
              onTap: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );

                if (picked != null) {
                  controller.tempFromDate.value = picked.start
                      .toIso8601String()
                      .split("T")
                      .first;
                  controller.tempToDate.value = picked.end
                      .toIso8601String()
                      .split("T")
                      .first;
                }
              },
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  controller.tempFromDate.value == null
                      ? "Select Date Range"
                      : "${controller.tempFromDate.value} → ${controller.tempToDate.value}",
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    controller.resetFilters();
                  },
                  child: Text("Reset"),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    controller.applyFilterFromSheet();
                    Get.back();
                  },
                  child: Text("Apply"),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

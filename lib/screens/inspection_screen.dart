import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/inspection_controller.dart';
import 'inspection_screens/multi_step_form.dart';

class InspectionScreen extends StatelessWidget {
  final String? userName;

  InspectionScreen({super.key, this.userName});

  final controller = Get.find<InspectionController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/images/adinn_logo.png', height: 40),

                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: const [
                          Text("தமிழ்", style: TextStyle(color: Colors.red)),
                          SizedBox(width: 5),
                          Text("|"),
                          SizedBox(width: 5),
                          Text("English", style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              const Text(
                "Fill Inspection Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                "Enter unipole details to start inspection",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 15),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    children: [
                      buildTextField(
                        label: "Unipole Height",
                        hint: "Enter height",
                        icon: Icons.height,
                        controller: controller.heightController,

                        suffixWidget: Obx(
                          () => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                buildUnit(
                                  unit: "ft",
                                  selectedUnit: controller.heightUnit.value,
                                  onChanged: controller.changeHeightUnit,
                                ),
                                buildUnit(
                                  unit: "inch",
                                  selectedUnit: controller.heightUnit.value,
                                  onChanged: controller.changeHeightUnit,
                                ),
                                buildUnit(
                                  unit: "cm",
                                  selectedUnit: controller.heightUnit.value,
                                  onChanged: controller.changeHeightUnit,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      buildTextField(
                        label: "Ad Structure Size",
                        hint: "Enter size (W x H)",
                        icon: Icons.aspect_ratio,
                        controller: controller.sizeController,
                        suffixWidget: Obx(
                          () => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                buildUnit(
                                  unit: "ft",
                                  selectedUnit: controller.sizeUnit.value,
                                  onChanged: controller.changeSizeUnit,
                                ),
                                buildUnit(
                                  unit: "inch",
                                  selectedUnit: controller.sizeUnit.value,
                                  onChanged: controller.changeSizeUnit,
                                ),
                                buildUnit(
                                  unit: "cm",
                                  selectedUnit: controller.sizeUnit.value,
                                  onChanged: controller.changeSizeUnit,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Visiting Date",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.red,
                              ),
                              Text(
                                controller.selectedDate.value.isEmpty
                                    ? "Select Date"
                                    : controller.selectedDate.value,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      buildTextField(
                        label: "Visited By",
                        icon: Icons.person,
                        controller: controller.visitedByController,
                        readOnly: true,
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            print(controller.heightController.text);
                            print(controller.sizeController.text);

                            Get.to(() => MultiStepForm());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Next",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    String? hint,
    required IconData icon,
    TextEditingController? controller,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            ?suffixWidget,
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.red),
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildUnit({
    required String unit,
    required String selectedUnit,
    required Function(String) onChanged,
  }) {
    final isSelected = selectedUnit == unit;

    return GestureDetector(
      onTap: () {
        onChanged(unit);
        print("$unit clicked");
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          unit,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

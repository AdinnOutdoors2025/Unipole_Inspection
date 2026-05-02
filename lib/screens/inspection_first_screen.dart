import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth_service.dart';
import '../controller/inspection_controller.dart';
import '../widgets/size_Input_formatter.dart';
import 'inspection_screens/multi_step_form.dart';

class InspectionFirstScreen extends StatelessWidget {
  const InspectionFirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InspectionController>();
    final isTamil = Get.locale?.languageCode == 'ta';
    final currentLang = Get.locale?.languageCode;
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
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString('lang', 'ta');
                              Get.updateLocale(const Locale('ta', 'IN'));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: currentLang == 'ta'
                                    ? Colors.red
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "தமிழ்",
                                style: TextStyle(
                                  color: currentLang == 'ta'
                                      ? Colors.white
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 2),

                          GestureDetector(
                            onTap: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString('lang', 'en');

                              Get.updateLocale(const Locale('en', 'US'));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: currentLang == 'en'
                                    ? Colors.red
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "English",
                                style: TextStyle(
                                  color: currentLang == 'en'
                                      ? Colors.white
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Image.asset('assets/images/adinn_logo.png', height: 40),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "inspection_first_screen_title".tr,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isTamil ? 15 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),

              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "inspection_first_screen_subtitle".tr,
                  style: TextStyle(fontSize: isTamil ? 11 : 15),
                ),
              ),

              const SizedBox(height: 15),

              Padding(
                padding: const EdgeInsets.all(12),
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
                        label: "unipole_height".tr,
                        hint: "unipole_height_hintText".tr,
                        icon: Icons.height,
                        controller: controller.heightController,
                        keyboardType: TextInputType.number,
                        suffixWidget: Obx(
                          () => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
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

                      Obx(
                        () => buildTextField(
                          label: "ad_structure_size".tr,
                          hint: "ad_structure_size_hintText".tr,
                          icon: Icons.aspect_ratio,
                          inputFormatters: [SizeInputFormatter()],
                          controller: controller.sizeController,
                          suffixWidget: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
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
                            "visiting_date".tr,
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
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.red,
                              ),
                              SizedBox(width: 17),
                              Text(controller.selectedDate.value),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      buildTextField(
                        label: "location".tr,
                        icon: Icons.location_on_rounded,
                        controller: controller.locationController,
                        hint: "address_hintText".tr,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey, width: 1),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Row(
                                children: [
                                  Icon(Icons.location_on),
                                  SizedBox(width: 1),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Obx(
                                () => Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          controller.latitude.value == '--'
                                              ? "Latitude"
                                              : controller.latitude.value,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight:
                                                controller.latitude.value ==
                                                    "--"
                                                ? FontWeight.w100
                                                : FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Obx(
                              () => Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        controller.longitude.value == '--'
                                            ? "Longitude"
                                            : controller.longitude.value,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight:
                                              controller.longitude.value == "--"
                                              ? FontWeight.w100
                                              : FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      buildTextField(
                        label: "visiting_by".tr,
                        icon: Icons.person,
                        controller: controller.visitedByController,
                        readOnly: true,
                      ),

                      const SizedBox(height: 20),

                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              controller.submitInspection();
                            },
                            style:
                                ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ).copyWith(
                                  overlayColor: MaterialStateProperty.all(
                                    Colors.white.withOpacity(0.5),
                                  ),
                                ),
                            child: Text(
                              controller.isExistingInspection.value
                                  ? "continue_button".tr
                                  : "next_button".tr,

                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await AuthService().logout();
                  Get.offAllNamed('/login');
                },
                child: Text("Logout"),
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
    List<SizeInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),

            if (suffixWidget != null) suffixWidget,
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.red),
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13),
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
    final isTamil = Get.locale?.languageCode == 'ta';
    return GestureDetector(
      onTap: () {
        onChanged(unit);
        print("$unit clicked");
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(horizontal: isTamil ? 4 : 7, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          unit.tr,
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
